module FriedFish.Domain
  type Bitboard = uint64
  type Square   = int
  type Rank     = int
  type File     = int
  
  type Pieces =
    | King
    | Queen
    | Knight
    | Bishop
    | Rook
    | Pawn
    
  type Family =
    | Black
    | White
  
  module Squares =
    val create: int -> Square
    val create: File -> Rank -> Square
    val Total: int
    
  module Ranks =
    val create: Square -> Rank
    val Total: int
    val _1: Rank
    val _2: Rank
    val _3: Rank
    val _4: Rank
    val _5: Rank
    val _6: Rank
    val _7: Rank
    val _8: Rank
    
  module Files =
    val create: Square -> File
    val Total: int
    val _A: File
    val _B: File
    val _C: File
    val _D: File
    val _E: File
    val _F: File
    val _G: File
    val _H: File

  
  module Helpers =
    val shift: int ->  'a ->  'a 