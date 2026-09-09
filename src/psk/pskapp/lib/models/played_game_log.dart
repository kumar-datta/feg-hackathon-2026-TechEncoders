class PlayedGameLog {
  final String id;
  final String gameId;
  final String gameTitle;
  final String category;
  final String provider;
  final String gameIcon;
  final DateTime timestamp;
  final double stake;
  final double winAmount;
  final int roundsPlayed;
  final String summary;
  final List<String> detailedLogs;

  const PlayedGameLog({
    required this.id,
    required this.gameId,
    required this.gameTitle,
    required this.category,
    required this.provider,
    required this.gameIcon,
    required this.timestamp,
    required this.stake,
    required this.winAmount,
    required this.roundsPlayed,
    required this.summary,
    required this.detailedLogs,
  });

  bool get isWin => winAmount > stake;
  bool get isPush => (winAmount - stake).abs() < 0.01;
  double get netProfit => winAmount - stake;

  String get formattedProfit {
    if (netProfit > 0) {
      return '+${netProfit.toStringAsFixed(2)} €';
    } else if (netProfit < 0) {
      return '${netProfit.toStringAsFixed(2)} €';
    } else {
      return '0.00 € (Push)';
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return mins <= 1 ? 'Just now' : '$mins mins ago';
    } else if (diff.inHours < 24 && now.day == timestamp.day) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minute';
    } else if (diff.inDays <= 1) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return 'Yesterday, $hour:$minute';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year}';
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameId': gameId,
    'gameTitle': gameTitle,
    'category': category,
    'provider': provider,
    'gameIcon': gameIcon,
    'timestamp': timestamp.toIso8601String(),
    'stake': stake,
    'winAmount': winAmount,
    'roundsPlayed': roundsPlayed,
    'summary': summary,
    'detailedLogs': detailedLogs,
  };

  factory PlayedGameLog.fromJson(Map<String, dynamic> json) {
    return PlayedGameLog(
      id: json['id'] as String? ?? '',
      gameId: json['gameId'] as String? ?? '',
      gameTitle: json['gameTitle'] as String? ?? '',
      category: json['category'] as String? ?? 'Slots',
      provider: json['provider'] as String? ?? 'Playtech',
      gameIcon: json['gameIcon'] as String? ?? '🎰',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      stake: (json['stake'] as num?)?.toDouble() ?? 0.0,
      winAmount: (json['winAmount'] as num?)?.toDouble() ?? 0.0,
      roundsPlayed: json['roundsPlayed'] as int? ?? 1,
      summary: json['summary'] as String? ?? '',
      detailedLogs: (json['detailedLogs'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
