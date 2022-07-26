include ../move
import base
import strformat

const
  moves  = [717294, 3612461, 1735935, 1937825, 2114547, 2921729, 2692259, 1492454, 618871, 3643533]


proc getMask(no_bits: int, offset: int): int=
  return not(0 xor (((1 shl no_bits)-1) shl offset))

template testFieldLookup*(fieldtype: typed, fieldLookup: typed, name: string, n: int, debug: bool)=
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

  for each_move in moves:
    testFieldChange(No_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "no castling", debug)
    testFieldChange(QueenSide_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "queen side castling", debug)
    testFieldChange(KingSide_Castling, each_move, setCastlingField, getCastlingField, tmp,
                    "CastlingField", "king side castling", debug)

proc testCapturedPieceFieldChange(debug: bool)=
  var
    tmp: Move

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
    doAssertRaises(AssertionDefect):
      discard setCapturedPieceField(each_move.int32, King)

proc testMovingPieceFieldChange(debug: bool)=
  var
    tmp: Move

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


proc testLocationToField(debug: bool)=
  var
    tmp: Move

  for each_move in moves:
    testFieldChange(A2, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "A2", debug)
    testFieldChange(B3, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "B3", debug)
    testFieldChange(C4, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "C4", debug)
    testFieldChange(D6, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "D6", debug)
    testFieldChange(E7, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "E7", debug)
    testFieldChange(F8, each_move, setLocationToField, getLocationToPieceField, tmp, 
                    "LocationToField", "F8", debug)
 
proc testLocationFromField(debug: bool)=
  var
    tmp: Move

  for each_move in moves:
    testFieldChange(A2, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "A2", debug)
    testFieldChange(B3, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "B3", debug)
    testFieldChange(C4, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "C4", debug)
    testFieldChange(D6, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "D6", debug)
    testFieldChange(E7, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "E7", debug)
    testFieldChange(F8, each_move, setLocationFromField, getLocationFromPieceField, tmp, 
                    "LocationFromField", "F8", debug)
 
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
  doTest "capturedPieceFieldChange", testCapturedPieceFieldChange(debug)
  doTest "movingPieceFieldChange"  , testMovingPieceFieldChange(debug)
  doTest "locationToFieldChagne"   , testLocationToField(debug)
  doTest "locationFromFieldChagne" , testLocationFromField(debug)

proc TestFullGetSet(debug: bool)=
  ## Full tests that checks that none of the fields are interfering with each other
  startTest("testing setting fields (integrated)")
  var
    tmp: Move

  doTest("all"):
    for each_move in moves:
      tmp = each_move.int32
              .setPromotionField(Queen_Promotion)
              .setCastlingField(No_Castling)
              .setCapturedPieceField(Rook)
              .setMovingPieceField(WhiteKnight)
              .setLocationToField(B6)
              .setLocationFromField(A4)
      assertVal(getPromotionField(tmp), Queen_Promotion, "wrong promo field in full test", debug)
      assertVal(getCastlingField(tmp), No_Castling, "wrong castlingPiece field in full test", debug)
      assertVal(getCapturedPieceField(tmp), Rook, "wrong capturedPiece field in full test", debug)
      assertVal(getMovingPieceField(tmp), WhiteKnight, "wrong movingPiece field in full test", debug)
      assertVal(getLocationToPieceField(tmp), B6, "wrong locationTo field in full test", debug)
      assertVal(getLocationFromPieceField(tmp), A4, "wrong locationFrom field in full test", debug)

      tmp = each_move.int32
              .setPromotionField(Knight_Promotion)
              .setCastlingField(KingSide_Castling)
              .setCapturedPieceField(NULL_PIECE)
              .setMovingPieceField(BlackPawn)
              .setLocationToField(B6)
              .setLocationFromField(A4)
      assertVal(getPromotionField(tmp), Knight_Promotion, "wrong promo field in full test", debug)
      assertVal(getCastlingField(tmp), KingSide_Castling, "wrong castlingPiece field in full test", debug)
      assertVal(getCapturedPieceField(tmp), NULL_PIECE, "wrong capturedPiece field in full test", debug)
      assertVal(getMovingPieceField(tmp), BlackPawn, "wrong movingPiece field in full test", debug)
      assertVal(getLocationToPieceField(tmp), B6, "wrong locationTo field in full test", debug)
      assertVal(getLocationFromPieceField(tmp), A4, "wrong locationFrom field in full test", debug)


when isMainModule:
  let d = false
  TestMasks(d)
  TestLookups(d)
  TestFieldGetSet(d)
  TestFullGetSet(d)
