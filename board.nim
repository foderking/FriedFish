## Function and types relating to the board state
##
## references
##   [1] https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation#Definition
##   [2] https://pages.cs.wisc.edu/~psilord/blog/data/chess-pages/physical.html
import re, bitops, strutils, terminal
from parseUtils import parseInt
from algorithm import reversed
import util, lookup
from tests/base import errorMsg, infoMsg

let
  fen_re* = re"^((?:[prbnkqPRBNKQ1-8]{1,8}\/){7}[prbnkqPRBNKQ1-8]{1,8}) ([wb]) (-|K?Q?k?q?) (-|[a-f][1-8]) (\d{1,2}|100) (\d+)$"

type
  # CastleBits is a type that represent castling rights
  # The last 4 bits represents the castling rights for both sides
  # A value of 0 means that specific castling is allowed
  # 0 0 0 0 1 0 1 1
  # | | | | | | | +--> queen side castling for black (allowed in this example)
  # | | | | | | +----> king side castling for black  (allowed in this example)
  # | | | | | +------> queen side castling for white (not allowed in this example)
  # | | | | + -------> king side castling for white  (allowed in this example)
  # +----------------> first 4 bits irrelevant
  CastleBits = uint8

  BoardState* = object
    ## [2] A lightwieght object representing the full state of the chess board
    ##
    # Bitboards for white and black pieces are stored separately in thier own arrays
    white*: array[ValidPiece, Bitboard]
    black*: array[ValidPiece, Bitboard]
    # representing the side to make a move (white or black)
    sideToMove: Family
    # castling availabiliy for both sides
    castling_rights: CastleBits
    # the index of position of the en passant target square of last move in bitboard
    # a value of 0..63 represents the position, a value of -1 means no en passant square
    enPassant_square: range[-1..63]
    half_moves: int      # number of half moves since last capture/pawn advance
    moves     : int      # the full move number
    all_white : Bitboard # bitboard representing all white pieces, incrementally updated
    all_black : Bitboard # bitboard representing all black pieces, incrementally updated
    all_piece : Bitboard # bitboard representing all, incrementally updated


proc getAllWhitePieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing all the white pieces by `or`ing each white piece bitboard
  for piece in this.white:
    result |= piece

proc getAllBlackPieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing all black pieces by `or`ing each black piece bitboard
  for piece in this.black:
    result |= piece

proc getAllPieces*(this: BoardState)  : Bitboard{.inline}=
  ## Generates a bitboard representing all boards pieces on the board
  return bitor(this.getAllBlackPieces(), this.getAllWhitePieces())

proc fenValid*(fen_string: string): bool{.inline}=
  ## Determines if a fen string is valid
  return re.match(fen_string, fen_re)


proc parsePieces*(index: var int, fen_string: string, this: var BoardState)=
  ## Parses the positions for the pieces in-place
  ## `this` is the board object modified in-place
  var
    tmp: array[1,string]
    s  : string
    location = 0
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string,
             re"((?:[prbnkqPRBNKQ1-8]{1,8}\/){7}[prbnkqPRBNKQ1-8]{1,8}) ", tmp, start=index)
  assert rand!=(first: -1, last: 0), errorMsg("Invalid pieces value")
  assert rand.first==index,          errorMsg("Invalid pieces value")

  s       = tmp[0]
  index   = rand.last # index continues at next space
  # reverses the ranks so you go through in proper order
  let arr =  s.split('/').reversed

  for row in arr:
    for current in row:
      case current

      of 'p':
        this.black[Pawn].setBit(location)
        location.inc
      of 'r':
        this.black[Rook].setBit(location)
        location.inc
      of 'b':
        this.black[Bishop].setBit(location)
        location.inc
      of 'n':
        this.black[Knight].setBit(location)
        location.inc
      of 'q':
        this.black[Queen].setBit(location)
        location.inc
      of 'k':
        this.black[King].setBit(location)
        location.inc
      of 'P':
        this.white[Pawn].setBit(location)
        location.inc
      of 'R':
        this.white[Rook].setBit(location)
        location.inc
      of 'N':
        this.white[Knight].setBit(location)
        location.inc
      of 'B':
        this.white[Bishop].setBit(location)
        location.inc
      of 'Q':
        this.white[Queen].setBit(location)
        location.inc
      of 'K':
        this.white[King].setBit(location)
        location.inc

      elif current.isDigit:
        location += ($current).parseInt
      else  : raiseAssert("Invalid pieces value")

proc parseSideToMove*(index: var int, fen_string: string): Family=
  ## Returns the family making the next move
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  assert index+1<fen_string.len
  assert fen_string[index+1]==' '

  case fen_string[index]
  of 'w': result = White
  of 'b': result = Black
  else  : raiseAssert("Invalid sidetomove value")

  index.inc

proc parseCastlingRights*(index: var int, fen_string: string): CastleBits=
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
  let rand = re.findBounds(fen_string, re"(-|K?Q?k?q?) ", tmp, start=index)
  assert rand!=(first: -1, last: 0), errorMsg("Invalid castling value") # pattern must be valid
  assert rand.first==index,          errorMsg("Invalid castling value") # pattern must start at index

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
    else  : raiseAssert("Invalid castling value")
    s = s.substr(1)

  index = rand.last # index continues at next space

