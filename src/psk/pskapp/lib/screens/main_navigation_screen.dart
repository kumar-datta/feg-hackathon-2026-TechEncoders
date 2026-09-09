import 'package:flutter/material.dart';

import '../assistant/assistant_scope.dart';
import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/arena_forum_widget.dart';
import '../widgets/assistant/assistant_fab.dart';
import '../widgets/assistant/assistant_panel.dart';
import '../widgets/casino_section.dart';
import '../widgets/floating_betslip_bar.dart';
import '../widgets/live_pitch_tracker.dart';
import '../widgets/psk_bottom_nav.dart';
import '../widgets/psk_drawer.dart';
import '../widgets/psk_header.dart';
import '../widgets/psk_top_tabs.dart';
import '../widgets/swipe_bet_widget.dart';
import 'betslip_screen.dart';
import 'champions_club_view.dart';
import 'home_view.dart';
import 'live_view.dart';
import 'lotto_view.dart';
import 'promotions_view.dart';
import 'sportsbook_view.dart';
import 'virtuals_view.dart';

class MainNavigationScreen extends StatefulWidget {
  final AppState state;

  const MainNavigationScreen({super.key, required this.state});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    final pendingLiveEventId = state.pendingLiveEventId;
    if (pendingLiveEventId != null) {
      // A PSK Pulse widget tap asked for this match's Pitch Tracker — open it
      // once this frame has finished building.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SportEvent? match;
        for (final e in state.events) {
          if (e.id == pendingLiveEventId) {
            match = e;
            break;
          }
        }
        state.clearPendingLiveEvent();
        if (match != null) {
          LivePitchTracker.show(context, match);
        }
      });
    }

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final isDark = state.isDarkMode;
        final assistant = AssistantScope.maybeOf(context);
        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
          drawer: PskDrawer(state: state),
          appBar: PskHeader(
            state: state,
            onOpenDrawer: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), // Clean mobile viewport frame on desktop/web
              child: Column(
                children: [
                  PskTopTabs(state: state),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildBody(state),

                        // Floating betslip bar if selections exist and not on the betslip tab
                        if (state.currentBottomNavIndex != PskBottomTab.betslip)
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 6,
                            child: FloatingBetslipBar(state: state),
                          ),

                        // PSK Assistant launcher — 16 px from the right edge,
                        // 12 px above the bottom nav (clear of the slip bar).
                        if (assistant != null)
                          Positioned(
                            right: 6,
                            bottom: state.betSlip.isNotEmpty && state.currentBottomNavIndex != PskBottomTab.betslip ? 66 : 2,
                            child: AssistantFab(
                              controller: assistant,
                              onPressed: () => AssistantPanel.show(context, assistant, state),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PskBottomNav(
                    state: state,
                    onOpenMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AppState state) {
    if (state.currentBottomNavIndex == PskBottomTab.betslip) {
      return BetslipScreen(state: state);
    }

    switch (state.selectedTopTabIndex) {
      case PskTab.home:
        return HomeView(state: state);
      case PskTab.sports:
        return SportsbookView(state: state);
      case PskTab.live:
        return LiveView(state: state);
      case PskTab.casino:
      case PskTab.liveCasino:
        return CasinoSection(state: state, liveOnly: state.selectedTopTabIndex == PskTab.liveCasino);
      case PskTab.lotto:
        return LottoView(state: state);
      case PskTab.virtuals:
        return VirtualsView(state: state);
      case PskTab.forum:
      case PskTab.arena:
        return ArenaForumWidget(state: state);
      case PskTab.promos:
        return PromotionsView(state: state);
      case PskTab.swipe:
        return SwipeBetWidget(state: state);
      case PskTab.championsClub:
        return ChampionsClubView(state: state);
      default:
        return HomeView(state: state);
    }
  }
}
