/// Friedfish's implementatoin of the UCI protocol.
/// The protocol is specified at https://web.archive.org/web/20200218202727/https://wbec-ridderkerk.nl/html/UCIProtocol.html
module FriedFish.Uci


  open System
  open System.Text.RegularExpressions
  
  type UciState =
    | Booting
    | Uci
    | Pondering

  type OptionsSetup =
    {
      Name: string
      Value: string option
    }
    
    
  type EngineOptionType =
    /// a checkbox that can either be true or false
    | String of string
    /// a spin wheel that can be an integer in a certain range
    | Spin   of int * int
    /// a combo box that can have different predefined strings as a value
    | Combo  of string array
    /// a button that can be pressed to send a command to the engine
    | Button of (unit -> unit)
    /// a checkbox that can either be true or false
    | Check  of bool
    
  /// All the options configurable by the engine
  type EngineOptions = Map<string, string * EngineOptionType>
    
    
  type PositionSetup =
    {
      StartPosition: string
      Moves: string seq
    }
  
  type GoSetup =
    {
      /// restrict search to this moves only
      SearchMoves: string seq option
      /// start searching in pondering move.
      Ponder: bool option
      /// white has x msec left on the clock
      WTime: int option
      /// black has x msec left on the clock
      BTime: int option
      /// white increment per move in mseconds if x > 0
      WInc: int option
      /// black increment per move in mseconds if x > 0
      BInc: int option
      /// there are x moves to the next time control, this will only be sent if x > 0
      MovesToGo: int option
      /// search x plies only.
      Depth: int option
      /// search x nodes only,
      Nodes: int option
      /// search for a mate in x moves
      Mate: int option
      /// search exactly x mseconds
      MoveTime: int option
      /// search until the "stop" command. Do not exit the search without being told so in this mode!
      Infinite: bool option
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
    
  let (|PositionSetup|_|) (str: string) =
    let m = Regx.positionRegex.Match(str.Trim())
    if m.Success
    then Some {
      StartPosition = m.Groups["start"].Value
      Moves = m.Groups["move"].Captures |> Seq.map (fun x -> x.Value)
    } 
    else None
    
  let (|OptionsSetup|_|) (str: string) =
    match str.Trim().Split() with
    | [|"setoption"; "name"; name; "value"; value|] ->
      {
        Name = name
        Value = Some value
      }
      |> Some
      
    | [|"setoption"; "name"; name|] ->
      {
        Name = name
        Value = None
      }
      |> Some
      
    | _ ->
       None
    
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
      // tell engine to use the uci (universal chess interface)
      | "uci" ->
        printEngineInfo()
        printOptions()
        handle state
      // switch the debug mode of the engine on 
      | "debug on" ->
        // TODO
        handle state
      // switch the debug mode of the engine off
      | "debug off" ->
        // TODO
        handle state
      // this is used to synchronize the engine with the GUI
      | "isready" ->
        printfn "readyok"
        handle state
      // this is sent to the engine when the user wants to change the internal parameters of the engine
      | OptionsSetup ops ->
        //TODO
        printfn "valid option"
        printfn "%A" ops
        handle state
      // this is sent to the engine when the next search (started with "position" and "go") will be from a different game
      | "ucinewgame" ->
        //TODO
        handle state
      //set up the position described in fenstring on the internal board and play the moves on the internal chess board.
      | PositionSetup ps ->
        //TODO
        printfn "valid position"
        printfn "%A" ps
        handle state
        
      | "go" ->
        //TODO
        let best = Search.GetBestMove()
        printfn "bestmove %s" best
        handle state
      // This will be sent if the engine was told to ponder on the same move the user has played
      | "ponderhit" ->
        //TODO
        handle state
      // stop calculating as soon as possible,
      | "stop" ->
        //TODO
        handle state
      // quit the program as soon as possible
      | "quit" ->
        state
      // invalid command
      | _ ->
        printfn "invalid command: %A" input
        handle state
    
    printfn "Friedfish <O><"
    handle Booting |> ignore
    
      