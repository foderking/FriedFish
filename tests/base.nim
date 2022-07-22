import strutils
import ../util

func errorMsg*(message: string): string=
  ## Generates red error text to be printed to terminal
  return "\n\e[1;31m"&message&"\e[0m"

func infoMsg*(message: string): string=
  ## Generates yellow info text to be printed to terminal
  return "\e[1;33m"&message&"\e[0m"

func passMsg*(): string=
  ## Generates greeen text to indicate test was passed
  return "\e[1;32mPASSED!\e[0m"

func testMsg*(message: string): string=
  return "\e[1;34m"&message&"\e[0m"

func expectMsg*(error: string, got: string, expect: string): string=
  ## Formats message to be printed to terminal after an error
  ## `error`: The error message formatted for the terminal
  ## `got`:   The incorrect result that was gotten
  ## `expect`: The correct result
  return """$#
$#: $#
$#: $#
""" % [errorMsg(error.capitalizeAscii), infoMsg("Got     "),
       got, infoMsg("Expected"), expect]

proc startTest*(msg: string)=
  echo ""
  #echo repeat('=',40)
  echo msg.toUpper
  echo repeat('=',20)

template assertVal*(value, expected, error: untyped, d: bool): untyped=
  ## helper function to help write testcases
  if d: echo infoMsg("Testing "&astToStr(value))
  let ans = value
  doAssert ans==expected, expectMsg(error, $(ans), $expected)

template assertBitboard*(value, expected, error: untyped, d: bool): untyped=
  ## helper function to help write testcases
  if d: echo infoMsg("\rTesting "&astToStr(value))
  let ans = value
  doAssert ans==expected, expectMsg(error&"\n"&value.prettyBitboard&"\n\n"&expected.prettyBitboard,
                                    ans.toHex, expected.toHex)

template doTest*(msg: string, test: untyped): untyped=
  echo testMsg("TESTING "&msg)
  #echo testMsg(repeat('=', 10))
  test
  echo passMsg()

template doTest*(test: untyped, msg: string): untyped=
  echo testMsg("TESTING "&msg)
  #echo testMsg(repeat('=', 10))
  test
  echo passMsg()

template testFieldLookup(fieldtype: typed, fieldLookup: typed, name: string, n: int, debug: bool)=
  ## Tests the mapping for a move fieldtype
  ## Each fieldtype has a Lookup array associated with it,.
  ## in the lookup array, every type is an element, and the indices is the numerical rep of the type
  ## for example `PromotionField` lookup has numerical rep:
  ##   Rook = 0, Bishop = 1, Knight = 2, Queen = 3
  ## The lookup would have the type indexed by its numerical rep
  ##
  ## Because of this, the following properties hold
  ## field.ord => index in lookup => field
  ## - The ordinal of the type would give its index in the lookup
  ## - The index in the lookup would give the type back
  ##
  ## this is an inverse mapping
  ##        type->number->type Mapping
  ##        ==========================
  ##                                       (lookup)
  ##            fieldtype ==> fieldtype.ord  ==>  fieldtype
  ##
  ##        number->type->number Mapping
  ##        ===========================
  ##        where `fieldvalue` is the numerical rep of the type
  ##                      (lookup)
  ##           fieldvalue ====>  fieldtype ==> fieldtype.ord


  # mapping type => number => type
  for field in fieldtype:
    assertval(fieldLookup[field.ord], field,
             "wrong type->number->type mapping for `"&name&"` at "&($field), debug)
  # mapping number => type => number
  # 0..n is the range of numerical reps of the type
  for number in 0..<n:
    assertval(fieldLookup[number].ord, number,
             "wrong number->type->number mapping for `"&name&"` with "&($number), debug)

