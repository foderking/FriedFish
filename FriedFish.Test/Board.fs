module FriedFish.Test.Board
    open System.IO
    open FriedFish.Board
    open Swensen.Unquote
    open Xunit

    module FenParsing =
        let fen_data =
            File.ReadAllLines("fen.txt")
            |> Array.map (fun x -> [|x|])
           
        [<Theory>]
        [<InlineData("r1bqkb1r/ppp2ppp/1nn5/3pP3/3P4/1Q3N2/PP3PPP/RNB1KB1R w KQkq d6 0 1")>]
        [<InlineData("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")>]
        [<InlineData("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")>]
        [<InlineData("rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq c6 0 2")>]
        [<InlineData("rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2")>]
        let ``board state should produce same fen it parsed (custom)``(fen: string) =
            let fen_rec = FenRecord.parse(fen)
            test <@ Option.isSome fen_rec @>
            let fenn = Option.get fen_rec
            let board = Board.create(fenn)
            test <@ board.createFen() = fenn @>
           
        [<Theory>]
        [<MemberData(nameof(fen_data))>]
        let ``board state should produce same fen it parsed``(fen: string) =
            let fen_rec = FenRecord.parse(fen)
            test <@ Option.isSome fen_rec @>
            let fenn = Option.get fen_rec
            let board = Board.create(fenn)
            test <@ board.createFen() = fenn @>
