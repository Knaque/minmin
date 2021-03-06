import leveling, json, math, times, strutils

proc getNetworkLevel*(stats: JsonNode): float =
  var networkExp = 0.0
  try: networkExp = stats["networkExp"].getFloat()
  except: discard
  var networkLevel = 0.0
  try: networkLevel = stats["networkLevel"].getFloat()
  except: discard
  return leveling.getNetworkLevel(networkExp, networkLevel)

proc getSkywarsStar*(stats: JsonNode): int =
  try:
    stats["achievements"]["skywars_you_re_a_star"].getInt()
  except:
    0

proc getSkywarsKdr*(stats: JsonNode): float =
  try:
    let kills = stats["stats"]["SkyWars"]["kills"].getInt()
    let deaths = stats["stats"]["SkyWars"]["deaths"].getInt()
    return kills / deaths
  except:
    return 0.0

proc getBedwarsStar*(stats: JsonNode): int =
  try:
    stats["achievements"]["bedwars_level"].getInt()
  except:
    0

proc getBedwarsFkdr*(stats: JsonNode): float =
  try:
    let fkills = stats["stats"]["Bedwars"]["final_kills_bedwars"].getInt()
    let fdeaths = stats["stats"]["Bedwars"]["final_deaths_bedwars"].getInt()
    return fkills / fdeaths
  except:
    return 0.0

proc getDuelsWins*(stats: JsonNode): int =
  try:
    stats["stats"]["Duels"]["wins"].getInt()
  except:
    0

proc getDuelsWlr*(stats: JsonNode): float =
  try:
    let wins = stats["stats"]["Duels"]["wins"].getInt()
    let loss = stats["stats"]["Duels"]["losses"].getInt()
    return wins / loss
  except:
    return 0.0

proc getDisplayname*(stats: JsonNode): string =
  stats["displayname"].getStr()

proc getGexpInfo*(g: JsonNode, uuid: string): tuple[state: bool, sum: int] =
  if $g == "null": return (false, 0)

  var state = false
  var s: seq[int]
  for member in g["members"].getElems():
    if member["uuid"].getStr() == uuid:
      if inDays(now() - member["joined"].`$`[0..9].parseInt().fromUnix().local()) > 6: state = true
      for _, day in member["expHistory"].pairs:
        s.add(day.getInt(0))
      break
  return (state, sum(s))