/// Editorial / product content that the website serves from `GET /api/content/*`.
/// The app ships it statically: promotions, news, lotteries, virtual races and
/// the Champions Club loyalty programme.
library;

class PromoTerms {
  final double minDeposit;
  final double maxBonus;
  final String wagering;
  final int validDays;
  final String products;
  final double minOdds;

  const PromoTerms({
    required this.minDeposit,
    required this.maxBonus,
    required this.wagering,
    required this.validDays,
    required this.products,
    this.minOdds = 1.50,
  });
}

class Promotion {
  final String slug;
  final String tag; // Sport, Casino, Loto, New members, Club
  final String badge; // NEW / HOT
  final String title;
  final String excerpt;
  final String body;
  final String cta;
  final int hueA;
  final int hueB;
  final DateTime validUntil;
  final PromoTerms terms;
  final bool featured;

  const Promotion({
    required this.slug,
    required this.tag,
    required this.badge,
    required this.title,
    required this.excerpt,
    required this.body,
    required this.cta,
    required this.hueA,
    required this.hueB,
    required this.validUntil,
    required this.terms,
    this.featured = false,
  });
}

class NewsArticle {
  final String slug;
  final String category;
  final String title;
  final String excerpt;
  final DateTime publishedAt;

  const NewsArticle({
    required this.slug,
    required this.category,
    required this.title,
    required this.excerpt,
    required this.publishedAt,
  });
}

class LotteryGame {
  final String slug;
  final String name;
  final String icon;
  final int pick;
  final int max;
  final String drawInfo;
  final double jackpot;
  final double price;
  final int hueA;
  final int hueB;
  final List<int> hotNumbers;

  const LotteryGame({
    required this.slug,
    required this.name,
    required this.icon,
    required this.pick,
    required this.max,
    required this.drawInfo,
    required this.jackpot,
    required this.price,
    required this.hueA,
    required this.hueB,
    required this.hotNumbers,
  });
}

class VirtualGame {
  final String slug;
  final String name;
  final String icon;
  final String intervalLabel;
  final int intervalSeconds;
  final int runners;
  final String description;
  final String track;
  final int hueA;
  final int hueB;

  const VirtualGame({
    required this.slug,
    required this.name,
    required this.icon,
    required this.intervalLabel,
    required this.intervalSeconds,
    required this.runners,
    required this.description,
    required this.track,
    required this.hueA,
    required this.hueB,
  });
}

class LoyaltyTier {
  final String name;
  final int points;
  final int colour;
  final List<String> perks;

  const LoyaltyTier({required this.name, required this.points, required this.colour, required this.perks});
}

class LoyaltyReward {
  final String id;
  final String title;
  final String description;
  final int cost;
  final String icon;

  const LoyaltyReward({
    required this.id,
    required this.title,
    required this.description,
    required this.cost,
    required this.icon,
  });
}

class ContentData {
  ContentData._();

