module FriedFish.Lookup
  open FriedFish.Domain

  module Rays =
    let Total = 8
  /// Types and functions for using a lookup table
  module LookupTable =
    let mutable _isRankSet = false
    /// Lookup for clearing all bits at a particular rank
    let clear_rank: Bitboard[] = Array.zeroCreate Ranks.Total
    /// Lookup for clearing all bits except the ones at a particular rank
    let mask_rank : Bitboard[] = Array.zeroCreate Ranks.Total
    /// Lookup for clearing all bits at a particular file
    let mutable _isFileSet = false
    let clear_file: Bitboard[] = Array.zeroCreate Files.Total
    /// Lookup for clearing all bits except the ones at a particular file
    let mask_file : Bitboard[] = Array.zeroCreate Files.Total
    /// Lookup for a particular board position
    let mutable _isPosSet = false
    let board_position: Bitboard[] = Array.zeroCreate Squares.Total
    /// Lookup for knight attacks at particular position
    let knight_attacks: Bitboard[] = Array.zeroCreate Squares.Total
    /// Lookup for king attacks at particular position
    let king_attacks: Bitboard[] = Array.zeroCreate Squares.Total
    /// Lookup for attacks of a particular ray at a particular position
    let ray_attacks: Bitboard[,] = Array2D.zeroCreate Squares.Total Rays.Total
    
    let _shr count bb =
      bb >>> count
    let _shl count bb =
      bb <<< count
      
    
    /// initializes lookups
    let init() =
      // initializes the files lookup
      mask_file[Files.A]  <- 0x0101010101010101UL
      mask_file[Files.B]  <- 0x0202020202020202UL
      mask_file[Files.C]  <- 0x0404040404040404UL
      mask_file[Files.D]  <- 0x0808080808080808UL
      mask_file[Files.E]  <- 0x1010101010101010UL
      mask_file[Files.F]  <- 0x2020202020202020UL
      mask_file[Files.G]  <- 0x4040404040404040UL
      mask_file[Files.H]  <- 0x8080808080808080UL
      clear_file[Files.A] <- 0xFEFEFEFEFEFEFEFEUL
      clear_file[Files.B] <- 0xFDFDFDFDFDFDFDFDUL
      clear_file[Files.C] <- 0xFBFBFBFBFBFBFBFBUL
      clear_file[Files.D] <- 0xF7F7F7F7F7F7F7F7UL
      clear_file[Files.E] <- 0xEFEFEFEFEFEFEFEFUL
      clear_file[Files.F] <- 0xDFDFDFDFDFDFDFDFUL
      clear_file[Files.G] <- 0xBFBFBFBFBFBFBFBFUL
      clear_file[Files.H] <- 0x7F7F7F7F7F7F7F7FUL
      _isFileSet <- true
      // initializes the ranks lookup
      mask_rank[Ranks._1]  <- 0x00000000000000FFUL
      mask_rank[Ranks._2]  <- 0x000000000000FF00UL
      mask_rank[Ranks._3]  <- 0x0000000000FF0000UL
      mask_rank[Ranks._4]  <- 0x00000000FF000000UL
      mask_rank[Ranks._5]  <- 0x000000FF00000000UL
      mask_rank[Ranks._6]  <- 0x0000FF0000000000UL
      mask_rank[Ranks._7]  <- 0x00FF000000000000UL
      mask_rank[Ranks._8]  <- 0xFF00000000000000UL
      clear_rank[Ranks._1] <- 0XFFFFFFFFFFFFFF00UL
      clear_rank[Ranks._2] <- 0XFFFFFFFFFFFF00FFUL
      clear_rank[Ranks._3] <- 0XFFFFFFFFFF00FFFFUL
      clear_rank[Ranks._4] <- 0XFFFFFFFF00FFFFFFUL
      clear_rank[Ranks._5] <- 0XFFFFFF00FFFFFFFFUL
      clear_rank[Ranks._6] <- 0XFFFF00FFFFFFFFFFUL
      clear_rank[Ranks._7] <- 0XFF00FFFFFFFFFFFFUL
      clear_rank[Ranks._8] <- 0X00FFFFFFFFFFFFFFUL
      _isRankSet <- true
      
      for position = 0 to Squares.Total-1 do
        // initialize board position
        board_position[position] <- 1UL <<< position
        _isPosSet <- true
        
      
    init()
