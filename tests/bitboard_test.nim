import ../bitboard
import tables, strutils


func errorMsg(message: string): string=
  ## Generates red error text to be printed to terminal
  return "\n\e[1;31m"&message&"\e[0m"

func infoMsg(message: string): string=
  ## Generates yellow info text to be printed to terminal
  return "\n\e[1;33m"&message&"\e[0m"

func passMsg(): string=
  ## Generates yellow info text to be printed to terminal
  return "\n\e[1;32mPASSED!\e[0m"

func expectMsg(error: string, got: string, expect: string): string=
  ## Formats message to be printed to terminal after an error
  ## `error`: The error message formatted for the terminal
  ## `got`:   The incorrect result that was gotten
  ## `expect`: The correct result
  return """$#
Got:
$#
Expected:
$#""" % [error, got, expect]

template test_posInd(value, ans: untyped): untyped=
  ## template should produce something like
  ## ```nim
  ## # from
  ## test_posInd(PositionsIndex.A1.ord, 0)
  ## # to
  ## doAssert PositionsIndex.A1.ord==0,
  ##    expectMsg(errorMsg("Invalid ord for "&($PositionsIndex.A1)), $PositionsIndex.A1.ord, "0")
  ##```
  doAssert value==ans,
    expectMsg(errorMsg("Invalid ord for "&($value)), $value, $ans)

template test_indPos(ans, value: untyped): untyped=
  ## template should produce something like
  ## ```nim
  ## # from
  ## test_indPos(PositionsIndex.A1, 0)
  ## # to
  ## doAssert IndexPositions[0] == PositionsIndex.A1
  ##    expectMsg(errorMsg("Invalid value at index "&($0)), $IndexPositions[0], PositionsIndex.A1)
  ##```
  doAssert IndexPositions[value] == ans,
    expectMsg(errorMsg("Invalid value at index "&($value)), $IndexPositions[value], $ans)


