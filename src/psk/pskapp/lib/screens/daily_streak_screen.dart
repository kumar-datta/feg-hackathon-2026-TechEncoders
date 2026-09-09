import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../models/daily_streak.dart';
import '../widgets/auth_dialog.dart';

/// PSK Pulse Daily Streak — a login perk that escalates over a 7-day cycle.
/// Pauses entirely under self-exclusion, same as the home-screen widgets:
/// engagement mechanics in a betting app get the same guardrail, not a pass.
class DailyStreakScreen extends StatelessWidget {
  final AppState state;

  const DailyStreakScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final isDark = state.isDarkMode;
        final cardColor = isDark ? PskColors.surfaceDark : Colors.white;
        final borderColor = isDark ? PskColors.borderDark : PskColors.borderLight;
        final streak = state.currentStreak;
        final currentDayInCycle = streak == 0 ? 0 : ((streak - 1) % DailyStreakRewards.cycle.length) + 1;
        final nextReward = state.nextStreakReward;

        return Scaffold(
          backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
          appBar: AppBar(
            backgroundColor: isDark ? PskColors.bgDarkSecondary : PskColors.brandBlue,
            foregroundColor: Colors.white,
            title: const Text('Daily Streak', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // Hero: streak count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [PskColors.bgDarkSecondary, PskColors.surfaceDarkPanel]
                        : [PskColors.brandBlue, PskColors.brandBlueHover],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(streak > 0 ? '🔥' : '💤', style: const TextStyle(fontSize: 36)),
                    const SizedBox(height: 6),
                    Text(
                      '$streak-day streak',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Longest streak: ${state.longestStreak} days · ${state.bonusSpins} bonus spins banked',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'THIS WEEK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: DailyStreakRewards.cycle.map((reward) {
                  final isDone = reward.day <= currentDayInCycle && streak > 0;
                  final isNext = !state.claimedToday && reward.day == nextReward.day;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _DayPill(reward: reward, isDone: isDone, isNext: isNext, isDark: isDark),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              if (state.selfExcluded)
                _infoCard(
                  cardColor: cardColor,
                  borderColor: PskColors.alertRed,
                  icon: Icons.shield,
                  iconColor: PskColors.alertRed,
                  title: 'Daily rewards are paused',
                  body:
                      "Self-exclusion is active on your account, so streak rewards won't be offered "
                      'until it ends. Your streak history is kept, not reset.',
                )
              else if (!state.isLoggedIn)
                Column(
                  children: [
                    _infoCard(
                      cardColor: cardColor,
                      borderColor: borderColor,
                      icon: Icons.login,
                      iconColor: PskColors.brandBlueLight,
                      title: 'Log in to start your streak',
                      body: 'Daily rewards are a perk for logged-in PSK accounts.',
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => AuthDialog.show(context, state, isRegister: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PskColors.accentGold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 46),
                      ),
                      child: const Text('Log in', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              else if (state.claimedToday)
                _infoCard(
                  cardColor: cardColor,
                  borderColor: PskColors.liveGreen,
                  icon: Icons.check_circle,
                  iconColor: PskColors.liveGreen,
                  title: 'Claimed for today',
                  body: 'Come back tomorrow to keep the streak going and unlock day '
                      '${((currentDayInCycle % DailyStreakRewards.cycle.length) + 1)}.',
                )
              else
                ElevatedButton(
                  onPressed: () => _claim(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PskColors.accentGold,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text(
                    'Claim Day ${nextReward.day} — ${nextReward.icon} ${nextReward.label}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _claim(BuildContext context) {
    final reward = state.claimDailyReward();
    if (reward == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${reward.icon} ${reward.label} claimed — day ${reward.day} of your streak!'),
        backgroundColor: PskColors.liveGreen,
      ),
    );
  }

  Widget _infoCard({
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String body,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(body, style: const TextStyle(fontSize: 11, color: PskColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  final StreakReward reward;
  final bool isDone;
  final bool isNext;
  final bool isDark;

  const _DayPill({required this.reward, required this.isDone, required this.isNext, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = isDone
        ? PskColors.liveGreen.withValues(alpha: 0.18)
        : (isDark ? PskColors.surfaceDark : Colors.white);
    final border = isNext
        ? PskColors.accentGold
        : (isDone ? PskColors.liveGreen : (isDark ? PskColors.borderDark : PskColors.borderLight));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: isNext ? 2 : 1),
      ),
      child: Column(
        children: [
          Text('D${reward.day}', style: const TextStyle(fontSize: 10, color: PskColors.textMuted)),
          const SizedBox(height: 4),
          Text(reward.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          if (isDone)
            const Icon(Icons.check, size: 12, color: PskColors.liveGreen)
          else
            Text(
              reward.type == StreakRewardType.freeSpins ? '${reward.amount.toInt()}sp' : '€${reward.amount.toInt()}',
              style: const TextStyle(fontSize: 9, color: PskColors.textMuted),
            ),
        ],
      ),
    );
  }
}
