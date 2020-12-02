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
    echo "queried " & query & " by " & m.author.username
    var prospect: Stats
    var embed: Embed

    if cache.hasKey(query):
      echo "found " & query & " in cache"
      prospect = cache[query]
    else:
      echo query & " not found in cache, getting uuid"
      var uuid: Option[string]
      try:
        uuid = await client.getUuid(query)
      except:
        discard await bot.api.sendMessage(m.channel_id, embed=some(
          errorEmbed(
            "Something went wrong",
            "Try again later."
            )
          )
        )
        return
      if uuid.isNone():
        discard await bot.api.sendMessage(m.channel_id, embed=some(
          errorEmbed(
            "Player does not exist",
            "You might have made a typo."
            )
          )
        )
        return
      
      echo "getting stats of " & query
      var stats: Option[Stats]
      try:
        stats = await client.getStats(uuid.get())
      except:
        let
          e = getCurrentException()
          msg = getCurrentExceptionMsg()
        echo "/!\\ got exception ", repr(e), " with message ", msg
        discard await bot.api.sendMessage(m.channel_id, embed=some(
          errorEmbed(
            "Something went wrong",
            "Try again later."
            )
          )
        )
        return
      if stats.isNone():
        discard await bot.api.sendMessage(m.channel_id, embed=some(
          errorEmbed(
            "Player has never been on Hypixel",
            "You might have made a typo."
            )
          )
        )
        return
      prospect = stats.get()
      echo "storing " & query & " in cache"
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
    echo "sending results for " & query
    discard await bot.api.sendMessage(m.channel_id, embed=some(embed))

    if inMinutes(now() - last_cache_init) > 30:
      echo "clearing cache"
      cache = initTable[string, Stats]()

waitFor bot.startSession()