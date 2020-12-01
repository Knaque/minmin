import httpclient, json, options, jsonaccessors, prospect, strformat, asyncdispatch

const key {.strdefine.}: string = ""
when key == "":
  {.fatal: "Please supply your Hypixel API key with -d:key=\"<key>\" when compiling.".}

proc getUuid*(client: AsyncHttpClient, username: string): Future[Option[string]] {.async.} =
  let request = await client.get(
    fmt"https://api.mojang.com/users/profiles/minecraft/{username}"
  )
  if request.code == Http200:
    let body = await request.body
    return some(body.parseJson()["id"].getStr())
  return none(string)

proc getStats*(client: AsyncHttpClient, uuid: string): Future[Option[Stats]] {.async.} =
  let request = await client.get(
    fmt"https://api.hypixel.net/player?key={key}&uuid={uuid}"
  )
  let body = await request.body
  let stats = body.parseJson()["player"]

  var prospect: Stats

  try:
    prospect.displayname = stats.getDisplayname()
  except:
    return none(Stats)
  
  prospect.network_level = stats.getNetworkLevel()
  prospect.skywars.star = stats.getSkywarsStar()
  prospect.skywars.kdr = stats.getSkywarsKdr()
  prospect.bedwars.star = stats.getBedwarsStar()
  prospect.bedwars.fkdr = stats.getBedwarsFkdr()
  prospect.duels.wins = stats.getDuelsWins()
  prospect.duels.wlr = stats.getDuelsWlr()

  return some(prospect)