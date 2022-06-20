##
## Utility types and functions for the chess engine
##
## references
##  [1] https://www.chessprogramming.org/Square_Mapping_Considerations
import bitops, sequtils, sugar, strutils

type
  Bitboard* = uint64 ## A unsigned 64 bit integer completely represents squares in a board

  BoardPosition* = enum
    ## Type for all board positions arranged in "LERF"[1]
    A1, B1, C1, D1, E1, F1, G1, H1,
    A2, B2, C2, D2, E2, F2, G2, H2,
    A3, B3, C3, D3, E3, F3, G3, H3,
    A4, B4, C4, D4, E4, F4, G4, H4,
    A5, B5, C5, D5, E5, F5, G5, H5,
    A6, B6, C6, D6, E6, F6, G6, H6,
    A7, B7, C7, D7, E7, F7, G7, H7,
    A8, B8, C8, D8, E8, F8, G8, H8, NULL_POS
  Pieces* = enum
    ## All the board pieces, null included
    Pawn, Rook, Bishop, Knight, Queen, King, NULL
  Ranks* = enum
    ## Type for all possible ranks on the board
    RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8
  Files* = enum
    ## Type for all possible files on the board
    FILE_A, FILE_B, FILE_C, FILE_D, FILE_E, FILE_F, FILE_G, FILE_H
  Family* = enum
    ## Type for the two possible families: white or black
    White, Black
  #[
  PieceType = enum
    ## Type for all unique pieces on the board (TODO: remove this ?)
    WhitePawn, WhiteRook, WhiteKnight, WhiteBishop, WhiteQueen, WhiteKing,
    BlackPawn, BlackRook, BlackKnight, BlackBishop, BlackQueen, BlackKing
  ]#
  ValidPiece* = Pawn..King ## All the **valid** possible board pieces (different from `Pieces`)
  # All possible board positions as indices in "Little-Endian Rank-File Mapping"[1]
  BoardIndex* = 0..63 
  ValidBoardPosition* = A1..H8
  # All indices for files
  FileIndex*  = 0..7
  ValidFile*  = FILE_A..FILE_H
  # All indices for files
  RankIndex*  = 0..7
  ValidRank*  = RANK_1..RANK_8


const 
  BoardPositionLookup* = [
    ## Mapping from `BoardIndex` -> `BoardPosition`
    A1, B1, C1, D1, E1, F1, G1, H1,
    A2, B2, C2, D2, E2, F2, G2, H2,
    A3, B3, C3, D3, E3, F3, G3, H3,
    A4, B4, C4, D4, E4, F4, G4, H4,
    A5, B5, C5, D5, E5, F5, G5, H5,
    A6, B6, C6, D6, E6, F6, G6, H6,
    A7, B7, C7, D7, E7, F7, G7, H7,
    A8, B8, C8, D8, E8, F8, G8, H8,
  ]
  FilesLookup* = [
    ## Mapping from `FileIndex` -> `Files`
    FILE_A, FILE_B, FILE_C, FILE_D,
    FILE_E, FILE_F, FILE_G, FILE_H
  ]
  RanksLookup* = [
    ## Mapping from `RankIndex` -> `Ranks`
    RANK_1, RANK_2, RANK_3, RANK_4,
    RANK_5, RANK_6, RANK_7, RANK_8
  ]

  empty_bitboard* = 0u64  # Bitboard representing an empty board
  full_bitboard*  = 0xFFFFFFFFFFFFFFFFu64 ## Bitboard representing a full board
  # default bitboard for white pieces
  white_p* = 0b0000000000000000000000000000000000000000000000001111111100000000u64
  white_r* = 0b0000000000000000000000000000000000000000000000000000000010000001u64
  white_n* = 0b0000000000000000000000000000000000000000000000000000000001000010u64
  white_b* = 0b0000000000000000000000000000000000000000000000000000000000100100u64
  white_q* = 0b0000000000000000000000000000000000000000000000000000000000001000u64
  white_k* = 0b0000000000000000000000000000000000000000000000000000000000010000u64
  # default bitboard for black pieces
  black_p* = 0b0000000011111111000000000000000000000000000000000000000000000000u64
  black_r* = 0b1000000100000000000000000000000000000000000000000000000000000000u64
  black_n* = 0b0100001000000000000000000000000000000000000000000000000000000000u64
  black_b* = 0b0010010000000000000000000000000000000000000000000000000000000000u64
  black_q* = 0b0000100000000000000000000000000000000000000000000000000000000000u64
  black_k* = 0b0001000000000000000000000000000000000000000000000000000000000000u64


func getInt*(s: '0'..'9') : 0..9{.inline}=
  ## Converts a numeric character to its integer representation
  ## parseInt('4') -> 4
  return s.int - 48

func getRank*(row: '1'..'8'): RankIndex{.inline}=
  ## Returns index of rank
  ## e.g 1 -> 0
  ##     8 -> 7
  return row.int - 49

func getFile*(col: 'a'..'h'): FileIndex{.inline}=
  ## Returns index of a file
  ## e.g a -> 0
  ##     h -> 7
  return col.int - 97

func getBoardIndex*(col: 'a'..'h', row: '1'..'8'): BoardIndex{.inline}=
  ## Returns the index of a board position rep by two chars
  ## eg (`e`,`3`) -> 20
  return (getRank(row) shl 3) + getFile(col)

func `|=`*(one: var Bitboard, two: Bitboard){.inline}=
  ## Template for in-place `or`ing
  one = bitor(one, two)

func `&=`*(one: var Bitboard, two: Bitboard){.inline}=
  ## Template for in-place `and`ing
  one = bitand(one, two)

func calcFile*(square: BoardPosition): Files{.inline}=
  ## Get the file of a board position
  return FilesLookup[bitand(square.ord, 7)]

func calcRank*(square: BoardPosition): Ranks{.inline}=
  ## Get the rank of a board position
  return RanksLookup[square.ord shr 3]


func prettyBitboard*(value: Bitboard): string=
  ## Creates a string representation of the way a bitboard number would be represented in the `real` board
  var
    tmp: array[8, array[8, string]]
    i = 0u64
  while i<64:
    tmp[7-(i div 8)][i mod 8] = if ((1u64 shl i) and value)!=0: " 1" else: " 0"
    i.inc
  return tmp.map(each => each.join("")).join("\n")

#[
proc parallelPrint(one: string, two: string)=
  ## TODO
  let
    first = one.splitLines
    second = two.splitLines
  for each in zip(first, second):
    echo each[0], repeat(" ", 5), each[1]
]#