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

proc testParseHalfMove(fenstrings: seq[string])=
  var index: int

  index = 53
  assertVal(parseHalfMove(index, fenstrings[0]), 3, "error in move parser")
  assertVal(index, 54, "incorrect index after parsing")

  index = 54
  assertVal(parseHalfMove(index, fenstrings[1]), 0, "error in move parser")
  assertVal(index, 55, "incorrect index after parsing")

  index = 57
  assertVal(parseHalfMove(index, fenstrings[2]), 0, "error in move parser")
  assertVal(index, 58, "incorrect index after parsing")

  index = 57
  assertVal(parseHalfMove(index, fenstrings[3]), 13, "error in move parser")
  assertVal(index, 59, "incorrect index after parsing")

  index = 41
  assertVal(parseHalfMove(index, fenstrings[4]), 0, "error in move parser")
  assertVal(index, 42, "incorrect index after parsing")

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

proc testParseMove(fenstrings: seq[string])=
  var index: int

  index = 55
  assertVal(parseMove(index, fenstrings[0]), 11, "error in halfmove parser")
  assertVal(index, 57, "incorrect index after parsing")

  index = 56
  assertVal(parseMove(index, fenstrings[1]), 1, "error in halfmove parser")
  assertVal(index, 57, "incorrect index after parsing")

  index = 59
  assertVal(parseMove(index, fenstrings[2]), 232, "error in halfmove parser")
  assertVal(index, 62, "incorrect index after parsing")

  index = 60
  assertVal(parseMove(index, fenstrings[3]), 20, "error in halfmove parser")
  assertVal(index, 62, "incorrect index after parsing")

  index = 43
  assertVal(parseMove(index, fenstrings[4]), 1, "error in halfmove parser")
  assertVal(index, 44, "incorrect index after parsing")

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

proc testParseInt(fenstrings: seq[string])=
  var tmp: int
  assertVal(parseInt(fenstrings[0], tmp, 53), 1, "error parsing int")
  assertVal(tmp, 3, "wrong value for int parsed")
  assertVal(parseInt(fenstrings[0], tmp, 55), 2, "error parsing int")
  assertVal(tmp, 11, "wrong value for int parsed")

proc testParseSideToMove(fenstrings: seq[string])=
  var index: int

  index = 44
  assertVal(parseSideToMove(index, fenstrings[0]), White, "error in sidetomove parser")
  assertVal(index, 45, "incorrect index after parsing")

  index = 46
  assertVal(parseSideToMove(index, fenstrings[1]), Black, "error in sidetomove parser")
  assertVal(index, 47, "incorrect index after parsing")

  index = 48
  assertVal(parseSideToMove(index, fenstrings[2]), White, "error in sidetomove parser")
  assertVal(index, 49, "incorrect index after parsing")

  index = 50
  assertVal(parseSideToMove(index, fenstrings[3]), Black, "error in sidetomove parser")
  assertVal(index, 51, "incorrect index after parsing")

  index = 35
  assertVal(parseSideToMove(index, fenstrings[4]), White, "error in sidetomove parser")
  assertVal(index, 36, "incorrect index after parsing")

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

proc testParseEnPassant(fenstrings: seq[string])=
  var index: int

  index = 51
  assertVal(parseEnPassant(index, fenstrings[0]), -1, "error parsing enpassant")
  assertVal(index, 52, "incorrect index after parsing")

  index = 51
  assertVal(parseEnPassant(index, fenstrings[1]), 20, "error parsing enpassant")
  assertVal(index, 53, "incorrect index after parsing")

  index = 54
  assertVal(parseEnPassant(index, fenstrings[2]), 42, "error parsing enpassant")
  assertVal(index, 56, "incorrect index after parsing")

  index = 55
  assertVal(parseEnPassant(index, fenstrings[3]), -1, "error parsing enpassant")
  assertVal(index, 56, "incorrect index after parsing")

  index = 39
  assertVal(parseEnPassant(index, fenstrings[4]), -1, "error parsing enpassant")
  assertVal(index, 40, "incorrect index after parsing")
  
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

