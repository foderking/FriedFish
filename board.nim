import bitboard, lookup, re, bitops, strutils
from tests/base import errorMsg, infoMsg
import sugar, sequtils, terminal, options

let
  fen_re* = re"((?:[prbnkqPRBNKQ1-8])+\/){7}(?:[prbnkqPRBNKQ1-8])+ [wb] [-KQkq]{1,4} (?:-|(?:[a-f][1-8])) \d \d"

type
  PieceType = enum
    Pawn, Rook, Bishop, Knight, Queen, King
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
    white_pieces: array[Pawn..King, Bitboard]
    black_pieces: array[Pawn..King, Bitboard]
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
  this.white_pieces[Rook]   = white_R
  this.white_pieces[Pawn]   = white_P
  this.white_pieces[Bishop] = white_B
  this.white_pieces[Knight] = white_N
  this.white_pieces[Queen]  = white_Q
  this.white_pieces[King]   = white_k
  this.black_pieces[Pawn]   = black_p
  this.black_pieces[Rook]   = black_r
  this.black_pieces[Bishop] = black_b
  this.black_pieces[Knight] = black_n
  this.black_pieces[Queen]  = black_q
  this.black_pieces[King]   = black_k
  
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
        this.black_pieces[Pawn].setBit(board_loc)
        board_loc.inc
      elif current=='r':
        this.black_pieces[Rook].setBit(board_loc)
        board_loc.inc
      elif current=='b':
        this.black_pieces[Bishop].setBit(board_loc)
        board_loc.inc
      elif current=='n':
        this.black_pieces[Knight].setBit(board_loc)
        board_loc.inc
      elif current=='q':
        this.black_pieces[Queen].setBit(board_loc)
        board_loc.inc
      elif current=='k':
        this.black_pieces[King].setBit(board_loc)
        board_loc.inc
      elif current=='P':
        this.white_pieces[Pawn].setBit(board_loc)
        board_loc.inc
      elif current=='R':
        this.white_pieces[Rook].setBit(board_loc)
        board_loc.inc
      elif current=='N':
        this.white_pieces[Knight].setBit(board_loc)
        board_loc.inc
      elif current=='B':
        this.white_pieces[Bishop].setBit(board_loc)
        board_loc.inc
      elif current=='Q':
        this.white_pieces[Queen].setBit(board_loc)
        board_loc.inc
      elif current=='K':
        this.white_pieces[King].setBit(board_loc)
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
        if i==King: movement = t.kingMove(piece_toMove, this.all_white)
        elif i==Knight: movement = t.knightMove(piece_toMove, this.all_white)
        elif i==Pawn: movement = t.pawnMove(piece_toMove, White,
                                                 this.all_white, this.all_black, this.all_piece)
        elif i==Queen: movement = t.queenMove(piece_toMove, this.all_piece, this.all_white)
        elif i==Bishop: movement = t.bishopMove(piece_toMove, this.all_piece, this.all_white)
        elif i==Rook: movement = t.rookMove(piece_toMove, this.all_piece, this.all_white)
        else: echo i
    if movement==0:
      for i, each in this.black_pieces:
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


when isMainModule:
  const
    t = newLookupTable()
  #echo "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/p/RNBQKBNR w - e4 0 2".fenValid
  let
    fen = "3Q4/bpNN4/2R4n/8/3P4/2KNkB2/7q/4r3 w - - 0 1"
    x = initFromFen(fen)
    #x = initDefaultBoard()
  #echo initDefaultBoard()
  #echo x.all_piece.prettyBitboard
  #assert initFromFen("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1") == initDefaultBoard()

  #echo parseLocation("h8")
  x.visualizeBoard(t, E3)
