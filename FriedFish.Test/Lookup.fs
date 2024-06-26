﻿module Tests.Lookup

open System
//open FriedFish
// open FsCheck.Xunit
open FsCheck.Xunit
open Xunit
open Swensen.Unquote.Assertions

[<Fact>]
let ``sadf``()=
    true
//let board = Board.Create()
//let lookup = Lookup.Lookup.Create()
//let bb_1 = 1UL
//let [<Literal>] noTests = 10000


//module KingAttacks =
//  let product(firstLow: int)firstHigh secondLow secondHigh = seq {
//    for x in firstLow..firstHigh do
//      for y in secondLow..secondHigh do
//        yield x,y
//  }

//  let uniteRankAndFile(fileMask: Bitboard[])(rankMask: Bitboard[])(bb: Bitboard)(file: int, rank: int) =
//    bb ||| (fileMask[int file] &&& rankMask[int rank])
   
//  module EmptyBoard =
//    let look = Board.Look board.lookup Family.White (Bitboards.Empty) Piece.King
    
//    [<Fact>]
//    let  ``the bitboard for the attacks and the bitboard for a single king are mutually exclusive``() =
//      Assert.All([0..63], fun square ->
//        let kingBB = board.lookup.boardPosition[square]
//        let attackBB = look square
//        test <@ attackBB &&& kingBB = Bitboards.Empty @>
//      )
      
//    [<Fact>]
//    let ``single king attacks are one step away from the source``() =
//      Assert.All(product 0 7 0 7, fun (file, rank) ->
//        let square = Squares.create (enum rank) (enum file)
//        let expectedBB =
//          product (Math.Max(0, file-1)) (Math.Min(7,file+1)) (Math.Max(0, rank-1)) (Math.Min(7,rank+1))
//          |> Seq.fold (uniteRankAndFile board.lookup.fileMasks board.lookup.rankMasks) Bitboards.Empty
//        let bb = board.lookup.boardPosition[square]
//        let attackBB = look square
//        test <@ (attackBB ||| bb) = expectedBB @>
//      )
       
//    (*
//    // module Overflows =
//    [<Fact>]
//    let ``attack for single king at the right edge should not overflow to the left``() =
//      let rightEdge = board.lookup.fileMasks[int File._H]
//      Assert.All([0..7], fun i ->
//        let rank = board.lookup.rankMasks[i]
//        let kingBB = rank &&& rightEdge
//        let attackBB = Lookup.calcKingAttack board.lookup.fileMasks kingBB
//        let leftEdge = board.lookup.fileMasks[Files._A]
//        test <@
//          kingBB |> ignore
//          attackBB &&& leftEdge = Bitboards.Empty
//        @>
//      )
    
//    [<Fact>]
//    let ``attack for single king at the left edge should not overflow to the right``() =
//      let leftEdge = board.lookup.fileMasks[Files._A]
//      Assert.All([0..7], fun i ->
//        let rank = board.lookup.rankMasks[i]
//        let kingBB = rank &&& leftEdge
//        let attackBB = Lookup.calcKingAttack board.lookup.fileMasks kingBB
//        let rightEdge = board.lookup.fileMasks[File._H]
//        test <@
//          kingBB |> ignore
//          attackBB &&& rightEdge = Bitboards.Empty
//        @>
//      )
      
     
//    // module Corners =
//    let rec union bb count =
//      match count with
//      | 0 ->
//        bb
//      | _ ->
//        let attack = Lookup.calcKingAttack board.lookup.fileMasks bb
//        union(bb ||| attack)(count - 1)
        
//    [<Fact>]
//    let ``king at A1 fills the board only after 7 attack unions``() =
//      let bb = Lookup.Position lookup (Squares.create2 Files.xA Ranks.x1)
//      Assert.All([0..6], fun i ->
//        test <@ union bb i <> Bitboards.Full @>
//      )
//      test <@ union bb 7 = Bitboards.Full @>
      
//    [<Fact>]
//    let ``king at H1 fills the board only after 7 attack unions``() =
//      let bb = Lookup.Position lookup (Squares.create2 Files.xH Ranks.x1)
//      Assert.All([0..6], fun i ->
//        test <@ union bb i <> Bitboards.Full @>
//      )
//      test <@ union bb 7 = Bitboards.Full @>
       
