module FriedFish.Moves

  type Move = Move of int

  let GenerateLegalMoves (board: Board.BoardState) = seq {
    yield (Move 4)
  }
  
  let GeneratePseudoLegalMoves (board: Board.BoardState) = seq {
    yield (Move 4)
  }
