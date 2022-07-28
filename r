## Function and types relating to the board state
##
## references
##   [1] https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation#Definition
##   [2] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/physical.html
##   [3] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/rep.html
import re, bitops, strutils, strformat
from parseUtils import parseInt
from algorithm import reversed
import util, lookup
from move import CastlingField

let
  # regex patterns for fields in fen string
  pieces_re    = r"((?:[prbnkqPRBNKQ1-8]{1,8}\/){7}[prbnkqPRBNKQ1-8]{1,8})"
  side_re      = r"([wb])"
  castle_re    = r"(-|K?Q?k?q?)"
  enpassant_re = r"(-|[a-f][1-8])"
  halfmove_re  = r"(\d{1,2}|100)"
  move_re      = r"(\d+)"
  # regex of a valid fen string
  fen_re       = re(fmt"^{pieces_re} {side_re} {castle_re} {enpassant_re} {halfmove_re} {move_re}$")

type
  BoardState* = object
    ## [2] A lightwieght object representing the full state of the chess board
    ##
    ## TODO board*: MailBox ## In addition to bitboards, a mailbox state is added to aid move generation
    white: array[ValidPiece, Bitboard] ## Bitboard array for each white piece type (white pawns,rook etc)
    black: array[ValidPiece, Bitboard] ## Bitboard array for each black piece type (black knight, pawn etc)
    sideToMove: Family                  ## The side to make a move (white or black)
    castling_rights: CastleBits         ## Castling availabiliy in the board
    enPassant_square: range[-1..63]     ## \
    ## The position of the en passant target square of last move on the board
    ## A value of 0..63 represents the position on the board, a value of -1 means no en passant square
    half_moves: int      ## Number of half moves since last capture/pawn advance
    moves     : int      ## Number the full moves
    all_white : Bitboard ## Bitboard representing all white pieces, incrementally updated
    all_black : Bitboard ## Bitboard representing all black pieces, incrementally updated
    all_piece : Bitboard ## Bitboard representing all pieces, incrementally updated

    lookup*   : LookupTables ## preinitialized lookup table

  CastleBits = uint8 ## \
  ## CastleBits is a type that represent castling rights for the board state
  ## The last 4 bits represents the castling rights for both sides
  ## A value of 0 means that specific castling is allowed
  ## 0 0 0 0 1 0 1 1
  ## | | | | | | | +--> queen side castling for black (allowed in this example)
  ## | | | | | | +----> king side castling for black  (allowed in this example)
  ## | | | | | +------> queen side castling for white (not allowed in this example)
  ## | | | | + -------> king side castling for white  (allowed in this example)
  ## +----------------> first 4 bits irrelevant

proc fenValid*(fen_string: string): bool{.inline}=
  ## Determines if a fen string is valid
  return re.match(fen_string, fen_re)


proc parsePieces(this: var BoardState, index: var int, fen_string: string)=
  ## Parses the positions for the pieces in-place
  ## `this` is the board object modified in-place
  var
    tmp: array[1,string]
    s  : string
    location = 0
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re(fmt"{pieces_re} "), tmp, start=index)
  # pattern must be valid and must start at index
  checkCondition(rand!=(first: -1, last: 0) and rand.first==index, "Invalid pieces value")

  s       = tmp[0]
  index   = rand.last # index continues at next space
  let arr =  s.split('/').reversed # reverses the ranks so you can iterate in proper order

  for row in arr:
    for current in row:
      case current
      of 'p':
        this.black[Pawn]
            .setBit(location)
        #this.board[location] = BlackPawn
        location.inc
      of 'r':
        this.black[Rook]
            .setBit(location)
        location.inc
      of 'b':
        this.black[Bishop]
            .setBit(location)
        location.inc
      of 'n':
        this.black[Knight]
            .setBit(location)
        location.inc
      of 'q':
        this.black[Queen]
            .setBit(location)
        location.inc
      of 'k':
        this.black[King]
            .setBit(location)
        location.inc
      of 'P':
        this.white[Pawn]
            .setBit(location)
        location.inc
      of 'R':
        this.white[Rook]
            .setBit(location)
        location.inc
      of 'N':
        this.white[Knight]
            .setBit(location)
        location.inc
      of 'B':
        this.white[Bishop]
            .setBit(location)
        location.inc
      of 'Q':
        this.white[Queen]
            .setBit(location)
        location.inc
      of 'K':
        this.white[King]
            .setBit(location)
        location.inc
      elif current.isDigit:
        location += ($current).parseInt
      else  : raiseAssert("Error parsing pieces value")

