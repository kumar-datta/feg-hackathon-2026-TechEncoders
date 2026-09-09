/* English strings — mirrors the shape of hr.js exactly. */
export default {
  /* ---------------- generic ---------------- */
  common: {
    play: 'Play', details: 'Details', close: 'Close', ok: 'OK',
    back: 'Back', save: 'Save', send: 'Send', cancel: 'Cancel',
    search: 'Search', filter: 'Filter', all: 'All', more: 'More',
    seeAll: 'See all', open: 'Open', loading: 'Loading…',
    error: 'Error', retry: 'Try again', noData: 'Nothing to show.',
    prev: 'Previous', next: 'Next', page: 'Page',
    home: 'Home', yes: 'Yes', no: 'No', note: 'Note',
    provider: 'Provider', balance: 'Balance', stake: 'Stake',
    lastWin: 'Last win', games: 'games', events: 'events',
    status: 'Status', date: 'Date', time: 'Time', amount: 'Amount'
  },

  demoBar: 'DEMO / LEARNING — an independent MERN exercise. Not connected to any real operator; no real money and no real betting.',

  /* ---------------- navigation ---------------- */
  nav: {
    sport: 'Sport', live: 'Live', casino: 'Casino', liveCasino: 'Live Casino',
    loto: 'Lottery', virtuals: 'Virtual games', forum: 'Forum', arena: 'Arena',
    promo: 'Promos', swipe: 'Swipe & Bet',
    home: 'Home', mobileApp: 'Mobile app', results: 'Results',
    statistics: 'Statistics', news: 'News', club: 'Champions Club',
    help: 'Help', shops: 'Shops', tickets: 'Tickets'
  },

  header: {
    menu: 'Menu', searchPlaceholder: 'Search events and games...',
    searchLabel: 'Search', theme: 'Light / dark theme',
    themeDark: 'Dark', themeLight: 'Light', help: 'Help',
    login: 'Log in', register: 'Sign up', account: 'My account',
    logout: 'Log out', deposit: 'Add demo credits'
  },

  /* ---------------- footer ---------------- */
  footer: {
    offer: 'Products', aboutUs: 'About', rules: 'Rules', support: 'Support',
    app: 'App', language: 'Language',
    sportsbook: 'Sportsbook', liveBetting: 'Live betting',
    promotions: 'Promotions', aboutProject: 'About the project', contact: 'Contact',
    gameRules: 'Game rules', bonusRules: 'General bonus terms',
    privacy: 'Privacy policy', cookies: 'Cookie policy',
    dataProtection: 'Data protection',
    faq: 'Help and FAQ', contactForm: 'Contact form',
    responsible: 'Responsible gaming', selfExclusion: 'Self-exclusion',
    limits: 'Play limits',
    androidApp: 'Android app', iosApp: 'iOS app', casinoApp: 'Casino app',
    social: 'Social media (display only)',
    payments: 'Payment methods (display only)',
    ageWarning: 'Gambling can be addictive. Play responsibly and set limits. Read more on the',
    disclaimerLead: 'This is a demonstration project.',
    disclaimer: 'A self-built MERN application (MongoDB, Express, React, Node) made for learning. It is not connected to any real gambling operator, accepts no payments, offers no real betting and represents no company. Every event, odd, game and amount is generated data, and account balances are fictional demo credits.',
    copyright: 'educational project.'
  },

  /* ---------------- bet slip ---------------- */
  slip: {
    title: 'Bet slip', myTickets: 'My tickets',
    empty: 'Your slip is empty.', emptyHint: 'Pick an odd from the offer.',
    remove: 'Remove', stake: 'Stake', pairs: 'Selections',
    totalOdds: 'Total odds', gross: 'Gross return',
    deduction: 'Deduction (10%)', potential: 'Potential return',
    place: 'Place bet', placing: 'Placing…', clear: 'Clear slip',
    loginTitle: 'Login required',
    loginBody: 'You need to log in to a demo account to place a bet.',
    loginNote: 'The demo account uses fictional credits, not real money.',
    placedTitle: 'Bet placed',
    placedBody: 'Demo ticket {ref} has been accepted.',
    placedToast: 'Ticket {ref} placed (demo).',
    code: 'code'
  },

  /* ---------------- sportsbook ---------------- */
  sportsbook: {
    sports: 'Sports', filterSports: 'Filter sports...',
    noSports: 'No sports match that filter.',
    offer: 'Offer', event: 'Event',
    allMarkets: 'All markets', noEvents: 'No events match the selected filters.',
    eventsCount: '{n} events',
    filters: { all: 'All', live: 'Live', today: 'Today', soon: 'Next 3h' },
    addedToSlip: 'Market {key} added to your slip.',
    liveShort: 'LIVE'
  },

  /* ---------------- casino ---------------- */
  casino: {
    title: 'Casino',
    lede: 'A demo game catalogue with categories, providers and search. Every round is settled on the server against your demo balance — no real money is involved.',
    searchPlaceholder: 'Find your game...',
    searchLabel: 'Game search',
    providers: 'Providers', allProviders: 'All providers ({n})',
    noGames: 'No games match the selected filters.',
    gamesCount: '{n} games',
    jackpotTiers: ['Mega', 'Major', 'Minor', 'Mini'],
    new: 'NEW', exclusive: 'EXCLUSIVE', jackpot: 'JACKPOT', live: 'LIVE',
    previewTag: 'DEMO',
    info: {
      type: 'Game type', rtp: 'RTP', volatility: 'Volatility', lines: 'Paylines',
      betRange: 'Bet range', jackpot: 'Jackpot', none: 'none',
      note: 'This game is a demonstration simulation. The server settles each round against your demo balance — no real money is involved.'
    }
  },

  liveCasino: {
    title: 'Live Casino',
    lede: 'Simulated live tables. Each table runs the matching demo engine — roulette, blackjack, baccarat, money wheel or dice.',
    tabs: { all: 'All tables', roulette: 'Roulette', table: 'Card games', shows: 'Game shows' },
    noTables: 'No tables in this category.',
    howTitle: 'How live tables work',
    howBody: 'In real systems, live casino tables stream video from a studio and the client receives table state over a persistent connection (a WebSocket or similar channel). In this demonstration that layer is replaced by a local simulation: player counts come from the database, while the round result is generated by the client and confirmed by the server.'
  },

  providers: {
    title: 'Providers',
    lede: 'Studios represented in the demo catalogue. Selecting a provider filters the game catalogue.',
    searchPlaceholder: 'Search providers...',
    searchLabel: 'Provider search'
  },

  /* ---------------- games ---------------- */
  game: {
    loginRequired: 'Log in to a demo account to play.',
    betPositive: 'The stake must be greater than zero.',
    insufficient: 'Not enough demo credits.',

    slot: {
      spin: 'SPIN', spinning: 'SPINNING…', rolling: 'Spinning...',
      rules: '5 paylines · 3 in a row = 4×, 4 = 12×, 5 = 45× the line stake',
      win: 'You won {amount}!', noWin: 'No winning combination. Try again.',
      footer: 'RTP {rtp}% · Volatility: {vol} · {provider}'
    },

    roulette: {
      spin: 'SPIN', spinning: 'SPINNING…',
      prompt: 'Choose one or more bets, then spin.',
      selected: 'Bets selected: {n}',
      pickFirst: 'Choose a bet first.',
      rolling: 'The ball is rolling…',
      win: 'Number {n} ({color}) — you won {amount}',
      lose: 'Number {n} ({color}) — no win.',
      colors: { red: 'red', black: 'black', green: 'green' },
      bets: {
        red: 'RED', black: 'BLACK', odd: 'ODD', even: 'EVEN',
        low: '1-18', high: '19-36',
        d1: '1st dozen', d2: '2nd dozen', d3: '3rd dozen', zero: 'ZERO (0)'
      },
      footer: 'European roulette, single zero · RTP 97.30% · the stake applies to each selected bet · {provider}'
    },

    blackjack: {
      dealer: 'Dealer', player: 'Player',
      deal: 'Deal', hit: 'Hit', stand: 'Stand',
      prompt: 'Set your stake and deal.', yourTurn: 'Your move.',
      blackjack: 'Blackjack!', bust: 'Bust ({v}).',
      dealerBust: 'Dealer busts ({d}).',
      win: 'You win {p}:{d}.', push: 'Push {p}:{d} — stake returned.',
      lose: 'Dealer wins {d}:{p}.',
      footer: 'Blackjack pays 3:2 · dealer draws to 17 · {provider}'
    },

    crash: {
      start: 'Start', cash: 'Cash out',
      prompt: 'Set a stake, start the round and cash out before it crashes.',
      running: 'Round in progress…',
      bust: 'Crashed at {mult}× — stake lost.',
      cashed: 'Cashed out at {mult}× — {amount}',
      footer: 'RTP 97% · maximum multiplier 100× · {provider}'
    },

    mines: {
      start: 'New round', cash: 'Cash out',
      prompt: 'Start a round and reveal tiles.',
      playing: 'Reveal tiles and cash out before hitting a mine.',
      safe: 'Safe tiles: {n} · multiplier {mult}×',
      boom: 'Mine! The round is over.',
      needOne: 'Reveal at least one tile.',
      cashed: 'Cashed out at {mult}× — {amount}',
      footer: '25 tiles, 3 mines · the multiplier grows with every safe tile · {provider}'
    },

    dice: {
      roll: 'Roll', prompt: 'Choose a bet and roll the dice.',
      under: 'Under (2-6)', seven: 'Exactly 7', over: 'Over (8-12)',
      win: 'Total {sum} — you won {amount}', lose: 'Total {sum} — no win.',
      footer: 'Two dice · "Exactly 7" pays 5× · {provider}'
    },

    wheel: {
      spin: 'SPIN', prompt: 'Choose a segment and spin the wheel.',
      rolling: 'The wheel is spinning…',
      win: 'It landed on {v}× — you won {amount}',
      lose: 'It landed on {v}×, you picked {sel}×.',
      footer: 'Money wheel, 20 segments · {provider}'
    },

    baccarat: {
      deal: 'Deal', prompt: 'Choose a side and deal.',
      player: 'Player', bank: 'Banker', tie: 'Tie',
      betPlayer: 'Player (2×)', betBank: 'Banker (1.95×)', betTie: 'Tie (9×)',
      win: '{side} {p}:{b} — you won {amount}',
      lose: '{side} {p}:{b} — no win.',
      footer: 'Punto Banco rules (simplified) · {provider}'
    }
  },

  /* ---------------- home ---------------- */
  home: {
    slides: [
      {
        eyebrow: 'Sportsbook',
        title: 'Over 30 sports and 150 leagues in one offer',
        text: 'Prematch and live betting, a full market board, systems and combinations.',
        primary: 'Open the offer', secondary: 'Live betting'
      },
      {
        eyebrow: 'Casino',
        title: 'More than 400 games and daily jackpots',
        text: 'Slots, table games, instant games and game shows.',
        primary: 'Enter the casino', secondary: 'Live Casino'
      },
      {
        eyebrow: 'Lottery and virtual games',
        title: 'Draws every day, rounds every few minutes',
        text: 'Lotto 7/39, Euro Jackpot, keno and bingo alongside virtual sport 24/7.',
        primary: 'Lottery offer', secondary: 'Virtual games'
      }
    ],
    quickAccess: 'Quick access',
    quick: {
      sport: 'Sport', live: 'Live', casino: 'Casino', liveCasino: 'Live Casino',
      loto: 'Lottery', virtuals: 'Virtual', swipe: 'Swipe & Bet', promo: 'Promos'
    },
    quickOpen: 'open',
    liveCasinoSub: 'live tables', lotoSub: '6 games', virtualsSub: '24/7 rounds',
    swipeSub: 'quick slip', promoSub: 'offers',
    topOffer: 'Featured from the offer', wholeOffer: 'Full offer',
    liveNow: 'Live now', allLive: 'All live',
    promos: 'Current promotions', allPromos: 'All promotions',
    news: 'News and analysis', allNews: 'All news',
    addedToSlip: 'Added to your slip.', removedFromSlip: 'Removed from your slip.',
    aboutTitle: 'About this project',
    aboutBody: 'This is a self-built MERN application (MongoDB, Express, React, Node) that demonstrates how a typical sportsbook and online casino site is structured: product navigation, a sports tree, an odds grid, a bet slip, a filterable game catalogue and the supporting information pages.',
    implementedTitle: 'What is implemented',
    implemented: [
      'An Express REST API with Mongoose models for sports, leagues, events, games, users and tickets.',
      'Login and registration with JWT tokens and a demo account balance.',
      'A bet slip validated on the server — odds are read from the database, never from the client.',
      'A casino catalogue with categories, providers, search and jackpot display.',
      'Eight playable demo games; every round is settled by the server.',
      'Light and dark themes, a multilingual interface and a responsive layout.'
    ],
    noteTitle: 'Note',
    noteBody: 'The application accepts no payments, offers no real betting and is not connected to any gambling operator. Every event, odd, game title and amount is generated data, and account balances are fictional demo credits.'
  },

  /* ---------------- lottery ---------------- */
  loto: {
    title: 'Lottery and number games',
    lede: 'Number games with different ranges. Pick your numbers by hand or at random, run the draw and see how many you matched.',
    pickRange: 'Pick {pick} of {max}', drawing: 'Draw: {info}',
    buyTicket: 'Buy a ticket',
    ticketPrompt: 'Choose {pick} numbers from {max}.',
    randomPick: 'Random', draw: 'Draw', drawingNow: 'Drawing…',
    pickExactly: 'Pick exactly {pick} numbers.',
    hits: 'Matches: {n} — you won {amount}',
    noHits: 'Matches: {n} — no win.',
    ticketFooter: 'Displayed jackpot: {jackpot} · price per line {price}. In this demonstration the win is based purely on the number of matches (3 → 2×, 4 → 8×, 5 → 40×, 6 → 400×, 7 → 5000×).',
    lastDraws: 'Recent draws',
    tbl: { game: 'Game', round: 'Round', date: 'Date', numbers: 'Drawn numbers', fund: 'Prize fund' },
    howTitle: 'How the win is calculated',
    howBody: 'In this demonstration the win depends solely on the number of matches, using a fixed multiplier table. Real systems use the round prize fund and the number of winners per tier, which is not modelled here.',
    responsibleTitle: 'Responsible play',
    responsibleBody: 'Number games are pure chance — no combination is more likely than another, and previous draws have no effect on the next one. Read more about setting limits on the',
  },

  /* ---------------- virtuals ---------------- */
  virtuals: {
    title: 'Virtual games',
    lede: 'Simulated competitions that run continuously. Pick a winner, start the round and watch the race play out in your browser.',
    start: 'Start', newRoundEvery: 'new round every {interval}',
    schedule: 'Upcoming rounds',
    tbl: { game: 'Game', next: 'Next round', interval: 'Interval', runners: 'Runners', status: 'Status' },
    open: 'open',
    racePrompt: 'Pick a winner and start the round.',
    running: 'Round in progress…',
    startRound: 'Start round',
    winner: 'Winner: {name} — you won {amount}',
    loser: 'Winner: {name} — no win.',
    colours: ['Red', 'Blue', 'Green', 'Yellow', 'White', 'Black', 'Grey', 'Purple', 'Orange', 'Brown', 'Silver', 'Gold'],
    whatTitle: 'What virtual games are',
    whatBody: 'Virtual games are simulations of sporting events whose outcome is decided by a random number generator. No real competition is being tracked — each round is independent, and the previous result has no bearing on the next.',
    howTitle: 'How this is implemented',
    howBody: 'Each game generates a field of runners with odds, then runs an animated simulation in which every runner advances by a random step. The winner is whoever advances furthest, and the round is settled on the server like every other demo game.'
  },

  /* ---------------- swipe ---------------- */
  swipe: {
    title: 'Swipe & Bet',
    lede: 'A fast way to build a slip: accept or reject the suggested selection. Accepted selections go straight onto the shared slip. Arrow keys work too.',
    done: 'You have been through every suggestion.', openOffer: 'Open the offer',
    reject: 'Reject', skip: 'Skip', accept: 'Add to slip',
    onSlip: 'On your slip: {n} selections',
    suggestion: 'suggestion {i} / {total}',
    openInOffer: 'Open the slip in the offer',
    added: 'Added to your slip: {name}',
    howTitle: 'How it works',
    howBody: 'Each card shows one event and one suggested market with its odds. Accepting adds the selection to the slip shared by every page of the app, so you can finish it in the offer. Rejecting or skipping moves on to the next suggestion.'
  },

  /* ---------------- arena ---------------- */
  arena: {
    title: 'Arena',
    lede: 'A space where players share their tickets. A ticket becomes visible here once you share it from the',
    tabs: { tickets: 'Shared tickets', inspiration: 'Get inspired' },
    empty: 'No shared tickets yet. Place a ticket and share it to see it appear here.',
    statuses: { won: 'won', lost: 'lost', open: 'in play' },
    copy: 'Copy to my slip',
    copied: 'Copied {n} selections to your slip.',
    copyFailed: 'None of those selections are still in the offer.',
    player: 'player',
    howTitle: 'How to use other people’s tickets',
    howLead: 'The Arena shows other players’ combinations as a source of ideas, not as a recommendation. Three things worth checking before copying:',
    howPoints: [
      ['Sample size', 'a hit rate over twenty tickets tells you very little; it only becomes informative after a few hundred.'],
      ['Odds range', 'a high hit rate on low odds does not mean profitability.'],
      ['Timing', 'odds move, so a copied selection may be worth something different than when it was placed.']
    ],
    noteTitle: 'Note',
    noteBody: 'Arena tickets come from this application’s demo database. They do not represent real players or real results.'
  },

  /* ---------------- promotions ---------------- */
  promos: {
    title: 'Promotions',
    lede: 'A display of the kinds of offers bookmakers typically run. Every description is illustrative — the demo has no real bonuses or wagering requirements.',
    modalNote: 'This is a demonstration display. The offer cannot be activated because the application does not process real payments — only demo credits are used.',
    termsTitle: 'Illustrative terms',
    terms: { turnover: 'Wagering requirement', minOdds: 'Minimum odds', deadline: 'Deadline', minDeposit: 'Minimum deposit', days: 'days' },
    readTitle: 'How to read bonus terms',
    readLead: 'With real offers there are always four things to check:',
    readPoints: [
      ['Wagering requirement', 'how many times the bonus must be played through before it can be withdrawn.'],
      ['Minimum odds', 'selections below a given price often do not count towards the requirement.'],
      ['Deadline', 'the period within which the requirement must be met.'],
      ['Game contribution', 'different games contribute to the requirement at different rates.']
    ],
    readTail: 'The detailed terms are on the'
  },

  /* ---------------- forum ---------------- */
  forum: {
    title: 'Forum',
    lede: 'Community discussion about the offer, strategy and games. The content is demonstrative and pre-generated — there are no real users.',
    noThreads: 'No threads in this category.',
    replies: '{n} replies', views: '{n} views',
    repliesTitle: 'Replies',
    postDisabled: 'Posting replies is not enabled in this demonstration — the forum exists to show the page structure.',
    backToForum: 'Back to the forum',
    rulesTitle: 'Community rules',
    rules: [
      'Discussion of the offer and of strategy is welcome; advice is never a guarantee of outcome.',
      'Do not share anyone else’s personal data or account credentials.',
      'Gambling is entertainment, not income — set limits before you need them.'
    ]
  },

  /* ---------------- results / stats ---------------- */
  results: {
    title: 'Results',
    lede: 'Events that have started or finished. The results are generated demonstration data.',
    none: 'No results to show.',
    tbl: { sport: 'Sport', competition: 'Competition', event: 'Event', time: 'Time', result: 'Result' }
  },

  stats: {
    title: 'Offer statistics',
    lede: 'An overview of what is currently in the database: how many events and games there are, and how they break down by sport and provider.',
    cards: {
      events: 'events in the offer', live: 'events live',
      games: 'games in the catalogue', jackpot: 'total displayed jackpots'
    },
    bySport: 'Events by sport',
    byProvider: 'Games by provider (top 20)',
    tbl: { sport: 'Sport', share: 'Share', live: 'Live', total: 'Total', provider: 'Provider', games: 'Games' },
    noteTitle: 'A note on the data',
    noteBody: 'All figures come from the local MongoDB database populated by the seed script. The data is produced by a deterministic random number generator, so every reseed is identical.'
  },

  /* ---------------- news ---------------- */
  news: {
    title: 'News and analysis',
    lede: 'Articles about the offer, sporting previews and guides. The content is demonstrative.',
    none: 'No articles in this category.',
    articleNote: 'This text is generated demonstration content and does not represent real journalism.',
    allNews: 'All news'
  },

  /* ---------------- shops ---------------- */
  shops: {
    title: 'Shops',
    lede: 'A list of locations in the demo database. Addresses and opening hours are invented data used to show the page structure.',
    none: 'No shops in the selected city.',
    tbl: { city: 'City', address: 'Address', hours: 'Opening hours', kind: 'Type' },
    mapNote: 'A location map is not included because it would require an external mapping service. Coordinates are stored in the database and can be displayed by adding a mapping library.'
  },

  /* ---------------- mobile app ---------------- */
  mobileApp: {
    title: 'Mobile app',
    lede: 'A display of an app download page. This project ships no real installers — the web app is responsive and works on mobile devices.',
    warn: 'The download links are inactive. There is no APK file and no app store listing.',
    heroEyebrow: 'Web app',
    heroTitle: 'Open it in your phone’s browser',
    heroText: 'The interface adapts to small screens — bottom navigation, a sports drawer and a full-width bet slip.',
    featuresTitle: 'What the app would include',
    features: [
      ['Fast slip building', 'Pick an odd in two taps, with the slip remembered between sessions.'],
      ['Event notifications', 'A reminder before an event you added to your slip kicks off.'],
      ['Live tracking', 'Odds and scores refresh without reloading the page.'],
      ['Casino in the same app', 'The game catalogue and demo rounds on the same account.'],
      ['Light and dark themes', 'The theme follows your choice and is stored locally.'],
      ['Responsible gaming tools', 'Limits and self-exclusion available straight from account settings.']
    ],
    downloadTitle: 'Download (inactive)',
    downloads: [['Android', 'APK package'], ['iOS', 'App Store'], ['Casino app', 'separate app']],
    unavailable: 'not available',
    securityTitle: 'A note on installation safety',
    securityBody: 'When real apps are not available in official stores, they are distributed as installer files straight from the operator’s site. That is a common fraud vector: fake sites offer modified packages that steal credentials. Check the domain before downloading, and never install an app from a link in a message or advert.'
  },

  /* ---------------- search ---------------- */
  search: {
    title: 'Search results',
    lede: 'Query: {q} — {events} events, {games} games.',
    prompt: 'Type a term into the search box in the header.',
    events: 'Sporting events', games: 'Casino games',
    noEvents: 'No events found.', noGames: 'No games found.'
  },

  /* ---------------- auth ---------------- */
  auth: {
    loginTitle: 'Log in',
    loginLede: 'Log in to a demo account to build slips and play the demo games.',
    demoNote: 'Demo account for a quick look: username {u}, password {p} (available once the seed script has been run).',
    usernameOrEmail: 'Username or email',
    password: 'Password', confirmPassword: 'Repeat password',
    signIn: 'Log in', signingIn: 'Logging in…',
    noAccount: 'No account yet?', openDemo: 'Open a demo account',
    haveAccount: 'Already have an account?',
    securityNote: 'This is an educational project. Do not enter a real password you use elsewhere — use made-up details.',
    alreadyIn: 'You are already logged in', alreadyInBody: 'Logged in as {name}.',

    registerTitle: 'Open a demo account',
    registerLede: 'The account exists purely to try out this demonstration. You start with 500 demo credits, which have no value whatsoever.',
    registerWarn: 'Do not use a real password from another site. Enter made-up details — this is an exercise, not a real service.',
    username: 'Username', usernameHint: '3–24 characters.',
    email: 'Email', emailHint: 'Use a made-up address, e.g. name@example.local.',
    passwordHint: 'At least 8 characters.',
    ageConfirm: 'I confirm that I am 18 or older.',
    termsPre: 'I accept the', termsLink: 'rules',
    termsPost: 'and understand that this is a demonstration project with no real money.',
    creating: 'Creating account…', createAccount: 'Open a demo account',
    accountExists: 'Your account is already open',
    errShort: 'The password must be at least 8 characters.',
    errMatch: 'The passwords do not match.',
    errAge: 'You must confirm that you are 18 or older.',
    errTerms: 'You must accept the terms of use.',
    loggedInAs: 'Logged in as {name}.',
    registered: 'Your demo account is open. You received 500 demo credits.',
    loggedOut: 'Logged out.'
  },

  /* ---------------- assistant ---------------- */
  assistant: {
    title: 'PSK Assistant',
    subtitle: 'Navigation and answers',
    welcome: 'Ask me anything about the site — I can take you to a game or page, '
      + 'or answer questions about deposits, withdrawals and verification.',
    placeholder: 'Type your question...',
    send: 'Send',
    yes: 'yes',
    error: 'I cannot reach the assistant right now. Try again in a moment.',
    sources: 'Sources ({n})',
    policyFlag: 'depends on official policy',
    disclaimer: 'Demo assistant. It cannot see account balances and gives no financial advice.',
    s1: 'Open Aviator',
    s2: 'How does Aviator work?',
    s3: 'My tickets',
    s4: 'Set a limit'
  },

  /* ---------------- checkout ---------------- */
  checkout: {
    title: 'Confirm your bet',
    lede: 'Check the selections and the amount before confirming. The slip goes to the server, which re-reads the odds from the database.',
    selections: 'Your selections',
    summary: 'Summary',
    stake: 'Stake',
    pairs: 'Selections',
    totalOdds: 'Total odds',
    gross: 'Gross return',
    deduction: 'Deduction (10%)',
    potential: 'Potential return',
    balanceAfter: 'Balance after stake',
    confirm: 'Confirm bet',
    confirming: 'Confirming…',
    back: 'Back to the offer',
    emptyTitle: 'Your slip is empty',
    emptyBody: 'Add at least one selection from the offer before confirming.',
    openOffer: 'Open the offer',
    loginTitle: 'Login required',
    loginBody: 'Log in to a demo account to confirm the bet.',
    social: '{n} players have already placed this combination today.',
    socialLive: '{n} viewing right now',
    marketCol: 'Market',
    oddsCol: 'Odds',
    demoNote: 'Demo bet — fictional credits are used, not real money.',

    placedTitle: 'Bet placed',
    placedBody: 'Your demo ticket has been accepted and is awaiting settlement.',
    ref: 'Ticket reference',
    myTickets: 'My tickets',
    newBet: 'New bet',
    placedAt: 'Placed at',

    leaveTitle: 'Leave without betting?',
    leaveBody: 'If you leave now this slip will not be placed.',
    leaveProjected: 'Had you confirmed, your potential return would be',
    leaveStay: 'Stay and confirm',
    leaveGo: 'Leave anyway'
  },

  /* ---------------- account ---------------- */
  account: {
    title: 'My account',
    needLogin: 'You need to log in to access your account.',
    openedOn: 'Demo account opened {date}.',
    cards: {
      balance: 'demo account balance', tickets: 'tickets placed',
      rounds: 'rounds played', net: 'casino round balance'
    },
    depositTitle: 'Add demo credits',
    depositBody: 'The credits are fictional and exist only for trying things out. There are no real payments, cards or transactions.',
    deposited: 'Added {amount} in demo credits.',
    limitsTitle: 'Play limits',
    limitDeposit: 'Daily deposit limit (€)',
    limitLoss: 'Daily loss limit (€)',
    limitSession: 'Session length (min)',
    saveLimits: 'Save limits', limitsSaved: 'Your limits have been saved.',
    limitsNote: 'In this demonstration the limits are stored in the database but not enforced automatically — in a real system they would block deposits and play once the threshold was reached.',
    selfExclusionTitle: 'Self-exclusion',
    selfExclusionBody: 'Self-exclusion blocks login to the account until the chosen period expires. In this demonstration it is enforced at the API level.',
    selfExcludeConfirm: 'Self-excluding for {n} days blocks login until the period ends. Continue?',
    selfExcluded: 'The account is self-excluded for {n} days.',
    day: 'day', days: 'days',
    historyTitle: 'Recent casino rounds',
    noRounds: 'No rounds played yet.',
    tbl: { game: 'Game', time: 'Time', bet: 'Stake', win: 'Win' }
  },

  /* ---------------- tickets ---------------- */
  tickets: {
    title: 'My tickets',
    lede: 'Your placed demo tickets. Settlement is simulated — each selection resolves at random, with a probability derived from its odds.',
    needLogin: 'You need to log in to a demo account to view your tickets.',
    filters: { all: 'All', open: 'In play', won: 'Won', lost: 'Lost' },
    statuses: { open: 'in play', won: 'won', lost: 'lost', void: 'void' },
    empty: 'No tickets yet.', emptyCta: 'Open the offer', emptyTail: 'and build your first one.',
    stake: 'Stake', totalOdds: 'Total odds', deduction: 'Deduction',
    paidOut: 'Paid out', potential: 'Potential return',
    settle: 'Settle', share: 'Share to Arena', unshare: 'Remove from Arena',
    settledWon: 'Ticket {ref} is a winner — {amount}!',
    settledLost: 'Ticket {ref} did not come in.',
    shared: 'The ticket has been shared to the Arena.',
    unshared: 'The ticket is no longer public.'
  },

  /* ---------------- help ---------------- */
  help: {
    title: 'Help and FAQ',
    lede: 'Answers to the most common questions about this demonstration and how it was built.',
    faq: [
      ['Is this a real bookmaker?', 'No. This is an educational project — a MERN application built to show how such a site is structured. There are no deposits, no withdrawals and no real betting, and all data is generated.'],
      ['Where do the events and odds come from?', 'From a local MongoDB database populated by the seed script. The generator uses a fixed seed, so the content is identical after every reseed.'],
      ['How do I build a slip?', 'On the offer page, click the odd you want. The selection is added to the slip on the right. Enter a stake and click "Place bet". The slip is sent to the server, which re-checks the odds against the database.'],
      ['Why do the odds on my slip differ from the ones I clicked?', 'The server always reads the current odds from the database instead of trusting what the browser sent. This is the same principle real systems use to prevent client-side manipulation.'],
      ['How are tickets settled?', 'By clicking "Settle" on the My tickets page. Each selection resolves at random with a probability derived from its odds. If every selection wins, the return is credited to your demo account.'],
      ['How do the casino games work?', 'The animation runs in the browser, but the round result is sent to the server, which validates the stake and updates the balance. That keeps the balance authoritative on the server.'],
      ['Can I lose real money?', 'No. Your balance is fictional demo credits with no value. There is no way to deposit real money.'],
      ['How do I add more demo credits?', 'The My account page has buttons for adding credits. It is a simulation, not a real transaction.'],
      ['How do I change the interface language?', 'There is a language selector in the page footer. Your choice is remembered in the browser and applies immediately, without a reload.'],
      ['How do I run the project locally?', 'You need Node.js and MongoDB. In the server folder run npm install, npm run seed and npm run dev; in the client folder run npm install and npm run dev. The details are in README.md.'],
      ['Where is data stored?', 'Users, tickets and rounds are stored in MongoDB. The theme, language, in-progress slip and login token are kept locally in the browser.']
    ],
    moreTitle: 'Need more help?',
    tiles: {
      contact: 'Contact form', contactSub: 'send a question',
      rules: 'Game rules', rulesSub: 'how it works',
      responsible: 'Responsible gaming', responsibleSub: 'limits and help',
      about: 'About the project', aboutSub: 'technical detail'
    }
  },

  /* ---------------- about ---------------- */
  about: {
    title: 'About the project',
    lede: 'An educational MERN application that reconstructs the information architecture of a typical sportsbook and online casino site.',
    warn: 'This is not a real bookmaker. The application is not connected to any gambling operator, accepts no payments and offers no real-money betting.',
    goalTitle: 'The goal',
    goalBody: 'The project began as a web development exercise. The focus is on how such a site fits together: how sports, leagues and events are modelled, how odds are presented in a grid, how the bet slip follows selections across the whole application, and how a catalogue of several hundred games is filtered and searched without the interface slowing down.',
    techTitle: 'Technologies',
    tech: [
      ['MongoDB', 'storage for sports, leagues, events, games, users, tickets and rounds.'],
      ['Express', 'a REST API with routes for the offer, the casino, tickets, users and content.'],
      ['React', 'the interface, with client-side routing and shared state through Context.'],
      ['Node.js', 'the server runtime.'],
      ['Alongside these', 'Mongoose, JSON Web Token, bcrypt, Helmet, Vite.']
    ],
    archTitle: 'Architecture',
    archBody: 'The application is split in two. The server in the server folder exposes the API and is the sole authority over account state: when a ticket is placed it re-reads the odds from the database rather than trusting the browser, and it validates casino rounds before updating the balance. The client in the client folder renders the interface and runs the game animations.',
    whyTitle: 'Why that matters',
    whyBody: 'In any system where the client can submit a result, that result has to be checked on the server. Here that is done by re-reading odds, validating the stake range and capping the payout per round.',
    dataTitle: 'The data',
    dataBody: 'All content is produced by the seed script using a random number generator with a fixed seed. Game titles are assembled from predefined words, and game thumbnails are drawn in CSS from two colours and an emoji, so the application depends on no external images.',
    missingTitle: 'What is not implemented',
    missing: [
      'Real payment processing and identity verification.',
      'Video streaming for live tables — the tables are simulated.',
      'Automatic enforcement of play limits; limits are stored but not applied.',
      'Any connection to real sports data or results feeds.'
    ],
    nameTitle: 'A note on the name',
    nameBody: 'The name and visual identity in the application are invented and marked as a demo so it is clear this is not a real service. More about the terms on the'
  },

  /* ---------------- rules ---------------- */
  rules: {
    title: 'Game rules',
    lede: 'How slips, odds, settlement and casino rounds work in this demonstration.',
    warn: 'These rules describe the behaviour of a demonstration application. They are not a legal document and do not represent the terms of any real service.',
    s1: '1. General',
    s1body: 'The application exists purely for display and learning. The account is a demo account, and the funds on it are fictional credits with no value. Real money cannot be deposited or withdrawn.',
    s2: '2. The bet slip',
    s2list: [
      'A slip may hold at most thirty selections.',
      'Only one selection per event is allowed; a new pick replaces the previous one.',
      'The minimum stake is 0.50 demo credits.',
      'The total odds are the product of the odds of every selection on the slip.',
      'On placement the server re-reads the odds from the database; the database price applies, not the one shown in the browser.'
    ],
    s3: '3. Calculating the return',
    s3body1: 'The gross return is the stake multiplied by the total odds. Ten percent is deducted from the difference between the gross return and the stake, representing an illustrative deduction. What remains is the potential net return.',
    s3body2: 'A ticket is settled manually, at the user’s request. Each selection resolves at random, with a probability derived from its odds — the higher the odds, the lower the chance of a hit. A ticket wins only if every selection wins.',
    s4: '4. General bonus terms',
    s4body: 'The promotions shown in the application are illustrative and cannot be activated. With real offers the terms usually include a wagering requirement, minimum odds per selection, a deadline, and different contribution rates for different games.',
    s5: '5. Casino games',
    s5list: [
      'The outcome of every round is decided by a random number generator in the browser.',
      'The round is sent to the server, which validates the stake and updates the balance.',
      'The stake must fall within the range defined for that game.',
      'Previous rounds have no effect on future ones — each is independent.',
      'The stated RTP is the theoretical return percentage over a very large number of rounds, not a promise about any outcome.'
    ],
    s6: '6. Number games',
    s6body: 'The return depends on how many numbers are matched, using a fixed multiplier table. The round prize fund and the number of winners per tier are not modelled.',
    s7: '7. A note on compliance',
    s7body: 'Because the application does not organise games of chance and does not handle real funds, it is not subject to the regulations governing gambling operators. The labels, amounts and texts shown exist to make the interface look realistic.',
    s8: '8. Responsible play',
    s8body: 'The same principle applies in a demonstration as in reality: gambling is entertainment, not a way to earn. Read more on the'
  },

  /* ---------------- responsible ---------------- */
  responsible: {
    title: 'Responsible gaming',
    lede: 'Gambling can be addictive. This page explains the tools built into the application and the basic principles of safe play.',
    warn: 'Although this is a demonstration with no real money, the principles set out here apply equally to every real service.',
    principlesTitle: 'Basic principles',
    principles: [
      'Gambling is a form of entertainment that costs money, not a way to earn or to solve financial problems.',
      'Decide in advance how much you are willing to spend and stick to it regardless of the outcome.',
      'Never try to win back a loss by raising your stakes — that is the most common route into serious trouble.',
      'Do not play while drinking, while upset, or when you are tired.',
      'Watch the time you spend playing as carefully as the money.'
    ],
    limitsTitle: 'Play limits',
    limitsLead: 'Three kinds of limit can be set on the My account page:',
    limits: [
      ['Daily deposit limit', 'the largest amount that can be added to the account in one day.'],
      ['Daily loss limit', 'the net loss threshold at which play stops.'],
      ['Session length', 'the amount of time after which the system ends the session.']
    ],
    limitsNote: 'In this demonstration the limits are stored in the database but not enforced automatically. In a real system they would block deposits and play as soon as the threshold was reached, and raising a limit would usually take effect only after a cooling-off period.',
    exclusionTitle: 'Self-exclusion',
    exclusionBody: 'Self-exclusion blocks login to the account until the chosen period expires. In this application it is enforced at the API level — an attempt to log in during the exclusion period returns an error. The period cannot be shortened once activated.',
    exclusionCta: 'Open self-exclusion settings',
    exclusionLogin: 'Log in to reach the settings',
    signsTitle: 'Warning signs',
    signsLead: 'It is worth pausing and reconsidering your habits if you recognise any of the following:',
    signs: [
      'You play for longer or for larger amounts than you planned.',
      'You borrow money or sell things in order to keep playing.',
      'You hide how much you play from the people close to you.',
      'Gambling is affecting your work, studies, sleep or relationships.',
      'You feel restless or irritable when you are not playing.'
    ],
    helpTitle: 'Where to find help',
    helpBody1: 'If you recognise these signs in yourself or someone close to you, a conversation with your GP is a good starting point — they can refer you to appropriate specialist support. Many countries also have free helplines and organisations specialising in gambling addiction, including support groups for family members.',
    helpBody2: 'If you are in acute crisis or thinking about harming yourself, contact emergency services immediately — in Croatia and across the European Union that is 112.',
    minorsTitle: 'Protecting minors',
    minorsBody: 'Gambling is available only to adults. If you share a device with children, use profile locks and parental control tools, and do not save credentials in the browser.'
  },

  /* ---------------- privacy ---------------- */
  privacy: {
    title: 'Privacy policy',
    lede: 'What this demonstration application stores, where it stores it, and how the data can be removed.',
    warn: 'This is not a legal document but a technical description of how the demo application behaves. Do not use real personal data when trying it out.',
    storedTitle: 'What the application stores',
    storedLead: 'When a demo account is created, the following is stored in the database:',
    stored: [
      'the username and email address you enter yourself,',
      'the password as a cryptographic hash (bcrypt), never in readable form,',
      'your demo credit balance and any play limits you set,',
      'the tickets you place and the casino rounds you play.'
    ],
    storedTail: 'The application does not request or process identity data, addresses, documents or any payment details, because there are no real deposits.',
    browserTitle: 'Browser storage',
    browserLead: 'The application uses no tracking cookies. Only the following is kept in the browser’s local storage:',
    browser: [
      'the login token, so the session survives a page refresh,',
      'the chosen theme (light or dark) and the interface language,',
      'the in-progress bet slip and the last stake you entered.'
    ],
    browserTail: 'That data stays on your device and can be removed by clearing the site data in your browser settings.',
    thirdTitle: 'Analytics and third parties',
    thirdBody: 'There is no analytics, no advertising script and no embedded third-party content. The application sends data nowhere except to its own API server running locally.',
    accessTitle: 'Access and deletion',
    accessBody: 'Because the server runs locally, all data lives in your own MongoDB database. The entire dataset can be removed by dropping the database or by re-running the seed script with the appropriate flag.',
    securityTitle: 'Security',
    security: [
      'Passwords are stored as bcrypt hashes.',
      'Authentication uses a JSON Web Token valid for seven days.',
      'The server sets protective headers and rate-limits requests.',
      'Account balances are changed only by the server, never by the client directly.'
    ],
    securityTail: 'Production use would additionally require HTTPS, secret rotation, access logging and token storage resistant to script-based theft — none of which is implemented here, as this is a local exercise.',
    contactTitle: 'Contact',
    contactBody: 'Questions about the project can be sent through the'
  },

  /* ---------------- contact ---------------- */
  contact: {
    title: 'Contact',
    lede: 'A form for questions about the project. It is shown for completeness of the interface.',
    warn: 'This form sends nothing and stores nothing. Do not enter real personal data.',
    topics: ['General', 'Technical problem', 'Suggestion', 'Question about the project'],
    name: 'Name', email: 'Email', emailHint: 'Use a made-up address.',
    topic: 'Topic', message: 'Message',
    submit: 'Send (simulation)',
    toast: 'The form is a demonstration — your message was not sent.',
    sentTitle: 'Form submitted (simulation)',
    sentBody: 'In a real application the message would be stored here and passed to the support team. In this demonstration it was not sent anywhere.',
    newMessage: 'New message',
    otherTitle: 'Other pages',
    tiles: { faq: 'FAQ', faqSub: 'quick answers', shops: 'Shops', shopsSub: 'location list', about: 'About the project', aboutSub: 'technical detail' }
  },

  /* ---------------- champions club ---------------- */
  club: {
    title: 'Champions Club',
    lede: 'A display of a loyalty programme with tiers and points. Points in this demonstration are derived from your demo balance and have no value.',
    yourTier: 'Your tier', points: 'Points collected',
    toNext: 'To {tier} tier', pointsShort: '{n} points',
    maxTier: 'Highest tier',
    loginPrompt: 'Log in to see your tier.',
    tiersTitle: 'Tiers and benefits', fromPoints: 'from {n} points',
    tiers: [
      { name: 'Bronze',   perks: ['Access to weekly offers', 'Standard support'] },
      { name: 'Silver',   perks: ['Faster support', 'Monthly tournament', 'Extra spins'] },
      { name: 'Gold',     perks: ['Priority support', 'Higher limits', 'Dedicated account manager'] },
      { name: 'Platinum', perks: ['Everything in Gold', 'Event invitations', 'Individual offers'] }
    ],
    howTitle: 'How points are collected',
    howBody: 'In real loyalty programmes points are usually awarded in proportion to turnover, at different rates for different products. Tiers are reviewed periodically, so inactivity can mean dropping to a lower one.',
    watchTitle: 'What to watch for',
    watchBody: 'Loyalty programmes are a marketing tool designed to encourage more frequent play. Benefits should never become a reason to play more than you planned. Read more about setting boundaries on the'
  },

  /* ---------------- 404 ---------------- */
  notFound: {
    title: 'Page not found',
    lede: 'The route you opened does not exist in this application.'
  },

  /* ---------------- enumerable data from the API ---------------- */
  data: {
    sports: {
      nogomet: 'Football', kosarka: 'Basketball', tenis: 'Tennis', rukomet: 'Handball',
      odbojka: 'Volleyball', hokej: 'Ice hockey', 'stolni-tenis': 'Table tennis',
      esport: 'Esports', boks: 'Boxing', mma: 'MMA / UFC', 'formula-1': 'Formula 1',
      'moto-gp': 'Moto GP', pikado: 'Darts', snooker: 'Snooker', golf: 'Golf',
      biciklizam: 'Cycling', ragbi: 'Rugby', 'am-nogomet': 'American football',
      bejzbol: 'Baseball', vaterpolo: 'Water polo', atletika: 'Athletics',
      skijanje: 'Skiing', 'ski-skokovi': 'Ski jumping', biatlon: 'Biathlon',
      sah: 'Chess', futsal: 'Futsal', badminton: 'Badminton', kuglanje: 'Bowling',
      'konjicke-utrke': 'Horse racing', zabava: 'Entertainment'
    },
    categories: {
      lobby: 'Lobby', favourites: 'Favourites', new: 'New games', popular: 'Popular',
      jackpot: 'Jackpots', exclusive: 'Exclusive', 'game-shows': 'Game shows',
      'buy-bonus': 'Buy Bonus', drops: 'Drops & Wins', 'small-bets': 'Small stakes',
      'big-wins': 'Big wins', instant: 'Instant games', table: 'Table games',
      roulette: 'Roulette', classic: 'Classic slots', megaways: 'Megaways', all: 'All games'
    },
    volatility: { Niska: 'Low', Srednja: 'Medium', Visoka: 'High' },
    marketLabels: {
      '1': 'Full time 1', 'X': 'Full time X', '2': 'Full time 2',
      '1X': 'Double chance 1X', 'X2': 'Double chance X2', '12': 'Double chance 12',
      'GG': 'Both teams to score', 'H1': 'Handicap 1', 'H2': 'Handicap 2',
      'U': 'Under', 'O': 'Over', 'TM': 'Total', 'Tečaj': 'Winner'
    },
    marketGroups: {
      'Konačni ishod': 'Match result',
      'Ukupno golova / poena': 'Total goals / points',
      'Poluvrijeme': 'Half time',
      'Hendikep': 'Handicap',
      'Kombinacije': 'Combinations'
    }
  }
};
