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


    type Move(initialSquare: int, targetSquare: int, piece_type: Piece, flag: Flag) = 
        let flags = uint32 flag
        let initial = uint32 initialSquare
        let target = uint32 targetSquare
        let mutable value = 0
        let mutable move: uint32 = 
            (uint32 piece_type &&& Mask.Piece)   <<< Shifts.Piece
            |> (|||) ((flags   &&& Mask.Flags)   <<< Shifts.Flags)
            |> (|||) ((target  &&& Mask.Target)  <<< Shifts.Target)
            |> (|||) ((initial &&& Mask.Initial) <<< Shifts.Initial)

        new() =
            Move(0, 0, Enum.cast 0u, Flag.NullMove)

        member this.pieceType
            with get() = Enum.cast<Piece>(move &&& Mask.Piece)

        member this.Initial
            with get() = int ((move >>> Shifts.Initial) &&& Mask.Initial)

        member this.Target
            with get() = int ((move >>> Shifts.Target) &&& Mask.Target)
        
        member this.Value
            with get() = value
            and set(v) = value <- v

        member this.flag
            with get() = Enum.cast<Flag>((move >>> Shifts.Flags) &&& Mask.Flags)
            and set(flag: Flag) =
                let flagType = uint32 flag
                let mask = Mask.Flags <<< Shifts.Flags
                move <- (move &&& ~~~mask) ||| ((flagType <<< Shifts.Flags) &&& mask)
        
        member this.capturedPiece
            with get() = Enum.cast<Piece>((move >>> Shifts.Captured) &&& Mask.Captured)
            and set(piece: Piece) =
                let pieceType = uint32 piece
                let mask = Mask.Captured <<< Shifts.Captured
                move <- (move &&& ~~~mask) ||| ((pieceType <<< Shifts.Captured) &&& mask)
        
        member this.promotionPiece
            with get() = Enum.cast<Piece>((move >>> Shifts.Promotion) &&& Mask.Promotion)
            and set(piece: Piece) =
                let pieceType = uint32 piece
                let mask = Mask.Promotion <<< Shifts.Promotion
                move <- ((move &&& ~~~mask) ||| ((pieceType <<< Shifts.Promotion) &&& mask))

        static member op_Equality (a: Move,b: Move): bool =
            a.GetHashCode() = b.GetHashCode()

        override this.GetHashCode() = int move
        override this.Equals(a: obj) = a.GetHashCode() = this.GetHashCode()
            
