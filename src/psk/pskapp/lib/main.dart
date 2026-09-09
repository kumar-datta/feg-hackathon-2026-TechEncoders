import 'package:flutter/material.dart';
import 'assistant/assistant_controller.dart';
import 'assistant/assistant_scope.dart';
import 'theme/psk_theme.dart';
import 'state/app_state.dart';
import 'screens/splash_screen.dart';
import 'services/widget_bridge_service.dart';
import 'services/lock_screen_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.restorePersistedState();

  // Tapping the lock-screen card should open the same match as a widget tap.
  await LockScreenNotificationService.initialize(
    onTapped: (payload) => _handleWidgetUri(appState, payload == null ? null : Uri.tryParse(payload)),
  );

  // Sync lock-screen card immediately once notification service is initialized
  if (appState.lockScreenWidgetEnabled) {
    LockScreenNotificationService.sync(
      appState.trackedLiveMatch,
      enabled: true,
      selfExcluded: appState.selfExcluded,
      quietHours: appState.isQuietHoursNow(),
      faceIndex: 0,
      balance: appState.balance,
      slipCount: appState.betSlip.count,
      slipTotalOdds: appState.betSlip.totalOdds,
      slipPotentialWin: appState.betSlip.potentialWin,
    );
  }

  // Cold start: app was opened by tapping a PSK Pulse home-screen widget.
  _handleWidgetUri(appState, await WidgetBridgeService.checkLaunchUri());
  // Warm start: a widget was tapped while the app was already running.
  WidgetBridgeService.clicks.listen((uri) => _handleWidgetUri(appState, uri));

  // The PSK Assistant builds its on-device RAG index in the background; the
  // FAB is usable as soon as the first frame renders.
  final assistant = AssistantController(appState);

  runApp(PskApp(state: appState, assistant: assistant));
}

void _handleWidgetUri(AppState appState, Uri? uri) {
  if (uri == null) return;
  if (uri.host == 'live' && uri.pathSegments.isNotEmpty) {
    appState.requestOpenLiveEvent(uri.pathSegments.first);
  } else if (uri.host == 'betslip') {
    appState.openBetSlipTab();
  } else if (uri.host == 'boost' && uri.pathSegments.isNotEmpty) {
    appState.openBoostMatch(uri.pathSegments.first);
  }
}

class PskApp extends StatelessWidget {
  final AppState state;
  final AssistantController assistant;

  const PskApp({super.key, required this.state, required this.assistant});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'PSK.hr - Sports & Casino',
          debugShowCheckedModeBanner: false,
          theme: PskTheme.lightTheme,
          darkTheme: PskTheme.darkTheme,
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          // Installed above the Navigator so every pushed screen can reach the assistant.
          builder: (context, child) => AssistantScope(controller: assistant, child: child ?? const SizedBox.shrink()),
          home: SplashScreen(state: state),
        );
      },
    );
  }
}
