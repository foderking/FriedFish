module FriedFish.BitBoard

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
     
let createFromRankFile(rank: Ranks, file: Files): BitBoard =
    (uint64 rank) * 8UL + (uint64 file)
    
let createFromSquare(square: int): BitBoard =
    (uint64) square <<< 1
