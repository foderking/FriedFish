module FriedFish.Lookup
  open FriedFish.Domain

  type Lookup =
    {
      /// Lookup for a particular square on the board
      boardPosition: Bitboard[]
      /// Lookup for knight attacks at particular position
      knightAttacks: Bitboard[]
      /// Lookup for king attacks at particular position
      kingAttacks  : Bitboard[]
      /// Lookup for normal pawn attacks at particular position
      pawnAttacks  : Bitboard[,]
      /// 8x64 Lookup for attacks at all squares for all rays
      rayAttacks: Bitboard[,]
      /// Bitboard lookup for files in the order FileA to FileH
      fileMasks: Bitboard[]
      /// Bitboard lookup for ranks in order Rank 1 to Rank 8
      rankMasks: Bitboard[]
      /// An array of 8 bitboards. Each bitboard is an empty set if the the ray is a positive ray otherwise a full set
      dirMasks: Bitboard[]
    }
    
  val Create: unit -> Lookup
