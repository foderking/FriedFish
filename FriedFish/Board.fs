module FriedFish.Board
  open System.Numerics
  open FriedFish.Domain
  open FriedFish.Lookup


  [<Struct>]
  type Board =
    {
      lookup: Lookup
      pieceBitboard: Bitboard[,]
      familyBitboard: Bitboard[]
      allPiecesBitboard: Bitboard
      enPassantSquare: Square option
      castleRights: CastlingRights
      sideToMove: Family
      halfMoves: int
      fullMoves: int
    }
    
  let Look(lookup: Lookup)(family: Family)(allPiece: Bitboard)(piece: Piece)(Square square) =
    // https://www.chessprogramming.org/Classical_Approach#Branchless_3
    let slidingAttack(rayAttacks: Bitboard[,])(Bitboard occupied)(ray: Ray)(square: int) =
      let dir = int ray
      let (Bitboard attack) = rayAttacks[square, dir]
      let (Bitboard minusOne) = Bitboards.Full
      let (Bitboard dirMask) = lookup.dirMasks[dir]
      let dirBit = 1UL <<< 63
      
      let blocker = attack &&& occupied
      let blocker = blocker &&& (minusOne*blocker ||| dirMask)
      let blocker = blocker ||| dirBit
      let lastSquare = BitOperations.Log2(blocker) // bitScan reverse is the floor of the base 2 logarithm
      
      let (Bitboard newAttack) = if lastSquare < Squares.Total then rayAttacks[lastSquare, dir] else Bitboards.Empty
      Bitboard(attack ^^^ newAttack)
    
    match piece with
    | Piece.King ->
      lookup.kingAttacks[square]
    | Piece.Knight ->
      lookup.knightAttacks[square]
    | Piece.Rook ->
      Bitboards.Empty
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.North square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.East  square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.South square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.West  square)
    | Piece.Bishop ->
      Bitboards.Empty
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.NorthWest square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.SouthWest square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.NorthEast square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.SouthEast square)
    | Piece.Queen ->
      Bitboards.Empty
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.NorthWest square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.SouthWest square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.NorthEast square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.SouthEast square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.North square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.East  square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.South square)
      |> (|||) (slidingAttack lookup.rayAttacks allPiece Ray.West  square)
    | Piece.Pawn ->
      let rank4 = lookup.rankMasks[int Rank._4]
      let rank5 = lookup.rankMasks[int Rank._5]
      let empty = ~~~allPiece
      let push =
        if family = Family.White then
          (Bitboards.create (square+8)) &&& empty
          |> (fun p -> (Bitboards.shift 8 p)  &&& empty &&& rank4)
        else
          (Bitboards.create (square-8))
          |> (fun p -> (Bitboards.shift -8 p) &&& empty &&& rank5)
          
      lookup.pawnAttacks[square, int family] ||| push
    | _ ->
      failwith "invalid piece"