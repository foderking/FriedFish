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


proc TestMoveLists(debug: bool)=
  testKnightMoveList(debug)

when isMainModule:
  let d = false
  TestMoveLists(d)