proc parseSideToMove(index: var int, fen_string: string): Family=
  ## Returns the family making the next move
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  # pattern must be followed by space
  checkCondition(index+1<fen_string.len and fen_string[index+1]==' ', "Invalid sidetomove value")

  case fen_string[index]
  of 'w': result = White
  of 'b': result = Black
  else  : raiseAssert("Error parsing sidetomove value")

  index.inc

proc parseCastlingRights(index: var int, fen_string: string): CastleBits=
  ## Returns the castling rights for both players
  ## 0 0 0 0 1 0 1 1 0
  ## | | | | | | | | +->(0) q
  ## | | | | | | | +--->(1) k
  ## | | | | | | +----->(2) Q
  ## | | | | | +------->(3) K
  ## +-------> first 4 bits irrelevant
  var
    tmp: array[1, string]
    s  : string
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re(fmt"{castle_re} "), tmp, start=index)
  # pattern must be valid and must start at index
  checkCondition(rand.first==index and rand!=(first: -1, last: 0), "Invalid castling value")

  result = 0
  s = tmp[0]

  while s!="":
    case s[0]
    of '-':
      assert tmp[0].len==1
    of 'K':
      result.setBit(3)
    of 'Q':
      result.setBit(2)
    of 'k':
      result.setBit(1)
    of 'q':
      result.setBit(0)
    else  : raiseAssert("Error parsing castling value")
    s = s.substr(1)

  index = rand.last # index continues at next space

proc parseEnPassant(index: var int, fen_string: string): range[-1..63]=
  ## Returns the board index of enpassant square or -1 if there isn't
  var
    tmp: array[1, string]
    s  : string
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re(fmt"{enpassant_re} "), tmp, start=index)
  # pattern must be valid and must start at index
  checkCondition(rand.first==index and rand!=(first: -1, last: 0), "Invalid enpassant value")

  s    = tmp[0]
  index= rand.last# index continues at next space

  if s=="-": return -1
  else: return getBoardIndex(s[0], s[1])
    

proc parseHalfMove(index: var int, fen_string: string): int=
  ## Returns the value of the half-move
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  var ans: int
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re(fmt"{halfmove_re} "), start=index)
  # pattern must be valid and must start at index
  checkCondition(rand.first==index and rand!=(first: -1, last: 0), "Invalid halfmove value")
  
  discard parseInt(fen_string, ans, start=index)
  index = rand.last # index continues at next space
  return ans

proc parseMove(index: var int, fen_string: string): int=
  ## Returns the value of the move count
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  let rand = re.findBounds(fen_string, re"\d+$", start=index)
  # pattern must be valid and must start at index
  checkCondition(rand.first==index and rand!=(first: -1, last: 0), "Invalid move value")
  discard parseInt(fen_string, result, start=index)
  index = rand.last+1 # index continues at next space


proc generateWhitePieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing white pieces
  for piece in this.white:
    result |= piece

proc generateBlackPieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing black pieces
  for piece in this.black:
    result |= piece

proc generateAllPieces*(this: BoardState)  : Bitboard{.inline}=
  ## Generates a bitboard representing all boards pieces on the board
  return bitor(this.generateBlackPieces(), this.generateWhitePieces())

proc getSideToMove*(this: BoardState): Family=
  return this.sideToMove

proc getEnPassantSquare*(this: BoardState): BoardPosition=
  if this.enPassant_square==-1: return NULL_POSITION
  else: return BoardPositionLookup[this.enPassant_square]

proc getHalfMoves*(this: BoardState): int=
  return this.half_moves

proc getFullMoves*(this: BoardState): int=
  return this.moves

proc getWhitePiecesBitboard*(this: BoardState): Bitboard{.inline}=
  return this.all_white

proc getBlackPiecesBitboard*(this: BoardState): Bitboard{.inline}=
  return this.all_black

