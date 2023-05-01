module FriedFish.Program
  
  [<EntryPoint>]
  let main _ =
    let zz = 2//Domain.Visualize (Lookup.LookupTable._calcKnightAttack (Domain.shift 38 3UL))
    printfn "%A" zz
    Uci.Start() 
    0