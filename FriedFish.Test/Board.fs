module FriedFish.Test.Board
    open System.IO
    open FriedFish.Board
    open Swensen.Unquote
    open Xunit

    module FenParsing =
        let fen_data =
            File.ReadAllLines("fen.txt")
            |> Array.map (fun x -> [|x|])
        [<Fact>]
        let ``parsing the default fen``() =
            let fen = FenRecord.parse("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
            test <@ Option.isSome fen @>
            let fenn = Option.get fen
            let board = Board.create(fenn)
            let b = board.createFen()
            test <@ fenn = b  @>
            
        [<Theory>]
        [<MemberData(nameof(fen_data))>]
        let ``board state should produce same fen it parsed``(fen: string) =
            let fen_rec = FenRecord.parse(fen)
            test <@ Option.isSome fen_rec @>
            let fenn = Option.get fen_rec
            let board = Board.create(fenn)
            test <@ board.createFen() = fenn @>
