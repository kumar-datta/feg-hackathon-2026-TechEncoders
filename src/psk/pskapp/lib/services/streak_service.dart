import 'package:shared_preferences/shared_preferences.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastClaimDate;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastClaimDate,
  });
}

/// Persists the daily-streak state across app restarts so "daily" actually
/// means something. Local-device only — this demo has no backend account,
/// so the streak lives per-install rather than per-login.
class StreakService {
  StreakService._();

  static const _keyCurrentStreak = 'psk_streak_current';
  static const _keyLongestStreak = 'psk_streak_longest';
  static const _keyLastClaimDate = 'psk_streak_last_claim_date';

  static Future<StreakData> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lastClaimIso = prefs.getString(_keyLastClaimDate);
    return StreakData(
      currentStreak: prefs.getInt(_keyCurrentStreak) ?? 0,
      longestStreak: prefs.getInt(_keyLongestStreak) ?? 0,
      lastClaimDate: lastClaimIso != null ? DateTime.tryParse(lastClaimIso) : null,
    );
  }

  static Future<void> save(StreakData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCurrentStreak, data.currentStreak);
    await prefs.setInt(_keyLongestStreak, data.longestStreak);
    if (data.lastClaimDate != null) {
      await prefs.setString(_keyLastClaimDate, data.lastClaimDate!.toIso8601String());
    }
  }
}
