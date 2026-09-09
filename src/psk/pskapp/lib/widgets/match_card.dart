import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../models/sport_event.dart';
import '../state/app_state.dart';

class MatchCard extends StatefulWidget {
  final SportEvent event;
  final AppState state;
  final VoidCallback? onOpenTracker;

  const MatchCard({
    super.key,
    required this.event,
    required this.state,
    this.onOpenTracker,
  });

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final state = widget.state;
    final isDark = state.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : PskColors.surfaceLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? PskColors.borderDark : PskColors.borderLight,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: League & Time/Live badge
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Icon(
                  event.sport == SportType.football
                      ? Icons.sports_soccer
                      : (event.sport == SportType.basketball
                          ? Icons.sports_basketball
                          : Icons.sports_tennis),
                  size: 14,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${event.leagueCountry} • ${event.league}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (event.isLive) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: PskColors.alertRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, size: 6, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          event.liveMinute ?? 'LIVE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    event.startTime,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Teams & Score
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Home Team
                      Row(
                        children: [
                          _buildTeamBadge(event.homeTeam),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.homeTeam,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.isLive && event.homeScore != null)
                            Text(
                              '${event.homeScore}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: PskColors.accentGold,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Away Team
                      Row(
                        children: [
                          _buildTeamBadge(event.awayTeam),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.awayTeam,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.isLive && event.awayScore != null)
                            Text(
                              '${event.awayScore}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: PskColors.accentGold,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main Odds Buttons Row (1, X, 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: event.mainOdds.map((odd) {
                final isSelected = state.isOddSelected(
                  event.id,
                  'Match Winner',
                  odd.label,
                );

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: _buildOddButton(
                      label: odd.label,
                      value: odd.value,
                      isSelected: isSelected,
                      isUp: odd.isTrendingUp,
                      isDown: odd.isTrendingDown,
                      onTap: () {
                        state.toggleOdd(event, 'Match Winner', odd);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Extra Markets expanded list
          if (_isExpanded && event.extraMarkets.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1),
            ...event.extraMarkets.map((market) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      market.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: market.options.map((opt) {
                        final isSel = state.isOddSelected(event.id, market.name, opt.label);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: _buildOddButton(
                              label: opt.label,
                              value: opt.value,
                              isSelected: isSel,
                              onTap: () {
                                state.toggleOdd(event, market.name, opt);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }),
          ],

          // Footer: Badges & Expand action
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (event.hasBetBuilder) ...[
                          _buildFeatureBadge('BB', 'BetBuilder', PskColors.brandBlue),
                          const SizedBox(width: 5),
                        ],
                        if (event.hasPskPrednost) ...[
                          _buildFeatureBadge('2UP', 'PSK Advantage', PskColors.liveGreen),
                          const SizedBox(width: 5),
                        ],
                        if (event.hasFavoritPlus) ...[
                          _buildFeatureBadge('FP', 'Favorite Plus', PskColors.warningOrange),
                          const SizedBox(width: 5),
                        ],
                        if (event.isLive && widget.onOpenTracker != null) ...[
                          InkWell(
                            onTap: widget.onOpenTracker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: PskColors.brandBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.stadium, size: 12, color: PskColors.brandBlueLight),
                                  SizedBox(width: 3),
                                  Text(
                                    'Pitch',
                                    style: TextStyle(fontSize: 10, color: PskColors.brandBlueLight, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          '+${event.extraMarketsCount}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: PskColors.brandBlueLight,
                          ),
                        ),
                        Icon(
                          _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          size: 16,
                          color: PskColors.brandBlueLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamBadge(String teamName) {
    Color color = PskColors.brandBlue;
    if (teamName.contains('Dinamo')) color = const Color(0xFF003B94);
    if (teamName.contains('Hajduk')) color = const Color(0xFFC8102E);
    if (teamName.contains('Rijeka')) color = const Color(0xFF009EE0);
    if (teamName.contains('Osijek')) color = const Color(0xFF005BAA);
    if (teamName.contains('Real')) color = const Color(0xFFEE8A00);
    if (teamName.contains('City')) color = const Color(0xFF6CABDD);

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        teamName.isNotEmpty ? teamName[0] : '',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOddButton({
    required String label,
    required double value,
    required bool isSelected,
    required VoidCallback onTap,
    bool isUp = false,
    bool isDown = false,
  }) {
    final isDark = widget.state.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? PskColors.brandBlue
              : (isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? PskColors.brandBlueLight
                : (isDark ? Colors.white10 : Colors.black12),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? Colors.white70
                    : (isDark ? PskColors.textMuted : PskColors.textDarkSecondary),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? PskColors.accentGold
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (isUp)
                    const Icon(Icons.arrow_drop_up, size: 14, color: PskColors.moneyGreen),
                  if (isDown)
                    const Icon(Icons.arrow_drop_down, size: 14, color: PskColors.alertRed),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String code, String tooltip, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.8),
      ),
      child: Text(
        code,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
