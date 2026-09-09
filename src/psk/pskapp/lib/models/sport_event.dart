enum SportType {
  football('Football', '⚽'),
  basketball('Basketball', '🏀'),
  tennis('Tennis', '🎾'),
  hockey('Hockey', '🏒'),
  handball('Handball', '🤾'),
  esport('E-Sports', '🎮'),
  volleyball('Volleyball', '🏐'),
  darts('Darts', '🎯'),
  waterPolo('Water Polo', '🤽');

  final String title;
  final String icon;
  const SportType(this.title, this.icon);
}

class OddOption {
  final String id;
  final String label; // "1", "X", "2", "1X", "X2", "12", ">2.5", "<2.5"
  final double value;
  final double? previousValue; // to indicate odds rising/falling

  const OddOption({
    required this.id,
    required this.label,
    required this.value,
    this.previousValue,
  });

  bool get isTrendingUp => previousValue != null && value > previousValue!;
  bool get isTrendingDown => previousValue != null && value < previousValue!;

  OddOption copyWith({double? value, double? previousValue}) {
    return OddOption(
      id: id,
      label: label,
      value: value ?? this.value,
      previousValue: previousValue ?? this.previousValue,
    );
  }
}

class Market {
  final String name; // "Match Winner", "Total Goals", "Both Teams to Score"
  final List<OddOption> options;

  const Market({required this.name, required this.options});
}

class SportEvent {
  final String id;
  final String league; // "SuperSport HNL", "Champions League", "Premier League"
  final String leagueCountry; // "Croatia", "Europe", "England"
  final SportType sport;
  final String homeTeam;
  final String awayTeam;
  final String startTime; // "Today 18:00" or "Tomorrow 21:00"
  final bool isLive;
  final String? liveMinute; // "68'"
  final int? homeScore;
  final int? awayScore;
  final List<OddOption> mainOdds; // 1, X, 2 (or 1, 2 for tennis)
  final List<Market> extraMarkets;
  final int extraMarketsCount;
  final bool hasBetBuilder;
  final bool hasPskPrednost;
  final bool hasFavoritPlus;

  const SportEvent({
    required this.id,
    required this.league,
    required this.leagueCountry,
    required this.sport,
    required this.homeTeam,
    required this.awayTeam,
    required this.startTime,
    this.isLive = false,
    this.liveMinute,
    this.homeScore,
    this.awayScore,
    required this.mainOdds,
    this.extraMarkets = const [],
    this.extraMarketsCount = 142,
    this.hasBetBuilder = true,
    this.hasPskPrednost = true,
    this.hasFavoritPlus = false,
  });

  SportEvent copyWith({
    String? liveMinute,
    int? homeScore,
    int? awayScore,
    List<OddOption>? mainOdds,
    bool? isLive,
  }) {
    return SportEvent(
      id: id,
      league: league,
      leagueCountry: leagueCountry,
      sport: sport,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      startTime: startTime,
      isLive: isLive ?? this.isLive,
      liveMinute: liveMinute ?? this.liveMinute,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      mainOdds: mainOdds ?? this.mainOdds,
      extraMarkets: extraMarkets,
      extraMarketsCount: extraMarketsCount,
      hasBetBuilder: hasBetBuilder,
      hasPskPrednost: hasPskPrednost,
      hasFavoritPlus: hasFavoritPlus,
    );
  }
}
