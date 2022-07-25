{.compile: "m42.cpp"}
from ../util import Bitboard, BoardIndex

proc init*() {.header: "m42.h", importcpp: "M42::init".}

proc randBitboard*(): Bitboard {.header: "m42.h", importcpp: "M42::randy".}

proc queenAttack*(square: cint, occ: Bitboard): Bitboard{.header: "m42.h",
                                                          importcpp: "M42::queen_attacks(@)".}

proc rookAttack*(square: cint, occ: Bitboard): Bitboard{.header: "m42.h",
                                                         importcpp: "M42::rook_attacks(@)".}

proc bishopAttack*(square: cint, occ: Bitboard): Bitboard{.header: "m42.h",
                                                           importcpp: "M42::bishop_attacks(@)".}
init()
