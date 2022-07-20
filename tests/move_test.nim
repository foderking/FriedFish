import ../move
import base
from ../util import Pieces
import strformat

const
  moves  = [717294, 3612461, 1735935, 1937825, 2114547, 2921729, 2692259, 1492454, 618871, 3643533]

proc testPromotionFieldLookup(debug: bool)=
  ## Tests the mapping for `PromotionField`
  ## `PromotionField` with ordinals of 1..4 should map..
  ## to indices 0..3 in the `PromotionFieldLookup` array
  ##                 number          <==>     type
  ## therefore PromotionField.ord-1  <==> PromotionField

  # mapping type => number => type
  for field in PromotionField:
    assertval(PromotionFieldLookup[field.ord-1], field,
             "wrong type->number->type mapping for `PromotionField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..3:
    assertval(PromotionFieldLookup[number].ord-1, number,
             "wrong number->type->number mapping for `PromotionField` with "&($number), debug)

proc testCastlingFieldLookup(debug: bool)=
  ## Tests the mapping for `CastlingField`
  ## `CastlingField` with ordinals of 4..6 should map..
  ## ..to indices 0..2 in the `CastlingFieldLookup` array
  ##                 number          <==>     type
  ## therefore CastlingField.ord-4  <==> CastlingField

  # mapping type => number => type
  for field in CastlingField:
    assertval(CastlingFieldLookup[field.ord-4], field,
             "wrong type->number->type mapping for `CastlingField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..2:
    assertval(CastlingFieldLookup[number].ord-4, number,
             "wrong number->type->number mapping for `CastlingField` with "&($number), debug)

proc testMovingPieceFieldLookup(debug: bool)=
  ## Tests the mapping for `MovingPieceField`
  ##                 number          <==>     type
  ## therefore MovingPieceField.ord  <==> MovingPieceField

  # mapping type => number => type
  for field in MovingPieceField:
    assertval(MovingPieceFieldLookup[field.ord], field,
             "wrong type->number->type mapping for `MovingPieceField` at "&($field), debug)
  # mapping number => type => number
  for number in 0..5:
    assertval(MovingPieceFieldLookup[number].ord, number,
             "wrong number->type->number mapping for `MovingPieceField` with "&($number), debug)



proc testPromotionFieldChange(debug: bool)=
  ## Tests that getting and setting `PromotionField` works correctly
  ## getting a field should return the field that was set
  var
    tmp: Move
    field: Pieces

  for each_move in moves:
    field = Rook
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Rook, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with rook", debug) 
    field = Knight
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Knight, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with knight", debug) 
    field = Bishop
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Bishop, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with bishop", debug) 
    field = Queen
    tmp = setPromotionField(each_move.int32, field)
    assertVal(getPromotionField(tmp), Queen, 
              fmt"Get and Set `PromotionField` incorrect for {tmp:#b} with bishop", debug) 

proc testCastlingFieldChange(debug: bool)=
  ## Tests that getting and setting `CastlingField` works correctly
  ## getting a field should return the field that was set
  var
    tmp: Move
    field: Pieces

  for each_move in moves:
    field = Queen
    tmp = setCastlingField(each_move.int32, field)
    assertVal(getCastlingField(tmp), Queen, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with queen castling", debug) 
    field = King
    tmp = setCastlingField(each_move.int32, field)
    assertVal(getCastlingField(tmp), King, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with king castling", debug) 
    field = NULL_PIECE
    tmp = setCastlingField(each_move.int32, field)
    assertVal(getCastlingField(tmp), NULL_PIECE, 
              fmt"Get and Set `CastlingField` incorrect for {tmp:#b} with no castling", debug) 

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


proc TestMasks(debug: bool)=
  startTest("testing masks")
  assertVal(promotionField_mask, 0, "wrong mask for promotion field", debug)

proc TestLookups(debug: bool)=
  startTest("testing lookups")
  doTest "promotionFieldLookup", testPromotionFieldLookup(debug)
  doTest "castlingFieldLookup" , testCastlingFieldLookup(debug)
  doTest "movingPieceFieldLookup" , testMovingPieceFieldLookup(debug)

proc TestFieldGetSet(debug: bool)=
  startTest("testing setting fields")
  doTest "promotionFieldChange", testPromotionFieldChange(debug)
  doTest "castlingFieldChange" , testCastlingFieldChange(debug)
  doTest "movingPieceFieldChange" , testMovingPieceFieldChange(debug)

when isMainModule:
  let d = false
  #TestMasks(d)
  TestLookups(d)
  TestFieldGetSet(d)

