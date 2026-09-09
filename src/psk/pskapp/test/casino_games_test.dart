import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psk/models/casino_game.dart';
import 'package:psk/state/app_state.dart';
import 'package:psk/screens/casino/slot_game_screen.dart';
import 'package:psk/screens/casino/roulette_game_screen.dart';
import 'package:psk/screens/casino/blackjack_game_screen.dart';

void main() {
  group('Casino Games Functional Tests', () {
    testWidgets('SlotGameScreen renders and displays game title and spin button', (WidgetTester tester) async {
      final state = AppState();
      const game = CasinoGame(
        id: 'vatreni_cup',
        title: 'Vatreni Cup',
        provider: 'Playtech',
        category: CasinoCategory.popular,
        imageUrl: 'https://example.com/vatreni.jpg',
        hasJackpot: true,
        jackpotAmount: 150000.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: SlotGameScreen(game: game, isDemo: true, state: state),
        ),
      );

      expect(find.text('Vatreni Cup'), findsOneWidget);
      expect(find.text('SPIN'), findsOneWidget);
      expect(find.text('DEMO'), findsOneWidget);
      expect(find.text('TOTAL BET'), findsOneWidget);

      state.dispose();
    });

    testWidgets('RouletteGameScreen renders wheel, betting table, and chips', (WidgetTester tester) async {
      final state = AppState();
      const game = CasinoGame(
        id: 'european_roulette',
        title: 'European Roulette Pro',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://example.com/roulette.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RouletteGameScreen(game: game, isDemo: true, state: state),
        ),
      );

      expect(find.text('European Roulette Pro'), findsOneWidget);
      expect(find.text('HISTORY:'), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(1));
      expect(find.text('RED'), findsOneWidget);
      expect(find.text('BLACK'), findsOneWidget);
      expect(find.text('EVEN'), findsOneWidget);
      expect(find.text('ODD'), findsOneWidget);

      state.dispose();
    });

    testWidgets('BlackjackGameScreen renders dealer area, player area, and DEAL button', (WidgetTester tester) async {
      final state = AppState();
      const game = CasinoGame(
        id: 'psk_blackjack',
        title: 'PSK VIP Blackjack',
        provider: 'Playtech',
        category: CasinoCategory.tableGames,
        imageUrl: 'https://example.com/blackjack.jpg',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlackjackGameScreen(game: game, isDemo: true, state: state),
        ),
      );

      expect(find.text('PSK VIP Blackjack'), findsOneWidget);
      expect(find.text('DEALER'), findsOneWidget);
      expect(find.text('YOU'), findsOneWidget);
      expect(find.text('DEAL'), findsOneWidget);
      expect(find.text('BET CHIPS:'), findsOneWidget);

      state.dispose();
    });
  });
}