proc testParseCastlingRights(fenstrings: seq[string])=
  var index: int

  index = 46
  assertVal(parseCastlingRights(index, fenstrings[0]), 0b1111,
            "error parsing castling rights")
  assertVal(index, 50, "incorrect index after parsing")

  index = 48
  assertVal(parseCastlingRights(index, fenstrings[1]), 0b1001,
            "error parsing castling rights")
  assertVal(index, 50, "incorrect index after parsing")

  index = 50
  assertVal(parseCastlingRights(index, fenstrings[2]), 0b1101,
            "error parsing castling rights")
  assertVal(index, 53, "incorrect index after parsing")

  index = 52
  assertVal(parseCastlingRights(index, fenstrings[3]), 0b0011,
            "error parsing castling rights")
  assertVal(index, 54, "incorrect index after parsing")

  index = 37
  assertVal(parseCastlingRights(index, fenstrings[4]), 0,
            "error parsing castling rights")
  assertVal(index, 38, "incorrect index after parsing")

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

proc testParsePieces(fenstrings: seq[string])=
  var
    index: int
    board: BoardState
  let random = "5N2/5P1B/2pk1P1K/2pr1r2/3p1P2/3p3p/4Q1p1/8 w - - 0 1"

  index=0
  board=BoardState()
  parsePieces(index, fenstrings[0], board)
  assertVal(index, 43, "wrong index after parsing")
  assertVal(board.getAllBlackPieces, 18446462598732840960u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 65535u64,
            "invalid bitboard for white pieces")
  index=0
  board=BoardState()
  parsePieces(index, fenstrings[1], board)
  assertVal(index, 45, "wrong index after parsing")
  assertVal(board.getAllBlackPieces, 18446462598732840960u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 268496895u64,
            "invalid bitboard for white pieces")
  index=0
  board=BoardState()
  parsePieces(index, fenstrings[2], board)
  assertVal(index, 47, "wrong index after parsing")
  assertVal(board.getAllBlackPieces, 18445336716005867520u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 268496895u64,
            "invalid bitboard for white pieces")

  index=0
  board=BoardState()
  parsePieces(index, fenstrings[3], board)
  assertVal(index, 49, "wrong index after parsing")
  assertVal(board.getAllBlackPieces, 18445336716005867520u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 270593983u64,
            "invalid bitboard for white pieces")

  index=0
  board=BoardState()
  parsePieces(index, fenstrings[4], board)
  assertVal(index, 34, "wrong index after parsing")
  assertVal(board.getAllBlackPieces, 985162419568656u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 579842850207563776u64,
            "invalid bitboard for white pieces")

  index=0
  board=BoardState()
  parsePieces(index, random, board)
  assertVal(index, 42, "wrong index after parsing")

  assertVal(board.getAllBlackPieces, 13383261241344u64,
            "invalid bitboard for black pieces")
  assertVal(board.getAllWhitePieces, 2351054927884718080u64,
            "invalid bitboard for white pieces")

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

proc TestAllParsers()=
  startTest("testing parsers")

  doTest("fenstrings"):
    assertVal(fen[0][53], '3', "Wrong value for string")
    assertVal(fen[1][54], '0', "wrong value for string")
    assertVal(fen[3][59], ' ', "wrong value for string")
  doTest testParseInt(fen),            "parseInt"
  doTest testParseHalfMove(fen),       "parseHalfMove"
  doTest testParseMove(fen),           "parseMove"
  doTest testParseSideToMove(fen),     "parseSideToMove"
  doTest testParseEnPassant(fen),      "parseEnPassant"
  doTest testParseCastlingRights(fen), "parseCastlingRights"
  doTest testParsePieces(fen),         "parsePieces"

proc TestFenValidator()=
  startTest("testing fen validation")
  assertVal("rnbqkbnr/pp1ppppp/8/2p5/4P3/8/p/RNBQKBNR w - e4 0 2".fenValid, 
            true, "wrong validation")

