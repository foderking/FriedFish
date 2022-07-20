## Types and functions for the engine's lookup tables 
##
## references
##  [2] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/nonsliding.html
##
import bitops
import util

type
  RAYS = enum
    ## This represent any possible ray from a sliding piece (rook, bishop, queen)
    NORTH,SOUTH,EAST,WEST ,
    NORTH_WEST, NORTH_EAST,
    SOUTH_WEST, SOUTH_EAST
  ValidRays = RAYS.low..RAYS.high

type
  LookupTables* = object
    initialized: bool ## helps in debugging TODO
    clear_rank*: array[ValidRank, Bitboard] ## Lookup for setting bits at a particular rank to zero
    mask_rank* : array[ValidRank, Bitboard] ## Lookup for only selecting bits at a particular rank
    clear_file*: array[ValidFile, Bitboard] ## Lookup for setting bits at a particular file to zero
    mask_file* : array[ValidFile, Bitboard] ## Lookup for only selecting bits at a particular file
    pieces*    : array[ValidBoardPosition, Bitboard] ## Lookup for bitboard rep of all board positions

    knight_attacks: array[ValidBoardPosition, Bitboard] ## Lookup to knight attacks
    bishop_attacks: array[ValidBoardPosition, Bitboard] ## Lookup for bishop attacks
    queen_attacks : array[ValidBoardPosition, Bitboard] ## Lookup for queen attacks
    king_attacks  : array[ValidBoardPosition, Bitboard] ## Lookup for king attacks
    rook_attacks  : array[ValidBoardPosition, Bitboard] ## Lookup for rook attacks
    pawn_attacks  : array[ValidBoardPosition, 
                          array[Family,Bitboard]] ## Lookup for both black and white pawn attacks.
    attack_rays: array[ValidBoardPosition, 
                       array[ValidRays, Bitboard]] ## Lookup for sliding pieces rays (rook, bishop)

proc getNorthRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## generates bitboard for north ray from rook at `square`
  return bitand(this.mask_file[calcFile(square)], not bitor(this.pieces[square], 
                this.pieces[square]-1))

proc getSouthRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## generates bitboard for south ray from rook at `square`
  return bitand(this.mask_file[calcFile(square)], not this.pieces[square],
                this.pieces[square]-1)

proc getEastRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## generates bitboard for east ray from rook at `square`
  return bitand(this.mask_rank[calcRank(square)], not bitor(this.pieces[square],
                this.pieces[square]-1))

proc getWestRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## generates bitboard for west ray from rook at `square`
  return bitand(this.mask_rank[calcRank(square)], not this.pieces[square], this.pieces[square]-1)

## The following implementations gotten from
## https://www.chessprogramming.org/Kogge-Stone_Algorithm#Fillonanemptyboard
##
proc getNorthEastRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## Gets north-east ray from bishop starting at `square` without blockers
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_A]
    pr1 = bitand(pr0, (pr0 shl  9))
    pr2 = bitand(pr1, (pr1 shl 18))
  gen |= bitand(pr0, (gen shl  9))
  gen |= bitand(pr1, (gen shl 18))
  gen |= bitand(pr2, (gen shl 36))
  return bitand(gen, not this.pieces[square]);

proc getSouthEastRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## Gets south-east ray from bishop starting at `square` without blockers
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_A]
    pr1 = bitand(pr0 , (pr0 shr  7))
    pr2 = bitand(pr1 , (pr1 shr 14))
  gen |= bitand(pr0 , (gen shr  7))
  gen |= bitand(pr1 , (gen shr 14))
  gen |= bitand(pr2 , (gen shr 28))
  return bitand(gen, not this.pieces[square]);

proc getSouthWestRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## Gets south-west ray from bishop starting at `square` without blockers
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_H]
    pr1 = bitand(pr0, (pr0 shr  9))
    pr2 = bitand(pr1, (pr1 shr 18))
  gen |= bitand(pr0, (gen shr  9))
  gen |= bitand(pr1, (gen shr 18))
  gen |= bitand(pr2, (gen shr 36))
  return bitand(gen, not this.pieces[square]);

proc getNorthWestRay*(this: LookupTables, square: BoardPosition): Bitboard{.inline}=
  ## Gets south-west ray from bishop starting at `square` without blockers
  var gen = this.pieces[square]
  let
    pr0 = this.clear_file[FILE_H]
    pr1 = bitand(pr0, (pr0 shl  7))
    pr2 = bitand(pr1, (pr1 shl 14))
  gen |= bitand(pr0, (gen shl  7))
  gen |= bitand(pr1, (gen shl 14))
  gen |= bitand(pr2, (gen shl 28))
  return bitand(gen, not this.pieces[square]);


