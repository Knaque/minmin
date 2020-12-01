import leveling, json

proc getNetworkLevel*(stats: JsonNode): float =
  var networkExp = 0.0
  try: networkExp = stats["networkExp"].getFloat()
  except: discard
  var networkLevel = 0.0
  try: networkLevel = stats["networkLevel"].getFloat()
  except: discard
  return leveling.getNetworkLevel(networkExp, networkLevel)

proc getSkywarsStar*(stats: JsonNode): int =
  stats["achievements"]["skywars_you_re_a_star"].getInt()

proc getSkywarsKdr*(stats: JsonNode): float =
  let kills = stats["stats"]["SkyWars"]["kills"].getInt()
  let deaths = stats["stats"]["SkyWars"]["deaths"].getInt()
  return kills / deaths

proc getBedwarsStar*(stats: JsonNode): int =
  stats["achievements"]["bedwars_level"].getInt()

proc getBedwarsFkdr*(stats: JsonNode): float =
  let fkills = stats["stats"]["Bedwars"]["final_kills_bedwars"].getInt()
  let fdeaths = stats["stats"]["Bedwars"]["final_deaths_bedwars"].getInt()
  return fkills / fdeaths

proc getDuelsWins*(stats: JsonNode): int =
  stats["stats"]["Duels"]["wins"].getInt()

proc getDuelsWlr*(stats: JsonNode): float =
  let wins = stats["stats"]["Duels"]["wins"].getInt()
  let loss = stats["stats"]["Duels"]["losses"].getInt()
  return wins / loss

proc getDisplayname*(stats: JsonNode): string =
  stats["displayname"].getStr()