import bitboard, lookup, re, bitops, strutils
from tests/base import errorMsg, infoMsg
import sugar, sequtils, terminal, options

let
  fen_re* = re"((?:[prbnkqPRBNKQ1-8])+\/){7}(?:[prbnkqPRBNKQ1-8])+ [wb] [-KQkq]{1,4} (?:-|(?:[a-f][1-8])) \d \d"

type
  # CastleBits is a type that represent castling rights
  # The last 4 bits represents the castling rights for both sides
  # A value of 0 means that specific castling is allowed
  # 0 0 0 0 1 0 1 1
  # | | | | | | | |--> queen side castling for black (allowed in this example)
  # | | | | | | |----> king side castling for black  (allowed in this example)
  # | | | | | |------> queen side castling for white (not allowed in this example)
  # | | | | | -------> king side castling for white  (allowed in this example)
  # |-|-|-|----> first 4 bits irrelevant
  CastleBits = uint8
  BoardState = object
    # Bitboards for white and black pieces are stored separately in thier own arrays
    white_pieces: array[WhitePawn..WhiteKing, Bitboard]
    black_pieces: array[BlackPawn..BlackKing, Bitboard]
    # representing the side to make a move (white or black)
    sideToMove: Family
    # castling availabiliy for both sides represented in a nibble
    castling_rights: CastleBits
    # the index of position of the en passant target square of last move in bitboard
    # a value of 0..63 represents the position, a value of -1 means no en passant square
    enPassant_square: range[-1..63]
    
    half_moves: int # number of half moves since last capture/pawn advance
    moves: int      # the full move number
    
    all_white: Bitboard # bitboard representing all white pieces, incrementally updated
    all_black: Bitboard # bitboard representing all black pieces, incrementally updated
    all_piece: Bitboard # bitboard representing all, incrementally updated

proc getWhitePieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing all the white pieces by `or`ing each white piece
  for piece in this.white_pieces:
    result |= piece

proc getBlackPieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing all the black pieces by `or`ing each black piece
  for piece in this.black_pieces:
    result |= piece

proc getAllPieces*(this: BoardState): Bitboard{.inline}=
  ## Generates a bitboard representing all the pieces on the board by `or`ing all the piece's Bitboards
  return bitor(this.getBlackPieces, this.getWhitePieces)



proc initDefaultBoard(): BoardState=
  ## Initializes the board to its proper default values
  var
    this = BoardState()
  # default pieces
  this.white_pieces[WhiteRook]   = white_R
  this.white_pieces[WhitePawn]   = white_P
  this.white_pieces[WhiteBishop] = white_B
  this.white_pieces[WhiteKnight] = white_N
  this.white_pieces[WhiteQueen]  = white_Q
  this.white_pieces[WhiteKing]   = white_k
  this.black_pieces[BlackPawn]   = black_p
  this.black_pieces[BlackRook]   = black_r
  this.black_pieces[BlackBishop] = black_b
  this.black_pieces[BlackKnight] = black_n
  this.black_pieces[BlackQueen]  = black_q
  this.black_pieces[BlackKing]   = black_k
  
  this.sideToMove       = White # By default, white moves first
  this.castling_rights  = 0b1111.CastleBits # By default all castling rights are active
  this.enPassant_square = -1 # By default en passant isn't available
  this.half_moves = 0 
  this.moves      = 1

  this.all_black = this.getBlackPieces
  this.all_white = this.getWhitePieces
  this.all_piece = this.getAllPieces

  return this

proc parseInt(s: char): int=
  return s.int - 48

proc getRank*(row: char): int=
  # returns index of rank
  # e.g 1 -> 0
  #     8 -> 7
  return row.int - 49

proc getFile*(col: char): int=
  # returns index of file
  # e.g a -> 0
  #     h -> 7
  return col.int - 97

proc fenValid(fen_string: string): bool=
  return re.match(fen_string, fen_re)

proc parseLocation*(loc: string): int=
  # string in form file-rank
  # eg `e3`
  let
    file = getFile(loc[0])
    rank = getRank(loc[1])
  #echo rank, " ", file
  return (rank shl 3) + file