proc parseEnPassant*(index: var int, fen_string: string): range[-1..63]=
  ## Returns the board index of enpassant square or -1 if there isn't
  var
    tmp: array[1, string]
    s  : string
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re"(-|[a-f][1-8])", tmp, start=index)
  assert rand!=(first: -1, last: 0), errorMsg("Invalid enpassant value") # pattern must be valid
  assert rand.first==index,          errorMsg("Invalid enpassant value") # pattern must start at index

  s    = tmp[0]
  index= rand.last+1# index continues at next space

  if s=="-": return -1
  else: return getBoardIndex(s[0], s[1])
    

proc parseHalfMove*(index: var int, fen_string: string): int=
  ## Returns the value of the half-move
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  var ans: int
  # checks if the pattern starting at `index` can be parsed
  let rand = re.findBounds(fen_string, re"(100|\d{1,2}) ", start=index)
  assert rand!=(first: -1, last: 0), errorMsg("Invalid move value") # pattern must be valid
  assert rand.first==index,          errorMsg("Invalid move value") # pattern must start at index
  
  discard parseInt(fen_string, ans, start=index)
  index = rand.last # index continues at next space
  return ans

proc parseMove*(index: var int, fen_string: string): int=
  ## Returns the value of the move count
  ## starts parsing at `index`,  also modifies `index` after parsing is finished
  let rand = re.findBounds(fen_string, re"\d+$", start=index)
  var ans: int

  assert rand!=(first: -1, last: 0), errorMsg("Invalid move value") # pattern must be valid
  assert rand.first==index,          errorMsg("Invalid move value") # pattern must start at index

  discard parseInt(fen_string, ans, start=index)
  index = rand.last+1 # index continues at next space
  return ans


proc initBoard*(fen_string: string): BoardState=
  ## Initializes board from a string in fen notation [1]
  doAssert(fen_string.fenValid, "Invalid Fen Notation".errorMsg) # make sure fen is valid
  let
    n = fen_string.len # no of chars in string
  var
    this  = BoardState()
    index = 0
  
  parsePieces(index, fen_string, this)
  index.inc
  this.sideToMove =  parseSideToMove(index, fen_string)
  index.inc
  this.castling_rights = parseCastlingRights(index, fen_string)
  index.inc
  this.enPassant_square = parseEnPassant(index, fen_string)
  index.inc
  this.half_moves = parseHalfMove(index, fen_string)
  index.inc
  this.moves = parseMove(index, fen_string)

  assert index==n, "error parsing fen string"

  this.all_black = this.getAllBlackPieces()
  this.all_white = this.getAllWhitePieces()
  this.all_piece = this.getAllPieces()

  return this

proc initBoard*(): BoardState=
  ## Initializes the board to the default values
  var
    this = BoardState()
  # default pieces
  this.white[Rook]      = white_r
  this.white[Pawn]      = white_p
  this.white[Bishop]    = white_b
  this.white[Knight]    = white_n
  this.white[Queen]     = white_q
  this.white[King]      = white_k
  this.black[Rook]      = black_r
  this.black[Pawn]      = black_p
  this.black[Bishop]    = black_b
  this.black[Knight]    = black_n
  this.black[Queen]     = black_q
  this.black[King]      = black_k
  this.sideToMove       = White              # By default, white moves first
  this.castling_rights  = CastleBits(0b1111) # By default all castling rights are active
  this.enPassant_square = -1                 # By default en passant isn't available
  this.half_moves       = 0
  this.moves            = 1
  this.all_black        = this.getAllBlackPieces()
  this.all_white        = this.getAllWhitePieces()
  this.all_piece        = this.getAllPieces()

  return this


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
  while white[Rook]>0:
    index = bitScanForward(white[Rook]).ord
    board_arr[7-(index shr 3)][index and 7] = white_rook
    white[Rook].clearBit(index)
  while white[Bishop]>0:
    index = bitScanForward(white[Bishop]).ord
    board_arr[7-(index shr 3)][index and 7] = white_bishop
    white[Bishop].clearBit(index)
  while white[Knight]>0:
    index = bitScanForward(white[Knight]).ord
    board_arr[7-(index shr 3)][index and 7] = white_knight
    white[Knight].clearBit(index)
  while white[Queen]>0:
    index = bitScanForward(white[Queen]).ord
    board_arr[7-(index shr 3)][index and 7] = white_queen
    white[Queen].clearBit(index)
  while white[King]>0:
    index = bitScanForward(white[King]).ord
    board_arr[7-(index shr 3)][index and 7] = white_king
    white[King].clearBit(index)
  while black[Pawn]>0:
    index = bitScanForward(black[Pawn]).ord
    board_arr[7-(index shr 3)][index and 7] = black_pawn
    black[Pawn].clearBit(index)
  while black[Rook]>0:
    index = bitScanForward(black[Rook]).ord
    board_arr[7-(index shr 3)][index and 7] = black_rook
    black[Rook].clearBit(index)
  while black[Bishop]>0:
    index = bitScanForward(black[Bishop]).ord
    board_arr[7-(index shr 3)][index and 7] = black_bishop
    black[Bishop].clearBit(index)
  while black[Knight]>0:
    index = bitScanForward(black[Knight]).ord
    board_arr[7-(index shr 3)][index and 7] = black_knight
    black[Knight].clearBit(index)
  while black[Queen]>0:
    index = bitScanForward(black[Queen]).ord
    board_arr[7-(index shr 3)][index and 7] = black_queen
    black[Queen].clearBit(index)
  while black[King]>0:
    index = bitScanForward(black[King]).ord
    board_arr[7-(index shr 3)][index and 7] = black_king
    black[King].clearBit(index)


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

