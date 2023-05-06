﻿module Tests.Lookup

open System
open FriedFish
open FriedFish.Domain
// open FsCheck.Xunit
open FsCheck.Xunit
open Xunit
open Swensen.Unquote.Assertions

let lookup = Lookup.Create()
let bb_1 = Bitboard 1UL

// let product(seq1: 'a seq)(seq2: 'a seq) = seq {
//   for x in seq1 do
//     for y in seq2 do
//       yield x,y
// }

let product(firstLow: int)firstHigh secondLow secondHigh = seq {
  for x in firstLow..firstHigh do
    for y in secondLow..secondHigh do
      yield x,y
}

let uniteRankAndFile(fileMask: Bitboard[])(rankMask: Bitboard[])(bb: Bitboard)(File file, Rank rank) =
  bb ||| (fileMask[file] &&& rankMask[rank])
    
module Rays =
  [<Fact>]
  let ``north ray generates correctly``() =
    Assert.All([0..63], fun i ->
      let square = Squares.create i
      let bb = (Lookup.Position lookup square)
      let ray = Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.North bb
      let expected = Lookup.fileMasks[Files.extract square] &&& ~~~(bb ||| (bb-bb_1)) 
      test <@ expected = ray @>
    )
    
  [<Fact>]
  let ``south ray generates correctly``() =
    Assert.All([0..63], fun i ->
      let square = Squares.create i
      let bb = (Lookup.Position lookup square)
      let ray = Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.South bb
      let expected = Lookup.fileMasks[Files.extract square] &&& ~~~bb &&& (bb-bb_1)
      test <@ expected = ray @>
    )
    
  [<Fact>]
  let ``east ray generates correctly``() =
    Assert.All([0..63], fun i ->
      let square = Squares.create i
      let bb = (Lookup.Position lookup square)
      let ray = Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.East bb
      let expected = Lookup.rankMasks[Ranks.extract square] &&& ~~~(bb ||| (bb-bb_1)) 
      test <@ expected = ray @>
    )
     
  [<Fact>]
  let ``west ray generates correctly``() =
    Assert.All([0..63], fun i ->
      let square = Squares.create i
      let bb = (Lookup.Position lookup square)
      let ray = Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.West bb
      let expected = Lookup.rankMasks[Ranks.extract square] &&& ~~~bb &&& (bb-bb_1)
      test <@ expected = ray @>
    )
    
module KnightAttacks =
  [<Fact>]
  let ``a single knight attack is a union of the surrounding 2 squares minus all rays extending from it``() =
    Assert.All(product Files._A Files._H Ranks._1 Ranks._8, fun (file, rank) ->
      let expectedBB =
        product (Math.Max(0, file-2)) (Math.Min(7, file+2)) (Math.Max(0, rank-2)) (Math.Min(7, rank+2))
        |> Seq.map (fun (x, y) -> Files.lookup[x], Ranks.lookup[y])
        |> Seq.fold (uniteRankAndFile Lookup.fileMasks Lookup.rankMasks) Bitboards.Empty
      let bb = Lookup.Position lookup (Squares._create file rank)
      let rays =
        Bitboards.Empty
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.North bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.South bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.East bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.West bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.NorthWest bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.NorthEast bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.SouthWest bb)
        |> (|||) (Lookup.calcRayAttack Lookup.fileMasks Lookup.Ray.SouthEast bb)
      let attackBB = Lookup.calcKnightAttack Lookup.fileMasks bb
      test <@ (attackBB ||| bb) = (expectedBB &&& ~~~rays) @>
    ) 
      
  [<Fact>]
  let  ``the bitboard for the attacks and the bitboard for a single knight are mutually exclusive``() =
    Assert.All([0..63], fun i ->
      let square = (Squares.create i)
      let knightBB = Lookup.Position lookup square
      let attackBB = Lookup.calcKnightAttack Lookup.fileMasks knightBB
      test <@
        attackBB &&& knightBB = Bitboards.Empty
      @>
    )
  
  [<Property(MaxTest=1000)>]
  let ``knight can move back after making move``(bb: uint64) =
    let bb = Bitboard bb
    let tmp = Lookup.calcKnightAttack Lookup.fileMasks bb
    let attackBB = Lookup.calcKnightAttack Lookup.fileMasks tmp
    test <@ (attackBB &&& bb) = bb @>
    
  
  [<Fact>]
  let ``attack for white and black knight should be the same``() =
    Assert.All([0..63], fun i ->
      let square = Squares.create i
      let whiteBB = Lookup.Look lookup Pieces.Knight Family.White square
      let blackBB = Lookup.Look lookup Pieces.Knight Family.Black square
      test <@ whiteBB = blackBB @>
    )
    
  [<Fact>]
  let ``bitboard for the attack and bitboard for single knight should be mutually exclusive``() =
    Assert.All([0..63], fun i ->
      let bb = Lookup.Position lookup (Squares.create i)
      let attackBB = Lookup.calcKnightAttack Lookup.fileMasks bb
      test <@ attackBB &&& bb = Bitboards.Empty @>
    )   

