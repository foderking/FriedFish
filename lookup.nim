from bitboard import Pieces, PositionsIndex, Bitboard,
     Ranks, Files, prettyBitboard, Family, IndexPositions,
     calcFile, calcRank 
import bitops, strutils

type
  RAYS = enum
    ## This represent any possible ray from a sliding piece (rook, bishop, queen)
    NORTH,SOUTH,EAST,WEST,
    NORTH_WEST ,NORTH_EAST,
    SOUTH_WEST ,SOUTH_EAST

type
  LookupTables* = object
    initialized: bool
    clear_rank: array[RANK_1..RANK_8, Bitboard] ## Lookup for setting bits at a particular rank to zero
    mask_rank : array[RANK_1..RANK_8, Bitboard] ## Lookup for only selecting bits at a particular rank
    clear_file: array[FILE_1..FILE_8, Bitboard] ## Lookup for setting bits at a particular file to zero
    mask_file : array[FILE_1..FILE_8, Bitboard] ## Lookup for only selecting bits at a particular file
    pieces*    : array[A1..H8, Bitboard] ## Cheap lookup for generating a single position bitboard

    knight_attacks: array[A1..H8, Bitboard] ## Lookup to knight attacks
    bishop_attacks: array[A1..H8, Bitboard] ## Lookup for bishop attacks
    queen_attacks : array[A1..H8, Bitboard] ## Lookup for queen attacks
    king_attacks  : array[A1..H8, Bitboard] ## Lookup for king attacks
    rook_attacks  : array[A1..H8, Bitboard] ## Lookup for rook attacks
    pawn_attacks  : array[A1..H8, array[Family,Bitboard]] ## Lookup for both black and white pawn attacks.

    attack_rays: array[A1..H8, array[RAYS.low..RAYS.high, Bitboard]] ## Lookup for sliding pieces rays (rook, bishop)

proc `|=`*(one: var Bitboard, two: Bitboard){.inline}=
  one = bitor(one, two)

proc `&=`*(one: var Bitboard, two: Bitboard){.inline}=
  one = bitand(one, two)

proc bitScanForward*(x: Bitboard): PositionsIndex{.inline}=
  ## Gets position of the least significant bit in bitboard
  return IndexPositions[firstSetBit(x)-1]

proc bitScanReverse*(x: Bitboard): PositionsIndex{.inline}=
  return IndexPositions[fastLog2(x)]

proc getNorthRay*(this: LookupTables, square: PositionsIndex): Bitboard{.inline}=
  ## generates bitoard for north ray from rook at `square`
  return bitand(this.mask_file[calcFile(square)], not bitor(this.pieces[square], this.pieces[square]-1))

proc getSouthRay*(this: LookupTables, square: PositionsIndex): Bitboard{.inline}=
  ## generates bitoard for south ray from rook at `square`
  return bitand(this.mask_file[calcFile(square)], not this.pieces[square], this.pieces[square]-1)

proc getEastRay*(this: LookupTables, square: PositionsIndex): Bitboard{.inline}=
  ## generates bitoard for east ray from rook at `square`
  return bitand(this.mask_rank[calcRank(square)], not bitor(this.pieces[square], this.pieces[square]-1))

proc getWestRay*(this: LookupTables, square: PositionsIndex): Bitboard{.inline}=
  ## generates bitoard for west ray from rook at `square`
  return bitand(this.mask_rank[calcRank(square)], not this.pieces[square], this.pieces[square]-1)


## The following implementations gotten from
## https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
##

proc getNorthEastRay*(this: LookupTables, square: PositionsIndex): Bitboard=
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_1]
    pr1 = bitand(pr0, (pr0 shl  9))
    pr2 = bitand(pr1, (pr1 shl 18))
  gen |= bitand(pr0, (gen shl  9))
  gen |= bitand(pr1, (gen shl 18))
  gen |= bitand(pr2, (gen shl 36))
  return bitand(gen, not this.pieces[square]);

proc getSouthEastRay*(this: LookupTables, square: PositionsIndex): Bitboard=
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_1]
    pr1 = bitand(pr0 , (pr0 shr  7))
    pr2 = bitand(pr1 , (pr1 shr 14))
  gen |= bitand(pr0 , (gen shr  7))
  gen |= bitand(pr1 , (gen shr 14))
  gen |= bitand(pr2 , (gen shr 28))
  return bitand(gen, not this.pieces[square]);

proc getSouthWestRay*(this: LookupTables, square: PositionsIndex): Bitboard=
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_8]
    pr1 = bitand(pr0, (pr0 shr  9))
    pr2 = bitand(pr1, (pr1 shr 18))
  gen |= bitand(pr0, (gen shr  9))
  gen |= bitand(pr1, (gen shr 18))
  gen |= bitand(pr2, (gen shr 36))
  return bitand(gen, not this.pieces[square]);

