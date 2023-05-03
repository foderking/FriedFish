module FriedFish.Domain
  /// Represents the state of the board in 64 bits, where each bit marks the state of a particular location
  [<Struct>]
  type Bitboard =
    Bitboard of uint64
    with
    static member (~~~): Bitboard -> Bitboard
    static member (&&&): Bitboard * Bitboard -> Bitboard
    static member (|||): Bitboard * Bitboard -> Bitboard
    static member   (+): Bitboard * Bitboard -> Bitboard
    static member   (-): Bitboard * Bitboard -> Bitboard
  module Bitboards =
    /// Bitboard with all bits set
    val Full: Bitboard
    /// Bitboard with no bits set
    val Empty: Bitboard
    /// Creates bitboard from valid board index
    val inline create: uint64 -> Bitboard
    /// Shifts bits by a specified amount.
    /// shifts in the rightward direction of the board if count is positive, then leftwards otherwise
    val inline shift: int ->  Bitboard -> Bitboard
    
  /// A valid zero indexed location on the board is between the numbers 0-63
  [<Struct>]
  type Square =
    Square of int
  /// Each rank represents one of the 8 rows in a chess board
  [<Struct>]
  type Rank =
    Rank of int
  /// Each file represents one of the 8 columns in a chess board
  [<Struct>]
  type File =
    File of int

  module Squares =
    /// total number of valid positions in a bitboard 
    val Total: int
    /// initializes a square from an integer index of the position
    val create: int -> Square
    /// initializes a square by specifying the rank and the file of the position
    val create2: File -> Rank -> Square
    val create3: File * Rank -> Square
    val inline _create: int -> int -> Square
    
  module Ranks =
    val _1: int
    val _2: int
    val _3: int
    val _4: int
    val _5: int
    val _6: int
    val _7: int
    val _8: int
    val x1: Rank
    val x2: Rank
    val x3: Rank
    val x4: Rank
    val x5: Rank
    val x6: Rank
    val x7: Rank
    val x8: Rank
    /// number of rows in chessboard
    val Total: int
    val lookup : Rank[]
    val inline extract: Square -> int
    /// Gets the row of a particular position
    val create : Square -> Rank
    
  module Files =
    val _A: int
    val _B: int
    val _C: int
    val _D: int
    val _E: int
    val _F: int
    val _G: int
    val _H: int
    val xA: File
    val xB: File
    val xC: File
    val xD: File
    val xE: File
    val xF: File
    val xG: File
    val xH: File
    /// number of columns in chessboard
    val Total: int
    val lookup: File[]
    val inline extract: Square -> int
    /// Gets the column of a particular position
    val create: Square -> File
    
   /// Every possible valid piece
  [<Struct>]
  type Pieces =
    | King
    | Queen
    | Knight
    | Bishop
    | Rook
    | Pawn
  // Family of the pieces
  [<Struct>]
  type Family =
    | Black
    | White
 
  
  // module Helpers =
    // Performs a bit shift. Shifts in the rightwards direction of board for positive `count` and leftwards direction otherwise
    // --> dir is positive; <-- dir is negative
    
    // val stringify: Bitboard -> string