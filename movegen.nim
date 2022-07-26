
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

proc genPsuedoLegalMoveList*(board: BoardState, family: Family): MoveList=
  var moves: MoveList
  
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


