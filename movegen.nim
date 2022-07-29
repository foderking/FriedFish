
## Types and functions for move generation
##
import util, board, move, lookup
from bitops import bitand, bitor

type
  MoveList = seq[Move]


iterator yieldSetBits(bitboard: Bitboard): BoardPosition=
  ## An iterator that returns all positions in bitboard where the bit is set (`1`)
  ## similar implementation to popcount
  var tmp = bitboard
  while tmp!=0:
    yield bitScanForward(tmp)
    tmp &= tmp-1

proc popAndGetLastBit(number: Bitboard): (Bitboard, BoardPosition)=
  return (bitand(number, number-1), bitScanForward(number))

proc generateKnightMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
  var
    attackBB: Bitboard 
    knightBB = board.getBitboard(family, Knight)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces

  while knightBB!=0:
    # last bit is removed from `knightBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
    (knightBB, fromPos) = popAndGetLastBit(knightBB)
    # get bitboard for attacks by knight at that position
    attackBB = board.lookup.getKnightMoves(fromPos, friendlyBB)
    # each set bit in attackBB represents a `to` field for a new move
    for toPos in yieldSetBits(attackBB):
      # get the piece being captured at `toPos` (if any)
      captured_piece = board.getEnemyPieceAtLocation(toPos, family)
      # create a new move
      tmp_move = setMainFields(Move(0), getFullPiece(Knight, family), captured_piece, toPos, fromPos)
      result.add(tmp_move)

proc generateRookMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
    enemyBB    = board.getEnemyBitboard(family)
  var
    attackBB: Bitboard 
    rookBB = board.getBitboard(family, Rook)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces

  while rookBB!=0:
    # last bit is removed from `rookBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
    (rookBB, fromPos) = popAndGetLastBit(rookBB)
    # get bitboard for attacks by rook at that position
    attackBB = board.lookup.getRookMoves(fromPos, friendlyBB, enemyBB)
    # each set bit in attackBB represents a `to` field for a new move
    for toPos in yieldSetBits(attackBB):
      # get the piece being captured at `toPos` (if any)
      captured_piece = board.getEnemyPieceAtLocation(toPos, family)
      # create a new move
      tmp_move = setMainFields(Move(0), getFullPiece(Rook, family), captured_piece, toPos, fromPos)
      result.add(tmp_move)

proc generateBishopMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
    enemyBB    = board.getEnemyBitboard(family)
  var
    attackBB: Bitboard 
    bishopBB = board.getBitboard(family, Bishop)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces

  while bishopBB!=0:
    # last bit is removed from `bishopBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
    (bishopBB, fromPos) = popAndGetLastBit(bishopBB)
    # get bitboard for attacks by bishop at that position
    attackBB = board.lookup.getBishopMoves(fromPos, friendlyBB, enemyBB)
    # each set bit in attackBB represents a `to` field for a new move
    for toPos in yieldSetBits(attackBB):
      # get the piece being captured at `toPos` (if any)
      captured_piece = board.getEnemyPieceAtLocation(toPos, family)
      # create a new move
      tmp_move = setMainFields(Move(0), getFullPiece(Bishop, family), captured_piece, toPos, fromPos)
      result.add(tmp_move)

proc generateQueenMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
    enemyBB    = board.getEnemyBitboard(family)
  var
    attackBB: Bitboard 
    queenBB = board.getBitboard(family, Queen)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces

  while queenBB!=0:
    # last bit is removed from `queenBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
    (queenBB, fromPos) = popAndGetLastBit(queenBB)
    # get bitboard for attacks by queen at that position
    attackBB = board.lookup.getQueenMoves(fromPos, friendlyBB, enemyBB)
    # each set bit in attackBB represents a `to` field for a new move
    for toPos in yieldSetBits(attackBB):
      # get the piece being captured at `toPos` (if any)
      captured_piece = board.getEnemyPieceAtLocation(toPos, family)
      # create a new move
      tmp_move = setMainFields(Move(0), getFullPiece(Queen, family), captured_piece, toPos, fromPos)
      result.add(tmp_move)

proc getLeftEnPassantTarget*(square: ValidBoardPosition, family: Family): ValidBoardPosition=
  ## The location to the left the pawn moves to after en passant
  checkCondition(isEnPassant(square, family), "position needs to be enpassant")
  case family
  of White:
    return BoardPositionLookup[square.ord shl 7]
  of Black:
    return BoardPositionLookup[square.ord shr 7]

proc getLeftEnPassantCapture*(square: ValidBoardPosition, family: Family): ValidBoardPosition=
  ## The location of the piece the pawn is capturing to the left during en passant
  checkCondition(isEnPassant(square, family), "position needs to be enpassant")
  case family
  of White:
    return BoardPositionLookup[square.ord shr 1]
  of Black:
    return BoardPositionLookup[square.ord shl 1]

proc getRightEnPassantTarget*(square: ValidBoardPosition, family: Family): ValidBoardPosition=
  ## The locationto the right the pawn moves to after en passant
  checkCondition(isEnPassant(square, family), "position needs to be enpassant")
  case family
  of White:
    return BoardPositionLookup[square.ord shl 9]
  of Black:
    return BoardPositionLookup[square.ord shr 9]

proc getRightEnPassantCapture*(square: ValidBoardPosition, family: Family): ValidBoardPosition=
  ## The location of the piece the pawn is capturing to the right during en passant
  checkCondition(isEnPassant(square, family), "position needs to be enpassant")
  case family
  of White:
    return BoardPositionLookup[(square.ord) shl 1]
  of Black:
    return BoardPositionLookup[square.ord shr 1]

