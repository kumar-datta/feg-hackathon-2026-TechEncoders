enum StreakRewardType { bonusCash, freeSpins }

class StreakReward {
  final int day; // 1..7, position in the repeating weekly cycle
  final StreakRewardType type;
  final double amount; // € for bonusCash, spin count for freeSpins
  final String label;
  final String icon;

  const StreakReward({
    required this.day,
    required this.type,
    required this.amount,
    required this.label,
    required this.icon,
  });
}

/// The 7-day PSK Pulse streak reward cycle. Escalates through the week and
/// loops — day 8 is day 1's reward again, etc.
class DailyStreakRewards {
  DailyStreakRewards._();

  static const List<StreakReward> cycle = [
    StreakReward(day: 1, type: StreakRewardType.bonusCash, amount: 1.0, label: '€1 Bonus', icon: '🎁'),
    StreakReward(day: 2, type: StreakRewardType.bonusCash, amount: 2.0, label: '€2 Bonus', icon: '🎁'),
    StreakReward(day: 3, type: StreakRewardType.freeSpins, amount: 5, label: '5 Free Spins', icon: '🎰'),
    StreakReward(day: 4, type: StreakRewardType.bonusCash, amount: 5.0, label: '€5 Bonus', icon: '🎁'),
    StreakReward(day: 5, type: StreakRewardType.freeSpins, amount: 10, label: '10 Free Spins', icon: '🎰'),
    StreakReward(day: 6, type: StreakRewardType.bonusCash, amount: 10.0, label: '€10 Bonus', icon: '🎁'),
    StreakReward(day: 7, type: StreakRewardType.bonusCash, amount: 20.0, label: '€20 Mega Bonus', icon: '🏆'),
  ];

  /// [streakCount] is the 1-based streak length after (or about to be after)
  /// a claim. Maps it onto the 7-day cycle.
  static StreakReward forStreakCount(int streakCount) {
    final dayInCycle = ((streakCount - 1) % cycle.length) + 1;
    return cycle.firstWhere((r) => r.day == dayInCycle);
  }
}