proc getFriendlyBitboard*(this: BoardState, family: Family): Bitboard{.inline}=
  case family
  of White: return this.getWhitePiecesBitboard()
  of Black: return this.getBlackPiecesBitboard()

proc getEnemyBitboard*(this: BoardState, family: Family): Bitboard{.inline}=
  case family
  of Black: return this.getWhitePiecesBitboard()
  of White: return this.getBlackPiecesBitboard()

proc getCastlingRights*(this: BoardState, family: Family): seq[CastlingField]=
  ## 0 0 0 0 1 0 1 1
  ## | | | | | | | +--> queen side castling for black (allowed in this example)
  ## | | | | | | +----> king side castling for black  (allowed in this example)
  ## | | | | | +------> queen side castling for white (not allowed in this example)
  ## | | | | + -------> king side castling for white  (allowed in this example)
  ## +----------------> first 4 bits irrelevant
  var ans: seq[CastlingField]

  case family
  of Black:
    if (this.castling_rights and (1 shl 0))!=0: ans.add(QueenSide_Castling)
    if (this.castling_rights and (1 shl 1))!=0: ans.add(KingSide_Castling)
    return (if ans != @[]: ans else: @[No_Castling])
  of White:
    if (this.castling_rights and (1 shl 2))!=0: ans.add(QueenSide_Castling)
    if (this.castling_rights and (1 shl 3))!=0: ans.add(KingSide_Castling)
    return (if ans != @[]: ans else: @[No_Castling])

proc getBitboard*(this: BoardState, family: Family, piece: ValidPiece): Bitboard{.inline}=
  case family
  of White:
    case piece:
      of Pawn  : return this.white[Pawn]
      of Rook  : return this.white[Rook]
      of Knight: return this.white[Knight]
      of Bishop: return this.white[Bishop]
      of Queen : return this.white[Queen]
      of King  : return this.white[King]
  of Black:
    case piece:
      of Pawn  : return this.black[Pawn]
      of Rook  : return this.black[Rook]
      of Knight: return this.black[Knight]
      of Bishop: return this.black[Bishop]
      of Queen : return this.black[Queen]
      of King  : return this.black[King]

proc getEnemyPieceAtLocation*(this: BoardState, location: ValidBoardPosition, family: Family): Pieces=
  ## Gets the enemy piece which is currently at `location` on the board
  ## - returns NULL_PIECE if there isn't any
  let locBB = this.lookup.getPieceLookup(location)

  case family
  of White:
    for piece, each in this.black:
      if (locBB and each)!=0: return piece
    return NULL_PIECE
  of Black:
    for piece, each in this.white:
      if (locBB and each)!=0: return piece
    return NULL_PIECE


proc initBoard*(fen_string: string, lookupT: LookupTables): BoardState=
  ## Initializes board from a string in fen notation [1]
  checkCondition(fen_string.fenValid, "Invalid Fen Notation") # make sure fen is valid
  let
    n = fen_string.len
  var
    this  = BoardState()
    index = 0
  
  this.parsePieces(index, fen_string)
  index.inc
  this.sideToMove       =  parseSideToMove(index, fen_string)
  index.inc
  this.castling_rights  = parseCastlingRights(index, fen_string)
  index.inc
  this.enPassant_square = parseEnPassant(index, fen_string)
  index.inc
  this.half_moves       = parseHalfMove(index, fen_string)
  index.inc
  this.moves            = parseMove(index, fen_string)

  checkCondition(index==n, "Error parsing fen string")
  this.all_black = this.generateBlackPieces()
  this.all_white = this.generateWhitePieces()
  this.all_piece = this.generateAllPieces()
  this.lookup    = lookupT

  return this

