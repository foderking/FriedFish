##
## Definitions for the bitboard
## references:
## [1] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/rep.html
## [2] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/physical.html
##
import sequtils, sugar, bitops, strutils
import util

type
  ChessBoard* = ref object
    ## [2] A lightwieght object representing the full state of the chess board
    ## white and black piece bitboards are each grouped arrays indexed by the type of each piece
    ##
    white_pieces: array[ValidPiece, Bitboard]
    black_pieces: array[ValidPiece, Bitboard]

const
  DiagonalIndex* = [
    # Mapping from board location to diagonal location
    0,15,14,13,12,11,10, 9,
    1, 0,15,14,13,12,11,10,
    2, 1, 0,15,14,13,12,11,
    3, 2, 1, 0,15,14,13,12,
    4, 3, 2, 1, 0,15,14,13,
    5, 4, 3, 2, 1, 0,15,14,
    6, 5, 4, 3, 2, 1, 0,15,
    7, 6, 5, 4, 3, 2, 1, 0,
  ]
  main_diag* = 0x8040201008040201u64 ## Diagonal going for A1 to H8


## TODO
##
proc getWhitePieceArr*(this: ChessBoard): array[ValidPiece, Bitboard]{.inline}=
  ## Returns an array of all white pieces
  return this.white_pieces

proc getBlackPieceArr*(this: ChessBoard): array[ValidPiece, Bitboard]{.inline}=
  ## Returns an array of all black pieces
  return this.black_pieces

proc getDiagonal*(square: BoardPosition): Bitboard{.inline}=
  echo DiagonalIndex[square.ord]
  return (1u64 shl DiagonalIndex[square.ord]) * main_diag
