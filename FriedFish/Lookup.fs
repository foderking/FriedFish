/// Types and functions for using a lookup table
module FriedFish.Lookup
  open FriedFish.Domain
  // module LookupTable =
  type Lookup =
    {
      /// Lookup for a particular square on the board
      boardPosition: Bitboard[]
      /// Lookup for knight attacks at particular position
      knightAttacks: Bitboard[]
      /// Lookup for king attacks at particular position
      kingAttacks  : Bitboard[]
    }
  
  type Ray =
    | North
    | West
    | East
    | South
    | NorthWest
    | NorthEast
    | SouthWest
    | SouthEast
  
  /// Bitboard lookup for files in the order FileA to FileH
  let fileMasks = 
    [|
      0x0101010101010101UL
      0x0202020202020202UL
      0x0404040404040404UL
      0x0808080808080808UL
      0x1010101010101010UL
      0x2020202020202020UL
      0x4040404040404040UL
      0x8080808080808080UL
    |] |> Array.map Bitboards.create
  /// Bitboard lookup for ranks in order Rank 1 to Rank 8
  let rankMasks = 
    [|
      0x00000000000000FFUL
      0x000000000000FF00UL
      0x0000000000FF0000UL
      0x00000000FF000000UL
      0x000000FF00000000UL
      0x0000FF0000000000UL
      0x00FF000000000000UL
      0xFF00000000000000UL
    |] |> Array.map Bitboards.create
  
  (*
            noNoWe    noNoEa
                +15  +17
                 |     |
    noWeWe  +6 __|     |__+10  noEaEa
                  \   /
                   >0<
               __ /   \ __
    soWeWe -10   |     |   -6  soEaEa
                 |     |
                -17  -15
            soSoWe    soSoEa
  *)
  /// Generate attack bitboard for knight from scratch
  /// https://www.chessprogramming.org/Knight_Pattern#by_Calculation
  let _calcKnightAttack(fileMask: Bitboard[])(bb: Bitboard) =
    let notG = ~~~fileMask[Files._G]
    let notH = ~~~fileMask[Files._H]
    let notGH = notG &&& notH
    let notA = ~~~fileMask[Files._A]
    let notB = ~~~fileMask[Files._B]
    let notAB = notA &&& notB
    Bitboards.create 0UL
    |> (|||) (Bitboards.shift  17 (bb &&& notH )) // noNoEa
    |> (|||) (Bitboards.shift  10 (bb &&& notGH)) // noEaEa
    |> (|||) (Bitboards.shift -6  (bb &&& notGH)) // soEaEa
    |> (|||) (Bitboards.shift -15 (bb &&& notH )) // soSoEa
    |> (|||) (Bitboards.shift  15 (bb &&& notA )) // noNoWe
    |> (|||) (Bitboards.shift  6  (bb &&& notAB)) // noWeWe
    |> (|||) (Bitboards.shift -10 (bb &&& notAB)) // soWeWe
    |> (|||) (Bitboards.shift -17 (bb &&& notA )) // soSoWe
    
  /// Generate attack bitboard for knight from scratch.
  /// Uses the same concept as `_calcKnightAttack`
  let _calcKingAttack(fileMask: Bitboard[])(bb: Bitboard) =
    let notA = ~~~fileMask[Files._A]
    let notH = ~~~fileMask[Files._H]
    Bitboards.create 0UL
    |> (|||) (Bitboards.shift  9 (bb &&& notH))
    |> (|||) (Bitboards.shift  1 (bb &&& notH))
    |> (|||) (Bitboards.shift -7 (bb &&& notH))
    |> (|||) (Bitboards.shift  8 bb)
    |> (|||) (Bitboards.shift -8 bb)
    |> (|||) (Bitboards.shift -9 (bb &&& notA))
    |> (|||) (Bitboards.shift -1 (bb &&& notA))
    |> (|||) (Bitboards.shift  7 (bb &&& notA))
    
  /// https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
  let getRay(maskFile: Bitboard[])(ray: Ray)(bb: Bitboard) =
    let northSouthPrefix(shiftCount: int)(bb: Bitboard) =
      bb ||| (Bitboards.shift shiftCount bb)
    let otherPrefix(shiftCount: int)(propagator: Bitboard)(bb: Bitboard) =
      bb ||| (propagator &&& (Bitboards.shift shiftCount bb))
      
    match ray with
    | Ray.North ->
      bb
      |> northSouthPrefix 8
      |> northSouthPrefix 16
      |> northSouthPrefix 32
      |> (&&&) ~~~bb
    | Ray.South ->
      bb
      |> northSouthPrefix -8
      |> northSouthPrefix -16
      |> northSouthPrefix -32
      |> (&&&) ~~~bb
    | Ray.East  ->
      let pr0 = ~~~maskFile[Files._A]
      let pr1 = pr0 &&& (Bitboards.shift 1 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 2 pr1)
      bb
      |> otherPrefix 1 pr0
      |> otherPrefix 2 pr1
      |> otherPrefix 4 pr2
      |> (&&&) ~~~bb
    | Ray.West  ->
      let pr0 = ~~~maskFile[Files._H]
      let pr1 = pr0 &&& (Bitboards.shift -1 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -2 pr1)
      bb
      |> otherPrefix -1 pr0
      |> otherPrefix -2 pr1
      |> otherPrefix -4 pr2
      |> (&&&) ~~~bb
    | Ray.SouthEast ->
      let pr0 = ~~~maskFile[Files._A]
      let pr1 = pr0 &&& (Bitboards.shift -7 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -14 pr1)
      bb
      |> otherPrefix -7  pr0
      |> otherPrefix -14 pr1
      |> otherPrefix -28 pr2     
      |> (&&&) ~~~bb
    | Ray.NorthWest ->
      let pr0 = ~~~maskFile[Files._H]
      let pr1 = pr0 &&& (Bitboards.shift 7 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 14 pr1)
      bb
      |> otherPrefix 7  pr0
      |> otherPrefix 14 pr1
      |> otherPrefix 28 pr2
      |> (&&&) ~~~bb
    | Ray.NorthEast ->
      let pr0 = ~~~maskFile[Files._A]
      let pr1 = pr0 &&& (Bitboards.shift 9 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 18 pr1)
      bb
      |> otherPrefix 9  pr0
      |> otherPrefix 18 pr1
      |> otherPrefix 36 pr2     
      |> (&&&) ~~~bb
    | Ray.SouthWest ->
      let pr0 = ~~~maskFile[Files._H]
      let pr1 = pr0 &&& (Bitboards.shift -9 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -18 pr1)
      bb
      |> otherPrefix -9  pr0
      |> otherPrefix -18 pr1
      |> otherPrefix -36 pr2   
      |> (&&&) ~~~bb
  
  let create() =
    {
      boardPosition = seq { for i in 0..63 -> Bitboards.shift i (Bitboards.create 1UL) } |> Seq.toArray
      knightAttacks = seq { for i in 0..63 -> _calcKnightAttack fileMasks (Bitboards.shift i (Bitboards.create 1UL)) } |> Seq.toArray
      kingAttacks   = seq { for i in 0..63 -> _calcKingAttack   fileMasks (Bitboards.shift i (Bitboards.create 1UL)) } |> Seq.toArray
    }
  
  let Look(lookup: Lookup)(piece: Pieces)(family: Family)(Square square) =
    match piece with
    | Pieces.King ->
      lookup.kingAttacks[square]
    | Pieces.Knight ->
      lookup.knightAttacks[square]
    | Pieces.Rook ->
      Bitboards.Empty
    | Pieces.Bishop ->
      Bitboards.Empty
    | Pieces.Queen ->
      Bitboards.Empty
    | Pieces.Pawn ->
      Bitboards.Empty

  let Position(lookup: Lookup)(Square position) =
    lookup.boardPosition[position]