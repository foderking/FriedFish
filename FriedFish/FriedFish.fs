module FriedFish.Main
  
  [<EntryPoint>]
  let main args =
    Uci.Start() |> Async.RunSynchronously
    0