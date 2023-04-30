﻿module FriedFish.Lookup
  open FriedFish.Domain

  module Rays =
    let Total = 8
  /// Types and functions for using a lookup table
  module LookupTable =
    type Lookup =
      {
        /// Lookup for a particular square on the board
        boardPosition: Bitboard[]
        /// Lookup for knight attacks at particular position
        knightAttacks: Bitboard[]
        /// Lookup for king attacks at particular position
        kingAttacks  : Bitboard[]
      }
    
    /// Bitboard lookup for files in the order FileA to FileH
    let fileMasks = 
      [|
        0x0101010101010101UL
        0x0202020202020202UL
        0x0404040404040404UL
        0x0808080808080808UL
        0x1010101010101010UL
        0x2020202020202020UL
        0x4040404040404040UL
        0x8080808080808080UL
      |]
    /// Bitboard lookup for ranks in order Rank 1 to Rank 8
    let rankMasks = 
      [|
        0x00000000000000FFUL
        0x000000000000FF00UL
        0x0000000000FF0000UL
        0x00000000FF000000UL
        0x000000FF00000000UL
        0x0000FF0000000000UL
        0x00FF000000000000UL
        0xFF00000000000000UL
      |]   
    
    (**
              noNoWe    noNoEa
                  +15  +17
                   |     |
      noWeWe  +6 __|     |__+10  noEaEa
                    \   /
                     >0<
                 __ /   \ __
      soWeWe -10   |     |   -6  soEaEa
                   |     |
                  -17  -15
              soSoWe    soSoEa
    **)
    /// Generate attack bitboard for knight bitboard from scratch
    /// https://www.chessprogramming.org/Knight_Pattern#by_Calculation
    let _calcKnightAttack(fileMask: Bitboard[])(bb: Bitboard) =
      let notG = ~~~fileMask[Files._G]
      let notH = ~~~fileMask[Files._H]
      let notGH = notG &&& notH
      let notA = ~~~fileMask[Files._A]
      let notB = ~~~fileMask[Files._B]
      let notAB = notA &&& notB
      0UL
      |> (|||) (Helpers.shift  17 (bb &&& notH )) // noNoEa
      |> (|||) (Helpers.shift  10 (bb &&& notGH)) // noEaEa
      |> (|||) (Helpers.shift -6  (bb &&& notGH)) // soEaEa
      |> (|||) (Helpers.shift -15 (bb &&& notH )) // soSoEa
      |> (|||) (Helpers.shift  15 (bb &&& notA )) // noNoWe
      |> (|||) (Helpers.shift  6  (bb &&& notAB)) // noWeWe
      |> (|||) (Helpers.shift -10 (bb &&& notAB)) // soWeWe
      |> (|||) (Helpers.shift -17 (bb &&& notH )) // soSoWe
      
    let _calcKingAttack(fileMask: Bitboard[])(bb: Bitboard) =
      let notA = ~~~fileMask[Files._A]
      let notH = ~~~fileMask[Files._H]
      0UL
      |> (|||) (Helpers.shift  9 (bb &&& notA))
      |> (|||) (Helpers.shift  1 (bb &&& notA))
      |> (|||) (Helpers.shift -7 (bb &&& notA))
      |> (|||) (Helpers.shift  8 bb)
      |> (|||) (Helpers.shift -8 bb)
      |> (|||) (Helpers.shift -9 (bb &&& notH))
      |> (|||) (Helpers.shift -1 (bb &&& notH))
      |> (|||) (Helpers.shift  7 (bb &&& notH))
      
      
    // let initFileAndRanks(arg: {| isMask: bool; isFile: bool |}) =
    //   match arg.isMask, arg.isFile with
    //   // maskFile
    //   | true, true ->
    //     [|
    //       0x0101010101010101UL
    //       0x0202020202020202UL
    //       0x0404040404040404UL
    //       0x0808080808080808UL
    //       0x1010101010101010UL
    //       0x2020202020202020UL
    //       0x4040404040404040UL
    //       0x8080808080808080UL
    //     |]
    //   // maskRank
    //   | true, false ->
    //     [|
    //       0x00000000000000FFUL
    //       0x000000000000FF00UL
    //       0x0000000000FF0000UL
    //       0x00000000FF000000UL
    //       0x000000FF00000000UL
    //       0x0000FF0000000000UL
    //       0x00FF000000000000UL
    //       0xFF00000000000000UL
    //     |]
    //   // clearFile
    //   | false, true ->
    //     [|
    //       0xFEFEFEFEFEFEFEFEUL
    //       0xFDFDFDFDFDFDFDFDUL
    //       0xFBFBFBFBFBFBFBFBUL
    //       0xF7F7F7F7F7F7F7F7UL
    //       0xEFEFEFEFEFEFEFEFUL
    //       0xDFDFDFDFDFDFDFDFUL
    //       0xBFBFBFBFBFBFBFBFUL
    //       0x7F7F7F7F7F7F7F7FUL
    //     |]
    //   // clearRank
    //   | false, false ->
    //     [|
    //       0XFFFFFFFFFFFFFF00UL
    //       0XFFFFFFFFFFFF00FFUL
    //       0XFFFFFFFFFF00FFFFUL
    //       0XFFFFFFFF00FFFFFFUL
    //       0XFFFFFF00FFFFFFFFUL
    //       0XFFFF00FFFFFFFFFFUL
    //       0XFF00FFFFFFFFFFFFUL
    //       0X00FFFFFFFFFFFFFFUL
    //     |]
    

    let create() =
      {
        boardPosition = seq { for i in 0..63 -> (Helpers.shift i 1UL) } |> Seq.toArray
        knightAttacks = [||]
        kingAttacks   = [||]
      }
    
    let Lookup(lookup: Lookup)(piece: Pieces)(family: Family)(square: Square) =
      match piece with
      | Pieces.King ->
        lookup.kingAttacks[square]
      | Pieces.Knight ->
        lookup.knightAttacks[square]
      | Pieces.Rook ->
        0UL
      | Pieces.Bishop ->
        0UL
      | Pieces.Queen ->
        0UL
      | Pieces.Pawn ->
        0UL