module Tests.Lookup

open FriedFish
open FriedFish.Domain
open Xunit
open Swensen.Unquote.Assertions

let lookup = Lookup.create()

module KnightAttacks =
  [<Fact>]
  let  ``the bitboard for the attacks and the bitboard for a single king are mutually exclusive``() =
    Assert.All([0..63], fun i ->
      let square = (Squares.create i)
      let knightBB = Lookup.Position lookup square
      let attackBB = Lookup.Look lookup Pieces.Knight White square
      test <@
        attackBB &&& knightBB = 0UL
      @>
    )
  

module KingAttacks =
  [<Fact>]
  let  ``the bitboard for the attacks and the bitboard for a single king are mutually exclusive``() =
    Assert.All([0..63], fun i ->
      let square = (Squares.create i)
      let kingBB = Lookup.Position lookup square
      let attackBB = Lookup.Look lookup Pieces.King White square
      test <@
        attackBB &&& kingBB = 0UL
      @>
    )
  // king attacks are one step away from the source
  // attack for single king at the right edge should not overflow to the left
  // attack for single king at the left edge should not overflow to the right
  // attack for multiple kings at the right edge should not overflow to the left
  // attack for multiple kings at the left edge should not overflow to the right
  // attack for multiple king at middle column should be columns before and after
  // attack for multiple king at top edge should be the row directly below
  // attack for multiple king at bottom edge should be the row directly above
  // attack for multiple kings at middle rows should be the rows above and below
  // attack for white king should be the same as the attack for black king
