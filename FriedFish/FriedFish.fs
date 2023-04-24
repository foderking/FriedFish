module FriedFish.Program
  
  [<EntryPoint>]
  let main _ =
    let zz = Domain.Visualize (Lookup.LookupTable._calcKnightAttack (Domain.shift 38 3UL))
    printfn "%A" zz
    Uci.Start() 
    0