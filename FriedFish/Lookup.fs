﻿/// Types and functions for using a lookup table
module FriedFish.Lookup
    open System.Numerics
    open FriedFish.BitBoard

    type Lookup() =
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
        member val private _rayAttacks = Array2D.zeroCreate<BitBoard> ray_count square_count
        member val private _rookAttacks = Array.zeroCreate<BitBoard> square_count
        member val private _bishopAttacks = Array.zeroCreate<BitBoard> square_count
        member val private _queenAttacks = Array.zeroCreate<BitBoard> square_count
        
        member this._getRay(ray: Ray, square: int, blockers: BitBoard): BitBoard=
            let attacks = this._rayAttacks[int ray, square] 
            
            if Helpers.intersection(attacks, blockers) then
                attacks &&& ~~~this._rayAttacks[int ray, BitOperations.TrailingZeroCount(attacks &&& blockers )]
            else
                attacks

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
                
        /// https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
        member this._initRay(bb: BitBoard, square: int) =
            let rayHelper (shiftCount: int) (bb: Bitboard) = bb ||| (Bitboards.shift shiftCount bb)
            let otherPrefix  (propagator: Bitboard) (shiftCount: int)(bb: Bitboard) =
                bb ||| (propagator &&& (Bitboards.shift shiftCount bb))
            let notH = ~~~this._rankMasks[int Files.FILE_H]
            let notA = ~~~this._rankMasks[int Files.FILE_A]
            let notBB = ~~~bb
            this._rayAttacks[int Ray.North, square] <-
                bb
                |> rayHelper 8
                |> rayHelper 16
                |> rayHelper 32
                |> (&&&) notBB
            this._rayAttacks[int Ray.South, square] <-
                bb
                |> rayHelper -8
                |> rayHelper -16
                |> rayHelper -32
                |> (&&&) notBB
            this._rayAttacks[int Ray.West, square] <-
                let pr0 = notH
                let pr1 = pr0 &&& (Bitboards.shift -1 pr0)
                let pr2 = pr1 &&& (Bitboards.shift -2 pr1)
                bb
                |> otherPrefix pr0 -1
                |> otherPrefix pr1 -2
                |> otherPrefix pr2 -4
                |> (&&&) notBB
            this._rayAttacks[int Ray.East, square] <-
                let pr0 = notA
                let pr1 = pr0 &&& (Bitboards.shift 1 pr0)
                let pr2 = pr1 &&& (Bitboards.shift 2 pr1)
                bb
                |> otherPrefix pr0 1
                |> otherPrefix pr1 2
                |> otherPrefix pr2 4
                |> (&&&) notBB
            this._rayAttacks[int Ray.NorthWest, square] <-
                let pr0 = notH
                let pr1 = pr0 &&& (Bitboards.shift  7 pr0)
                let pr2 = pr1 &&& (Bitboards.shift 14 pr1)
                bb
                |> otherPrefix pr0  7
                |> otherPrefix pr1 14
                |> otherPrefix pr2 28
                |> (&&&) notBB
            this._rayAttacks[int Ray.SouthEast, square] <-
                let pr0 = notA
                let pr1 = pr0 &&& (Bitboards.shift  -7 pr0)
                let pr2 = pr1 &&& (Bitboards.shift -14 pr1)
                bb
                |> otherPrefix pr0  -7
                |> otherPrefix pr1 -14
                |> otherPrefix pr2 -28
                |> (&&&) notBB
            this._rayAttacks[int Ray.NorthEast, square] <-
                let pr0 = notA
                let pr1 = pr0 &&& (Bitboards.shift  9 pr0)
                let pr2 = pr1 &&& (Bitboards.shift 18 pr1)
                bb
                |> otherPrefix pr0  9
                |> otherPrefix pr1 18
                |> otherPrefix pr2 36
                |> (&&&) notBB
            this._rayAttacks[int Ray.SouthWest, square] <-
                let pr0 = notH
                let pr1 = pr0 &&& (Bitboards.shift  -9 pr0)
                let pr2 = pr1 &&& (Bitboards.shift -18 pr1)
                bb
                |> otherPrefix pr0  -9
                |> otherPrefix pr1 -18
                |> otherPrefix pr2 -36
                |> (&&&) notBB
            
            this._rookAttacks[square] <-
                this._rayAttacks[int Ray.East, square]
                ||| this._rayAttacks[int Ray.West, square] 
                ||| this._rayAttacks[int Ray.South, square]
                ||| this._rayAttacks[int Ray.North, square] 
            this._bishopAttacks[square] <-
                this._rayAttacks[int Ray.NorthEast, square]
                ||| this._rayAttacks[int Ray.NorthWest, square] 
                ||| this._rayAttacks[int Ray.SouthEast, square]
                ||| this._rayAttacks[int Ray.SouthWest, square]
            this._queenAttacks[square] <- this._rookAttacks[square] ||| this._bishopAttacks[square]
                
            
        member this.init() =
            for i in 0..63 do
                let bb = Helpers.createFromSquare(i)
                this._initKnight(bb, i)
                this._initKing(bb, i)
                this._initPawn(bb, i)
                this._initRay(bb, i)
                
        member this.getAttack(family: Family, piece: Piece, square: int, blockers: BitBoard) : BitBoard =
            match piece with
            | Piece.Bishop ->
                0UL
                |> (|||) (this._getRay(Ray.NorthEast, square, blockers))
                |> (|||) (this._getRay(Ray.NorthWest, square, blockers))
                |> (|||) (this._getRay(Ray.SouthEast, square, blockers))
                |> (|||) (this._getRay(Ray.SouthWest, square, blockers))
            | Piece.Queen ->
                0UL
                |> (|||) (this._getRay(Ray.North, square, blockers))
                |> (|||) (this._getRay(Ray.South, square, blockers))
                |> (|||) (this._getRay(Ray.East, square, blockers))
                |> (|||) (this._getRay(Ray.West, square, blockers))
                |> (|||) (this._getRay(Ray.NorthEast, square, blockers))
                |> (|||) (this._getRay(Ray.NorthWest, square, blockers))
                |> (|||) (this._getRay(Ray.SouthEast, square, blockers))
                |> (|||) (this._getRay(Ray.SouthWest, square, blockers))
            | Piece.Rook -> 
                0UL
                |> (|||) (this._getRay(Ray.North, square, blockers))
                |> (|||) (this._getRay(Ray.South, square, blockers))
                |> (|||) (this._getRay(Ray.East, square, blockers))
                |> (|||) (this._getRay(Ray.West, square, blockers))
            | _ -> this.getAttack(family, piece, square)
               
        member this.getAttack(family: Family, piece: Piece, square: int) : BitBoard =
            match piece with
            | Piece.Knight -> this._knightAttacks[square]
            | Piece.King   -> this._kingAttacks[square]
            | Piece.Pawn when family = Family.White -> this._whitePawnAttacks[square]
            | Piece.Pawn when family = Family.Black -> this._blackPawnAttacks[square]
            | _ -> failwith "unexpected"
