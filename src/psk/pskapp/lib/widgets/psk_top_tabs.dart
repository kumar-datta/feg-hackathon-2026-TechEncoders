import 'package:flutter/material.dart';

import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';

class PskTopTabs extends StatefulWidget {
  final AppState state;

  const PskTopTabs({super.key, required this.state});

  @override
  State<PskTopTabs> createState() => _PskTopTabsState();
}

class _PskTopTabsState extends State<PskTopTabs> {
  final _scroll = ScrollController();
  int _lastIndex = -1;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _ensureVisible(int index) {
    if (_lastIndex == index || !_scroll.hasClients) return;
    _lastIndex = index;
    // ~96 px per tab is close enough to keep the selected one on screen
    final target = (index * 96.0 - 120).clamp(0.0, _scroll.position.maxScrollExtent);
    _scroll.animateTo(target, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureVisible(state.selectedTopTabIndex));

    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? PskColors.bgDarkSecondary : PskColors.brandBlueDark,
        border: Border(
          bottom: BorderSide(
            color: isDark ? PskColors.borderDark : Colors.white10,
            width: 1,
          ),
        ),
      ),
      child: ListView.builder(
        controller: _scroll,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: PskTab.all.length,
        itemBuilder: (context, i) {
          final tab = PskTab.all[i];
          final isSelected = state.selectedTopTabIndex == tab.index;

          return GestureDetector(
            onTap: () => state.setTopTabIndex(tab.index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? PskColors.accentGold : Colors.transparent,
                    width: 3,
                  ),
                ),
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  if (tab.index == PskTab.home)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(tab.icon, size: 16, color: isSelected ? Colors.white : (isDark ? PskColors.textMuted : Colors.white70)),
                    ),
                  if (tab.isLive)
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 5),
                      decoration: const BoxDecoration(color: PskColors.alertRed, shape: BoxShape.circle),
                    ),
                  Text(
                    tab.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? PskColors.textMuted : Colors.white70),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  if (tab.isNew)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(color: PskColors.alertRed, borderRadius: BorderRadius.circular(3)),
                      child: const Text('NEW', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
