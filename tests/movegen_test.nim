include ../movegen
import base
from strformat import fmt
import sequtils, sugar, strutils

let
  lookupT = newLookupTable()
  fen = @[
    "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b kq - 13 20",
    "5N2/5P1B/2pk1P1K/2pr1r2/3p1P2/3p3p/4Q1p1/8 w - - 0 1"
  ]

proc showMoveList(moveL: MoveList): string=
  "@[\n" & join(moveL.map(each => fmt"  {each.prettyMove()}"), "\n") & "\n]"

template assertMove*(value, expected: MoveList, error: string, d: bool) =
  if d: echo infoMsg("\rTesting "&astToStr(value))
  let ans = value
  
  doAssert ans==expected, expectMsg(error, $(ans.showMoveList()),
                                    $(expected.showMoveList()))

proc view(rand: MoveList)=
  for m in rand:
    echo fmt"setMainFields({m.prettyMove()}),"

proc testKnightMoveList(debug: bool)=
  startTest("testing knight movelists generation")
  var boardT: BoardState

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertMove( boardT.generateKnightMoveList(White), @[
        setMainFields((fro: B1, to: A3, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: B1, to: C3, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: G1, to: F3, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: G1, to: H3, captured: NULL_PIECE, moving: WhiteKnight))
      ], "invalid movelist for white knight", debug)
    assertMove( boardT.generateKnightMoveList(Black), @[
        setMainFields((fro: B8, to: A6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: B8, to: C6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: G8, to: F6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: G8, to: H6, captured: NULL_PIECE, moving: BlackKnight)),
      ], "invalid movelist for black knight", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertMove( boardT.generateKnightMoveList(White), @[
        setMainFields((fro: B1, to: A3, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: B1, to: C3, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F3, to: G1, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F3, to: D4, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F3, to: H4, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F3, to: E5, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F3, to: G5, captured: NULL_PIECE, moving: WhiteKnight)),
      ], "invalid movelist for white knight", debug)
    assertMove( boardT.generateKnightMoveList(Black), @[
        setMainFields((fro: B8, to: A6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: B8, to: C6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: G8, to: F6, captured: NULL_PIECE, moving: BlackKnight)),
        setMainFields((fro: G8, to: H6, captured: NULL_PIECE, moving: BlackKnight)),
      ], "invalid movelist for black knight", debug)

  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertMove( boardT.generateKnightMoveList(White), @[
        setMainFields((fro: F8, to: E6, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F8, to: G6, captured: NULL_PIECE, moving: WhiteKnight)),
        setMainFields((fro: F8, to: D7, captured: NULL_PIECE, moving: WhiteKnight)),
      ], "invalid movelist for white knight", debug)
    assertMove( boardT.generateKnightMoveList(Black), @[
      ], "invalid movelist for black knight", debug)

proc testRookMoveList(debug: bool)=
  startTest("testing rook movelists generation")
  var boardT: BoardState

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertMove( boardT.generateRookMoveList(White), @[
      ], "invalid movelist for white rook", debug)
    assertMove( boardT.generateRookMoveList(Black), @[
      ], "invalid movelist for black rook", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertMove( boardT.generateRookMoveList(White), @[
        setMainFields((fro: H1, to: G1, captured: NULL_PIECE, moving: WhiteRook)),
      ], "invalid movelist for white rook", debug)
    assertMove( boardT.generateRookMoveList(Black), @[
      ], "invalid movelist for black rook", debug)

  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertMove( boardT.generateRookMoveList(White), @[
      ], "invalid movelist for white rook", debug)
    assertMove( boardT.generateRookMoveList(Black), @[
        setMainFields((fro: D5, to: E5, captured: NULL_PIECE, moving: BlackRook)),
        setMainFields((fro: F5, to: F4, captured: Pawn, moving: BlackRook)),
        setMainFields((fro: F5, to: E5, captured: NULL_PIECE, moving: BlackRook)),
        setMainFields((fro: F5, to: G5, captured: NULL_PIECE, moving: BlackRook)),
        setMainFields((fro: F5, to: H5, captured: NULL_PIECE, moving: BlackRook)),
        setMainFields((fro: F5, to: F6, captured: Pawn, moving: BlackRook)),
      ], "invalid movelist for black rook", debug)

proc testBishopMoveList(debug: bool)=
  startTest("testing bishop movelists generation")
  var boardT: BoardState

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertMove( boardT.generateBishopMoveList(White), @[
      ], "invalid movelist for white bishop", debug)
    assertMove( boardT.generateBishopMoveList(Black), @[
      ], "invalid movelist for black bishop", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertMove( boardT.generateBishopMoveList(White), @[
        setMainFields((fro: F1, to: E2, captured: NULL_PIECE, moving: WhiteBishop)),
        setMainFields((fro: F1, to: D3, captured: NULL_PIECE, moving: WhiteBishop)),
        setMainFields((fro: F1, to: C4, captured: NULL_PIECE, moving: WhiteBishop)),
        setMainFields((fro: F1, to: B5, captured: NULL_PIECE, moving: WhiteBishop)),
        setMainFields((fro: F1, to: A6, captured: NULL_PIECE, moving: WhiteBishop)),
      ], "invalid movelist for white bishop", debug)
    assertMove( boardT.generateBishopMoveList(Black), @[
      ], "invalid movelist for black bishop", debug)

  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertMove( boardT.generateBishopMoveList(White), @[
        setMainFields((fro: H7, to: F5, captured: Rook, moving: WhiteBishop)),
        setMainFields((fro: H7, to: G6, captured: NULL_PIECE, moving: WhiteBishop)),
        setMainFields((fro: H7, to: G8, captured: NULL_PIECE, moving: WhiteBishop)),
      ], "invalid movelist for white bishop", debug)
    assertMove( boardT.generateBishopMoveList(Black), @[
      ], "invalid movelist for black bishop", debug)

proc testQueenMoveList(debug: bool)=
  startTest("testing queen movelists generation")
  var boardT: BoardState

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertMove( boardT.generateQueenMoveList(White), @[
      ], "invalid movelist for white queen", debug)
    assertMove( boardT.generateQueenMoveList(Black), @[
      ], "invalid movelist for black queen", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertMove( boardT.generateQueenMoveList(White), @[
        setMainFields((fro: D1, to: E2, captured: NULL_PIECE, moving: WhiteQueen)),
      ], "invalid movelist for white queen", debug)
    assertMove( boardT.generateQueenMoveList(Black), @[
        setMainFields((fro: D8, to: A5, captured: NULL_PIECE, moving: BlackQueen)),
        setMainFields((fro: D8, to: B6, captured: NULL_PIECE, moving: BlackQueen)),
        setMainFields((fro: D8, to: C7, captured: NULL_PIECE, moving: BlackQueen)),
      ], "invalid movelist for black queen", debug)

  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertMove( boardT.generateQueenMoveList(White), @[
        setMainFields((fro: E2, to: D1, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E1, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: F1, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: A2, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: B2, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: C2, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: D2, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: F2, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: G2, captured: Pawn, moving: WhiteQueen)),
        setMainFields((fro: E2, to: D3, captured: Pawn, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E3, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: F3, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E4, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: G4, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E5, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: H5, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E6, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E7, captured: NULL_PIECE, moving: WhiteQueen)),
        setMainFields((fro: E2, to: E8, captured: NULL_PIECE, moving: WhiteQueen)),
      ], "invalid movelist for white queen", debug)
    assertMove( boardT.generateQueenMoveList(Black), @[
      ], "invalid movelist for black queen", debug)


proc TestMoveLists(debug: bool)=
  testRookMoveList(debug)
  testKnightMoveList(debug)
  testBishopMoveList(debug)
  testQueenMoveList(debug)

when isMainModule:
  let d = false
  TestMoveLists(d)
