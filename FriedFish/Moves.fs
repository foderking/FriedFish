module FriedFish.Moves

  type Move = Move of int

  let GenerateLegalMoves (board: Board.Board) = seq {
    yield (Move 4)
  }
  
  let GeneratePseudoLegalMoves (board: Board.Board) = seq {
    yield (Move 4)
  }
