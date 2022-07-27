
## Types and functions for move generation
##
import util, board, move, lookup
from bitops import bitand

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

proc generateKingMoveList(board: BoardState, family: Family): MoveList=
  let
    friendlyBB = board.getFriendlyBitboard(family)
  var
    attackBB: Bitboard 
    kingBB = board.getBitboard(family, King)
    fromPos: BoardPosition
    tmp_move: Move
    captured_piece: Pieces
  # TODO the can only be one king in board
  # generate normal moves
  while kingBB!=0:
    # last bit is removed from `kingBB`, its position in rank-file mapping is also returned
    # the `fromPos` is the `from` field for the next set of moves
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
  for castleRight in board.getCastlingRights(family):
    # for castling the only fields need is the moving piece as king and the type of castling
    if castleRight==No_Castling: continue
    else:
      case family
      of White:
        tmp_move = Move(0)
                    .setCastlingField(castleRight)
                    .setMovingPieceField(WhiteKing)
      of Black:
        tmp_move = Move(0)
                    .setCastlingField(castleRight)
                    .setMovingPieceField(BlackKing)
      result.add(tmp_move)


  
proc genPsuedoLegalMoveList*(board: BoardState, family: Family): MoveList=
  var moves: MoveList