proc calcKingMoves(this: LookupTables, square: BoardPosition): Bitboard=
  ## Pre-calculates all possible movements for king in the board location at `square`
  let
    pos    = this.pieces[square]
    left   = bitand(pos, this.clear_file[FILE_A]) shr 1
    right  = bitand(pos, this.clear_file[FILE_H]) shl 1
    middle = bitor(left, right, pos)
    up     = bitand(middle, this.clear_rank[RANK_8]) shl 8
    down   = bitand(middle, this.clear_rank[RANK_1]) shr 8
  return bitor(up, down, middle).clearMasked(pos)

proc calcKnightMoves(this: LookupTables, square: BoardPosition): Bitboard=
  ## Pre-calculates all possible movements for the knight in the board location at `square`
  let
    pos       = this.pieces[square]
    left_one  = bitand(pos, this.clear_file[FILE_A]) shr 1
    left_two  = bitand(pos, this.clear_file[FILE_A], this.clear_file[FILE_B]) shr 2
    right_one = bitand(pos, this.clear_file[FILE_H]) shl 1
    right_two = bitand(pos, this.clear_file[FILE_H], this.clear_file[FILE_G]) shl 2
    one       = bitor(left_one, right_one)
    two       = bitor(left_two, right_two)
    north_one = bitand(one, this.clear_rank[RANK_8], this.clear_rank[RANK_7]) shl 16
    north_two = bitand(two, this.clear_rank[RANK_8]) shl 8
    south_one = bitand(one, this.clear_rank[RANK_1], this.clear_rank[RANK_2]) shr 16
    south_two = bitand(two, this.clear_rank[RANK_1]) shr 8
  return bitor(north_one, north_two, south_one, south_two)

proc calcPawnAttack(this: LookupTables, square: BoardPosition, fam: Family): Bitboard=
  ## Pre-calculates all possible **attacks** for the pawn with specified color at `square`
  ## Notes: pawn movements are different from the attacks
  let
    pos = this.pieces[square]
  case fam
  of White:
    return bitor(bitand(pos, this.clear_file[FILE_A]) shl 7,
                 bitand(pos, this.clear_file[FILE_H]) shl 9)
  of Black:
    return bitor(bitand(pos, this.clear_file[FILE_H]) shr 7,
                 bitand(pos, this.clear_file[FILE_A]) shr 9)


proc kingMove*(this: LookupTables, square: BoardPosition,
               friendly_pieces: Bitboard): Bitboard{.inline}=
  ## Returns a bitboard representing all valid moves for a king at location `square`
  assert this.initialized # make sure tables have been initialized
  return bitand(this.king_attacks[square], bitnot(friendly_pieces))

proc knightMove*(this: LookupTables, square: BoardPosition,
                 friendly_pieces: Bitboard): Bitboard{.inline}=
  ## Returns a bitboard representing all valid moves for a knight at location `square`
  assert this.initialized # make sure tables have been initialized
  return bitand(this.knight_attacks[square], bitnot(friendly_pieces))

proc pawnMove*(this: LookupTables, square: BoardPosition,
               fam : Family, friendly_pieces, enemy_pieces: Bitboard): Bitboard{.inline}=
  ## Returns a bitboard representing all valid movements (including attacks) for a pawn at location `square`
  ## TODO: enpassant
  ## Implementation based on [2]
  assert this.initialized # make sure tables have been initialized
  let all_pieces = bitor(friendly_pieces, enemy_pieces)

  case fam
  of White:
    let
      pos = this.pieces[square]
      # the bitnot(all_pieces) prevents the pawn from moving into occupied squares
      # check the single space infront of the white pawn
      one_step = bitand(pos shl 8, bitnot(all_pieces)) # one step in front of pos
      # Only pawns that can move two steps must
      #   - be at rank 2
      #   - not be blocked by another piece: `one_step` is 0
      two_step = bitand(bitand(one_step, this.mask_rank[RANK_3]) shl 8, bitnot(all_pieces))
      attack   = bitand(this.pawn_attacks[square][White], enemy_pieces)
    return bitor(attack, one_step, two_step)
  of Black:
    let
      pos = this.pieces[square]
      # the bitnot(all_pieces) prevents the pawn from moving into occupied squares
      # check the single space infront of the white pawn
      one_step = bitand(pos shr 8, bitnot(all_pieces))
      # Only pawns that can move two steps must
      #   - be at rank 7
      #   - not be blocked by another piece: `one_step` is 0
      two_step = bitand(bitand(one_step, this.mask_rank[RANK_6]) shr 8, bitnot(all_pieces))
      attack   = bitand(this.pawn_attacks[square][Black], enemy_pieces)
    return bitor(attack, one_step, two_step)
 
