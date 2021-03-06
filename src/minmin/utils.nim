from dimscord import Embed
import options, strutils, math

proc boolToEmoji*(c: bool): string =
  case c
  of true: ":white_check_mark:"
  of false: ":x:"

proc boolToColor*(c: bool): int =
  case c
  of true: 3066993
  of false: 15158332

proc errorEmbed*(title, description: string): Embed =
  result.title = some(title)
  result.description = some(description)

proc pretty*(x: int): string = ($x).insertSep(',')
proc pretty*(x: float): string =
  let (a, b) = (x.`$`.split('.')[0], x.`$`.split('.')[1])
  return [a.insertSep(','), b].join(".")

proc roundDown*(n: float, decimals: Positive = 1): float = 
  let multiplier = 10 ^ decimals
  return floor(n * multiplier.toFloat) / multiplier.toFloat

func escapeUnderscores*(s: string): string {.inline.} = s.replace("_", "\\_")