import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../models/demo_user.dart';
import '../navigation/psk_tabs.dart';
import '../assistant/assistant_scope.dart';
import '../screens/account_screen.dart';
import '../screens/info_page_screen.dart';
import 'assistant/assistant_panel.dart';
import '../screens/widget_settings_screen.dart';
import '../screens/daily_streak_screen.dart';
import '../screens/game_history_screen.dart';
import 'auth_dialog.dart';
import 'my_bets_sheet.dart';

class PskDrawer extends StatelessWidget {
  final AppState state;

  const PskDrawer({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;

    return Drawer(
      backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
      child: SafeArea(
        child: Column(
          children: [
            // User Header with Auth / Wallet Clusters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? PskColors.bgDarkSecondary : PskColors.brandBlue,
              ),
              child: state.isLoggedIn ? _buildLoggedInHeader(context, isDark) : _buildLoggedOutHeader(context, isDark),
            ),

            // Scrollable Menu Options
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSectionHeader('APPEARANCE & THEME', isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? PskColors.surfaceDarkPanel : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? PskColors.borderDark : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => state.setThemeMode(false),
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: !isDark ? Colors.white : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: !isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.1),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.wb_sunny_rounded,
                                        size: 16,
                                        color: !isDark ? PskColors.brandBlue : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Bright Mode',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: !isDark ? FontWeight.bold : FontWeight.normal,
                                          color: !isDark ? PskColors.brandBlue : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => state.setThemeMode(true),
                              borderRadius: BorderRadius.circular(8),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? PskColors.brandBlue : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: isDark
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.nightlight_round,
                                        size: 16,
                                        color: isDark ? Colors.white : Colors.grey,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Dark Mode',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isDark ? FontWeight.bold : FontWeight.normal,
                                          color: isDark ? Colors.white : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Divider(height: 1),

                  // Demo Logins Quick Switcher
                  _buildSectionHeader('SWITCH DEMO PROFILE', isDark),
                  ...DemoUserProfile.demoProfiles.map((p) {
                    final isActive = state.isLoggedIn && state.username == p.username;
                    return ListTile(
                      dense: true,
                      visualDensity: const VisualDensity(vertical: -3),
                      leading: Text(p.avatar, style: const TextStyle(fontSize: 18)),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              p.username,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                                color: isActive ? PskColors.accentGold : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              '${p.startingBalance.toStringAsFixed(0)} €',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: PskColors.moneyGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        p.recentGames.isNotEmpty || p.recentTickets.isNotEmpty
                            ? '${p.badge} • ${p.recentGames.length} games · ${p.recentTickets.length} bets'
                            : p.badge,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: PskColors.textMuted),
                      ),
                      trailing: isActive
                          ? const Icon(Icons.check_circle, color: PskColors.liveGreen, size: 18)
                          : const Icon(Icons.arrow_forward_ios, size: 12, color: PskColors.textMuted),
                      onTap: () {
                        state.loginAsDemo(p);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Switched to ${p.fullName} • ${p.recentGames.length} games & ${p.recentTickets.length} bets ready',
                            ),
                            backgroundColor: PskColors.liveGreen,
                          ),
                        );
                      },
                    );
                  }),

                  const Divider(height: 1),

                  _buildSectionHeader('REWARDS', isDark),
                  _buildMenuItem(context, 'Daily Streak', Icons.local_fire_department, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DailyStreakScreen(state: state)),
                    );
                  }, isNew: true),

                  const Divider(height: 1),

                  _buildSectionHeader('HOME SCREEN', isDark),
                  _buildMenuItem(context, 'PSK Pulse Widgets', Icons.widgets, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WidgetSettingsScreen(state: state)),
                    );
                  }, isNew: true),

                  const Divider(height: 1),

                  _buildSectionHeader('PLAY', isDark),
                  _buildMenuItem(context, 'Home', Icons.home_rounded, () {
                    state.goHome();
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'PSK Assistant (AI chat)', Icons.auto_awesome, () {
                    Navigator.pop(context);
                    final assistant = AssistantScope.maybeOf(context);
                    if (assistant != null) AssistantPanel.show(context, assistant, state);
                  }, isNew: true),
                  _buildMenuItem(context, 'My Account & Limits', Icons.person, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => AccountScreen(state: state)));
                  }),
                  _buildMenuItem(context, 'My Bets (${state.activeTicketsCount})', Icons.receipt_long, () {
                    Navigator.pop(context);
                    MyBetsSheet.show(context, state);
                  }),
                  _buildMenuItem(context, 'Game Activity & Logs (${state.gameHistory.length})', Icons.history_edu, () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => GameHistoryScreen(state: state)),
                    );
                  }, isNew: true),
                  _buildMenuItem(context, 'Sports Betting', Icons.sports_soccer, () {
                    state.setTopTabIndex(PskTab.sports);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Live Betting', Icons.access_time_filled, () {
                    state.setTopTabIndex(PskTab.live);
                    Navigator.pop(context);
                  }, isLive: true),
                  _buildMenuItem(context, 'PSK Casino & Slots', Icons.casino, () {
                    state.setTopTabIndex(PskTab.casino);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Live Casino', Icons.stream, () {
                    state.setTopTabIndex(PskTab.liveCasino);
                    Navigator.pop(context);
                  }, isNew: true),
                  _buildMenuItem(context, 'Lottery Games', Icons.looks_one, () {
                    state.setTopTabIndex(PskTab.lotto);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Virtual Games', Icons.videogame_asset, () {
                    state.setTopTabIndex(PskTab.virtuals);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Swipe & Bet', Icons.swipe, () {
                    state.setTopTabIndex(PskTab.swipe);
                    Navigator.pop(context);
                  }, isNew: true),

                  const Divider(height: 1),

                  _buildSectionHeader('EXPLORE & COMMUNITY', isDark),
                  _buildMenuItem(context, 'PSK Arena', Icons.military_tech, () {
                    state.setTopTabIndex(PskTab.arena);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Community Forum', Icons.forum, () {
                    state.setTopTabIndex(PskTab.forum);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Promotions & Bonuses', Icons.card_giftcard, () {
                    state.setTopTabIndex(PskTab.promos);
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(context, 'Results & Statistics', Icons.bar_chart, () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Match results and sports statistics')),
                    );
                  }),
                  _buildMenuItem(context, 'Champions Club (Loyalty)', Icons.emoji_events, () {
                    state.setTopTabIndex(PskTab.championsClub);
                    Navigator.pop(context);
                  }, isNew: true),

                  const Divider(height: 1),

                  _buildSectionHeader('SUPPORT & LOCATIONS', isDark),
                  _buildMenuItem(context, 'Help & FAQ', Icons.help_outline, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPageScreen(state: state, page: InfoPage.help)));
                  }),
                  _buildMenuItem(context, 'Customer Support (Chat)', Icons.support_agent, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPageScreen(state: state, page: InfoPage.contact)));
                  }),
                  _buildMenuItem(context, 'Game Rules', Icons.rule, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPageScreen(state: state, page: InfoPage.rules)));
                  }),
                  _buildMenuItem(context, 'Responsible Gaming', Icons.shield, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPageScreen(state: state, page: InfoPage.responsible)));
                  }),
                  _buildMenuItem(context, 'Privacy Policy', Icons.privacy_tip_outlined, () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => InfoPageScreen(state: state, page: InfoPage.privacy)));
                  }),
                ],
              ),
            ),

            // Responsible gaming 18+ footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              color: isDark ? PskColors.bgDarkSecondary : Colors.grey.shade200,
              alignment: Alignment.center,
              child: const Text(
                '🔞 Gambling can be addictive. Play responsibly!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: PskColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isLive = false,
    bool isNew = false,
  }) {
    return ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(icon, size: 18, color: PskColors.brandBlueLight),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isLive) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: PskColors.alertRed, borderRadius: BorderRadius.circular(3)),
              child: const Text('LIVE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
          if (isNew) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: PskColors.accentGold, borderRadius: BorderRadius.circular(3)),
              child: const Text('NEW', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
      trailing: const Icon(Icons.chevron_right, size: 16, color: PskColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildLoggedInHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: PskColors.accentGold.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      state.userBadge,
                      style: const TextStyle(
                        color: PskColors.accentGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
              onPressed: () {
                state.logout();
                Navigator.pop(context);
              },
              tooltip: 'Log out',
            ),
          ],
        ),
        const SizedBox(height: 12),
        _loggedInCluster(context, isDark),
      ],
    );
  }

  Widget _buildLoggedOutHeader(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_outline, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Guest User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Log in for full sportsbook access',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _loggedOutCluster(context),
      ],
    );
  }

  Widget _loggedInCluster(BuildContext context, bool isDark) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? PskColors.surfaceDarkPanel : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? PskColors.borderDark : Colors.white24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_balance_wallet, color: PskColors.accentGold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${state.balance.toStringAsFixed(2)} €',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              _showDepositModal(context);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(color: PskColors.moneyGreen, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'DEPOSIT',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.3),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _avatarWithStreakBadge(context, isDark),
        ],
      ),
    );
  }

  Widget _loggedOutCluster(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
              AuthDialog.show(context, state, isRegister: false);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white38),
              ),
              child: const Text(
                'Log in',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: () {
              Navigator.pop(context);
              AuthDialog.show(context, state, isRegister: true);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(color: PskColors.accentGold, borderRadius: BorderRadius.circular(8)),
              child: const Text(
                'Register',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarWithStreakBadge(BuildContext context, bool isDark) {
    final streak = state.currentStreak;

    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDark ? PskColors.surfaceDarkPanel : Colors.white24,
                shape: BoxShape.circle,
                border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.7)),
              ),
              alignment: Alignment.center,
              child: Text(state.userAvatar, style: const TextStyle(fontSize: 15)),
            ),
          ),
          if (streak > 0)
            Positioned(
              right: -4,
              top: -4,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DailyStreakScreen(state: state)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: PskColors.bgDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PskColors.accentGold, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 8)),
                      const SizedBox(width: 1),
                      Text(
                        '$streak',
                        style: const TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showDepositModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: state.isDarkMode ? PskColors.surfaceDark : PskColors.surfaceLight,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Deposit',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select an amount to instantly top up your account:',
                style: TextStyle(color: PskColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [10.0, 20.0, 50.0, 100.0].map((amt) {
                  return ElevatedButton(
                    onPressed: () {
                      state.deposit(amt);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Deposited ${amt.toStringAsFixed(0)} € to your PSK account!'),
                          backgroundColor: PskColors.liveGreen,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PskColors.brandBlue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('+${amt.toStringAsFixed(0)} €'),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
