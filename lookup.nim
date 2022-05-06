from bitboard import Pieces, PositionsIndex, Bitboard,
     Ranks, Files, prettyBitboard
import bitops, strutils


type
  LookupTables = object
    clear_rank: array[RANK_1..RANK_8, Bitboard] ## Lookup for setting bits at a particular rank to zero
    mask_rank : array[RANK_1..RANK_8, Bitboard] ## Lookup for only selecting bits at a particular rank
    clear_file: array[FILE_1..FILE_8, Bitboard] ## Lookup for setting bits at a particular file to zero
    mask_file : array[FILE_1..FILE_8, Bitboard] ## Lookup for only selecting bits at a particular file
    pieces    : array[A1..H8, Bitboard]




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
  return table

when isMainModule:
  const
    a = newLookupTable()

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
  #[
    ]#



