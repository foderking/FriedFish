module FriedFish.Uci

  open System
  open System.Text.RegularExpressions
  
  type UciState =
    | Booting
    | Ready
    | Pondering

  type PositionSetup =
    {
      StartPosition: string
      Moves: string seq
    }
    
  module Regx = 
    let fenRegex = String.Format(
      "{0} {1} {2} {3} {4} {5}",
      @"(?:[prbnkqPRBNKQ1-8]{1,8}\/){7}[prbnkqPRBNKQ1-8]{1,8}",
      @"[wb]",
      @"(?:-|[KQkq]{1,4})",
      @"(?:-|[a-h][3-6])",
      @"\d+",
      @"\d+"
    )
    let moveRegex = @"[a-h]\d[a-h]\d"
    let positionRegex =
      Regex(
        String.Format(@"position\s+(?:fen\s+(?'start'{0})|(?'start'startpos))\s+moves(?:\s+(?'move'{1}))+", fenRegex, moveRegex),
        RegexOptions.Compiled
      )
    positionRegex.Match
    
  let (|PositionSetup|_|) str =
    let m = Regx.positionRegex.Match(str)
    if m.Success
    then Some {
      StartPosition = m.Groups["start"].Value
      Moves = m.Groups["move"].Captures |> Seq.map (fun x -> x.Value)
    } 
    else None
    
    
  let Start() = 
    let printEngineInfo() =
      printfn "id name FriedFish 0.0"
      printfn "id author Ajibola Onaopemipo"
    let printOptions() =
      printfn ""
      printfn "uciok"
      
    let rec handle (state: UciState) = 
      let input = Console.ReadLine()
      
      match input with
      | "uci" ->
        printEngineInfo()
        printOptions()
        handle state
        
      | "isready" ->
        printfn "readyok"
        handle state
        
      | PositionSetup ps ->
        //TODO
        printfn "valid position"
        printfn "%A" ps
        handle state
        
      | _ ->
        Console.WriteLine input
        handle state
    
    Console.WriteLine("Friedfish")
    handle Booting
    
      