import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../models/played_game_log.dart';
import '../models/placed_bet_ticket.dart';
import '../models/casino_game.dart';
import '../navigation/psk_tabs.dart';
import '../screens/casino/slot_game_screen.dart';
import '../screens/casino/blackjack_game_screen.dart';
import '../screens/casino/roulette_game_screen.dart';
import '../screens/game_history_screen.dart';
import 'live_pitch_tracker.dart';

/// Interactive "Jump Back In / Continue Playing" section shown when a user is logged in.
/// Displays their recently played casino games, table games, and placed sports tickets,
/// enabling 1-tap re-play, re-betting, and live match tracking.
class UserQuickResumeSection extends StatefulWidget {
  final AppState state;
  final bool casinoOnly;

  const UserQuickResumeSection({
    super.key,
    required this.state,
    this.casinoOnly = false,
  });

  @override
  State<UserQuickResumeSection> createState() => _UserQuickResumeSectionState();
}

class _UserQuickResumeSectionState extends State<UserQuickResumeSection> {
  int _selectedFilter = 0; // 0 = All, 1 = Casino, 2 = Sports

  void _launchCasinoGame(PlayedGameLog log) {
    CasinoGame? targetGame = widget.state.casinoGames.where((g) {
      if (g.id.toLowerCase() == log.gameId.toLowerCase()) return true;
      if (log.gameId == 'psk_blackjack' && g.id == 'blackjack_vip') return true;
      return g.title.toLowerCase() == log.gameTitle.toLowerCase();
    }).firstOrNull;

    targetGame ??= CasinoGame(
      id: log.gameId,
      title: log.gameTitle,
      provider: log.provider,
      category: log.category.toLowerCase().contains('table')
          ? CasinoCategory.tableGames
          : CasinoCategory.slots,
      imageUrl: 'https://images.unsplash.com/photo-1518609878373-06d740f60d8b?w=400&q=80',
      badge: log.provider.toUpperCase(),
    );

    final titleLower = log.gameTitle.toLowerCase();
    final idLower = log.gameId.toLowerCase();

    // Check if it's Lottery or Virtuals
    if (log.category.toLowerCase() == 'lottery' || log.gameId.startsWith('loto_')) {
      widget.state.setTopTabIndex(PskTab.lotto);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to Lottery: ${log.gameTitle}'),
          backgroundColor: PskColors.brandBlue,
        ),
      );
      return;
    } else if (log.category.toLowerCase() == 'virtuals' || log.gameId.contains('virtual')) {
      widget.state.setTopTabIndex(PskTab.virtuals);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to Virtuals: ${log.gameTitle}'),
          backgroundColor: PskColors.brandBlue,
        ),
      );
      return;
    }

    Widget destination;
    if (titleLower.contains('blackjack') || idLower.contains('blackjack')) {
      destination = BlackjackGameScreen(
        game: targetGame,
        isDemo: !widget.state.isLoggedIn,
        state: widget.state,
      );
    } else if (titleLower.contains('roulette') || idLower.contains('roulette')) {
      destination = RouletteGameScreen(
        game: targetGame,
        isDemo: !widget.state.isLoggedIn,
        state: widget.state,
      );
    } else {
      destination = SlotGameScreen(
        game: targetGame,
        isDemo: !widget.state.isLoggedIn,
        state: widget.state,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  void _reBetTicket(PlacedBetTicket ticket) {
    final selections = ticket.legs.map((l) => l.selection).toList();
    widget.state.copyTicket(selections);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Loaded ${selections.length} selection${selections.length > 1 ? 's' : ''} into BetSlip!'),
        backgroundColor: PskColors.liveGreen,
      ),
    );
  }

  void _trackMatch(PlacedBetLeg leg) {
    final liveMatch = widget.state.events.where((e) => e.id == leg.selection.eventId).firstOrNull;
    if (liveMatch != null) {
      LivePitchTracker.show(context, liveMatch);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Match info: ${leg.selection.homeTeam} vs ${leg.selection.awayTeam}'),
          backgroundColor: PskColors.brandBlue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    if (!state.isLoggedIn) return const SizedBox.shrink();

    final isDark = state.isDarkMode;
    final games = state.gameHistory;
    final tickets = state.placedTickets;

    if (games.isEmpty && tickets.isEmpty) return const SizedBox.shrink();

    // Filter items according to tab
    final showCasino = widget.casinoOnly || _selectedFilter == 0 || _selectedFilter == 1;
    final showSports = !widget.casinoOnly && (_selectedFilter == 0 || _selectedFilter == 2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? PskColors.borderDark : PskColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header: User cluster & Jump Back In title
          Row(
            children: [
              Text(
                state.userAvatar,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'CONTINUE PLAYING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                        ),
                      ),
                    ),
                    Text(
                      'Welcome back, ${state.username}!',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : PskColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // View All History Link
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GameHistoryScreen(state: state)),
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'All Logs',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PskColors.brandBlueLight),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: PskColors.brandBlueLight),
                  ],
                ),
              ),
            ],
          ),

          // Filter chips (All / Casino / Sports)
          if (!widget.casinoOnly && tickets.isNotEmpty && games.isNotEmpty) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All (${games.length + tickets.length})', 0, isDark),
                  const SizedBox(width: 6),
                  _buildFilterChip('🎰 Casino (${games.length})', 1, isDark),
                  const SizedBox(width: 6),
                  _buildFilterChip('⚽ Sports (${tickets.length})', 2, isDark),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Horizontal Carousel of Quick Resume Cards
          SizedBox(
            height: 154,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Casino Game Cards
                if (showCasino)
                  ...games.take(6).map((log) => _buildCasinoCard(log, isDark)),

                // Sports Bet Cards
                if (showSports)
                  ...tickets.take(5).map((ticket) => _buildSportsCard(ticket, isDark)),

                // View All Activity End Tile
                _buildViewAllCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, bool isDark) {
    final isSelected = _selectedFilter == index;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = index),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? PskColors.brandBlue
              : (isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : PskColors.textDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCasinoCard(PlayedGameLog log, bool isDark) {
    final isWin = log.isWin;
    final isPush = log.isPush;

    final profitColor = isWin
        ? PskColors.moneyGreen
        : isPush
            ? PskColors.textMuted
            : PskColors.alertRed;

    return Container(
      width: 215,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? PskColors.borderDark : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Icon + Game Title & Profit Badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? PskColors.surfaceDarkAction : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(log.gameIcon, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.gameTitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : PskColors.textDark,
                      ),
                    ),
                    Text(
                      '${log.provider} • ${log.category}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: PskColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Middle: Performance & Last played
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: profitColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    log.formattedProfit,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: profitColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${log.roundsPlayed} rnds · ${log.formattedDate}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 9, color: PskColors.textMuted),
                ),
              ),
            ],
          ),

          // Bottom: 1-Tap "Play Again" Button
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton.icon(
              onPressed: () => _launchCasinoGame(log),
              icon: const Icon(Icons.play_arrow, size: 14),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Play Again',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: PskColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSportsCard(PlacedBetTicket ticket, bool isDark) {
    final leg = ticket.legs.firstOrNull;
    final isMulti = ticket.legs.length > 1;
    final isInPlay = ticket.isInPlay;
    final isWon = ticket.status == TicketStatus.won;

    final badgeColor = isWon
        ? PskColors.moneyGreen
        : isInPlay
            ? (leg?.selection.isLive == true ? PskColors.alertRed : PskColors.accentGold)
            : PskColors.textMuted;

    final title = isMulti
        ? '${ticket.legs.length}-Fold Ticket'
        : (leg != null ? '${leg.selection.homeTeam} vs ${leg.selection.awayTeam}' : 'Sports Bet');

    final subtitle = isMulti
        ? ticket.legs.map((l) => l.selection.homeTeam).join(', ')
        : (leg != null ? '${leg.selection.marketName}: ${leg.selection.selectionLabel} @ ${leg.selection.oddValue.toStringAsFixed(2)}' : '');

    return Container(
      width: 225,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? PskColors.borderDark : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: Sport Icon + Matchup + Status Badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? PskColors.surfaceDarkAction : Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('⚽', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : PskColors.textDark,
                      ),
                    ),
                    Text(
                      leg?.selection.league ?? 'Sportsbook',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: PskColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isWon ? 'WON' : isInPlay ? (leg?.currentScore != null ? leg!.currentScore! : 'IN PLAY') : ticket.status.label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),

          // Middle: Odds, Stake & Potential Win
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Stake: ${ticket.stake.toStringAsFixed(0)} €',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, color: PskColors.textMuted),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Win: ${ticket.potentialWin.toStringAsFixed(2)} €',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: PskColors.moneyGreen),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Bottom Action Row: Re-Bet & Live Tracker
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 30,
                  child: ElevatedButton.icon(
                    onPressed: () => _reBetTicket(ticket),
                    icon: const Icon(Icons.repeat, size: 12),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Re-Bet', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PskColors.accentGold,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ),
              ),
              if (leg != null) ...[
                const SizedBox(width: 6),
                SizedBox(
                  height: 30,
                  child: OutlinedButton(
                    onPressed: () => _trackMatch(leg),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark ? Colors.white : PskColors.brandBlue,
                      side: BorderSide(color: isDark ? PskColors.borderDark : Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Icon(Icons.sports_soccer, size: 14),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllCard(bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GameHistoryScreen(state: widget.state)),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? PskColors.borderDark : Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PskColors.brandBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.history_edu, color: PskColors.brandBlueLight, size: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'View All History',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              'Audit Logs',
              style: TextStyle(fontSize: 9, color: PskColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
