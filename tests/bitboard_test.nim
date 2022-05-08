import ../bitboard
import tables, strutils, base

template test_posInd(value, ans: untyped): untyped=
  ## template should produce something like
  ## ```nim
  ## # from
  ## test_posInd(PositionsIndex.A1.ord, 0)
  ## # to
  ## doAssert PositionsIndex.A1.ord==0,
  ##    expectMsg(errorMsg("Invalid ord for "&($PositionsIndex.A1)), $PositionsIndex.A1.ord, "0")
  ##```
  doAssert value==ans,
    expectMsg(errorMsg("Invalid ord for "&($value)), $value, $ans)

template test_indPos(ans, value: untyped): untyped=
  ## template should produce something like
  ## ```nim
  ## # from
  ## test_indPos(PositionsIndex.A1, 0)
  ## # to
  ## doAssert IndexPositions[0] == PositionsIndex.A1
  ##    expectMsg(errorMsg("Invalid value at index "&($0)), $IndexPositions[0], PositionsIndex.A1)
  ##```
  doAssert IndexPositions[value] == ans,
    expectMsg(errorMsg("Invalid value at index "&($value)), $IndexPositions[value], $ans)



when isMainModule:
  const
    pawn_bb = 0b0000000000000000000000000000000000000000000000001111111100000000u64
    rand_01 = 0b1010111010011101011011010101011101010110010110101011011000111011u64
    rand_02 = 0b0000000000000000000000000000000011111111000000000000000000000000u64
    rand_03 = 0b0000000000000000000000000000000001010110000000000000000000000000u64
    white_P = 0b0000000000000000000000000000000000000000000000001111111100000000u64
    white_R = 0b0000000000000000000000000000000000000000000000000000000010000001u64
    white_N = 0b0000000000000000000000000000000000000000000000000000000001000010u64
    white_B = 0b0000000000000000000000000000000000000000000000000000000000100100u64
    white_Q = 0b0000000000000000000000000000000000000000000000000000000000001000u64
    white_K = 0b0000000000000000000000000000000000000000000000000000000000010000u64
    black_p = 0b0000000011111111000000000000000000000000000000000000000000000000u64
    black_r = 0b1000000100000000000000000000000000000000000000000000000000000000u64
    black_n = 0b0100001000000000000000000000000000000000000000000000000000000000u64
    black_b = 0b0010010000000000000000000000000000000000000000000000000000000000u64
    black_q = 0b0000100000000000000000000000000000000000000000000000000000000000u64
    black_k = 0b0001000000000000000000000000000000000000000000000000000000000000u64
    white_pieces = 0b0000000000000000000000000000000000000000000000001111111111111111u64
    black_pieces = 0b1111111111111111000000000000000000000000000000000000000000000000u64
    all_pieces   = 0b1111111111111111000000000000000000000000000000001111111111111111u64




  var
    test_pretty = initTable[Bitboard, string]()
    default_p = [0u64, 0u64, 0u64, 0u64, 0u64, 0u64] 

  test_pretty = {
    pawn_bb: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0""",
    rand_01: """ 0 1 1 1 0 1 0 1
 1 0 1 1 1 0 0 1
 1 0 1 1 0 1 1 0
 1 1 1 0 1 0 1 0
 0 1 1 0 1 0 1 0
 0 1 0 1 1 0 1 0
 0 1 1 0 1 1 0 1
 1 1 0 1 1 1 0 0""",
    rand_02: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    rand_03: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 1 1 0 1 0 1 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    white_P: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0""",
    white_R: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 0 0 0 0 0 0 1""",
    white_N: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 1 0 0 0 0 1 0""",
    white_B: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 1 0 0 1 0 0""",
    white_Q: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 1 0 0 0 0""",
    white_K: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 1 0 0 0""",
    black_p: """ 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    black_r: """ 1 0 0 0 0 0 0 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    black_n: """ 0 1 0 0 0 0 1 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    black_b: """ 0 0 1 0 0 1 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    black_q: """ 0 0 0 1 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    black_k: """ 0 0 0 0 1 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    white_pieces: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 1 1 1 1 1 1 1 1""",
    black_pieces: """ 1 1 1 1 1 1 1 1
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    all_pieces: """ 1 1 1 1 1 1 1 1
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 1 1 1 1 1 1 1 1"""
  }.toTable

  let
    cboard = ChessBoard()

  # Testing index of the chessboard
  echo infoMsg("Check the default value the chessboard initializes to")
  assertVal(cboard.getBlackPieceArr, default_p, "Wrong initialization of black pieces")
  assertVal(cboard.getWhitePieceArr, default_p, "Wrong initialization of white pieces")

  doAssert cboard.getWhitePieceArr is array[WhitePawn..WhiteKing, Bitboard],
    expectMsg(errorMsg("white piece array is not of the correct type"),
              $cboard.getWhitePieceArr.type, "array[0..5, Bitboard]")
  doAssert cboard.getBlackPieceArr is array[BlackPawn..BlackKing, Bitboard],
    expectMsg(errorMsg("black piece array is not of the correct type"),
              $cboard.getBlackPieceArr.type, "array[6..11, Bitboard]")
  echo passMsg()

  cboard.init()
  # Test the initialization
  echo infoMsg("Check that the initialization function works properly")
  assertVal(cboard.getWhitePieceArr[WhiteKing]  ,white_K, "White king not initialized properly")
  assertVal(cboard.getWhitePieceArr[WhiteQueen] ,white_Q, "White queen not initialized properly")
  assertVal(cboard.getWhitePieceArr[WhiteBishop],white_B, "White bishop not initialized properly")
  assertVal(cboard.getWhitePieceArr[WhiteKnight],white_N, "White knight not initialized properly")
  assertVal(cboard.getWhitePieceArr[WhiteRook]  ,white_R, "White rook not initialized properly")
  assertVal(cboard.getWhitePieceArr[WhitePawn]  ,white_P, "White pawn not initialized properly")

  assertVal(cboard.getBlackPieceArr[BlackKing]  ,black_k, "black king not initialized properly")
  assertVal(cboard.getBlackPieceArr[BlackQueen] ,black_q, "black queen not initialized properly")
  assertVal(cboard.getBlackPieceArr[BlackBishop],black_b, "black bishop not initialized properly")
  assertVal(cboard.getBlackPieceArr[BlackKnight],black_n, "black knight not initialized properly")
  assertVal(cboard.getBlackPieceArr[BlackRook]  ,black_r, "black rook not initialized properly")
  assertVal(cboard.getBlackPieceArr[BlackPawn]  ,black_p, "black pawn not initialized properly")
  echo passMsg()

  # Testing helper functions
  echo infoMsg("Testing calcRank and calcFile")
  assertVal(calcRank(A1), RANK_1, "Invalid rank for A1")
  assertVal(calcRank(B1), RANK_1, "Invalid rank for B1")
  assertVal(calcRank(C1), RANK_1, "Invalid rank for C1")
  assertVal(calcRank(E1), RANK_1, "Invalid rank for E1")
  assertVal(calcRank(G1), RANK_1, "Invalid rank for G1")
  assertVal(calcRank(H1), RANK_1, "Invalid rank for H1")
  assertVal(calcRank(A2), RANK_2, "Invalid rank for A2")
  assertVal(calcRank(B2), RANK_2, "Invalid rank for B2")
  assertVal(calcRank(C2), RANK_2, "Invalid rank for C2")
  assertVal(calcRank(E2), RANK_2, "Invalid rank for E2")
  assertVal(calcRank(G2), RANK_2, "Invalid rank for G2")
  assertVal(calcRank(H2), RANK_2, "Invalid rank for H2")
  assertVal(calcRank(A4), RANK_4, "Invalid rank for A4")
  assertVal(calcRank(B4), RANK_4, "Invalid rank for B4")
  assertVal(calcRank(C4), RANK_4, "Invalid rank for C4")
  assertVal(calcRank(E4), RANK_4, "Invalid rank for E4")
  assertVal(calcRank(G4), RANK_4, "Invalid rank for G4")
  assertVal(calcRank(H4), RANK_4, "Invalid rank for H4")
  assertVal(calcRank(A6), RANK_6, "Invalid rank for A6")
  assertVal(calcRank(B6), RANK_6, "Invalid rank for B6")
  assertVal(calcRank(C6), RANK_6, "Invalid rank for C6")
  assertVal(calcRank(E6), RANK_6, "Invalid rank for E6")
  assertVal(calcRank(G6), RANK_6, "Invalid rank for G6")
  assertVal(calcRank(H6), RANK_6, "Invalid rank for H6")
  assertVal(calcRank(A8), RANK_8, "Invalid rank for A8")
  assertVal(calcRank(B8), RANK_8, "Invalid rank for B8")
  assertVal(calcRank(C8), RANK_8, "Invalid rank for C8")
  assertVal(calcRank(E8), RANK_8, "Invalid rank for E8")
  assertVal(calcRank(G8), RANK_8, "Invalid rank for G8")
  assertVal(calcRank(H8), RANK_8, "Invalid rank for H8")
  assertVal(calcFile(A1), FILE_1, "Invalid file for A1")
  assertVal(calcFile(C1), FILE_3, "Invalid file for C1")
  assertVal(calcFile(E1), FILE_5, "Invalid file for E1")
  assertVal(calcFile(G1), FILE_7, "Invalid file for G1")
  assertVal(calcFile(H1), FILE_8, "Invalid file for H1")
  assertVal(calcFile(A2), FILE_1, "Invalid file for A2")
  assertVal(calcFile(B2), FILE_2, "Invalid file for B2")
  assertVal(calcFile(C2), FILE_3, "Invalid file for C2")
  assertVal(calcFile(E2), FILE_5, "Invalid file for E2")
  assertVal(calcFile(G2), FILE_7, "Invalid file for G2")
  assertVal(calcFile(H2), FILE_8, "Invalid file for H2")
  assertVal(calcFile(A4), FILE_1, "Invalid file for A4")
  assertVal(calcFile(B4), FILE_2, "Invalid file for B4")
  assertVal(calcFile(C4), FILE_3, "Invalid file for C4")
  assertVal(calcFile(E4), FILE_5, "Invalid file for E4")
  assertVal(calcFile(G4), FILE_7, "Invalid file for G4")
  assertVal(calcFile(H4), FILE_8, "Invalid file for H4")
  assertVal(calcFile(A6), FILE_1, "Invalid file for A6")
  assertVal(calcFile(B6), FILE_2, "Invalid file for B6")
  assertVal(calcFile(C6), FILE_3, "Invalid file for C6")
  assertVal(calcFile(E6), FILE_5, "Invalid file for E6")
  assertVal(calcFile(G6), FILE_7, "Invalid file for G6")
  assertVal(calcFile(H6), FILE_8, "Invalid file for H6")
  assertVal(calcFile(A8), FILE_1, "Invalid file for A8")
  assertVal(calcFile(B8), FILE_2, "Invalid file for B8")
  assertVal(calcFile(C8), FILE_3, "Invalid file for C8")
  assertVal(calcFile(E8), FILE_5, "Invalid file for E8")
  assertVal(calcFile(G7), FILE_7, "Invalid file for G8")
  assertVal(calcFile(H8), FILE_8, "Invalid file for H8")
  echo passMsg()

  # Test chessboard methods
  echo infoMsg("Testing chess board methods")
  assertVal(cboard.getWhitePieces, white_pieces, "wrong value for initial white positions")
  assertVal(cboard.getBlackPieces, black_pieces, "wrong value for initial black positions")
  assertVal(cboard.getAllPieces,   all_pieces,   "wrong value for initial positions")
  echo passMsg()

  # Checks the pretty function gives correct output
  echo infoMsg("Check that `pretty` function produces the correct output")
  assertVal(prettyBitboard(pawn_bb), test_pretty[pawn_bb], "Err in `pretty`")
  assertVal(prettyBitboard(rand_01), test_pretty[rand_01], "Err in `pretty`")
  assertVal(prettyBitboard(rand_02), test_pretty[rand_02], "Err in `pretty`")
  assertVal(prettyBitboard(rand_03), test_pretty[rand_03], "Err in `pretty`")
  # for board pieces
  assertVal(prettyBitboard(white_P), test_pretty[white_P], "Wrong representation for white pawn")
  assertVal(prettyBitboard(white_R), test_pretty[white_R], "Wrong representation for white rook")
  assertVal(prettyBitboard(white_N), test_pretty[white_N], "Wrong representation for white knight")
  assertVal(prettyBitboard(white_B), test_pretty[white_B], "Wrong representation for white bishop")
  assertVal(prettyBitboard(white_Q), test_pretty[white_Q], "Wrong representation for white queen")
  assertVal(prettyBitboard(white_K), test_pretty[white_K], "Wrong representation for white king")
  assertVal(prettyBitboard(black_p), test_pretty[black_p], "Wrong representation for black pawn")
  assertVal(prettyBitboard(black_r), test_pretty[black_r], "Wrong representation for black rook")
  assertVal(prettyBitboard(black_n), test_pretty[black_n], "Wrong representation for black knight")
  assertVal(prettyBitboard(black_b), test_pretty[black_b], "Wrong representation for black bishop")
  assertVal(prettyBitboard(black_q), test_pretty[black_q], "Wrong representation for black queen")
  assertVal(prettyBitboard(black_k), test_pretty[black_k], "Wrong representation for black king")
  assertVal(prettyBitboard(white_pieces), test_pretty[white_pieces],"Wrong representation for white pieces")
  assertVal(prettyBitboard(black_pieces), test_pretty[black_pieces],"Wrong representation for black pieces")
  assertVal(prettyBitboard(all_pieces), test_pretty[all_pieces],"Wrong representation for all pieces")
  echo passMsg()

  # Checks anding of bitboards
  echo infoMsg("Check that `and`ing bitboards work")
  assertVal((rand_01 and rand_02), rand_03, "Err `and`ing")
  echo passMsg()

  # Testing `PositionIndex`
  echo infoMsg("Testing `PositionsIndex`")
  test_posInd(PositionsIndex.A1.ord, 0)
  test_posInd(PositionsIndex.B1.ord, 1)
  test_posInd(PositionsIndex.C1.ord, 2)
  test_posInd(PositionsIndex.D1.ord, 3)
  test_posInd(PositionsIndex.E1.ord, 4)
  test_posInd(PositionsIndex.F1.ord, 5)
  test_posInd(PositionsIndex.G1.ord, 6)
  test_posInd(PositionsIndex.H1.ord, 7)
  test_posInd(PositionsIndex.A2.ord, 8)
  test_posInd(PositionsIndex.B2.ord, 9)
  test_posInd(PositionsIndex.C2.ord,10)
  test_posInd(PositionsIndex.D2.ord,11)
  test_posInd(PositionsIndex.E2.ord,12)
  test_posInd(PositionsIndex.F2.ord,13)
  test_posInd(PositionsIndex.G2.ord,14)
  test_posInd(PositionsIndex.H2.ord,15) 
  test_posInd(PositionsIndex.A3.ord,16)
  test_posInd(PositionsIndex.B3.ord,17)
  test_posInd(PositionsIndex.C3.ord,18)
  test_posInd(PositionsIndex.D3.ord,19)
  test_posInd(PositionsIndex.E3.ord,20)
  test_posInd(PositionsIndex.F3.ord,21)
  test_posInd(PositionsIndex.G3.ord,22)
  test_posInd(PositionsIndex.H3.ord,23)
  test_posInd(PositionsIndex.A4.ord,24)
  test_posInd(PositionsIndex.B4.ord,25)
  test_posInd(PositionsIndex.C4.ord,26)
  test_posInd(PositionsIndex.D4.ord,27)
  test_posInd(PositionsIndex.E4.ord,28)
  test_posInd(PositionsIndex.F4.ord,29)
  test_posInd(PositionsIndex.G4.ord,30)
  test_posInd(PositionsIndex.H4.ord,31)
  test_posInd(PositionsIndex.A5.ord,32)
  test_posInd(PositionsIndex.B5.ord,33)
  test_posInd(PositionsIndex.C5.ord,34)
  test_posInd(PositionsIndex.D5.ord,35)
  test_posInd(PositionsIndex.E5.ord,36)
  test_posInd(PositionsIndex.F5.ord,37)
  test_posInd(PositionsIndex.G5.ord,38)
  test_posInd(PositionsIndex.H5.ord,39)
  test_posInd(PositionsIndex.A6.ord,40)
  test_posInd(PositionsIndex.B6.ord,41)
  test_posInd(PositionsIndex.C6.ord,42)
  test_posInd(PositionsIndex.D6.ord,43)
  test_posInd(PositionsIndex.E6.ord,44)
  test_posInd(PositionsIndex.F6.ord,45)
  test_posInd(PositionsIndex.G6.ord,46)
  test_posInd(PositionsIndex.H6.ord,47)
  test_posInd(PositionsIndex.A7.ord,48)
  test_posInd(PositionsIndex.B7.ord,49)
  test_posInd(PositionsIndex.C7.ord,50)
  test_posInd(PositionsIndex.D7.ord,51)
  test_posInd(PositionsIndex.E7.ord,52)
  test_posInd(PositionsIndex.F7.ord,53)
  test_posInd(PositionsIndex.G7.ord,54)
  test_posInd(PositionsIndex.H7.ord,55) 
  test_posInd(PositionsIndex.A8.ord,56)
  test_posInd(PositionsIndex.B8.ord,57)
  test_posInd(PositionsIndex.C8.ord,58)
  test_posInd(PositionsIndex.D8.ord,59)
  test_posInd(PositionsIndex.E8.ord,60)
  test_posInd(PositionsIndex.F8.ord,61)
  test_posInd(PositionsIndex.G8.ord,62)
  test_posInd(PositionsIndex.H8.ord,63)
  echo passMsg()

  echo infoMsg("Testing `IndexPositions` array")
  test_indPos(PositionsIndex.A1, 0)
  test_indPos(PositionsIndex.B1, 1)
  test_indPos(PositionsIndex.C1, 2)
  test_indPos(PositionsIndex.D1, 3)
  test_indPos(PositionsIndex.E1, 4)
  test_indPos(PositionsIndex.F1, 5)
  test_indPos(PositionsIndex.G1, 6)
  test_indPos(PositionsIndex.H1, 7)
  test_indPos(PositionsIndex.A2, 8)
  test_indPos(PositionsIndex.B2, 9)
  test_indPos(PositionsIndex.C2,10)
  test_indPos(PositionsIndex.D2,11)
  test_indPos(PositionsIndex.E2,12)
  test_indPos(PositionsIndex.F2,13)
  test_indPos(PositionsIndex.G2,14)
  test_indPos(PositionsIndex.H2,15) 
  test_indPos(PositionsIndex.A3,16)
  test_indPos(PositionsIndex.B3,17)
  test_indPos(PositionsIndex.C3,18)
  test_indPos(PositionsIndex.D3,19)
  test_indPos(PositionsIndex.E3,20)
  test_indPos(PositionsIndex.F3,21)
  test_indPos(PositionsIndex.G3,22)
  test_indPos(PositionsIndex.H3,23)
  test_indPos(PositionsIndex.A4,24)
  test_indPos(PositionsIndex.B4,25)
  test_indPos(PositionsIndex.C4,26)
  test_indPos(PositionsIndex.D4,27)
  test_indPos(PositionsIndex.E4,28)
  test_indPos(PositionsIndex.F4,29)
  test_indPos(PositionsIndex.G4,30)
  test_indPos(PositionsIndex.H4,31)
  test_indPos(PositionsIndex.A5,32)
  test_indPos(PositionsIndex.B5,33)
  test_indPos(PositionsIndex.C5,34)
  test_indPos(PositionsIndex.D5,35)
  test_indPos(PositionsIndex.E5,36)
  test_indPos(PositionsIndex.F5,37)
  test_indPos(PositionsIndex.G5,38)
  test_indPos(PositionsIndex.H5,39)
  test_indPos(PositionsIndex.A6,40)
  test_indPos(PositionsIndex.B6,41)
  test_indPos(PositionsIndex.C6,42)
  test_indPos(PositionsIndex.D6,43)
  test_indPos(PositionsIndex.E6,44)
  test_indPos(PositionsIndex.F6,45)
  test_indPos(PositionsIndex.G6,46)
  test_indPos(PositionsIndex.H6,47)
  test_indPos(PositionsIndex.A7,48)
  test_indPos(PositionsIndex.B7,49)
  test_indPos(PositionsIndex.C7,50)
  test_indPos(PositionsIndex.D7,51)
  test_indPos(PositionsIndex.E7,52)
  test_indPos(PositionsIndex.F7,53)
  test_indPos(PositionsIndex.G7,54)
  test_indPos(PositionsIndex.H7,55) 
  test_indPos(PositionsIndex.A8,56)
  test_indPos(PositionsIndex.B8,57)
  test_indPos(PositionsIndex.C8,58)
  test_indPos(PositionsIndex.D8,59)
  test_indPos(PositionsIndex.E8,60)
  test_indPos(PositionsIndex.F8,61)
  test_indPos(PositionsIndex.G8,62)
  test_indPos(PositionsIndex.H8,63)
  echo passMsg()

