module Tests.FsCheck

open FsCheck
open FriedFish
type Generator =
    static member Piece(): Arbitrary<Piece> =
        Arb.fromGen(gen{ 
            let! x = Arb.generate<uint32>
            return Enum.cast<Piece>(x%6u)
        })

    static member Flag(): Arbitrary<Flag> =
        Arb.fromGen(gen{ 
            let! x = Arb.generate<uint32>
            return Enum.cast<Flag>( 1u <<< int((x%7u)+1u) )
        })

    static member Square(): Arbitrary<Square> =
        Arb.fromGen(gen{ 
            let! x = Arb.generate<uint32>
            return x % 64u
        })

   

do Arb.register<Generator>() |> ignore
