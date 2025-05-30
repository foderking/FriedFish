module FriedFish.Board
    open System.Text.RegularExpressions
    open FriedFish.BitBoard
    
    /// The Forsyth–Edwards Notation representation of the board state
    type FenRecord = {
        pieces: string // piece data for each rank arranged in reverse (from Rank 8 to 1)
        family: Family
        castling: string
        en_passant: ValueOption<int>
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
                    en_passant = if m.Groups["ep"].Value = "-" then ValueNone else ValueSome(int m.Groups["ep"].Value)
                    half_move  = int m.Groups["halfmove"].Value
                    full_move  = int m.Groups["fullmove"].Value
                }
            | _ -> None
            
        static member default_fen(): FenRecord =
            FenRecord.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            |> Option.get
           
    type CastleField =
        | BlackQueen = 0b0001
        | BlackKing  = 0b0010
        | WhiteQueen = 0b0100
        | WhiteKing  = 0b1000
            
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
            | Family.Black ->
                _black[int piece] <- _black[int piece] ||| (1UL <<< square)
            | Family.White ->
                _white[int piece] <- _white[int piece] ||| (1UL <<< square)
            | _ -> ()
        
        member private this._setCastle(castle: CastleField) =
            _castling <- _castling ||| int castle
            
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
            _en_passant <- BitBoard.createFromSquare(ValueOption.defaultValue 0 fen.en_passant)
            
            for ch in fen.castling do
                match ch with
                | 'q' -> this._setCastle(CastleField.BlackQueen)
                | 'k' -> this._setCastle(CastleField.BlackKing)
                | 'Q' -> this._setCastle(CastleField.WhiteQueen)
                | 'K' -> this._setCastle(CastleField.WhiteKing)
                | _   -> ()
                    
            let mutable position = 56
            for ch in fen.pieces do
                match ch with
                | 'p' ->
                    this._setBit(Family.Black, Piece.Pawn, position)
                    position <- position + 1
                | 'r' ->
                    this._setBit(Family.Black, Piece.Rook, position)
                    position <- position + 1
                | 'n' ->
                    this._setBit(Family.Black, Piece.Knight, position)
                    position <- position + 1
                | 'b' ->
                    this._setBit(Family.Black, Piece.Bishop, position)
                    position <- position + 1
                | 'q' ->
                    this._setBit(Family.Black, Piece.Queen, position)
                    position <- position + 1
                | 'k' ->
                    this._setBit(Family.Black, Piece.King, position)
                    position <- position + 1
                | 'P' ->
                    this._setBit(Family.White, Piece.Pawn, position)
                    position <- position + 1
                | 'R' ->
                    this._setBit(Family.White, Piece.Rook, position)
                    position <- position + 1
                | 'N' ->
                    this._setBit(Family.White, Piece.Knight, position)
                    position <- position + 1
                | 'B' ->
                    this._setBit(Family.White, Piece.Bishop, position)
                    position <- position + 1
                | 'Q' ->
                    this._setBit(Family.White, Piece.Queen, position)
                    position <- position + 1
                | 'K' ->
                    this._setBit(Family.White, Piece.King, position)
                    position <- position + 1
                | '/' ->
                    position <- position - 16
                | num ->
                    position <- position + (int num - int '0')

        //member this.createFen(): FenString =
            //FenString("")