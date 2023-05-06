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
    /// shifts in the rightward direction of the board if count is positive, then leftwards otherwise
    val inline shift: int ->  Bitboard -> Bitboard
    /// Creates bitboard from valid board index
    val inline create: int -> Bitboard
    
  /// A valid zero indexed location on the board is between the numbers 0-63
  [<Struct>]
  type Square =
    Square of int
   
  /// Each rank represents one of the 8 rows in a chess board
  type Rank =
    | _1 = 0
    | _2 = 1
    | _3 = 2
    | _4 = 3
    | _5 = 4
    | _6 = 5
    | _7 = 6
    | _8 = 7
  module Ranks =
    /// number of rows in chessboard
    val Total: int
    /// Gets the row of a particular position
    val create : Square -> Rank
    
  /// Each file represents one of the 8 columns in a chess board
  type File =
    | _A = 0
    | _B = 1
    | _C = 2
    | _D = 3
    | _E = 4
    | _F = 5
    | _G = 6
    | _H = 7
  module Files =
    /// number of columns in chessboard
    val Total: int
    /// Gets the column of a particular position
    val create: Square -> File
    
    
  module Squares =
    /// total number of valid positions in a bitboard 
    val Total: int
    /// initializes a square from an integer index of the position
    val create: int -> Square
    /// initializes a square by specifying the rank and the file of the position
    val create2: Rank -> File -> Square
   
   /// Every possible valid piece
  [<Struct>]
  type Piece =
    | King   = 0
    | Queen  = 1
    | Knight = 2
    | Bishop = 3
    | Rook   = 4
    | Pawn   = 5
  
  module Pieces =
    val Total: int
    
  /// Family of the pieces
  // [<Struct>]
  type Family =
    | Black = 0
    | White = 1
    
  module Families =
    val enemy: Family -> Family
    val Total: int
    
  /// Rays from sliding pieces
  type Ray =
    | North     = 0
    | West      = 1
    | East      = 2
    | South     = 3
    | NorthWest = 4
    | NorthEast = 5
    | SouthWest = 6
    | SouthEast = 7
  
  module Rays =
    val Total: int
    val inline isNegative: Ray -> bool
    
  [<Struct>]
  type CastlingRights = CastlingRights of byte
  module Castling =
    val aa: int
