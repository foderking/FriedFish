import base
import ../board, ../util
from parseUtils import parseInt
from strutils import repeat

let
  fen = @[
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 3 11",
    "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b Kq e3 0 1",
    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQq c6 0 232",
    "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b kq - 13 20",
    "3Q4/bpNN4/2R4n/8/3P4/2KNkB2/7q/4r3 w - - 0 1",
    "3Q4/bpNN4/2R4n/8/3P4/2KNkB2/7q/4r3 - 2 k 111 -1"
  ]


proc testParseHalfMove(fenstrings: seq[string], debug: bool)=
  ## Tests the `parseHalfMove` function
  var index: int
  let 
    error  = "error in `parseHalfMove`"
    error2 = "incorrect index after parsing"
  index = 53
  assertVal(parseHalfMove(index, fenstrings[0]), 3, error, debug)
  assertVal(index, 54, error2, debug)
  index = 54
  assertVal(parseHalfMove(index, fenstrings[1]), 0, error, debug)
  assertVal(index, 55, error2, debug)
  index = 57
  assertVal(parseHalfMove(index, fenstrings[2]), 0, error, debug)
  assertVal(index, 58, error2, debug)
  index = 57
  assertVal(parseHalfMove(index, fenstrings[3]),13, error, debug)
  assertVal(index, 59, error2, debug)
  index = 41
  assertVal(parseHalfMove(index, fenstrings[4]), 0, error, debug)
  assertVal(index, 42, error2, debug)
  # Testing error handling
  doAssertRaises(AssertionDefect):
    index = 55
    discard parseHalfMove(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 56
    discard parseHalfMove(index, fenstrings[1])
  doAssertRaises(AssertionDefect):
    index = 59
    discard parseHalfMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 59
    discard parseHalfMove(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 43
    discard parseHalfMove(index, fenstrings[4])
  doAssertRaises(AssertionDefect):
    index = 41
    discard parseHalfMove(index, fenstrings[5])
  doAssertRaises(AssertionDefect):
    index = 100
    discard parseHalfMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 53
    discard parseHalfMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 100
    discard parseHalfMove(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 53
    discard parseHalfMove(index, fenstrings[3])

proc testParseMove(fenstrings: seq[string], debug: bool)=
  ## Tests the `parseMove` function
  var index: int
  let
    error  = "error in `parseMove`"
    error2 = "incorrect index after parsing"
  index = 55
  assertVal(parseMove(index, fenstrings[0]), 11, error, debug)
  assertVal(index, 57, error2, debug)
  index = 56
  assertVal(parseMove(index, fenstrings[1]),  1, error, debug)
  assertVal(index, 57, error2, debug)
  index = 59
  assertVal(parseMove(index, fenstrings[2]),232, error, debug)
  assertVal(index, 62, error2, debug)
  index = 60
  assertVal(parseMove(index, fenstrings[3]), 20, error, debug)
  assertVal(index, 62, error2, debug)
  index = 43
  assertVal(parseMove(index, fenstrings[4]),  1, error, debug)
  assertVal(index, 44, error2, debug)
  # Testing error handling
  doAssertRaises(AssertionDefect):
    index = 53
    discard parseMove(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 54
    discard parseMove(index, fenstrings[1])
  doAssertRaises(AssertionDefect):
    index = 57
    discard parseMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 57
    discard parseMove(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 41
    discard parseMove(index, fenstrings[4])
  doAssertRaises(AssertionDefect):
    index = 44
    discard parseMove(index, fenstrings[5])
  doAssertRaises(AssertionDefect):
    index = 100
    discard parseMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 53
    discard parseMove(index, fenstrings[2])
  doAssertRaises(AssertionDefect):
    index = 100
    discard parseMove(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 53
    discard parseMove(index, fenstrings[3])

proc testParseInt(fenstrings: seq[string], debug: bool)=
  ## Tests `parseInt`
  # TODO
  var tmp: int
  let
    error = "error in `parseInt`"
    error2 = "wrong value parsed in `parseInt`"
  assertVal(parseInt(fenstrings[0], tmp, 53), 1, error, debug)
  assertVal(tmp, 3, error2, debug)
  assertVal(parseInt(fenstrings[0], tmp, 55), 2, error, debug)
  assertVal(tmp,11, error2, debug)

proc testParseSideToMove(fenstrings: seq[string], debug: bool)=
  ## Tests `parseSideToMove`
  var index: int
  let
    error = "error in `parseSideToMove`"
    error2 = "incorrect index after parsing"
  index = 44
  assertVal(parseSideToMove(index, fenstrings[0]), White, error, debug)
  assertVal(index, 45, error2, debug)
  index = 46
  assertVal(parseSideToMove(index, fenstrings[1]), Black, error, debug)
  assertVal(index, 47, error2, debug)
  index = 48
  assertVal(parseSideToMove(index, fenstrings[2]), White, error, debug)
  assertVal(index, 49, error2, debug)
  index = 50
  assertVal(parseSideToMove(index, fenstrings[3]), Black, error, debug)
  assertVal(index, 51, error2, debug)
  index = 35
  assertVal(parseSideToMove(index, fenstrings[4]), White, error, debug)
  assertVal(index, 36, error2, debug)

  doAssertRaises(AssertionDefect):
    index = 40
    discard parseSideToMove(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 45
    discard parseSideToMove(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 135
    discard parseSideToMove(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 35
    discard parseSideToMove(index, fenstrings[5])

proc testParseEnPassant(fenstrings: seq[string], debug: bool)=
  ## Tests `parseEnPassant`
  var index: int
  let
    error = "error in `parseEnPassant`"
    error2 = "incorrect index after parsing"
  index = 51
  assertVal(parseEnPassant(index, fenstrings[0]), -1, error, debug)
  assertVal(index, 52, error2, debug)
  index = 51
  assertVal(parseEnPassant(index, fenstrings[1]), 20, error, debug)
  assertVal(index, 53, error2, debug)
  index = 54
  assertVal(parseEnPassant(index, fenstrings[2]), 42, error, debug)
  assertVal(index, 56, error2, debug)
  index = 55
  assertVal(parseEnPassant(index, fenstrings[3]), -1, error, debug)
  assertVal(index, 56, error2, debug)
  index = 39
  assertVal(parseEnPassant(index, fenstrings[4]), -1, error, debug)
  assertVal(index, 40, error2, debug)

  doAssertRaises(AssertionDefect):
    index = 40
    discard parseEnPassant(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 45
    discard parseEnPassant(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 135
    discard parseEnPassant(index, fenstrings[3])
  doAssertRaises(AssertionDefect):
    index = 39
    discard parseEnPassant(index, fenstrings[5])

proc testParseCastlingRights(fenstrings: seq[string], debug: bool)=
  ## Tests `parseCastlingRights`
  var index: int
  let
    error = "error in `parseCastlingRights`"
    error2 = "incorrect index after parsing"
  index = 46
  assertVal(parseCastlingRights(index, fenstrings[0]), 0b1111, error, debug)
  assertVal(index, 50, error2, debug)
  index = 48
  assertVal(parseCastlingRights(index, fenstrings[1]), 0b1001, error, debug)
  assertVal(index, 50, error2, debug)
  index = 50
  assertVal(parseCastlingRights(index, fenstrings[2]), 0b1101, error, debug)
  assertVal(index, 53, error2, debug)
  index = 52
  assertVal(parseCastlingRights(index, fenstrings[3]), 0b0011, error, debug)
  assertVal(index, 54, error2, debug)
  index = 37
  assertVal(parseCastlingRights(index, fenstrings[4]), 0, error, debug)
  assertVal(index, 38, error2, debug)

  doAssertRaises(AssertionDefect):
    index = 10
    discard parseCastlingRights(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 37
    discard parseCastlingRights(index, fenstrings[5])
  doAssertRaises(AssertionDefect):
    index = -1
    discard parseCastlingRights(index, fenstrings[0])
  doAssertRaises(AssertionDefect):
    index = 100
    discard parseCastlingRights(index, fenstrings[0])

proc testParsePieces(fenstrings: seq[string], debug: bool)=
  ## Tests all the bitboards initialized from fen_strings
  ## TODO
  var
    index: int
    board: BoardState
  let
    random = "5N2/5P1B/2pk1P1K/2pr1r2/3p1P2/3p3p/4Q1p1/8 w - - 0 1"
    error  = "error in `parsePieces` for black"
    error2 = "error in `parsePieces` for white"
    error3 = "incorrect index after parsing"

  index=0
  board=BoardState()
  parsePieces(index, fenstrings[0], board)
  assertVal(index, 43, error3, debug)
  assertVal(board.getAllBlackPieces, 18446462598732840960u64, error, debug)
  assertVal(board.getAllWhitePieces, 65535u64, error2, debug)

  index=0
  board=BoardState()
  parsePieces(index, fenstrings[1], board)
  assertVal(index, 45, error3, debug)
  assertVal(board.getAllBlackPieces, 18446462598732840960u64, error, debug)
  assertVal(board.getAllWhitePieces, 268496895u64, error2, debug)
  
  index=0
  board=BoardState()
  parsePieces(index, fenstrings[2], board)
  assertVal(index, 47, error3, debug)
  assertVal(board.getAllBlackPieces, 18445336716005867520u64, error, debug)
  assertVal(board.getAllWhitePieces, 268496895u64, error2, debug)
  
  index=0
  board=BoardState()
  parsePieces(index, fenstrings[3], board)
  assertVal(index, 49, error3, debug)
  assertVal(board.getAllBlackPieces, 18445336716005867520u64, error, debug)
  assertVal(board.getAllWhitePieces, 270593983u64, error2, debug)
  
  index=0
  board=BoardState()
  parsePieces(index, fenstrings[4], board)
  assertVal(index, 34, error3, debug)
  assertVal(board.getAllBlackPieces, 985162419568656u64, error, debug)
  assertVal(board.getAllWhitePieces, 579842850207563776u64, error2, debug)

  index=0
  board=BoardState()
  parsePieces(index, random, board)
  assertVal(index, 42, error3, debug)
  assertVal(board.getAllBlackPieces, 13383261241344u64, error, debug)
  assertVal(board.getAllWhitePieces, 2351054927884718080u64, error2, debug)

  doAssertRaises(AssertionDefect):
    index = 100
    parsePieces(index, fenstrings[0], board)
  doAssertRaises(AssertionDefect):
    index = 8
    parsePieces(index, fenstrings[0], board)
  doAssertRaises(AssertionDefect):
    index = 15
    parsePieces(index, fenstrings[0], board)
  doAssertRaises(AssertionDefect):
    index = 45
    parsePieces(index, fenstrings[0], board)
  doAssertRaises(AssertionDefect):
    index = -324
    parsePieces(index, fenstrings[0], board)

proc TestAllParsers(debug: bool)=
  startTest("testing parsers")

  doTest("fenstrings"):
    assertVal(fen[0][53], '3', "Wrong value for string", debug)
    assertVal(fen[1][54], '0', "wrong value for string", debug)
    assertVal(fen[3][59], ' ', "wrong value for string", debug)
  doTest testParseInt(fen, debug),            "parseInt"
  doTest testParseHalfMove(fen, debug),       "parseHalfMove"
  doTest testParseMove(fen, debug),           "parseMove"
  doTest testParseSideToMove(fen, debug),     "parseSideToMove"
  doTest testParseEnPassant(fen, debug),      "parseEnPassant"
  doTest testParseCastlingRights(fen, debug), "parseCastlingRights"
  doTest testParsePieces(fen, debug),         "parsePieces"

proc TestFenValidator(debug: bool)=
  # TODO
  startTest("testing fen validation")
  assertVal("rnbqkbnr/pp1ppppp/8/2p5/4P3/8/p/RNBQKBNR w - e4 0 2".fenValid, 
            true, "wrong validation", debug)

proc TestBoards(debug: bool)=
  startTest("testing board state init")
  var
    board: BoardState
  let random = "5N2/5P1B/2pk1P1K/2pr1r2/3p1P2/3p3p/4Q1p1/8 w - - 0 1"

  doTest("init"):
    assertVal(initBoard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
              initBoard(), "boards don't match", debug)
    doAssertRaises(AssertionDefect):
      discard initBoard("3Q4/bpNN4/2R4n/8/3P4/2KNkB2/7q/4r3 - 2 k 111 -1")

  doTest("random fen"):
    board=initBoard(random)
    assertVal(board.getAllBlackPieces, 13383261241344u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 2351054927884718080u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 9042384163700736u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 0u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 36028797018963968u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 2305843009213693952u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 4096u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 140737488355328u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 4415369527296u64, "wrong value for black pawn", debug)
    assertBitboard(board.black[Rook], 171798691840u64, "wrong value for black rook", debug)
    assertBitboard(board.black[Bishop], 0u64, "wrong value for black bishop", debug)
    assertBitboard(board.black[Knight], 0u64, "wrong value for black knight", debug)
    assertBitboard(board.black[Queen], 0u64, "wrong value for black queen", debug)
    assertBitboard(board.black[King], 8796093022208u64, "wrong value for black king", debug)

  doTest("fen[0]"):
    board=initBoard(fen[0])
    assertVal(board.getAllBlackPieces, 18446462598732840960u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 65535u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 65280u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 16u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 71776119061217280u64, "wrong value for black pawn", debug)
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook", debug)
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop", debug)
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight", debug)
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen", debug)
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king", debug)


  doTest("fen[1]"):
    board=initBoard(fen[1])
    assertVal(board.getAllBlackPieces, 18446462598732840960u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 268496895u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 16u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 71776119061217280u64, "wrong value for black pawn", debug)
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook", debug)
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop", debug)
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight", debug)
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen", debug)
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king", debug)


  doTest("fen[2]"):
    board=initBoard(fen[2])
    assertVal(board.getAllBlackPieces, 18445336716005867520u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 268496895u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 16u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 70650236334243840u64, "wrong value for black pawn", debug)
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook", debug)
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop", debug)
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight", debug)
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen", debug)
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king", debug)


  doTest("fen[3]"):
    board=initBoard(fen[3])
    assertVal(board.getAllBlackPieces, 18445336716005867520u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 270593983u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 2097154u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 16u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 70650236334243840u64, "wrong value for black pawn", debug)
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook", debug)
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop", debug)
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight", debug)
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen", debug)
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king", debug)


  doTest("fen[4]"):
    board=initBoard(fen[4])
    assertVal(board.getAllBlackPieces, 985162419568656u64,
              "invalid bitboard for black pieces", debug)
    assertVal(board.getAllWhitePieces, 579842850207563776u64,
              "invalid bitboard for white pieces", debug)
    assertBitboard(board.white[Pawn], 134217728u64, "wrong value for white pawn", debug)
    assertBitboard(board.white[Rook], 4398046511104u64, "wrong value for white rook", debug)
    assertBitboard(board.white[Bishop], 2097152u64, "wrong value for white bishop", debug)
    assertBitboard(board.white[Knight], 3377699721052160u64, "wrong value for white knight", debug)
    assertBitboard(board.white[Queen], 576460752303423488u64, "wrong value for white queen", debug)
    assertBitboard(board.white[King], 262144u64, "wrong value for white king", debug)

    assertBitboard(board.black[Pawn], 562949953421312u64, "wrong value for pawn", debug)
    assertBitboard(board.black[Rook], 16u64, "wrong value for rook", debug)
    assertBitboard(board.black[Bishop], 281474976710656u64, "wrong value for bishop", debug)
    assertBitboard(board.black[Knight], 140737488355328u64, "wrong value for knight", debug)
    assertBitboard(board.black[Queen], 32768u64, "wrong value for queen", debug)
    assertBitboard(board.black[King], 1048576u64, "wrong value for king", debug)

#[
#
  ]#

when isMainModule:
  let d = true
  TestAllParsers(d)
  TestFenValidator(d)
  TestBoards(d)