proc initFromFen(fen_string: string): BoardState=
  ## Initializes board from a fen
  ## https://en.wikipedia.org/wiki/Forsyth%E2%80%93Edwards_Notation#Definition
  ##
  doAssert(fen_string.fenValid, "Invalid Fen Notation".errorMsg) # make sure fen is valid

  let
    n = fen_string.len # no of chars in string
  var
    this = BoardState()
    parsed_piece    = false # has all the pieces postion been parsed?
    parsed_active   = false # has the current player been parsed?
    parsed_castles  = false # has all the castling rights been parsed?
    parsed_enpassnt = false # has the en passant square been parsed
    parsed_halfmove = false # has the halfmove count been parsed?
    parsed_fullmove = false # has the move count been parsed?
    board_loc = 56 # to make parsing pieces easier
    current: char

  this.castling_rights = 0.CastleBits

  for index in 0..<n:
    current = fen_string[index]
    if not parsed_piece:
      echo current, " ", board_loc
      if current=='p':
        this.black_pieces[BlackPawn].setBit(board_loc)
        board_loc.inc
      elif current=='r':
        this.black_pieces[BlackRook].setBit(board_loc)
        board_loc.inc
      elif current=='b':
        this.black_pieces[BlackBishop].setBit(board_loc)
        board_loc.inc
      elif current=='n':
        this.black_pieces[BlackKnight].setBit(board_loc)
        board_loc.inc
      elif current=='q':
        this.black_pieces[BlackQueen].setBit(board_loc)
        board_loc.inc
      elif current=='k':
        this.black_pieces[BlackKing].setBit(board_loc)
        board_loc.inc
      elif current=='P':
        this.white_pieces[WhitePawn].setBit(board_loc)
        board_loc.inc
      elif current=='R':
        this.white_pieces[WhiteRook].setBit(board_loc)
        board_loc.inc
      elif current=='N':
        this.white_pieces[WhiteKnight].setBit(board_loc)
        board_loc.inc
      elif current=='B':
        this.white_pieces[WhiteBishop].setBit(board_loc)
        board_loc.inc
      elif current=='Q':
        this.white_pieces[WhiteQueen].setBit(board_loc)
        board_loc.inc
      elif current=='K':
        this.white_pieces[WhiteKing].setBit(board_loc)
        board_loc.inc
      elif current.isDigit:
        board_loc += ($current).parseInt
      elif current=='/':
        board_loc -= 16

      elif current==' ':
        parsed_piece = true
        echo "parsed pieces".infoMsg
      else: raiseAssert "This shouldn't happen"

    elif not parsed_active:
      if current=='w': this.sideToMove = White
      elif current=='b': this.sideToMove = Black

      elif current==' ':
        parsed_active = true
        echo "parsed active".infoMsg
      else: raiseAssert "This shouldn't happen"

    elif not parsed_castles:
      # 0 0 0 0 1 0 1 1
      # | | | | | | | |--> q 
      # | | | | | | |----> k
      # | | | | | |------> Q
      # | | | | | -------> K
      # |-|-|-|----> first 4 bits irrelevant
      if current=='-':
        continue
      elif current=='K':
        this.castling_rights.setBit(3)
      elif current=='Q':
        this.castling_rights.setBit(2)
      elif current=='k':
        this.castling_rights.setBit(1)
      elif current=='q':
        this.castling_rights.setBit(0)

      elif current==' ':
        parsed_castles = true
        echo "parsed castles".infoMsg
      else: raiseAssert "This shouldn't happen"

    elif not parsed_enpassnt:
      if current=='-':
        this.enPassant_square = -1
      elif current!=' ':
        let l = parseLocation(fen_string[index-2..index-1])
        echo fen_string[index-2..index-1]
        this.enPassant_square = l

      else:
        parsed_enpassnt = true
        echo "parsed en passant".infoMsg

    elif not parsed_halfmove:
      if current==' ':
        parsed_halfmove = true
        echo "parsed halfmoves".infoMsg
      else:
        this.half_moves = current.parseInt

    elif not parsed_fullmove:
      if current!=' ':
        this.moves = current.parseInt
      else:
        parsed_fullmove = true
        echo "parsed full moves".infoMsg

    else:
      raiseAssert "This shouldn't happen"

  this.all_black = this.getBlackPieces
  this.all_white = this.getWhitePieces
  this.all_piece = this.getAllPieces

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
    white = this.white_pieces
    black = this.black_pieces
    board_arr: array[8, array[8, string]]
    loc_bb: Bitboard
    movement = Bitboard(0) # bitboard showing possible of selected pieces if there's any
    valid_move: array[0..63, bool]

  if piece_toMove!=NULL_POS:
    loc_bb = t.pieces[piece_toMove]

    for i, each in this.white_pieces:
      if bitand(each, loc_bb)!=0:
        if i==WhiteKing: movement = t.kingMove(piece_toMove, this.all_white)
        elif i==WhiteKnight: movement = t.knightMove(piece_toMove, this.all_white)
        elif i==WhitePawn: movement = t.pawnMove(piece_toMove, White,
                                                 this.all_white, this.all_black, this.all_piece)
        else: echo i
    #echo movement.prettyBitboard
    while movement!=0:
      valid_move[bitScanForward(movement).ord] = true
      movement &= movement-1
    #echo valid_move



  while white[WhitePawn]>0:
    index = bitScanForward(white[WhitePawn]).ord
    board_arr[7-(index shr 3)][index and 7] = white_pawn
    white[WhitePawn].clearBit(index)
  while white[WhiteRook]>0:
    index = bitScanForward(white[WhiteRook]).ord
    board_arr[7-(index shr 3)][index and 7] = white_rook
    white[WhiteRook].clearBit(index)
  while white[WhiteBishop]>0:
    index = bitScanForward(white[WhiteBishop]).ord
    board_arr[7-(index shr 3)][index and 7] = white_bishop
    white[WhiteBishop].clearBit(index)
  while white[WhiteKnight]>0:
    index = bitScanForward(white[WhiteKnight]).ord
    board_arr[7-(index shr 3)][index and 7] = white_knight
    white[WhiteKnight].clearBit(index)
  while white[WhiteQueen]>0:
    index = bitScanForward(white[WhiteQueen]).ord
    board_arr[7-(index shr 3)][index and 7] = white_queen
    white[WhiteQueen].clearBit(index)
  while white[WhiteKing]>0:
    index = bitScanForward(white[WhiteKing]).ord
    board_arr[7-(index shr 3)][index and 7] = white_king
    white[WhiteKing].clearBit(index)
  while black[BlackPawn]>0:
    index = bitScanForward(black[BlackPawn]).ord
    board_arr[7-(index shr 3)][index and 7] = black_pawn
    black[BlackPawn].clearBit(index)
  while black[BlackRook]>0:
    index = bitScanForward(black[BlackRook]).ord
    board_arr[7-(index shr 3)][index and 7] = black_rook
    black[BlackRook].clearBit(index)
  while black[BlackBishop]>0:
    index = bitScanForward(black[BlackBishop]).ord
    board_arr[7-(index shr 3)][index and 7] = black_bishop
    black[BlackBishop].clearBit(index)
  while black[BlackKnight]>0:
    index = bitScanForward(black[BlackKnight]).ord
    board_arr[7-(index shr 3)][index and 7] = black_knight
    black[BlackKnight].clearBit(index)
  while black[BlackQueen]>0:
    index = bitScanForward(black[BlackQueen]).ord
    board_arr[7-(index shr 3)][index and 7] = black_queen
    black[BlackQueen].clearBit(index)
  while black[BlackKing]>0:
    index = bitScanForward(black[BlackKing]).ord
    board_arr[7-(index shr 3)][index and 7] = black_king
    black[BlackKing].clearBit(index)


  for i in 0..7:
    stdout.write(7-i+1,"| ")
    for j in 0..7:
      let pos = ((7-i) shl 3)+j
      if board_arr[i][j]=="":
        if valid_move[pos]:
          stdout.setBackGroundColor(bgGreen)
          stdout.setForeGroundColor(fgBlue)
          stdout.write("  ")
          stdout.resetAttributes()
        else:
          stdout.write(" ", " ")
      else:
        if valid_move[pos]:
          stdout.setBackGroundColor(bgGreen)
          stdout.setForeGroundColor(fgBlue, true)
          stdout.write(board_arr[i][j], " ")
          stdout.resetAttributes()
        else:
          stdout.write(board_arr[i][j], " ")
    stdout.write("\n")
  stdout.writeLine(" +----------------")
  stdout.writeLine("   a b c d e f g h")

when isMainModule:
  #echo find("uxabc", re"(?<=x|y)ab" )
  const
    t = newLookupTable()
  #echo "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/p/RNBQKBNR w - e4 0 2".fenValid
  let
    #x = initFromFen("rnbqkbnr/ppppppp1/7p/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    x = initDefaultBoard()
  #echo initDefaultBoard()
  #echo x.all_piece.prettyBitboard
  #assert initFromFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1") == initDefaultBoard()

  #echo parseLocation("h8")
  x.visualizeBoard(t, C2)
