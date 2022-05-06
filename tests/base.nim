import strutils

func errorMsg*(message: string): string=
  ## Generates red error text to be printed to terminal
  return "\n\e[1;31m"&message&"\e[0m"

func infoMsg*(message: string): string=
  ## Generates yellow info text to be printed to terminal
  return "\n\e[1;33m"&message&"\e[0m"

func passMsg*(): string=
  ## Generates greeen text to indicate test was passed
  return "\n\e[1;32mPASSED!\e[0m"

func expectMsg*(error: string, got: string, expect: string): string=
  ## Formats message to be printed to terminal after an error
  ## `error`: The error message formatted for the terminal
  ## `got`:   The incorrect result that was gotten
  ## `expect`: The correct result
  return """$#
Got:
$#
Expected:
$#""" % [error, got, expect]

template assertVal*(value, expected, error: untyped): untyped=
  ## helper function to help write testcases
  doAssert value==expected,
    expectMsg(errorMsg(error), $value, $expected)

