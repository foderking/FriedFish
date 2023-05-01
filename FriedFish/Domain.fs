module FriedFish.Domain
  type Bitboard = uint64
  type Square = int
  type Rank = int
  type File = int
  // /// A board position is either valid or a null position
  // type BoardPosition =
  //   | Valid of Square
  //   | Null
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
  
  
  module Bitboards =
    let Full = 0xFFFFFFFFFFFFFFFFUL 
      
  module Helpers =
    let inline shift(count: int)(bb: 'a) =
      if count > 0 then
        bb <<< count
      else
        bb >>> -count
    
    let createMailbox(bb: Bitboard)(fillerFunc: int -> bool -> 'T) =
      //Array2D.init 8 8 (fun i j -> fillerFunc (i*8+j) (((shift ((7-i)*8+j) 1UL) &&& bb) = 0UL))
      Array2D.init 8 8 (fun i j -> fillerFunc (i*8+j) (((shift (58+j-8*i) 1UL) &&& bb) = 0UL) )
      
    let Visualize(bb: Bitboard) =
      Array2D.init 8 8 (fun i j -> if ((shift ((7-i)*8+j) 1UL) &&& bb) = 0UL then " " else "X")
      
    let stringify(bb: Bitboard) =
      ""
      
    
  module Ranks =
    let Total = 8
    let _1,_2,_3,_4,_5,_6,_7,_8 = 0, 1, 2, 3, 4, 5, 6, 7
    
    // The formula is: square // 8, where `//` is integer division
    // but y // 2^x is the same as y >>> x (this applies since 8 is a power of 2)
    let create square =
      square >>> 3
    
    
    
  module Files =
    let Total = 8
    let _A, _B, _C, _D, _E, _F, _G, _H = 0, 1, 2, 3, 4, 5, 6, 7
    
    // The formula is: square % 8, where `%` is modulo operator
    // but y % 2^x is the same as y &&& (x-1) 
    let create square =
      square &&& 7
      

  /// Types and functions for locations/squares in the board
  module Squares =
    let Total = 64
    
    let create(square: int) =
      if square >= 0 && square < 64 then
        square
      else
        failwith "valid board position should be between 0 and 63"
        
    let create2(file: File)(rank: Rank) =
      rank * 8 + file
      |> create
    // let A1, B1, C1, D1, E1, F1, G1, H1 =  0,  1,  2,  3,  4,  5,  6,  7
    // let A2, B2, C2, D2, E2, F2, G2, H2 =  8,  9, 10, 11, 12, 13, 14, 15
    // let A3, B3, C3, D3, E3, F3, G3, H3 = 16, 17, 18, 19, 20, 21, 22, 23
    // let A4, B4, C4, D4, E4, F4, G4, H4 = 24, 25, 26, 27, 28, 29, 30, 31
    // let A5, B5, C5, D5, E5, F5, G5, H5 = 32, 33, 34, 35, 36, 37, 38, 39
    // let A6, B6, C6, D6, E6, F6, G6, H6 = 40, 41, 42, 43, 44, 45, 46, 47
    // let A7, B7, C7, D7, E7, F7, G7, H7 = 48, 49, 50, 51, 52, 53, 54, 55
    // let A8, B8, C8, D8, E8, F8, G8, H8 = 56, 57, 58, 59, 60, 61, 62, 63
    // let NULL = 64
    //