//    [<Fact>]
//    let ``king at A8 fills the board only after 7 attack unions``() =
//      let bb = Lookup.Position lookup (Squares.create2 Files.xA Ranks.x8)
//      Assert.All([0..6], fun i ->
//        test <@ union bb i <> Bitboards.Full @>
//      )
//      test <@ union bb 7 = Bitboards.Full @>
       
//    [<Fact>]
//    let ``king at H8 fills the board only after 7 attack unions``() =
//      let bb = Lookup.Position lookup (Squares.create2 Files.xH Ranks.x8)
//      Assert.All([0..6], fun i ->
//        test <@ union bb i <> Bitboards.Full @>
//      )
//      test <@ union bb 7 = Bitboards.Full @>
     
//    // module Columns =
//    [<Fact>]
//    let ``attack for kings at the last column results in moves at last two columns``() =
//      let bb = board.lookup.fileMasks[File._H]
//      let attackBB = Lookup.calcKingAttack board.lookup.fileMasks bb
//      let expected = board.lookup.fileMasks[Files._G] ||| board.lookup.fileMasks[File._H]
//      test <@ attackBB = expected @>
      
//    [<Fact>]
//    let ``attack for kings at the first column results in moves at first two columns``() =
//      let bb = board.lookup.fileMasks[Files._A]
//      let attackBB = Lookup.calcKingAttack board.lookup.fileMasks bb
//      let expected = board.lookup.fileMasks[Files._B] ||| board.lookup.fileMasks[Files._A]
//      test <@ attackBB = expected @>
    
//    [<Fact>]
//    let ``attack for kings at an inner column results in moves between column before and after said column`` () =
//      Assert.All([1..6], fun i ->
//        let file = board.lookup.fileMasks[i]
//        let attackBB = Lookup.calcKingAttack board.lookup.fileMasks file
//        let expectBB = board.lookup.fileMasks[i-1] ||| board.lookup.fileMasks[i] ||| board.lookup.fileMasks[i+1]
//        test <@ expectBB = attackBB  @>
//      )

//    // module Rows = 
//    [<Fact>]
//    let ``attack for kings at last row results in moves at last two rows`` () =
//      let rank = board.lookup.rankMasks[Ranks._8]
//      let attackBB = Lookup.calcKingAttack board.lookup.fileMasks rank
//      let expected = board.lookup.rankMasks[Ranks._7] |||  board.lookup.rankMasks[Ranks._8]
//      test <@ expected = attackBB @>
      
//    [<Fact>]
//    let ``attack for kings at first row results in moves at first two rows`` () =
//      let rank = board.lookup.rankMasks[Ranks._1]
//      let attackBB = Lookup.calcKingAttack board.lookup.fileMasks rank
//      let expected = board.lookup.rankMasks[Ranks._1] ||| board.lookup.rankMasks[Ranks._2]
//      test <@ expected = attackBB @>
      
//    [<Fact>]
//    let ``attack for king at inner rows result in moves at row between the row before and after``() =
//      Assert.All([1..6], fun (i: int) ->
//        let rank = board.lookup.rankMasks[i]
//        let attackBB = Lookup.calcKingAttack board.lookup.fileMasks rank
//        let expected = board.lookup.rankMasks[i-1] ||| board.lookup.rankMasks[i] ||| board.lookup.rankMasks[i+1]
//        test <@ expected = attackBB @>
//      )
//   **)
//  module NonEmtpy =
//    [<Property(MaxTest = noTests)>]
//    let ``attack for white king should be the same as the attack for black king``(all: uint64) =
//      Assert.All([0..63], fun square ->
//        let allPieces = all ^^^ board.lookup.boardPosition[square]
//        let white = Board.Look board.lookup Family.White allPieces Piece.King square
//        let black = Board.Look board.lookup Family.Black allPieces Piece.King square
//        Assert.Equal(white,black)
//      )
      
//    [<Property(MaxTest = noTests)>]
//    let ``the attacks for king isn't affected by other pieces in the board``(first: uint64, second: uint64) =
//      Assert.All([0..63], fun square ->
//        let a = first  ^^^ board.lookup.boardPosition[square]
//        let b = second ^^^ board.lookup.boardPosition[square]
//        let one = Board.Look board.lookup Family.White a Piece.King square
//        let two = Board.Look board.lookup Family.White b Piece.King square
//        Assert.Equal(one,two)
//      )   
//  (* 
//module Rays =
//  [<Fact>]
//  let ``north ray generates correctly``() =
//    Assert.All([0..63], fun i ->
//      let square = Squares.create i
//      let bb = (Lookup.Position lookup square)
//      let ray = Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.North bb
//      let expected = board.lookup.fileMasks[Files.extract square] &&& ~~~(bb ||| (bb-bb_1)) 
//      test <@ expected = ray @>
//    )
    
