import strutils
import sequtils, sugar

##
## Definitions for the bitboard
## references:
## [1] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/rep.html
## [2] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/physical.html
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
  Pieces* = enum
    ## Type for all possible pieces on the board
    WhitePawn, WhiteRook, WhiteKnight, WhiteBishop, WhiteQueen, WhiteKing,
    BlackPawn, BlackRook, BlackKnight, BlackBishop, BlackQueen, BlackKing

  ChessBoard* = ref object
    ##
    ## [2] A lightwieght object representing the full state of the chess board
    ## white and black piece bitboards are each grouped arrays indexed by the piece type ( in `Pieces` enum)
    ## functions are provided to get additional states like: white pieces, black pieces and all pieces
    white_pieces: array[WhitePawn..WhiteKing, Bitboard]
    black_pieces: array[BlackPawn..BlackKing, Bitboard]

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
  # default bitboard for white pieces
  white_P = 0b0000000000000000000000000000000000000000000000001111111100000000u64
  white_R = 0b0000000000000000000000000000000000000000000000000000000010000001u64
  white_N = 0b0000000000000000000000000000000000000000000000000000000001000010u64
  white_B = 0b0000000000000000000000000000000000000000000000000000000000100100u64
  white_Q = 0b0000000000000000000000000000000000000000000000000000000000001000u64
  white_K = 0b0000000000000000000000000000000000000000000000000000000000010000u64
  # default bitboard for black pieces
  black_p = 0b0000000011111111000000000000000000000000000000000000000000000000u64
  black_r = 0b1000000100000000000000000000000000000000000000000000000000000000u64
  black_n = 0b0100001000000000000000000000000000000000000000000000000000000000u64
  black_b = 0b0010010000000000000000000000000000000000000000000000000000000000u64
  black_q = 0b0000100000000000000000000000000000000000000000000000000000000000u64
  black_k = 0b0001000000000000000000000000000000000000000000000000000000000000u64


method init*(this: ChessBoard){.base}=
  ## Initializes the board to its proper default values
  # white pieces
  this.white_pieces[WhitePawn]   = white_P
  this.white_pieces[WhiteRook]   = white_R
  this.white_pieces[WhiteBishop] = white_B
  this.white_pieces[WhiteKnight] = white_N
  this.white_pieces[WhiteQueen]  = white_Q
  this.white_pieces[WhiteKing]   = white_k
  # black pieces
  this.black_pieces[BlackPawn]   = black_p
  this.black_pieces[BlackRook]   = black_r
  this.black_pieces[BlackBishop] = black_b
  this.black_pieces[BlackKnight] = black_n
  this.black_pieces[BlackQueen]  = black_q
  this.black_pieces[BlackKing]   = black_k

method getWhitePieceArr*(this: ChessBoard):
  array[WhitePawn..WhiteKing, Bitboard]{.base}=
  ## Returns an array of all white pieces
  return this.white_pieces

method getBlackPieceArr*(this: ChessBoard):
  array[BlackPawn..BlackKing, Bitboard]{.base}=
  ## Returns an array of all black pieces
  return this.black_pieces

method getWhitePieces*(this: ChessBoard): Bitboard{.base}=
  ## Generates a bitboard representing all the white pieces by `or`ing each white piece
  for piece in this.getWhitePieceArr:
    result = result or piece

method getBlackPieces*(this: ChessBoard): Bitboard{.base}=
  ## Generates a bitboard representing all the black pieces by `or`ing each black piece
  for piece in this.getBlackPieceArr:
    result = result or piece

method getAllPieces*(this: ChessBoard): Bitboard{.base}=
  ## Generates a bitboard representing all the pieces on the board by `or`ing all the piece's Bitboards
  return this.getBlackPieces or this.getWhitePieces


func prettyBitboard*(value: Bitboard): string=
  ## Creates a string representation of the way a bitboard number would be represented in the `real` board
  var
    tmp: array[8, array[8, string]]
    i = 0u64
  while i<64:
    tmp[7-(i div 8)][i mod 8] = if ((1u64 shl i) and value)!=0: " 1" else: " 0"
    i.inc
  return tmp.map(each => each.join("")).join("\n")
