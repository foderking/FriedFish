from bitboard import Pieces, PositionsIndex, Bitboard,
     Ranks, Files, prettyBitboard, Family
import bitops, strutils

const
  all_ones* = 0xFFFFFFFFFFFFFFFFu64

type
  LookupTables = object
    initialized: bool
    clear_rank: array[RANK_1..RANK_8, Bitboard] ## Lookup for setting bits at a particular rank to zero
    mask_rank : array[RANK_1..RANK_8, Bitboard] ## Lookup for only selecting bits at a particular rank
    clear_file: array[FILE_1..FILE_8, Bitboard] ## Lookup for setting bits at a particular file to zero
    mask_file : array[FILE_1..FILE_8, Bitboard] ## Lookup for only selecting bits at a particular file
    pieces    : array[A1..H8, Bitboard]

    knight_attacks: array[A1..H8, Bitboard]
    bishop_attacks: array[A1..H8, Bitboard]
    queen_attacks : array[A1..H8, Bitboard]
    king_attacks  : array[A1..H8, Bitboard]
    rook_attacks  : array[A1..H8, Bitboard]
    pawn_attacks  : array[A1..H8, array[Family,Bitboard]]

proc calcKingMoves(this: LookupTables, square: PositionsIndex): Bitboard=
  let
    pos = this.pieces[square]
    left   = bitand(pos, this.clear_file[FILE_1]) shr 1
    right  = bitand(pos, this.clear_file[FILE_8]) shl 1
    middle = bitor(left, right, pos)
    up     = bitand(middle, this.clear_rank[RANK_8]) shl 8
    down   = bitand(middle, this.clear_rank[RANK_1]) shr 8
  return bitor(up, down, middle).clearMasked(pos)

proc calcKnightMoves(this: LookupTables, square: PositionsIndex): Bitboard=
  let
    pos = this.pieces[square]
    left_one  = bitand(pos, this.clear_file[FILE_1]) shr 1
    left_two  = bitand(pos, this.clear_file[FILE_1], this.clear_file[FILE_2]) shr 2
    right_one = bitand(pos, this.clear_file[FILE_8]) shl 1
    right_two = bitand(pos, this.clear_file[FILE_8], this.clear_file[FILE_7]) shl 2
    one = bitor(left_one, right_one)
    two = bitor(left_two, right_two)
    north_one = bitand(one, this.clear_rank[RANK_8], this.clear_rank[RANK_7]) shl 16
    north_two = bitand(two, this.clear_rank[RANK_8]) shl 8
    south_one = bitand(one, this.clear_rank[RANK_1], this.clear_rank[RANK_2]) shr 16
    south_two = bitand(two, this.clear_rank[RANK_1]) shr 8
  return bitor(north_one, north_two, south_one, south_two)

proc calcPawnAttack(this: LookupTables, square: PositionsIndex, fam: Family): Bitboard=
  case fam
  of White:
    let
      pos = this.pieces[square]
    return bitor(bitand(pos, this.clear_file[FILE_1]) shl 7, bitand(pos, this.clear_file[FILE_8]) shl 9)
  of Black:
    let
      pos = this.pieces[square]
    return bitor(bitand(pos, this.clear_file[FILE_8]) shr 7, bitand(pos, this.clear_file[FILE_1]) shr 9)
  else:
    raiseAssert "Error calculating pawn moves"

proc kingMove*(this: LookupTables, square: PositionsIndex, friendly_pieces: Bitboard): Bitboard{.inline}=
  assert this.initialized # make sure tables have been initialized
  return bitand(this.king_attacks[square], bitnot(friendly_pieces))

proc knightMove*(this: LookupTables, square: PositionsIndex, friendly_pieces: Bitboard): Bitboard{.inline}=
  assert this.initialized # make sure tables have been initialized
  return bitand(this.knight_attacks[square], bitnot(friendly_pieces))

