import dimscord, asyncdispatch, strutils, options, httpclient, tables, times
import minmin/[apicalls, utils, prospect]

const token {.strdefine.}: string = ""
if token == "":
  quit("Please supply your Discord bot token with -d:token=\"<token>\" when compiling.", QuitFailure)

var bot = newDiscordClient(token)

var
  cache = initTable[string, Prospect]()
  last_cache_init = now()

bot.events.on_ready = proc (s: Shard, r: Ready) {.async.} =
  echo "Ready to rumble!"

bot.events.message_create = proc (s: Shard, m: Message) {.async.} =
  if m.author.bot: return
  if m.content.startsWith(".m "):
    var botmsg = await bot.api.sendMessage(m.channel_id, "Working on it...")

    var client = newAsyncHttpClient()

    let query = m.content.split()[^1].toLower()
    echo "queried " & query & " by " & m.author.username
    var prospect: Prospect
    prospect.exists = true
    prospect.hypixel = true
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
        let
          e = getCurrentException()
          msg = getCurrentExceptionMsg()
        echo "/!\\ got exception ", repr(e), " with message ", msg
        discard await bot.api.editMessage(m.channel_id, botmsg.id, embed=some(
          errorEmbed(
            "Something went wrong",
            "Try again later."
            )
          )
        )
        return
      if uuid.isNone():
        prospect.exists = false

      if prospect.exists:
        echo "getting stats of " & query
        var stats: Option[Prospect]
        try:
          stats = await client.getProspect(uuid.get())
        except:
          let
            e = getCurrentException()
            msg = getCurrentExceptionMsg()
          echo "/!\\ got exception ", repr(e), " with message ", msg
          discard await bot.api.editMessage(m.channel_id, botmsg.id, embed=some(
            errorEmbed(
              "Something went wrong",
              "Try again later."
              )
            )
          )
          return
        if stats.isNone():
          prospect.hypixel = false
        else:
          prospect = stats.get()
      echo "storing " & query & " in cache"
      cache[query] = prospect

    echo "sending results for " & query
    if not prospect.exists:
      discard await bot.api.editMessage(m.channel_id, botmsg.id, embed=some(
        errorEmbed(
          "Player does not exist",
          "You might have made a typo."
          )
        )
      )
      return
    elif not prospect.hypixel:
      discard await bot.api.editMessage(m.channel_id, botmsg.id, embed=some(
        errorEmbed(
          "Player has never been on Hypixel",
          "You might have made a typo."
          )
        )
      )
      return
    else:
      let qualifies = prospect.meetsAll()
      embed.title = some(qualifies.boolToEmoji() & " - " & prospect.displayname)
      embed.color = some(qualifies.boolToColor())
      var fields = @[
        EmbedField(
          name: "Network Level",
          value: prospect.meetsNetwork().boolToEmoji() & " - " & roundDown(prospect.network_level, 2).pretty() & ":earth_asia:"
        ),
        EmbedField(
          name: "Skywars",
          value: prospect.meetsSkywars().boolToEmoji() & " - " & prospect.skywars.star.pretty() & ":star: " & roundDown(prospect.skywars.kdr, 2).pretty() & ":crossed_swords:"
        ),
        EmbedField(
          name: "Bedwars",
          value: prospect.meetsBedwars().boolToEmoji() & " - " & prospect.bedwars.star.pretty() & ":star: " & roundDown(prospect.bedwars.fkdr, 2).pretty() & ":crossed_swords:"
        ),
        EmbedField(
          name: "Duels",
          value: prospect.meetsDuels().boolToEmoji() & " - " & prospect.duels.wins.pretty() & ":crown: " & roundDown(prospect.duels.wlr, 2).pretty() & ":crossed_swords:"
        )
      ]
      if prospect.guild:
        fields.add(
          EmbedField(
            name: "Weekly GEXP",
           value: prospect.meetsWeeklyGexp().boolToEmoji() & " - " & prospect.gexp.pretty() & ":sparkles:"
          )
        )
      embed.fields = some(fields)
      discard await bot.api.editMessage(m.channel_id, botmsg.id, embed=some(embed))

    if inMinutes(now() - last_cache_init) > 60:
      echo "clearing cache"
      cache = initTable[string, Prospect]()
      last_cache_init = now()
  if m.content == ".cc":
    echo "cache manually cleared by " & m.author.username
    cache = initTable[string, Prospect]()
    last_cache_init = now()
    

waitFor bot.startSession()