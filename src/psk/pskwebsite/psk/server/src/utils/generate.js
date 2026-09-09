/**
 * generate.js — deterministic content generation for the seed script.
 * A seeded PRNG keeps every reseed identical, which makes the demo
 * reproducible across machines.
 */

export function makeRng(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
export const pick = (arr, r) => arr[Math.floor(r() * arr.length)];
export const rint = (min, max, r) => Math.floor(r() * (max - min + 1)) + min;
export const slugify = (s) => s.toLowerCase()
  .replace(/[čć]/g, 'c').replace(/đ/g, 'd').replace(/š/g, 's').replace(/ž/g, 'z')
  .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

/* ================================================================== */
/* SPORTS                                                             */
/* ================================================================== */
export const SPORTS = [
  { slug: 'nogomet',      name: 'Nogomet',          icon: '⚽',  marketSet: '1x2' },
  { slug: 'kosarka',      name: 'Košarka',          icon: '🏀',  marketSet: '12' },
  { slug: 'tenis',        name: 'Tenis',            icon: '🎾',  marketSet: '12' },
  { slug: 'rukomet',      name: 'Rukomet',          icon: '🤾',  marketSet: '1x2' },
  { slug: 'odbojka',      name: 'Odbojka',          icon: '🏐',  marketSet: '12' },
  { slug: 'hokej',        name: 'Hokej na ledu',    icon: '🏒',  marketSet: '1x2' },
  { slug: 'stolni-tenis', name: 'Stolni tenis',     icon: '🏓',  marketSet: '12' },
  { slug: 'esport',       name: 'E-sport',          icon: '🎮',  marketSet: '12' },
  { slug: 'boks',         name: 'Boks',             icon: '🥊',  marketSet: '12' },
  { slug: 'mma',          name: 'MMA / UFC',        icon: '🥋',  marketSet: '12' },
  { slug: 'formula-1',    name: 'Formula 1',        icon: '🏎️', marketSet: 'outright' },
  { slug: 'moto-gp',      name: 'Moto GP',          icon: '🏍️', marketSet: 'outright' },
  { slug: 'pikado',       name: 'Pikado',           icon: '🎯',  marketSet: '12' },
  { slug: 'snooker',      name: 'Snooker',          icon: '🎱',  marketSet: '12' },
  { slug: 'golf',         name: 'Golf',             icon: '⛳',  marketSet: 'outright' },
  { slug: 'biciklizam',   name: 'Biciklizam',       icon: '🚴',  marketSet: 'outright' },
  { slug: 'ragbi',        name: 'Ragbi',            icon: '🏉',  marketSet: '1x2' },
  { slug: 'am-nogomet',   name: 'Američki nogomet', icon: '🏈',  marketSet: '12' },
  { slug: 'bejzbol',      name: 'Bejzbol',          icon: '⚾',  marketSet: '12' },
  { slug: 'vaterpolo',    name: 'Vaterpolo',        icon: '🤽',  marketSet: '1x2' },
  { slug: 'atletika',     name: 'Atletika',         icon: '🏃',  marketSet: 'outright' },
  { slug: 'skijanje',     name: 'Skijanje',         icon: '⛷️', marketSet: 'outright' },
  { slug: 'ski-skokovi',  name: 'Ski skokovi',      icon: '🎿',  marketSet: 'outright' },
  { slug: 'biatlon',      name: 'Biatlon',          icon: '🎽',  marketSet: 'outright' },
  { slug: 'sah',          name: 'Šah',              icon: '♟️', marketSet: '1x2' },
  { slug: 'futsal',       name: 'Futsal',           icon: '🥅',  marketSet: '1x2' },
  { slug: 'badminton',    name: 'Badminton',        icon: '🏸',  marketSet: '12' },
  { slug: 'kuglanje',     name: 'Kuglanje',         icon: '🎳',  marketSet: '12' },
  { slug: 'konjicke-utrke', name: 'Konjičke utrke', icon: '🐎',  marketSet: 'outright' },
  { slug: 'zabava',       name: 'Svijet zabave',    icon: '🎬',  marketSet: '12' }
];

/* ================================================================== */
/* LEAGUES — keyed by sport slug                                      */
/* ================================================================== */
export const LEAGUES = {
  nogomet: [
    ['hnl', 'HNL', '🇭🇷'], ['hrvatski-kup', 'Hrvatski kup', '🇭🇷'],
    ['liga-prvaka', 'Liga prvaka', '🇪🇺'], ['europska-liga', 'Europska liga', '🇪🇺'],
    ['konferencijska-liga', 'Konferencijska liga', '🇪🇺'],
    ['premier-liga', 'Engleska - Premier liga', '🏴'], ['championship', 'Engleska - Championship', '🏴'],
    ['la-liga', 'Španjolska - La Liga', '🇪🇸'], ['serie-a', 'Italija - Serie A', '🇮🇹'],
    ['bundesliga', 'Njemačka - Bundesliga', '🇩🇪'], ['ligue-1', 'Francuska - Ligue 1', '🇫🇷'],
    ['primeira-liga', 'Portugal - Primeira Liga', '🇵🇹'], ['eredivisie', 'Nizozemska - Eredivisie', '🇳🇱'],
    ['super-lig', 'Turska - Süper Lig', '🇹🇷'], ['pro-liga-be', 'Belgija - Pro liga', '🇧🇪'],
    ['bundesliga-at', 'Austrija - Bundesliga', '🇦🇹'], ['superliga-rs', 'Srbija - Superliga', '🇷🇸'],
    ['snl', 'Slovenija - 1. SNL', '🇸🇮'], ['premijer-liga-ba', 'BiH - Premijer liga', '🇧🇦'],
    ['mls', 'SAD - MLS', '🇺🇸'], ['brasileirao', 'Brazil - Serie A', '🇧🇷'],
    ['liga-profesional', 'Argentina - Liga Profesional', '🇦🇷'], ['j1-liga', 'Japan - J1 liga', '🇯🇵'],
    ['saudi-pro-liga', 'Saudijska Arabija - Pro liga', '🇸🇦'], ['a-liga', 'Australija - A-liga', '🇦🇺']
  ],
  kosarka: [
    ['nba', 'NBA', '🇺🇸'], ['euroliga', 'Euroliga', '🇪🇺'], ['eurokup', 'Eurokup', '🇪🇺'],
    ['aba-liga', 'ABA liga', '🌍'], ['premijer-liga-hr', 'Hrvatska - Premijer liga', '🇭🇷'],
    ['acb', 'Španjolska - ACB', '🇪🇸'], ['lega-a', 'Italija - Lega A', '🇮🇹'], ['ncaa', 'NCAA', '🇺🇸']
  ],
  tenis: [
    ['atp-tour', 'ATP Tour', '🎾'], ['wta-tour', 'WTA Tour', '🎾'], ['grand-slam', 'Grand Slam', '🏆'],
    ['challenger', 'ATP Challenger', '🎾'], ['itf', 'ITF', '🎾'], ['davis-cup', 'Davis Cup', '🌍']
  ],
  rukomet: [
    ['ehf-liga-prvaka', 'EHF Liga prvaka', '🇪🇺'], ['premijer-liga-hr', 'Hrvatska - Premijer liga', '🇭🇷'],
    ['hbl', 'Njemačka - Bundesliga', '🇩🇪'], ['asobal', 'Španjolska - Asobal', '🇪🇸'], ['seha', 'SEHA liga', '🌍']
  ],
  odbojka: [
    ['cev-liga-prvaka', 'CEV Liga prvaka', '🇪🇺'], ['superlega', 'Italija - SuperLega', '🇮🇹'],
    ['plusliga', 'Poljska - PlusLiga', '🇵🇱'], ['superliga-hr', 'Hrvatska - Superliga', '🇭🇷']
  ],
  hokej: [['nhl', 'NHL', '🇺🇸'], ['khl', 'KHL', '🌍'], ['ice-liga', 'ICE liga', '🇦🇹'], ['shl', 'Švedska - SHL', '🇸🇪']],
  esport: [
    ['lec', 'League of Legends - LEC', '🎮'], ['lck', 'League of Legends - LCK', '🎮'],
    ['cs2', 'Counter-Strike 2', '🎮'], ['dota-2', 'Dota 2', '🎮'],
    ['valorant', 'Valorant', '🎮'], ['rocket-league', 'Rocket League', '🎮']
  ],
  'stolni-tenis': [['tt-elite', 'TT Elite Series', '🏓'], ['liga-pro', 'Češka - Liga Pro', '🇨🇿']],
  boks: [['wbc-wba', 'WBC / WBA borbe', '🥊']],
  mma: [['ufc', 'UFC', '🥋'], ['bellator', 'Bellator', '🥋']],
  pikado: [['pdc', 'PDC World Series', '🎯']],
  snooker: [['world-snooker-tour', 'World Snooker Tour', '🎱']],
  ragbi: [['six-nations', 'Six Nations', '🏉']],
  'am-nogomet': [['nfl', 'NFL', '🏈'], ['ncaaf', 'NCAA Football', '🏈']],
  bejzbol: [['mlb', 'MLB', '⚾']],
  vaterpolo: [['prva-liga-hr', 'Hrvatska - Prva liga', '🇭🇷'], ['len-liga-prvaka', 'LEN Liga prvaka', '🇪🇺']],
  futsal: [['hmnl', 'Hrvatska - 1. HMNL', '🇭🇷']],
  badminton: [['bwf', 'BWF World Tour', '🏸']],
  kuglanje: [['hrvatska-liga', 'Hrvatska liga', '🎳']],
  sah: [['fide-grand-prix', 'FIDE Grand Prix', '♟️']],
  'formula-1': [['f1-sezona', 'Formula 1 - Sezona', '🏎️']],
  'moto-gp': [['motogp-sezona', 'MotoGP - Sezona', '🏍️']],
  golf: [['pga-tour', 'PGA Tour', '⛳']],
  biciklizam: [['grand-tour', 'Grand Tour', '🚴']],
  atletika: [['diamond-league', 'Diamond League', '🏃']],
  skijanje: [['fis-svjetski-kup', 'FIS Svjetski kup', '⛷️']],
  'ski-skokovi': [['fis-skokovi', 'FIS Svjetski kup - skokovi', '🎿']],
  biatlon: [['ibu-svjetski-kup', 'IBU Svjetski kup', '🎽']],
  'konjicke-utrke': [['uk-utrke', 'UK utrke', '🐎']],
  zabava: [['tv-dogadanja', 'TV i događanja', '🎬']]
};

/* ================================================================== */
/* COMPETITOR POOLS — keyed by league slug                            */
/* ================================================================== */
export const TEAMS = {
  hnl: ['Dinamo Z.','Hajduk','Rijeka','Osijek','Gorica','Slaven B.','Lokomotiva','Varaždin','Istra 1961','Šibenik'],
  'hrvatski-kup': ['Dinamo Z.','Hajduk','Rijeka','Osijek','Cibalia','Dugopolje','Rudeš','Orijent'],
  'liga-prvaka': ['Real Madrid','Man City','Bayern','PSG','Inter','Arsenal','Barcelona','Liverpool','Milan','Atletico','Dortmund','Napoli'],
  'europska-liga': ['Roma','Leverkusen','Ajax','Benfica','Rangers','Betis','Lyon','Fenerbahče'],
  'konferencijska-liga': ['Fiorentina','Rijeka','Gent','Legia','Aston Villa','Basel'],
  'premier-liga': ['Arsenal','Man City','Liverpool','Chelsea','Tottenham','Man United','Newcastle','Aston Villa','Brighton','West Ham','Everton','Fulham'],
  championship: ['Leeds','Southampton','Norwich','Sunderland','Middlesbrough','Cardiff','Stoke','Hull'],
  'la-liga': ['Real Madrid','Barcelona','Atletico','Sevilla','Villarreal','Real Sociedad','Valencia','Betis','Athletic','Girona'],
  'serie-a': ['Inter','Milan','Juventus','Napoli','Roma','Lazio','Atalanta','Fiorentina','Torino','Bologna'],
  bundesliga: ['Bayern','Dortmund','Leipzig','Leverkusen','Frankfurt','Stuttgart','Wolfsburg','Freiburg','Union Berlin'],
  'ligue-1': ['PSG','Marseille','Monaco','Lyon','Lille','Nice','Rennes','Lens'],
  'primeira-liga': ['Benfica','Porto','Sporting','Braga','Vitoria SC'],
  eredivisie: ['Ajax','PSV','Feyenoord','AZ Alkmaar','Twente','Utrecht'],
  'super-lig': ['Galatasaray','Fenerbahče','Bešiktaš','Trabzonspor','Bašakšehir'],
  'pro-liga-be': ['Club Brugge','Anderlecht','Genk','Gent','Antwerp'],
  'bundesliga-at': ['Salzburg','Sturm Graz','Rapid Beč','Austria Beč','LASK'],
  'superliga-rs': ['Crvena zvezda','Partizan','Vojvodina','Čukarički','TSC'],
  snl: ['Olimpija','Maribor','Celje','Koper','Bravo'],
  'premijer-liga-ba': ['Zrinjski','Sarajevo','Željezničar','Borac','Široki Brijeg'],
  mls: ['Inter Miami','LAFC','LA Galaxy','Seattle','Atlanta Utd','NY Red Bulls'],
  brasileirao: ['Flamengo','Palmeiras','Corinthians','Sao Paulo','Gremio','Fluminense'],
  'liga-profesional': ['Boca Juniors','River Plate','Racing','Independiente','San Lorenzo'],
  'j1-liga': ['Kawasaki','Urawa','Kashima','Yokohama FM','Gamba Osaka'],
  'saudi-pro-liga': ['Al Hilal','Al Nassr','Al Ittihad','Al Ahli'],
  'a-liga': ['Melbourne City','Sydney FC','Western United','Adelaide'],
  nba: ['Boston','LA Lakers','Denver','Milwaukee','Golden State','Miami','Phoenix','Philadelphia','Dallas','New York','Oklahoma City','Cleveland'],
  euroliga: ['Real Madrid','Panathinaikos','Olympiacos','Fenerbahče','Barcelona','Monaco','Maccabi','Partizan','Crvena zvezda','Efes'],
  eurokup: ['Bahčešehir','Hapoel TA','Paris','Valencia','Turk Telekom'],
  'aba-liga': ['Cibona','Zadar','Split','Crvena zvezda','Partizan','Cedevita Olimpija','Igokea','Mega'],
  'premijer-liga-hr': ['Cibona','Zadar','Split','Cedevita Junior','Šibenka','Zabok'],
  acb: ['Real Madrid','Barcelona','Baskonia','Unicaja','Valencia','Gran Canaria'],
  'lega-a': ['Virtus Bologna','Olimpia Milano','Venezia','Brescia','Tortona'],
  ncaa: ['Duke','Kansas','Kentucky','UCLA','Gonzaga','North Carolina'],
  'atp-tour': ['Sinner','Alcaraz','Djoković','Medvedev','Zverev','Rune','Ruud','Fritz','Tsitsipas','Rublev','Ćorić','Musetti'],
  'wta-tour': ['Swiatek','Sabalenka','Gauff','Rybakina','Pegula','Vondrousova','Jabeur','Zheng'],
  'grand-slam': ['Sinner','Alcaraz','Djoković','Zverev','Swiatek','Sabalenka','Gauff','Medvedev'],
  challenger: ['Prižmić','Ajduković','Serdarušić','Poljičak','Mrva','Kovačević'],
  itf: ['Petrović','Novak','Kovač','Horvat','Marić'],
  'davis-cup': ['Hrvatska','Italija','Španjolska','Srbija','Australija','SAD'],
  'ehf-liga-prvaka': ['Barcelona','Kiel','Magdeburg','PSG','Veszprem','Aalborg','Zagreb'],
  hbl: ['Kiel','Magdeburg','Flensburg','Rhein-Neckar','Fuchse Berlin'],
  asobal: ['Barcelona','Granollers','Bidasoa','Logrono'],
  seha: ['Zagreb','Vardar','Nexe','Tatran','Vojvodina'],
  'cev-liga-prvaka': ['Perugia','Trentino','Zaksa','Jastrzebski','Zenit'],
  superlega: ['Perugia','Trentino','Civitanova','Modena','Milano'],
  plusliga: ['Zaksa','Jastrzebski','Resovia','Projekt Warszawa'],
  'superliga-hr': ['Mladost','Kaštela','Rijeka','Osijek'],
  nhl: ['Boston','Colorado','Toronto','Edmonton','Vegas','Rangers','Florida','Dallas'],
  khl: ['CSKA','SKA','Ak Bars','Metallurg','Dynamo M.'],
  'ice-liga': ['Salzburg','KAC','Vienna Capitals','Bolzano','Medveščak'],
  shl: ['Frolunda','Skelleftea','Lulea','Farjestad'],
  lec: ['G2 Esports','Fnatic','MAD Lions','Team Vitality','Rogue','SK Gaming'],
  lck: ['T1','Gen.G','Hanwha Life','DRX','KT Rolster'],
  cs2: ['NAVI','FaZe','Vitality','G2','Spirit','MOUZ','Astralis'],
  'dota-2': ['Team Spirit','Gaimin Gladiators','LGD','Tundra','OG'],
  valorant: ['Sentinels','Fnatic','LOUD','DRX','Paper Rex'],
  'rocket-league': ['Karmine Corp','G2','Team BDS','NRG'],
  'tt-elite': ['Kaczmarek','Nowak','Kowalski','Wisniewski','Zielinski'],
  'liga-pro': ['Novak','Svoboda','Dvorak','Cerny','Prochazka'],
  'wbc-wba': ['Usyk','Fury','Joshua','Wilder','Dubois','Hrgović'],
  ufc: ['Makhachev','Volkanovski','Pereira','Adesanya','O’Malley','Topuria'],
  bellator: ['Amosov','Storley','Nemkov','Bader'],
  pdc: ['Humphries','Littler','Van Gerwen','Price','Aspinall','Smith'],
  'world-snooker-tour': ['O’Sullivan','Trump','Selby','Robertson','Murphy','Allen'],
  'six-nations': ['Irska','Francuska','Engleska','Škotska','Wales','Italija'],
  nfl: ['Chiefs','49ers','Ravens','Bills','Cowboys','Eagles','Lions','Dolphins'],
  ncaaf: ['Alabama','Georgia','Michigan','Ohio State','Texas'],
  mlb: ['Yankees','Dodgers','Astros','Braves','Red Sox','Mets'],
  'prva-liga-hr': ['Jug AO','Mladost','Primorje','Šibenik'],
  'len-liga-prvaka': ['Pro Recco','Novi Beograd','Jug AO','Ferencvaros','Olympiacos'],
  hmnl: ['Futsal Dinamo','Olmissum','Novo Vrijeme','Split Tommy'],
  bwf: ['Axelsen','Momota','An Se-young','Marin','Antonsen'],
  'hrvatska-liga': ['Zaprešić','Zagreb','Rijeka','Poštar'],
  'fide-grand-prix': ['Carlsen','Nakamura','Caruana','Ding','Nepomnjašči','Firouzja'],
  'tv-dogadanja': ['Kandidat A','Kandidat B','Kandidat C','Kandidat D']
};

export const OUTRIGHT_FIELDS = {
  'f1-sezona':        ['Verstappen','Norris','Leclerc','Piastri','Hamilton','Russell','Sainz','Perez','Alonso'],
  'motogp-sezona':    ['Bagnaia','Martin','Marquez','Bastianini','Vinales','Acosta'],
  'pga-tour':         ['Scheffler','McIlroy','Rahm','Schauffele','Hovland','Koepka'],
  'grand-tour':       ['Pogačar','Vingegaard','Evenepoel','Roglič','Van Aert','Philipsen'],
  'diamond-league':   ['Duplantis','Lyles','Warholm','Ingebrigtsen','Barshim'],
  'fis-svjetski-kup': ['Odermatt','Kristoffersen','Braathen','Kilde','Zubčić'],
  'fis-skokovi':      ['Kobayashi','Lanišek','Kraft','Tschofenig','Prevc'],
  'ibu-svjetski-kup': ['Boe J.T.','Laegreid','Samuelsson','Fillon Maillet','Jacquelin'],
  'uk-utrke':         ['Silver Arrow','Northern Dancer','Blue Marlin','Red Baron','Gold Rush','Midnight Run']
};

/* ================================================================== */
/* MARKETS                                                            */
/* ================================================================== */
export const MARKET_SETS = {
  '1x2':      ['1', 'X', '2', '1X', 'X2', '12', 'GG'],
  '12':       ['1', '2', 'H1', 'H2', 'U', 'O', 'TM'],
  'outright': ['Tečaj']
};

export const MARKET_LABELS = {
  '1': 'Konačni ishod 1', 'X': 'Konačni ishod X', '2': 'Konačni ishod 2',
  '1X': 'Dvostruka šansa 1X', 'X2': 'Dvostruka šansa X2', '12': 'Dvostruka šansa 12',
  'GG': 'Oba tima daju gol', 'H1': 'Hendikep 1', 'H2': 'Hendikep 2',
  'U': 'Manje golova/poena', 'O': 'Više golova/poena', 'TM': 'Ukupno', 'Tečaj': 'Pobjednik'
};

export function oddsFor(key, r) {
  const table = {
    '1':  [1.25, 4.2], 'X':  [2.90, 2.0], '2':  [1.45, 6.0],
    '1X': [1.08, 0.9], 'X2': [1.12, 1.1], '12': [1.10, 0.6],
    'GG': [1.55, 0.7], 'H1': [1.60, 0.7], 'H2': [1.60, 0.7],
    'U':  [1.55, 0.6], 'O':  [1.50, 0.7], 'TM': [1.80, 0.5]
  };
  const [base, span] = table[key] || [2.0, 9.0];
  return +(base + r() * span).toFixed(2);
}

/* ================================================================== */
/* CASINO                                                             */
/* ================================================================== */
export const PROVIDERS = [
  '7777 Gaming','Adell','Amatic','Amusnet','Apollo','Atomic Slot Lab','Barbara Bang','Bellot',
  'BF Games','Big Time Gaming','Bluberi','Casimi','CT Interactive','Digital','E-Gaming','Endorphina',
  'Evolution','Evoplay','Fazi','G-Corps','Galaxsys','GameArt','Games Global','Gamomat','Greentube',
  'Habanero','Indigo Magic','iSoftBet','Kajot','Kalamba','Mojos','NetEnt','Nolimit City','Octoplay',
  'ORYX','Pateplay','Play’n GO','Playson','Playtech','Pragmatic Play','Red Tiger','Slingo',
  'Smartsoft','Spribe','Synot','Tech4Bet','Tom Horn','Wazdan','XGames'
];

export const CATEGORIES = [
  { id: 'lobby',      name: 'Lobby',             icon: '🏠' },
  { id: 'favourites', name: 'Favoriti',          icon: '⭐' },
  { id: 'new',        name: 'Nove igre',         icon: '✨' },
  { id: 'popular',    name: 'Popularno',         icon: '🔥' },
  { id: 'jackpot',    name: 'Jackpoti',          icon: '💰' },
  { id: 'exclusive',  name: 'Samo kod nas',      icon: '🎖️' },
  { id: 'game-shows', name: 'Game Shows',        icon: '🎪' },
  { id: 'buy-bonus',  name: 'Buy Bonus',         icon: '🎁' },
  { id: 'drops',      name: 'Drops & Wins',      icon: '💧' },
  { id: 'small-bets', name: 'Mali ulozi',        icon: '🪙' },
  { id: 'big-wins',   name: 'Veliki dobici',     icon: '🏆' },
  { id: 'instant',    name: 'Instant igre',      icon: '⚡' },
  { id: 'table',      name: 'Igre na stolovima', icon: '🃏' },
  { id: 'roulette',   name: 'Rulet',             icon: '🎡' },
  { id: 'classic',    name: 'Klasični slotovi',  icon: '🍒' },
  { id: 'megaways',   name: 'Megaways',          icon: '🌀' },
  { id: 'all',        name: 'Sve igre',          icon: '🎰' }
];

/* Invented titles assembled from theme parts — no third-party game names. */
const ADJ = ['Zlatni','Vatreni','Divlji','Sretni','Tajni','Kraljevski','Brzi','Mistični','Ledeni','Srebrni',
             'Veliki','Skriveni','Blistavi','Tihi','Grimizni','Nebeski','Drevni','Munjeviti','Bogati','Zvjezdani'];
const NOUN = ['Feniks','Zmaj','Hram','Rudnik','Karavan','Sedam','Kotač','Piramida','Vitez','Grom',
              'Delfin','Vulkan','Safir','Kompas','Galeb','Jelen','Maslina','Sidro','Lampion','Kovčeg',
              'Bubanj','Kraljica','Amfora','Otok','Zvono','Ključ','Krila','Tigar','Orao','Val'];
const SUF = ['','',' Deluxe',' Megaways',' XL',' 27',' Respin',' Bonanza',' Hold & Win',' 100',' Fortune',' Rush',' Gold'];
const SYMS = ['🍒','🔔','💎','7️⃣','🍇','🍋','⭐','👑','🐉','🔥','🪙','🍀','⚡','🌊','🦅','🎰','💰','🏆','🎲','🥇','🧿','🗝️','🌴','🃏'];
const HUES = [8, 22, 38, 52, 96, 140, 168, 190, 210, 232, 258, 280, 302, 324, 342];

export function generateSlots(count, seed = 424242) {
  const r = makeRng(seed);
  const seen = new Set();
  const out = [];
  for (let i = 0; out.length < count && i < count * 12; i++) {
    const title = `${pick(ADJ, r)} ${pick(NOUN, r)}${pick(SUF, r)}`;
    if (seen.has(title)) continue;
    seen.add(title);

    const cats = ['all'];
    const roll = r();
    if (roll < 0.10) cats.push('new');
    if (roll > 0.55) cats.push('popular');
    if (r() < 0.12) cats.push('jackpot');
    if (r() < 0.09) cats.push('exclusive');
    if (r() < 0.14) cats.push('buy-bonus');
    if (r() < 0.11) cats.push('drops');
    if (r() < 0.18) cats.push('small-bets');
    if (r() < 0.13) cats.push('big-wins');
    if (r() < 0.10) cats.push('megaways');
    if (r() < 0.12) cats.push('classic');
    if (r() < 0.08) cats.push('instant');
    if (r() < 0.15) cats.push('favourites');

    const h = pick(HUES, r);
    out.push({
      slug: slugify(title),
      title,
      providerName: pick(PROVIDERS, r),
      engine: 'slot',
      categories: cats,
      symbol: pick(SYMS, r),
      hueA: h,
      hueB: (h + rint(25, 80, r)) % 360,
      rtp: +(94 + r() * 3.6).toFixed(2),
      volatility: pick(['Niska', 'Srednja', 'Visoka'], r),
      lines: pick([10, 20, 25, 40, 243, 1024, 4096], r),
      minBet: pick([0.10, 0.20, 0.25, 0.50], r),
      maxBet: pick([20, 40, 50, 100], r),
      jackpot: r() < 0.12 ? rint(4000, 480000, r) : 0,
      popularity: rint(0, 1000, r)
    });
  }
  return out;
}

export const TABLE_GAMES = [
  { title: 'Europski rulet',      providerName: 'PSK Studio', engine: 'roulette',  symbol: '🎡', hueA: 0,   hueB: 340, categories: ['all','table','roulette','popular','favourites'], rtp: 97.30, volatility: 'Srednja' },
  { title: 'Rulet Pro',           providerName: 'PSK Studio', engine: 'roulette',  symbol: '🎡', hueA: 140, hueB: 190, categories: ['all','table','roulette'], rtp: 97.30, volatility: 'Srednja' },
  { title: 'Blackjack Classic',   providerName: 'PSK Studio', engine: 'blackjack', symbol: '🃏', hueA: 210, hueB: 260, categories: ['all','table','popular','favourites'], rtp: 99.50, volatility: 'Niska' },
  { title: 'Blackjack Multihand', providerName: 'PSK Studio', engine: 'blackjack', symbol: '♠️', hueA: 258, hueB: 300, categories: ['all','table'], rtp: 99.40, volatility: 'Niska' },
  { title: 'Aviator Rush',        providerName: 'PSK Studio', engine: 'crash',     symbol: '🚀', hueA: 22,  hueB: 52,  categories: ['all','instant','popular','big-wins','favourites'], rtp: 97.00, volatility: 'Visoka' },
  { title: 'Crash Royale',        providerName: 'PSK Studio', engine: 'crash',     symbol: '📈', hueA: 96,  hueB: 168, categories: ['all','instant','big-wins'], rtp: 97.00, volatility: 'Visoka' },
  { title: 'Mine Hunter',         providerName: 'PSK Studio', engine: 'mines',     symbol: '💣', hueA: 302, hueB: 342, categories: ['all','instant','small-bets'], rtp: 97.00, volatility: 'Visoka' },
  { title: 'Kocka Duel',          providerName: 'PSK Studio', engine: 'dice',      symbol: '🎲', hueA: 190, hueB: 232, categories: ['all','instant','table','small-bets'], rtp: 98.00, volatility: 'Srednja' }
];

export const LIVE_TABLES = [
  { title: 'Live Rulet HR',      providerName: 'Evolution',      engine: 'roulette',  symbol: '🎡', hueA: 0,   hueB: 30,  categories: ['live','roulette','popular'] },
  { title: 'Auto Rulet Speed',   providerName: 'Evolution',      engine: 'roulette',  symbol: '⚡', hueA: 22,  hueB: 44,  categories: ['live','roulette'] },
  { title: 'Live Blackjack A',   providerName: 'Evolution',      engine: 'blackjack', symbol: '🃏', hueA: 140, hueB: 168, categories: ['live','table','popular'] },
  { title: 'Live Blackjack VIP', providerName: 'Playtech',       engine: 'blackjack', symbol: '♠️', hueA: 210, hueB: 240, categories: ['live','table'] },
  { title: 'Kolo sreće',         providerName: 'Evolution',      engine: 'wheel',     symbol: '🎪', hueA: 280, hueB: 320, categories: ['live','game-shows','popular'] },
  { title: 'Mega Kotač Live',    providerName: 'Pragmatic Play', engine: 'wheel',     symbol: '🌀', hueA: 302, hueB: 342, categories: ['live','game-shows'] },
  { title: 'Live Baccarat',      providerName: 'Evolution',      engine: 'baccarat',  symbol: '🎴', hueA: 96,  hueB: 130, categories: ['live','table'] },
  { title: 'Speed Baccarat',     providerName: 'Playtech',       engine: 'baccarat',  symbol: '🎴', hueA: 168, hueB: 196, categories: ['live','table'] },
  { title: 'Live Poker Hold’em', providerName: 'Evolution',      engine: 'baccarat',  symbol: '🂡', hueA: 232, hueB: 268, categories: ['live','table'] },
  { title: 'Dice Show Live',     providerName: 'Pragmatic Play', engine: 'dice',      symbol: '🎲', hueA: 52,  hueB: 96,  categories: ['live','game-shows'] },
  { title: 'Sic Bo Live',        providerName: 'Evolution',      engine: 'dice',      symbol: '🀄', hueA: 8,   hueB: 52,  categories: ['live','table'] },
  { title: 'Craps Live',         providerName: 'Evolution',      engine: 'dice',      symbol: '🎯', hueA: 190, hueB: 220, categories: ['live','table'] }
];

/* ================================================================== */
/* CONTENT                                                            */
/* ================================================================== */
export const LOTTERIES = [
  { slug: 'loto-7-39',   name: 'Loto 7/39',      pick: 7,  max: 39, drawInfo: 'Srijeda i nedjelja, 20:00', jackpot: 1850000,  price: 1.00 },
  { slug: 'loto-6-45',   name: 'Loto 6/45',      pick: 6,  max: 45, drawInfo: 'Utorak i petak, 20:00',     jackpot: 640000,   price: 0.80 },
  { slug: 'euro-jackpot',name: 'Euro Jackpot',   pick: 5,  max: 50, drawInfo: 'Petak, 21:00',              jackpot: 12500000, price: 2.00 },
  { slug: 'keno',        name: 'Keno',           pick: 10, max: 80, drawInfo: 'Svakih 5 minuta',           jackpot: 100000,   price: 0.50 },
  { slug: 'bingo-90',    name: 'Bingo 90',       pick: 6,  max: 90, drawInfo: 'Svakih 10 minuta',          jackpot: 48000,    price: 1.00 },
  { slug: 'sretni-brojevi', name: 'Sretni brojevi', pick: 8, max: 35, drawInfo: 'Svake 4 minute',          jackpot: 25000,    price: 0.50 }
];

export const VIRTUALS = [
  { slug: 'virtualni-nogomet',    name: 'Virtualni nogomet',       icon: '⚽',  symbol: '⚽',  hueA: 140, hueB: 168, intervalLabel: '3 min', runners: 2,  description: 'Simulirana liga s 16 momčadi i punom ponudom tržišta.' },
  { slug: 'virtualne-konjske',    name: 'Virtualne konjske utrke', icon: '🐎',  symbol: '🐎',  hueA: 22,  hueB: 52,  intervalLabel: '2 min', runners: 8,  description: 'Osam grla po utrci, pobjednik i plasman.' },
  { slug: 'virtualni-hrtovi',     name: 'Virtualni hrtovi',        icon: '🐕',  symbol: '🐕',  hueA: 38,  hueB: 96,  intervalLabel: '2 min', runners: 6,  description: 'Šest hrtova, brze utrke tijekom cijelog dana.' },
  { slug: 'virtualni-tenis',      name: 'Virtualni tenis',         icon: '🎾',  symbol: '🎾',  hueA: 96,  hueB: 140, intervalLabel: '4 min', runners: 2,  description: 'Meč na dva dobivena seta, simulacija uživo.' },
  { slug: 'virtualna-kosarka',    name: 'Virtualna košarka',       icon: '🏀',  symbol: '🏀',  hueA: 8,   hueB: 38,  intervalLabel: '5 min', runners: 2,  description: 'Četiri četvrtine, hendikep i ukupno poena.' },
  { slug: 'virtualne-auto-utrke', name: 'Virtualne auto utrke',    icon: '🏎️', symbol: '🏎️', hueA: 210, hueB: 258, intervalLabel: '3 min', runners: 10, description: 'Utrka s deset bolida i tržištem pobjednika.' },
  { slug: 'virtualni-biciklizam', name: 'Virtualni biciklizam',    icon: '🚴',  symbol: '🚴',  hueA: 168, hueB: 196, intervalLabel: '4 min', runners: 12, description: 'Etapa s dvanaest vozača.' },
  { slug: 'brzi-keno',            name: 'Brzi keno',               icon: '🔢',  symbol: '🔢',  hueA: 280, hueB: 324, intervalLabel: '1 min', runners: 0,  description: 'Izvlačenje 20 od 80 brojeva svake minute.' }
];

export const PROMOS = [
  { slug: 'bonus-dobrodoslice', tag: 'Sport',  title: 'Bonus dobrodošlice na prvu uplatu', cta: 'Preuzmi bonus', hueA: 210, hueB: 258, body: 'Novi igrači dobivaju bonus na prvu uplatu do zadanog iznosa, uz uvjet prometa opisan u pravilima akcije.' },
  { slug: 'besplatni-okreti',   tag: 'Casino', title: 'Besplatni okreti svaki tjedan',      cta: 'Pogledaj igre', hueA: 280, hueB: 324, body: 'Tjedni paket besplatnih okreta na odabranim igrama za sve verificirane korisnike.' },
  { slug: 'bonus-tip',          tag: 'Sport',  title: 'Bonus tip na kombinacije',           cta: 'Saznaj više',   hueA: 22,  hueB: 52,  body: 'Što više parova na listiću, to veći postotak bonusa na dobitak. Postoci su navedeni u tablici akcije.' },
  { slug: 'favorit-plus',       tag: 'Sport',  title: 'Favorit Plus',                       cta: 'Odigraj',       hueA: 140, hueB: 168, body: 'Uvećani tečajevi na odabrane favorite u ponudi dana.' },
  { slug: 'mjesecni-turnir',    tag: 'Casino', title: 'Mjesečni turnir igrača',             cta: 'Rang lista',    hueA: 96,  hueB: 140, body: 'Skupljaj bodove igrajući odabrane igre i natječi se za nagradni fond.' },
  { slug: 'dupli-listic',       tag: 'Loto',   title: 'Dupli listić srijedom',              cta: 'Uplati listić', hueA: 302, hueB: 342, body: 'Uplati loto listić srijedom i dobij drugi listić za isto kolo.' },
  { slug: 'klub-prvaka',        tag: 'Klub',   title: 'Klub prvaka - bodovi i razine',      cta: 'O klubu',       hueA: 190, hueB: 232, body: 'Sakupljaj bodove kroz igru i otključavaj razine s dodatnim pogodnostima.' },
  { slug: 'drops-wins',         tag: 'Casino', title: 'Drops & Wins nagradni fond',         cta: 'Igraj sada',    hueA: 8,   hueB: 38,  body: 'Dnevne i mjesečne nagrade na odabranim igrama uključenim u akciju.' }
];

export const NEWS = [
  { slug: 'najava-kola-derbi',      category: 'Nogomet',    title: 'Najava kola: derbi zatvara subotu',   excerpt: 'Pregled forme, izostanaka i statistike uoči najvažnije utakmice kola.' },
  { slug: 'euroliga-uvodni-susreti',category: 'Košarka',    title: 'Euroliga: analiza uvodnih susreta',   excerpt: 'Kako su europski klubovi otvorili sezonu i što očekivati u nastavku.' },
  { slug: 'turnirski-raspored',     category: 'Tenis',      title: 'Turnirski raspored za rujan',         excerpt: 'Sve o nadolazećim ATP i WTA turnirima te hrvatskim predstavnicima.' },
  { slug: 'kvalifikacije-sp',       category: 'E-sport',    title: 'Kvalifikacije za svjetsko prvenstvo', excerpt: 'Raspored, formati i favoriti u nadolazećim kvalifikacijama.' },
  { slug: 'nove-igre-mjeseca',      category: 'Casino',     title: 'Nove igre u ponudi ovog mjeseca',     excerpt: 'Pregled naslova koji su ovog mjeseca dodani u casino ponudu.' },
  { slug: 'vodic-betbuilder',       category: 'Kladionica', title: 'Vodič: kako radi BetBuilder',         excerpt: 'Korak po korak kroz slaganje vlastite oklade na jedan događaj.' },
  { slug: 'regionalna-liga',        category: 'Rukomet',    title: 'Regionalna liga pred startom',        excerpt: 'Sastavi, pojačanja i očekivanja pred novu sezonu.' },
  { slug: 'sigurnosni-vodic',       category: 'Sigurnost',  title: 'Sigurnosni vodič za korisnike',       excerpt: 'Kako zaštititi račun, prepoznati prijevare i postaviti limite igre.' }
];

export const SHOPS = [
  { city: 'Zagreb',          address: 'Ilica 120',            hours: '07:00 - 23:00', kind: 'Kladionica + kafić' },
  { city: 'Zagreb',          address: 'Avenija Dubrovnik 16', hours: '00:00 - 24:00', kind: 'Kladionica' },
  { city: 'Zagreb',          address: 'Vukovarska 269',       hours: '08:00 - 22:00', kind: 'Kladionica + kafić' },
  { city: 'Split',           address: 'Domovinskog rata 24',  hours: '07:00 - 24:00', kind: 'Kladionica' },
  { city: 'Split',           address: 'Poljička cesta 5',     hours: '08:00 - 23:00', kind: 'Kladionica + kafić' },
  { city: 'Rijeka',          address: 'Korzo 14',             hours: '07:00 - 23:00', kind: 'Kladionica' },
  { city: 'Rijeka',          address: 'Zvonimirova 8',        hours: '08:00 - 22:00', kind: 'Kladionica' },
  { city: 'Osijek',          address: 'Trg slobode 3',        hours: '07:00 - 23:00', kind: 'Kladionica + kafić' },
  { city: 'Zadar',           address: 'Široka ulica 11',      hours: '08:00 - 24:00', kind: 'Kladionica' },
  { city: 'Varaždin',        address: 'Gundulićeva 2',        hours: '07:00 - 22:00', kind: 'Kladionica' },
  { city: 'Slavonski Brod',  address: 'Ulica kralja Petra 7', hours: '08:00 - 22:00', kind: 'Kladionica' },
  { city: 'Pula',            address: 'Giardini 9',           hours: '07:00 - 23:00', kind: 'Kladionica + kafić' },
  { city: 'Dubrovnik',       address: 'Stradun 4',            hours: '09:00 - 23:00', kind: 'Kladionica' },
  { city: 'Šibenik',         address: 'Kralja Zvonimira 12',  hours: '08:00 - 22:00', kind: 'Kladionica' },
  { city: 'Karlovac',        address: 'Trg bana Jelačića 6',  hours: '07:00 - 22:00', kind: 'Kladionica' },
  { city: 'Vinkovci',        address: 'Duga ulica 30',        hours: '08:00 - 22:00', kind: 'Kladionica' }
];

export const THREADS = [
  { slug: 'najava-kola',      category: 'Nogomet',    title: 'Vaši tipovi za ovo kolo?',        author: 'tipster_hr',  body: 'Otvaram temu za najavu kola. Zanima me kako gledate na derbi i ima li netko statistiku posljednjih pet susreta.' },
  { slug: 'strategija-sistem',category: 'Strategija', title: 'Ima li smisla igrati sisteme?',   author: 'kombinator',  body: 'Igram uglavnom sisteme 4/6. Zanima me računa li netko očekivanu vrijednost prije uplate ili ide osjećajem.' },
  { slug: 'live-kladenje',    category: 'Uživo',      title: 'Klađenje uživo — kada ulaziti?',  author: 'plavi_val',   body: 'Primjećujem da tečajevi najviše skaču oko 20. minute. Kako vi birate trenutak ulaska?' },
  { slug: 'casino-rtp',       category: 'Casino',     title: 'Koliko vam znači RTP igre?',      author: 'sigurica',    body: 'Gledate li RTP prije nego što otvorite igru ili birate po temi i grafici?' },
  { slug: 'esport-pocetnik',  category: 'E-sport',    title: 'Počinjem s e-sportom, savjeti?',  author: 'novi_igrac',  body: 'Pratim CS već godinama ali nikad se nisam kladio. Na što obratiti pažnju kod mapa i hendikepa?' },
  { slug: 'limiti-igre',      category: 'Općenito',   title: 'Postavljate li limite na račun?',  author: 'dalmatinac',  body: 'Postavio sam tjedni limit i preporučam svima. Puno lakše je držati se plana kad sustav to čuva umjesto tebe.' }
];

export const FORUM_REPLIES = [
  'Slažem se, iako bih dodao da statistika bez konteksta zna prevariti.',
  'Kod mene je ključno ne mijenjati plan nakon gubitka. To je najskuplja greška.',
  'Dobra tema. Ja gledam samo lige koje stvarno pratim, ostalo preskačem.',
  'Hvala na odgovorima, puno mi je jasnije sada.',
  'Bitno je unaprijed odrediti iznos i držati ga se bez obzira na ishod.',
  'Imam suprotno iskustvo, ali razumijem tvoju logiku.'
];

export const PAYMENTS = ['Visa','Mastercard','Maestro','Apple Pay','Google Pay','PayPal','Keks Pay','IBAN','Aircash','Skrill','Neteller','Paysafecard'];
