import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../screens/daily_streak_screen.dart';
import 'my_bets_sheet.dart';

class PskHeader extends StatelessWidget implements PreferredSizeWidget {
  final AppState state;
  final VoidCallback onOpenDrawer;

  const PskHeader({
    super.key,
    required this.state,
    required this.onOpenDrawer,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;

    return Container(
      color: isDark ? PskColors.bgDark : PskColors.brandBlue,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 6,
        bottom: 10,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          // Menu — the one consistent way into the drawer, logged in or not.
          InkWell(
            onTap: onOpenDrawer,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.menu_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 6),

          // PSK SVG Logo
          GestureDetector(
            onTap: () => state.goHome(),
            child: SizedBox(
              height: 26,
              width: 72,
              child: SvgPicture.asset(
                'assets/images/psk_logo.svg',
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Right-side utility & profile cluster wrapped for zero-overflow on narrow screens
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.search, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => _showSearchDialog(context),
                          tooltip: 'Search matches or teams',
                        ),
                        Container(width: 1, height: 16, color: Colors.white24),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 19),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => _showBetslipScanner(context),
                          tooltip: 'Check Ticket',
                        ),
                        Container(width: 1, height: 16, color: Colors.white24),
                        IconButton(
                          icon: Badge(
                            isLabelVisible: state.activeTicketsCount > 0,
                            label: Text('${state.activeTicketsCount}', style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            backgroundColor: PskColors.liveGreen,
                            child: const Icon(Icons.receipt_long, color: Colors.white, size: 19),
                          ),
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => MyBetsSheet.show(context, state),
                          tooltip: 'My Bets',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Profile / Menu Button
                  _profileHeaderButton(context, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileHeaderButton(BuildContext context, bool isDark) {
    if (state.isLoggedIn) {
      return _avatarWithStreakBadge(context, isDark);
    }
    return InkWell(
      onTap: onOpenDrawer,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 20),
      ),
    );
  }

  /// The avatar doubles as the drawer entry point; a streak badge sits on
  /// its corner (instead of its own separate chip) so a personal-best isn't
  /// competing with the wallet and deposit CTA for header width.
  Widget _avatarWithStreakBadge(BuildContext context, bool isDark) {
    final streak = state.currentStreak;

    return InkWell(
      onTap: onOpenDrawer,
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
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
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DailyStreakScreen(state: state)),
                  ),
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
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: state.isDarkMode ? PskColors.surfaceDark : PskColors.surfaceLight,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Search Sportsbook',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Enter team (e.g. Dinamo, Real), league...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: state.isDarkMode ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  state.setSearchQuery(val);
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: ['Dinamo', 'Hajduk', 'Real Madrid', 'Premier League', 'NBA'].map((t) {
                  return ActionChip(
                    label: Text(t, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      state.setSearchQuery(t);
                      Navigator.pop(ctx);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBetslipScanner(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: state.isDarkMode ? PskColors.surfaceDark : PskColors.surfaceLight,
          title: const Row(
            children: [
              Icon(Icons.qr_code_scanner, color: PskColors.brandBlueLight),
              SizedBox(width: 8),
              Text('Check Ticket'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter 12-digit ticket code from shop or scan barcode:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 14),
              TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. 7821-4902-1849',
                  filled: true,
                  fillColor: state.isDarkMode ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ticket is active and in play! Events: 4/5 won so far.'),
                      backgroundColor: PskColors.brandBlue,
                    ),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('CHECK'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PskColors.brandBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showDepositModal(BuildContext context, AppState state) {
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
