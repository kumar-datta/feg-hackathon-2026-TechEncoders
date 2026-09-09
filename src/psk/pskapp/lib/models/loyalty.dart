/// One line in the Champions Club points ledger.
class LoyaltyEntry {
  final DateTime date;
  final String action;
  final int points;

  const LoyaltyEntry({required this.date, required this.action, required this.points});

  Map<String, dynamic> toJson() => {'date': date.toIso8601String(), 'action': action, 'points': points};

  factory LoyaltyEntry.fromJson(Map<String, dynamic> j) => LoyaltyEntry(
        date: DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now(),
        action: j['action'] as String? ?? '',
        points: (j['points'] as num?)?.toInt() ?? 0,
      );
}
