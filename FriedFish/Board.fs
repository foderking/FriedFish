module FriedFish.Board
    open System.Text
    open System.Text.RegularExpressions
    open FriedFish.BitBoard
    
    /// The Forsyth–Edwards Notation representation of the board state
    type FenRecord = {
        pieces: string // piece data for each rank arranged in reverse (from Rank 8 to 1)
        family: Family
        castling: string
        en_passant: ValueOption<string>
        half_move: int
        full_move: int
    }
    with
        static member fen_regex = new Regex(
            @"^(?<pieces>(?:[rnbqkpRNBQKP1-8]+\/){7}[rnbqkpRNBQKP1-8]+) (?<color>[bw]) (?<castling>(?:K?Q?k?q?)|-) (?<ep>-|[a-h][1-8]) (?<halfmove>\d+) (?<fullmove>\d+)$",
            RegexOptions.Compiled
        )
        static member parse(fen: string): Option<FenRecord> =
            match FenRecord.fen_regex.Match(fen) with
            | m when m.Success ->
                Some {
                    pieces     = m.Groups["pieces"].Value
                    family     = if m.Groups["color"].Value[0] = 'w' then Family.White else Family.Black
                    castling   = m.Groups["castling"].Value
                    en_passant = if m.Groups["ep"].Value = "-" then ValueNone else ValueSome(m.Groups["ep"].Value)
                    half_move  = int m.Groups["halfmove"].Value
                    full_move  = int m.Groups["fullmove"].Value
                }
            | _ -> None
        static member default_fen(): FenRecord =
            FenRecord.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            |> Option.get
            
    type Board() =
        let mutable _black = Array.zeroCreate<BitBoard> piece_count
        let mutable _white = Array.zeroCreate<BitBoard> piece_count
        let mutable _black_pieces: Bitboard = 0UL
        let mutable _white_pieces: Bitboard = 0UL
        let mutable _en_passant  : BitBoard = 0UL
        let mutable _occupied    : BitBoard = 0UL
        let mutable _active_family: Family = Family.White
        let mutable _half_moves = 0
        let mutable _full_moves = 0
        let mutable _castling   = 0
        
        static member create(fen: FenRecord): Board =
            let board = Board()
            board.setFen(fen)
            board;
        
        member private this._setBit(family: Family, piece: Piece, square: int) =
            match family with
            | Family.Black -> _black[int piece] <- _black[int piece] ||| (1UL <<< square)
            | Family.White -> _white[int piece] <- _white[int piece] ||| (1UL <<< square)
            | _ -> ()
        
        member private this._setCastle(castle: CastleField) =
            _castling <- _castling ||| int castle
        
        member private this._getCastle(castle: CastleField) =
            (_castling &&& int castle) > 0
        
        member private this._parseSquareNotation(square: string) =
            Helpers.squareFromRankFile(int square[1] - int '1', int square[0] - int 'a')
            
        member private this._getSquareNotation(square: int) =
            let rank, file = Helpers.extractRankFile(square)
            sprintf "%c%d" (char(file + int 'a')) (rank+1)
            
        member private this._updateRedundant() =
            _black_pieces <- 0UL
            _white_pieces <- 0UL
            for bb in _black do
                _black_pieces <- _black_pieces  ||| bb
            for wb in _white do
                _white_pieces <- _white_pieces  ||| wb
            _occupied <- _black_pieces ||| _white_pieces
        
        member private this._updateCastling(castle: string) =
            for ch in castle do
                match ch with
                | 'q' -> this._setCastle(CastleField.BlackQueen)
                | 'k' -> this._setCastle(CastleField.BlackKing)
                | 'Q' -> this._setCastle(CastleField.WhiteQueen)
                | 'K' -> this._setCastle(CastleField.WhiteKing)
                | _   -> ()
                
        member private this._updatePieces(pieces: string) =
            let mutable position = 56
            for ch in pieces do
                match ch with
                | 'p' -> this._setBit(Family.Black, Piece.Pawn, position); position <- position + 1
                | 'r' -> this._setBit(Family.Black, Piece.Rook, position); position <- position + 1
                | 'n' -> this._setBit(Family.Black, Piece.Knight, position); position <- position + 1
                | 'b' -> this._setBit(Family.Black, Piece.Bishop, position); position <- position + 1
                | 'q' -> this._setBit(Family.Black, Piece.Queen, position); position <- position + 1
                | 'k' -> this._setBit(Family.Black, Piece.King, position); position <- position + 1
                | 'P' -> this._setBit(Family.White, Piece.Pawn, position); position <- position + 1
                | 'R' -> this._setBit(Family.White, Piece.Rook, position); position <- position + 1
                | 'N' -> this._setBit(Family.White, Piece.Knight, position); position <- position + 1
                | 'B' -> this._setBit(Family.White, Piece.Bishop, position); position <- position + 1
                | 'Q' -> this._setBit(Family.White, Piece.Queen, position); position <- position + 1
                | 'K' -> this._setBit(Family.White, Piece.King, position); position <- position + 1
                | '/' -> position <- position - 16
                | num -> position <- position + (int num - int '0')
            
        member this.reset()=
            for piece in 0..piece_count-1 do
                _black[piece] <- 0UL
                _white[piece] <- 0UL
            _occupied    <- 0UL
            _en_passant  <- 0UL
            _black_pieces <- 0UL
            _white_pieces <- 0UL
            
        member this.setFen(fen: FenRecord)=
            _active_family <- fen.family
            _half_moves <- fen.half_move
            _full_moves <- fen.full_move
            _en_passant <- 
                fen.en_passant
                |> ValueOption.map (this._parseSquareNotation >> Helpers.createFromSquare)
                |> ValueOption.defaultValue 0UL
            this._updateCastling(fen.castling)
            this._updatePieces(fen.pieces)
            this._updateRedundant()

        member this.createFen(): FenRecord =
            let piece_builder = StringBuilder()
            
            for rank= int Ranks.RANK_8 downto int Ranks.RANK_1 do
                let mutable count =  0
                for file in int Files.FILE_A.. int Files.FILE_H do
                    let square = Helpers.squareFromRankFile(rank, file)
                    if this.isPositionOccupied(square) then
                        if count > 0 then
                            piece_builder.Append(count) |> ignore
                            count <- 0
                        let piece_char = 
                            match this.getPieceAtPosition(square) with
                            | (Family.Black, Piece.King)   -> 'k'
                            | (Family.Black, Piece.Queen)  -> 'q'
                            | (Family.Black, Piece.Bishop) -> 'b'
                            | (Family.Black, Piece.Knight) -> 'n'
                            | (Family.Black, Piece.Rook)   -> 'r'
                            | (Family.Black, Piece.Pawn)   -> 'p'
                            | (Family.White, Piece.King)   -> 'K'
                            | (Family.White, Piece.Queen)  -> 'Q'
                            | (Family.White, Piece.Bishop) -> 'B'
                            | (Family.White, Piece.Knight) -> 'N'
                            | (Family.White, Piece.Rook)   -> 'R'
                            | (Family.White, Piece.Pawn)   -> 'P'                           
                            | _ -> failwith "unexpected"
                        piece_builder.Append( piece_char ) |> ignore
                    else
                        count <- count + 1
                if count > 0 then
                    piece_builder.Append(count) |> ignore
                    count <- 0
                piece_builder.Append('/') |> ignore
            
            piece_builder.Length <- piece_builder.Length-1 // remove trailing slash
            
            let bk = this._getCastle(CastleField.BlackKing)
            let bq = this._getCastle(CastleField.BlackQueen)
            let wk = this._getCastle(CastleField.WhiteKing)
            let wq = this._getCastle(CastleField.WhiteQueen)
            let castle = bk || bq || wk || wq
            let txt(pred: bool)(value: string) = if pred then value else ""
            {
                 pieces = piece_builder.ToString()
                 castling =
                     if castle then sprintf "%s%s%s%s" (txt wk "K")(txt wq "Q")(txt bk "k")(txt bq "q")
                     else "-"
                 en_passant = ValueOption.map this._getSquareNotation (Helpers.extractSquare(_en_passant))
                 half_move = _half_moves
                 full_move = _full_moves
                 family = _active_family
            }
            
        member this.isPositionOccupied(position: int) =
            Helpers.intersection(_occupied, Helpers.createFromSquare(position))
            
        member this.getPieceAtPosition(position: int) =
            let posBB = Helpers.createFromSquare(position)
            if      Helpers.intersection(_black[int Piece.Pawn], posBB) then (Family.Black, Piece.Pawn)
            else if Helpers.intersection(_black[int Piece.Rook], posBB) then (Family.Black, Piece.Rook)
            else if Helpers.intersection(_black[int Piece.Bishop], posBB) then (Family.Black, Piece.Bishop)
            else if Helpers.intersection(_black[int Piece.Knight], posBB) then (Family.Black, Piece.Knight)
            else if Helpers.intersection(_black[int Piece.Queen], posBB) then (Family.Black, Piece.Queen)
            else if Helpers.intersection(_black[int Piece.King], posBB) then (Family.Black, Piece.King)
            else if Helpers.intersection(_white[int Piece.Pawn], posBB) then (Family.White, Piece.Pawn)
            else if Helpers.intersection(_white[int Piece.Rook], posBB) then (Family.White, Piece.Rook)
            else if Helpers.intersection(_white[int Piece.Bishop], posBB) then (Family.White, Piece.Bishop)
            else if Helpers.intersection(_white[int Piece.Knight], posBB) then (Family.White, Piece.Knight)
            else if Helpers.intersection(_white[int Piece.Queen], posBB) then (Family.White, Piece.Queen)
            else if Helpers.intersection(_white[int Piece.King], posBB) then (Family.White, Piece.King)               
            else
                failwith "not expected"
