import httpclient, json, options, jsonaccessors, prospect, strformat, asyncdispatch

const key {.strdefine.}: string = ""
if key == "":
  quit("Please supply your Hypixel API key with -d:key=\"<key>\" when compiling.", QuitFailure)

proc getUuid*(client: AsyncHttpClient, username: string): Future[Option[string]] {.async.} =
  let request = await client.get(
    fmt"https://api.mojang.com/users/profiles/minecraft/{username}"
  )
  if request.code == Http200:
    let body = await request.body
    return some(body.parseJson()["id"].getStr())
  return none(string)

proc getProspect*(client: AsyncHttpClient, uuid: string): Future[Option[Prospect]] {.async.} =
  let playerdata = await client.get(
    fmt"https://api.hypixel.net/player?key={key}&uuid={uuid}"
  )
  let guilddata = await client.get(
    fmt"https://api.hypixel.net/guild?key={key}&player={uuid}"
  )
  let playerbody = await playerdata.body
  var stats: JsonNode
  try:
    stats = playerbody.parseJson()["player"]
  except Exception as e:
    echo playerbody
    raise newException(Exception, e.msg)

  let guildbody = await guilddata.body
  var guild: JsonNode
  try:
    guild = guildbody.parseJson()["guild"]
  except Exception as e:
    echo guildbody
    raise newException(Exception, e.msg)

  var prospect: Prospect

  try:
    prospect.displayname = stats.getDisplayname()
  except:
    return none(Prospect)
  
  prospect.exists = true
  prospect.hypixel = true
  prospect.network_level = stats.getNetworkLevel()
  prospect.skywars.star = stats.getSkywarsStar()
  prospect.skywars.kdr = stats.getSkywarsKdr()
  prospect.bedwars.star = stats.getBedwarsStar()
  prospect.bedwars.fkdr = stats.getBedwarsFkdr()
  prospect.duels.wins = stats.getDuelsWins()
  prospect.duels.wlr = stats.getDuelsWlr()
  (prospect.guild, prospect.gexp) = guild.getGexpInfo(uuid)

  return some(prospect)

proc getGuildMembers*(client: AsyncHttpClient, guild: string): Future[seq[string]] {.async.} =
  #! Doesn't work with spaces! This is okay for now.
  let guilddata = await client.get(
    fmt"https://api.hypixel.net/guild?key={key}&name={guild}"
  )
  let body = await guilddata.body
  let members = body.parseJson()["guild"]["members"]

  var uuids: seq[string]
  for member in members:
    uuids.add member["uuid"].getStr()
  
  return uuids

proc getUsername*(client: AsyncHttpClient, uuid: string): Future[string] {.async.} =
  #! Doesn't account for invalid uuids... Okay for now.
  let response = await client.get(
    fmt"https://api.mojang.com/user/profiles/{uuid}/names"
  )
  let body = await response.body
  for n in body.parseJson():
    result = n["name"].getStr()