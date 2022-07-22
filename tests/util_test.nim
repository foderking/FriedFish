import ../util
import base

proc testBoardPosition(debug: bool)=
  # Tests the ordinals for `BoardPosition`
  assertVal(A1.ord,  0, "invalid ordinal for A1", debug)
  assertVal(B1.ord,  1, "invalid ordinal for B1", debug)
  assertVal(C1.ord,  2, "invalid ordinal for C1", debug)
  assertVal(D1.ord,  3, "invalid ordinal for D1", debug)
  assertVal(E1.ord,  4, "invalid ordinal for E1", debug)
  assertVal(F1.ord,  5, "invalid ordinal for F1", debug)
  assertVal(G1.ord,  6, "invalid ordinal for G1", debug)
  assertVal(H1.ord,  7, "invalid ordinal for H1", debug)
  assertVal(A2.ord,  8, "invalid ordinal for A2", debug)
  assertVal(B2.ord,  9, "invalid ordinal for B2", debug)
  assertVal(C2.ord, 10, "invalid ordinal for C2", debug)
  assertVal(D2.ord, 11, "invalid ordinal for D2", debug)
  assertVal(E2.ord, 12, "invalid ordinal for E2", debug)
  assertVal(F2.ord, 13, "invalid ordinal for F2", debug)
  assertVal(G2.ord, 14, "invalid ordinal for G2", debug)
  assertVal(H2.ord, 15, "invalid ordinal for H2", debug)
  assertVal(A3.ord, 16, "invalid ordinal for A3", debug)
  assertVal(B3.ord, 17, "invalid ordinal for B3", debug)
  assertVal(C3.ord, 18, "invalid ordinal for C3", debug)
  assertVal(D3.ord, 19, "invalid ordinal for D3", debug)
  assertVal(E3.ord, 20, "invalid ordinal for E3", debug)
  assertVal(F3.ord, 21, "invalid ordinal for F3", debug)
  assertVal(G3.ord, 22, "invalid ordinal for G3", debug)
  assertVal(H3.ord, 23, "invalid ordinal for H3", debug)
  assertVal(A4.ord, 24, "invalid ordinal for A4", debug)
  assertVal(B4.ord, 25, "invalid ordinal for B4", debug)
  assertVal(C4.ord, 26, "invalid ordinal for C4", debug)
  assertVal(D4.ord, 27, "invalid ordinal for D4", debug)
  assertVal(E4.ord, 28, "invalid ordinal for E4", debug)
  assertVal(F4.ord, 29, "invalid ordinal for F4", debug)
  assertVal(G4.ord, 30, "invalid ordinal for G4", debug)
  assertVal(H4.ord, 31, "invalid ordinal for H4", debug)
  assertVal(A5.ord, 32, "invalid ordinal for A5", debug)
  assertVal(B5.ord, 33, "invalid ordinal for B5", debug)
  assertVal(C5.ord, 34, "invalid ordinal for C5", debug)
  assertVal(D5.ord, 35, "invalid ordinal for D5", debug)
  assertVal(E5.ord, 36, "invalid ordinal for E5", debug)
  assertVal(F5.ord, 37, "invalid ordinal for F5", debug)
  assertVal(G5.ord, 38, "invalid ordinal for G5", debug)
  assertVal(H5.ord, 39, "invalid ordinal for H5", debug)
  assertVal(A6.ord, 40, "invalid ordinal for A6", debug)
  assertVal(B6.ord, 41, "invalid ordinal for B6", debug)
  assertVal(C6.ord, 42, "invalid ordinal for C6", debug)
  assertVal(D6.ord, 43, "invalid ordinal for D6", debug)
  assertVal(E6.ord, 44, "invalid ordinal for E6", debug)
  assertVal(F6.ord, 45, "invalid ordinal for F6", debug)
  assertVal(G6.ord, 46, "invalid ordinal for G6", debug)
  assertVal(H6.ord, 47, "invalid ordinal for H6", debug)
  assertVal(A7.ord, 48, "invalid ordinal for A7", debug)
  assertVal(B7.ord, 49, "invalid ordinal for B7", debug)
  assertVal(C7.ord, 50, "invalid ordinal for C7", debug)
  assertVal(D7.ord, 51, "invalid ordinal for D7", debug)
  assertVal(E7.ord, 52, "invalid ordinal for E7", debug)
  assertVal(F7.ord, 53, "invalid ordinal for F7", debug)
  assertVal(G7.ord, 54, "invalid ordinal for G7", debug)
  assertVal(H7.ord, 55, "invalid ordinal for H8", debug)
  assertVal(A8.ord, 56, "invalid ordinal for A8", debug)
  assertVal(B8.ord, 57, "invalid ordinal for B8", debug)
  assertVal(C8.ord, 58, "invalid ordinal for C8", debug)
  assertVal(D8.ord, 59, "invalid ordinal for D8", debug)
  assertVal(E8.ord, 60, "invalid ordinal for E8", debug)
  assertVal(F8.ord, 61, "invalid ordinal for F8", debug)
  assertVal(G8.ord, 62, "invalid ordinal for G8", debug)
  assertVal(H8.ord, 63, "invalid ordinal for H8", debug)
  assertVal(NULL_POSITION.ord, 64, "invalid ordinal for null position", debug)