proc initBoard*(lookupT: LookupTables): BoardState=
  ## Initializes the board to the default values
  var
    this = BoardState()
  # default pieces
  this.white[Rook]      = 0x0000000000000081u64
  this.white[Pawn]      = 0x000000000000FF00u64
  this.white[Bishop]    = 0x0000000000000024u64
  this.white[Knight]    = 0x0000000000000042u64
  this.white[Queen]     = 0x0000000000000008u64
  this.white[King]      = 0x0000000000000010u64
  this.black[Rook]      = 0x8100000000000000u64
  this.black[Pawn]      = 0x00FF000000000000u64
  this.black[Bishop]    = 0x2400000000000000u64
  this.black[Knight]    = 0x4200000000000000u64
  this.black[Queen]     = 0x0800000000000000u64
  this.black[King]      = 0x1000000000000000u64
  this.sideToMove       = White              # By default, white moves first
  this.castling_rights  = CastleBits(0b1111) # By default all castling rights are active
  this.enPassant_square = -1                 # By default en passant isn't available
  this.half_moves       = 0
  this.moves            = 1
  this.all_black        = this.generateBlackPieces()
  this.all_white        = this.generateWhitePieces()
  this.all_piece        = this.generateAllPieces()
  this.lookup           = lookupT

  return this

#[
#TODO
proc visualizeBoard(this: BoardState, t: LookupTables, piece_toMove = NULL_POS )=
  ##
  ## Prints the current boards state to terminal
  ## piece_toMove is an optional parameter that lets player show move for a specific piece
  ##
  const
    white_king    = "K"
    white_queen   = "Q"
    white_rook    = "R"
    white_bishop  = "B"
    white_knight  = "N"
    white_pawn    = "P"
    black_king    = "k"
    black_queen   = "q"
    black_rook    = "r"
    black_bishop  = "b"
    black_knight  = "n"
    black_pawn    = "p"
  var
    index: int
    white = this.white
    black = this.black
    board_arr: array[8, array[8, string]]
    loc_bb: Bitboard
    movement = Bitboard(0) # bitboard showing possible of selected pieces if there's any
    valid_move: array[0..63, bool]

  if piece_toMove!=NULL_POS:
    loc_bb = t.pieces[piece_toMove]

    for i, each in this.white:
      if bitand(each, loc_bb)!=0:
        if i==King: movement = t.kingMove(piece_toMove, this.all_white)
        elif i==Knight: movement = t.knightMove(piece_toMove, this.all_white)
        elif i==Pawn: movement = t.pawnMove(piece_toMove, White,
                                                 this.all_white, this.all_black, this.all_piece)
        elif i==Queen: movement = t.queenMove(piece_toMove, this.all_piece, this.all_white)
        elif i==Bishop: movement = t.bishopMove(piece_toMove, this.all_piece, this.all_white)
        elif i==Rook: movement = t.rookMove(piece_toMove, this.all_piece, this.all_white)
        else: echo i
    if movement==0:
      for i, each in this.black:
        if bitand(each, loc_bb)!=0:
          if i==King: movement = t.kingMove(piece_toMove, this.all_black)
          elif i==Knight: movement = t.knightMove(piece_toMove, this.all_black)
          elif i==Pawn: movement = t.pawnMove(piece_toMove, Black,
                                                   this.all_black, this.all_white, this.all_piece)
          elif i==Queen: movement = t.queenMove(piece_toMove, this.all_piece, this.all_black)
          elif i==Bishop: movement = t.bishopMove(piece_toMove, this.all_piece, this.all_black)
          elif i==Rook: movement = t.rookMove(piece_toMove, this.all_piece, this.all_black)
          else: echo i
    #echo movement.prettyBitboard
    while movement!=0:
      valid_move[bitScanForward(movement).ord] = true
      movement &= movement-1
    #echo valid_move



  while white[Pawn]>0:
    index = bitScanForward(white[Pawn]).ord
    board_arr[7-(index shr 3)][index and 7] = white_pawn
    white[Pawn].clearBit(index)
 
  for i in 0..7:
    stdout.write(7-i+1,"| ")
    for j in 0..7:
      let pos = ((7-i) shl 3)+j
      if board_arr[i][j]=="":
        if valid_move[pos]:
          stdout.setBackGroundColor(bgGreen)
          stdout.setForeGroundColor(fgBlue)
          stdout.write(". ")
          stdout.resetAttributes()
        else:
          stdout.write(". ")
      else:
        if valid_move[pos]:
          stdout.setBackGroundColor(bgGreen)
          stdout.setForeGroundColor(fgWhite, true)
          stdout.write(board_arr[i][j], " ")
          stdout.resetAttributes()
        else:
          stdout.write(board_arr[i][j], " ")
    stdout.write("\n")
  stdout.writeLine(" +----------------")
  stdout.writeLine("   a b c d e f g h")

]#
