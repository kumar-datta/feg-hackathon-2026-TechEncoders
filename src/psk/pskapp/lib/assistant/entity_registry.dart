import '../models/casino_game.dart';
import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import 'assistant_models.dart';

/// The app's navigation registry — the equivalent of the website's
/// `entities.json`, regenerated there from the live site. Here it is built from
/// the app's own tabs, screens, sports and casino catalogue, so every route the
/// assistant can emit is one the app actually has.
///
/// Route grammar (interpreted by [AssistantRouter]):
///
/// * `tab:INDEX` — top tab
/// * `game:ID` — casino game (opens the preview sheet)
/// * `sport:NAME` — sportsbook filtered to one sport (SportType.name)
/// * `category:NAME` — casino filtered to a category
/// * `sheet:NAME` — deposit | mybets | betslip
/// * `screen:NAME` — checkout | streak | widgets | history | account | help |
///   contact | rules | responsible | limits | self_exclusion | privacy |
///   login | register
class EntityRegistry {
  EntityRegistry._();

  static List<AssistantEntity> build(List<CasinoGame> games) {
    return [
      ..._pages,
      ..._sports,
      ..._categories,
      ...games.map(_gameEntity),
    ];
  }

  static const List<AssistantEntity> _pages = [
    AssistantEntity(
      id: 'page_home',
      type: 'PAGE',
      name: 'Home',
      aliases: ['home', 'homepage', 'main page', 'naslovna', 'ghar', 'start page'],
      description: 'the landing screen with the hero carousel, quick access grid, top offer and casino rails.',
      category: 'Navigation',
      route: 'tab:${PskTab.home}',
      keywords: ['home', 'landing'],
    ),
    AssistantEntity(
      id: 'page_sportsbook',
      type: 'PAGE',
      name: 'Sportsbook',
      aliases: ['sports', 'sportsbook', 'betting', 'oklade', 'ponuda', 'sports betting', 'match betting',
        'sports dikhao', 'khel satta', 'bet on sports', 'the offer', 'full offer'],
      description: 'the pre-match offer with leagues, odds and extra markets.',
      category: 'Sports',
      route: 'tab:${PskTab.sports}',
      keywords: ['sports', 'betting', 'odds', 'oklade', 'offer'],
    ),
    AssistantEntity(
      id: 'page_live_betting',
      type: 'PAGE',
      name: 'Live Betting',
      aliases: ['live', 'live betting', 'in play', 'inplay', 'uzivo', 'zivo', 'live odds', 'live matches', 'live bets'],
      description: 'in-play matches with live scores, minute and the pitch tracker.',
      category: 'Sports',
      route: 'tab:${PskTab.live}',
      keywords: ['live', 'inplay', 'score'],
    ),
    AssistantEntity(
      id: 'page_casino',
      type: 'PAGE',
      name: 'Casino',
      aliases: ['casino', 'casino lobby', 'slots', 'casino games', 'casino kholo', 'casino dikhao', 'slot games'],
      description: 'the casino lobby with slots, jackpots and table games.',
      category: 'Casino',
      route: 'tab:${PskTab.casino}',
      keywords: ['casino', 'slots', 'games'],
    ),
    AssistantEntity(
      id: 'page_live_casino',
      type: 'PAGE',
      name: 'Live Casino',
      aliases: ['live casino', 'live dealer', 'live tables', 'zivi casino', 'real dealer'],
      description: 'live dealer tables — roulette, blackjack and baccarat.',
      category: 'Casino',
      route: 'tab:${PskTab.liveCasino}',
      keywords: ['live', 'dealer', 'tables'],
    ),
    AssistantEntity(
      id: 'page_loto',
      type: 'PAGE',
      name: 'Lotto',
      aliases: ['loto', 'lotto', 'lottery', 'numbers game', 'keno', 'bingo', 'loto dikhao', 'eurojackpot', 'joker'],
      description: 'six lottery draws with number picking and animated draws.',
      category: 'Games',
      route: 'tab:${PskTab.lotto}',
      keywords: ['lotto', 'lottery', 'draw', 'numbers'],
    ),
    AssistantEntity(
      id: 'page_virtuals',
      type: 'PAGE',
      name: 'Virtual Races',
      aliases: ['virtual', 'virtuals', 'virtual games', 'virtualne igre', 'simulated games', 'virtual races',
        'horse racing', 'greyhounds', 'virtual horses'],
      description: 'simulated horse and greyhound races every few minutes.',
      category: 'Games',
      route: 'tab:${PskTab.virtuals}',
      keywords: ['virtual', 'races', 'horses'],
    ),
    AssistantEntity(
      id: 'page_swipe',
      type: 'PAGE',
      name: 'Swipe & Bet',
      aliases: ['swipe', 'swipe and bet', 'swipe bet', 'quick bet', 'quick picks', 'tinder bets'],
      description: 'a card stack of suggested bets — swipe right to add, left to skip.',
      category: 'Sports',
      route: 'tab:${PskTab.swipe}',
      keywords: ['swipe', 'quick'],
    ),
    AssistantEntity(
      id: 'page_arena',
      type: 'PAGE',
      name: 'PSK Arena',
      aliases: ['arena', 'shared tickets', 'community tickets', 'psk arena', 'social feed', 'copy tickets'],
      description: 'the social feed of shared tickets you can copy onto your slip.',
      category: 'Community',
      route: 'tab:${PskTab.arena}',
      keywords: ['arena', 'community', 'shared'],
    ),
    AssistantEntity(
      id: 'page_forum',
      type: 'PAGE',
      name: 'Forum',
      aliases: ['forum', 'community', 'discussion', 'threads'],
      description: 'community discussion threads.',
      category: 'Community',
      route: 'tab:${PskTab.forum}',
      keywords: ['forum', 'discussion'],
    ),
    AssistantEntity(
      id: 'page_promotions',
      type: 'PAGE',
      name: 'Promotions',
      aliases: ['promotions', 'promocije', 'promo', 'offers', 'deals', 'bonus', 'bonuses', 'offer dikhao',
        'koi bonus hai', 'welcome bonus', 'free bets'],
      description: 'active bonuses, welcome offers and seasonal campaigns.',
      category: 'Content',
      route: 'tab:${PskTab.promos}',
      keywords: ['promo', 'bonus', 'offers'],
    ),
    AssistantEntity(
      id: 'page_champions_club',
      type: 'PAGE',
      name: 'Champions Club',
      aliases: ['champions club', 'klub prvaka', 'loyalty', 'vip', 'tiers', 'points', 'loyalty points',
        'my tier', 'rewards shop', 'redeem points'],
      description: 'the loyalty programme with tiers, points and a rewards shop.',
      category: 'Account',
      route: 'tab:${PskTab.championsClub}',
      keywords: ['loyalty', 'tier', 'points', 'club'],
    ),
    AssistantEntity(
      id: 'page_checkout',
      type: 'PAGE',
      name: 'Betslip',
      aliases: ['checkout', 'confirm bet', 'place bet', 'bet slip', 'betslip', 'my slip', 'listic', 'place my bet'],
      description: 'your current selections, stake and potential return.',
      category: 'Sports',
      route: 'sheet:betslip',
      keywords: ['betslip', 'checkout', 'stake'],
    ),
    AssistantEntity(
      id: 'page_tickets',
      type: 'PAGE',
      name: 'My Tickets',
      aliases: ['tickets', 'my tickets', 'listici', 'bet history', 'my bets', 'betting history', 'past bets',
        'mera bet history dikhao', 'na bets chupinchu', 'active bets', 'cash out'],
      description: 'your placed tickets, in play and settled, with cash-out.',
      category: 'Account',
      route: 'sheet:mybets',
      keywords: ['tickets', 'bets', 'history'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_account',
      type: 'PAGE',
      name: 'My Account',
      aliases: ['account', 'my account', 'profile', 'racun', 'wallet', 'balance', 'my profile', 'account settings',
        'profile kholo', 'my wallet'],
      description: 'your wallet, play limits and session settings.',
      category: 'Account',
      route: 'screen:account',
      keywords: ['account', 'wallet', 'profile'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_deposit',
      type: 'PAGE',
      name: 'Deposit',
      aliases: ['deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge', 'paisa dalo', 'deposit karo',
        'paise jama karo', 'dabbu vesali', 'add credits', 'quick deposit'],
      description: 'the quick deposit sheet for demo credits.',
      category: 'Account',
      route: 'sheet:deposit',
      keywords: ['deposit', 'money', 'funds'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_limits',
      type: 'PAGE',
      name: 'Play Limits',
      aliases: ['limits', 'deposit limit', 'set limit', 'play limits', 'limit set karo', 'spending limit', 'set a limit'],
      description: 'deposit, loss and session limits.',
      category: 'Account',
      route: 'screen:limits',
      keywords: ['limits', 'limit'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_self_exclusion',
      type: 'PAGE',
      name: 'Self-Exclusion',
      aliases: ['self exclusion', 'self exclude', 'block my account', 'take a break', 'exclude me', 'gambling band karo'],
      description: 'pause your account and all PSK Pulse widgets.',
      category: 'Account',
      route: 'screen:self_exclusion',
      keywords: ['exclusion', 'break'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_streak',
      type: 'PAGE',
      name: 'Daily Streak',
      aliases: ['streak', 'daily streak', 'daily reward', 'claim reward', 'login bonus', 'daily bonus'],
      description: 'the daily login streak and its rewards.',
      category: 'Rewards',
      route: 'screen:streak',
      keywords: ['streak', 'daily', 'reward'],
    ),
    AssistantEntity(
      id: 'page_widgets',
      type: 'PAGE',
      name: 'PSK Pulse Widgets',
      aliases: ['widgets', 'pulse', 'psk pulse', 'home screen widget', 'lock screen', 'widget settings'],
      description: 'home-screen and lock-screen widget settings.',
      category: 'Settings',
      route: 'screen:widgets',
      keywords: ['widget', 'pulse'],
    ),
    AssistantEntity(
      id: 'page_game_history',
      type: 'PAGE',
      name: 'Game Activity',
      aliases: ['game history', 'game activity', 'play history', 'casino history', 'my rounds', 'game logs'],
      description: 'your casino rounds and session logs.',
      category: 'Account',
      route: 'screen:history',
      keywords: ['history', 'activity', 'logs'],
      requiresAuth: true,
    ),
    AssistantEntity(
      id: 'page_login',
      type: 'PAGE',
      name: 'Login',
      aliases: ['login', 'log in', 'sign in', 'prijava', 'login karo'],
      description: 'the sign-in dialog.',
      category: 'Account',
      route: 'screen:login',
      keywords: ['login'],
    ),
    AssistantEntity(
      id: 'page_register',
      type: 'PAGE',
      name: 'Register',
      aliases: ['register', 'sign up', 'registracija', 'create account', 'new account'],
      description: 'the registration dialog.',
      category: 'Account',
      route: 'screen:register',
      keywords: ['register', 'signup'],
    ),
    AssistantEntity(
      id: 'page_help',
      type: 'PAGE',
      name: 'Help',
      aliases: ['help', 'pomoc', 'faq', 'help center', 'support articles', 'madad', 'sahayam'],
      description: 'help articles and frequently asked questions.',
      category: 'Support',
      route: 'screen:help',
      keywords: ['help', 'faq'],
    ),
    AssistantEntity(
      id: 'page_contact',
      type: 'PAGE',
      name: 'Contact Support',
      aliases: ['contact', 'contact support', 'support', 'customer care', 'agent', 'complaint',
        'support se baat karao', 'live chat', 'customer support'],
      description: 'ways to reach customer support.',
      category: 'Support',
      route: 'screen:contact',
      keywords: ['contact', 'support'],
    ),
    AssistantEntity(
      id: 'page_rules',
      type: 'PAGE',
      name: 'Game Rules',
      aliases: ['rules', 'game rules', 'terms', 'pravila igre', 'terms and conditions', 'tnc', 'bonus terms'],
      description: 'betting and game rules.',
      category: 'Support',
      route: 'screen:rules',
      keywords: ['rules', 'terms'],
    ),
    AssistantEntity(
      id: 'page_responsible_gaming',
      type: 'PAGE',
      name: 'Responsible Gaming',
      aliases: ['responsible gaming', 'responsible gambling', 'odgovorno igranje', 'safer gambling', 'gambling help',
        'addiction help', 'stop gambling', 'problem gambling'],
      description: 'tools and contacts for safer play.',
      category: 'Support',
      route: 'screen:responsible',
      keywords: ['responsible', 'safer', 'help'],
    ),
    AssistantEntity(
      id: 'page_privacy',
      type: 'PAGE',
      name: 'Privacy Policy',
      aliases: ['privacy', 'privacy policy', 'data policy', 'pravila privatnosti', 'gdpr'],
      description: 'how your data is handled.',
      category: 'Support',
      route: 'screen:privacy',
      keywords: ['privacy', 'data'],
    ),
  ];

  static final List<AssistantEntity> _sports = [
    for (final s in SportType.values)
      AssistantEntity(
        id: 'sport_${s.name}',
        type: 'SPORT',
        name: s.title,
        aliases: _sportAliases[s] ?? [s.title.toLowerCase()],
        description: '${s.title} betting markets in the sportsbook.',
        category: 'Sports',
        route: 'sport:${s.name}',
        keywords: [s.title.toLowerCase(), 'bets', 'betting'],
      ),
  ];

  static const Map<SportType, List<String>> _sportAliases = {
    SportType.football: ['football', 'soccer', 'nogomet', 'futbol', 'football bets', 'football betting', 'nogomet dikhao', 'hnl', 'premier league'],
    SportType.basketball: ['basketball', 'kosarka', 'košarka', 'nba', 'basket', 'basketball bets'],
    SportType.tennis: ['tennis', 'tenis', 'atp', 'wta', 'tennis bets'],
    SportType.hockey: ['hockey', 'ice hockey', 'hokej', 'nhl'],
    SportType.handball: ['handball', 'rukomet'],
    SportType.esport: ['esports', 'e-sports', 'esport', 'counter strike', 'lol', 'dota'],
    SportType.volleyball: ['volleyball', 'odbojka'],
    SportType.darts: ['darts', 'pikado'],
    SportType.waterPolo: ['water polo', 'vaterpolo'],
  };

  static final List<AssistantEntity> _categories = [
    for (final c in CasinoCategory.values)
      AssistantEntity(
        id: 'category_${c.name}',
        type: 'CATEGORY',
        name: '${c.title} games',
        aliases: _categoryAliases[c] ?? [c.title.toLowerCase()],
        description: 'the ${c.title.toLowerCase()} category in the casino lobby.',
        category: 'Casino',
        route: 'category:${c.name}',
        keywords: [c.title.toLowerCase()],
      ),
  ];

  static const Map<CasinoCategory, List<String>> _categoryAliases = {
    CasinoCategory.popular: ['popular games', 'popular slots', 'top games', 'most played'],
    CasinoCategory.newGames: ['new games', 'new slots', 'latest games', 'newest'],
    CasinoCategory.jackpot: ['jackpot games', 'jackpots', 'progressive jackpot', 'jackpot slots'],
    CasinoCategory.slots: ['slot games', 'video slots', 'classic slots', 'fruit slots'],
    CasinoCategory.tableGames: ['table games', 'roulette', 'blackjack', 'baccarat', 'card games', 'tables'],
    CasinoCategory.megaways: ['megaways', 'megaways slots', 'ways to win'],
  };

  static AssistantEntity _gameEntity(CasinoGame g) {
    final lower = g.title.toLowerCase();
    final simplified = lower.replaceAll(RegExp(r"[^a-z0-9 ]"), '').replaceAll(RegExp(r'\s+'), ' ').trim();
    final words = simplified.split(' ').where((w) => w.isNotEmpty).toList();
    final aliases = <String>{
      lower,
      simplified,
      if (words.length > 1) words.take(2).join(' '),
      if (words.length > 2) words.take(3).join(' '),
      '$simplified slot',
      'play $simplified',
    };
    return AssistantEntity(
      id: 'game_${g.id}',
      type: 'GAME',
      name: g.title,
      aliases: aliases.toList(),
      description: 'a ${g.category.title.toLowerCase()} game by ${g.provider}.',
      category: 'Casino',
      route: 'game:${g.id}',
      keywords: [...words.where((w) => w.length > 3), g.provider.toLowerCase()],
    );
  }
}