proc testPieces(debug: bool)=
  # Tests the ordinals for `Pieces`
  assertVal(Pawn.ord  , 0, "invalid ordinal for pawn"  , debug)
  assertVal(Rook.ord  , 1, "invalid ordinal for rook"  , debug)
  assertVal(Bishop.ord, 2, "invalid ordinal for bishop", debug)
  assertVal(Knight.ord, 3, "invalid ordinal for knight", debug)
  assertVal(Queen.ord , 4, "invalid ordinal for queen" , debug)
  assertVal(King.ord  , 5, "invalid ordinal for king"  , debug)
  assertVal(NULL_PIECE.ord, 6, "invalid ordinal for null piece", debug)

proc testRanks(debug: bool)=
  # Tests ordinals for `Ranks`
  assertVal(RANK_1.ord, 0, "invalid rank in `RANK_1`", debug)
  assertVal(RANK_2.ord, 1, "invalid rank in `RANK_2`", debug)
  assertVal(RANK_3.ord, 2, "invalid rank in `RANK_3`", debug)
  assertVal(RANK_4.ord, 3, "invalid rank in `RANK_4`", debug)
  assertVal(RANK_5.ord, 4, "invalid rank in `RANK_5`", debug)
  assertVal(RANK_6.ord, 5, "invalid rank in `RANK_6`", debug)
  assertVal(RANK_7.ord, 6, "invalid rank in `RANK_7`", debug)
  assertVal(RANK_8.ord, 7, "invalid rank in `RANK_8`", debug)

proc testFiles(debug: bool)=
  # Tests ordinals for `Files`
  assertVal(FILE_A.ord, 0, "invalid file in `FILE_A`", debug)
  assertVal(FILE_B.ord, 1, "invalid file in `FILE_B`", debug)
  assertVal(FILE_C.ord, 2, "invalid file in `FILE_C`", debug)
  assertVal(FILE_D.ord, 3, "invalid file in `FILE_D`", debug)
  assertVal(FILE_E.ord, 4, "invalid file in `FILE_E`", debug)
  assertVal(FILE_F.ord, 5, "invalid file in `FILE_F`", debug)
  assertVal(FILE_G.ord, 6, "invalid file in `FILE_G`", debug)
  assertVal(FILE_H.ord, 7, "invalid file in `FILE_H`", debug)

proc testFamily(debug: bool)=
  # Tests `Family`
  assertVal(White.ord, 0, "invalid ord for White", debug)
  assertVal(Black.ord, 1, "invalid ord for Black", debug)

proc testValidPieces(debug: bool)=
  assertVal(ValidPiece.low, Pawn, "invalid lower bound for `ValidPiece`", debug)
  assertVal(ValidPiece.high,King, "invalid upper bound for `ValidPiece`", debug)

proc testBoardIndex(debug: bool)=
  assertVal(BoardIndex.low , 0, "wrong lower bound for `BoardIndex`", debug)
  assertVal(BoardIndex.high,63, "wrong upper bound for `BoardIndex`", debug)

proc testValidBoardPosition(debug: bool)=
  assertVal(ValidBoardPosition.low, A1,
            "wrong lower bound for `ValidBoardPosition`", debug)
  assertVal(ValidBoardPosition.high, H8,
            "wrong upper bound for `ValidBoardPosition`", debug)

