module FriedFish.Board

    open System
    open FriedFish.BitBoard
    type FenString = FenString of string
        with
        static member parse(fen: string): Option<FenString> =
            None
        static member default_fen(): FenString =
            FenString("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    
    type Board()=
        let mutable _black = Array.zeroCreate<BitBoard> piece_count
        let mutable _white = Array.zeroCreate<BitBoard> piece_count
        let mutable _black_pieces: Bitboard = 0UL
        let mutable _white_pieces: Bitboard = 0UL
        let mutable _en_passant  : BitBoard = 0UL
        let mutable _occupied    : BitBoard = 0UL
        
        static member create(fen: FenString): Board =
            let board = Board()
            board.setFen(fen)
            board;
        
        member this.setBit(family: Family, piece: Piece, square: int) =
            match family with
            | Family.Black ->
                _black[int piece] <- _black[int piece] ||| (1UL <<< square)
            | Family.White ->
                _white[int piece] <- _white[int piece] ||| (1UL <<< square)
            | _ -> ()
                
        member this.clear()=
            for piece in 0..piece_count-1 do
                _black[piece] <- 0UL
                _white[piece] <- 0UL
            _occupied    <- 0UL
            _en_passant  <- 0UL
            _black_pieces <- 0UL
            _white_pieces <- 0UL
            
        member this.setFen(FenString fen)=
            let paritions = fen.Split(' ', StringSplitOptions.RemoveEmptyEntries)
            let piecePlacement = paritions[0]
            let mutable boardPos =  56
            
            for c in piecePlacement do
                match c with
                | 'p' ->
                    this.setBit(Family.Black, Piece.Pawn  , boardPos)
                    boardPos <- boardPos + 1
                | 'r' ->
                    this.setBit(Family.Black, Piece.Rook  , boardPos)
                    boardPos <- boardPos + 1
                | 'n' ->
                    this.setBit(Family.Black, Piece.Knight, boardPos)
                    boardPos <- boardPos + 1
                | 'b' ->
                    this.setBit(Family.Black, Piece.Bishop, boardPos)
                    boardPos <- boardPos + 1
                | 'q' ->
                    this.setBit(Family.Black, Piece.Queen , boardPos)
                    boardPos <- boardPos + 1
                | 'k' ->
                    this.setBit(Family.Black, Piece.King  , boardPos)
                    boardPos <- boardPos + 1
                | 'P' ->
                    this.setBit(Family.Black, Piece.Pawn  , boardPos)
                    boardPos <- boardPos + 1
                | 'R' ->
                    this.setBit(Family.Black, Piece.Rook  , boardPos)
                    boardPos <- boardPos + 1
                | 'N' ->
                    this.setBit(Family.Black, Piece.Knight, boardPos)
                    boardPos <- boardPos + 1
                | 'B' ->
                    this.setBit(Family.Black, Piece.Bishop, boardPos)
                    boardPos <- boardPos + 1
                | 'Q' ->
                    this.setBit(Family.Black, Piece.Queen , boardPos)
                    boardPos <- boardPos + 1
                | 'K' ->
                    this.setBit(Family.Black, Piece.King  , boardPos)
                    boardPos <- boardPos + 1
                | '/' ->
                    boardPos <- boardPos - 16
                | _   ->
                    boardPos <- boardPos + int (string c)