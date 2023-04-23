﻿module FriedFish.Domain
  /// Represents the state of the board in 64 bits, where each bit marks the state of a particular location
  type Bitboard = uint64
  
  /// Types and functions for ranks in board
  module Ranks =
    /// The number of ranks in a chessboard
    let Total = 8
    let _1,_2,_3,_4,_5,_6,_7,_8 = 0, 1, 2, 3, 4, 5, 6, 7
    
    /// Gets the file no from board position index.
    /// The formula would be -> square // 8, where `//` is integer division
    /// but y // 2^x is the same as y >>> x 
    let Get square =
      square >>> 3
    
  /// Types and functions for files in board
  module Files =
    /// The number of files in a chessboard
    let Total = 8
    let A, B, C, D, E, F, G, H = 0, 1, 2, 3, 4, 5, 6, 7
    
    /// Gets the file no from board position index.
    /// The formula would be -> square % 8, where `%` is modulo operator
    /// but y % 2^x is the same as y &&& (x-1) 
    let Get square =
      square &&& 7
      

  /// Types and functions for locations/squares in the board
  module Squares =
    /// The number of valid board positions
    let Total = 64
    let A1, B1, C1, D1, E1, F1, G1, H1 =  0,  1,  2,  3,  4,  5,  6,  7
    let A2, B2, C2, D2, E2, F2, G2, H2 =  8,  9, 10, 11, 12, 13, 14, 15
    let A3, B3, C3, D3, E3, F3, G3, H3 = 16, 17, 18, 19, 20, 21, 22, 23
    let A4, B4, C4, D4, E4, F4, G4, H4 = 24, 25, 26, 27, 28, 29, 30, 31
    let A5, B5, C5, D5, E5, F5, G5, H5 = 32, 33, 34, 35, 36, 37, 38, 39
    let A6, B6, C6, D6, E6, F6, G6, H6 = 40, 41, 42, 43, 44, 45, 46, 47
    let A7, B7, C7, D7, E7, F7, G7, H7 = 48, 49, 50, 51, 52, 53, 54, 55
    let A8, B8, C8, D8, E8, F8, G8, H8 = 56, 57, 58, 59, 60, 61, 62, 63
    let NULL = 64
  