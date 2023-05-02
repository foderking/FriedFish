module FriedFish.Domain
  /// Represents the state of the board in 64 bits, where each bit marks the state of a particular location
  type Bitboard = uint64
  /// A valid zero indexed location on the board is between the numbers 0-63
  type Square   = int
  /// Each rank represents one of the 8 rows in a chess board
  type Rank     = int
  /// Each file represents one of the 8 columns in a chess board
  type File     = int
  /// Every possible valid piece
  type Pieces =
    | King
    | Queen
    | Knight
    | Bishop
    | Rook
    | Pawn
  // Family of the pieces
  type Family =
    | Black
    | White
  
  module Squares =
    /// initializes a square from an integer index of the position
    val create: int -> Square
    /// initializes a square by specifying the rank and the file of the position
    val create2: File -> Rank -> Square
    val create3: File * Rank -> Square
    /// total number of valid positions in a bitboard 
    val Total: int
    
  module Bitboards =
    val Full: Bitboard
  module Ranks =
    /// Gets the row of a particular position
    val create: Square -> Rank
    /// number of rows in chessboard
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
    /// Gets the column of a particular position
    val create: Square -> File
    /// number of columns in chessboard
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
    /// Performs a bit shift. Shifts in the rightwards direction of board for positive `count` and leftwards direction otherwise
    /// --> dir is positive; <-- dir is negative
    val inline shift: int ->  'a ->  'a when 'a: (static member (>>>) : 'a * int32 -> 'a) and 'a: (static member (<<<) : 'a * int32 -> 'a)
    
    val stringify: Bitboard -> string