when isMainModule:
  const
    pawn_bb = 0b0000000000000000000000000000000000000000000000001111111100000000u64
    rand_01 = 0b1010111010011101011011010101011101010110010110101011011000111011u64
    rand_02 = 0b0000000000000000000000000000000011111111000000000000000000000000u64
    rand_03 = 0b0000000000000000000000000000000001010110000000000000000000000000u64


  var
    test_pretty = initTable[Bitboard, string]()

  test_pretty = {
    pawn_bb: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0""",
    rand_01: """ 0 1 1 1 0 1 0 1
 1 0 1 1 1 0 0 1
 1 0 1 1 0 1 1 0
 1 1 1 0 1 0 1 0
 0 1 1 0 1 0 1 0
 0 1 0 1 1 0 1 0
 0 1 1 0 1 1 0 1
 1 1 0 1 1 1 0 0""",
    rand_02: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 1 1 1 1 1 1 1 1
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
    rand_03: """ 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 1 1 0 1 0 1 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0
 0 0 0 0 0 0 0 0""",
  }.toTable




  # Checks the pretty function gives correct output
  echo infoMsg("Check that `pretty` function produces the correct output")
  doAssert pretty(pawn_bb)==test_pretty[pawn_bb],
    expectMsg(errorMsg("Err in `pretty`"), pretty(pawn_bb), test_pretty[pawn_bb])

  doAssert pretty(rand_01)==test_pretty[rand_01],
    expectMsg(errorMsg("Err in `pretty`"), pretty(rand_01), test_pretty[rand_01])

  doAssert pretty(rand_02)==test_pretty[rand_02], 
    expectMsg(errorMsg("Err in `pretty`"), pretty(rand_02), test_pretty[rand_02])

  doAssert pretty(rand_03)==test_pretty[rand_03], 
    expectMsg(errorMsg("Err in `pretty`"), pretty(rand_03), test_pretty[rand_03])
  echo passMsg()

  # Checks anding of bitboards
  echo infoMsg("Check that `and`ing bitboards work")
  doAssert (rand_01 and rand_02)==rand_03,
    expectMsg(errorMsg("Err `and`ing"), $(rand_01 and rand_02), $rand_03)
  echo passMsg()

  # Testing `PositionIndex`
  echo infoMsg("Testing `PositionsIndex`")

  test_posInd(PositionsIndex.A1.ord, 0)
  test_posInd(PositionsIndex.B1.ord, 1)
  test_posInd(PositionsIndex.C1.ord, 2)
  test_posInd(PositionsIndex.D1.ord, 3)
  test_posInd(PositionsIndex.E1.ord, 4)
  test_posInd(PositionsIndex.F1.ord, 5)
  test_posInd(PositionsIndex.G1.ord, 6)
  test_posInd(PositionsIndex.H1.ord, 7)
  test_posInd(PositionsIndex.A2.ord, 8)
  test_posInd(PositionsIndex.B2.ord, 9)
  test_posInd(PositionsIndex.C2.ord,10)
  test_posInd(PositionsIndex.D2.ord,11)
  test_posInd(PositionsIndex.E2.ord,12)
  test_posInd(PositionsIndex.F2.ord,13)
  test_posInd(PositionsIndex.G2.ord,14)
  test_posInd(PositionsIndex.H2.ord,15) 
  test_posInd(PositionsIndex.A3.ord,16)
  test_posInd(PositionsIndex.B3.ord,17)
  test_posInd(PositionsIndex.C3.ord,18)
  test_posInd(PositionsIndex.D3.ord,19)
  test_posInd(PositionsIndex.E3.ord,20)
  test_posInd(PositionsIndex.F3.ord,21)
  test_posInd(PositionsIndex.G3.ord,22)
  test_posInd(PositionsIndex.H3.ord,23)
  test_posInd(PositionsIndex.A4.ord,24)
  test_posInd(PositionsIndex.B4.ord,25)
  test_posInd(PositionsIndex.C4.ord,26)
  test_posInd(PositionsIndex.D4.ord,27)
  test_posInd(PositionsIndex.E4.ord,28)
  test_posInd(PositionsIndex.F4.ord,29)
  test_posInd(PositionsIndex.G4.ord,30)
  test_posInd(PositionsIndex.H4.ord,31)
  test_posInd(PositionsIndex.A5.ord,32)
  test_posInd(PositionsIndex.B5.ord,33)
  test_posInd(PositionsIndex.C5.ord,34)
  test_posInd(PositionsIndex.D5.ord,35)
  test_posInd(PositionsIndex.E5.ord,36)
  test_posInd(PositionsIndex.F5.ord,37)
  test_posInd(PositionsIndex.G5.ord,38)
  test_posInd(PositionsIndex.H5.ord,39)
  test_posInd(PositionsIndex.A6.ord,40)
  test_posInd(PositionsIndex.B6.ord,41)
  test_posInd(PositionsIndex.C6.ord,42)
  test_posInd(PositionsIndex.D6.ord,43)
  test_posInd(PositionsIndex.E6.ord,44)
  test_posInd(PositionsIndex.F6.ord,45)
  test_posInd(PositionsIndex.G6.ord,46)
  test_posInd(PositionsIndex.H6.ord,47)
  test_posInd(PositionsIndex.A7.ord,48)
  test_posInd(PositionsIndex.B7.ord,49)
  test_posInd(PositionsIndex.C7.ord,50)
  test_posInd(PositionsIndex.D7.ord,51)
  test_posInd(PositionsIndex.E7.ord,52)
  test_posInd(PositionsIndex.F7.ord,53)
  test_posInd(PositionsIndex.G7.ord,54)
  test_posInd(PositionsIndex.H7.ord,55) 
  test_posInd(PositionsIndex.A8.ord,56)
  test_posInd(PositionsIndex.B8.ord,57)
  test_posInd(PositionsIndex.C8.ord,58)
  test_posInd(PositionsIndex.D8.ord,59)
  test_posInd(PositionsIndex.E8.ord,60)
  test_posInd(PositionsIndex.F8.ord,61)
  test_posInd(PositionsIndex.G8.ord,62)
  test_posInd(PositionsIndex.H8.ord,63)

  echo passMsg()

  echo infoMsg("Testing `IndexPositions` array")

  test_indPos(PositionsIndex.A1, 0)
  test_indPos(PositionsIndex.B1, 1)
  test_indPos(PositionsIndex.C1, 2)
  test_indPos(PositionsIndex.D1, 3)
  test_indPos(PositionsIndex.E1, 4)
  test_indPos(PositionsIndex.F1, 5)
  test_indPos(PositionsIndex.G1, 6)
  test_indPos(PositionsIndex.H1, 7)
  test_indPos(PositionsIndex.A2, 8)
  test_indPos(PositionsIndex.B2, 9)
  test_indPos(PositionsIndex.C2,10)
  test_indPos(PositionsIndex.D2,11)
  test_indPos(PositionsIndex.E2,12)
  test_indPos(PositionsIndex.F2,13)
  test_indPos(PositionsIndex.G2,14)
  test_indPos(PositionsIndex.H2,15) 
  test_indPos(PositionsIndex.A3,16)
  test_indPos(PositionsIndex.B3,17)
  test_indPos(PositionsIndex.C3,18)
  test_indPos(PositionsIndex.D3,19)
  test_indPos(PositionsIndex.E3,20)
  test_indPos(PositionsIndex.F3,21)
  test_indPos(PositionsIndex.G3,22)
  test_indPos(PositionsIndex.H3,23)
  test_indPos(PositionsIndex.A4,24)
  test_indPos(PositionsIndex.B4,25)
  test_indPos(PositionsIndex.C4,26)
  test_indPos(PositionsIndex.D4,27)
  test_indPos(PositionsIndex.E4,28)
  test_indPos(PositionsIndex.F4,29)
  test_indPos(PositionsIndex.G4,30)
  test_indPos(PositionsIndex.H4,31)
  test_indPos(PositionsIndex.A5,32)
  test_indPos(PositionsIndex.B5,33)
  test_indPos(PositionsIndex.C5,34)
  test_indPos(PositionsIndex.D5,35)
  test_indPos(PositionsIndex.E5,36)
  test_indPos(PositionsIndex.F5,37)
  test_indPos(PositionsIndex.G5,38)
  test_indPos(PositionsIndex.H5,39)
  test_indPos(PositionsIndex.A6,40)
  test_indPos(PositionsIndex.B6,41)
  test_indPos(PositionsIndex.C6,42)
  test_indPos(PositionsIndex.D6,43)
  test_indPos(PositionsIndex.E6,44)
  test_indPos(PositionsIndex.F6,45)
  test_indPos(PositionsIndex.G6,46)
  test_indPos(PositionsIndex.H6,47)
  test_indPos(PositionsIndex.A7,48)
  test_indPos(PositionsIndex.B7,49)
  test_indPos(PositionsIndex.C7,50)
  test_indPos(PositionsIndex.D7,51)
  test_indPos(PositionsIndex.E7,52)
  test_indPos(PositionsIndex.F7,53)
  test_indPos(PositionsIndex.G7,54)
  test_indPos(PositionsIndex.H7,55) 
  test_indPos(PositionsIndex.A8,56)
  test_indPos(PositionsIndex.B8,57)
  test_indPos(PositionsIndex.C8,58)
  test_indPos(PositionsIndex.D8,59)
  test_indPos(PositionsIndex.E8,60)
  test_indPos(PositionsIndex.F8,61)
  test_indPos(PositionsIndex.G8,62)
  test_indPos(PositionsIndex.H8,63)

  echo passMsg()
