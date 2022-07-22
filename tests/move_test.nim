import ../move
import base
import ../util
import strformat

const
  moves  = [717294, 3612461, 1735935, 1937825, 2114547, 2921729, 2692259, 1492454, 618871, 3643533]


proc getMask(no_bits: int, offset: int): int=
  return not(0 xor (((1 shl no_bits)-1) shl offset))


proc testPromotionFieldLookup(debug: bool)=
 testFieldLookup(PromotionField, PromotionFieldLookup, "PromotionField", PromotionFieldLookup.len, debug)

proc testCastlingFieldLookup(debug: bool)=
 testFieldLookup(CastlingField, CastlingFieldLookup, "CastlingField", CastlingFieldLookup.len, debug)


template testFieldChange(field, each_move, setField, getField, tmp: typed, name: string, piece: string, debug: bool)=
    # Tests that getting and setting a field works correctly
    # getting a field should return the field that was set
    tmp = setField(each_move.int32, field)
    block:
      let 
        a{.inject.} = name
        b{.inject.} = piece
      assertVal(getField(tmp), field, 
                fmt"Get and Set `{a}` incorrect for {tmp:#b} with {b}", debug) 

proc testPromotionFieldChange(debug: bool)=
  var
    tmp: Move
    field: PromotionField

  for each_move in moves:
    testFieldChange(Rook_Promotion, each_move, setPromotionField, getPromotionField, tmp,
                    "PromotionField", "rook promotion", debug)
    testFieldChange(Knight_Promotion, each_move, setPromotionField, getPromotionField, tmp,
                    "PromotionField", "knight promotion", debug)
    testFieldChange(Bishop_Promotion, each_move, setPromotionField, getPromotionField, tmp,
                    "PromotionField", "bishop promotion", debug)
    testFieldChange(Queen_Promotion, each_move, setPromotionField, getPromotionField, tmp,
                    "PromotionField", "queen promotion", debug)

proc testCastlingFieldChange(debug: bool)=
  var
    tmp: Move
    field: CastlingField

  for each_move in moves:
    testFieldChange(No_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "no castling", debug)
    testFieldChange(QueenSide_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "queen side castling", debug)
    testFieldChange(KingSide_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "king side castling", debug)

proc testMovingPieceFieldChange(debug: bool)=
  var
    tmp: Move
    field: CastlingField

  for each_move in moves:
    testFieldChange(WhitePawn, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white pawn", debug)
    testFieldChange(WhiteRook, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white rook", debug)
    testFieldChange(WhiteBishop, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white bishop", debug)
    testFieldChange(WhiteKnight, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white knight", debug)
    testFieldChange(WhiteQueen, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white queen", debug)
    testFieldChange(WhiteKing, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "white king", debug)
    testFieldChange(BlackPawn, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black pawn", debug)
    testFieldChange(BlackRook, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black rook", debug)
    testFieldChange(BlackBishop, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black bishop", debug)
    testFieldChange(BlackKnight, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black knight", debug)
    testFieldChange(BlackQueen, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black queen", debug)
    testFieldChange(BlackKing, each_move, setMovingPieceField, getMovingPieceField, tmp, 
                    "movingPieceField", "black king", debug)


proc testCapturedPieceFieldChange(debug: bool)=
  var
    tmp: Move
    field: CastlingField

  for each_move in moves:
    testFieldChange(Pawn, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "pawn", debug)
    testFieldChange(Rook, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "rook", debug)
    testFieldChange(Bishop, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "bishop", debug)
    testFieldChange(Knight, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "knight", debug)
    testFieldChange(Queen, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "queen", debug)
    testFieldChange(NULL_PIECE, each_move, setCapturedPieceField, getCapturedPieceField, tmp, 
                    "CapturedPieceField", "no capture", debug)

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

proc TestFieldGetSet(debug: bool)=
  startTest("testing setting fields")
  doTest "promotionFieldChange", testPromotionFieldChange(debug)
  doTest "castlingFieldChange" , testCastlingFieldChange(debug)
  doTest "capturedPieceFieldChange" , testCapturedPieceFieldChange(debug)
  doTest "movingPieceFieldChange" , testMovingPieceFieldChange(debug)

when isMainModule:
  echo fmt"{getMask(3,4).uint32:#010X}"
  let d = false
  TestMasks(d)
  TestLookups(d)
  TestFieldGetSet(d)