proc getNorthWestRay*(this: LookupTables, square: PositionsIndex): Bitboard=
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_8]
    pr1 = bitand(pr0, (pr0 shl  7))
    pr2 = bitand(pr1, (pr1 shl 14))
  gen |= bitand(pr0, (gen shl  7))
  gen |= bitand(pr1, (gen shl 14))
  gen |= bitand(pr2, (gen shl 28))
  return bitand(gen, not this.pieces[square]);

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

proc kingMove*(this: LookupTables, square: PositionsIndex, friendly_pieces: Bitboard): Bitboard{.inline}=
  assert this.initialized # make sure tables have been initialized
  return bitand(this.king_attacks[square], bitnot(friendly_pieces))

proc knightMove*(this: LookupTables, square: PositionsIndex, friendly_pieces: Bitboard): Bitboard{.inline}=
  assert this.initialized # make sure tables have been initialized
  return bitand(this.knight_attacks[square], bitnot(friendly_pieces))

proc pawnMove*(this: LookupTables, square: PositionsIndex,
               fam : Family, friendly_pieces, enemy_pieces, all_pieces: Bitboard): Bitboard{.inline}=
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
      attack   = bitand(this.pawn_attacks[square][White], enemy_pieces)
    return bitor(attack, one_step, two_step)
  of Black:
    let
      pos = this.pieces[square]
      one_step = bitand(pos shr 8, bitnot(all_pieces))
      two_step = bitand(bitand(one_step, this.mask_rank[RANK_6]) shr 8, bitnot(all_pieces))
      attack   = bitand(this.pawn_attacks[square][Black], enemy_pieces)
    return bitor(attack, one_step, two_step)
 
