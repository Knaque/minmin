import requirements

type
  SkywarsStats* = object
    star*: int
    kdr*: float
  BedwarsStats* = object
    star*: int
    fkdr*: float
  DuelsStats* = object
    wins*: int
    wlr*: float
  Prospect* = object
    exists*, hypixel*: bool
    displayname*: string
    network_level*: float
    skywars*: SkywarsStats
    bedwars*: BedwarsStats
    duels*: DuelsStats
    guild*: bool
    gexp*: int

func meetsNetwork*(p: Prospect): bool = p.network_level >= NETWORK_LEVEL

func meetsSkywars*(p: Prospect): bool = p.skywars.star >= SKYWARS_STAR and p.skywars.kdr >= SKYWARS_KDR

func meetsBedwars*(p: Prospect): bool = p.bedwars.star >= BEDWARS_STAR and p.bedwars.fkdr >= BEDWARS_FKDR

func meetsDuels*(p: Prospect): bool = p.duels.wins >= DUELS_WINS and p.duels.wlr >= DUELS_WLR

func meetsWeeklyGexp*(p: Prospect): bool = p.gexp >= WEEKLY_GEXP

func meetsExceptionGexp*(p: Prospect): bool = p.gexp >= EXCEPTION_GEXP

func meetsAll*(p: Prospect): bool =
  case p.guild
  of true:
    p.meetsNetwork and (
      p.meetsSkywars or
      p.meetsBedwars or
      p.meetsDuels or
      p.meetsExceptionGexp
    ) and
    p.meetsWeeklyGexp
  of false:
    p.meetsNetwork and (
      p.meetsSkywars or
      p.meetsBedwars or
      p.meetsDuels
    )