//  [<Fact>]
//  let ``south ray generates correctly``() =
//    Assert.All([0..63], fun i ->
//      let square = Squares.create i
//      let bb = (Lookup.Position lookup square)
//      let ray = Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.South bb
//      let expected = board.lookup.fileMasks[Files.extract square] &&& ~~~bb &&& (bb-bb_1)
//      test <@ expected = ray @>
//    )
    
//  [<Fact>]
//  let ``east ray generates correctly``() =
//    Assert.All([0..63], fun i ->
//      let square = Squares.create i
//      let bb = (Lookup.Position lookup square)
//      let ray = Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.East bb
//      let expected = board.lookup.rankMasks[Ranks.extract square] &&& ~~~(bb ||| (bb-bb_1)) 
//      test <@ expected = ray @>
//    )
     
//  [<Fact>]
//  let ``west ray generates correctly``() =
//    Assert.All([0..63], fun i ->
//      let square = Squares.create i
//      let bb = (Lookup.Position lookup square)
//      let ray = Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.West bb
//      let expected = board.lookup.rankMasks[Ranks.extract square] &&& ~~~bb &&& (bb-bb_1)
//      test <@ expected = ray @>
//    )
    
//module KnightAttacks =
//  [<Fact>]
//  let ``a single knight attack is a union of the surrounding 2 squares minus all rays extending from it``() =
//    Assert.All(product Files._A Files._H Ranks._1 Ranks._8, fun (file, rank) ->
//      let expectedBB =
//        product (Math.Max(0, file-2)) (Math.Min(7, file+2)) (Math.Max(0, rank-2)) (Math.Min(7, rank+2))
//        |> Seq.map (fun (x, y) -> Files.lookup[x], Ranks.lookup[y])
//        |> Seq.fold (uniteRankAndFile board.lookup.fileMasks board.lookup.rankMasks) Bitboards.Empty
//      let bb = Lookup.Position lookup (Squares._create file rank)
//      let rays =
//        Bitboards.Empty
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.North bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.South bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.East bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.West bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.NorthWest bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.NorthEast bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.SouthWest bb)
//        |> (|||) (Lookup.calcRayAttack board.lookup.fileMasks Lookup.Ray.SouthEast bb)
//      let attackBB = Lookup.calcKnightAttack board.lookup.fileMasks bb
//      test <@ (attackBB ||| bb) = (expectedBB &&& ~~~rays) @>
//    ) 
      
//  [<Fact>]
//  let  ``the bitboard for the attacks and the bitboard for a single knight are mutually exclusive``() =
//    Assert.All([0..63], fun i ->
//      let square = (Squares.create i)
//      let knightBB = Lookup.Position lookup square
//      let attackBB = Lookup.calcKnightAttack board.lookup.fileMasks knightBB
//      test <@
//        attackBB &&& knightBB = Bitboards.Empty
//      @>
//    )
  
//  [<Property(MaxTest=1000)>]
//  let ``knight can move back after making move``(bb: uint64) =
//    let bb = Bitboard bb
//    let tmp = Lookup.calcKnightAttack board.lookup.fileMasks bb
//    let attackBB = Lookup.calcKnightAttack board.lookup.fileMasks tmp
//    test <@ (attackBB &&& bb) = bb @>
    
  
//  [<Fact>]
//  let ``attack for white and black knight should be the same``() =
//    Assert.All([0..63], fun i ->
//      let square = Squares.create i
//      let whiteBB = Lookup.Look lookup Pieces.Knight Family.White square
//      let blackBB = Lookup.Look lookup Pieces.Knight Family.Black square
//      test <@ whiteBB = blackBB @>
//    )
    
//  [<Fact>]
//  let ``bitboard for the attack and bitboard for single knight should be mutually exclusive``() =
//    Assert.All([0..63], fun i ->
//      let bb = Lookup.Position lookup (Squares.create i)
//      let attackBB = Lookup.calcKnightAttack board.lookup.fileMasks bb
//      test <@ attackBB &&& bb = Bitboards.Empty @>
//    )   

//    *)
