import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psk/models/casino_game.dart';
import 'package:psk/navigation/psk_tabs.dart';
import 'package:psk/state/app_state.dart';
import 'package:psk/screens/main_navigation_screen.dart';
import 'package:psk/screens/casino/slot_game_screen.dart';
import 'package:psk/screens/casino/roulette_game_screen.dart';
import 'package:psk/screens/casino/blackjack_game_screen.dart';
import 'package:psk/screens/widget_settings_screen.dart';
import 'package:psk/widgets/live_pitch_tracker.dart';

void main() {
  group('Zero Overflow Tests Across Multiple Screen Sizes', () {
    final viewports = [
      const Size(320, 568), // iPhone SE (1st gen)
      const Size(360, 640), // Standard Android compact
      const Size(375, 667), // iPhone SE (2nd/3rd gen)
      const Size(390, 844), // iPhone 14
      const Size(412, 915), // Pixel 7
    ];

    for (final size in viewports) {
      testWidgets('MainNavigationScreen on ${size.width}x${size.height} has no overflow', (tester) async {
        final state = AppState();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          MaterialApp(
            home: MainNavigationScreen(state: state),
          ),
        );
        await tester.pumpAndSettle();

        // Check Sportsbook Tab
        expect(find.byType(MainNavigationScreen), findsOneWidget);

        // Visit every top tab (Home, Sports, Live, Casino, Live Casino, Lotto,
        // Virtuals, Forum, Arena, Promotions, Swipe & Bet, Champions Club).
        for (final tab in PskTab.all) {
          state.setTopTabIndex(tab.index);
          await tester.pump(const Duration(milliseconds: 400));
        }

        // Switch to Betslip
        state.setBottomNavIndex(PskBottomTab.betslip);
        await tester.pumpAndSettle();

        state.dispose();
      });

      testWidgets('Casino Games on ${size.width}x${size.height} have no overflow', (tester) async {
        final state = AppState();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        const slotGame = CasinoGame(
          id: 'vatreni_cup',
          title: 'Vatreni Cup',
          provider: 'Playtech',
          category: CasinoCategory.popular,
          imageUrl: 'https://example.com/vatreni.jpg',
          hasJackpot: true,
          jackpotAmount: 150000.0,
        );

        // Test SlotGameScreen
        await tester.pumpWidget(
          MaterialApp(
            home: SlotGameScreen(game: slotGame, isDemo: true, state: state),
          ),
        );
        await tester.pumpAndSettle();

        const rouletteGame = CasinoGame(
          id: 'european_roulette',
          title: 'European Roulette Pro',
          provider: 'Playtech',
          category: CasinoCategory.tableGames,
          imageUrl: 'https://example.com/roulette.jpg',
        );

        // Test RouletteGameScreen
        await tester.pumpWidget(
          MaterialApp(
            home: RouletteGameScreen(game: rouletteGame, isDemo: true, state: state),
          ),
        );
        await tester.pumpAndSettle();

        const bjGame = CasinoGame(
          id: 'psk_blackjack',
          title: 'PSK VIP Blackjack',
          provider: 'Playtech',
          category: CasinoCategory.tableGames,
          imageUrl: 'https://example.com/blackjack.jpg',
        );

        // Test BlackjackGameScreen
        await tester.pumpWidget(
          MaterialApp(
            home: BlackjackGameScreen(game: bjGame, isDemo: true, state: state),
          ),
        );
        await tester.pumpAndSettle();

        state.dispose();
      });

      testWidgets('LivePitchTracker and WidgetSettingsScreen on ${size.width}x${size.height}', (tester) async {
        final state = AppState();
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        final event = state.events.firstWhere((e) => e.isLive);

        // Test LivePitchTracker
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: LivePitchTracker(event: event)),
          ),
        );
        await tester.pumpAndSettle();

        // Test WidgetSettingsScreen
        await tester.pumpWidget(
          MaterialApp(
            home: WidgetSettingsScreen(state: state),
          ),
        );
        await tester.pumpAndSettle();

        state.dispose();
      });
    }
  });
}