proc testFileIndex(debug: bool)=
  assertVal(FileIndex.low , 0, "wrong lower bound for `FileIndex`", debug)
  assertVal(FileIndex.high, 7, "wrong upper bound for `FileIndex`", debug)

proc testValidFile(debug: bool)=
  assertVal(ValidFile.low , FILE_A, "wrong lower bound for `ValidFile`", debug)
  assertVal(ValidFile.high, FILE_H, "wrong upper bound for `ValidFile`", debug)
  
proc testRankIndex(debug: bool)=
  assertVal(RankIndex.low , 0, "wrong lower bound for `RankIndex`", debug)
  assertVal(RankIndex.high, 7, "wrong upper bound for `RankIndex`", debug)
  
proc testValidRank(debug: bool)=
  assertVal(ValidRank.low , RANK_1, "wrong lower bound for `ValidRank`", debug)
  assertVal(ValidRank.high, RANK_8, "wrong upper bound for `ValidRank`", debug)

proc testBoardPositionLookup(debug: bool)=
  # Tests the mapping for `BoardPositionLookup` over `BoardIndex`
  #   BardIndexType == BoardPositionLookup[BoardIndexType].ord
  for boardIndexType in BoardIndex.low..BoardIndex.high:
    assertVal(BoardPositionLookup[boardIndexType].ord, boardIndexType,
              "wrong mapping for `BoardPositionLookup` at "&($boardIndexType), debug)

proc testFilesLookup(debug: bool)=
  # Tests the mapping for `FilesLookup` over `FileIndex`
  #   FileIndexType == FilesLookup[FileIndexType].ord
  for fileIndexType in FileIndex.low..FileIndex.high:
    assertVal(FilesLookup[fileIndexType].ord, fileIndexType,
              "wrong mapping for `FilesLookup` at "&($fileIndexType), debug)

proc testRanksLookup(debug: bool)=
  # Tests the mapping for `RanksLookup` over `RankIndex`
  #   RankIndexType == RanksLookup[RankIndexType].ord
  for rankIndexType in RankIndex.low..RankIndex.high:
    assertVal(RanksLookup[rankIndexType].ord, rankIndexType,
              "wrong mapping for `RanksLookup` at "&($rankIndexType), debug)
              
proc testPiecesLookup(debug: bool)=
  ## TODO extract all the lookup tests to a function
  # Tests the mapping for `PieceLookup` over `PieceIndex`
  #   PieceIndexType == PieceLookup[PieceIndexType].ord
  for pieceIndexType in PieceIndex.low..PieceIndex.high:
    assertVal(PieceLookup[pieceIndexType].ord, pieceIndexType,
              "wrong mapping for `PieceLookup` at "&($pieceIndexType), debug)

proc testAllPiecesLookup(debug: bool)=
  # Tests the mapping for `AllPieceLookup`
  for pieceIndexType in AllPieces.low..AllPieces.high:
    assertVal(pieceIndexType, AllPiecesLookup[pieceIndexType.ord],
              "wrong mapping for `AllPieceLookup` at "&($pieceIndexType), debug)


proc testDefaultBitboards(debug: bool)=
  assertVal(empty_bitboard, 0u64, "wrong value for empty bitboard", debug)
  assertVal(full_bitboard, 0xFFFFFFFFFFFFFFFFu64, "wrong value for full bitboard", debug)
  assertVal(white_p, 0b0000000000000000000000000000000000000000000000001111111100000000u64,
            "wrong value for white pawn"  , debug)
  assertVal(white_r, 0b0000000000000000000000000000000000000000000000000000000010000001u64,
            "wrong value for white rook"  , debug)
  assertVal(white_n, 0b0000000000000000000000000000000000000000000000000000000001000010u64,
            "wrong value for white knight", debug)
  assertVal(white_b, 0b0000000000000000000000000000000000000000000000000000000000100100u64,
            "wrong value for white bishop", debug)
  assertVal(white_q, 0b0000000000000000000000000000000000000000000000000000000000001000u64,
            "wrong value for white queen" , debug)
  assertVal(white_k, 0b0000000000000000000000000000000000000000000000000000000000010000u64,
            "wrong value for white king"  , debug)
  assertVal(black_p, 0b0000000011111111000000000000000000000000000000000000000000000000u64,
            "wrong value for black pawn"  , debug)
  assertVal(black_r, 0b1000000100000000000000000000000000000000000000000000000000000000u64,
            "wrong value for black rook"  , debug)
  assertVal(black_n, 0b0100001000000000000000000000000000000000000000000000000000000000u64,
            "wrong value for black knight", debug)
  assertVal(black_b, 0b0010010000000000000000000000000000000000000000000000000000000000u64,
            "wrong value for black bishop", debug)
  assertVal(black_q, 0b0000100000000000000000000000000000000000000000000000000000000000u64,
            "wrong value for black queen" , debug)
  assertVal(black_k, 0b0001000000000000000000000000000000000000000000000000000000000000u64,
            "wrong value for black king"  , debug)