  static final List<Promotion> promos = [
    Promotion(
      slug: 'welcome-bonus',
      tag: 'New members',
      badge: 'NEW',
      title: 'Welcome Bonus — 100% Match on First Deposit',
      excerpt: 'Get double your first deposit up to 500 €. Valid for new accounts only. T&Cs apply.',
      body:
          'Register a new account and make your first deposit. We will match 100% up to 500 €. '
          'Wagering requirements: 5× on sports, 25× on casino. The bonus is credited automatically '
          'once the qualifying deposit settles.',
      cta: 'Claim bonus',
      hueA: 210,
      hueB: 258,
      validUntil: DateTime(2026, 9, 30),
      terms: const PromoTerms(minDeposit: 10, maxBonus: 500, wagering: '5× / 25×', validDays: 30, products: 'All'),
      featured: true,
    ),
    Promotion(
      slug: 'cashback-weekend',
      tag: 'Casino',
      badge: 'HOT',
      title: 'Cashback Weekend',
      excerpt: 'Get 10% cashback on all casino losses every Saturday and Sunday.',
      body:
          'Play any slot or table game from Friday 18:00 to Sunday midnight. 10% of your net losses '
          'come back as bonus credits on Monday morning, up to 100 € per weekend.',
      cta: 'View games',
      hueA: 280,
      hueB: 324,
      validUntil: DateTime(2026, 10, 31),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 100, wagering: '10×', validDays: 7, products: 'Casino'),
    ),
    Promotion(
      slug: 'free-bet-friday',
      tag: 'Sport',
      badge: 'SPORT',
      title: 'Free Bet Friday',
      excerpt: 'Place 5 bets during the week, get 1 free 5 € bet every Friday.',
      body:
          'Place five settled sports tickets of at least 2 € between Monday and Thursday. '
          'On Friday a free 5 € bet is added to your account, usable on any accumulator with total odds of 1.50 or higher.',
      cta: 'Open offer',
      hueA: 22,
      hueB: 52,
      validUntil: DateTime(2026, 12, 31),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 5, wagering: '1×', validDays: 3, products: 'Sport', minOdds: 1.50),
    ),
    Promotion(
      slug: 'jackpot-race',
      tag: 'Casino',
      badge: 'CASINO',
      title: 'Jackpot Race',
      excerpt: 'Win a share of 50,000 € in mystery cash drops on EGT and Pragmatic games.',
      body:
          'Every spin on a participating game enters the weekly race. Random cash drops between 5 € and 5,000 € '
          'land on players during the week, with the leaderboard top 100 sharing the remaining fund on Sunday.',
      cta: 'Play now',
      hueA: 8,
      hueB: 38,
      validUntil: DateTime(2026, 9, 27),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 5000, wagering: '0×', validDays: 7, products: 'Casino'),
    ),
    Promotion(
      slug: 'lucky-7-draw',
      tag: 'Loto',
      badge: 'LOTO',
      title: 'Lucky 7 Draw',
      excerpt: 'Every 7th Loto 7/39 ticket is free — automatically applied at checkout.',
      body:
          'Buy Loto 7/39 tickets and every seventh ticket in a calendar week is on us. '
          'The free ticket uses the same numbers and draw as the ticket before it.',
      cta: 'Buy ticket',
      hueA: 302,
      hueB: 342,
      validUntil: DateTime(2026, 11, 15),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 1, wagering: '0×', validDays: 7, products: 'Loto'),
    ),
    Promotion(
      slug: 'psk-advantage-2up',
      tag: 'Sport',
      badge: 'SPORT',
      title: 'PSK Advantage — 2UP',
      excerpt: 'Leading by 2 goals? Your bet is already a winner, no need to wait for the final whistle.',
      body:
          'Available for football (2UP), basketball (16UP) and handball (5UP) pre-match single bets on the match winner market. '
          'Once your team leads by the required margin the selection is settled as won.',
      cta: 'Bet now',
      hueA: 140,
      hueB: 168,
      validUntil: DateTime(2026, 12, 31),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 0, wagering: '0×', validDays: 0, products: 'Sport'),
    ),
    Promotion(
      slug: 'champions-club',
      tag: 'Club',
      badge: 'CLUB',
      title: 'Champions Club — Points & Tiers',
      excerpt: 'Collect points on every bet and casino round, unlock tiers with extra perks.',
      body:
          'Every euro staked earns points. Climb from Starter to Platinum for cashback, free bets and a VIP manager. '
          'Tiers are reviewed monthly and points expire after 6 months of inactivity.',
      cta: 'About the club',
      hueA: 190,
      hueB: 232,
      validUntil: DateTime(2026, 12, 31),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 0, wagering: '0×', validDays: 180, products: 'All'),
    ),
    Promotion(
      slug: 'drops-wins',
      tag: 'Casino',
      badge: 'NEW',
      title: 'Drops & Wins Prize Pool',
      excerpt: 'Daily and monthly prizes on selected Pragmatic Play slots.',
      body:
          'Daily prize drops and a monthly tournament on selected Pragmatic Play titles. '
          'Minimum qualifying spin is 0.50 €; prizes are paid as cash with no wagering.',
      cta: 'Play now',
      hueA: 96,
      hueB: 140,
      validUntil: DateTime(2026, 10, 31),
      terms: const PromoTerms(minDeposit: 0, maxBonus: 2000, wagering: '0×', validDays: 30, products: 'Casino'),
    ),
  ];

  static const List<String> promoTags = ['All', 'Sport', 'Casino', 'Loto', 'New members', 'Club'];

  static final List<NewsArticle> news = [
    NewsArticle(
      slug: 'derby-preview',
      category: 'Football',
      title: 'Round preview: the derby closes Saturday',
      excerpt: 'Form, absences and stats ahead of the most important match of the round.',
      publishedAt: DateTime(2026, 9, 9),
    ),
    NewsArticle(
      slug: 'euroleague-openers',
      category: 'Basketball',
      title: 'EuroLeague: analysis of the opening games',
      excerpt: 'How the European clubs opened the season and what to expect next.',
      publishedAt: DateTime(2026, 9, 8),
    ),
    NewsArticle(
      slug: 'tennis-september',
      category: 'Tennis',
      title: 'Tournament calendar for September',
      excerpt: 'Everything about the upcoming ATP and WTA events and Croatian players.',
      publishedAt: DateTime(2026, 9, 7),
    ),
    NewsArticle(
      slug: 'new-games-month',
      category: 'Casino',
      title: 'New games in the lobby this month',
      excerpt: 'A look at the titles added to the casino offer in September.',
      publishedAt: DateTime(2026, 9, 6),
    ),
    NewsArticle(
      slug: 'betbuilder-guide',
      category: 'Sportsbook',
      title: 'Guide: how BetBuilder works',
      excerpt: 'Step by step through building your own bet on a single event.',
      publishedAt: DateTime(2026, 9, 5),
    ),
    NewsArticle(
      slug: 'security-guide',
      category: 'Safety',
      title: 'Security guide for players',
      excerpt: 'How to protect your account, spot scams and set play limits.',
      publishedAt: DateTime(2026, 9, 4),
    ),
  ];

  static const List<LotteryGame> lotteries = [
    LotteryGame(
      slug: 'loto-7-39',
      name: 'Loto 7/39',
      icon: '🎱',
      pick: 7,
      max: 39,
      drawInfo: 'Wed & Sun, 20:00',
      jackpot: 1250000,
      price: 1.00,
      hueA: 220,
      hueB: 232,
      hotNumbers: [7, 14, 21, 28, 33],
    ),
    LotteryGame(
      slug: 'joker',
      name: 'Joker',
      icon: '🃏',
      pick: 6,
      max: 45,
      drawInfo: 'Tue & Fri, 20:00',
      jackpot: 845000,
      price: 0.80,
      hueA: 275,
      hueB: 290,
      hotNumbers: [3, 11, 19, 27, 42],
    ),
    LotteryGame(
      slug: 'eurojackpot',
      name: 'EuroJackpot',
      icon: '🌍',
      pick: 5,
      max: 50,
      drawInfo: 'Fri, 21:00',
      jackpot: 42000000,
      price: 2.00,
      hueA: 152,
      hueB: 158,
      hotNumbers: [5, 17, 23, 35, 49],
    ),
    LotteryGame(
      slug: 'bingo',
      name: 'Bingo 90',
      icon: '🔴',
      pick: 6,
      max: 90,
      drawInfo: 'Every 10 minutes',
      jackpot: 125000,
      price: 1.00,
      hueA: 8,
      hueB: 12,
      hotNumbers: [9, 22, 47, 61, 88],
    ),
    LotteryGame(
      slug: 'keno',
      name: 'Keno',
      icon: '⭐',
      pick: 10,
      max: 80,
      drawInfo: 'Every 5 minutes',
      jackpot: 500000,
      price: 0.50,
      hotNumbers: [2, 15, 31, 44, 66, 77],
      hueA: 28,
      hueB: 32,
    ),
    LotteryGame(
      slug: 'quick-pick',
      name: 'Quick Pick',
      icon: '⚡',
      pick: 8,
      max: 35,
      drawInfo: 'Every 4 minutes',
      jackpot: 50000,
      price: 0.50,
      hueA: 240,
      hueB: 240,
      hotNumbers: [4, 13, 20, 29],
    ),
  ];

  /// Illustrative pay table by number of matched numbers — multiplier of stake.
  static const Map<int, double> lotteryPayTable = {
    3: 2, 4: 8, 5: 40, 6: 400, 7: 5000, 8: 9000, 9: 14000, 10: 20000,
  };

  static const List<VirtualGame> virtuals = [
    VirtualGame(
      slug: 'horses',
      name: 'Horse Racing',
      icon: '🐎',
      intervalLabel: 'Every 3 min',
      intervalSeconds: 180,
      runners: 8,
      description: 'Eight runners per race, winner and placing markets.',
      track: 'Ascot Virtual',
      hueA: 22,
      hueB: 52,
    ),
    VirtualGame(
      slug: 'greyhounds',
      name: 'Greyhounds',
      icon: '🐕',
      intervalLabel: 'Every 2 min',
      intervalSeconds: 120,
      runners: 6,
      description: 'Six dogs, fast races all day long.',
      track: 'Romford Virtual',
      hueA: 38,
      hueB: 96,
    ),
    VirtualGame(
      slug: 'motor',
      name: 'Motor Racing',
      icon: '🏎️',
      intervalLabel: 'Every 3 min',
      intervalSeconds: 180,
      runners: 10,
      description: 'Ten cars and a winner market.',
      track: 'Monza Virtual',
      hueA: 210,
      hueB: 258,
    ),
    VirtualGame(
      slug: 'cycling',
      name: 'Cycling',
      icon: '🚴',
      intervalLabel: 'Every 4 min',
      intervalSeconds: 240,
      runners: 12,
      description: 'A stage with twelve riders.',
      track: 'Alpe Virtual',
      hueA: 168,
      hueB: 196,
    ),
  ];

  static const List<String> runnerNames = [
    'Thunder Bolt', 'Silver Arrow', 'Midnight Star', 'Golden Dawn', 'Royal Flush', 'Blue Comet',
    'Iron Duke', 'Velvet Storm', 'Wild Rose', 'Northern Light', 'Sea Breeze', 'Crimson Tide',
  ];

  static const List<String> jockeys = [
    'J. Smith', 'K. Patel', 'M. Horvat', 'L. Rossi', 'A. Novak', 'D. Kovač', 'P. Dubois',
    'R. Garcia', 'T. Müller', 'S. Ivić', 'B. O\'Neil', 'F. Costa',
  ];

  static const List<LoyaltyTier> tiers = [
    LoyaltyTier(name: 'Starter', points: 0, colour: 0xFF8A5A2B, perks: ['Basic access', 'Streak rewards']),
    LoyaltyTier(name: 'Bronze', points: 500, colour: 0xFFB87333, perks: ['2% cashback', 'Daily rewards']),
    LoyaltyTier(name: 'Silver', points: 1500, colour: 0xFF9AA7B8, perks: ['5% cashback', 'Bonus spins', 'Promo access']),
    LoyaltyTier(
      name: 'Gold',
      points: 4000,
      colour: 0xFFD4A017,
      perks: ['10% cashback', 'Weekly free bets', 'Higher bet limits', 'Monthly bonus'],
    ),
    LoyaltyTier(
      name: 'Platinum',
      points: 20000,
      colour: 0xFFC0D6E4,
      perks: ['VIP manager', '15% cashback', 'Exclusive events', 'Priority withdrawals', 'Birthday bonus'],
    ),
  ];

  static const List<LoyaltyReward> rewards = [
    LoyaltyReward(id: 'free_bet_5', title: 'Free Bet 5 €', description: 'Credited to your balance', cost: 200, icon: '🎟️'),
    LoyaltyReward(id: 'spins_10', title: 'Bonus Spins ×10', description: 'On any slot', cost: 150, icon: '🎰'),
    LoyaltyReward(id: 'cashback_boost', title: 'Cashback Boost', description: '+5% for 7 days', cost: 500, icon: '📈'),
    LoyaltyReward(id: 'merch_voucher', title: 'Merch Voucher', description: '20 € PSK store', cost: 1000, icon: '🎁'),
  ];

  static const Map<String, String> earningRules = {
    'Sports bet': '1 pt / 1 €',
    'Casino play': '2 pt / 1 €',
    'Daily login': '5 pts',
    'Streak bonus': 'up to 25 pts',
    'Winning bet': '2× points',
  };
}
