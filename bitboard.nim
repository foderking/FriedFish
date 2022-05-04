import strutils
import sequtils, sugar

##
## Definitions for the bitboard
## references:
## [1] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/rep.html
##

type
  Bitboard* = uint64 ## A unisigned 64 bit integer completely represents a board
  PositionsIndex* = enum
    ## This enum allows you to get the index in bitboard if you know the location on the real board [1].
    A1, B1, C1, D1, E1, F1, G1, H1,
    A2, B2, C2, D2, E2, F2, G2, H2,
    A3, B3, C3, D3, E3, F3, G3, H3,
    A4, B4, C4, D4, E4, F4, G4, H4,
    A5, B5, C5, D5, E5, F5, G5, H5,
    A6, B6, C6, D6, E6, F6, G6, H6,
    A7, B7, C7, D7, E7, F7, G7, H7,
    A8, B8, C8, D8, E8, F8, G8, H8,

const
  IndexPositions* = [
    ## This arrray allows you to get the location on the real board if you know the index in bitboard [1].
    A1, B1, C1, D1, E1, F1, G1, H1,
    A2, B2, C2, D2, E2, F2, G2, H2,
    A3, B3, C3, D3, E3, F3, G3, H3,
    A4, B4, C4, D4, E4, F4, G4, H4,
    A5, B5, C5, D5, E5, F5, G5, H5,
    A6, B6, C6, D6, E6, F6, G6, H6,
    A7, B7, C7, D7, E7, F7, G7, H7,
    A8, B8, C8, D8, E8, F8, G8, H8,
  ]


func pretty*(value: Bitboard): string=
  ## Creates a string representation of the way a bitboard number would be represented in the `real` board
  var
    tmp: array[8, array[8, string]]
    i = 0u64
  while i<64:
    tmp[7-(i div 8)][i mod 8] = if ((1u64 shl i) and value)!=0: " 1" else: " 0"
    i.inc
  return tmp.map(each => each.join("")).join("\n")
