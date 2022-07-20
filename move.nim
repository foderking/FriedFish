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
  ##          |     |     |   |  | |          `PromotionField`
  ##          |     |     |   |  | +> (2 bits) Representing which piece to promote to.
  ##          |     |     |   |  | .          `CastlingField`
  ##          |     |     |   |  +--> (2 bits) Representing the castling status
  ##          |     |     |   |  . .          `MovingPieceField`   
  ##          |     |     |   +-----> (3 bits) Representing the captured piece
  ##          |     |     |   .  . .          `MovingPieceField
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
  ## since the orignal mapping from `Pieces` is Pawn=0, Rook=1, Bishop=2.. and Pawn is not valid
  PromotionField* = Rook..Queen

  ## Encodes all possible values of castling field within two bits
  ## Only three possible options of no castling, queen and king side castling
  ## no castling = 00, queen side = 01, king side  = 2 or 0b10
  CastlingField*  = enum
    No_Castling, QueenSide_Castling, KingSide_Castling

  ## Ecnodes the p
  ##
  CapturedPieceField* = ValidPiece

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
  promotionField_mask*     = 0xFFFFFFFFFFFFFFFC#'i32
  castlingField_mask*      = 0xFFFFFFFFFFFFFFF3#'i32
  movingPieceField_mask*   = 0xFFFFFFFFFFFFF87F#'i32
  capturedPieceField_mask* = 0xFFFFFFFFFFFE07FF#'i32
  locationToField_mask*    = 0xFFFFFFFFFF81FFFF#'i32
  locationFromField_mask*  = 0xFFFFFFFFE07FFFFF#'i32

  PromotionFieldLookup* = [
    Rook, Bishop, Knight, Queen 
  ]
  CastlingFieldLookup* = [
    No_Castling, QueenSide_Castling, KingSide_Castling
  ]
  MovingPieceFieldLookup* = [
    Pawn, Rook, Bishop, Knight, Queen, King 
  ]

##
## Generic method for setting fields in a `Move`
## `move`      : The move to be modified
## `field`     : The field to be set. As of 20/7/22 there are 6 fields that can be set. eg `CastlingField`
## `field_mask`: A number with all bits set apart from the ones corresponding the the field.
## `bit_offset`: Distance of the last bit of the field  from the last bit in the move
##                (How many bits do you have to shift a number representing the field to reach its position\
##                eg `CastlingField` has to be shifted by 2 bits to get to its location in the move)
## `field_offset` : Some fields dont have 1<->1 mapping in the original type, so a number has ...
##                  to be substracted from its orindal
##                  Eg: for `PromotionField` only 4 types from `ValidPiece` are used `Pawn` is not included,
##                  so you have to offset it by one to make the type start at `Rook` instead of `Pawn`
## returns a new move with the field set
proc setField[T](move: Move, field: T, field_mask: int32, bit_offset: int, field_offset = 0): Move{.inline}=
  let
    tmp = bitand(move, field_mask)        ## \
                      ## The field mask is anded with the move to clear all bits corresponding to the field
    value = int32(field.ord-field_offset) ## \
                      ## The numeric representation of the field (with an optional offset)
  return bitor(tmp, value shl bit_offset) ## \
                      ## The numeric representation is shifted to its position and merged with the move

## 
## Generic method for getting a particular field from a move
## `move`         : The move which you want to get the field from.
## `field_mask`   : A number with all bits set apart from the ones corresponding the the field.
## `bit_offset`   : Distance of the last bit of the field  from the last bit in the move
## `field_lookup` : An array mapping the numeric value of a move back to the actual move itself
## returns the extracted field
proc getField[T](move: Move, field_mask: int32, bit_offset: int, field_lookup: openArray[T]): T{.inline}=
  let value = bitand(move, bitnot(field_mask)) ## \
                            ## Gets the value of the field by anding the inverse of its mask with the move
  return field_lookup[value]                   ## \
                            ## The actual type of the field is gotten from its numeric rep from the lookup

proc setPromotionField*(move: Move, field: PromotionField): Move{.inline}=
  # Clear bits used by the field
  let new_move = bitand(move, promotionField_mask)
  # merge the field to the move
  return bitor(new_move, int32(field.ord-1)) # 1 is subtracted because the type starts from `Rook`

proc getPromotionField*(move: Move): PromotionField{.inline}=
  ## extracts the field from move; returns the type since they're arranged by the type in lookup
  return PromotionFieldLookup[bitand(move, bitnot(promotionField_mask))]


proc setCastlingField*(move: Move, field: CastlingField): Move{.inline}=
  # Clear bits used by the field
  let new_move = bitand(move, castlingField_mask)
  # merge the field to the move
  return bitor(new_move, int32(field.ord) shl 2)

proc getCastlingField*(move: Move): CastlingField{.inline}=
  ## extracts the field from move; returns the type since they're arranged by the type in lookup
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
