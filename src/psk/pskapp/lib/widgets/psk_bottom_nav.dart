import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';

class PskBottomNav extends StatelessWidget {
  final AppState state;
  final VoidCallback onOpenMenu;

  const PskBottomNav({
    super.key,
    required this.state,
    required this.onOpenMenu,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final currentIndex = state.currentBottomNavIndex;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? PskColors.bgDarkSecondary : PskColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color: isDark ? PskColors.borderDark : PskColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                label: 'Live',
                icon: Icons.access_time_filled,
                isSelected: currentIndex == 0,
                hasLiveDot: true,
                onTap: () => state.setBottomNavIndex(0),
              ),
              _buildNavItem(
                index: 1,
                label: 'Sports',
                icon: Icons.sports_soccer,
                isSelected: currentIndex == 1,
                onTap: () => state.setBottomNavIndex(1),
              ),
              _buildNavItem(
                index: 2,
                label: 'Betslip',
                icon: Icons.confirmation_number_outlined,
                isSelected: currentIndex == 2,
                badgeCount: state.betSlip.count,
                onTap: () => state.setBottomNavIndex(2),
              ),
              _buildNavItem(
                index: 3,
                label: 'Casino',
                icon: Icons.casino_outlined,
                isSelected: currentIndex == 3,
                onTap: () => state.setBottomNavIndex(3),
              ),
              _buildNavItem(
                index: 4,
                label: 'Menu',
                icon: Icons.menu,
                isSelected: currentIndex == 4,
                onTap: onOpenMenu,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool hasLiveDot = false,
    int badgeCount = 0,
  }) {
    final activeColor = PskColors.brandBlueLight;
    final inactiveColor = state.isDarkMode ? PskColors.textMuted : PskColors.textDarkSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: isSelected ? activeColor : inactiveColor,
                    ),
                    if (hasLiveDot)
                      Positioned(
                        top: -2,
                        right: -3,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: PskColors.alertRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    if (badgeCount > 0)
                      Positioned(
                        top: -4,
                        right: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: PskColors.accentGold,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Text(
                            '$badgeCount',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? activeColor : inactiveColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