##
## The following functions implement move generation for sliding pieces using..
## the classical approach. https://www.chessprogramming.org/Classical_Approach
## Based on: https://rhysre.net/fast-chess-move-generation-with-magic-bitboards.html
##
proc bishopMove*(this: LookupTables,  square: BoardPosition,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  let
    nw_ray = this.attack_rays[square][NORTH_WEST]
    ne_ray = this.attack_rays[square][NORTH_EAST]
    sw_ray = this.attack_rays[square][SOUTH_WEST]
    se_ray = this.attack_rays[square][SOUTH_EAST]
  var
    attacks = this.attack_rays[square][NORTH_WEST]
    index: BoardPosition ## location of first blocked piece

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

proc rookMove*(this: LookupTables,  square: BoardPosition,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  let
    n_ray = this.attack_rays[square][NORTH]
    s_ray = this.attack_rays[square][SOUTH]
    e_ray = this.attack_rays[square][EAST]
    w_ray = this.attack_rays[square][WEST]

  var
    attacks = this.attack_rays[square][NORTH]
    index: BoardPosition ## location of first blocked piece

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

proc queenMove*(this: LookupTables,  square: BoardPosition,
                 all_pieces, friendly_pieces: Bitboard): Bitboard{.inline}=
  return bitor(this.bishopMove(square, all_pieces, friendly_pieces),
               this.rookMove(square,   all_pieces, friendly_pieces))


proc newLookupTable*(): LookupTables=
  ## This initializes all the lookups for the board
  ## meant to be assigned to a const variable
  ##
  var table = LookupTables()
  # File lookups
  table.mask_file[FILE_A]  = 0x0101010101010101u64
  table.mask_file[FILE_B]  = 0x0202020202020202u64
  table.mask_file[FILE_C]  = 0x0404040404040404u64
  table.mask_file[FILE_D]  = 0x0808080808080808u64
  table.mask_file[FILE_E]  = 0x1010101010101010u64
  table.mask_file[FILE_F]  = 0x2020202020202020u64
  table.mask_file[FILE_G]  = 0x4040404040404040u64
  table.mask_file[FILE_H]  = 0x8080808080808080u64
  table.clear_file[FILE_A] = 0xFEFEFEFEFEFEFEFEu64
  table.clear_file[FILE_B] = 0xFDFDFDFDFDFDFDFDu64
  table.clear_file[FILE_C] = 0xFBFBFBFBFBFBFBFBu64
  table.clear_file[FILE_D] = 0xF7F7F7F7F7F7F7F7u64
  table.clear_file[FILE_E] = 0xEFEFEFEFEFEFEFEFu64
  table.clear_file[FILE_F] = 0xDFDFDFDFDFDFDFDFu64
  table.clear_file[FILE_G] = 0xBFBFBFBFBFBFBFBFu64
  table.clear_file[FILE_H] = 0x7F7F7F7F7F7F7F7Fu64
  # Rank lookups
  table.mask_rank[RANK_1]  = 0x00000000000000FFu64
  table.mask_rank[RANK_2]  = 0x000000000000FF00u64
  table.mask_rank[RANK_3]  = 0x0000000000FF0000u64
  table.mask_rank[RANK_4]  = 0x00000000FF000000u64
  table.mask_rank[RANK_5]  = 0x000000FF00000000u64
  table.mask_rank[RANK_6]  = 0x0000FF0000000000u64
  table.mask_rank[RANK_7]  = 0x00FF000000000000u64
  table.mask_rank[RANK_8]  = 0xFF00000000000000u64
  table.clear_rank[RANK_1] = 0XFFFFFFFFFFFFFF00u64
  table.clear_rank[RANK_2] = 0XFFFFFFFFFFFF00FFu64
  table.clear_rank[RANK_3] = 0XFFFFFFFFFF00FFFFu64
  table.clear_rank[RANK_4] = 0XFFFFFFFF00FFFFFFu64
  table.clear_rank[RANK_5] = 0XFFFFFF00FFFFFFFFu64
  table.clear_rank[RANK_6] = 0XFFFF00FFFFFFFFFFu64
  table.clear_rank[RANK_7] = 0XFF00FFFFFFFFFFFFu64
  table.clear_rank[RANK_8] = 0X00FFFFFFFFFFFFFFu64

  for location in ValidBoardPosition:
    # piece lookups
    table.pieces[location] = 1u64 shl location.ord
    # initialize rays (need to be initialized before attacks)
    table.attack_rays[location][NORTH]      = table.getNorthRay(location)
    table.attack_rays[location][SOUTH]      = table.getSouthRay(location)
    table.attack_rays[location][EAST]       = table.getEastRay(location)
    table.attack_rays[location][WEST]       = table.getWestRay(location)
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
