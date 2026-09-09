import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/my_bets_sheet.dart';
import '../widgets/psk_header.dart';

enum AccountSection { wallet, limits, selfExclusion }

/// My Account — wallet, play limits and self-exclusion. The website has these
/// on `/racun`; the assistant routes `screen:account|limits|self_exclusion`
/// here and scrolls to the requested section.
class AccountScreen extends StatefulWidget {
  final AppState state;
  final AccountSection section;

  const AccountScreen({super.key, required this.state, this.section = AccountSection.wallet});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _limitsKey = GlobalKey();
  final _exclusionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = switch (widget.section) {
        AccountSection.limits => _limitsKey,
        AccountSection.selfExclusion => _exclusionKey,
        AccountSection.wallet => null,
      };
      if (key?.currentContext != null) {
        Scrollable.ensureVisible(key!.currentContext!, duration: const Duration(milliseconds: 300));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final isDark = state.isDarkMode;
        final tier = _tierFor(state.loyaltyPoints);
        return Scaffold(
          backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
          appBar: AppBar(
            title: const Text('My Account'),
            backgroundColor: isDark ? PskColors.bgDark : PskColors.brandBlue,
          ),
          body: !state.isLoggedIn
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.lock_outline, size: 48, color: PskColors.textMuted),
                        const SizedBox(height: 12),
                        const Text('Log in to see your account', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => AuthDialog.show(context, state, isRegister: false),
                          style: ElevatedButton.styleFrom(backgroundColor: PskColors.brandBlue, foregroundColor: Colors.white),
                          child: const Text('LOG IN'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _panel(isDark, [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: PskColors.surfaceDarkPanel,
                            child: Text(state.userAvatar, style: const TextStyle(fontSize: 20)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(state.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${state.userBadge} · ${tier.name} tier',
                                    style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        children: [
                          const Text('Balance', style: TextStyle(color: PskColors.textMuted)),
                          const Spacer(),
                          Text('${state.balance.toStringAsFixed(2)} €',
                              style: const TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold, fontSize: 20)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text('Loyalty points', style: TextStyle(color: PskColors.textMuted)),
                          const Spacer(),
                          Text('${state.loyaltyPoints}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => PskHeader.showDepositModal(context, state),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('DEPOSIT'),
                              style: ElevatedButton.styleFrom(backgroundColor: PskColors.moneyGreen, foregroundColor: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => MyBetsSheet.show(context, state),
                              icon: const Icon(Icons.receipt_long, size: 16),
                              label: Text('TICKETS (${state.activeTicketsCount})'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'This demo has no withdrawal flow — balances are demo credits only.',
                        style: TextStyle(color: PskColors.textMuted, fontSize: 11, fontStyle: FontStyle.italic),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Container(
                      key: _limitsKey,
                      child: _panel(isDark, [
                        const Text('Play limits', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        const Text(
                          'Lowering a limit applies immediately; raising one takes effect after 24 hours.',
                          style: TextStyle(color: PskColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        _limitRow('Daily deposit limit', state.dailyDepositLimit, (v) => state.setDailyDepositLimit(v)),
                        _limitRow('Weekly loss limit', state.weeklyLossLimit, (v) => state.setWeeklyLossLimit(v)),
                        _limitRow('Session limit (minutes)', state.sessionLimitMinutes.toDouble(),
                            (v) => state.setSessionLimitMinutes(v.round()),
                            unit: 'min', options: const [30, 60, 120, 240]),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      key: _exclusionKey,
                      child: _panel(isDark, [
                        const Text('Take a break', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Self-exclusion', style: TextStyle(fontSize: 13)),
                          subtitle: const Text(
                            'Pauses PSK Pulse widgets, the lock-screen card, daily rewards and all incentives. Cannot be lifted early in a real account.',
                            style: TextStyle(fontSize: 11),
                          ),
                          value: state.selfExcluded,
                          activeThumbColor: PskColors.accentGold,
                          onChanged: (v) => state.setSelfExcluded(v),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            state.setTopTabIndex(PskTab.championsClub);
                          },
                          icon: const Icon(Icons.emoji_events, size: 16),
                          label: const Text('Champions Club & rewards'),
                        ),
                      ]),
                    ),
                  ],
                ),
        );
      },
    );
  }

  LoyaltyTier _tierFor(int points) {
    var t = ContentData.tiers.first;
    for (final tier in ContentData.tiers) {
      if (points >= tier.points) t = tier;
    }
    return t;
  }

  Widget _panel(bool isDark, List<Widget> children) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? PskColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _limitRow(String label, double value, ValueChanged<double> onChanged,
      {String unit = '€', List<num> options = const [50, 100, 250, 500, 1000]}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          DropdownButton<double>(
            value: options.map((o) => o.toDouble()).contains(value) ? value : options.first.toDouble(),
            underline: const SizedBox.shrink(),
            items: options
                .map((o) => DropdownMenuItem(value: o.toDouble(), child: Text('${o.toStringAsFixed(0)} $unit', style: const TextStyle(fontSize: 13))))
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}