proc TestBoards()=
  startTest("testing board state init")
  var
    board: BoardState
  let random = "5N2/5P1B/2pk1P1K/2pr1r2/3p1P2/3p3p/4Q1p1/8 w - - 0 1"

  doTest("init"):
    assertVal(initBoard("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"),
              initBoard(), "boards don't match")
    doAssertRaises(AssertionDefect):
      discard initBoard("3Q4/bpNN4/2R4n/8/3P4/2KNkB2/7q/4r3 - 2 k 111 -1")

  doTest("random fen"):
    board=initBoard(random)
    assertVal(board.getAllBlackPieces, 13383261241344u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 2351054927884718080u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 9042384163700736u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 0u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 36028797018963968u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 2305843009213693952u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 4096u64, "wrong value for white queen")
    assertBitboard(board.white[King], 140737488355328u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 4415369527296u64, "wrong value for black pawn")
    assertBitboard(board.black[Rook], 171798691840u64, "wrong value for black rook")
    assertBitboard(board.black[Bishop], 0u64, "wrong value for black bishop")
    assertBitboard(board.black[Knight], 0u64, "wrong value for black knight")
    assertBitboard(board.black[Queen], 0u64, "wrong value for black queen")
    assertBitboard(board.black[King], 8796093022208u64, "wrong value for black king")

  doTest("fen[0]"):
    board=initBoard(fen[0])
    assertVal(board.getAllBlackPieces, 18446462598732840960u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 65535u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 65280u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen")
    assertBitboard(board.white[King], 16u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 71776119061217280u64, "wrong value for black pawn")
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook")
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop")
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight")
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen")
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king")


  doTest("fen[1]"):
    board=initBoard(fen[1])
    assertVal(board.getAllBlackPieces, 18446462598732840960u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 268496895u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen")
    assertBitboard(board.white[King], 16u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 71776119061217280u64, "wrong value for black pawn")
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook")
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop")
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight")
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen")
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king")


  doTest("fen[2]"):
    board=initBoard(fen[2])
    assertVal(board.getAllBlackPieces, 18445336716005867520u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 268496895u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 66u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen")
    assertBitboard(board.white[King], 16u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 70650236334243840u64, "wrong value for black pawn")
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook")
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop")
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight")
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen")
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king")


  doTest("fen[3]"):
    board=initBoard(fen[3])
    assertVal(board.getAllBlackPieces, 18445336716005867520u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 270593983u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 268496640u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 129u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 36u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 2097154u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 8u64, "wrong value for white queen")
    assertBitboard(board.white[King], 16u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 70650236334243840u64, "wrong value for black pawn")
    assertBitboard(board.black[Rook], 9295429630892703744u64, "wrong value for black rook")
    assertBitboard(board.black[Bishop], 2594073385365405696u64, "wrong value for black bishop")
    assertBitboard(board.black[Knight], 4755801206503243776u64, "wrong value for black knight")
    assertBitboard(board.black[Queen], 576460752303423488u64, "wrong value for black queen")
    assertBitboard(board.black[King], 1152921504606846976u64, "wrong value for black king")


  doTest("fen[4]"):
    board=initBoard(fen[4])
    assertVal(board.getAllBlackPieces, 985162419568656u64,
              "invalid bitboard for black pieces")
    assertVal(board.getAllWhitePieces, 579842850207563776u64,
              "invalid bitboard for white pieces")
    assertBitboard(board.white[Pawn], 134217728u64, "wrong value for white pawn")
    assertBitboard(board.white[Rook], 4398046511104u64, "wrong value for white rook")
    assertBitboard(board.white[Bishop], 2097152u64, "wrong value for white bishop")
    assertBitboard(board.white[Knight], 3377699721052160u64, "wrong value for white knight")
    assertBitboard(board.white[Queen], 576460752303423488u64, "wrong value for white queen")
    assertBitboard(board.white[King], 262144u64, "wrong value for white king")

    assertBitboard(board.black[Pawn], 562949953421312u64, "wrong value for pawn")
    assertBitboard(board.black[Rook], 16u64, "wrong value for rook")
    assertBitboard(board.black[Bishop], 281474976710656u64, "wrong value for bishop")
    assertBitboard(board.black[Knight], 140737488355328u64, "wrong value for knight")
    assertBitboard(board.black[Queen], 32768u64, "wrong value for queen")
    assertBitboard(board.black[King], 1048576u64, "wrong value for king")

#[
#
  ]#

when isMainModule:
  TestAllParsers()
  TestFenValidator()
  TestBoards()
