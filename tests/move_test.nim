import ../move
import base
from ../util import Pieces, PieceLookup
import strformat

const
  moves  = [717294, 3612461, 1735935, 1937825, 2114547, 2921729, 2692259, 1492454, 618871, 3643533]


proc getMask(no_bits: int, offset: int): int=
  return not(0 xor (((1 shl no_bits)-1) shl offset))

template testFieldLookup(fieldtype: typed, fieldLookup: typed, name: string, n: int, debug: bool)=
  ## Tests the mapping for a move fieldtype
  ## Each fieldtype has a Lookup array associated with it,.
  ## in the lookup array, every type is an element, and the indices is the numerical rep of the type
  ## for example `PromotionField` lookup has numerical rep:
  ##   Rook = 0, Bishop = 1, Knight = 2, Queen = 3
  ## The lookup would have the type indexed by its numerical rep
  ##
  ## Because of this, the following properties hold
  ## field.ord => index in lookup => field
  ## - The ordinal of the type would give its index in the lookup
  ## - The index in the lookup would give the type back
  ##
  ## this is an inverse mapping
  ##        type->number->type Mapping
  ##        ==========================
  ##                                       (lookup)
  ##            fieldtype ==> fieldtype.ord  ==>  fieldtype
  ##
  ##        number->type->number Mapping
  ##        ===========================
  ##        where `fieldvalue` is the numerical rep of the type
  ##                      (lookup)
  ##           fieldvalue ====>  fieldtype ==> fieldtype.ord


  # mapping type => number => type
  for field in fieldtype:
    assertval(fieldLookup[field.ord], field,
             "wrong type->number->type mapping for `"&name&"` at "&($field), debug)
  # mapping number => type => number
  # 0..n is the range of numerical reps of the type
  for number in 0..<n:
    assertval(fieldLookup[number].ord, number,
             "wrong number->type->number mapping for `"&name&"` with "&($number), debug)


proc testPromotionFieldLookup(debug: bool)=
  ## Tests the mapping for `PromotionField`
  ## `PromotionField` with ordinals of 1..4 should map..
  ## to indices 0..3 in the `PromotionFieldLookup` array
  ##                 number          <==>     type
  ## therefore PromotionField.ord  <==> PromotionField

  # mapping type => number => type
  #[
  for field in PromotionField:
    assertval(PromotionFieldLookup[field.ord], field,
             "wrong type->number->type mapping for `PromotionField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..3:
    assertval(PromotionFieldLookup[number].ord, number,
             "wrong number->type->number mapping for `PromotionField` with "&($number), debug)
  ]#
  testFieldLookup(PromotionField, PromotionFieldLookup, "PromotionField", PromotionFieldLookup.len, debug)

proc testCastlingFieldLookup(debug: bool)=
  ## Tests the mapping for `CastlingField`
  ## `CastlingField` with ordinals of 4..6 should map..
  ## ..to indices 0..2 in the `CastlingFieldLookup` array
  ##                 number          <==>     type
  ## therefore CastlingField.ord  <==> CastlingField

  # mapping type => number => type
  #[
  for field in CastlingField:
    assertval(CastlingFieldLookup[field.ord], field,
             "wrong type->number->type mapping for `CastlingField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..2:
    assertval(CastlingFieldLookup[number].ord, number,
             "wrong number->type->number mapping for `CastlingField` with "&($number), debug)

  ]#
  testFieldLookup(CastlingField, CastlingFieldLookup, "CastlingField", CastlingFieldLookup.len, debug)

proc testCapturedPieceFieldLookup(debug: bool)=
  testFieldLookup(CapturedPieceField, PieceLookup, "CapturedField", PieceLookup.len, debug)

proc testMovingPieceFieldLookup(debug: bool)=
  ## Tests the mapping for `MovingPieceField`
  ##                 number          <==>     type
  ## therefore MovingPieceField.ord  <==> MovingPieceField

  # mapping type => number => type
  #[
  for field in MovingPieceField:
    assertval(MovingPieceFieldLookup[field.ord], field,
             "wrong type->number->type mapping for `MovingPieceField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..5:
    assertval(MovingPieceFieldLookup[number].ord, number,
             "wrong number->type->number mapping for `MovingPieceField` with "&($number), debug)

  ]#
  testFieldLookup(MovingPieceField, MovingPieceFieldLookup, "MovingPieceField", MovingPieceFieldLookup.len, debug)