proc testCalcRank(debug: bool)=
  assertVal(calcRank(A1), RANK_1, "Invalid rank for A1", debug)
  assertVal(calcRank(B1), RANK_1, "Invalid rank for B1", debug)
  assertVal(calcRank(C1), RANK_1, "Invalid rank for C1", debug)
  assertVal(calcRank(E1), RANK_1, "Invalid rank for E1", debug)
  assertVal(calcRank(G1), RANK_1, "Invalid rank for G1", debug)
  assertVal(calcRank(H1), RANK_1, "Invalid rank for H1", debug)
  assertVal(calcRank(A2), RANK_2, "Invalid rank for A2", debug)
  assertVal(calcRank(B2), RANK_2, "Invalid rank for B2", debug)
  assertVal(calcRank(C2), RANK_2, "Invalid rank for C2", debug)
  assertVal(calcRank(E2), RANK_2, "Invalid rank for E2", debug)
  assertVal(calcRank(G2), RANK_2, "Invalid rank for G2", debug)
  assertVal(calcRank(H2), RANK_2, "Invalid rank for H2", debug)
  assertVal(calcRank(A4), RANK_4, "Invalid rank for A4", debug)
  assertVal(calcRank(B4), RANK_4, "Invalid rank for B4", debug)
  assertVal(calcRank(C4), RANK_4, "Invalid rank for C4", debug)
  assertVal(calcRank(E4), RANK_4, "Invalid rank for E4", debug)
  assertVal(calcRank(G4), RANK_4, "Invalid rank for G4", debug)
  assertVal(calcRank(H4), RANK_4, "Invalid rank for H4", debug)
  assertVal(calcRank(A6), RANK_6, "Invalid rank for A6", debug)
  assertVal(calcRank(B6), RANK_6, "Invalid rank for B6", debug)
  assertVal(calcRank(C6), RANK_6, "Invalid rank for C6", debug)
  assertVal(calcRank(E6), RANK_6, "Invalid rank for E6", debug)
  assertVal(calcRank(G6), RANK_6, "Invalid rank for G6", debug)
  assertVal(calcRank(H6), RANK_6, "Invalid rank for H6", debug)
  assertVal(calcRank(A8), RANK_8, "Invalid rank for A8", debug)
  assertVal(calcRank(B8), RANK_8, "Invalid rank for B8", debug)
  assertVal(calcRank(C8), RANK_8, "Invalid rank for C8", debug)
  assertVal(calcRank(E8), RANK_8, "Invalid rank for E8", debug)
  assertVal(calcRank(G8), RANK_8, "Invalid rank for G8", debug)
  assertVal(calcRank(H8), RANK_8, "Invalid rank for H8", debug)