proc generatePawnMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
    enemyBB    = board.getEnemyBitboard(family)
  var
    attackBB: Bitboard 
    pawnBB = board.getBitboard(family, Pawn)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces

  while pawnBB!=0:
    # last bit is removed from `pawnBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
    (pawnBB, fromPos) = popAndGetLastBit(pawnBB)
    ## en passant
    if isEnPassant(fromPos, family):
      let
        leftT   = getLeftEnPassantTarget(fromPos, family)
        leftCap = getLeftEnPassantCapture(fromPos, family)
        rightT   = getRightEnPassantTarget(fromPos, family)
        rightCap = getRightEnPassantCapture(fromPos, family)
      if calcFile(fromPos)!=FILE_A and  board.getEnPassantSquare()==leftCap:
        tmp_move = setMainFields(Move(0), getFullPiece(Pawn, family), Pawn, leftT, fromPos)
      if calcFile(fromPos)!=FILE_H and  board.getEnPassantSquare()==rightCap:
        tmp_move = setMainFields(Move(0), getFullPiece(Pawn, family), Pawn, rightT, fromPos)

    # get bitboard for attacks by pawn at that position
    attackBB = board.lookup.getPawnMoves(fromPos, family, friendlyBB, enemyBB)
    # each set bit in attackBB represents a `to` field for a new move
    for toPos in yieldSetBits(attackBB):
      # get the piece being captured at `toPos` (if any)
      captured_piece = board.getEnemyPieceAtLocation(toPos, family)
      # create a new move
      tmp_move = setMainFields(Move(0), getFullPiece(Pawn, family), captured_piece, toPos, fromPos)
      ## pawn promotion
      if isPromotable(fromPos, family):
        # adds all the possible promotions
        for promoType in PromotionField:
          tmp_move = tmp_move.setPromotionField(promoType)
          result.add(tmp_move)
      else:
        result.add(tmp_move)

proc getSpaceBetween(castleType: CastlingField, family: Family): Bitboard=
  if castleType==KingSide_Castling:
    case family
    of Black:
      return bitor(1 shl F8.ord, 1 shl G8.ord)
    of White:
      return bitor(1 shl F1.ord, 1 shl G1.ord)
  elif castleType==QueenSide_Castling:
    case family
    of Black:
      return bitor(1 shl B8.ord, 1 shl C8.ord, 1 shl D8.ord)
    of White:
      return bitor(1 shl B1.ord, 1 shl C1.ord, 1 shl D1.ord)
  else: raiseAssert("Not valid castle type")

proc spaceBetweenAttacked(board: BoardState, castleType: CastlingField, family: Family): bool=
  if castleType==KingSide_Castling:
    case family
    of Black:
      return (board.squareUnderAttack(Black, F8) or board.squareUnderAttack(Black,G8) )
    of White:
      return (board.squareUnderAttack(White, F1) or board.squareUnderAttack(White,G1) )
  elif castleType==QueenSide_Castling:
    case family
    of Black:
      return (board.squareUnderAttack(Black, B8) or board.squareUnderAttack(Black,C8) or board.squareUnderAttack(Black,D8))
    of White:
      return (board.squareUnderAttack(White, B1) or board.squareUnderAttack(White,C1) or board.squareUnderAttack(White,D1))
  else: raiseAssert("Not valid castle type")


proc canCastle(board: BoardState, family: Family, caslteType: CastlingField): bool=
  ## For a king to be able to castle
  ## - The king side castling bit must be set in the board state (the king must not have moved)
  ## - The king must not be in check
  ## - There must be an empty space between the king and the rook and they must not be under attack
  checkCondition(caslteType!=No_Castling, "must be a valid castle type")
  let
    spaceBetweenEmpty = bitand(board.getAllPieces(), getSpaceBetween(caslteType, family))==0 

  return board.isKSC(family) and not board.spaceBetweenAttacked(caslteType, family) and 
         spaceBetweenEmpty   and not board.colorInCheck(family)



proc generateKingMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
  var
    attackBB: Bitboard 
    kingBB = board.getBitboard(family, King)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces
  # the can only be one king in board
  checkCondition(bitScanForward(kingBB)==bitScanReverse(kingBB), "there can only be one king")
  # generate normal moves
  (kingBB, fromPos) = popAndGetLastBit(kingBB)
  # get bitboard for attacks by king at that position
  attackBB = board.lookup.getKingMoves(fromPos, friendlyBB)
  # each set bit in attackBB represents a `to` field for a new move
  for toPos in yieldSetBits(attackBB):
    # get the piece being captured at `toPos` (if any)
    captured_piece = board.getEnemyPieceAtLocation(toPos, family)
    # create a new move
    tmp_move = setMainFields(Move(0), getFullPiece(King, family), captured_piece, toPos, fromPos)
    result.add(tmp_move)

proc generateCastlingMoveList(board: BoardState, family: Family): MoveList=
  var tmp_move: Move
  # castling
  if board.canCastle(family, KingSide_Castling):
        result.add(Move(0)
                    .setCastlingField(KingSide_Castling)
                    .setMovingPieceField(getFullPiece(King, family)))
  if board.canCastle(family, QueenSide_Castling):
        result.add(Move(0)
                    .setCastlingField(QueenSide_Castling)
                    .setMovingPieceField(getFullPiece(King,family)))

  
proc genPsuedoLegalMoveList*(board: BoardState): MoveList=
  var moves: MoveList
  let activePlayer = board.getSideToMove()
  result.add(generateBishopMoveList(board, activePlayer))
  result.add(generateKnightMoveList(board, activePlayer))
  result.add(generateRookMoveList(board, activePlayer))
  result.add(generateQueenMoveList(board, activePlayer))

  result.add(generateKingMoveList(board, activePlayer))
  result.add(generateCastlingMoveList(board, activePlayer))
  result.add(generatePawnMoveList(board, activePlayer))
