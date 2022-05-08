import base, ../lookup
import ../bitboard
from variables import kingLookupTest, knightLookup, blackpawnTest, whitepawnTest
import  tables
from bitops import bitor

when isMainModule:
  const
    a = newLookupTable()
    friend = 0u64

  #[
  for each in a.mask_rank:
    echo prettyBitboard(each)
    echo repeat("-",16)
  echo repeat("=",16)
  for each in a.clear_rank:
    echo prettyBitboard(each)
    echo repeat("-",16)

  for each in a.pieces:
    echo prettyBitboard(each)
    echo repeat("-",16)
    ]#
  echo infoMsg("Testing rays")
  #echo a.getNorthRay(H1).prettyBitboard
  #echo a.getSouthRay(A3).prettyBitboard
  #echo a.getWestRay(D5).prettyBitboard
  #echo a.getEastRay(D5).prettyBitboard
  for t in A1..H8:
    echo bitor(a.getWestRay(t), a.getEastRay(t), a.getNorthRay(t), a.getSouthRay(t)).prettyBitboard
    echo "Press Enter to continue checking; Press q to stop"
    let x = stdin.readLine()
    if x=="q": break
  echo passMsg()

  echo infoMsg("Testing king moves")
  assertVal(a.kingMove(A1, friend).prettyBitboard, kingLookupTest[A1], "Wrong move for king at A1")
  assertVal(a.kingMove(B1, friend).prettyBitboard, kingLookupTest[B1], "Wrong move for king at B1")
  assertVal(a.kingMove(C1, friend).prettyBitboard, kingLookupTest[C1], "Wrong move for king at C1")
  assertVal(a.kingMove(D1, friend).prettyBitboard, kingLookupTest[D1], "Wrong move for king at D1")
  assertVal(a.kingMove(E1, friend).prettyBitboard, kingLookupTest[E1], "Wrong move for king at E1")
  assertVal(a.kingMove(F1, friend).prettyBitboard, kingLookupTest[F1], "Wrong move for king at F1")
  assertVal(a.kingMove(G1, friend).prettyBitboard, kingLookupTest[G1], "Wrong move for king at G1")
  assertVal(a.kingMove(H1, friend).prettyBitboard, kingLookupTest[H1], "Wrong move for king at H1")
  assertVal(a.kingMove(H2, friend).prettyBitboard, kingLookupTest[H2], "Wrong move for king at H2")
  assertVal(a.kingMove(H3, friend).prettyBitboard, kingLookupTest[H3], "Wrong move for king at H3")
  assertVal(a.kingMove(H4, friend).prettyBitboard, kingLookupTest[H4], "Wrong move for king at H4")
  assertVal(a.kingMove(H5, friend).prettyBitboard, kingLookupTest[H5], "Wrong move for king at H5")
  assertVal(a.kingMove(H6, friend).prettyBitboard, kingLookupTest[H6], "Wrong move for king at H6")
  assertVal(a.kingMove(H7, friend).prettyBitboard, kingLookupTest[H7], "Wrong move for king at H7")
  assertVal(a.kingMove(H8, friend).prettyBitboard, kingLookupTest[H8], "Wrong move for king at H8")
  assertVal(a.kingMove(G8, friend).prettyBitboard, kingLookupTest[G8], "Wrong move for king at G8")
  assertVal(a.kingMove(F8, friend).prettyBitboard, kingLookupTest[F8], "Wrong move for king at F8")
  assertVal(a.kingMove(E8, friend).prettyBitboard, kingLookupTest[E8], "Wrong move for king at E8")
  assertVal(a.kingMove(D8, friend).prettyBitboard, kingLookupTest[D8], "Wrong move for king at D8")
  assertVal(a.kingMove(C8, friend).prettyBitboard, kingLookupTest[C8], "Wrong move for king at C8")
  assertVal(a.kingMove(B8, friend).prettyBitboard, kingLookupTest[B8], "Wrong move for king at B8")
  assertVal(a.kingMove(A8, friend).prettyBitboard, kingLookupTest[A8], "Wrong move for king at A8")
  assertVal(a.kingMove(A7, friend).prettyBitboard, kingLookupTest[A7], "Wrong move for king at A7")
  assertVal(a.kingMove(A6, friend).prettyBitboard, kingLookupTest[A6], "Wrong move for king at A6")
  assertVal(a.kingMove(A5, friend).prettyBitboard, kingLookupTest[A5], "Wrong move for king at A5")
  assertVal(a.kingMove(A4, friend).prettyBitboard, kingLookupTest[A4], "Wrong move for king at A4")
  assertVal(a.kingMove(A3, friend).prettyBitboard, kingLookupTest[A3], "Wrong move for king at A3")
  assertVal(a.kingMove(A2, friend).prettyBitboard, kingLookupTest[A2], "Wrong move for king at A2")
  assertVal(a.kingMove(D4, friend).prettyBitboard, kingLookupTest[D4], "Wrong move for king at D4")
  echo passMsg()

  echo infoMsg("Testing knight moves")
  assertVal(a.knightMove(D4, friend).prettyBitboard, knightLookup[D4], "Wrong move for knight at D4")
  assertVal(a.knightMove(F6, friend).prettyBitboard, knightLookup[F6], "Wrong move for knight at F6")
  assertVal(a.knightMove(G7, friend).prettyBitboard, knightLookup[G7], "Wrong move for knight at G7")
  assertVal(a.knightMove(H8, friend).prettyBitboard, knightLookup[H8], "Wrong move for knight at H8")
  assertVal(a.knightMove(E8, friend).prettyBitboard, knightLookup[E8], "Wrong move for knight at E8")
  assertVal(a.knightMove(E7, friend).prettyBitboard, knightLookup[E7], "Wrong move for knight at E7")
  assertVal(a.knightMove(B7, friend).prettyBitboard, knightLookup[B7], "Wrong move for knight at E7")
  assertVal(a.knightMove(A8, friend).prettyBitboard, knightLookup[A8], "Wrong move for knight at A8")
  assertVal(a.knightMove(A3, friend).prettyBitboard, knightLookup[A3], "Wrong move for knight at A3")
  assertVal(a.knightMove(A1, friend).prettyBitboard, knightLookup[A1], "Wrong move for knight at A1")
  echo passMsg()

  echo infoMsg("Testing pawn moves")
  assertVal(a.pawnMove(D8, Black, friend, friend).prettyBitboard, blackpawnTest[D8], "Wrong move for black at D8")
  assertVal(a.pawnMove(D8, White, friend, friend).prettyBitboard, whitepawnTest[D8], "Wrong move for white at D8")
  assertVal(a.pawnMove(D2, Black, friend, friend).prettyBitboard, blackpawnTest[D2], "Wrong move for black at D2")
  assertVal(a.pawnMove(D2, White, friend, friend).prettyBitboard, whitepawnTest[D2], "Wrong move for white at D2")
  assertVal(a.pawnMove(D1, Black, friend, friend).prettyBitboard, blackpawnTest[D1], "Wrong move for black at D1")
  assertVal(a.pawnMove(D1, White, friend, friend).prettyBitboard, whitepawnTest[D1], "Wrong move for white at D1")
  assertVal(a.pawnMove(B6, Black, friend, friend).prettyBitboard, blackpawnTest[B6], "Wrong move for black at B6")
  assertVal(a.pawnMove(B6, White, friend, friend).prettyBitboard, whitepawnTest[B6], "Wrong move for white at B6")
  assertVal(a.pawnMove(B7, Black, friend, friend).prettyBitboard, blackpawnTest[B7], "Wrong move for black at B7")
  assertVal(a.pawnMove(B7, White, friend, friend).prettyBitboard, whitepawnTest[B7], "Wrong move for white at B7")
  echo passMsg()

