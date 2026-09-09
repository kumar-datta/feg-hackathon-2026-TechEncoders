import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:psk/models/demo_user.dart';
import 'package:psk/models/played_game_log.dart';
import 'package:psk/state/app_state.dart';
import 'package:psk/screens/game_history_screen.dart';
import 'package:psk/widgets/user_quick_resume_section.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Demo Users Game Logs Data Integrity Tests', () {
    test('All 4 demo profiles have non-empty recentGames with round-by-round logs', () {
      final profiles = DemoUserProfile.demoProfiles;
      expect(profiles.length, 4);

      for (final profile in profiles) {
        expect(profile.recentGames, isNotEmpty,
            reason: '${profile.username} should have pre-populated recentGames');

        for (final game in profile.recentGames) {
          expect(game.id, isNotEmpty);
          expect(game.gameId, isNotEmpty);
          expect(game.gameTitle, isNotEmpty);
          expect(game.stake, greaterThan(0));
          expect(game.roundsPlayed, greaterThan(0));
          expect(game.detailedLogs, isNotEmpty,
              reason: '${game.gameTitle} should have round audit entries');
          expect(game.summary, isNotEmpty);
        }
      }
    });

    test('Marko_VIP profile has high-roller Blackjack and VIP game logs', () {
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');
      expect(marko.badge, 'VIP Gold Tier');
      expect(marko.startingBalance, 5000.00);

      final bjGame = marko.recentGames.firstWhere((g) => g.gameId == 'psk_blackjack');
      expect(bjGame.stake, 500.00);
      expect(bjGame.winAmount, 1250.00);
      expect(bjGame.isWin, isTrue);
      expect(bjGame.detailedLogs.length, 5);
      expect(bjGame.detailedLogs.any((l) => l.contains('NATURAL BLACKJACK')), isTrue);
    });

    test('Ana_SpinQueen profile has slot and free spins game logs', () {
      final ana = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Ana_SpinQueen');
      expect(ana.badge, 'Casino VIP');
      expect(ana.recentGames.any((g) => g.gameId == 'shining_crown'), isTrue);
      expect(ana.recentGames.any((g) => g.gameId == 'sweet_bonanza'), isTrue);

      final sweetBonanza = ana.recentGames.firstWhere((g) => g.gameId == 'sweet_bonanza');
      expect(sweetBonanza.roundsPlayed, 25);
      expect(sweetBonanza.detailedLogs.any((l) => l.contains('Free Spins')), isTrue);
    });

    test('All 4 demo profiles have non-empty recentTickets with authentic sports bets', () {
      final profiles = DemoUserProfile.demoProfiles;
      for (final profile in profiles) {
        expect(profile.recentTickets, isNotEmpty,
            reason: '${profile.username} should have pre-populated recentTickets');
        for (final ticket in profile.recentTickets) {
          expect(ticket.id, isNotEmpty);
          expect(ticket.legs, isNotEmpty);
          expect(ticket.stake, greaterThan(0));
          expect(ticket.totalOdds, greaterThan(1.0));
          for (final leg in ticket.legs) {
            expect(leg.selection.homeTeam, isNotEmpty);
            expect(leg.selection.awayTeam, isNotEmpty);
            expect(leg.selection.oddValue, greaterThan(1.0));
          }
        }
      }
    });
  });

  group('AppState Game History Integration Tests', () {
    test('loginAsDemo loads profile gameHistory and placedTickets, logout clears both', () {
      final state = AppState();
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');

      state.loginAsDemo(marko);
      expect(state.isLoggedIn, isTrue);
      expect(state.username, 'Marko_VIP');
      expect(state.gameHistory.length, marko.recentGames.length);
      expect(state.gameHistory.first.gameTitle, marko.recentGames.first.gameTitle);
      expect(state.placedTickets.length, marko.recentTickets.length);

      // Add a live game log
      final liveLog = PlayedGameLog(
        id: 'test_log_1',
        gameId: 'vatreni_cup',
        gameTitle: 'Vatreni Cup Test',
        category: 'Slots',
        provider: 'Playtech',
        gameIcon: '⚽',
        timestamp: DateTime.now(),
        stake: 10.0,
        winAmount: 25.0,
        roundsPlayed: 5,
        summary: 'Test session win',
        detailedLogs: ['Spin #1: Won 5.0 €', 'Spin #2: Won 20.0 €'],
      );
      state.addGameLog(liveLog);
      expect(state.gameHistory.first.id, 'test_log_1');
      expect(state.gameHistory.length, marko.recentGames.length + 1);

      // Logout clears history and tickets
      state.logout();
      expect(state.isLoggedIn, isFalse);
      expect(state.gameHistory, isEmpty);
      expect(state.placedTickets, isEmpty);

      state.dispose();
    });
  });

  group('GameHistoryScreen Widget Tests', () {
    testWidgets('Renders dashboard stats, category chips, and game cards', (WidgetTester tester) async {
      final state = AppState();
      final ana = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Ana_SpinQueen');
      state.loginAsDemo(ana);

      await tester.pumpWidget(
        MaterialApp(
          home: GameHistoryScreen(state: state),
        ),
      );

      // Verify AppBar and Header
      expect(find.text('Game Activity & Logs'), findsOneWidget);
      expect(find.text('Ana_SpinQueen'), findsAtLeastNWidgets(1));
      expect(find.text('Casino VIP'), findsOneWidget);

      // Verify Metric Tiles
      expect(find.text('SESSIONS / ROUNDS'), findsOneWidget);
      expect(find.text('TOTAL STAKED'), findsOneWidget);
      expect(find.text('TOTAL WON'), findsOneWidget);
      expect(find.text('WIN RATE'), findsOneWidget);

      // Verify Category Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Slots'), findsAtLeastNWidgets(1));
      expect(find.text('Table Games'), findsAtLeastNWidgets(1));
      expect(find.text('Blackjack'), findsOneWidget);
      expect(find.text('Roulette'), findsOneWidget);

      // Verify Game Cards
      expect(find.text('Shining Crown'), findsOneWidget);
      expect(find.text('Sweet Bonanza'), findsOneWidget);
      expect(find.text('Play Again'), findsAtLeastNWidgets(1));

      // Test expanding audit log
      final auditLogButton = find.textContaining('View Audit Log').first;
      await tester.ensureVisible(auditLogButton);
      await tester.tap(auditLogButton);
      await tester.pumpAndSettle();

      expect(find.text('ROUND-BY-ROUND AUDIT TRAIL'), findsAtLeastNWidgets(1));
      expect(find.text('#1'), findsAtLeastNWidgets(1));

      state.dispose();
    });

    testWidgets('Filtering by category updates visible game list', (WidgetTester tester) async {
      final state = AppState();
      final ana = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Ana_SpinQueen');
      state.loginAsDemo(ana);

      await tester.pumpWidget(
        MaterialApp(
          home: GameHistoryScreen(state: state),
        ),
      );

      // Initial list shows slot games
      expect(find.text('Shining Crown'), findsOneWidget);

      // Tap 'Table Games' filter chip
      await tester.tap(find.text('Table Games'));
      await tester.pumpAndSettle();

      // European Roulette is a Table Game and now visible at top of list
      expect(find.text('European Roulette Pro'), findsOneWidget);
      expect(find.text('Shining Crown'), findsNothing);

      // Tap 'Slots' filter chip
      await tester.tap(find.text('Slots'));
      await tester.pumpAndSettle();

      // Shining Crown is a Slot and now visible
      expect(find.text('Shining Crown'), findsOneWidget);
      expect(find.text('European Roulette Pro'), findsNothing);

      state.dispose();
    });

    testWidgets('Zero overflow check on narrow 320x568 screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppState();
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');
      state.loginAsDemo(marko);

      await tester.pumpWidget(
        MaterialApp(
          home: GameHistoryScreen(state: state),
        ),
      );

      await tester.pumpAndSettle();

      // Ensure no flutter overflow errors thrown
      expect(tester.takeException(), isNull);

      state.dispose();
    });
  });

  group('UserQuickResumeSection Widget Tests', () {
    testWidgets('Renders personalized header, casino games, and sports bet tickets', (WidgetTester tester) async {
      final state = AppState();
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');
      state.loginAsDemo(marko);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserQuickResumeSection(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('CONTINUE PLAYING'), findsOneWidget);
      expect(find.text('Welcome back, Marko_VIP!'), findsOneWidget);
      expect(find.text('All Logs'), findsOneWidget);

      // Verify Casino Cards
      expect(find.text('PSK VIP Blackjack'), findsOneWidget);
      expect(find.text('Play Again'), findsAtLeastNWidgets(1));

      // Tap Sports filter chip to view Sports Cards
      await tester.tap(find.textContaining('Sports ('));
      await tester.pumpAndSettle();

      // Verify Sports Cards
      expect(find.text('Real Madrid vs Manchester City'), findsOneWidget);
      expect(find.text('Re-Bet'), findsAtLeastNWidgets(1));

      state.dispose();
    });

    testWidgets('Re-Bet button loads ticket selections into BetSlip', (WidgetTester tester) async {
      final state = AppState();
      final luka = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Luka_HNL_Pro');
      state.loginAsDemo(luka);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserQuickResumeSection(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Sports filter so sports tickets are at the front
      await tester.tap(find.textContaining('Sports ('));
      await tester.pumpAndSettle();

      expect(find.text('Dinamo Zagreb vs Hajduk Split'), findsOneWidget);

      // Find and tap Re-Bet button
      final reBetFinder = find.text('Re-Bet').first;
      await tester.tap(reBetFinder);
      await tester.pumpAndSettle();

      // BetSlip now has the selection and navigation moved to BetSlip tab (index 2)
      expect(state.betSlip.count, greaterThan(0));
      expect(state.currentBottomNavIndex, equals(2));

      state.dispose();
    });

    testWidgets('casinoOnly mode hides sports bets and filter chips', (WidgetTester tester) async {
      final state = AppState();
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');
      state.loginAsDemo(marko);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserQuickResumeSection(state: state, casinoOnly: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Casino games are shown
      expect(find.text('PSK VIP Blackjack'), findsOneWidget);
      expect(find.text('Play Again'), findsAtLeastNWidgets(1));

      // Sports bets and sports filters are hidden
      expect(find.text('⚡ Re-Bet'), findsNothing);
      expect(find.textContaining('Sports ('), findsNothing);

      state.dispose();
    });

    testWidgets('Does not render when user is logged out', (WidgetTester tester) async {
      final state = AppState();
      state.logout();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserQuickResumeSection(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('CONTINUE PLAYING'), findsNothing);
      expect(find.text('Play Again'), findsNothing);

      state.dispose();
    });

    testWidgets('Zero overflow check on narrow 320x568 screen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppState();
      final marko = DemoUserProfile.demoProfiles.firstWhere((p) => p.username == 'Marko_VIP');
      state.loginAsDemo(marko);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: UserQuickResumeSection(state: state),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      state.dispose();
    });
  });
}
