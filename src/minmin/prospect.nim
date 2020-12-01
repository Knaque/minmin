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
  Stats* = object
    displayname*: string
    network_level*: float
    skywars*: SkywarsStats
    bedwars*: BedwarsStats
    duels*: DuelsStats

func meetsNetwork*(p: Stats): bool = p.network_level >= NETWORK_LEVEL

func meetsSkywars*(p: Stats): bool = p.skywars.star >= SKYWARS_STAR and p.skywars.kdr >= SKYWARS_KDR

func meetsBedwars*(p: Stats): bool = p.bedwars.star >= BEDWARS_STAR and p.bedwars.fkdr >= BEDWARS_FKDR

func meetsDuels*(p: Stats): bool = p.duels.wins >= DUELS_WINS and p.duels.wlr >= DUELS_WLR

func meetsAll*(p: Stats): bool =
  p.meetsNetwork and (
    p.meetsSkywars or
    p.meetsBedwars or
    p.meetsDuels
  )