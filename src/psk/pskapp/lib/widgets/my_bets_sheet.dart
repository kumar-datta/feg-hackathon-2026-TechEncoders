import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/placed_bet_ticket.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';

class MyBetsSheet extends StatefulWidget {
  final AppState state;

  const MyBetsSheet({super.key, required this.state});

  static void show(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MyBetsSheet(state: state),
    );
  }

  @override
  State<MyBetsSheet> createState() => _MyBetsSheetState();
}

class _MyBetsSheetState extends State<MyBetsSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final bgColor = isDark ? PskColors.surfaceDark : PskColors.surfaceLight;
    final textColor = isDark ? PskColors.textWhite : PskColors.textDark;
    final mutedColor = isDark ? PskColors.textMuted : PskColors.textDarkSecondary;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final activeTickets = state.activeTickets;
        final settledTickets = state.settledTickets;

        return Container(
          height: MediaQuery.of(context).size.height * 0.88,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle drag bar
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: mutedColor.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, color: PskColors.brandBlue, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'MY BETS',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: textColor,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      color: mutedColor,
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFE5EDF7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: PskColors.brandBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: mutedColor,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: [
                    Tab(text: 'Active (${activeTickets.length})'),
                    Tab(text: 'Settled (${settledTickets.length})'),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTicketsList(activeTickets, isDark, true),
                    _buildTicketsList(settledTickets, isDark, false),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketsList(List<PlacedBetTicket> tickets, bool isDark, bool isActiveTab) {
    if (tickets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActiveTab ? Icons.sports_soccer : Icons.history,
                size: 64,
                color: isDark ? PskColors.textMuted.withAlpha(100) : Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isActiveTab ? 'No Active Bets' : 'No Settled Bets',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? PskColors.textWhite : PskColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isActiveTab
                    ? 'Place a bet from the Sportsbook or Live events to track your open tickets and cash out early here.'
                    : 'Your completed or cashed out bets will be archived here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        return _buildTicketCard(tickets[index], isDark);
      },
    );
  }

  Widget _buildTicketCard(PlacedBetTicket ticket, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1B2232) : Colors.white;
    final borderColor = isDark ? const Color(0xFF28334A) : const Color(0xFFE2E8F0);
    final mutedColor = isDark ? PskColors.textMuted : PskColors.textDarkSecondary;
    final timeStr = DateFormat('dd.MM. yyyy • HH:mm').format(ticket.placedAt);

    Color statusColor;
    String statusLabel = ticket.status.label;

    switch (ticket.status) {
      case TicketStatus.inPlay:
        statusColor = PskColors.liveGreen;
        break;
      case TicketStatus.won:
        statusColor = const Color(0xFFFFDB01);
        break;
      case TicketStatus.cashedOut:
        statusColor = PskColors.brandBlueLight;
        break;
      case TicketStatus.lost:
        statusColor = PskColors.alertRed;
        break;
    }

    final cashOutVal = ticket.currentCashOutValue;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 50 : 15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF151B27) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(fontSize: 10, color: mutedColor),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(35),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusColor.withAlpha(120)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ticket.isInPlay) ...[
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Legs list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              children: ticket.legs.map((leg) => _buildLegRow(leg, isDark)).toList(),
            ),
          ),

          const Divider(height: 1),

          // Footer metrics and Cash Out action
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stake', style: TextStyle(fontSize: 10, color: mutedColor)),
                        const SizedBox(height: 2),
                        Text(
                          '€${ticket.stake.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Total Odds', style: TextStyle(fontSize: 10, color: mutedColor)),
                        const SizedBox(height: 2),
                        Text(
                          ticket.totalOdds.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          ticket.status == TicketStatus.cashedOut
                              ? 'Cashed Out'
                              : 'Potential Win',
                          style: TextStyle(fontSize: 10, color: mutedColor),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ticket.status == TicketStatus.cashedOut
                              ? '€${(ticket.cashedOutAmount ?? 0.0).toStringAsFixed(2)}'
                              : '€${ticket.potentialWin.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: ticket.status == TicketStatus.cashedOut
                                ? PskColors.brandBlueLight
                                : PskColors.moneyGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Cash-out button if in-play
                if (ticket.isInPlay && cashOutVal > 0) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _confirmCashOut(context, ticket, cashOutVal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488), // Teal cash-out brand color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.bolt, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'CASH OUT  €${cashOutVal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegRow(PlacedBetLeg leg, bool isDark) {
    final mutedColor = isDark ? PskColors.textMuted : PskColors.textDarkSecondary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: PskColors.liveGreen.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: PskColors.liveGreen, size: 12),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${leg.selection.homeTeam} – ${leg.selection.awayTeam}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${leg.selection.marketName}: ',
                      style: TextStyle(fontSize: 10.5, color: mutedColor),
                    ),
                    Text(
                      leg.selection.selectionLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: PskColors.brandBlueLight,
                      ),
                    ),
                    if (leg.currentScore != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF232D42) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${leg.matchMinute ?? "LIVE"} (${leg.currentScore})',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: isDark ? const Color(0xFFFFDB01) : const Color(0xFFB45309),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222B3D) : const Color(0xFFEBF2FA),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              leg.selection.oddValue.toStringAsFixed(2),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCashOut(BuildContext context, PlacedBetTicket ticket, double amount) {
    final isDark = widget.state.isDarkMode;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? PskColors.surfaceDark : PskColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Confirm Cash Out?'),
        content: Text(
          'Are you sure you want to cash out ticket ${ticket.id} early for €${amount.toStringAsFixed(2)}?\n\nThis amount will be immediately added to your wallet balance.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final success = widget.state.cashOutTicket(ticket.id);
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cashed out ticket ${ticket.id} for €${amount.toStringAsFixed(2)}!'),
                    backgroundColor: const Color(0xFF0D9488),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
            ),
            child: const Text('CONFIRM CASH OUT'),
          ),
        ],
      ),
    );
  }
}
