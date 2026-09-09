enum BetSlipType {
  single('Single'), // Solo
  accumulator('Accumulator'), // AKO
  system('System'); // Maxicombi

  final String title;
  const BetSlipType(this.title);
}

class BetSelection {
  final String eventId;
  final String homeTeam;
  final String awayTeam;
  final String league;
  final String marketName; // e.g. "Match Winner"
  final String selectionLabel; // e.g. "1", "X", "2"
  final double oddValue;
  final bool isLive;

  const BetSelection({
    required this.eventId,
    required this.homeTeam,
    required this.awayTeam,
    required this.league,
    required this.marketName,
    required this.selectionLabel,
    required this.oddValue,
    this.isLive = false,
  });

  String get id => '$eventId-$marketName-$selectionLabel';
}

class BetSlipModel {
  final List<BetSelection> selections;
  final double stake;
  final BetSlipType type;

  const BetSlipModel({
    this.selections = const [],
    this.stake = 2.0,
    this.type = BetSlipType.accumulator,
  });

  int get count => selections.length;
  bool get isEmpty => selections.isEmpty;
  bool get isNotEmpty => selections.isNotEmpty;

  double get totalOdds {
    if (selections.isEmpty) return 0.0;
    double product = 1.0;
    for (final s in selections) {
      product *= s.oddValue;
    }
    return double.parse(product.toStringAsFixed(2));
  }

  /// Sportsbook processing fee (5% MT)
  double get mtFee => double.parse((stake * 0.05).toStringAsFixed(2));
  double get netStake => double.parse((stake - mtFee).toStringAsFixed(2));

  double get grossWin {
    if (selections.isEmpty) return 0.0;
    return double.parse((netStake * totalOdds).toStringAsFixed(2));
  }

  /// Estimated tax deduction (10% on winnings above stake)
  double get estimatedTax {
    final profit = grossWin - stake;
    if (profit <= 0) return 0.0;
    return double.parse((profit * 0.10).toStringAsFixed(2));
  }

  double get potentialWin {
    if (selections.isEmpty) return 0.0;
    final win = grossWin - estimatedTax;
    return double.parse(win.toStringAsFixed(2));
  }

  BetSlipModel copyWith({
    List<BetSelection>? selections,
    double? stake,
    BetSlipType? type,
  }) {
    return BetSlipModel(
      selections: selections ?? this.selections,
      stake: stake ?? this.stake,
      type: type ?? this.type,
    );
  }
}
