module Tests.Move

open FsCheck.Xunit
open Xunit
open FriedFish.Move
open FriedFish
open Swensen.Unquote.Assertions

[<Property>]
let ``Setting flag works and doesn't affect other fields``(init: Square, targ: Square, piece: Piece, flag: Flag) =
    let m = Move(int init,int targ, piece, Flag.NullMove)
    m.flag <- flag

    test <@ m.Initial = int init@>
    test <@ m.Target = int targ @>
    test <@ m.pieceType = piece @>
    test <@ m.flag = flag@>
    test <@ m.capturedPiece = Enum.cast 0u @>
    test <@ m.promotionPiece = Enum.cast 0u @>

[<Property>]
let ``Setting captured piece works and doesn't affect other fields``(init: Square, targ: Square, piece: Piece, capt_piece: Piece, flag: Flag) =
    let m = Move(int init,int targ, piece, flag)
    m.capturedPiece <- capt_piece

    test <@ m.Initial = int init @>
    test <@ m.Target = int targ @>
    test <@ m.pieceType = piece@>
    test <@ m.flag = flag@>
    test <@ m.capturedPiece = capt_piece@>
    test <@ m.promotionPiece = Enum.cast 0u @>

[<Property>]
let ``Setting promotion piece works and doesn't affect other fields``(init: Square, targ: Square, piece: Piece, promo_piece: Piece, flag: Flag) =
    let m = Move(int init,int targ, piece, flag)
    m.promotionPiece <- promo_piece

    test <@ m.flag = flag @>
    test <@ m.Initial = int init @>
    test <@ m.Target = int targ @>
    test <@ m.pieceType = piece @>
    test <@ m.promotionPiece = promo_piece @>
    test <@ m.capturedPiece = Enum.cast 0u @>


[<Property>]
let ``Constructor set appropriate values``(initial: Square, target: Square, piece: Piece, flag: Flag) =
    let m = Move(int initial, int target, piece, flag)

    test <@ m.Initial = int initial @>
    test <@ m.Target = int target @>
    test <@ m.pieceType = piece @>
    test <@ m.flag = flag @>
    test <@ m.capturedPiece = Enum.cast 0u @>

[<Property>]
let ``Different moves shouldn't equal itself``(initial: Square, target: Square, piece: Piece, flag: Flag) =
    let a = Move(int initial,int target,piece,flag)
    let b = Move(int ((initial + 1u)%64u),int target,piece,flag)

    test <@ a <> b @>

[<Property>]
let ``Same moves should equal itself``(initial: Square, target: Square, piece: Piece, flag: Flag) =
    let a = Move(int initial,int target,piece,flag)
    let b = Move(int initial,int target,piece,flag)

    test <@ a = b @>


