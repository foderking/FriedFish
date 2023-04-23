module FriedFish.Uci

  open System
  
  type UciState =
    | Booting

  let Start() = async {
    let rec handle (state: UciState) = async {
      let! input = Console.In.ReadLineAsync() |> Async.AwaitTask
      match state with
      | Booting ->
        do! Console.Out.WriteLineAsync input |> Async.AwaitTask
        return! handle state
    }
    
    do! handle Booting
  }
    
      