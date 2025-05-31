/// Types and functions for using a lookup table
module FriedFish.Lookup
    open FriedFish.BitBoard

    type Lookups() =
        member val private _fileMasks = [|
            0x0101010101010101UL
            0x0202020202020202UL
            0x0404040404040404UL
            0x0808080808080808UL
            0x1010101010101010UL
            0x2020202020202020UL
            0x4040404040404040UL
            0x8080808080808080UL
        |]
        member val private _rankMasks = [|
            0x00000000000000FFUL
            0x000000000000FF00UL
            0x0000000000FF0000UL
            0x00000000FF000000UL
            0x000000FF00000000UL
            0x0000FF0000000000UL
            0x00FF000000000000UL
            0xFF00000000000000UL
        |]
        member val private _knightAttacks = Array.zeroCreate<BitBoard> square_count
        member val private _kingAttacks = Array.zeroCreate<BitBoard> square_count
        member val private _blackPawnAttacks = Array.zeroCreate<BitBoard> square_count
        member val private _whitePawnAttacks = Array.zeroCreate<BitBoard> square_count

        /// Generate attack bitboard for knight from scratch
        /// https://www.chessprogramming.org/Knight_Pattern#by_Calculation
        member this._initKnight(bb: BitBoard, square: int) =
            let notG = ~~~this._fileMasks[int Files.FILE_G]
            let notH = ~~~this._fileMasks[int Files.FILE_H]
            let notGH = notG &&& notH
            let notA = ~~~this._fileMasks[int Files.FILE_A]
            let notB = ~~~this._fileMasks[int Files.FILE_B]
            let notAB = notA &&& notB
    
            this._knightAttacks[square] <- 
                0UL
                |> (|||) (Helpers.shift -17 (bb &&& notA)) // noNoEa
                |> (|||) (Helpers.shift  15 (bb &&& notA)) // soSoEa
                |> (|||) (Helpers.shift -10 (bb &&& notAB)) // noEaEa
                |> (|||) (Helpers.shift   6 (bb &&& notAB)) // soEaEa
                |> (|||) (Helpers.shift -15 (bb &&& notH)) // noNoWe
                |> (|||) (Helpers.shift  17 (bb &&& notH)) // soSoWe
                |> (|||) (Helpers.shift  -6 (bb &&& notGH)) // noWeWe
                |> (|||) (Helpers.shift  10 (bb &&& notGH)) // soWeWe
            
        /// Generate attack bitboard for king from scratch.
        /// Uses the same concept as `calcKnightAttack`
        member this._initKing(bb: BitBoard, square: int) =
            let notA = ~~~this._fileMasks[int Files.FILE_A]
            let notH = ~~~this._fileMasks[int Files.FILE_H]
            
            this._kingAttacks[square] <-
                0UL
                |> (|||) (Bitboards.shift 9 (bb &&& notH))
                |> (|||) (Bitboards.shift 1 (bb &&& notH))
                |> (|||) (Bitboards.shift -7 (bb &&& notH))
                |> (|||) (Bitboards.shift 8 bb)
                |> (|||) (Bitboards.shift -8 bb)
                |> (|||) (Bitboards.shift -9 (bb &&& notA))
                |> (|||) (Bitboards.shift -1 (bb &&& notA))
                |> (|||) (Bitboards.shift 7 (bb &&& notA))
        member this._initPawn(bb: BitBoard, square: int) =
            let notA = ~~~this._fileMasks[int Files.FILE_A]
            let notH = ~~~this._fileMasks[int Files.FILE_H]
            // white pawns move up while black pawns move down
            this._whitePawnAttacks[square] <-
                Bitboards.Empty
                |> (|||) (Bitboards.shift 9 (bb &&& notH))
                |> (|||) (Bitboards.shift 7 (bb &&& notA))
            this._blackPawnAttacks[square] <-
                Bitboards.Empty
                |> (|||) (Bitboards.shift -9 (bb &&& notA))
                |> (|||) (Bitboards.shift -7 (bb &&& notH))               
        member this.init() =
            for i in 0..63 do
                let bb = Helpers.createFromSquare(i)
                this._initKnight(bb, i)
                this._initKing(bb, i)
                this._initPawn(bb, i)
                
        member this.getAttack(family: Family, piece: Piece, from_sq: int, to_sq: int) : BitBoard =
            match piece with
            | Piece.Bishop -> 0UL
            | Piece.Queen  -> 0UL
            | Piece.Rook   -> 0UL
            | _ -> this.getAttack(family, piece, from_sq)
               
        member this.getAttack(family: Family, piece: Piece, square: int) : BitBoard =
            match piece with
            | Piece.Knight -> this._knightAttacks[square]
            | Piece.King   -> this._kingAttacks[square]
            | Piece.Pawn when family = Family.White -> this._whitePawnAttacks[square]
            | Piece.Pawn when family = Family.Black -> this._blackPawnAttacks[square]
            | _ -> failwith "unexpected"


    /// https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
    let calcRayAttack (maskFile: Bitboard[]) (ray: Ray) (sq: int) =
        let northSouthPrefix (shiftCount: int) (bb: Bitboard) = bb ||| (Bitboards.shift shiftCount bb)

        let otherPrefix (shiftCount: int) (propagator: Bitboard) (bb: Bitboard) =
            bb ||| (propagator &&& (Bitboards.shift shiftCount bb))

        let bb = Bitboards.create sq

        match ray with
        | Ray.North ->
            bb
            |> northSouthPrefix 8
            |> northSouthPrefix 16
            |> northSouthPrefix 32
            |> (&&&) ~~~bb
        | Ray.South ->
            bb
            |> northSouthPrefix -8
            |> northSouthPrefix -16
            |> northSouthPrefix -32
            |> (&&&) ~~~bb
        | Ray.East ->
            let pr0 = ~~~maskFile[int File._A]
            let pr1 = pr0 &&& (Bitboards.shift 1 pr0)
            let pr2 = pr1 &&& (Bitboards.shift 2 pr1)
            bb |> otherPrefix 1 pr0 |> otherPrefix 2 pr1 |> otherPrefix 4 pr2 |> (&&&) ~~~bb
        | Ray.West ->
            let pr0 = ~~~maskFile[int File._H]
            let pr1 = pr0 &&& (Bitboards.shift -1 pr0)
            let pr2 = pr1 &&& (Bitboards.shift -2 pr1)

            bb
            |> otherPrefix -1 pr0
            |> otherPrefix -2 pr1
            |> otherPrefix -4 pr2
            |> (&&&) ~~~bb
        | Ray.SouthEast ->
            let pr0 = ~~~maskFile[int File._A]
            let pr1 = pr0 &&& (Bitboards.shift -7 pr0)
            let pr2 = pr1 &&& (Bitboards.shift -14 pr1)

            bb
            |> otherPrefix -7 pr0
            |> otherPrefix -14 pr1
            |> otherPrefix -28 pr2
            |> (&&&) ~~~bb
        | Ray.NorthWest ->
            let pr0 = ~~~maskFile[int File._H]
            let pr1 = pr0 &&& (Bitboards.shift 7 pr0)
            let pr2 = pr1 &&& (Bitboards.shift 14 pr1)

            bb
            |> otherPrefix 7 pr0
            |> otherPrefix 14 pr1
            |> otherPrefix 28 pr2
            |> (&&&) ~~~bb
        | Ray.NorthEast ->
            let pr0 = ~~~maskFile[int File._A]
            let pr1 = pr0 &&& (Bitboards.shift 9 pr0)
            let pr2 = pr1 &&& (Bitboards.shift 18 pr1)

            bb
            |> otherPrefix 9 pr0
            |> otherPrefix 18 pr1
            |> otherPrefix 36 pr2
            |> (&&&) ~~~bb
        | Ray.SouthWest ->
            let pr0 = ~~~maskFile[int File._H]
            let pr1 = pr0 &&& (Bitboards.shift -9 pr0)
            let pr2 = pr1 &&& (Bitboards.shift -18 pr1)

            bb
            |> otherPrefix -9 pr0
            |> otherPrefix -18 pr1
            |> otherPrefix -36 pr2
            |> (&&&) ~~~bb
        | _ -> failwith "invalid ray"

    type Lookup =
        {
          boardPosition: Bitboard[]
          knightAttacks: Bitboard[]
          kingAttacks: Bitboard[]
          pawnAttacks: Bitboard[,]
          rayAttacks: Bitboard[,]
          fileMasks: Bitboard[]
          rankMasks: Bitboard[]
          dirMasks: Bitboard[]
        }