import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../widgets/match_card.dart';
import '../widgets/live_pitch_tracker.dart';

class LiveView extends StatelessWidget {
  final AppState state;

  const LiveView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final liveEvents = state.liveEvents;
    final isDark = state.isDarkMode;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Live Header Banner
        Container(
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? PskColors.surfaceDarkPanel : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PskColors.alertRed.withValues(alpha: 0.6)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: PskColors.alertRed,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'LIVE BETTING',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 24),
                Text(
                  '${liveEvents.length} events in play',
                  style: const TextStyle(color: PskColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ),

        // Live Matches
        if (liveEvents.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No live matches currently in play.'),
            ),
          )
        else
          ...liveEvents.map((e) {
            return MatchCard(
              event: e,
              state: state,
              onOpenTracker: () => LivePitchTracker.show(context, e),
            );
          }),
      ],
    );
  }
}
