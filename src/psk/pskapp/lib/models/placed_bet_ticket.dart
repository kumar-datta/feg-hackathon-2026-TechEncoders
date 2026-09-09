import 'bet_slip_model.dart';

enum TicketStatus {
  inPlay('In Play'),
  won('Won'),
  lost('Lost'),
  cashedOut('Cashed Out');

  final String label;
  const TicketStatus(this.label);
}

enum LegOutcome {
  pending('Pending'),
  winning('Winning'),
  won('Won'),
  lost('Lost');

  final String label;
  const LegOutcome(this.label);
}

class PlacedBetLeg {
  final BetSelection selection;
  final LegOutcome outcome;
  final String? currentScore;
  final String? matchMinute;

  const PlacedBetLeg({
    required this.selection,
    this.outcome = LegOutcome.pending,
    this.currentScore,
    this.matchMinute,
  });

  PlacedBetLeg copyWith({
    LegOutcome? outcome,
    String? currentScore,
    String? matchMinute,
  }) {
    return PlacedBetLeg(
      selection: selection,
      outcome: outcome ?? this.outcome,
      currentScore: currentScore ?? this.currentScore,
      matchMinute: matchMinute ?? this.matchMinute,
    );
  }

  Map<String, dynamic> toJson() => {
    'eventId': selection.eventId,
    'homeTeam': selection.homeTeam,
    'awayTeam': selection.awayTeam,
    'league': selection.league,
    'marketName': selection.marketName,
    'selectionLabel': selection.selectionLabel,
    'oddValue': selection.oddValue,
    'isLive': selection.isLive,
    'outcome': outcome.name,
    'currentScore': currentScore,
    'matchMinute': matchMinute,
  };

  factory PlacedBetLeg.fromJson(Map<String, dynamic> json) {
    return PlacedBetLeg(
      selection: BetSelection(
        eventId: json['eventId'] as String? ?? '',
        homeTeam: json['homeTeam'] as String? ?? '',
        awayTeam: json['awayTeam'] as String? ?? '',
        league: json['league'] as String? ?? '',
        marketName: json['marketName'] as String? ?? 'Match Winner',
        selectionLabel: json['selectionLabel'] as String? ?? '1',
        oddValue: (json['oddValue'] as num?)?.toDouble() ?? 1.0,
        isLive: json['isLive'] as bool? ?? false,
      ),
      outcome: LegOutcome.values.firstWhere(
        (e) => e.name == json['outcome'],
        orElse: () => LegOutcome.pending,
      ),
      currentScore: json['currentScore'] as String?,
      matchMinute: json['matchMinute'] as String?,
    );
  }
}

class PlacedBetTicket {
  final String id;
  final DateTime placedAt;
  final double stake;
  final double totalOdds;
  final double potentialWin;
  final List<PlacedBetLeg> legs;
  final TicketStatus status;
  final double? cashedOutAmount;
  final DateTime? settledAt;

  const PlacedBetTicket({
    required this.id,
    required this.placedAt,
    required this.stake,
    required this.totalOdds,
    required this.potentialWin,
    required this.legs,
    this.status = TicketStatus.inPlay,
    this.cashedOutAmount,
    this.settledAt,
  });

  bool get isInPlay => status == TicketStatus.inPlay;
  bool get isSettled => status != TicketStatus.inPlay;

  /// Dynamic Cash-Out calculation based on elapsed minutes and legs winning.
  /// Standard sportsbook formula: base return discounted by remaining risk.
  double get currentCashOutValue {
    if (!isInPlay) return 0.0;
    
    // If any leg is explicitly lost, no cash out.
    if (legs.any((l) => l.outcome == LegOutcome.lost)) return 0.0;

    int winningCount = legs.where((l) => l.outcome == LegOutcome.winning || l.outcome == LegOutcome.won).length;
    double progressRatio = legs.isEmpty ? 1.0 : winningCount / legs.length;

    // Baseline cash-out scales with current progress
    double valuation = stake * 0.85 + (potentialWin - stake) * 0.70 * progressRatio;
    if (valuation > potentialWin * 0.95) valuation = potentialWin * 0.95;
    if (valuation < stake * 0.60) valuation = stake * 0.60;

    return double.parse(valuation.toStringAsFixed(2));
  }

  PlacedBetTicket copyWith({
    TicketStatus? status,
    double? cashedOutAmount,
    DateTime? settledAt,
    List<PlacedBetLeg>? legs,
  }) {
    return PlacedBetTicket(
      id: id,
      placedAt: placedAt,
      stake: stake,
      totalOdds: totalOdds,
      potentialWin: potentialWin,
      legs: legs ?? this.legs,
      status: status ?? this.status,
      cashedOutAmount: cashedOutAmount ?? this.cashedOutAmount,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'placedAt': placedAt.toIso8601String(),
    'stake': stake,
    'totalOdds': totalOdds,
    'potentialWin': potentialWin,
    'legs': legs.map((l) => l.toJson()).toList(),
    'status': status.name,
    'cashedOutAmount': cashedOutAmount,
    'settledAt': settledAt?.toIso8601String(),
  };

  factory PlacedBetTicket.fromJson(Map<String, dynamic> json) {
    return PlacedBetTicket(
      id: json['id'] as String? ?? 'HR-${DateTime.now().millisecondsSinceEpoch}',
      placedAt: DateTime.tryParse(json['placedAt'] as String? ?? '') ?? DateTime.now(),
      stake: (json['stake'] as num?)?.toDouble() ?? 2.0,
      totalOdds: (json['totalOdds'] as num?)?.toDouble() ?? 1.0,
      potentialWin: (json['potentialWin'] as num?)?.toDouble() ?? 2.0,
      legs: (json['legs'] as List<dynamic>?)
              ?.map((l) => PlacedBetLeg.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      status: TicketStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TicketStatus.inPlay,
      ),
      cashedOutAmount: (json['cashedOutAmount'] as num?)?.toDouble(),
      settledAt: json['settledAt'] != null ? DateTime.tryParse(json['settledAt'] as String) : null,
    );
  }
}
