/* ============================================================
   data.js — offer + catalogue data model
   Everything here is generated locally from a seeded PRNG so the
   site renders identical content on every load without a backend.
   ============================================================ */

/* ---------- seeded PRNG (mulberry32) ---------- */
function makeRng(seed) {
  let a = seed >>> 0;
  return function () {
    a |= 0; a = (a + 0x6D2B79F5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}
const rng = makeRng(20260909);
const pick = (arr, r = rng) => arr[Math.floor(r() * arr.length)];
const rint = (min, max, r = rng) => Math.floor(r() * (max - min + 1)) + min;

/* ============================================================
   SPORTS + LEAGUES
   ============================================================ */
const SPORTS = [
  { id: 'nogomet',     name: 'Nogomet',            icon: '⚽', cols: '1x2' },
  { id: 'kosarka',     name: 'Košarka',            icon: '🏀', cols: '12' },
  { id: 'tenis',       name: 'Tenis',              icon: '🎾', cols: '12' },
  { id: 'rukomet',     name: 'Rukomet',            icon: '🤾', cols: '1x2' },
  { id: 'odbojka',     name: 'Odbojka',            icon: '🏐', cols: '12' },
  { id: 'hokej',       name: 'Hokej na ledu',      icon: '🏒', cols: '1x2' },
  { id: 'stolni-tenis',name: 'Stolni tenis',       icon: '🏓', cols: '12' },
  { id: 'esport',      name: 'E-sport',            icon: '🎮', cols: '12' },
  { id: 'boks',        name: 'Boks',               icon: '🥊', cols: '12' },
  { id: 'mma',         name: 'MMA / UFC',          icon: '🥋', cols: '12' },
  { id: 'formula-1',   name: 'Formula 1',          icon: '🏎️', cols: 'outright' },
  { id: 'moto-gp',     name: 'Moto GP',            icon: '🏍️', cols: 'outright' },
  { id: 'pikado',      name: 'Pikado',             icon: '🎯', cols: '12' },
  { id: 'snooker',     name: 'Snooker',            icon: '🎱', cols: '12' },
  { id: 'golf',        name: 'Golf',               icon: '⛳', cols: 'outright' },
  { id: 'biciklizam',  name: 'Biciklizam',         icon: '🚴', cols: 'outright' },
  { id: 'ragbi',       name: 'Ragbi',              icon: '🏉', cols: '1x2' },
  { id: 'am-nogomet',  name: 'Američki nogomet',   icon: '🏈', cols: '12' },
  { id: 'bejzbol',     name: 'Bejzbol',            icon: '⚾', cols: '12' },
  { id: 'vaterpolo',   name: 'Vaterpolo',          icon: '🤽', cols: '1x2' },
  { id: 'atletika',    name: 'Atletika',           icon: '🏃', cols: 'outright' },
  { id: 'skijanje',    name: 'Skijanje',           icon: '⛷️', cols: 'outright' },
  { id: 'skokovi',     name: 'Ski skokovi',        icon: '🎿', cols: 'outright' },
  { id: 'biatlon',     name: 'Biatlon',            icon: '🎽', cols: 'outright' },
  { id: 'sah',         name: 'Šah',                icon: '♟️', cols: '1x2' },
  { id: 'futsal',      name: 'Futsal',             icon: '🥅', cols: '1x2' },
  { id: 'badminton',   name: 'Badminton',          icon: '🏸', cols: '12' },
  { id: 'kuglanje',    name: 'Kuglanje',           icon: '🎳', cols: '12' },
  { id: 'konji',       name: 'Konjičke utrke',     icon: '🐎', cols: 'outright' },
  { id: 'zabava',      name: 'Svijet zabave',      icon: '🎬', cols: '12' }
];

const LEAGUES = {
  nogomet: [
    { id: 'hr-1hnl',  flag: '🇭🇷', name: 'HNL' },
    { id: 'hr-kup',   flag: '🇭🇷', name: 'Hrvatski kup' },
    { id: 'ucl',      flag: '🇪🇺', name: 'Liga prvaka' },
    { id: 'uel',      flag: '🇪🇺', name: 'Europska liga' },
    { id: 'uecl',     flag: '🇪🇺', name: 'Konferencijska liga' },
    { id: 'eng-pl',   flag: '🏴', name: 'Engleska - Premier liga' },
    { id: 'eng-ch',   flag: '🏴', name: 'Engleska - Championship' },
    { id: 'esp-la',   flag: '🇪🇸', name: 'Španjolska - La Liga' },
    { id: 'ita-sa',   flag: '🇮🇹', name: 'Italija - Serie A' },
    { id: 'ger-bl',   flag: '🇩🇪', name: 'Njemačka - Bundesliga' },
    { id: 'fra-l1',   flag: '🇫🇷', name: 'Francuska - Ligue 1' },
    { id: 'por-pl',   flag: '🇵🇹', name: 'Portugal - Primeira Liga' },
    { id: 'ned-ed',   flag: '🇳🇱', name: 'Nizozemska - Eredivisie' },
    { id: 'tur-sl',   flag: '🇹🇷', name: 'Turska - Süper Lig' },
    { id: 'bel-pd',   flag: '🇧🇪', name: 'Belgija - Pro liga' },
    { id: 'aut-bl',   flag: '🇦🇹', name: 'Austrija - Bundesliga' },
    { id: 'srb-sl',   flag: '🇷🇸', name: 'Srbija - Superliga' },
    { id: 'slo-1s',   flag: '🇸🇮', name: 'Slovenija - 1. SNL' },
    { id: 'bih-pl',   flag: '🇧🇦', name: 'BiH - Premijer liga' },
    { id: 'usa-mls',  flag: '🇺🇸', name: 'SAD - MLS' },
    { id: 'bra-sa',   flag: '🇧🇷', name: 'Brazil - Serie A' },
    { id: 'arg-lp',   flag: '🇦🇷', name: 'Argentina - Liga Profesional' },
    { id: 'jpn-j1',   flag: '🇯🇵', name: 'Japan - J1 liga' },
    { id: 'ksa-pl',   flag: '🇸🇦', name: 'Saudijska Arabija - Pro liga' },
    { id: 'aus-al',   flag: '🇦🇺', name: 'Australija - A-liga' }
  ],
  kosarka: [
    { id: 'nba',      flag: '🇺🇸', name: 'NBA' },
    { id: 'euroliga', flag: '🇪🇺', name: 'Euroliga' },
    { id: 'eurokup',  flag: '🇪🇺', name: 'Eurokup' },
    { id: 'aba',      flag: '🌍', name: 'ABA liga' },
    { id: 'hr-pk',    flag: '🇭🇷', name: 'Hrvatska - Premijer liga' },
    { id: 'esp-acb',  flag: '🇪🇸', name: 'Španjolska - ACB' },
    { id: 'ita-lba',  flag: '🇮🇹', name: 'Italija - Lega A' },
    { id: 'ncaa',     flag: '🇺🇸', name: 'NCAA' }
  ],
  tenis: [
    { id: 'atp',      flag: '🎾', name: 'ATP Tour' },
    { id: 'wta',      flag: '🎾', name: 'WTA Tour' },
    { id: 'gs',       flag: '🏆', name: 'Grand Slam' },
    { id: 'challenger',flag: '🎾', name: 'ATP Challenger' },
    { id: 'itf',      flag: '🎾', name: 'ITF' },
    { id: 'davis',    flag: '🌍', name: 'Davis Cup' }
  ],
  rukomet: [
    { id: 'ehf-cl',   flag: '🇪🇺', name: 'EHF Liga prvaka' },
    { id: 'hr-pl',    flag: '🇭🇷', name: 'Hrvatska - Premijer liga' },
    { id: 'ger-hbl',  flag: '🇩🇪', name: 'Njemačka - Bundesliga' },
    { id: 'esp-asobal',flag: '🇪🇸', name: 'Španjolska - Asobal' },
    { id: 'sehа',     flag: '🌍', name: 'SEHA liga' }
  ],
  odbojka: [
    { id: 'cev-cl',   flag: '🇪🇺', name: 'CEV Liga prvaka' },
    { id: 'ita-sa',   flag: '🇮🇹', name: 'Italija - SuperLega' },
    { id: 'pol-pl',   flag: '🇵🇱', name: 'Poljska - PlusLiga' },
    { id: 'hr-sl',    flag: '🇭🇷', name: 'Hrvatska - Superliga' }
  ],
  hokej: [
    { id: 'nhl',      flag: '🇺🇸', name: 'NHL' },
    { id: 'khl',      flag: '🌍', name: 'KHL' },
    { id: 'ice',      flag: '🇦🇹', name: 'ICE liga' },
    { id: 'shl',      flag: '🇸🇪', name: 'Švedska - SHL' }
  ],
  esport: [
    { id: 'lol-lec',  flag: '🎮', name: 'League of Legends - LEC' },
    { id: 'lol-lck',  flag: '🎮', name: 'League of Legends - LCK' },
    { id: 'cs2',      flag: '🎮', name: 'Counter-Strike 2' },
    { id: 'dota',     flag: '🎮', name: 'Dota 2' },
    { id: 'valorant', flag: '🎮', name: 'Valorant' },
    { id: 'rl',       flag: '🎮', name: 'Rocket League' }
  ],
  'stolni-tenis': [
    { id: 'setka',    flag: '🏓', name: 'TT Elite Series' },
    { id: 'czl',      flag: '🇨🇿', name: 'Češka - Liga Pro' }
  ],
  boks:  [{ id: 'wbc', flag: '🥊', name: 'WBC / WBA borbe' }],
  mma:   [{ id: 'ufc', flag: '🥋', name: 'UFC' }, { id: 'bellator', flag: '🥋', name: 'Bellator' }],
  pikado:[{ id: 'pdc', flag: '🎯', name: 'PDC World Series' }],
  snooker:[{ id: 'wst', flag: '🎱', name: 'World Snooker Tour' }],
  ragbi: [{ id: 'six', flag: '🏉', name: 'Six Nations' }],
  'am-nogomet': [{ id: 'nfl', flag: '🏈', name: 'NFL' }, { id: 'ncaaf', flag: '🏈', name: 'NCAA Football' }],
  bejzbol: [{ id: 'mlb', flag: '⚾', name: 'MLB' }],
  vaterpolo: [{ id: 'hr-pl', flag: '🇭🇷', name: 'Hrvatska - Prva liga' }, { id: 'len', flag: '🇪🇺', name: 'LEN Liga prvaka' }],
  futsal: [{ id: 'hr-1hml', flag: '🇭🇷', name: 'Hrvatska - 1. HMNL' }],
  badminton: [{ id: 'bwf', flag: '🏸', name: 'BWF World Tour' }],
  kuglanje: [{ id: 'hr-kl', flag: '🇭🇷', name: 'Hrvatska liga' }],
  sah:  [{ id: 'fide', flag: '♟️', name: 'FIDE Grand Prix' }],
  'formula-1': [{ id: 'f1', flag: '🏎️', name: 'Formula 1 - Sezona' }],
  'moto-gp':   [{ id: 'mgp', flag: '🏍️', name: 'MotoGP - Sezona' }],
  golf:        [{ id: 'pga', flag: '⛳', name: 'PGA Tour' }],
  biciklizam:  [{ id: 'tdf', flag: '🚴', name: 'Grand Tour' }],
  atletika:    [{ id: 'dl',  flag: '🏃', name: 'Diamond League' }],
  skijanje:    [{ id: 'fis', flag: '⛷️', name: 'FIS Svjetski kup' }],
  skokovi:     [{ id: 'fis-sj', flag: '🎿', name: 'FIS Svjetski kup - skokovi' }],
  biatlon:     [{ id: 'ibu', flag: '🎽', name: 'IBU Svjetski kup' }],
  konji:       [{ id: 'uk-rc', flag: '🐎', name: 'UK utrke' }],
  zabava:      [{ id: 'tv',  flag: '🎬', name: 'TV i događanja' }]
};

/* ---------- team name pools per league ---------- */
const TEAMS = {
  'hr-1hnl': ['Dinamo Z.','Hajduk','Rijeka','Osijek','Gorica','Slaven B.','Lokomotiva','Varaždin','Istra 1961','Šibenik'],
  'hr-kup':  ['Dinamo Z.','Hajduk','Rijeka','Osijek','Cibalia','Dugopolje','Rudeš','Orijent'],
  'ucl':     ['Real Madrid','Man City','Bayern','PSG','Inter','Arsenal','Barcelona','Liverpool','Milan','Atletico','Dortmund','Napoli'],
  'uel':     ['Roma','Leverkusen','Ajax','Benfica','Rangers','Betis','Lyon','Fenerbahče'],
  'uecl':    ['Fiorentina','Rijeka','Gent','Legia','Aston Villa','Basel'],
  'eng-pl':  ['Arsenal','Man City','Liverpool','Chelsea','Tottenham','Man United','Newcastle','Aston Villa','Brighton','West Ham','Everton','Fulham','Brentford','Crystal Palace'],
  'eng-ch':  ['Leeds','Southampton','Norwich','Sunderland','Middlesbrough','Cardiff','Stoke','Hull'],
  'esp-la':  ['Real Madrid','Barcelona','Atletico','Sevilla','Villarreal','Real Sociedad','Valencia','Betis','Athletic','Girona'],
  'ita-sa':  ['Inter','Milan','Juventus','Napoli','Roma','Lazio','Atalanta','Fiorentina','Torino','Bologna'],
  'ger-bl':  ['Bayern','Dortmund','Leipzig','Leverkusen','Frankfurt','Stuttgart','Wolfsburg','Freiburg','Union Berlin'],
  'fra-l1':  ['PSG','Marseille','Monaco','Lyon','Lille','Nice','Rennes','Lens'],
  'por-pl':  ['Benfica','Porto','Sporting','Braga','Vitoria SC'],
  'ned-ed':  ['Ajax','PSV','Feyenoord','AZ Alkmaar','Twente','Utrecht'],
  'tur-sl':  ['Galatasaray','Fenerbahče','Bešiktaš','Trabzonspor','Bašakšehir'],
  'bel-pd':  ['Club Brugge','Anderlecht','Genk','Gent','Antwerp'],
  'aut-bl':  ['Salzburg','Sturm Graz','Rapid Beč','Austria Beč','LASK'],
  'srb-sl':  ['Crvena zvezda','Partizan','Vojvodina','Čukarički','TSC'],
  'slo-1s':  ['Olimpija','Maribor','Celje','Koper','Bravo'],
  'bih-pl':  ['Zrinjski','Sarajevo','Željezničar','Borac','Široki Brijeg'],
  'usa-mls': ['Inter Miami','LAFC','LA Galaxy','Seattle','Atlanta Utd','NY Red Bulls'],
  'bra-sa':  ['Flamengo','Palmeiras','Corinthians','Sao Paulo','Gremio','Fluminense'],
  'arg-lp':  ['Boca Juniors','River Plate','Racing','Independiente','San Lorenzo'],
  'jpn-j1':  ['Kawasaki','Urawa','Kashima','Yokohama FM','Gamba Osaka'],
  'ksa-pl':  ['Al Hilal','Al Nassr','Al Ittihad','Al Ahli'],
  'aus-al':  ['Melbourne City','Sydney FC','Western United','Adelaide'],
  nba:       ['Boston','LA Lakers','Denver','Milwaukee','Golden State','Miami','Phoenix','Philadelphia','Dallas','New York','Oklahoma City','Cleveland'],
  euroliga:  ['Real Madrid','Panathinaikos','Olympiacos','Fenerbahče','Barcelona','Monaco','Maccabi','Partizan','Crvena zvezda','Efes'],
  eurokup:   ['Bahčešehir','Hapoel TA','Paris','Valencia','Turk Telekom'],
  aba:       ['Cibona','Zadar','Split','Crvena zvezda','Partizan','Cedevita Olimpija','Igokea','Mega'],
  'hr-pk':   ['Cibona','Zadar','Split','Cedevita Junior','Šibenka','Zabok'],
  'esp-acb': ['Real Madrid','Barcelona','Baskonia','Unicaja','Valencia','Gran Canaria'],
  'ita-lba': ['Virtus Bologna','Olimpia Milano','Venezia','Brescia','Tortona'],
  ncaa:      ['Duke','Kansas','Kentucky','UCLA','Gonzaga','North Carolina'],
  atp:       ['Sinner','Alcaraz','Djoković','Medvedev','Zverev','Rune','Ruud','Fritz','Tsitsipas','Rublev','Ćorić','Musetti'],
  wta:       ['Swiatek','Sabalenka','Gauff','Rybakina','Pegula','Vondrousova','Jabeur','Zheng'],
  gs:        ['Sinner','Alcaraz','Djoković','Zverev','Swiatek','Sabalenka','Gauff','Medvedev'],
  challenger:['Prižmić','Ajduković','Serdarušić','Poljičak','Mrva','Kovačević'],
  itf:       ['Petrović','Novak','Kovač','Horvat','Marić'],
  davis:     ['Hrvatska','Italija','Španjolska','Srbija','Australija','SAD'],
  'ehf-cl':  ['Barcelona','Kiel','Magdeburg','PSG','Veszprem','Aalborg','Zagreb'],
  'hr-pl':   ['Zagreb','Nexe','PPD Zagreb','Sesvete','Dubrava','Poreč'],
  'ger-hbl': ['Kiel','Magdeburg','Flensburg','Rhein-Neckar','Fuchse Berlin'],
  'esp-asobal': ['Barcelona','Granollers','Bidasoa','Logrono'],
  'sehа':    ['Zagreb','Vardar','Nexe','Tatran','Vojvodina'],
  'cev-cl':  ['Perugia','Trentino','Zaksa','Jastrzebski','Zenit'],
  'pol-pl':  ['Zaksa','Jastrzebski','Resovia','Projekt Warszawa'],
  'hr-sl':   ['Mladost','Kaštela','Rijeka','Osijek'],
  nhl:       ['Boston','Colorado','Toronto','Edmonton','Vegas','Rangers','Florida','Dallas'],
  khl:       ['CSKA','SKA','Ak Bars','Metallurg','Dynamo M.'],
  ice:       ['Salzburg','KAC','Vienna Capitals','Bolzano','Medveščak'],
  shl:       ['Frolunda','Skelleftea','Lulea','Farjestad'],
  'lol-lec': ['G2 Esports','Fnatic','MAD Lions','Team Vitality','Rogue','SK Gaming'],
  'lol-lck': ['T1','Gen.G','Hanwha Life','DRX','KT Rolster'],
  cs2:       ['NAVI','FaZe','Vitality','G2','Spirit','MOUZ','Astralis'],
  dota:      ['Team Spirit','Gaimin Gladiators','LGD','Tundra','OG'],
  valorant:  ['Sentinels','Fnatic','LOUD','DRX','Paper Rex'],
  rl:        ['Karmine Corp','G2','Team BDS','NRG'],
  setka:     ['Kaczmarek','Nowak','Kowalski','Wisniewski','Zielinski'],
  czl:       ['Novak','Svoboda','Dvorak','Cerny','Prochazka'],
  wbc:       ['Usyk','Fury','Joshua','Wilder','Dubois','Hrgović'],
  ufc:       ['Makhachev','Volkanovski','Pereira','Adesanya','O’Malley','Topuria'],
  pdc:       ['Humphries','Littler','Van Gerwen','Price','Aspinall','Smith'],
  wst:       ['O’Sullivan','Trump','Selby','Robertson','Murphy','Allen'],
  six:       ['Irska','Francuska','Engleska','Škotska','Wales','Italija'],
  nfl:       ['Chiefs','49ers','Ravens','Bills','Cowboys','Eagles','Lions','Dolphins'],
  ncaaf:     ['Alabama','Georgia','Michigan','Ohio State','Texas'],
  mlb:       ['Yankees','Dodgers','Astros','Braves','Red Sox','Mets'],
  'len':     ['Pro Recco','Novi Beograd','Jug AO','Ferencvaros','Olympiacos'],
  'hr-1hml': ['Futsal Dinamo','Olmissum','Novo Vrijeme','Split Tommy'],
  bwf:       ['Axelsen','Momota','An Se-young','Marin','Antonsen'],
  'hr-kl':   ['Zaprešić','Zagreb','Rijeka','Poštar'],
  fide:      ['Carlsen','Nakamura','Caruana','Ding','Nepomnjašči','Firouzja']
};

/* outright markets (motorsport, golf, cycling, athletics, winter, horses) */
const OUTRIGHTS = {
  f1:    { title: 'Pobjednik utrke', field: ['Verstappen','Norris','Leclerc','Piastri','Hamilton','Russell','Sainz','Perez','Alonso'] },
  mgp:   { title: 'Pobjednik utrke', field: ['Bagnaia','Martin','Marquez','Bastianini','Vinales','Acosta'] },
  pga:   { title: 'Pobjednik turnira', field: ['Scheffler','McIlroy','Rahm','Schauffele','Hovland','Koepka'] },
  tdf:   { title: 'Pobjednik etape', field: ['Pogačar','Vingegaard','Evenepoel','Roglič','Van Aert','Philipsen'] },
  dl:    { title: 'Pobjednik discipline', field: ['Duplantis','Lyles','Warholm','Ingebrigtsen','Barshim'] },
  fis:   { title: 'Pobjednik utrke', field: ['Odermatt','Kristoffersen','Braathen','Kilde','Zubčić'] },
  'fis-sj': { title: 'Pobjednik natjecanja', field: ['Kobayashi','Lanišek','Kraft','Tschofenig','Prevc'] },
  ibu:   { title: 'Pobjednik utrke', field: ['Boe J.T.','Laegreid','Samuelsson','Fillon Maillet','Jacquelin'] },
  'uk-rc': { title: 'Pobjednik utrke', field: ['Silver Arrow','Northern Dancer','Blue Marlin','Red Baron','Gold Rush','Midnight Run'] }
};

/* ============================================================
   EVENT GENERATION
   ============================================================ */
const MARKET_SETS = {
  '1x2':      ['1','X','2','1X','X2','12','GG'],
  '12':       ['1','2','H1','H2','U','O','TM'],
  'outright': ['Tečaj']
};
const MARKET_LABELS = {
  '1': 'Konačni ishod 1', 'X': 'Konačni ishod X', '2': 'Konačni ishod 2',
  '1X': 'Dvostruka šansa 1X', 'X2': 'Dvostruka šansa X2', '12': 'Dvostruka šansa 12',
  'GG': 'Oba tima daju gol', 'H1': 'Hendikep 1', 'H2': 'Hendikep 2',
  'U': 'Manje golova/poena', 'O': 'Više golova/poena', 'TM': 'Ukupno',
  'Tečaj': 'Pobjednik'
};

function oddsFor(kind, r) {
  switch (kind) {
    case '1':  return +(1.25 + r() * 4.2).toFixed(2);
    case 'X':  return +(2.90 + r() * 2.0).toFixed(2);
    case '2':  return +(1.45 + r() * 6.0).toFixed(2);
    case '1X': return +(1.08 + r() * 0.9).toFixed(2);
    case 'X2': return +(1.12 + r() * 1.1).toFixed(2);
    case '12': return +(1.10 + r() * 0.6).toFixed(2);
    case 'GG': return +(1.55 + r() * 0.7).toFixed(2);
    case 'H1': return +(1.60 + r() * 0.7).toFixed(2);
    case 'H2': return +(1.60 + r() * 0.7).toFixed(2);
    case 'U':  return +(1.55 + r() * 0.6).toFixed(2);
    case 'O':  return +(1.50 + r() * 0.7).toFixed(2);
    case 'TM': return +(1.80 + r() * 0.5).toFixed(2);
    default:   return +(2.00 + r() * 9.0).toFixed(2);
  }
}

let _eid = 1000;
function makeEvent(sport, league, r, opts = {}) {
  const isOutright = sport.cols === 'outright';
  const pool = isOutright ? (OUTRIGHTS[league.id] || { field: ['A','B','C'] }).field
                          : (TEAMS[league.id] || ['Tim A','Tim B','Tim C','Tim D']);
  let home, away, name;
  if (isOutright) {
    home = pick(pool, r); away = null;
    name = home;
  } else {
    home = pick(pool, r);
    let guard = 0;
    do { away = pick(pool, r); guard++; } while (away === home && guard < 25);
    name = home + ' - ' + away;
  }

  const live = !!opts.live;
  const start = new Date(Date.now() + (live ? -rint(5, 80, r) : rint(20, 8600, r)) * 60000);
  const markets = {};
  MARKET_SETS[sport.cols].forEach(k => {
    // some markets are intentionally missing, mirroring a real offer grid
    if (!isOutright && r() < 0.07) { markets[k] = null; return; }
    markets[k] = oddsFor(k, r);
  });

  const ev = {
    id: 'e' + (_eid++),
    sportId: sport.id,
    leagueId: league.id,
    leagueName: league.name,
    flag: league.flag,
    home, away, name,
    start: start.toISOString(),
    live,
    outright: isOutright,
    markets,
    marketCount: rint(28, 210, r),
    code: rint(1000, 9999, r)
  };
  if (live) {
    ev.minute = rint(3, 88, r);
    ev.score = sport.id === 'kosarka' ? rint(48, 96, r) + ':' + rint(48, 96, r)
             : sport.id === 'tenis'   ? rint(0, 2, r) + ':' + rint(0, 2, r)
             : rint(0, 4, r) + ':' + rint(0, 4, r);
  }
  return ev;
}

/** Build the full offer once, deterministically. */
function buildOffer() {
  const r = makeRng(778899);
  const out = [];
  SPORTS.forEach(sport => {
    (LEAGUES[sport.id] || []).forEach(league => {
      const n = sport.id === 'nogomet' ? rint(4, 11, r)
              : sport.cols === 'outright' ? rint(3, 7, r)
              : rint(3, 9, r);
      for (let i = 0; i < n; i++) {
        out.push(makeEvent(sport, league, r, { live: r() < 0.16 }));
      }
    });
  });
  return out;
}

const OFFER = buildOffer();

/* counts per sport, used by the sidebar */
const SPORT_COUNTS = SPORTS.reduce((acc, s) => {
  acc[s.id] = OFFER.filter(e => e.sportId === s.id).length;
  return acc;
}, {});
const LIVE_COUNT = OFFER.filter(e => e.live).length;

/* ============================================================
   CASINO CATALOGUE
   ============================================================ */
const PROVIDERS = [
  '7777 Gaming','Adell','Amatic','Amusnet','Apollo','Atomic Slot Lab','Barbara Bang','Bellot',
  'BF Games','Big Time Gaming','Bluberi','Casimi','CT Interactive','Digital','E-Gaming','Endorphina',
  'Evolution','Evoplay','Fazi','G-Corps','Galaxsys','GameArt','Games Global','Gamomat','Greentube',
  'Habanero','Indigo Magic','iSoftBet','Kajot','Kalamba','Mojos','NetEnt','Nolimit City','Octoplay',
  'ORYX','Pateplay','Play’n GO','Playson','Playtech','Pragmatic Play','Red Tiger','Slingo',
  'Smartsoft','Spribe','Synot','Tech4Bet','Tom Horn','Wazdan','XGames'
];

const CASINO_CATEGORIES = [
  { id: 'lobby',        name: 'Lobby',              icon: '🏠' },
  { id: 'favourites',   name: 'Favoriti',           icon: '⭐' },
  { id: 'new',          name: 'Nove igre',          icon: '✨' },
  { id: 'popular',      name: 'Popularno',          icon: '🔥' },
  { id: 'jackpot',      name: 'Jackpoti',           icon: '💰' },
  { id: 'exclusive',    name: 'Samo kod nas',       icon: '🎖️' },
  { id: 'game-shows',   name: 'Game Shows',         icon: '🎪' },
  { id: 'buy-bonus',    name: 'Buy Bonus',          icon: '🎁' },
  { id: 'drops',        name: 'Drops & Wins',       icon: '💧' },
  { id: 'small-bets',   name: 'Mali ulozi',         icon: '🪙' },
  { id: 'big-wins',     name: 'Veliki dobici',      icon: '🏆' },
  { id: 'instant',      name: 'Instant igre',       icon: '⚡' },
  { id: 'table',        name: 'Igre na stolovima',  icon: '🃏' },
  { id: 'roulette',     name: 'Rulet',              icon: '🎡' },
  { id: 'classic',      name: 'Klasični slotovi',   icon: '🍒' },
  { id: 'megaways',     name: 'Megaways',           icon: '🌀' },
  { id: 'all',          name: 'Sve igre',           icon: '🎰' }
];

/* Invented game titles built from theme parts — no real trademarks. */
const T_ADJ  = ['Zlatni','Vatreni','Divlji','Sretni','Tajni','Kraljevski','Brzi','Mistični','Ledeni','Srebrni',
                'Veliki','Skriveni','Blistavi','Tihi','Grimizni','Nebeski','Drevni','Munjeviti','Bogati','Zvjezdani'];
const T_NOUN = ['Feniks','Zmaj','Hram','Rudnik','Karavan','Sedam','Kotač','Piramida','Vitez','Grom',
                'Delfin','Vulkan','Safir','Kompas','Galeb','Jelen','Maslina','Sidro','Lampion','Kovčeg',
                'Bubanj','Kraljica','Amfora','Otok','Zvono','Ključ','Krila','Tigar','Orao','Val'];
const T_SUF  = ['','',' Deluxe',' Megaways',' XL',' 27',' Respin',' Bonanza',' Hold & Win',' 100',' Fortune',' Rush',' Gold'];
const SYMS   = ['🍒','🔔','💎','7️⃣','🍇','🍋','⭐','👑','🐉','🔥','🪙','🍀','⚡','🌊','🦅','🎰','💰','🏆','🎲','🥇','🧿','🗝️','🌴','🃏'];
const HUES   = [8, 22, 38, 52, 96, 140, 168, 190, 210, 232, 258, 280, 302, 324, 342];

function makeGames(n) {
  const r = makeRng(424242);
  const seen = new Set();
  const games = [];
  for (let i = 0; games.length < n && i < n * 12; i++) {
    const title = pick(T_ADJ, r) + ' ' + pick(T_NOUN, r) + pick(T_SUF, r);
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
    games.push({
      id: 'g' + (1000 + games.length),
      title,
      provider: pick(PROVIDERS, r),
      sym: pick(SYMS, r),
      h1: h,
      h2: (h + rint(25, 80, r)) % 360,
      cats,
      rtp: +(94 + r() * 3.6).toFixed(2),
      volatility: pick(['Niska','Srednja','Visoka'], r),
      lines: pick([10, 20, 25, 40, 243, 1024, 4096], r),
      minBet: pick([0.10, 0.20, 0.25, 0.50], r),
      maxBet: pick([20, 40, 50, 100], r),
      jackpot: r() < 0.12 ? rint(4000, 480000, r) : 0,
      engine: 'slot'
    });
  }
  return games;
}

const SLOTS = makeGames(420);

/* Hand-built table & live-dealer titles with real playable engines */
const TABLE_GAMES = [
  { id: 't1', title: 'Europski rulet',      provider: 'PSK Studio', sym: '🎡', h1: 0,   h2: 340, cats: ['all','table','roulette','popular','favourites'], engine: 'roulette', rtp: 97.30, volatility: 'Srednja' },
  { id: 't2', title: 'Rulet Pro',           provider: 'PSK Studio', sym: '🎡', h1: 140, h2: 190, cats: ['all','table','roulette'],                        engine: 'roulette', rtp: 97.30, volatility: 'Srednja' },
  { id: 't3', title: 'Blackjack Classic',   provider: 'PSK Studio', sym: '🃏', h1: 210, h2: 260, cats: ['all','table','popular','favourites'],           engine: 'blackjack', rtp: 99.50, volatility: 'Niska' },
  { id: 't4', title: 'Blackjack Multihand', provider: 'PSK Studio', sym: '♠️', h1: 258, h2: 300, cats: ['all','table'],                                   engine: 'blackjack', rtp: 99.40, volatility: 'Niska' },
  { id: 't5', title: 'Aviator Rush',        provider: 'PSK Studio', sym: '🚀', h1: 22,  h2: 52,  cats: ['all','instant','popular','big-wins','favourites'], engine: 'crash', rtp: 97.00, volatility: 'Visoka' },
  { id: 't6', title: 'Crash Royale',        provider: 'PSK Studio', sym: '📈', h1: 96,  h2: 168, cats: ['all','instant','big-wins'],                      engine: 'crash', rtp: 97.00, volatility: 'Visoka' },
  { id: 't7', title: 'Mine Hunter',         provider: 'PSK Studio', sym: '💣', h1: 302, h2: 342, cats: ['all','instant','small-bets'],                    engine: 'mines', rtp: 97.00, volatility: 'Visoka' },
  { id: 't8', title: 'Kocka Duel',          provider: 'PSK Studio', sym: '🎲', h1: 190, h2: 232, cats: ['all','instant','table','small-bets'],            engine: 'dice', rtp: 98.00, volatility: 'Srednja' }
];

const LIVE_TABLES = [
  { id: 'l1',  title: 'Live Rulet HR',        provider: 'Evolution',      sym: '🎡', h1: 0,   h2: 30,  cats: ['live','roulette','popular'], engine: 'roulette', players: 0 },
  { id: 'l2',  title: 'Auto Rulet Speed',     provider: 'Evolution',      sym: '⚡', h1: 22,  h2: 44,  cats: ['live','roulette'],           engine: 'roulette', players: 0 },
  { id: 'l3',  title: 'Live Blackjack A',     provider: 'Evolution',      sym: '🃏', h1: 140, h2: 168, cats: ['live','table','popular'],    engine: 'blackjack', players: 0 },
  { id: 'l4',  title: 'Live Blackjack VIP',   provider: 'Playtech',       sym: '♠️', h1: 210, h2: 240, cats: ['live','table'],              engine: 'blackjack', players: 0 },
  { id: 'l5',  title: 'Kolo sreće',           provider: 'Evolution',      sym: '🎪', h1: 280, h2: 320, cats: ['live','game-shows','popular'], engine: 'wheel', players: 0 },
  { id: 'l6',  title: 'Mega Kotač Live',      provider: 'Pragmatic Play', sym: '🌀', h1: 302, h2: 342, cats: ['live','game-shows'],         engine: 'wheel', players: 0 },
  { id: 'l7',  title: 'Live Baccarat',        provider: 'Evolution',      sym: '🎴', h1: 96,  h2: 130, cats: ['live','table'],              engine: 'baccarat', players: 0 },
  { id: 'l8',  title: 'Speed Baccarat',       provider: 'Playtech',       sym: '🎴', h1: 168, h2: 196, cats: ['live','table'],              engine: 'baccarat', players: 0 },
  { id: 'l9',  title: 'Live Poker Hold’em', provider: 'Evolution',   sym: '🂡', h1: 232, h2: 268, cats: ['live','table'],              engine: 'poker', players: 0 },
  { id: 'l10', title: 'Dice Show Live',       provider: 'Pragmatic Play', sym: '🎲', h1: 52,  h2: 96,  cats: ['live','game-shows'],         engine: 'dice', players: 0 },
  { id: 'l11', title: 'Sic Bo Live',          provider: 'Evolution',      sym: '🀄', h1: 8,   h2: 52,  cats: ['live','table'],              engine: 'dice', players: 0 },
  { id: 'l12', title: 'Craps Live',           provider: 'Evolution',      sym: '🎯', h1: 190, h2: 220, cats: ['live','table'],              engine: 'dice', players: 0 }
];

const ALL_GAMES = SLOTS.concat(TABLE_GAMES);
(function seedPlayers() {
  const r = makeRng(9911);
  LIVE_TABLES.forEach(t => { t.players = rint(12, 480, r); });
})();

/* ============================================================
   VIRTUAL GAMES / LOTTERY
   ============================================================ */
const VIRTUALS = [
  { id: 'v1', name: 'Virtualni nogomet',   icon: '⚽', sym: '⚽', h1: 140, h2: 168, every: '3 min', desc: 'Simulirana liga s 16 momčadi i punom ponudom tržišta.' },
  { id: 'v2', name: 'Virtualne konjske utrke', icon: '🐎', sym: '🐎', h1: 22, h2: 52, every: '2 min', desc: 'Osam grla po utrci, pobjednik i plasman.' },
  { id: 'v3', name: 'Virtualni hrtovi',    icon: '🐕', sym: '🐕', h1: 38, h2: 96, every: '2 min', desc: 'Šest hrtova, brze utrke tijekom cijelog dana.' },
  { id: 'v4', name: 'Virtualni tenis',     icon: '🎾', sym: '🎾', h1: 96, h2: 140, every: '4 min', desc: 'Meč na dva dobivena seta, uživo simulacija.' },
  { id: 'v5', name: 'Virtualna košarka',   icon: '🏀', sym: '🏀', h1: 8,  h2: 38,  every: '5 min', desc: 'Četiri četvrtine, hendikep i ukupno poena.' },
  { id: 'v6', name: 'Virtualni auto trke', icon: '🏎️', sym: '🏎️', h1: 210, h2: 258, every: '3 min', desc: 'Utrka s deset bolida i tržištem pobjednika.' },
  { id: 'v7', name: 'Virtualni biciklizam',icon: '🚴', sym: '🚴', h1: 168, h2: 196, every: '4 min', desc: 'Etapa s dvanaest vozača.' },
  { id: 'v8', name: 'Brzi keno',           icon: '🔢', sym: '🔢', h1: 280, h2: 324, every: '1 min', desc: 'Izvlačenje 20 od 80 brojeva svake minute.' }
];

const LOTTERIES = [
  { id: 'loto-7-39', name: 'Loto 7/39',       pick: 7,  max: 39, draw: 'Srijeda i nedjelja, 20:00', jackpot: 1850000, price: 1.00 },
  { id: 'loto-6-45', name: 'Loto 6/45',       pick: 6,  max: 45, draw: 'Utorak i petak, 20:00',     jackpot: 640000,  price: 0.80 },
  { id: 'eurojack',  name: 'Euro Jackpot',    pick: 5,  max: 50, draw: 'Petak, 21:00',              jackpot: 12500000, price: 2.00 },
  { id: 'keno',      name: 'Keno',            pick: 10, max: 80, draw: 'Svakih 5 minuta',           jackpot: 100000,  price: 0.50 },
  { id: 'bingo',     name: 'Bingo 90',        pick: 6,  max: 90, draw: 'Svakih 10 minuta',          jackpot: 48000,   price: 1.00 },
  { id: 'brojevi',   name: 'Sretni brojevi',  pick: 8,  max: 35, draw: 'Svakih 4 minute',           jackpot: 25000,   price: 0.50 }
];

/* ============================================================
   PROMOTIONS / NEWS / SHOPS
   ============================================================ */
const PROMOS = [
  { id: 'p1', tag: 'Sport',  title: 'Bonus dobrodošlice na prvu uplatu', text: 'Novi igrači dobivaju bonus na prvu uplatu do zadanog iznosa, uz uvjet prometa opisan u pravilima akcije.', cta: 'Preuzmi bonus', h1: 210, h2: 258 },
  { id: 'p2', tag: 'Casino', title: 'Besplatni okreti svaki tjedan',      text: 'Tjedni paket besplatnih okreta na odabranim igrama za sve verificirane korisnike.', cta: 'Pogledaj igre', h1: 280, h2: 324 },
  { id: 'p3', tag: 'Sport',  title: 'Bonus tip na kombinacije',           text: 'Što više parova na listiću, to veći postotak bonusa na dobitak. Postoci su navedeni u tablici akcije.', cta: 'Saznaj više', h1: 22, h2: 52 },
  { id: 'p4', tag: 'Sport',  title: 'Favorit Plus',                       text: 'Uvećani tečajevi na odabrane favorite u ponudi dana.', cta: 'Odigraj', h1: 140, h2: 168 },
  { id: 'p5', tag: 'Casino', title: 'Mjesečni turnir igrača',             text: 'Skupljaj bodove igrajući odabrane igre i natječi se za nagradni fond.', cta: 'Rang lista', h1: 96, h2: 140 },
  { id: 'p6', tag: 'Loto',   title: 'Dupli listić srijedom',              text: 'Uplati loto listić srijedom i dobij drugi listić za isto kolo.', cta: 'Uplati listić', h1: 302, h2: 342 },
  { id: 'p7', tag: 'Klub',   title: 'Klub prvaka - bodovi i razine',      text: 'Sakupljaj bodove kroz igru i otključavaj razine s dodatnim pogodnostima.', cta: 'O klubu', h1: 190, h2: 232 },
  { id: 'p8', tag: 'Casino', title: 'Drops & Wins nagradni fond',         text: 'Dnevne i mjesečne nagrade na odabranim igrama uključenim u akciju.', cta: 'Igraj sada', h1: 8, h2: 38 }
];

const NEWS = [
  { id: 'n1', cat: 'Nogomet',  title: 'Najava kola: derbi zatvara subotu',      date: '2026-09-08', text: 'Pregled forme, izostanaka i statistike uoči najvažnije utakmice kola.' },
  { id: 'n2', cat: 'Košarka',  title: 'Euroliga: analiza uvodnih susreta',      date: '2026-09-07', text: 'Kako su europski klubovi otvorili sezonu i što očekivati u nastavku.' },
  { id: 'n3', cat: 'Tenis',    title: 'Turnirski raspored za rujan',            date: '2026-09-06', text: 'Sve o nadolazećim ATP i WTA turnirima te hrvatskim predstavnicima.' },
  { id: 'n4', cat: 'E-sport',  title: 'Kvalifikacije za svjetsko prvenstvo',    date: '2026-09-05', text: 'Raspored, formati i favoriti u nadolazećim kvalifikacijama.' },
  { id: 'n5', cat: 'Casino',   title: 'Nove igre u ponudi ovog mjeseca',        date: '2026-09-04', text: 'Pregled naslova koji su ovog mjeseca dodani u casino ponudu.' },
  { id: 'n6', cat: 'Kladionica', title: 'Vodič: kako radi BetBuilder',         date: '2026-09-03', text: 'Korak po korak kroz slaganje vlastite oklade na jedan događaj.' },
  { id: 'n7', cat: 'Rukomet',  title: 'Regionalna liga pred startom',           date: '2026-09-02', text: 'Sastavi, pojačanja i očekivanja pred novu sezonu.' },
  { id: 'n8', cat: 'Sigurnost',title: 'Sigurnosni vodič za korisnike',          date: '2026-09-01', text: 'Kako zaštititi račun, prepoznati prijevare i postaviti limite igre.' }
];

const SHOPS = [
  { city: 'Zagreb',     addr: 'Ilica 120',              hours: '07:00 - 23:00', type: 'Kladionica + kafić' },
  { city: 'Zagreb',     addr: 'Avenija Dubrovnik 16',   hours: '00:00 - 24:00', type: 'Kladionica' },
  { city: 'Zagreb',     addr: 'Vukovarska 269',         hours: '08:00 - 22:00', type: 'Kladionica + kafić' },
  { city: 'Split',      addr: 'Domovinskog rata 24',    hours: '07:00 - 24:00', type: 'Kladionica' },
  { city: 'Split',      addr: 'Poljička cesta 5',       hours: '08:00 - 23:00', type: 'Kladionica + kafić' },
  { city: 'Rijeka',     addr: 'Korzo 14',               hours: '07:00 - 23:00', type: 'Kladionica' },
  { city: 'Rijeka',     addr: 'Zvonimirova 8',          hours: '08:00 - 22:00', type: 'Kladionica' },
  { city: 'Osijek',     addr: 'Trg slobode 3',          hours: '07:00 - 23:00', type: 'Kladionica + kafić' },
  { city: 'Zadar',      addr: 'Široka ulica 11',        hours: '08:00 - 24:00', type: 'Kladionica' },
  { city: 'Varaždin',   addr: 'Gundulićeva 2',          hours: '07:00 - 22:00', type: 'Kladionica' },
  { city: 'Slavonski Brod', addr: 'Ulica kralja Petra 7', hours: '08:00 - 22:00', type: 'Kladionica' },
  { city: 'Pula',       addr: 'Giardini 9',             hours: '07:00 - 23:00', type: 'Kladionica + kafić' },
  { city: 'Dubrovnik',  addr: 'Stradun 4',              hours: '09:00 - 23:00', type: 'Kladionica' },
  { city: 'Šibenik',    addr: 'Kralja Zvonimira 12',    hours: '08:00 - 22:00', type: 'Kladionica' },
  { city: 'Karlovac',   addr: 'Trg bana Jelačića 6',    hours: '07:00 - 22:00', type: 'Kladionica' },
  { city: 'Vinkovci',   addr: 'Duga ulica 30',          hours: '08:00 - 22:00', type: 'Kladionica' }
];

const PAYMENTS = ['Visa','Mastercard','Maestro','Apple Pay','Google Pay','PayPal','Keks Pay','IBAN','Aircash','Skrill','Neteller','Paysafecard'];

/* expose */
window.PSK_DATA = {
  SPORTS, LEAGUES, TEAMS, OUTRIGHTS, OFFER, SPORT_COUNTS, LIVE_COUNT,
  MARKET_SETS, MARKET_LABELS,
  PROVIDERS, CASINO_CATEGORIES, SLOTS, TABLE_GAMES, LIVE_TABLES, ALL_GAMES,
  VIRTUALS, LOTTERIES, PROMOS, NEWS, SHOPS, PAYMENTS,
  makeRng
};
