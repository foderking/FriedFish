module FriedFish.Board

  open FriedFish.Domain
  open FriedFish.Lookup

  [<Struct>]
  type Board =
    {
      /// lookup table
      lookup: Lookup
      /// A 2x6 Array containing bitboards for every piece for every family
      pieceBitboard: Bitboard[,]
      /// An representing the bitboard for all pieces of a particular family (white or black)
      familyBitboard: Bitboard[]
      /// A bitboard for every piece in the board
      allPiecesBitboard: Bitboard
      
      enPassantSquare: Square option
      castleRights: CastlingRights
      sideToMove: Family
      halfMoves: int
      fullMoves: int
    }
  val Create: unit -> Board
  val Look: Lookup -> Family -> Bitboard -> Piece -> Square -> Bitboard