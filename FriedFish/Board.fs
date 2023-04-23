module FriedFish.Board


  type BoardState =
    {
      white: Domain.Bitboard[,]
      black: Domain.Bitboard[,]
      all: Domain.Bitboard[]
    }