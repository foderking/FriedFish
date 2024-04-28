/// Types and functions for using a lookup table
module FriedFish.Lookup

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
    |]
    
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
    |]
  
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
  let calcKnightAttack(fileMask: Bitboard[])(bb: Bitboard) =
    let notG = ~~~fileMask[int File._G]
    let notH = ~~~fileMask[int File._H]
    let notGH = notG &&& notH
    let notA = ~~~fileMask[int File._A]
    let notB = ~~~fileMask[int File._B]
    let notAB = notA &&& notB
    0UL
    |> (|||) (Bitboards.shift  17 (bb &&& notH )) // noNoEa
    |> (|||) (Bitboards.shift  10 (bb &&& notGH)) // noEaEa
    |> (|||) (Bitboards.shift -6  (bb &&& notGH)) // soEaEa
    |> (|||) (Bitboards.shift -15 (bb &&& notH )) // soSoEa
    |> (|||) (Bitboards.shift  15 (bb &&& notA )) // noNoWe
    |> (|||) (Bitboards.shift  6  (bb &&& notAB)) // noWeWe
    |> (|||) (Bitboards.shift -10 (bb &&& notAB)) // soWeWe
    |> (|||) (Bitboards.shift -17 (bb &&& notA )) // soSoWe
    
  /// Generate attack bitboard for knight from scratch.
  /// Uses the same concept as `calcKnightAttack`
  let calcKingAttack(fileMask: Bitboard[])(bb: Bitboard) =
    let notA = ~~~fileMask[int File._A]
    let notH = ~~~fileMask[int File._H]
    0UL
    |> (|||) (Bitboards.shift  9 (bb &&& notH))
    |> (|||) (Bitboards.shift  1 (bb &&& notH))
    |> (|||) (Bitboards.shift -7 (bb &&& notH))
    |> (|||) (Bitboards.shift  8 bb)
    |> (|||) (Bitboards.shift -8 bb)
    |> (|||) (Bitboards.shift -9 (bb &&& notA))
    |> (|||) (Bitboards.shift -1 (bb &&& notA))
    |> (|||) (Bitboards.shift  7 (bb &&& notA))
    
  /// https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
  let calcRayAttack(maskFile: Bitboard[])(ray: Ray)(sq: int) =
    let northSouthPrefix(shiftCount: int)(bb: Bitboard) =
      bb ||| (Bitboards.shift shiftCount bb)
    let otherPrefix(shiftCount: int)(propagator: Bitboard)(bb: Bitboard) =
      bb ||| (propagator &&& (Bitboards.shift shiftCount bb))
      
    let bb = Bitboards.create sq
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
      let pr0 = ~~~maskFile[int File._A]
      let pr1 = pr0 &&& (Bitboards.shift 1 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 2 pr1)
      bb
      |> otherPrefix 1 pr0
      |> otherPrefix 2 pr1
      |> otherPrefix 4 pr2
      |> (&&&) ~~~bb
    | Ray.West  ->
      let pr0 = ~~~maskFile[int File._H]
      let pr1 = pr0 &&& (Bitboards.shift -1 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -2 pr1)
      bb
      |> otherPrefix -1 pr0
      |> otherPrefix -2 pr1
      |> otherPrefix -4 pr2
      |> (&&&) ~~~bb
    | Ray.SouthEast ->
      let pr0 = ~~~maskFile[int File._A]
      let pr1 = pr0 &&& (Bitboards.shift -7 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -14 pr1)
      bb
      |> otherPrefix -7  pr0
      |> otherPrefix -14 pr1
      |> otherPrefix -28 pr2     
      |> (&&&) ~~~bb
    | Ray.NorthWest ->
      let pr0 = ~~~maskFile[int File._H]
      let pr1 = pr0 &&& (Bitboards.shift 7 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 14 pr1)
      bb
      |> otherPrefix 7  pr0
      |> otherPrefix 14 pr1
      |> otherPrefix 28 pr2
      |> (&&&) ~~~bb
    | Ray.NorthEast ->
      let pr0 = ~~~maskFile[int File._A]
      let pr1 = pr0 &&& (Bitboards.shift 9 pr0)
      let pr2 = pr1 &&& (Bitboards.shift 18 pr1)
      bb
      |> otherPrefix 9  pr0
      |> otherPrefix 18 pr1
      |> otherPrefix 36 pr2     
      |> (&&&) ~~~bb
    | Ray.SouthWest ->
      let pr0 = ~~~maskFile[int File._H]
      let pr1 = pr0 &&& (Bitboards.shift -9 pr0)
      let pr2 = pr1 &&& (Bitboards.shift -18 pr1)
      bb
      |> otherPrefix -9  pr0
      |> otherPrefix -18 pr1
      |> otherPrefix -36 pr2   
      |> (&&&) ~~~bb
    | _ ->
      failwith "invalid ray"
  
  let calcPawnAttack(fileMasks: Bitboard[])(family: Family)(bb: Bitboard) =
    let notA = ~~~fileMasks[int File._A]
    let notH = ~~~fileMasks[int File._H]
    // white pawns move up while black pawns move down
    if family = Family.White then
      Bitboards.Empty
      |> (|||) (Bitboards.shift 9 (bb &&& notH))
      |> (|||) (Bitboards.shift 7 (bb &&& notA))
    else
      Bitboards.Empty
      |> (|||) (Bitboards.shift -9 (bb &&& notA))
      |> (|||) (Bitboards.shift -7 (bb &&& notH))
   
  type Lookup =
    {
      boardPosition: Bitboard[]
      knightAttacks: Bitboard[]
      kingAttacks  : Bitboard[]
      pawnAttacks  : Bitboard[,]
      rayAttacks: Bitboard[,]
      fileMasks: Bitboard[]
      rankMasks: Bitboard[]
      dirMasks: Bitboard[]
    }
   
    static member Create() =
      {
        fileMasks = fileMasks
        rankMasks = rankMasks
        dirMasks = Array.init Rays.Total (fun ray -> if Rays.isNegative (enum<Ray> ray) then Bitboards.Full else Bitboards.Empty)
        boardPosition = Array.init Squares.Total (fun i -> Bitboards.create i)
        knightAttacks = Array.init Squares.Total (fun i -> calcKnightAttack fileMasks (Bitboards.create i))
        kingAttacks   = Array.init Squares.Total (fun i -> calcKingAttack   fileMasks (Bitboards.create i))
        rayAttacks  = Array2D.init Squares.Total Rays.Total     (fun square ray -> calcRayAttack  fileMasks (enum<Ray> ray)    square)
        pawnAttacks = Array2D.init Squares.Total Families.Total (fun square fam -> calcPawnAttack fileMasks (enum<Family> fam) (Bitboards.create square))
      }