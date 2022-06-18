import strutils

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

template assertVal*(value, expected, error: typed): typed=
  ## helper function to help write testcases
  echo infoMsg("Testing "&astToStr(value))
  let ans = value
  doAssert ans==expected, expectMsg(error, $(ans), $expected)

template doTest*(test: untyped, msg: string): untyped=
  echo testMsg("\nTESTING "&msg)
  echo testMsg(repeat('=', 10))
  test
  echo passMsg()
