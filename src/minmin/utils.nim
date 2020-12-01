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

proc notFoundEmbed*(): Embed =
  result.title = some("Player not found")
  result.description = some("You might have made a typo.")