proc testCalcFile(debug: bool)=
  assertVal(calcFile(A1), FILE_A, "Invalid file for A1", debug)
  assertVal(calcFile(C1), FILE_C, "Invalid file for C1", debug)
  assertVal(calcFile(E1), FILE_E, "Invalid file for E1", debug)
  assertVal(calcFile(G1), FILE_G, "Invalid file for G1", debug)
  assertVal(calcFile(H1), FILE_H, "Invalid file for H1", debug)
  assertVal(calcFile(A2), FILE_A, "Invalid file for A2", debug)
  assertVal(calcFile(B2), FILE_B, "Invalid file for B2", debug)
  assertVal(calcFile(C2), FILE_C, "Invalid file for C2", debug)
  assertVal(calcFile(E2), FILE_E, "Invalid file for E2", debug)
  assertVal(calcFile(G2), FILE_G, "Invalid file for G2", debug)
  assertVal(calcFile(H2), FILE_H, "Invalid file for H2", debug)
  assertVal(calcFile(A4), FILE_A, "Invalid file for A4", debug)
  assertVal(calcFile(B4), FILE_B, "Invalid file for B4", debug)
  assertVal(calcFile(C4), FILE_C, "Invalid file for C4", debug)
  assertVal(calcFile(E4), FILE_E, "Invalid file for E4", debug)
  assertVal(calcFile(G4), FILE_G, "Invalid file for G4", debug)
  assertVal(calcFile(H4), FILE_H, "Invalid file for H4", debug)
  assertVal(calcFile(A6), FILE_A, "Invalid file for A6", debug)
  assertVal(calcFile(B6), FILE_B, "Invalid file for B6", debug)
  assertVal(calcFile(C6), FILE_C, "Invalid file for C6", debug)
  assertVal(calcFile(E6), FILE_E, "Invalid file for E6", debug)
  assertVal(calcFile(G6), FILE_G, "Invalid file for G6", debug)
  assertVal(calcFile(H6), FILE_H, "Invalid file for H6", debug)
  assertVal(calcFile(A8), FILE_A, "Invalid file for A8", debug)
  assertVal(calcFile(B8), FILE_B, "Invalid file for B8", debug)
  assertVal(calcFile(C8), FILE_C, "Invalid file for C8", debug)
  assertVal(calcFile(E8), FILE_E, "Invalid file for E8", debug)
  assertVal(calcFile(G7), FILE_G, "Invalid file for G8", debug)
  assertVal(calcFile(H8), FILE_H, "Invalid file for H8", debug)

proc testGetRank(debug: bool)=
  for rank in 1..8:
    # TODO assertVal(getRank(rank.ch))
    #echo getRank('1')
    discard

proc TestHelpers(debug: bool)=
  startTest("testing Helper functions")
  doTest "default bitboards", testDefaultBitboards(debug)
  doTest "calcRank", testCalcRank(debug)
  doTest "calcFile", testCalcFile(debug)

proc TestTypes(debug: bool)=
  # The main types
  startTest("testing base types")
  doTest "BoardPosition", testBoardPosition(debug)
  doTest "Pieces", testPieces(debug)
  doTest "Ranks",  testRanks(debug)
  doTest "Files",  testFiles(debug)
  doTest "Family", testFamily(debug)

proc TestRangeTypes(debug: bool)=
  # Tests types that are range of enums (eg Type = Pawn..King)
  # if all values of the enum are tested to have the correct ordinal,
  # then, testing only the upper and lower bound is sufficient to test the range type
  # eg:
  #   if `testPiece` works, then `Pawn` < `Rook` < ... < `King` < `NULL_PIECE`
  #   and if the lower bound is `Pawn` and higher bound is `King`, then
  #   `ValidPiece` => `Pawn..King`
  startTest("testing range types")
  doTest "ValidPiece", testValidPieces(debug)
  doTest "BoardIndex", testBoardIndex(debug)
  doTest "ValidBoardPosition", testValidBoardPosition(debug)
  doTest "FileIndex", testFileIndex(debug)
  doTest "ValidFile", testValidFile(debug)
  doTest "ValidRank", testValidRank(debug)
  doTest "RankIndex", testRankIndex(debug)

proc TestMappingTypes(debug: bool)=
  # Tests types that map to each other
  # eg:
  #   BoardPositionLookup maps BoardIndex -> BoardPosition
  #
  #   if  `BoardPositionLookup[BoardIndexType] = BoardPositionType`
  #   and `BoardPositionType.ord = BoardIndexType`
  #   then:
    #   BardIndexType = BoardPositionLookup[BoardIndexType].ord
  doTest "BoardPositionLookup", testBoardPositionLookup(debug)
  doTest "FilesLookup", testFilesLookup(debug)
  doTest "RanksLookup", testRanksLookup(debug)
  doTest "PieceLookup", testPiecesLookup(debug)
  doTest "AllPieceLookup", testAllPiecesLookup(debug)

when isMainModule:
  let d = false
  TestTypes(d)
  TestRangeTypes(d)
  TestMappingTypes(d)
  TestHelpers(d)
  testGetRank(d)
