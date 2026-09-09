/* Croatian strings — the source language of the project. */
export default {
  /* ---------------- generic ---------------- */
  common: {
    play: 'Igraj', details: 'Detalji', close: 'Zatvori', ok: 'U redu',
    back: 'Natrag', save: 'Spremi', send: 'Pošalji', cancel: 'Odustani',
    search: 'Pretraži', filter: 'Filtriraj', all: 'Sve', more: 'Više',
    seeAll: 'Vidi sve', open: 'Otvori', loading: 'Učitavam…',
    error: 'Greška', retry: 'Pokušaj ponovno', noData: 'Nema podataka za prikaz.',
    prev: 'Prethodna', next: 'Sljedeća', page: 'Stranica',
    home: 'Naslovna', yes: 'Da', no: 'Ne', note: 'Napomena',
    provider: 'Provider', balance: 'Stanje', stake: 'Ulog',
    lastWin: 'Zadnji dobitak', games: 'igara', events: 'događaja',
    status: 'Status', date: 'Datum', time: 'Vrijeme', amount: 'Iznos'
  },

  demoBar: 'DEMO / UČENJE — nezavisna MERN vježba. Nije povezano s pravim operaterom; nema stvarnog novca ni klađenja.',

  /* ---------------- navigation ---------------- */
  nav: {
    sport: 'Sport', live: 'Uživo', casino: 'Casino', liveCasino: 'Live Casino',
    loto: 'Loto', virtuals: 'Virtualne igre', forum: 'Forum', arena: 'Arena',
    promo: 'Promo', swipe: 'Swipe & Bet',
    home: 'Naslovna', mobileApp: 'Mobilna aplikacija', results: 'Rezultati',
    statistics: 'Statistika', news: 'Novosti', club: 'Klub prvaka',
    help: 'Pomoć', shops: 'Poslovnice', tickets: 'Listići'
  },

  header: {
    menu: 'Izbornik', searchPlaceholder: 'Pretraži događaje i igre...',
    searchLabel: 'Pretraga', theme: 'Svijetla / tamna tema',
    themeDark: 'Tamna', themeLight: 'Svijetla', help: 'Pomoć',
    login: 'Prijava', register: 'Registracija', account: 'Moj račun',
    logout: 'Odjava', deposit: 'Uplata demo kredita'
  },

  /* ---------------- footer ---------------- */
  footer: {
    offer: 'Ponuda', aboutUs: 'O nama', rules: 'Pravila', support: 'Podrška',
    app: 'Aplikacija', language: 'Jezik',
    sportsbook: 'Sportska kladionica', liveBetting: 'Klađenje uživo',
    promotions: 'Promocije', aboutProject: 'O projektu', contact: 'Kontakt',
    gameRules: 'Pravila igre', bonusRules: 'Opća pravila bonusa',
    privacy: 'Pravila o privatnosti', cookies: 'Politika kolačića',
    dataProtection: 'Zaštita osobnih podataka',
    faq: 'Pomoć i česta pitanja', contactForm: 'Kontakt forma',
    responsible: 'Odgovorno igranje', selfExclusion: 'Samoisključenje',
    limits: 'Limiti igre',
    androidApp: 'Android aplikacija', iosApp: 'iOS aplikacija', casinoApp: 'Casino aplikacija',
    social: 'Društvene mreže (prikaz)',
    payments: 'Načini plaćanja (samo prikaz)',
    ageWarning: 'Igre na sreću mogu izazvati ovisnost. Igraj odgovorno i postavi limite. Više na stranici',
    disclaimerLead: 'Ovo je demonstracijski projekt.',
    disclaimer: 'Samostalno izrađena MERN aplikacija (MongoDB, Express, React, Node) napravljena radi učenja. Nije povezana ni s jednim stvarnim priređivačem igara na sreću, ne prihvaća uplate, ne omogućuje stvarno klađenje i ne predstavlja nijednu tvrtku. Svi događaji, tečajevi, igre i iznosi su generirani podaci, a stanje računa su izmišljeni demo krediti.',
    copyright: 'obrazovni projekt.'
  },

  /* ---------------- bet slip ---------------- */
  slip: {
    title: 'Listić', myTickets: 'Moji listići',
    empty: 'Listić je prazan.', emptyHint: 'Odaberi tečaj iz ponude.',
    remove: 'Ukloni', stake: 'Uplata', pairs: 'Parova',
    totalOdds: 'Ukupni tečaj', gross: 'Bruto dobitak',
    deduction: 'Odbitak (10%)', potential: 'Mogući dobitak',
    place: 'Uplati listić', placing: 'Uplaćujem…', clear: 'Obriši listić',
    loginTitle: 'Prijava potrebna',
    loginBody: 'Za uplatu listića potrebna je prijava na demo račun.',
    loginNote: 'Demo račun koristi izmišljene kredite, ne stvarni novac.',
    placedTitle: 'Listić uplaćen',
    placedBody: 'Demo listić {ref} je zaprimljen.',
    placedToast: 'Listić {ref} uplaćen (demo).',
    code: 'šifra'
  },

  /* ---------------- sportsbook ---------------- */
  sportsbook: {
    sports: 'Sportovi', filterSports: 'Filtriraj sport...',
    noSports: 'Nema sportova za taj filter.',
    offer: 'Ponuda', event: 'Događaj',
    allMarkets: 'Sva tržišta', noEvents: 'Nema događaja za odabrane filtere.',
    eventsCount: '{n} događaja',
    filters: { all: 'Sve', live: 'Uživo', today: 'Danas', soon: 'Uskoro (3h)' },
    addedToSlip: 'Tržište {key} dodano na listić.',
    liveShort: 'UŽIVO'
  },

  /* ---------------- casino ---------------- */
  casino: {
    title: 'Casino',
    lede: 'Katalog demo igara s kategorijama, providerima i pretragom. Svaka runda obračunava se na poslužitelju uz demo stanje računa — stvarni novac nije uključen.',
    searchPlaceholder: 'Pronađi svoju igru...',
    searchLabel: 'Pretraga igara',
    providers: 'Provideri', allProviders: 'Svi provideri ({n})',
    noGames: 'Nema igara za odabrane filtere.',
    gamesCount: '{n} igara',
    jackpotTiers: ['Mega', 'Major', 'Minor', 'Mini'],
    new: 'NOVO', exclusive: 'EKSKLUZIVNO', jackpot: 'JACKPOT', live: 'UŽIVO',
    previewTag: 'DEMO',
    info: {
      type: 'Tip igre', rtp: 'RTP', volatility: 'Volatilnost', lines: 'Linije',
      betRange: 'Raspon uloga', jackpot: 'Jackpot', none: 'nema',
      note: 'Igra je demonstracijska simulacija. Rundu obračunava poslužitelj na demo stanju računa — stvarni novac nije uključen.'
    }
  },

  liveCasino: {
    title: 'Live Casino',
    lede: 'Simulirani stolovi uživo. Svaki stol pokreće odgovarajući demo mehanizam igre — rulet, blackjack, baccarat, kolo sreće ili kocke.',
    tabs: { all: 'Svi stolovi', roulette: 'Rulet', table: 'Kartaške igre', shows: 'Game Shows' },
    noTables: 'Nema stolova u ovoj kategoriji.',
    howTitle: 'Kako radi ponuda uživo',
    howBody: 'U stvarnim sustavima live casino stolovi emitiraju video iz studija, a klijent prima stanje stola preko trajne veze (WebSocket ili sličan kanal). U ovoj demonstraciji taj sloj zamijenjen je lokalnom simulacijom: broj igrača dolazi iz baze, a rezultat runde generira klijent i potvrđuje poslužitelj.'
  },

  providers: {
    title: 'Provideri',
    lede: 'Studiji zastupljeni u demo katalogu. Odabir providera filtrira katalog igara.',
    searchPlaceholder: 'Pretraži providere...',
    searchLabel: 'Pretraga providera'
  },

  /* ---------------- games ---------------- */
  game: {
    loginRequired: 'Prijavi se na demo račun za igranje.',
    betPositive: 'Ulog mora biti veći od nule.',
    insufficient: 'Nedovoljno demo kredita.',

    slot: {
      spin: 'ZAVRTI', spinning: 'VRTIM…', rolling: 'Vrtim...',
      rules: '5 linija · 3 u nizu = 4×, 4 = 12×, 5 = 45× uloga po liniji',
      win: 'Dobitak {amount}!', noWin: 'Nema dobitne kombinacije. Pokušaj ponovno.',
      footer: 'RTP {rtp}% · Volatilnost: {vol} · {provider}'
    },

    roulette: {
      spin: 'ZAVRTI', spinning: 'VRTIM…',
      prompt: 'Odaberi jednu ili više oklada, zatim zavrti.',
      selected: 'Odabrano oklada: {n}',
      pickFirst: 'Prvo odaberi okladu.',
      rolling: 'Kuglica se vrti…',
      win: 'Broj {n} ({color}) — dobitak {amount}',
      lose: 'Broj {n} ({color}) — nema dobitka.',
      colors: { red: 'crveno', black: 'crno', green: 'zeleno' },
      bets: {
        red: 'CRVENO', black: 'CRNO', odd: 'NEPAR', even: 'PAR',
        low: '1-18', high: '19-36',
        d1: '1. tucet', d2: '2. tucet', d3: '3. tucet', zero: 'ZERO (0)'
      },
      footer: 'Europski rulet, jedna nula · RTP 97,30% · ulog vrijedi po svakoj odabranoj okladi · {provider}'
    },

    blackjack: {
      dealer: 'Djelitelj', player: 'Igrač',
      deal: 'Podijeli', hit: 'Još kartu', stand: 'Stani',
      prompt: 'Postavi ulog i podijeli karte.', yourTurn: 'Tvoj potez.',
      blackjack: 'Blackjack!', bust: 'Prekoračenje ({v}).',
      dealerBust: 'Djelitelj je prekoračio ({d}).',
      win: 'Pobjeda {p}:{d}.', push: 'Neriješeno {p}:{d} — ulog vraćen.',
      lose: 'Djelitelj pobjeđuje {d}:{p}.',
      footer: 'Blackjack plaća 3:2 · djelitelj vuče do 17 · {provider}'
    },

    crash: {
      start: 'Pokreni', cash: 'Naplati',
      prompt: 'Postavi ulog, pokreni rundu i naplati prije pada.',
      running: 'Runda je u tijeku…',
      bust: 'Pad na {mult}× — ulog izgubljen.',
      cashed: 'Naplaćeno na {mult}× — {amount}',
      footer: 'RTP 97% · maksimalni množitelj 100× · {provider}'
    },

    mines: {
      start: 'Nova runda', cash: 'Naplati',
      prompt: 'Pokreni rundu i otkrivaj polja.',
      playing: 'Otkrivaj polja i naplati prije mine.',
      safe: 'Sigurnih polja: {n} · množitelj {mult}×',
      boom: 'Mina! Runda je gotova.',
      needOne: 'Otkrij barem jedno polje.',
      cashed: 'Naplaćeno {mult}× — {amount}',
      footer: '25 polja, 3 mine · množitelj raste sa svakim sigurnim poljem · {provider}'
    },

    dice: {
      roll: 'Baci', prompt: 'Odaberi okladu i baci kocke.',
      under: 'Manje (2-6)', seven: 'Točno 7', over: 'Više (8-12)',
      win: 'Zbroj {sum} — dobitak {amount}', lose: 'Zbroj {sum} — nema dobitka.',
      footer: 'Dvije kocke · "Točno 7" plaća 5× · {provider}'
    },

    wheel: {
      spin: 'ZAVRTI', prompt: 'Odaberi polje i zavrti kolo.',
      rolling: 'Kolo se vrti…',
      win: 'Palo je {v}× — dobitak {amount}',
      lose: 'Palo je {v}×, tvoj odabir {sel}×.',
      footer: 'Kolo sreće, 20 polja · {provider}'
    },

    baccarat: {
      deal: 'Podijeli', prompt: 'Odaberi stranu i podijeli.',
      player: 'Igrač', bank: 'Banka', tie: 'Neriješeno',
      betPlayer: 'Igrač (2×)', betBank: 'Banka (1,95×)', betTie: 'Neriješeno (9×)',
      win: '{side} {p}:{b} — dobitak {amount}',
      lose: '{side} {p}:{b} — nema dobitka.',
      footer: 'Punto Banco pravila (pojednostavljeno) · {provider}'
    }
  },

  /* ---------------- home ---------------- */
  home: {
    slides: [
      {
        eyebrow: 'Sportska kladionica',
        title: 'Preko 30 sportova i 150 liga u jednoj ponudi',
        text: 'Prematch i klađenje uživo, puna ploča tržišta, sistemi i kombinacije.',
        primary: 'Otvori ponudu', secondary: 'Klađenje uživo'
      },
      {
        eyebrow: 'Casino',
        title: 'Više od 400 igara i dnevni jackpotovi',
        text: 'Slotovi, igre na stolovima, instant igre i game showovi.',
        primary: 'Uđi u casino', secondary: 'Live Casino'
      },
      {
        eyebrow: 'Loto i virtualne igre',
        title: 'Izvlačenja svaki dan, kola svakih nekoliko minuta',
        text: 'Loto 7/39, Euro Jackpot, keno i bingo uz virtualni sport 24/7.',
        primary: 'Loto ponuda', secondary: 'Virtualne igre'
      }
    ],
    quickAccess: 'Brzi pristup',
    quick: {
      sport: 'Sport', live: 'Uživo', casino: 'Casino', liveCasino: 'Live Casino',
      loto: 'Loto', virtuals: 'Virtualne', swipe: 'Swipe & Bet', promo: 'Promo'
    },
    quickOpen: 'otvori',
    liveCasinoSub: 'stolovi uživo', lotoSub: '6 igara', virtualsSub: '24/7 kola',
    swipeSub: 'brzi listić', promoSub: 'akcije',
    topOffer: 'Izdvojeno iz ponude', wholeOffer: 'Cijela ponuda',
    liveNow: 'Uživo sada', allLive: 'Sve uživo',
    promos: 'Aktualne promocije', allPromos: 'Sve promocije',
    news: 'Novosti i analize', allNews: 'Sve novosti',
    addedToSlip: 'Dodano na listić.', removedFromSlip: 'Uklonjeno s listića.',
    aboutTitle: 'O ovom projektu',
    aboutBody: 'Ovo je samostalno izrađena MERN aplikacija (MongoDB, Express, React, Node) koja demonstrira kako je strukturirana tipična stranica sportske kladionice i online casina: navigacija po proizvodima, stablo sportova, mreža tečajeva, listić, katalog igara s filtriranjem te informativne stranice.',
    implementedTitle: 'Što je implementirano',
    implemented: [
      'REST API na Expressu s Mongoose modelima za sportove, lige, događaje, igre, korisnike i listiće.',
      'Prijava i registracija s JWT tokenom te demo stanjem računa.',
      'Listić koji se validira na poslužitelju — tečajevi se čitaju iz baze, ne s klijenta.',
      'Casino katalog s kategorijama, providerima, pretragom i jackpot prikazom.',
      'Osam igrivih demo igara; svaku rundu obračunava poslužitelj.',
      'Svijetla i tamna tema, višejezično sučelje i responzivni raspored.'
    ],
    noteTitle: 'Napomena',
    noteBody: 'Aplikacija ne prima uplate, ne omogućuje stvarno klađenje i nije povezana ni s jednim priređivačem igara na sreću. Svi događaji, tečajevi, nazivi igara i iznosi generirani su podaci, a stanje računa su izmišljeni demo krediti.'
  },

  /* ---------------- loto ---------------- */
  loto: {
    title: 'Loto i brojčane igre',
    lede: 'Brojčane igre s različitim rasponima. Odaberi brojeve ručno ili nasumično, pokreni izvlačenje i vidi koliko si pogodio.',
    pickRange: 'Odabir {pick} od {max}', drawing: 'Izvlačenje: {info}',
    buyTicket: 'Uplati listić',
    ticketPrompt: 'Odaberi {pick} brojeva od {max}.',
    randomPick: 'Slučajno', draw: 'Izvuci', drawingNow: 'Izvlačenje…',
    pickExactly: 'Odaberi točno {pick} brojeva.',
    hits: 'Pogodaka: {n} — dobitak {amount}',
    noHits: 'Pogodaka: {n} — nema dobitka.',
    ticketFooter: 'Prikazani jackpot: {jackpot} · cijena kombinacije {price}. Dobitak se u ovoj demonstraciji računa po broju pogodaka (3 → 2×, 4 → 8×, 5 → 40×, 6 → 400×, 7 → 5000×).',
    lastDraws: 'Zadnja izvlačenja',
    tbl: { game: 'Igra', round: 'Kolo', date: 'Datum', numbers: 'Izvučeni brojevi', fund: 'Fond' },
    howTitle: 'Kako se računa dobitak',
    howBody: 'U ovoj demonstraciji dobitak ovisi isključivo o broju pogodaka prema fiksnoj tablici množitelja. Stvarni sustavi koriste fond kola i broj dobitnika po razredu, što ovdje nije modelirano.',
    responsibleTitle: 'Odgovorna igra',
    responsibleBody: 'Brojčane igre su igre čiste sreće — nijedna kombinacija nije vjerojatnija od druge, a prethodna izvlačenja ne utječu na sljedeća. Više o postavljanju limita na stranici'
  },

  /* ---------------- virtuals ---------------- */
  virtuals: {
    title: 'Virtualne igre',
    lede: 'Simulirana natjecanja koja se odvijaju neprekidno. Odaberi pobjednika, pokreni kolo i prati ishod utrke generirane u pregledniku.',
    start: 'Pokreni', newRoundEvery: 'novo kolo svakih {interval}',
    schedule: 'Raspored sljedećih kola',
    tbl: { game: 'Igra', next: 'Sljedeće kolo', interval: 'Interval', runners: 'Sudionika', status: 'Status' },
    open: 'otvoreno',
    racePrompt: 'Odaberi pobjednika i pokreni kolo.',
    running: 'Kolo je u tijeku…',
    startRound: 'Pokreni kolo',
    winner: 'Pobjednik: {name} — dobitak {amount}',
    loser: 'Pobjednik: {name} — nema dobitka.',
    colours: ['Crveni', 'Plavi', 'Zeleni', 'Žuti', 'Bijeli', 'Crni', 'Sivi', 'Ljubičasti', 'Narančasti', 'Smeđi', 'Srebrni', 'Zlatni'],
    whatTitle: 'Što su virtualne igre',
    whatBody: 'Virtualne igre su simulacije sportskih događaja čiji ishod određuje generator slučajnih brojeva. Ne prati se stvarno natjecanje — svako kolo je nezavisno, a rezultat prethodnog kola ne utječe na sljedeće.',
    howTitle: 'Kako je ovo implementirano',
    howBody: 'Svaka igra generira polje sudionika s tečajevima, zatim pokreće animiranu simulaciju u kojoj svaki sudionik napreduje nasumičnim korakom. Pobjednik je onaj s najvećim ukupnim napretkom, a runda se obračunava na poslužitelju kao i ostale demo igre.'
  },

  /* ---------------- swipe ---------------- */
  swipe: {
    title: 'Swipe & Bet',
    lede: 'Brzi način slaganja listića: prihvati ili odbaci ponuđeni par. Prihvaćeni parovi odmah idu na zajednički listić. Radi i sa strelicama na tipkovnici.',
    done: 'Prošao si sve prijedloge.', openOffer: 'Otvori ponudu',
    reject: 'Odbaci', skip: 'Preskoči', accept: 'Dodaj na listić',
    onSlip: 'Na listiću: {n} parova',
    suggestion: 'prijedlog {i} / {total}',
    openInOffer: 'Otvori listić u ponudi',
    added: 'Dodano na listić: {name}',
    howTitle: 'Kako radi',
    howBody: 'Svaka kartica prikazuje jedan događaj i jedan prijedlog tržišta s pripadajućim tečajem. Potvrda dodaje par na listić koji dijele sve stranice aplikacije, pa ga možeš dovršiti u ponudi. Odbacivanje ili preskakanje prelazi na sljedeći prijedlog.'
  },

  /* ---------------- arena ---------------- */
  arena: {
    title: 'Arena',
    lede: 'Prostor u kojem igrači dijele svoje listiće. Listić postaje vidljiv ovdje kad ga podijeliš sa stranice',
    tabs: { tickets: 'Podijeljeni listići', inspiration: 'Inspiriraj se' },
    empty: 'Još nema podijeljenih listića. Uplati listić i podijeli ga da se pojavi ovdje.',
    statuses: { won: 'dobitan', lost: 'gubitan', open: 'u tijeku' },
    copy: 'Kopiraj na moj listić',
    copied: 'Kopirano {n} parova na tvoj listić.',
    copyFailed: 'Nijedan par više nije u ponudi.',
    player: 'igrač',
    howTitle: 'Kako koristiti tuđe listiće',
    howLead: 'Arena prikazuje kombinacije drugih igrača kao izvor ideja, ne kao preporuku. Tri stvari koje vrijedi provjeriti prije kopiranja:',
    howPoints: [
      ['Uzorak', 'postotak pogodaka na dvadeset listića malo govori; tek na nekoliko stotina počinje biti informativan.'],
      ['Tečajni raspon', 'visok postotak pogodaka na niskim tečajevima ne znači profitabilnost.'],
      ['Vrijeme', 'tečaj se mijenja, pa kopirani par može imati drukčiju vrijednost nego u trenutku uplate.']
    ],
    noteTitle: 'Napomena',
    noteBody: 'Listići u Areni dolaze iz demo baze ove aplikacije. Ne predstavljaju stvarne igrače ni stvarne rezultate.'
  },

  /* ---------------- promotions ---------------- */
  promos: {
    title: 'Promocije',
    lede: 'Prikaz tipičnih akcija koje kladionice nude. Svi opisi su ilustrativni — u demo verziji nema stvarnih bonusa niti uvjeta prometa.',
    modalNote: 'Ovo je demonstracijski prikaz. Akcija se ne može aktivirati jer aplikacija ne obrađuje stvarne uplate — koriste se samo demo krediti.',
    termsTitle: 'Ilustrativni uvjeti',
    terms: { turnover: 'Uvjet prometa', minOdds: 'Minimalni tečaj', deadline: 'Rok', minDeposit: 'Minimalna uplata', days: 'dana' },
    readTitle: 'Kako se čitaju uvjeti bonusa',
    readLead: 'Kod stvarnih ponuda uvijek se provjeravaju četiri stvari:',
    readPoints: [
      ['Uvjet prometa', 'koliko puta treba odigrati iznos bonusa prije isplate.'],
      ['Minimalni tečaj', 'parovi ispod zadanog tečaja često se ne broje u promet.'],
      ['Rok', 'vremenski period u kojem uvjet mora biti ispunjen.'],
      ['Doprinos igara', 'različite igre doprinose prometu različitim postotkom.']
    ],
    readTail: 'Detaljna pravila nalaze se na stranici'
  },

  /* ---------------- forum ---------------- */
  forum: {
    title: 'Forum',
    lede: 'Rasprave zajednice o ponudi, strategiji i igrama. Sadržaj je demonstracijski i unaprijed generiran — nema stvarnih korisnika.',
    noThreads: 'Nema tema u ovoj kategoriji.',
    replies: '{n} odgovora', views: '{n} pregleda',
    repliesTitle: 'Odgovori',
    postDisabled: 'Objavljivanje odgovora nije omogućeno u ovoj demonstraciji — forum je samo za prikaz strukture stranice.',
    backToForum: 'Natrag na forum',
    rulesTitle: 'Pravila zajednice',
    rules: [
      'Rasprava o ponudi i strategiji je dobrodošla; savjeti nisu jamstvo ishoda.',
      'Nema dijeljenja tuđih osobnih podataka ni pristupnih podataka računa.',
      'Igra je zabava, a ne izvor prihoda — postavi limite prije nego što ti zatrebaju.'
    ]
  },

  /* ---------------- results / stats ---------------- */
  results: {
    title: 'Rezultati',
    lede: 'Događaji koji su počeli ili su završeni. Rezultati su generirani demonstracijski podaci.',
    none: 'Nema rezultata za prikaz.',
    tbl: { sport: 'Sport', competition: 'Natjecanje', event: 'Događaj', time: 'Vrijeme', result: 'Rezultat' }
  },

  stats: {
    title: 'Statistika ponude',
    lede: 'Pregled onoga što se trenutno nalazi u bazi: broj događaja, igara i raspodjela po sportovima i providerima.',
    cards: {
      events: 'događaja u ponudi', live: 'događaja uživo',
      games: 'igara u katalogu', jackpot: 'zbroj prikazanih jackpota'
    },
    bySport: 'Događaji po sportu',
    byProvider: 'Igre po provideru (top 20)',
    tbl: { sport: 'Sport', share: 'Udio', live: 'Uživo', total: 'Ukupno', provider: 'Provider', games: 'Igara' },
    noteTitle: 'Napomena o podacima',
    noteBody: 'Sve brojke dolaze iz lokalne MongoDB baze koju popunjava skripta za sijanje podataka. Podaci su generirani determinističkim generatorom slučajnih brojeva, pa je svako ponovno sijanje identično.'
  },

  /* ---------------- news ---------------- */
  news: {
    title: 'Novosti i analize',
    lede: 'Tekstovi o ponudi, sportskim najavama i vodičima. Sadržaj je demonstracijski.',
    none: 'Nema članaka u ovoj kategoriji.',
    articleNote: 'Tekst je generirani demonstracijski sadržaj i ne predstavlja stvarnu novinarsku analizu.',
    allNews: 'Sve novosti'
  },

  /* ---------------- shops ---------------- */
  shops: {
    title: 'Poslovnice',
    lede: 'Popis lokacija u demo bazi. Adrese i radna vremena su izmišljeni podaci za prikaz strukture stranice.',
    none: 'Nema poslovnica u odabranom gradu.',
    tbl: { city: 'Grad', address: 'Adresa', hours: 'Radno vrijeme', kind: 'Tip' },
    mapNote: 'Karta lokacija nije uključena jer bi zahtijevala vanjski servis karata. Koordinate se nalaze u bazi i mogu se prikazati dodavanjem kartografske biblioteke.'
  },

  /* ---------------- mobile app ---------------- */
  mobileApp: {
    title: 'Mobilna aplikacija',
    lede: 'Prikaz stranice za preuzimanje aplikacije. U ovom projektu nema stvarnih instalacijskih paketa — web aplikacija je responzivna i radi na mobilnim uređajima.',
    warn: 'Poveznice za preuzimanje su neaktivne. Nema APK datoteke ni objave u trgovinama aplikacija.',
    heroEyebrow: 'Web aplikacija',
    heroTitle: 'Otvori u pregledniku na mobitelu',
    heroText: 'Sučelje se prilagođava malim ekranima — donja navigacija, ladica sa sportovima i listić u punoj širini.',
    featuresTitle: 'Što bi aplikacija sadržavala',
    features: [
      ['Brzo slaganje listića', 'Odabir tečaja u dva dodira, uz pamćenje listića između sesija.'],
      ['Obavijesti o događajima', 'Podsjetnik prije početka događaja koji si dodao na listić.'],
      ['Praćenje uživo', 'Osvježavanje tečajeva i rezultata bez ponovnog učitavanja stranice.'],
      ['Casino u istoj aplikaciji', 'Katalog igara i demo runde uz isti račun.'],
      ['Svijetla i tamna tema', 'Tema prati odabir korisnika i sprema se lokalno.'],
      ['Alati odgovorne igre', 'Limiti i samoisključenje dostupni izravno iz postavki računa.']
    ],
    downloadTitle: 'Preuzimanje (neaktivno)',
    downloads: [['Android', 'APK paket'], ['iOS', 'App Store'], ['Casino app', 'zasebna aplikacija']],
    unavailable: 'nije dostupno',
    securityTitle: 'Napomena o sigurnosti instalacije',
    securityBody: 'Kad stvarne aplikacije nisu dostupne u službenim trgovinama, distribuiraju se kao instalacijske datoteke izravno sa stranice priređivača. To je čest vektor prijevare: lažne stranice nude izmijenjene pakete koji kradu pristupne podatke. Provjeri domenu prije preuzimanja i nikad ne instaliraj aplikaciju s poveznice iz poruke ili oglasa.'
  },

  /* ---------------- search ---------------- */
  search: {
    title: 'Rezultati pretrage',
    lede: 'Upit: {q} — {events} događaja, {games} igara.',
    prompt: 'Upiši pojam u tražilicu u zaglavlju.',
    events: 'Sportski događaji', games: 'Casino igre',
    noEvents: 'Nema pronađenih događaja.', noGames: 'Nema pronađenih igara.'
  },

  /* ---------------- auth ---------------- */
  auth: {
    loginTitle: 'Prijava',
    loginLede: 'Prijavi se na demo račun da bi mogao slagati listiće i igrati demo igre.',
    demoNote: 'Demo račun za brzo isprobavanje: korisničko ime {u}, lozinka {p} (dostupan nakon pokretanja skripte za sijanje podataka).',
    usernameOrEmail: 'Korisničko ime ili e-mail',
    password: 'Lozinka', confirmPassword: 'Ponovi lozinku',
    signIn: 'Prijavi se', signingIn: 'Prijavljujem…',
    noAccount: 'Nemaš račun?', openDemo: 'Otvori demo račun',
    haveAccount: 'Već imaš račun?',
    securityNote: 'Ovo je obrazovni projekt. Ne unosi stvarne lozinke koje koristiš drugdje — koristi izmišljene podatke.',
    alreadyIn: 'Već si prijavljen', alreadyInBody: 'Prijavljen si kao {name}.',

    registerTitle: 'Otvori demo račun',
    registerLede: 'Račun služi isključivo za isprobavanje ove demonstracije. Dobivaš 500 demo kredita koji nemaju nikakvu vrijednost.',
    registerWarn: 'Ne koristi stvarnu lozinku koju imaš na drugim stranicama. Unesi izmišljene podatke — ovo je vježba, a ne stvarna usluga.',
    username: 'Korisničko ime', usernameHint: '3–24 znaka.',
    email: 'E-mail', emailHint: 'Koristi izmišljenu adresu, npr. ime@primjer.local.',
    passwordHint: 'Najmanje 8 znakova.',
    ageConfirm: 'Potvrđujem da imam 18 ili više godina.',
    termsPre: 'Prihvaćam', termsLink: 'pravila',
    termsPost: 'i razumijem da je ovo demonstracijski projekt bez stvarnog novca.',
    creating: 'Otvaram račun…', createAccount: 'Otvori demo račun',
    accountExists: 'Račun je već otvoren',
    errShort: 'Lozinka mora imati barem 8 znakova.',
    errMatch: 'Lozinke se ne podudaraju.',
    errAge: 'Moraš potvrditi da imaš 18 ili više godina.',
    errTerms: 'Moraš prihvatiti pravila korištenja.',
    loggedInAs: 'Prijavljen kao {name}.',
    registered: 'Demo račun je otvoren. Dobio si 500 demo kredita.',
    loggedOut: 'Odjavljen.'
  },

  /* ---------------- assistant ---------------- */
  assistant: {
    title: 'PSK pomoćnik',
    subtitle: 'Navigacija i odgovori',
    welcome: 'Pitaj me bilo što o stranici — mogu te odvesti na igru ili stranicu, '
      + 'ili odgovoriti na pitanje o uplatama, isplatama i verifikaciji.',
    placeholder: 'Napiši pitanje...',
    send: 'Pošalji',
    yes: 'da',
    error: 'Trenutno se ne mogu povezati. Pokušaj ponovno za koji trenutak.',
    sources: 'Izvori ({n})',
    policyFlag: 'ovisi o službenim pravilima',
    disclaimer: 'Demo pomoćnik. Ne vidi stanje računa i ne daje financijske savjete.',
    s1: 'Otvori Aviator',
    s2: 'Kako radi Aviator?',
    s3: 'Moji listići',
    s4: 'Postavi limit'
  },

  /* ---------------- checkout ---------------- */
  checkout: {
    title: 'Potvrda listića',
    lede: 'Provjeri parove i iznos prije potvrde. Listić se šalje na poslužitelj koji ponovno čita tečajeve iz baze.',
    selections: 'Odabrani parovi',
    summary: 'Sažetak',
    stake: 'Uplata',
    pairs: 'Parova',
    totalOdds: 'Ukupni tečaj',
    gross: 'Bruto dobitak',
    deduction: 'Odbitak (10%)',
    potential: 'Mogući dobitak',
    balanceAfter: 'Stanje nakon uplate',
    confirm: 'Potvrdi uplatu',
    confirming: 'Potvrđujem…',
    back: 'Natrag na ponudu',
    emptyTitle: 'Listić je prazan',
    emptyBody: 'Dodaj barem jedan par iz ponude prije potvrde.',
    openOffer: 'Otvori ponudu',
    loginTitle: 'Prijava potrebna',
    loginBody: 'Za potvrdu listića prijavi se na demo račun.',
    social: 'Ovu kombinaciju je danas već odigralo {n} igrača.',
    socialLive: 'upravo sada gleda {n}',
    marketCol: 'Tržište',
    oddsCol: 'Tečaj',
    demoNote: 'Demo uplata — koriste se izmišljeni krediti, ne stvarni novac.',

    placedTitle: 'Listić je uplaćen',
    placedBody: 'Tvoj demo listić je zaprimljen i čeka obračun.',
    ref: 'Broj listića',
    myTickets: 'Moji listići',
    newBet: 'Nova oklada',
    placedAt: 'Vrijeme uplate',

    leaveTitle: 'Sigurno želiš odustati?',
    leaveBody: 'Ako sada napustiš potvrdu, ovaj listić neće biti uplaćen.',
    leaveProjected: 'Da si potvrdio, mogući dobitak bio bi',
    leaveStay: 'Ostani i potvrdi',
    leaveGo: 'Ipak odustani'
  },

  /* ---------------- account ---------------- */
  account: {
    title: 'Moj račun',
    needLogin: 'Za pristup računu potrebna je prijava.',
    openedOn: 'Demo račun otvoren {date}.',
    cards: {
      balance: 'stanje demo računa', tickets: 'uplaćenih listića',
      rounds: 'odigranih rundi', net: 'saldo casino rundi'
    },
    depositTitle: 'Dodaj demo kredite',
    depositBody: 'Krediti su izmišljeni i služe samo za isprobavanje. Nema stvarnih uplata, platnih kartica ni transakcija.',
    deposited: 'Dodano {amount} demo kredita.',
    limitsTitle: 'Limiti igre',
    limitDeposit: 'Dnevni limit uplate (€)',
    limitLoss: 'Dnevni limit gubitka (€)',
    limitSession: 'Trajanje sesije (min)',
    saveLimits: 'Spremi limite', limitsSaved: 'Limiti su spremljeni.',
    limitsNote: 'Limiti se u ovoj demonstraciji spremaju u bazu, ali se ne provode automatski — u stvarnom sustavu blokirali bi uplate i igru po dostizanju praga.',
    selfExclusionTitle: 'Samoisključenje',
    selfExclusionBody: 'Samoisključenje onemogućuje prijavu na račun do isteka odabranog razdoblja. U ovoj demonstraciji provodi se na razini API-ja.',
    selfExcludeConfirm: 'Samoisključenje na {n} dana onemogućuje prijavu do isteka roka. Nastaviti?',
    selfExcluded: 'Račun je samoisključen na {n} dana.',
    day: 'dan', days: 'dana',
    historyTitle: 'Zadnje casino runde',
    noRounds: 'Još nema odigranih rundi.',
    tbl: { game: 'Igra', time: 'Vrijeme', bet: 'Ulog', win: 'Dobitak' }
  },

  /* ---------------- tickets ---------------- */
  tickets: {
    title: 'Moji listići',
    lede: 'Uplaćeni demo listići. Obračun je simuliran — svaki par se razrješava nasumično, s vjerojatnošću izvedenom iz tečaja.',
    needLogin: 'Za pregled listića potrebna je prijava na demo račun.',
    filters: { all: 'Svi', open: 'U tijeku', won: 'Dobitni', lost: 'Gubitni' },
    statuses: { open: 'u tijeku', won: 'dobitan', lost: 'gubitan', void: 'poništen' },
    empty: 'Još nema listića.', emptyCta: 'Otvori ponudu', emptyTail: 'i složi svoj prvi.',
    stake: 'Uplata', totalOdds: 'Ukupni tečaj', deduction: 'Odbitak',
    paidOut: 'Isplaćeno', potential: 'Mogući dobitak',
    settle: 'Obračunaj', share: 'Podijeli u Arenu', unshare: 'Ukloni iz Arene',
    settledWon: 'Listić {ref} je dobitan — {amount}!',
    settledLost: 'Listić {ref} nije prošao.',
    shared: 'Listić je podijeljen u Areni.',
    unshared: 'Listić više nije javan.'
  },

  /* ---------------- help ---------------- */
  help: {
    title: 'Pomoć i česta pitanja',
    lede: 'Odgovori na najčešća pitanja o ovoj demonstraciji i o tome kako je izrađena.',
    faq: [
      ['Je li ovo stvarna kladionica?', 'Nije. Ovo je obrazovni projekt — MERN aplikacija napravljena da pokaže kako je strukturirana takva stranica. Nema uplata, isplata ni stvarnog klađenja, a svi podaci su generirani.'],
      ['Odakle dolaze događaji i tečajevi?', 'Iz lokalne MongoDB baze koju popunjava skripta za sijanje podataka. Generator koristi fiksno sjeme, pa je sadržaj identičan pri svakom ponovnom sijanju.'],
      ['Kako složiti listić?', 'Na stranici ponude klikni na tečaj koji te zanima. Par se dodaje na listić s desne strane. Unesi ulog i klikni "Uplati listić". Listić se šalje na poslužitelj koji ponovno provjerava tečajeve iz baze.'],
      ['Zašto se tečaj na listiću razlikuje od onog na koji sam kliknuo?', 'Poslužitelj uvijek čita aktualni tečaj iz baze umjesto da vjeruje podacima iz preglednika. To je isti princip koji koriste stvarni sustavi kako bi spriječili manipulaciju s klijentske strane.'],
      ['Kako se obračunavaju listići?', 'Klikom na "Obračunaj" na stranici Moji listići. Svaki par razrješava se nasumično s vjerojatnošću izvedenom iz tečaja. Ako su svi parovi pogođeni, dobitak se pripisuje demo računu.'],
      ['Kako rade casino igre?', 'Animacija se odvija u pregledniku, ali rezultat runde šalje se poslužitelju koji provjerava ulog i ažurira stanje računa. Time je stanje računa uvijek autoritativno na poslužitelju.'],
      ['Mogu li izgubiti stvarni novac?', 'Ne. Stanje računa su izmišljeni demo krediti bez ikakve vrijednosti. Ne postoji način uplate stvarnog novca.'],
      ['Kako dodati još demo kredita?', 'Na stranici Moj račun postoje gumbi za dodavanje kredita. To je simulacija, ne stvarna transakcija.'],
      ['Kako promijeniti jezik sučelja?', 'U podnožju stranice nalazi se izbornik jezika. Odabir se pamti u pregledniku i primjenjuje odmah, bez ponovnog učitavanja.'],
      ['Kako pokrenuti projekt lokalno?', 'Potreban je Node.js i MongoDB. U mapi server pokreni npm install, npm run seed i npm run dev; u mapi client pokreni npm install i npm run dev. Detalji su u datoteci README.md.'],
      ['Gdje se spremaju podaci?', 'Korisnici, listići i runde spremaju se u MongoDB. Tema, jezik, listić u izradi i token prijave čuvaju se lokalno u pregledniku.']
    ],
    moreTitle: 'Trebaš još pomoći?',
    tiles: {
      contact: 'Kontakt forma', contactSub: 'pošalji upit',
      rules: 'Pravila igre', rulesSub: 'kako se igra',
      responsible: 'Odgovorno igranje', responsibleSub: 'limiti i pomoć',
      about: 'O projektu', aboutSub: 'tehnički detalji'
    }
  },

  /* ---------------- about ---------------- */
  about: {
    title: 'O projektu',
    lede: 'Obrazovna MERN aplikacija koja rekonstruira informacijsku arhitekturu tipične stranice sportske kladionice i online casina.',
    warn: 'Ovo nije stvarna kladionica. Aplikacija nije povezana ni s jednim priređivačem igara na sreću, ne prima uplate i ne omogućuje klađenje stvarnim novcem.',
    goalTitle: 'Cilj',
    goalBody: 'Projekt je nastao kao vježba iz razvoja web aplikacija. Fokus je na tome kako se takva stranica slaže: kako se modeliraju sportovi, lige i događaji, kako se tečajevi prikazuju u mreži, kako listić prati odabire kroz cijelu aplikaciju te kako se katalog od nekoliko stotina igara filtrira i pretražuje bez usporavanja sučelja.',
    techTitle: 'Tehnologije',
    tech: [
      ['MongoDB', 'pohrana sportova, liga, događaja, igara, korisnika, listića i rundi.'],
      ['Express', 'REST API s rutama za ponudu, casino, listiće, korisnike i sadržaj.'],
      ['React', 'sučelje s klijentskim usmjeravanjem i dijeljenim stanjem kroz Context.'],
      ['Node.js', 'izvršno okruženje poslužitelja.'],
      ['Uz to', 'Mongoose, JSON Web Token, bcrypt, Helmet, Vite.']
    ],
    archTitle: 'Arhitektura',
    archBody: 'Aplikacija je podijeljena na dva dijela. Poslužitelj u mapi server izlaže API i jedini je autoritet nad stanjem računa: pri uplati listića ponovno čita tečajeve iz baze umjesto da vjeruje podacima iz preglednika, a casino runde provjerava prije nego što ažurira stanje. Klijent u mapi client renderira sučelje i pokreće animacije igara.',
    whyTitle: 'Zašto je to bitno',
    whyBody: 'U svakom sustavu gdje klijent može poslati rezultat, taj se rezultat mora provjeriti na poslužitelju. Ovdje je to izvedeno kroz ponovno čitanje tečajeva, provjeru raspona uloga i gornju granicu dobitka po rundi.',
    dataTitle: 'Podaci',
    dataBody: 'Sav sadržaj generira skripta za sijanje podataka koristeći generator slučajnih brojeva s fiksnim sjemenom. Nazivi igara složeni su od unaprijed zadanih riječi, a sličice igara crtaju se u CSS-u iz dvije boje i emoji simbola, pa aplikacija ne ovisi ni o kakvim vanjskim slikama.',
    missingTitle: 'Što nije implementirano',
    missing: [
      'Stvarna obrada plaćanja i provjera identiteta korisnika.',
      'Prijenos videa za stolove uživo — stolovi su simulirani.',
      'Automatsko provođenje limita igre; limiti se spremaju, ali se ne primjenjuju.',
      'Povezivanje sa stvarnim izvorima sportskih podataka i rezultata.'
    ],
    nameTitle: 'Napomena o nazivu',
    nameBody: 'Naziv i vizualni identitet u aplikaciji su izmišljeni i označeni kao demo kako bi bilo jasno da se ne radi o stvarnoj usluzi. Više o pravilima na stranicama'
  },

  /* ---------------- rules ---------------- */
  rules: {
    title: 'Pravila igre',
    lede: 'Kako u ovoj demonstraciji funkcioniraju listići, tečajevi, obračun i casino runde.',
    warn: 'Ova pravila opisuju ponašanje demonstracijske aplikacije. Nisu pravni dokument i ne predstavljaju uvjete nijedne stvarne usluge.',
    s1: '1. Opće odredbe',
    s1body: 'Aplikacija služi isključivo za prikaz i učenje. Račun je demo račun, a sredstva na njemu su izmišljeni krediti bez ikakve vrijednosti. Nije moguće uplatiti ni isplatiti stvarni novac.',
    s2: '2. Listić',
    s2list: [
      'Na jednom listiću može biti najviše trideset parova.',
      'Na jednom događaju može se odabrati najviše jedan par; novi odabir zamjenjuje prethodni.',
      'Minimalni ulog je 0,50 demo kredita.',
      'Ukupni tečaj je umnožak tečajeva svih parova na listiću.',
      'Tečajeve pri uplati poslužitelj ponovno čita iz baze; vrijedi tečaj iz baze, ne onaj prikazan u pregledniku.'
    ],
    s3: '3. Obračun dobitka',
    s3body1: 'Bruto dobitak je ulog pomnožen ukupnim tečajem. Od razlike između bruto dobitka i uloga odbija se 10 posto, što predstavlja ilustrativni odbitak. Rezultat je mogući neto dobitak.',
    s3body2: 'Listić se obračunava ručno, na zahtjev korisnika. Svaki par razrješava se nasumično, s vjerojatnošću izvedenom iz njegovog tečaja — što je tečaj viši, to je vjerojatnost pogotka manja. Listić je dobitan samo ako su svi parovi pogođeni.',
    s4: '4. Opća pravila bonusa',
    s4body: 'Promocije prikazane u aplikaciji su ilustrativne i ne mogu se aktivirati. Kod stvarnih ponuda uvjeti obično uključuju uvjet prometa, minimalni tečaj po paru, rok za ispunjenje te različit doprinos pojedinih igara prometu.',
    s5: '5. Casino igre',
    s5list: [
      'Ishod svake runde određuje generator slučajnih brojeva u pregledniku.',
      'Runda se šalje poslužitelju koji provjerava ulog i ažurira stanje računa.',
      'Ulog mora biti unutar raspona definiranog za pojedinu igru.',
      'Prethodne runde ne utječu na buduće — svaka je nezavisna.',
      'Navedeni RTP je teorijski postotak povrata na vrlo velikom broju rundi, a ne obećanje ishoda.'
    ],
    s6: '6. Brojčane igre',
    s6body: 'Dobitak ovisi o broju pogođenih brojeva prema fiksnoj tablici množitelja. Fond kola i broj dobitnika po razredu nisu modelirani.',
    s7: '7. Napomena o sukladnosti',
    s7body: 'Budući da aplikacija ne priređuje igre na sreću i ne obrađuje stvarna sredstva, ne podliježe propisima koji uređuju priređivanje igara na sreću. Prikazane oznake, iznosi i tekstovi postoje radi realističnog prikaza sučelja.',
    s8: '8. Odgovorna igra',
    s8body: 'I u demonstraciji vrijedi isto načelo kao u stvarnosti: igra je zabava, a ne način zarade. Više na stranici'
  },

  /* ---------------- responsible ---------------- */
  responsible: {
    title: 'Odgovorno igranje',
    lede: 'Igre na sreću mogu izazvati ovisnost. Ova stranica objašnjava alate ugrađene u aplikaciju i osnovna načela sigurne igre.',
    warn: 'Iako je ovo demonstracija bez stvarnog novca, načela navedena ovdje vrijede jednako za sve stvarne usluge.',
    principlesTitle: 'Osnovna načela',
    principles: [
      'Igra je oblik zabave s troškom, a ne način zarade ili rješavanja financijskih problema.',
      'Unaprijed odredi iznos koji si spreman potrošiti i drži ga se bez obzira na ishod.',
      'Nikada ne pokušavaj nadoknaditi gubitak povećanjem uloga — to je najčešći put u ozbiljne probleme.',
      'Ne igraj pod utjecajem alkohola, u lošem raspoloženju ili kad si umoran.',
      'Prati vrijeme provedeno u igri jednako pažljivo kao i potrošeni iznos.'
    ],
    limitsTitle: 'Limiti igre',
    limitsLead: 'Na stranici Moj račun mogu se postaviti tri vrste limita:',
    limits: [
      ['Dnevni limit uplate', 'najveći iznos koji se u jednom danu može dodati na račun.'],
      ['Dnevni limit gubitka', 'prag neto gubitka nakon kojeg igra prestaje.'],
      ['Trajanje sesije', 'vrijeme nakon kojeg sustav prekida sesiju.']
    ],
    limitsNote: 'U ovoj demonstraciji limiti se spremaju u bazu, ali se ne provode automatski. U stvarnom sustavu blokirali bi uplate i igru čim se prag dosegne, a povećanje limita obično stupa na snagu tek nakon razdoblja čekanja.',
    exclusionTitle: 'Samoisključenje',
    exclusionBody: 'Samoisključenje onemogućuje prijavu na račun do isteka odabranog razdoblja. U aplikaciji se provodi na razini API-ja — pokušaj prijave tijekom razdoblja isključenja vraća grešku. Razdoblje se ne može skratiti nakon aktivacije.',
    exclusionCta: 'Otvori postavke samoisključenja',
    exclusionLogin: 'Prijavi se za pristup postavkama',
    signsTitle: 'Znakovi upozorenja',
    signsLead: 'Vrijedi zastati i preispitati navike ako prepoznaš nešto od sljedećeg:',
    signs: [
      'Igraš dulje ili za veće iznose nego što si planirao.',
      'Posuđuješ novac ili prodaješ stvari da bi nastavio igrati.',
      'Skrivaš koliko igraš od bliskih osoba.',
      'Igra utječe na posao, školu, san ili odnose.',
      'Osjećaš nemir ili razdražljivost kad ne igraš.'
    ],
    helpTitle: 'Gdje potražiti pomoć',
    helpBody1: 'Ako prepoznaješ ove znakove kod sebe ili bliske osobe, razgovor s liječnikom obiteljske medicine dobra je prva točka — može uputiti na odgovarajuću stručnu podršku. U mnogim zemljama postoje i besplatne savjetodavne linije te udruge specijalizirane za ovisnost o kockanju, uključujući grupe podrške za članove obitelji.',
    helpBody2: 'Ako si u akutnoj krizi ili razmišljaš o samoozljeđivanju, obrati se hitnoj službi odmah — u Hrvatskoj i ostatku Europske unije to je broj 112.',
    minorsTitle: 'Zaštita maloljetnika',
    minorsBody: 'Igre na sreću dostupne su isključivo punoljetnim osobama. Ako dijeliš uređaj s djecom, koristi zaključavanje profila i alate za roditeljski nadzor te ne spremaj pristupne podatke u pregledniku.'
  },

  /* ---------------- privacy ---------------- */
  privacy: {
    title: 'Pravila o privatnosti',
    lede: 'Što ova demonstracijska aplikacija sprema, gdje to sprema i kako se podaci mogu ukloniti.',
    warn: 'Ovo nije pravni dokument nego tehnički opis ponašanja demo aplikacije. Ne koristi stvarne osobne podatke pri isprobavanju.',
    storedTitle: 'Koje podatke aplikacija sprema',
    storedLead: 'Pri otvaranju demo računa u bazu se spremaju:',
    stored: [
      'korisničko ime i e-mail adresa koje sam unosiš,',
      'lozinka u obliku kriptografskog sažetka (bcrypt), nikad u čitljivom obliku,',
      'stanje demo kredita i postavljeni limiti igre,',
      'uplaćeni listići i odigrane casino runde.'
    ],
    storedTail: 'Aplikacija ne traži ni ne obrađuje podatke o identitetu, adresi, dokumentima ni bilo kakve platne podatke, jer nema stvarnih uplata.',
    browserTitle: 'Pohrana u pregledniku',
    browserLead: 'Aplikacija ne koristi kolačiće za praćenje. U lokalnoj pohrani preglednika (localStorage) čuvaju se samo:',
    browser: [
      'token prijave, kako bi sesija preživjela osvježavanje stranice,',
      'odabrana tema (svijetla ili tamna) i jezik sučelja,',
      'listić u izradi i zadnji uneseni ulog.'
    ],
    browserTail: 'Ti podaci ostaju na tvom uređaju i mogu se ukloniti brisanjem podataka stranice u postavkama preglednika.',
    thirdTitle: 'Analitika i treće strane',
    thirdBody: 'Nema analitike, oglašivačkih skripti ni ugrađenih sadržaja trećih strana. Aplikacija ne šalje podatke nikamo osim vlastitom API poslužitelju koji radi lokalno.',
    accessTitle: 'Pristup i brisanje podataka',
    accessBody: 'Budući da poslužitelj radi lokalno, svi podaci nalaze se u tvojoj MongoDB bazi. Cijeli skup podataka može se ukloniti brisanjem baze ili ponovnim pokretanjem skripte za sijanje s odgovarajućom zastavicom.',
    securityTitle: 'Sigurnost',
    security: [
      'Lozinke se spremaju kao bcrypt sažetci.',
      'Autentikacija koristi JSON Web Token s rokom valjanosti od sedam dana.',
      'Poslužitelj koristi zaštitna zaglavlja i ograničenje broja zahtjeva.',
      'Stanje računa mijenja isključivo poslužitelj, nikad klijent izravno.'
    ],
    securityTail: 'Za produkcijsku upotrebu bilo bi potrebno dodati HTTPS, rotaciju tajni, evidenciju pristupa i pohranu tokena otpornu na krađu skriptom — što ovdje nije implementirano jer je riječ o lokalnoj vježbi.',
    contactTitle: 'Kontakt',
    contactBody: 'Pitanja o projektu možeš poslati putem'
  },

  /* ---------------- contact ---------------- */
  contact: {
    title: 'Kontakt',
    lede: 'Forma za upite o projektu. Prikazana je radi potpunosti sučelja.',
    warn: 'Ova forma ništa ne šalje i ne sprema. Ne unosi stvarne osobne podatke.',
    topics: ['Općenito', 'Tehnički problem', 'Prijedlog', 'Pitanje o projektu'],
    name: 'Ime', email: 'E-mail', emailHint: 'Koristi izmišljenu adresu.',
    topic: 'Tema', message: 'Poruka',
    submit: 'Pošalji (simulacija)',
    toast: 'Forma je demonstracijska — poruka nije poslana.',
    sentTitle: 'Forma je poslana (simulacija)',
    sentBody: 'U stvarnoj aplikaciji ovdje bi se poruka spremila i proslijedila timu podrške. U ovoj demonstraciji nije poslana nikamo.',
    newMessage: 'Nova poruka',
    otherTitle: 'Druge stranice',
    tiles: { faq: 'Česta pitanja', faqSub: 'brzi odgovori', shops: 'Poslovnice', shopsSub: 'popis lokacija', about: 'O projektu', aboutSub: 'tehnički detalji' }
  },

  /* ---------------- champions club ---------------- */
  club: {
    title: 'Klub prvaka',
    lede: 'Prikaz programa vjernosti s razinama i bodovima. Bodovi u ovoj demonstraciji izvedeni su iz stanja demo računa i nemaju nikakvu vrijednost.',
    yourTier: 'Tvoja razina', points: 'Sakupljeni bodovi',
    toNext: 'Do razine {tier}', pointsShort: '{n} bodova',
    maxTier: 'Najviša razina',
    loginPrompt: 'Prijavi se da bi vidio svoju razinu.',
    tiersTitle: 'Razine i pogodnosti', fromPoints: 'od {n} bodova',
    tiers: [
      { name: 'Bronca',  perks: ['Pristup tjednim akcijama', 'Osnovna podrška'] },
      { name: 'Srebro',  perks: ['Brža podrška', 'Mjesečni turnir', 'Dodatni okreti'] },
      { name: 'Zlato',   perks: ['Prioritetna podrška', 'Viši limiti', 'Poseban voditelj računa'] },
      { name: 'Platina', perks: ['Sve iz Zlata', 'Pozivnice na događaje', 'Individualne ponude'] }
    ],
    howTitle: 'Kako se skupljaju bodovi',
    howBody: 'U stvarnim programima vjernosti bodovi se obično dodjeljuju razmjerno prometu, uz različit koeficijent za pojedine proizvode. Razine se preispituju periodično, pa neaktivnost može značiti pad na nižu razinu.',
    watchTitle: 'Na što paziti',
    watchBody: 'Programi vjernosti su marketinški alat osmišljen da potakne češću igru. Pogodnosti nikada ne bi trebale biti razlog za igranje više nego što si planirao. Više o postavljanju granica na stranici'
  },

  /* ---------------- 404 ---------------- */
  notFound: {
    title: 'Stranica nije pronađena',
    lede: 'Ruta koju si otvorio ne postoji u ovoj aplikaciji.'
  },

  /* ---------------- enumerable data from the API ---------------- */
  data: {
    sports: {
      nogomet: 'Nogomet', kosarka: 'Košarka', tenis: 'Tenis', rukomet: 'Rukomet',
      odbojka: 'Odbojka', hokej: 'Hokej na ledu', 'stolni-tenis': 'Stolni tenis',
      esport: 'E-sport', boks: 'Boks', mma: 'MMA / UFC', 'formula-1': 'Formula 1',
      'moto-gp': 'Moto GP', pikado: 'Pikado', snooker: 'Snooker', golf: 'Golf',
      biciklizam: 'Biciklizam', ragbi: 'Ragbi', 'am-nogomet': 'Američki nogomet',
      bejzbol: 'Bejzbol', vaterpolo: 'Vaterpolo', atletika: 'Atletika',
      skijanje: 'Skijanje', 'ski-skokovi': 'Ski skokovi', biatlon: 'Biatlon',
      sah: 'Šah', futsal: 'Futsal', badminton: 'Badminton', kuglanje: 'Kuglanje',
      'konjicke-utrke': 'Konjičke utrke', zabava: 'Svijet zabave'
    },
    categories: {
      lobby: 'Lobby', favourites: 'Favoriti', new: 'Nove igre', popular: 'Popularno',
      jackpot: 'Jackpoti', exclusive: 'Samo kod nas', 'game-shows': 'Game Shows',
      'buy-bonus': 'Buy Bonus', drops: 'Drops & Wins', 'small-bets': 'Mali ulozi',
      'big-wins': 'Veliki dobici', instant: 'Instant igre', table: 'Igre na stolovima',
      roulette: 'Rulet', classic: 'Klasični slotovi', megaways: 'Megaways', all: 'Sve igre'
    },
    volatility: { Niska: 'Niska', Srednja: 'Srednja', Visoka: 'Visoka' },
    marketLabels: {
      '1': 'Konačni ishod 1', 'X': 'Konačni ishod X', '2': 'Konačni ishod 2',
      '1X': 'Dvostruka šansa 1X', 'X2': 'Dvostruka šansa X2', '12': 'Dvostruka šansa 12',
      'GG': 'Oba tima daju gol', 'H1': 'Hendikep 1', 'H2': 'Hendikep 2',
      'U': 'Manje golova/poena', 'O': 'Više golova/poena', 'TM': 'Ukupno', 'Tečaj': 'Pobjednik'
    },
    marketGroups: {
      'Konačni ishod': 'Konačni ishod',
      'Ukupno golova / poena': 'Ukupno golova / poena',
      'Poluvrijeme': 'Poluvrijeme',
      'Hendikep': 'Hendikep',
      'Kombinacije': 'Kombinacije'
    }
  }
};
