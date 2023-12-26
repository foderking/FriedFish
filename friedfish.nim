import strutils
import lookup, board, movegen, move
import sequtils, sugar
import random

type Friedfish = ref object
  board: BoardState
  lookup: LookupTables

proc init()=
  randomize()



proc printBanner()=
  echo "Friedfish by foderking"

proc error(fish: Friedfish, message: string)=
  stderr.writeLine(message)

proc handleUci(fish: Friedfish)=
  echo """id name Friedfish
id author foderking"""
  echo "uciok"

proc handlePosition(fish: Friedfish, tokens: seq[string])=
  var
    i = 1
    n = tokens.len

  if tokens[0]=="startpos":
    fish.board = initBoard(fish.lookup)
  else:
    var
      fen: string
    while tokens[i] != "moves" and i<n:
      fen.add(" ")
      fen.add(tokens[i])

    fish.board = initBoard(fen, fish.lookup)

  if tokens[i] == "moves": # moves should be next on counter
    while i+1<n:
      var
        move = tokens[i+1]
        validmoves = fish.board.genLegalMoveList()
        found = false

      for validmove in validmoves:
        if getNotation(validmove, Uci)==move:
          found = true
          echo fish.board.getSideToMove()
          fish.board.makeMove(validmove)
          echo fish.board.getSideToMove()

      
      if not found:
        #fish.error "invalid move"
        echo "invalid move"
        return

      i.inc
  else:
    fish.error "bad command"
    return


proc handleGo(fish: Friedfish, tokens: seq[string])=
  let
    g = fish.board.genLegalMoveList.map(each => each.getNotation(Uci))
    tmp = g[0]#.sample()

  echo g
  echo "info score cp 30 depth 3 nodes 39 time 4 pv " & tmp & " f1c3 g8f6"
  echo "bestmove " & tmp

proc handleUciNewgame(fish: Friedfish)=
  #fish.board = initBoard(fish.lookup)
  # fish.board.reset()
  discard


proc loop(fish: Friedfish)=
  var
    line: string
    tokens: seq[string]

  while stdin.readLine(line):
    tokens = line.strip().split()

    if tokens[0] == "uci":
      fish.handleUci()
    elif tokens[0] == "ucinewgame":
      fish.handleUciNewgame()
    elif tokens[0] == "isready":
      echo "readyok"
    elif tokens[0] == "position":
      fish.handlePosition(tokens[1..^1])
    elif tokens[0] == "go":
      fish.handleGo(tokens[1..^1])
    elif tokens[0] == "stop":
      discard
    elif tokens[0] == "quit":
      return
    else:
      echo "what?"


when isMainModule:
  let f: Friedfish = Friedfish(board: nil, lookup: newLookupTable())
  init()
  printBanner()
  loop(f)
