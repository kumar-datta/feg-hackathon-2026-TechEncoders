import 'package:flutter/material.dart';
import '../models/played_game_log.dart';
import '../models/casino_game.dart';
import '../models/demo_user.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import 'casino/slot_game_screen.dart';
import 'casino/blackjack_game_screen.dart';
import 'casino/roulette_game_screen.dart';

/// PSK Game Activity & Round-by-Round Audit Log Screen.
/// Displays played casino and slot sessions for active demo accounts,
/// summary statistics (turnover, payout, profit, win rate), category filters,
/// detailed audit logs, and an instant "Play Again" launcher.
class GameHistoryScreen extends StatefulWidget {
  final AppState state;

  const GameHistoryScreen({super.key, required this.state});

  @override
  State<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends State<GameHistoryScreen> {
  String _selectedCategory = 'All';
  final Set<String> _expandedLogIds = {};

  final List<String> _categories = [
    'All',
    'Slots',
    'Table Games',
    'Blackjack',
    'Roulette',
    'Virtuals',
  ];

  List<PlayedGameLog> _filterLogs(List<PlayedGameLog> logs) {
    if (_selectedCategory == 'All') return logs;
    return logs.where((log) {
      final cat = log.category.toLowerCase();
      final title = log.gameTitle.toLowerCase();
      final id = log.gameId.toLowerCase();

      switch (_selectedCategory) {
        case 'Slots':
          return cat.contains('slot') || title.contains('slot');
        case 'Table Games':
          return cat.contains('table') || cat.contains('live');
        case 'Blackjack':
          return title.contains('blackjack') || id.contains('blackjack');
        case 'Roulette':
          return title.contains('roulette') || id.contains('roulette');
        case 'Virtuals':
          return cat.contains('virtual') || title.contains('virtual') || id.contains('derby');
        default:
          return true;
      }
    }).toList();
  }

  void _launchGame(PlayedGameLog log) {
    // 1. Locate game in app state or build fallback
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
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _showDemoProfilePicker() {
    final isDark = widget.state.isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? PskColors.bgDarkSecondary : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'SELECT DEMO PROFILE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? Colors.white : PskColors.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...DemoUserProfile.demoProfiles.map((profile) {
                  final isCurrent = widget.state.isLoggedIn && widget.state.username == profile.username;
                  return ListTile(
                    dense: true,
                    leading: Text(profile.avatar, style: const TextStyle(fontSize: 22)),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.username,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isCurrent ? PskColors.accentGold : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: PskColors.moneyGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${profile.startingBalance.toStringAsFixed(0)} €',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: PskColors.moneyGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      '${profile.badge} • ${profile.recentGames.length} games logged',
                      style: const TextStyle(fontSize: 11, color: PskColors.textMuted),
                    ),
                    trailing: isCurrent
                        ? const Icon(Icons.check_circle, color: PskColors.liveGreen, size: 20)
                        : const Icon(Icons.arrow_forward_ios, size: 14, color: PskColors.textMuted),
                    onTap: () {
                      widget.state.loginAsDemo(profile);
                      Navigator.pop(ctx);
                      setState(() {});
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.state,
      builder: (context, _) {
        final isDark = widget.state.isDarkMode;
        final allLogs = widget.state.gameHistory;
        final filteredLogs = _filterLogs(allLogs);

        // Compute aggregated metrics
        final totalGames = allLogs.length;
        final totalStaked = allLogs.fold<double>(0.0, (s, g) => s + g.stake);
        final totalWon = allLogs.fold<double>(0.0, (s, g) => s + g.winAmount);
        final netProfit = totalWon - totalStaked;
        final totalRounds = allLogs.fold<int>(0, (s, g) => s + g.roundsPlayed);
        final winRate = totalGames > 0
            ? (allLogs.where((g) => g.isWin).length / totalGames * 100)
            : 0.0;

        return Scaffold(
          backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
          appBar: AppBar(
            backgroundColor: isDark ? PskColors.bgDarkSecondary : PskColors.brandBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            title: const FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Game Activity & Logs',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              TextButton.icon(
                onPressed: _showDemoProfilePicker,
                icon: const Icon(Icons.switch_account, color: PskColors.accentGold, size: 16),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.state.isLoggedIn ? widget.state.username : 'Switch Demo',
                    style: const TextStyle(
                      color: PskColors.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          body: Column(
            children: [
              // Hero Summary Stats Header
              _buildStatsDashboard(
                isDark: isDark,
                totalGames: totalGames,
                totalRounds: totalRounds,
                totalStaked: totalStaked,
                totalWon: totalWon,
                netProfit: netProfit,
                winRate: winRate,
              ),

              // Filter Chips Bar
              _buildCategoryChips(allLogs, isDark),

              // Game Logs List
              Expanded(
                child: filteredLogs.isEmpty
                    ? _buildEmptyState(isDark)
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemCount: filteredLogs.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final log = filteredLogs[index];
                          final isExpanded = _expandedLogIds.contains(log.id);
                          return _buildGameLogCard(log, isExpanded, isDark);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsDashboard({
    required bool isDark,
    required int totalGames,
    required int totalRounds,
    required double totalStaked,
    required double totalWon,
    required double netProfit,
    required double winRate,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? PskColors.borderDark : PskColors.borderLight,
          ),
        ),
      ),
      child: Column(
        children: [
          // Active User Cluster
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.state.userAvatar,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.state.username,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : PskColors.textDark,
                            ),
                          ),
                          Text(
                            widget.state.userBadge,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: PskColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Net Profit Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (netProfit >= 0 ? PskColors.moneyGreen : PskColors.alertRed)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: (netProfit >= 0 ? PskColors.moneyGreen : PskColors.alertRed)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        netProfit >= 0 ? Icons.trending_up : Icons.trending_down,
                        size: 13,
                        color: netProfit >= 0 ? PskColors.moneyGreen : PskColors.alertRed,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Net: ${netProfit >= 0 ? '+' : ''}${netProfit.toStringAsFixed(2)} €',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: netProfit >= 0 ? PskColors.moneyGreen : PskColors.alertRed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 4 Metric Tiles
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'SESSIONS / ROUNDS',
                  value: '$totalGames / $totalRounds',
                  isDark: isDark,
                  color: isDark ? Colors.white : PskColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL STAKED',
                  value: '${totalStaked.toStringAsFixed(2)} €',
                  isDark: isDark,
                  color: isDark ? Colors.white70 : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricTile(
                  label: 'TOTAL WON',
                  value: '${totalWon.toStringAsFixed(2)} €',
                  isDark: isDark,
                  color: PskColors.moneyGreen,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildMetricTile(
                  label: 'WIN RATE',
                  value: '${winRate.toStringAsFixed(0)}%',
                  isDark: isDark,
                  color: winRate >= 50 ? PskColors.moneyGreen : PskColors.warningOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w600,
                color: PskColors.textMuted,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(List<PlayedGameLog> allLogs, bool isDark) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, idx) {
          final cat = _categories[idx];
          final isSelected = _selectedCategory == cat;
          final count = cat == 'All' ? allLogs.length : _filterLogs(allLogs).length;

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: InkWell(
              onTap: () {
                setState(() => _selectedCategory = cat);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? PskColors.brandBlue
                      : (isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? PskColors.brandBlueHover
                        : (isDark ? PskColors.borderDark : Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : PskColors.textDark),
                      ),
                    ),
                    if (count > 0) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : (isDark ? PskColors.surfaceDarkAction : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : PskColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGameLogCard(PlayedGameLog log, bool isExpanded, bool isDark) {
    final isWin = log.isWin;
    final isPush = log.isPush;

    Color profitColor = isWin
        ? PskColors.moneyGreen
        : isPush
            ? PskColors.textMuted
            : PskColors.alertRed;

    Color profitBg = isWin
        ? PskColors.moneyGreen.withValues(alpha: 0.12)
        : isPush
            ? Colors.grey.withValues(alpha: 0.12)
            : PskColors.alertRed.withValues(alpha: 0.12);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded
              ? (isDark ? PskColors.brandBlueLight.withValues(alpha: 0.4) : PskColors.brandBlue)
              : (isDark ? PskColors.borderDark : PskColors.borderLight),
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Info Row
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Game Icon Container
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? PskColors.borderDark : Colors.grey.shade300,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        log.gameIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Game Title & Provider
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  log.gameTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : PskColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  log.provider,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: PskColors.textMuted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text('•', style: TextStyle(fontSize: 10, color: PskColors.textMuted)),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  log.category,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? PskColors.brandBlueLight : PskColors.brandBlue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            log.formattedDate,
                            style: const TextStyle(
                              fontSize: 10,
                              color: PskColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Profit Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: profitBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            log.formattedProfit,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: profitColor,
                            ),
                          ),
                          Text(
                            isWin ? 'PROFIT' : isPush ? 'PUSH' : 'LOSS',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: profitColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Financial breakdown row (Stake / Won / Rounds)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Text('Stake: ', style: TextStyle(fontSize: 11, color: PskColors.textMuted)),
                              Text(
                                '${log.stake.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white70 : PskColors.textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 12, color: Colors.grey.withValues(alpha: 0.3)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              const Text(' Payout: ', style: TextStyle(fontSize: 11, color: PskColors.textMuted)),
                              Text(
                                '${log.winAmount.toStringAsFixed(2)} €',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isWin ? PskColors.moneyGreen : (isDark ? Colors.white70 : PskColors.textDark),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(width: 1, height: 12, color: Colors.grey.withValues(alpha: 0.3)),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${log.roundsPlayed} ${log.roundsPlayed == 1 ? 'round' : 'rounds'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: PskColors.accentGold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Summary sentence
                Text(
                  log.summary,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : PskColors.textDark,
                  ),
                ),

                const SizedBox(height: 10),

                // Buttons: Expand Audit Log & Play Again
                Row(
                  children: [
                    // Expand/Collapse Toggle Button
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (isExpanded) {
                              _expandedLogIds.remove(log.id);
                            } else {
                              _expandedLogIds.add(log.id);
                            }
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isExpanded ? Icons.expand_less : Icons.expand_more,
                                  size: 16,
                                  color: isDark ? Colors.white70 : PskColors.textDarkSecondary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isExpanded ? 'Hide Audit Log' : 'View Audit Log (${log.detailedLogs.length})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : PskColors.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // "Play Again" Button
                    InkWell(
                      onTap: () => _launchGame(log),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: PskColors.brandBlue,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_arrow, size: 16, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Play Again',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expandable Round-by-Round Audit Log
          if (isExpanded) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF16161D) : Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? PskColors.borderDark : Colors.grey.shade300,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.verified_outlined, size: 14, color: PskColors.accentGold),
                      SizedBox(width: 6),
                      Text(
                        'ROUND-BY-ROUND AUDIT TRAIL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: PskColors.accentGold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...log.detailedLogs.asMap().entries.map((entry) {
                    final roundIdx = entry.key + 1;
                    final logText = entry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '#$roundIdx',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white70 : PskColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              logText,
                              style: TextStyle(
                                fontSize: 11,
                                height: 1.35,
                                color: isDark ? Colors.white70 : PskColors.textDarkSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'No Games Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : PskColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _selectedCategory == 'All'
                  ? 'Switch to one of the demo profiles (e.g. Marko_VIP or Ana_SpinQueen) to view pre-loaded game logs and round history.'
                  : 'No games logged under the "$_selectedCategory" filter.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: PskColors.textMuted),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showDemoProfilePicker,
              icon: const Icon(Icons.switch_account, size: 16),
              label: const Text('Choose Demo Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: PskColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
