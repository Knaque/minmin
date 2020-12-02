from dimscord import Embed
import options

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