import 'package:flutter/material.dart';

import '../models/casino_game.dart';
import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import '../screens/account_screen.dart';
import '../screens/daily_streak_screen.dart';
import '../screens/game_history_screen.dart';
import '../screens/info_page_screen.dart';
import '../screens/widget_settings_screen.dart';
import '../state/app_state.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/betslip_sheet.dart';
import '../widgets/casino/game_preview_sheet.dart';
import '../widgets/my_bets_sheet.dart';
import '../widgets/psk_header.dart';

/// Executes a registry route inside the app. This is the app-side half of the
/// website's invariant: the assistant hands over an opaque route string that
/// came from the registry, and only this class knows what it does.
class AssistantRouter {
  AssistantRouter._();

  /// Returns false if the route was not understood.
  static bool open(BuildContext context, AppState state, String route) {
    final sep = route.indexOf(':');
    if (sep < 0) return false;
    final kind = route.substring(0, sep);
    final arg = route.substring(sep + 1);

    switch (kind) {
      case 'tab':
        final idx = int.tryParse(arg);
        if (idx == null) return false;
        state.setTopTabIndex(idx);
        return true;

      case 'sport':
        final sport = SportType.values.where((s) => s.name == arg).firstOrNull;
        if (sport == null) return false;
        state.setTopTabIndex(PskTab.sports);
        if (state.selectedSport != sport) state.setSport(sport);
        return true;

      case 'category':
        final cat = CasinoCategory.values.where((c) => c.name == arg).firstOrNull;
        if (cat == null) return false;
        state.requestCasinoCategory(cat);
        state.setTopTabIndex(PskTab.casino);
        return true;

      case 'game':
        final game = state.casinoGames.where((g) => g.id == arg).firstOrNull;
        if (game == null) return false;
        state.setTopTabIndex(PskTab.casino);
        GamePreviewSheet.show(context, state, game);
        return true;

      case 'sheet':
        switch (arg) {
          case 'deposit':
            PskHeader.showDepositModal(context, state);
            return true;
          case 'mybets':
            MyBetsSheet.show(context, state);
            return true;
          case 'betslip':
            BetslipSheet.show(context, state);
            return true;
        }
        return false;

      case 'screen':
        Widget? screen;
        switch (arg) {
          case 'checkout':
            BetslipSheet.show(context, state);
            return true;
          case 'streak':
            screen = DailyStreakScreen(state: state);
          case 'widgets':
            screen = WidgetSettingsScreen(state: state);
          case 'history':
            screen = GameHistoryScreen(state: state);
          case 'account':
            screen = AccountScreen(state: state);
          case 'limits':
            screen = AccountScreen(state: state, section: AccountSection.limits);
          case 'self_exclusion':
            screen = AccountScreen(state: state, section: AccountSection.selfExclusion);
          case 'login':
            AuthDialog.show(context, state, isRegister: false);
            return true;
          case 'register':
            AuthDialog.show(context, state, isRegister: true);
            return true;
          case 'help':
          case 'contact':
          case 'rules':
          case 'responsible':
          case 'privacy':
            screen = InfoPageScreen(state: state, page: InfoPage.values.byName(arg));
        }
        if (screen == null) return false;
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen!));
        return true;
    }
    return false;
  }
}
