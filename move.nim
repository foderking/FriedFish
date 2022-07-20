##
## Implements functionality for move generation
##
## references
##  - [zephyr chess engine project report]()
##
import util
import bitops

type
  ## `Move` Completey encodes all information of a move in a 32 bit number
  ## 00000000000000000000000000000000
  ## xxxxxxxxx|~~~~~|~~~~~|~~~|~~|~|~ 
  ## .........23....17....11..7..4.2.
  ##          |     |     |   |  | +> (2 bits) Representing which piece to promote to.
  ##          |     |     |   |  | .  options: `PromotionField`, masks: `promotionField_mask`.
  ##          |     |     |   |  +--> (2 bits) Representing the castling status
  ##          |     |     |   |  . .
  ##          |     |     |   +-----> (3 bits) Representing the captured piece
  ##          |     |     |   .  . .
  ##          |     |     +---------> (4 bits) Representing the piece making the move
  ##          |     |     .   .  . .
  ##          |     +---------------> (6 bits) Representing the location to move to in index
  ##          |     .     .   .  . . 
  ##          +---------------------> (6 bits) Representing the location to move from in index
  ##
  Move* = int32

  ## Encodes all posible value in promotion field within two bits
  ## Rook = 0, Bishop = 1 or 0b01, Knight = 2 or 0b10, Queen = 3 or 0b11
  ## Note: In implementation 1 is subtract from the ordinal..
  ## since the orignal mapping from `Pieces` is Pawn=0, Rook=1, Bishop=2.. etc 
  PromotionField* = Rook..Queen

  ## Encodes all possible values of castling field within two bits
  ## Only three possible options of no castling, queen and king side castling
  ## Queen = 00, King = 01, No castling  = 2 or 0b10
  ## Note: In implementation 4 is subtract from the ordinal..
  ## since original mapping from Pieces is Queen=4, King=5, NULL_PIECE=6
  CastlingField*  = Queen..NULL_PIECE

  ## Ecnodes the p

  ## Encodes all possible moving pieces within 4 bits
  ## Pawn=0b0000, Rook=0b0001, Bishop=0b0010, Knight=0b0011, Queen=0b0100, King=0b0101
  ## the leftmost bit determines if it is black or white
  MovingPieceField* = ValidPiece

  ## Encodes the location to move to in little endian rank-file mapping
  ## all possible values are from 0-63
  LocationToField* =  BoardIndex

  ## Encodes the location to move from in little endian rank-file mapping
  ## all possible values are from 0-63
  LocationFromField* =  BoardIndex

const
  promotionField_mask*     = 0xFFFFFFFFFFFFFFFC
  castlingField_mask*      = 0xFFFFFFFFFFFFFFF3
  movingPieceField_mask*   = 0xFFFFFFFFFFFFF87F
  capturedPieceField_mask* = 0xFFFFFFFFFFFE07FF
  locationToField_mask*    = 0xFFFFFFFFFF81FFFF
  locationFromField_mask*  = 0xFFFFFFFFE07FFFFF

  PromotionFieldLookup* = [
    Rook, Bishop, Knight, Queen 
  ]
  CastlingFieldLookup* = [
    Queen, King, NULL_PIECE
  ]
  MovingPieceFieldLookup* = [
    Pawn, Rook, Bishop, Knight, Queen, King 
  ]

proc setPromotionField*(move: Move, field: PromotionField): Move{.inline}=
  let new_move = bitand(move, promotionField_mask)
  return bitor(new_move, int32(field.ord-1))

proc getPromotionField*(move: Move): PromotionField{.inline}=
  return PromotionFieldLookup[bitand(move, bitnot(promotionField_mask))]

proc setCastlingField*(move: Move, field: CastlingField): Move{.inline}=
  let new_move = bitand(move, castlingField_mask)
  return bitor(new_move, int32(field.ord-4) shl 2)

proc getCastlingField*(move: Move): CastlingField{.inline}=
  return CastlingFieldLookup[bitand(move, bitnot(castlingField_mask)) shr 2]

proc setMovingPieceField*(move: Move, field: MovingPieceField): Move{.inline}=
  let new_move = bitand(move, movingPieceField_mask)
  return bitor(new_move, int32(field.ord) shl 7)

proc getMovingPieceField*(move: Move): MovingPieceField{.inline}=
  return MovingPieceFieldLookup[bitand(move, bitnot(movingPieceField_mask)) shr 7]

proc setLocationToField*(move: Move, field: LocationToField): Move{.inline}=
  let new_move = bitand(move, locationToField_mask)
  return bitor(new_move, int32(field.ord) shl 17)

proc getLocationToPieceField*(move: Move): LocationToField{.inline}=
  return BoardPositionLookup[bitand(move, bitnot(locationToField_mask)) shr 17]

proc setLocationFromField*(move: Move, field: LocationFromField): Move{.inline}=
  let new_move = bitand(move, locationFromField_mask)
  return bitor(new_move, int32(field.ord) shl 23)

proc getLocationFromPieceField*(move: Move): LocationToField{.inline}=
  return BoardPositionLookup[bitand(move, bitnot(locationFromField_mask)) shr 23]
