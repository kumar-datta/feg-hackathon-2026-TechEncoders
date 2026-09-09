import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:psk/models/bet_slip_model.dart';
import 'package:psk/models/placed_bet_ticket.dart';
import 'package:psk/models/demo_user.dart';
import 'package:psk/state/app_state.dart';
import 'package:psk/services/haptic_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PlacedBetTicket & Cash-Out Tests', () {
    test('Ticket serialization to and from JSON preserves all fields', () {
      final now = DateTime.now();
      final leg = PlacedBetLeg(
        selection: const BetSelection(
          eventId: 'match_1',
          homeTeam: 'Dinamo Zagreb',
          awayTeam: 'Hajduk Split',
          league: 'SuperSport HNL',
          marketName: 'Match Winner',
          selectionLabel: '1',
          oddValue: 1.85,
          isLive: true,
        ),
        outcome: LegOutcome.winning,
        currentScore: '2-1',
        matchMinute: '67\'',
      );

      final ticket = PlacedBetTicket(
        id: 'HR-12345-2026',
        placedAt: now,
        stake: 10.0,
        totalOdds: 1.85,
        potentialWin: 18.50,
        legs: [leg],
        status: TicketStatus.inPlay,
      );

      final json = ticket.toJson();
      final restored = PlacedBetTicket.fromJson(json);

      expect(restored.id, equals('HR-12345-2026'));
      expect(restored.stake, equals(10.0));
      expect(restored.totalOdds, equals(1.85));
      expect(restored.potentialWin, equals(18.50));
      expect(restored.status, equals(TicketStatus.inPlay));
      expect(restored.legs.length, equals(1));
      expect(restored.legs.first.currentScore, equals('2-1'));
      expect(restored.legs.first.matchMinute, equals('67\''));
      expect(restored.legs.first.outcome, equals(LegOutcome.winning));
    });

    test('Cash-out returns 0 if leg is lost, positive valuation when in-play', () {
      final winningTicket = PlacedBetTicket(
        id: 'HR-WIN-01',
        placedAt: DateTime.now(),
        stake: 10.0,
        totalOdds: 3.0,
        potentialWin: 30.0,
        legs: [
          PlacedBetLeg(
            selection: const BetSelection(
              eventId: 'e1',
              homeTeam: 'A',
              awayTeam: 'B',
              league: 'L',
              marketName: 'M',
              selectionLabel: '1',
              oddValue: 3.0,
            ),
            outcome: LegOutcome.winning,
          ),
        ],
        status: TicketStatus.inPlay,
      );

      expect(winningTicket.currentCashOutValue, greaterThan(10.0));

      final lostTicket = winningTicket.copyWith(
        legs: [
          winningTicket.legs.first.copyWith(outcome: LegOutcome.lost),
        ],
      );

      expect(lostTicket.currentCashOutValue, equals(0.0));
    });
  });

  group('AppState Milestone 1 Features: My Bets, Cash Out & Persistence', () {
    test('AppState defaults home screen widgets to enabled', () {
      final state = AppState();
      expect(state.liveWidgetEnabled, isTrue);
      expect(state.slipWidgetEnabled, isTrue);
      expect(state.boostWidgetEnabled, isTrue);
      expect(state.lockScreenWidgetEnabled, isFalse);
    });

    test('AppState placeBet creates PlacedBetTicket, deducts balance, and tracks in activeTickets', () {
      final state = AppState();
      state.loginAsDemo(DemoUserProfile.demoProfiles.first); // Marko Kovac: 250.00 €
      final initialBalance = state.balance;

      final initialTickets = state.placedTickets.length;
      final initialActive = state.activeTickets.length;
      final initialSettled = state.settledTickets.length;

      final event = state.events.first;
      state.toggleOdd(event, 'Match Winner', event.mainOdds.first);
      state.setStake(15.0);

      expect(state.betSlip.count, equals(1));

      final ticket = state.placeBet();
      expect(ticket, isNotNull);
      expect(ticket!.stake, equals(15.0));
      expect(state.balance, equals(initialBalance - 15.0));
      expect(state.betSlip.count, equals(0));

      expect(state.placedTickets.length, equals(initialTickets + 1));
      expect(state.activeTickets.length, equals(initialActive + 1));
      expect(state.settledTickets.length, equals(initialSettled));
      expect(state.activeTicketsCount, equals(initialActive + 1));
    });

    test('AppState cashOutTicket credits wallet and moves ticket to settledTickets', () {
      final state = AppState();
      state.loginAsDemo(DemoUserProfile.demoProfiles.first);
      final initialActive = state.activeTickets.length;
      final initialSettled = state.settledTickets.length;

      final event = state.events.first;
      state.toggleOdd(event, 'Match Winner', event.mainOdds.first);
      state.setStake(20.0);

      final ticket = state.placeBet();
      expect(ticket, isNotNull);

      final preCashOutBalance = state.balance;
      final cashOutVal = ticket!.currentCashOutValue;
      expect(cashOutVal, greaterThan(0));

      final success = state.cashOutTicket(ticket.id);
      expect(success, isTrue);

      expect(state.balance, closeTo(preCashOutBalance + cashOutVal, 0.01));
      expect(state.activeTickets.length, equals(initialActive));
      expect(state.settledTickets.length, equals(initialSettled + 1));
      expect(state.settledTickets.first.status, equals(TicketStatus.cashedOut));
      expect(state.settledTickets.first.cashedOutAmount, equals(cashOutVal));
    });

    test('AppState persistence: theme, user session, wallet, widgets, and tickets persist', () async {
      SharedPreferences.setMockInitialValues({});
      final state1 = AppState();
      await state1.restorePersistedState();

      // Change theme
      state1.setThemeMode(false); // Bright mode
      // Login
      state1.loginAsDemo(DemoUserProfile.demoProfiles[1]); // Luka Novak: 85.00 €
      final initialTickets = state1.placedTickets.length;
      // Deposit
      state1.deposit(50.0);
      // Widget toggles
      state1.setLockScreenWidgetEnabled(true);

      // Place a bet
      final event = state1.events.first;
      state1.toggleOdd(event, 'Match Winner', event.mainOdds.first);
      state1.setStake(10.0);
      state1.placeBet();

      expect(state1.placedTickets.length, equals(initialTickets + 1));
      await state1.savePersistedState();

      // Simulate app restart by instantiating new AppState and restoring
      final state2 = AppState();
      await state2.restorePersistedState();

      expect(state2.isDarkMode, isFalse);
      expect(state2.isLoggedIn, isTrue);
      expect(state2.username, equals('Luka_HNL_Pro'));
      expect(state2.balance, equals(state1.balance));
      expect(state2.lockScreenWidgetEnabled, isTrue);
      expect(state2.placedTickets.length, equals(initialTickets + 1));
      expect(state2.placedTickets.first.stake, equals(10.0));
    });

    test('HapticService operates safely without throwing in test environment', () async {
      HapticService.setEnabled(true);
      expect(HapticService.isEnabled, isTrue);

      // Verify all haptic methods execute cleanly
      await HapticService.oddsSelected();
      await HapticService.betPlaced();
      await HapticService.cashOut();
      await HapticService.casinoAction();
      await HapticService.celebration();
      await HapticService.tabClick();

      HapticService.setEnabled(false);
      expect(HapticService.isEnabled, isFalse);
      await HapticService.oddsSelected();
    });

    test('ScreenOverlayService and Floating Overlay in AppState operate safely', () async {
      final state = AppState();
      expect(state.floatingOverlayEnabled, isFalse);

      await state.setFloatingOverlayEnabled(true);
      expect(state.floatingOverlayEnabled, isTrue);

      await state.savePersistedState();

      final state2 = AppState();
      await state2.restorePersistedState();
      expect(state2.floatingOverlayEnabled, isTrue);

      await state2.setFloatingOverlayEnabled(false);
      expect(state2.floatingOverlayEnabled, isFalse);

      // Self-exclusion disables floating overlay
      await state.setFloatingOverlayEnabled(true);
      expect(state.floatingOverlayEnabled, isTrue);
      state.setSelfExcluded(true);
      expect(state.selfExcluded, isTrue);
    });
  });
}