module KingAttacks =
  [<Fact>]
  let  ``the bitboard for the attacks and the bitboard for a single king are mutually exclusive``() =
    Assert.All([0..63], fun i ->
      let square = (Squares.create i)
      let kingBB = Lookup.Position lookup square
      let attackBB = Lookup.Look lookup Pieces.King White square
      test <@ attackBB &&& kingBB = Bitboards.Empty @>
    )
    
  [<Fact>]
  let ``single king attacks are one step away from the source``() =
    Assert.All(product Files._A Files._H Ranks._1 Ranks._8, fun (file, rank) ->
      let expectedBB =
        product (Math.Max(0, file-1)) (Math.Min(7,file+1)) (Math.Max(0, rank-1)) (Math.Min(7,rank+1))
        |> Seq.map (fun (x, y) -> Files.lookup[x], Ranks.lookup[y])
        |> Seq.fold (uniteRankAndFile Lookup.fileMasks Lookup.rankMasks) Bitboards.Empty
      let bb = Lookup.Position lookup (Squares._create file rank)
      let attackBB = Lookup.calcKingAttack Lookup.fileMasks bb
      test <@ (attackBB ||| bb) = expectedBB @>
    )
    
  [<Fact>]
  let ``attack for white king should be the same as the attack for black king``() =
    Assert.All([0..63], fun i ->
      let whiteBB = Lookup.Look lookup King White (Squares.create i)
      let blackBB = Lookup.Look lookup King Black (Squares.create i)
      test <@ whiteBB = blackBB @>
    )
    
  // module Corners =
  let rec union bb count =
    match count with
    | 0 ->
      bb
    | _ ->
      let attack = Lookup.calcKingAttack Lookup.fileMasks bb
      union(bb ||| attack)(count - 1)
      
  [<Fact>]
  let ``king at A1 fills the board only after 7 attack unions``() =
    let bb = Lookup.Position lookup (Squares.create2 Files.xA Ranks.x1)
    Assert.All([0..6], fun i ->
      test <@ union bb i <> Bitboards.Full @>
    )
    test <@ union bb 7 = Bitboards.Full @>
    
  [<Fact>]
  let ``king at H1 fills the board only after 7 attack unions``() =
    let bb = Lookup.Position lookup (Squares.create2 Files.xH Ranks.x1)
    Assert.All([0..6], fun i ->
      test <@ union bb i <> Bitboards.Full @>
    )
    test <@ union bb 7 = Bitboards.Full @>
     
  [<Fact>]
  let ``king at A8 fills the board only after 7 attack unions``() =
    let bb = Lookup.Position lookup (Squares.create2 Files.xA Ranks.x8)
    Assert.All([0..6], fun i ->
      test <@ union bb i <> Bitboards.Full @>
    )
    test <@ union bb 7 = Bitboards.Full @>
     
  [<Fact>]
  let ``king at H8 fills the board only after 7 attack unions``() =
    let bb = Lookup.Position lookup (Squares.create2 Files.xH Ranks.x8)
    Assert.All([0..6], fun i ->
      test <@ union bb i <> Bitboards.Full @>
    )
    test <@ union bb 7 = Bitboards.Full @>
    
  // module Overflows =
  [<Fact>]
  let ``attack for single king at the right edge should not overflow to the left``() =
    let rightEdge = Lookup.fileMasks[Files._H]
    Assert.All([0..7], fun i ->
      let rank = Lookup.rankMasks[i]
      let kingBB = rank &&& rightEdge
      let attackBB = Lookup.calcKingAttack Lookup.fileMasks kingBB
      let leftEdge = Lookup.fileMasks[Files._A]
      test <@
        kingBB |> ignore
        attackBB &&& leftEdge = Bitboards.Empty
      @>
    )
  
  [<Fact>]
  let ``attack for single king at the left edge should not overflow to the right``() =
    let leftEdge = Lookup.fileMasks[Files._A]
    Assert.All([0..7], fun i ->
      let rank = Lookup.rankMasks[i]
      let kingBB = rank &&& leftEdge
      let attackBB = Lookup.calcKingAttack Lookup.fileMasks kingBB
      let rightEdge = Lookup.fileMasks[Files._H]
      test <@
        kingBB |> ignore
        attackBB &&& rightEdge = Bitboards.Empty
      @>
    )
    
  // module Columns =
  [<Fact>]
  let ``attack for kings at the last column results in moves at last two columns``() =
    let bb = Lookup.fileMasks[Files._H]
    let attackBB = Lookup.calcKingAttack Lookup.fileMasks bb
    let expected = Lookup.fileMasks[Files._G] ||| Lookup.fileMasks[Files._H]
    test <@ attackBB = expected @>
    
  [<Fact>]
  let ``attack for kings at the first column results in moves at first two columns``() =
    let bb = Lookup.fileMasks[Files._A]
    let attackBB = Lookup.calcKingAttack Lookup.fileMasks bb
    let expected = Lookup.fileMasks[Files._B] ||| Lookup.fileMasks[Files._A]
    test <@ attackBB = expected @>
  
  [<Fact>]
  let ``attack for kings at an inner column results in moves between column before and after said column`` () =
    Assert.All([1..6], fun i ->
      let file = Lookup.fileMasks[i]
      let attackBB = Lookup.calcKingAttack Lookup.fileMasks file
      let expectBB = Lookup.fileMasks[i-1] ||| Lookup.fileMasks[i] ||| Lookup.fileMasks[i+1]
      test <@ expectBB = attackBB  @>
    )

  // module Rows = 
  [<Fact>]
  let ``attack for kings at last row results in moves at last two rows`` () =
    let rank = Lookup.rankMasks[Ranks._8]
    let attackBB = Lookup.calcKingAttack Lookup.fileMasks rank
    let expected = Lookup.rankMasks[Ranks._7] |||  Lookup.rankMasks[Ranks._8]
    test <@ expected = attackBB @>
    
  [<Fact>]
  let ``attack for kings at first row results in moves at first two rows`` () =
    let rank = Lookup.rankMasks[Ranks._1]
    let attackBB = Lookup.calcKingAttack Lookup.fileMasks rank
    let expected = Lookup.rankMasks[Ranks._1] ||| Lookup.rankMasks[Ranks._2]
    test <@ expected = attackBB @>
    
  [<Fact>]
  let ``attack for king at inner rows result in moves at row between the row before and after``() =
    Assert.All([1..6], fun (i: int) ->
      let rank = Lookup.rankMasks[i]
      let attackBB = Lookup.calcKingAttack Lookup.fileMasks rank
      let expected = Lookup.rankMasks[i-1] ||| Lookup.rankMasks[i] ||| Lookup.rankMasks[i+1]
      test <@ expected = attackBB @>
    )