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
  wqc = Move(644)
  wkc = Move(648)
  bqc = Move(1412)
  bkc = Move(1416)

proc showMoveList(moveL: MoveList): string=
  "@[\n" & join(moveL.map(each => fmt"  {each.prettyMove()}"), "\n") & "\n]"

proc showFullMoveList(moveL: MoveList): string=
  "@[\n" & join(moveL.map(each => fmt"  {each.prettyMoveFull()}"), "\n") & "\n]"

template assertMove*(value, expected: MoveList, error: string, d: bool) =
  if d: echo infoMsg("\rTesting "&astToStr(value))
  let ans = value
  doAssert ans==expected, expectMsg(error, $(ans.showMoveList()),
                                    $(expected.showMoveList()))

template assertKing*(value, expected: MoveList, error: string, d: bool) =
  if d: echo infoMsg("\rTesting "&astToStr(value))
  let ans = value
  doAssert ans==expected, expectMsg(error, $(ans.showFullMoveList()),
                                    $(expected.showFullMoveList()))


#[
proc view(rand: MoveList)=
  for m in rand:
    echo fmt"setMainFields({m.prettyMove()}),"
]#

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

proc testPawnMoveList(debug: bool)=
  startTest("testing pawn movelists generation")
  var
    boardT: BoardState
    #castleT: MoveList

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertKing( boardT.generatePawnMoveList(White), @[
        setMainFields((fro: A2, to: A3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: A2, to: A4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: B2, to: B3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: B2, to: B4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: C2, to: C3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: C2, to: C4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: D2, to: D3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: D2, to: D4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: E2, to: E3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: E2, to: E4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: F2, to: F3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: F2, to: F4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: G2, to: G3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: G2, to: G4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: H2, to: H3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: H2, to: H4, captured: NULL_PIECE, moving: WhitePawn))
      ], "invalid movelist for white pawn", debug)
    assertKing( boardT.generatePawnMoveList(Black), @[
        setMainFields((fro: A7, to: A5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: A7, to: A6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: B7, to: B5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: B7, to: B6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: C7, to: C5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: C7, to: C6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: D7, to: D5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: D7, to: D6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: E7, to: E5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: E7, to: E6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: F7, to: F5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: F7, to: F6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: G7, to: G5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: G7, to: G6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: H7, to: H5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: H7, to: H6, captured: NULL_PIECE, moving: BlackPawn))
      ], "invalid movelist for black pawn", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertKing( boardT.generatePawnMoveList(White), @[
        setMainFields((fro: A2, to: A3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: A2, to: A4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: B2, to: B3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: B2, to: B4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: C2, to: C3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: C2, to: C4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: D2, to: D3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: D2, to: D4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: G2, to: G3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: G2, to: G4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: H2, to: H3, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: H2, to: H4, captured: NULL_PIECE, moving: WhitePawn)),
        setMainFields((fro: E4, to: E5, captured: NULL_PIECE, moving: WhitePawn))
      ], "invalid movelist for white pawn", debug)
    assertKing( boardT.generatePawnMoveList(Black), @[
        setMainFields((fro: C5, to: C4, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: A7, to: A5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: A7, to: A6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: B7, to: B5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: B7, to: B6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: D7, to: D5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: D7, to: D6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: E7, to: E5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: E7, to: E6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: F7, to: F5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: F7, to: F6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: G7, to: G5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: G7, to: G6, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: H7, to: H5, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: H7, to: H6, captured: NULL_PIECE, moving: BlackPawn))
      ], "invalid movelist for black pawn", debug)

  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertKing( boardT.generatePawnMoveList(Black), @[
        setMainFields((fro: G2, to: G1, captured: NULL_PIECE, moving: BlackPawn))
          .setPromotionField(Rook_Promotion),
        setMainFields((fro: G2, to: G1, captured: NULL_PIECE, moving: BlackPawn))
          .setPromotionField(Bishop_Promotion),
        setMainFields((fro: G2, to: G1, captured: NULL_PIECE, moving: BlackPawn))
          .setPromotionField(Knight_Promotion),
        setMainFields((fro: G2, to: G1, captured: NULL_PIECE, moving: BlackPawn))
          .setPromotionField(Queen_Promotion),
        setMainFields((fro: D3, to: D2, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: D3, to: E2, captured: Queen, moving: BlackPawn)),
        setMainFields((fro: H3, to: H2, captured: NULL_PIECE, moving: BlackPawn)),
        setMainFields((fro: C5, to: C4, captured: NULL_PIECE, moving: BlackPawn)),
      ], "invalid movelist for black pawn", debug)
    assertKing( boardT.generatePawnMoveList(White), @[
      ], "invalid movelist for white pawn", debug)

proc testKingMoveList(debug: bool)=
  startTest("testing king movelists generation")
  var
    boardT: BoardState
    #castleT: MoveList

  doTest("default board"):
    boardT = initBoard(lookupT)
    assertMove( boardT.generateKingMoveList(White), @[
      ], "invalid movelist for white king", debug)
    assertMove( boardT.generateKingMoveList(Black), @[
      ], "invalid movelist for black king", debug)

    assertKing(boardT.generateCastlingMoveList(White), @[
      ], "invalid castling rights for white king", debug)
    assertKing(boardT.generateCastlingMoveList(Black), @[
      ], "invalid castling rights for black king", debug)

  doTest("fen 1"):
    boardT = initBoard(fen[0], lookupT)
    assertMove( boardT.generateKingMoveList(White), @[
        setMainFields((fro: E1, to: E2, captured: NULL_PIECE, moving: WhiteKing)),
      ], "invalid movelist for white king", debug)
    assertMove( boardT.generateKingMoveList(Black), @[
      ], "invalid movelist for black king", debug)

    assertKing(boardT.generateCastlingMoveList(White), @[],
           "invalid castling rights for white king", debug)
    assertKing(boardT.generateCastlingMoveList(Black), @[],
           "invalid castling rights for black king", debug)


  doTest("fen 2"):
    boardT = initBoard(fen[1], lookupT)
    assertMove( boardT.generateKingMoveList(White), @[
        setMainFields((fro: H6, to: G5, captured: NULL_PIECE, moving: WhiteKing)),
        setMainFields((fro: H6, to: H5, captured: NULL_PIECE, moving: WhiteKing)),
        setMainFields((fro: H6, to: G6, captured: NULL_PIECE, moving: WhiteKing)),
        setMainFields((fro: H6, to: G7, captured: NULL_PIECE, moving: WhiteKing)),
      ], "invalid movelist for white king", debug)
    assertMove( boardT.generateKingMoveList(Black), @[
        setMainFields((fro: D6, to: E5, captured: NULL_PIECE, moving: BlackKing)),
        setMainFields((fro: D6, to: E6, captured: NULL_PIECE, moving: BlackKing)),
        setMainFields((fro: D6, to: C7, captured: NULL_PIECE, moving: BlackKing)),
        setMainFields((fro: D6, to: D7, captured: NULL_PIECE, moving: BlackKing)),
        setMainFields((fro: D6, to: E7, captured: NULL_PIECE, moving: BlackKing)),
      ], "invalid movelist for black king", debug)

    assertKing(boardT.generateCastlingMoveList(White), @[],
           "invalid castling rights for white king", debug)
    assertKing(boardT.generateCastlingMoveList(Black), @[],
           "invalid castling rights for black king", debug)
  doTest("more than one king"):
    boardT = initBoard("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBKKB1R b kq - 13 20", lookupT)
    doAssertRaises(AssertionDefect):
      discard boardT.generateKingMoveList(White)

    boardT = initBoard("rnbkkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b kq - 13 20", lookupT)
    doAssertRaises(AssertionDefect):
      discard boardT.generateKingMoveList(Black)

proc testPsuedoLegal(debug: bool)=
  startTest("testing psuedo legal movelists generation")
  var
    boardT: BoardState
  doTest("default board"):
    boardT = initBoard(lookupT)
    assertVal( boardT.genPsuedoLegalMoveList().len, 0, "invalid psuedolegal movelist", debug)

    assertMove( boardT.genPsuedoLegalMoveList(), @[
      ], "invalid psuedolegal movelist", debug)

proc TestMoveLists(debug: bool)=
  testRookMoveList(debug)
  testKnightMoveList(debug)
  testBishopMoveList(debug)
  testQueenMoveList(debug)
  testKingMoveList(debug)
  testPawnMoveList(debug)
  #testPsuedoLegal(debug)

when isMainModule:
  let d = false
  TestMoveLists(d)
