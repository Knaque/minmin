import dimscord, asyncdispatch, strutils, options, httpclient, tables, times
import minmin/[apicalls, utils, prospect]

const token {.strdefine.}: string = ""
when token == "":
  {.fatal: "Please supply your Discord bot token with -d:token=\"<token>\" when compiling.".}

var bot = newDiscordClient(token)

var client = newAsyncHttpClient()

var
  cache = initTable[string, Stats]()
  last_cache_init = now()

bot.events.on_ready = proc (s: Shard, r: Ready) {.async.} =
  echo "Ready to rumble!"

bot.events.message_create = proc (s: Shard, m: Message) {.async.} =
  if m.author.bot: return
  if m.content.startsWith(".m "):

    let query = m.content.split()[1].toLower()
    debugEcho "queried " & query & " by " & m.author.username
    var prospect: Stats
    var embed: Embed

    if cache.hasKey(query):
      debugEcho "found " & query & " in cache"
      prospect = cache[query]
    else:
      debugEcho query & " not found in cache, getting uuid"
      let uuid = await client.getUuid(query)
      if uuid.isNone():
        discard await bot.api.sendMessage(m.channel_id, embed=some(notFoundEmbed()))
        return
      
      debugEcho "getting stats of " & query
      let stats = await client.getStats(uuid.get())
      if stats.isNone():
        discard await bot.api.sendMessage(m.channel_id, embed=some(notFoundEmbed()))
        return
      prospect = stats.get()
      debugEcho "storing " & query & " in cache"
      cache[query] = prospect

    let qualifies = prospect.meetsAll()
    embed.title = some(prospect.displayname & " " & qualifies.boolToEmoji())
    embed.color = some(qualifies.boolToColor())
    embed.fields = some(
      @[
        EmbedField(
          name: "Network Level",
          value: prospect.meetsNetwork().boolToEmoji()
        ),
        EmbedField(
          name: "Skywars",
          value: prospect.meetsSkywars().boolToEmoji()
        ),
        EmbedField(
          name: "Bedwars",
          value: prospect.meetsBedwars().boolToEmoji()
        ),
        EmbedField(
          name: "Duels",
          value: prospect.meetsDuels().boolToEmoji()
        )
      ]
    )
    debugEcho "sending results for " & query
    discard await bot.api.sendMessage(m.channel_id, embed=some(embed))

    if inMinutes(now() - last_cache_init) > 30:
      debugEcho "clearing cache"
      cache = initTable[string, Stats]()

waitFor bot.startSession()