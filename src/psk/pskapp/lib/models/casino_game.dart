enum CasinoCategory {
  popular('Popular', '🔥'),
  newGames('New', '✨'),
  jackpot('Jackpot', '💎'),
  slots('Slots', '🎰'),
  tableGames('Table Games', '🎲'),
  megaways('Megaways', '⚡');

  final String title;
  final String icon;
  const CasinoCategory(this.title, this.icon);
}

/// Which playable engine a game launches into. Mirrors the website's
/// `engine` field, which also decides which demo clip previews the tile.
enum GameEngine {
  slot('slot'),
  roulette('roulette'),
  blackjack('blackjack'),
  baccarat('baccarat'),
  crash('crash'),
  mines('mines'),
  dice('dice'),
  wheel('wheel');

  final String slug;
  const GameEngine(this.slug);
}

enum GameVolatility {
  low('Low'),
  medium('Medium'),
  high('High');

  final String label;
  const GameVolatility(this.label);
}

class CasinoGame {
  final String id;
  final String title;
  final String provider; // "Pragmatic Play", "EGT Digital", "Novomatic", "Playtech", "Fazi"
  final CasinoCategory category;
  final String imageUrl;
  final bool hasJackpot;
  final double? jackpotAmount;
  final bool isNew;
  final bool isExclusive;
  final String badge;

  const CasinoGame({
    required this.id,
    required this.title,
    required this.provider,
    required this.category,
    required this.imageUrl,
    this.hasJackpot = false,
    this.jackpotAmount,
    this.isNew = false,
    this.isExclusive = false,
    this.badge = '',
  });

  // ------------------------------------------------------------------
  // Derived metadata (the website stores these per game; here they are
  // derived deterministically from the id so the catalogue stays const).
  // ------------------------------------------------------------------

  int get _seed {
    var h = 2166136261;
    for (final c in id.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h;
  }

  GameEngine get engine {
    final t = title.toLowerCase();
    if (category == CasinoCategory.tableGames) {
      if (t.contains('roulette')) return GameEngine.roulette;
      if (t.contains('baccarat')) return GameEngine.baccarat;
      if (t.contains('blackjack') || t.contains('poker') || t.contains("hold'em")) return GameEngine.blackjack;
    }
    return GameEngine.slot;
  }

  bool get isTableGame => engine != GameEngine.slot;

  String get emoji => switch (engine) {
        GameEngine.roulette => '🎡',
        GameEngine.blackjack => '🃏',
        GameEngine.baccarat => '🂡',
        GameEngine.crash => '🚀',
        GameEngine.mines => '💣',
        GameEngine.dice => '🎲',
        GameEngine.wheel => '🎯',
        GameEngine.slot => '🎰',
      };

  /// Return-to-player, 94.0–97.5 %.
  double get rtp => isTableGame ? 97.3 : 94.0 + ((_seed >> 3) % 36) / 10.0;

  GameVolatility get volatility => GameVolatility.values[(_seed >> 7) % 3];

  int get lines => switch (engine) {
        GameEngine.slot => const [5, 10, 20, 25, 40][(_seed >> 5) % 5],
        _ => 0,
      };

  double get minBet => isTableGame ? 1.0 : const [0.10, 0.20, 0.25, 0.50][(_seed >> 9) % 4];
  double get maxBet => isTableGame ? 500.0 : const [50.0, 100.0, 200.0, 250.0][(_seed >> 11) % 4];

  /// Two hues drive the gradient behind the artwork, exactly like the website.
  int get hueA => _seed % 360;
  int get hueB => (hueA + 40 + (_seed >> 13) % 60) % 360;

  /// Live tables show a fake table occupancy.
  int get players => isTableGame ? 12 + (_seed >> 4) % 140 : 0;
}