proc pawnMove*(this: LookupTables, square: PositionsIndex,
               fam : Family, friendly_pieces, all_pieces: Bitboard): Bitboard{.inline}=
  ## Implementation based on
  ## https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/nonsliding.html
  assert this.initialized # make sure tables have been initialized
  case fam
  of White:
    let
      pos = this.pieces[square]
      # the bitnot(all_pieces) prevents the pawn from moving into occupied squares
      # check the single space infront of the white pawn
      one_step = bitand(pos shl 8, bitnot(all_pieces))
      # Only pawns at rank 2 would be allowed to move two steps
      two_step = bitand(bitand(one_step, this.mask_rank[RANK_3]) shl 8, bitnot(all_pieces))
      attack   = bitand(this.pawn_attacks[square][White], bitnot(friendly_pieces))
    return bitor(attack, one_step, two_step)
  of Black:
    let
      pos = this.pieces[square]
      one_step = bitand(pos shr 8, bitnot(all_pieces))
      two_step = bitand(bitand(one_step, this.mask_rank[RANK_6]) shr 8, bitnot(all_pieces))
      attack   = bitand(this.pawn_attacks[square][Black], bitnot(friendly_pieces))
    return bitor(attack, one_step, two_step)
  else:
    raiseAssert "Error getting pawns move"

func newLookupTable*(): LookupTables=
  var table = LookupTables()
  # file lookups
  table.mask_file[FILE_1] = 0x0101010101010101u64
  table.mask_file[FILE_2] = 0x0202020202020202u64
  table.mask_file[FILE_3] = 0x0404040404040404u64
  table.mask_file[FILE_4] = 0x0808080808080808u64
  table.mask_file[FILE_5] = 0x1010101010101010u64
  table.mask_file[FILE_6] = 0x2020202020202020u64
  table.mask_file[FILE_7] = 0x4040404040404040u64
  table.mask_file[FILE_8] = 0x8080808080808080u64
  table.clear_file[FILE_1] = bitnot(table.mask_file[FILE_1])
  table.clear_file[FILE_2] = bitnot(table.mask_file[FILE_2])
  table.clear_file[FILE_3] = bitnot(table.mask_file[FILE_3])
  table.clear_file[FILE_4] = bitnot(table.mask_file[FILE_4])
  table.clear_file[FILE_5] = bitnot(table.mask_file[FILE_5])
  table.clear_file[FILE_6] = bitnot(table.mask_file[FILE_6])
  table.clear_file[FILE_7] = bitnot(table.mask_file[FILE_7])
  table.clear_file[FILE_8] = bitnot(table.mask_file[FILE_8])
  # rank lookups
  table.mask_rank[RANK_1] = 0x00000000000000FFu64
  table.mask_rank[RANK_2] = 0x000000000000FF00u64
  table.mask_rank[RANK_3] = 0x0000000000FF0000u64
  table.mask_rank[RANK_4] = 0x00000000FF000000u64
  table.mask_rank[RANK_5] = 0x000000FF00000000u64
  table.mask_rank[RANK_6] = 0x0000FF0000000000u64
  table.mask_rank[RANK_7] = 0x00FF000000000000u64
  table.mask_rank[RANK_8] = 0xFF00000000000000u64
  table.clear_rank[RANK_1] = bitnot(table.mask_rank[RANK_1])
  table.clear_rank[RANK_2] = bitnot(table.mask_rank[RANK_2])
  table.clear_rank[RANK_3] = bitnot(table.mask_rank[RANK_3])
  table.clear_rank[RANK_4] = bitnot(table.mask_rank[RANK_4])
  table.clear_rank[RANK_5] = bitnot(table.mask_rank[RANK_5])
  table.clear_rank[RANK_6] = bitnot(table.mask_rank[RANK_6])
  table.clear_rank[RANK_7] = bitnot(table.mask_rank[RANK_7])
  table.clear_rank[RANK_8] = bitnot(table.mask_rank[RANK_8])
  # piece lookups
  for location in A1..H8:
    table.pieces[location] = 1u64 shl location.ord

    table.king_attacks[location]        = table.calcKingMoves(location)
    table.knight_attacks[location]      = table.calcKnightMoves(location)
    table.pawn_attacks[location][White] = table.calcPawnAttack(location, White)
    table.pawn_attacks[location][Black] = table.calcPawnAttack(location, Black)
  table.initialized = true # indicate that table has been initialized
  return table