proc testPromotionFieldChange(debug: bool)=
  ## Tests that getting and setting `PromotionField` works correctly
  ## getting a field should return the field that was set
  var
    tmp: Move
    field: PromotionField

  for each_move in moves:
    field = Rook_Promotion
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Rook_Promotion, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with rook", debug) 
    field = Knight_Promotion
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Knight_Promotion, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with knight", debug) 
    field = Bishop_Promotion
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Bishop_Promotion, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with bishop", debug) 
    field = Queen_Promotion
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Queen_Promotion, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with bishop", debug) 

proc testCastlingFieldChange(debug: bool)=
  ## Tests that getting and setting `CastlingField` works correctly
  ## getting a field should return the field that was set
  var
    tmp: Move
    field: CastlingField

  for each_move in moves:
    field = QueenSide_Castling
    tmp = setCastlingField(each_move.int32, field)
    #echo fmt"{each_move:#b}"
    #echo fmt"{tmp:#b}"
    assertVal(getCastlingField(tmp), QueenSide_Castling, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with queen castling", debug) 
    field = KingSide_Castling
    tmp = setCastlingField(each_move.int32, field)
    assertVal(getCastlingField(tmp), KingSide_Castling, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with king castling", debug) 
    field = No_Castling
    tmp = setCastlingField(each_move.int32, field)
    assertVal(getCastlingField(tmp), No_Castling, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with no castling", debug) 

#[
proc testMovingPieceFieldChange(debug: bool)=
  ## Tests that getting and setting `MovingPieceField` works correctly
  ## getting a field should return the field that was set
  var
    tmp: Move
    field: Pieces

  for each_move in moves:
    field = Pawn
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), Pawn, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with pawn", debug) 
    field = Bishop
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), Bishop, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with bishop", debug) 
    field = Rook
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), Rook, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with rook", debug) 
    field = Knight
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), Knight, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with knight", debug) 
    field = Queen
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), Queen, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with queen", debug) 
    field = King
    tmp = setMovingPieceField(each_move.int32, field)
    assertVal(getMovingPieceField(tmp), King, 
              fmt"Get and Set `MovingPieceField` incorrect for {tmp:#b} with king", debug) 
              ]#


proc TestMasks(debug: bool)=
  startTest("testing masks")
  doTest("promotionField mask"):
    assertVal(promotionField_mask, getMask(2,0), "wrong mask for promotion field", debug)
  doTest("castlingField mask"):
    assertVal(castlingField_mask, getMask(2,2), "wrong mask for castling field", debug)
  doTest("capturedPieceField mask"):
    assertVal(capturedPieceField_mask, getMask(3,4), "wrong mask for captured piece field", debug)
  doTest("movingPieceField mask"):
    assertVal(movingPieceField_mask, getMask(4,7), "wrong mask for moving piece field", debug)
  doTest("locationToField mask"):
    assertVal(locationToField_mask, getMask(6,11), "wrong mask for location to field", debug)
  doTest("locationFromField mask"):
    assertVal(locationFromField_mask, getMask(6,17), "wrong mask for location from field", debug)
    
  doTest("last mask"):
    assertVal(last_mask, getMask(9,23), "wrong mask for location from field", debug)

proc TestLookups(debug: bool)=
  startTest("testing lookups")
  doTest "promotionFieldLookup", testPromotionFieldLookup(debug)
  doTest "castlingFieldLookup" , testCastlingFieldLookup(debug)
  doTest "capturedPieceFieldLookup" , testCapturedPieceFieldLookup(debug)
  doTest "movingPieceFieldLookup" , testMovingPieceFieldLookup(debug)

proc TestFieldGetSet(debug: bool)=
  startTest("testing setting fields")
  doTest "promotionFieldChange", testPromotionFieldChange(debug)
  doTest "castlingFieldChange" , testCastlingFieldChange(debug)
 ## doTest "movingPieceFieldChange" , testMovingPieceFieldChange(debug)

when isMainModule:
  echo fmt"{getMask(3,4).uint32:#010X}"
  let d = false
  TestMasks(d)
  TestLookups(d)
  TestFieldGetSet(d)

