module FriedFish.BitBoard

    open System.Numerics

    type BitBoard = uint64
      
    type Ranks =
    | RANK_1 = 0
    | RANK_2 = 1
    | RANK_3 = 2
    | RANK_4 = 3
    | RANK_5 = 4
    | RANK_6 = 5
    | RANK_7 = 6
    | RANK_8 = 7

    type Files =
    | FILE_A = 0
    | FILE_B = 1
    | FILE_C = 2
    | FILE_D = 3
    | FILE_E = 4
    | FILE_F = 5
    | FILE_G = 6
    | FILE_H = 7
    
    type Piece =
    | King   = 0u
    | Queen  = 1u
    | Knight = 2u
    | Bishop = 3u
    | Rook   = 4u
    | Pawn   = 5u

    type Family =
    | Black = 0
    | White = 1
        
    type Ray =
    | North     = 0
    | West      = 1
    | East      = 2
    | South     = 3
    | NorthWest = 4
    | NorthEast = 5
    | SouthWest = 6
    | SouthEast = 7
               
    type CastleField =
    | BlackQueen = 0b0001
    | BlackKing  = 0b0010
    | WhiteQueen = 0b0100
    | WhiteKing  = 0b1000
    
    let rank_count = 8
    let file_count = 8
    let piece_count = 6
    let family_count = 2
    let ray_count = 8
         

    let extractSquare(bb: BitBoard): ValueOption<int> =
        if bb = 0UL then
            ValueNone
        else
            ValueSome(BitOperations.TrailingZeroCount(bb))
    
    let extractRankFile(square: int) =
        (square >>> 3, square &&& 7)
            
    let squareFromRankFile(rank: int, file: int): int =
        rank * 8 + file
        
    let createFromSquare(square: int): BitBoard =
        1UL <<< square
        
    let createFromRankFile(rank: int, file: int): BitBoard =
        1UL <<< (rank * 8 + file)
        
    module Helpers =
        let intersection(bb1: BitBoard, bb2: BitBoard): bool =
            (bb1 &&& bb2) > 0UL
            