##
## The following functions implement move generation for sliding pieces using..
## the classical approach. https://www.chessprogramming.org/Classical_Approach
## Based on: https://rhysre.net/fast-chess-move-generation-with-magic-bitboards.html
##
proc bishopMove*(this: LookupTables,  square: PositionsIndex,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  let
    nw_ray = this.attack_rays[square][NORTH_WEST]
    ne_ray = this.attack_rays[square][NORTH_EAST]
    sw_ray = this.attack_rays[square][SOUTH_WEST]
    se_ray = this.attack_rays[square][SOUTH_EAST]
  var
    attacks = this.attack_rays[square][NORTH_WEST]
    index: PositionsIndex ## location of first blocked piece

  # north west ray
  if bitand(all_pieces, nw_ray)!=0:
    # the first blocked piece is gotten from the location of the **least** significant byte
    # of the bitboard for all relevant blocked pieces
    index = bitscanForward(bitand(nw_ray, all_pieces))
    attacks &=  not this.attack_rays[index][NORTH_WEST]
  # north east ray
  attacks |= ne_ray
  if bitand(ne_ray, all_pieces)!=0:
    index = bitscanForward(bitand(ne_ray, all_pieces))
    attacks &= not this.attack_rays[index][NORTH_EAST]
  # south east ray
  attacks |= se_ray
  if bitand(se_ray, all_pieces)!=0:
    # the first blocked piece is gotten from the location of the **most** significant byte
    # of the bitboard for all relevant blocked pieces
    index = bitscanReverse(bitand(se_ray, all_pieces))
    attacks &= not this.attack_rays[index][SOUTH_EAST]
  # south west ray
  attacks |= sw_ray
  if bitand(sw_ray, all_pieces)!=0:
    index = bitscanReverse(bitand(sw_ray, all_pieces))
    attacks &= not this.attack_rays[index][SOUTH_WEST]

  return bitand(attacks, bitnot(friendly_pieces))

proc rookMove*(this: LookupTables,  square: PositionsIndex,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  let
    n_ray = this.attack_rays[square][NORTH]
    s_ray = this.attack_rays[square][SOUTH]
    e_ray = this.attack_rays[square][EAST]
    w_ray = this.attack_rays[square][WEST]

  var
    attacks = this.attack_rays[square][NORTH]
    index: PositionsIndex ## location of first blocked piece

  # north ray
  if bitand(n_ray, all_pieces)!=0:
    index = bitScanForward(bitand(n_ray, all_pieces))
    attacks &= not this.attack_rays[index][NORTH]
  # east ray
  attacks |= e_ray
  if bitand(e_ray, all_pieces)!=0:
    index = bitScanForward(bitand(e_ray, all_pieces))
    attacks &= not this.attack_rays[index][EAST]
  # west ray 
  attacks |= w_ray
  if bitand(w_ray, all_pieces)!=0:
    index = bitScanReverse(bitand(w_ray, all_pieces))
    attacks &= not this.attack_rays[index][WEST]
  # south ray
  attacks |= s_ray
  if bitand(s_ray, all_pieces)!=0:
    index = bitScanReverse(bitand(s_ray, all_pieces))
    attacks &= not this.attack_rays[index][SOUTH]

  return bitand(attacks, bitnot(friendly_pieces))

proc queenMove*(this: LookupTables,  square: PositionsIndex,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  return bitor(
          this.bishopMove(square, all_pieces, friendly_pieces),
          this.rookMove(square, all_pieces, friendly_pieces),
         )

func newLookupTable*(): LookupTables=
  ## This initializes all the useful lookups for the board at compile time
  ## meant to be assigned to a const variable
  ##
  var table = LookupTables()
  # file lookups
  table.mask_file[FILE_1]  = 0x0101010101010101u64
  table.mask_file[FILE_2]  = 0x0202020202020202u64
  table.mask_file[FILE_3]  = 0x0404040404040404u64
  table.mask_file[FILE_4]  = 0x0808080808080808u64
  table.mask_file[FILE_5]  = 0x1010101010101010u64
  table.mask_file[FILE_6]  = 0x2020202020202020u64
  table.mask_file[FILE_7]  = 0x4040404040404040u64
  table.mask_file[FILE_8]  = 0x8080808080808080u64
  table.clear_file[FILE_1] = bitnot(table.mask_file[FILE_1])
  table.clear_file[FILE_2] = bitnot(table.mask_file[FILE_2])
  table.clear_file[FILE_3] = bitnot(table.mask_file[FILE_3])
  table.clear_file[FILE_4] = bitnot(table.mask_file[FILE_4])
  table.clear_file[FILE_5] = bitnot(table.mask_file[FILE_5])
  table.clear_file[FILE_6] = bitnot(table.mask_file[FILE_6])
  table.clear_file[FILE_7] = bitnot(table.mask_file[FILE_7])
  table.clear_file[FILE_8] = bitnot(table.mask_file[FILE_8])
  # rank lookups
  table.mask_rank[RANK_1]  = 0x00000000000000FFu64
  table.mask_rank[RANK_2]  = 0x000000000000FF00u64
  table.mask_rank[RANK_3]  = 0x0000000000FF0000u64
  table.mask_rank[RANK_4]  = 0x00000000FF000000u64
  table.mask_rank[RANK_5]  = 0x000000FF00000000u64
  table.mask_rank[RANK_6]  = 0x0000FF0000000000u64
  table.mask_rank[RANK_7]  = 0x00FF000000000000u64
  table.mask_rank[RANK_8]  = 0xFF00000000000000u64
  table.clear_rank[RANK_1] = bitnot(table.mask_rank[RANK_1])
  table.clear_rank[RANK_2] = bitnot(table.mask_rank[RANK_2])
  table.clear_rank[RANK_3] = bitnot(table.mask_rank[RANK_3])
  table.clear_rank[RANK_4] = bitnot(table.mask_rank[RANK_4])
  table.clear_rank[RANK_5] = bitnot(table.mask_rank[RANK_5])
  table.clear_rank[RANK_6] = bitnot(table.mask_rank[RANK_6])
  table.clear_rank[RANK_7] = bitnot(table.mask_rank[RANK_7])
  table.clear_rank[RANK_8] = bitnot(table.mask_rank[RANK_8])

  for location in A1..H8:
    # piece lookups
    table.pieces[location] = 1u64 shl location.ord
    # initialze rays
    table.attack_rays[location][NORTH]  = table.getNorthRay(location)
    table.attack_rays[location][SOUTH]  = table.getSouthRay(location)
    table.attack_rays[location][EAST]   = table.getEastRay(location)
    table.attack_rays[location][WEST]   = table.getWestRay(location)
    table.attack_rays[location][NORTH_WEST] = table.getNorthWestRay(location)
    table.attack_rays[location][NORTH_EAST] = table.getNorthEastRay(location)
    table.attack_rays[location][SOUTH_EAST] = table.getSouthEastRay(location)
    table.attack_rays[location][SOUTH_WEST] = table.getSouthWestRay(location)
    # initialize attacks
    table.king_attacks[location]        = table.calcKingMoves(location)
    table.knight_attacks[location]      = table.calcKnightMoves(location)
    table.pawn_attacks[location][White] = table.calcPawnAttack(location, White)
    table.pawn_attacks[location][Black] = table.calcPawnAttack(location, Black)
  table.initialized = true # indicate that table has been initialized
  return table


