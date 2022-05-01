import strutils
import sequtils, sugar

type
  Bitboard = distinct uint64

func pretty(value: uint64): string=
  var
    tmp: array[8, array[8, string]]
    val = value
    i = 0

  while val!=0:
    tmp[7-(i div 8)][i mod 8] = ($(val mod 2)).align(2)
    val = val shr 1
    i.inc
  while i<64:
    tmp[7-(i div 8)][i mod 8] = "0".align(2)
    i.inc
  return tmp.map(each => each.join("")).join("\n")


when isMainModule:
  var
    pawn: uint64
  pawn = 0xAE9D6D57565AB63Bu64
  echo pawn
  echo pretty(pawn)
