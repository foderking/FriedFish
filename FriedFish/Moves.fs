module FriedFish.Move
    module Mask =
        [<Literal>]
        let Piece   = 0x7u
        [<Literal>]
        let Initial = 0x3fu
        [<Literal>]
        let Target  = 0x3fu
        [<Literal>]
        let Flags   = 0x7fu
        [<Literal>]
        let Captured  = 0x7u
        [<Literal>]
        let Promotion = 0x7u

    module Shifts =
        [<Literal>]
        let Piece   = 0
        [<Literal>]
        let Initial = 9
        [<Literal>]
        let Target  = 15
        [<Literal>]
        let Flags   = 21
        [<Literal>]
        let Captured  = 6
        [<Literal>]
        let Promotion = 3


    type Move(initial: uint32, target: uint32, piece_type: uint32, flags: uint32 ) = 
        let mutable value = 0
        let mutable move: uint32 = 
            (piece_type &&& Mask.Piece) <<< Shifts.Piece
            |> (|||) (flags   &&& Mask.Flags)   <<< Shifts.Flags
            |> (|||) (target  &&& Mask.Target)  <<< Shifts.Target
            |> (|||) (initial &&& Mask.Initial) <<< Shifts.Initial

        new() =
            Move(0u,0u,0u,uint32 Flag.NullMove)

        member this.pieceType
            with get() = Enum.cast<Piece>(move &&& Mask.Piece)

        member this.Initial
            with get() = ((move >>> Shifts.Initial) &&& Mask.Initial)

        member this.Target
            with get() = ((move >>> Shifts.Target) &&& Mask.Target)
        
        member this.Value
            with get() = value
            and set(v) = value <- v

        member this.flag
            with get() = Enum.cast<Flag>((move >>> Shifts.Flags) &&& Mask.Flags)
            and set(flag: Flag) =
                let flagType = uint32 flag
                let mask = Mask.Flags <<< Shifts.Flags
                move <- (move &&& mask) ||| ((flagType <<< Shifts.Flags) &&& Mask.Flags)
        
        member this.capturedPiece
            with get() = Enum.cast<Piece>((move >>> Shifts.Captured) &&& Mask.Captured)
            and set(piece: Piece) =
                let pieceType = uint32 piece
                let mask = Mask.Captured <<< Shifts.Captured
                move <- (move &&& mask) ||| ((pieceType <<< Shifts.Captured) &&& Mask.Captured)
        
        member this.promotionPiece
            with get() = Enum.cast<Piece>((move >>> Shifts.Promotion) &&& Mask.Promotion)
            and set(piece: Piece) =
                let pieceType = uint32 piece
                let mask = Mask.Promotion <<< Shifts.Promotion
                move <- (move &&& mask) ||| ((pieceType <<< Shifts.Promotion) &&& Mask.Promotion)

        static member op_Equality (a: Move,b: Move): bool =
            a.GetHashCode() = b.GetHashCode()

        override this.GetHashCode() = int move
        override this.Equals(a: obj) = a.GetHashCode() = this.GetHashCode()
            
