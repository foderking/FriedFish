module FriedFish.Test.Board
    open FriedFish.Board
    open Swensen.Unquote
    open Xunit

    module FenParsing =
        [<Fact>]
        let ``parsing the default fen``() =
            let fen = FenRecord.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            test <@ Option.isSome fen @>
