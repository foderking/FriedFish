module FriedFish.Moves

  type Move = Move of int

  let generateLegal(board: Board.Board): seq<Move> =
    []
  
  let generatePsuedoLegal (board: Board.Board) = seq {
    yield (Move 4)
  }
