import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../widgets/match_card.dart';
import '../widgets/live_pitch_tracker.dart';
import '../widgets/user_quick_resume_section.dart';

class SportsbookView extends StatelessWidget {
  final AppState state;

  const SportsbookView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final events = state.filteredEvents;

    // Group events by league
    final Map<String, List<SportEvent>> grouped = {};
    for (final e in events) {
      if (!grouped.containsKey(e.league)) {
        grouped[e.league] = [];
      }
      grouped[e.league]!.add(e);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 80),
        children: [
          // Promotional Banner Carousel
          _buildPromoBanner(context, isDark),

          // User Quick Resume (Continue Playing & Betting after login)
          if (state.isLoggedIn)
            UserQuickResumeSection(state: state),

          // Time Filter Chips (All, Today, Tomorrow, 3h, Weekend)
          _buildTimeFilters(isDark),

          // Sports Horizontal Categories
          _buildSportChips(isDark),

          const SizedBox(height: 6),

          // Search indicator if search is active
          if (state.searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Results for: "${state.searchQuery}"',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => state.setSearchQuery(''),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: PskColors.brandBlueLight, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Empty state or Grouped Match Cards
          if (events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 12),
                    const Text('No events matching selected filter', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            )
          else
            ...grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // League Section Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 14,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: PskColors.accentGold,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.key.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${entry.value.length} matches',
                          style: const TextStyle(fontSize: 11, color: PskColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  // Match Cards in this league
                  ...entry.value.map((e) {
                    return MatchCard(
                      event: e,
                      state: state,
                      onOpenTracker: () => LivePitchTracker.show(context, e),
                    );
                  }),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPromoBanner(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      constraints: const BoxConstraints(minHeight: 88),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F3A8A), Color(0xFF1752BF), Color(0xFF1B2A4A)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: PskColors.accentGold,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'WELCOME BONUS',
                    style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '100% Up to 100€ + Free Spins!',
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Register and play with PSK Advantage (2UP).',
                  style: TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => state.setTopTabIndex(PskTab.promos),
            style: ElevatedButton.styleFrom(
              backgroundColor: PskColors.accentGold,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
            ),
            child: const Text('CLAIM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeFilters(bool isDark) {
    final filters = ['All', 'Today', 'Tomorrow', '3h', 'Weekend'];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: filters.length,
        itemBuilder: (context, idx) {
          final f = filters[idx];
          final isSel = state.timeFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(f),
              selected: isSel,
              onSelected: (_) => state.setTimeFilter(f),
              selectedColor: PskColors.brandBlue,
              backgroundColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.white : (isDark ? PskColors.textGray : Colors.black87),
              ),
              visualDensity: const VisualDensity(horizontal: -2, vertical: -3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportChips(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: SportType.values.length,
        itemBuilder: (context, idx) {
          final s = SportType.values[idx];
          final isSel = state.selectedSport == s;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.icon, style: const TextStyle(fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(s.title),
                ],
              ),
              selected: isSel,
              onSelected: (_) => state.setSport(s),
              selectedColor: PskColors.brandBlue,
              backgroundColor: isDark ? PskColors.surfaceDark : Colors.white,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.white : (isDark ? PskColors.textMuted : PskColors.textDarkSecondary),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              side: BorderSide(
                color: isSel ? PskColors.brandBlueLight : (isDark ? PskColors.borderDark : PskColors.borderLight),
              ),
            ),
          );
        },
      ),
    );
  }
}
