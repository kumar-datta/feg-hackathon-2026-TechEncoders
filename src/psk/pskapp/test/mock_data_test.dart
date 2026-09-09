import 'package:flutter_test/flutter_test.dart';
import 'package:psk/data/mock_psk_data.dart';
import 'package:psk/models/sport_event.dart';
import 'package:psk/models/casino_game.dart';
import 'package:psk/navigation/psk_tabs.dart';
import 'package:psk/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockPskData & AppState Tests', () {
    test('Every SportType is represented in mock sports events', () {
      final events = MockPskData.getSportsEvents();
      expect(events.isNotEmpty, isTrue);

      for (final sport in SportType.values) {
        final matchesForSport = events.where((e) => e.sport == sport).toList();
        expect(matchesForSport.isNotEmpty, isTrue, reason: 'Sport ${sport.title} has no mock events');
      }
    });

    test('Every CasinoCategory is represented in mock casino games', () {
      final games = MockPskData.getCasinoGames();
      expect(games.isNotEmpty, isTrue);

      for (final cat in CasinoCategory.values) {
        final gamesForCat = games.where((g) => g.category == cat).toList();
        expect(gamesForCat.isNotEmpty, isTrue, reason: 'Category ${cat.title} has no mock games');
      }
    });

    test('Live events are present across multiple sports', () {
      final events = MockPskData.getSportsEvents();
      final liveEvents = events.where((e) => e.isLive).toList();
      expect(liveEvents.length, greaterThanOrEqualTo(8));
    });

    test('AppState filters correctly by time, sport, and live tab', () {
      final state = AppState();

      // Filter by Football
      state.setSport(SportType.football);
      expect(state.filteredEvents.every((e) => e.sport == SportType.football), isTrue);

      // Filter by Basketball
      state.setSport(SportType.basketball);
      expect(state.filteredEvents.every((e) => e.sport == SportType.basketball), isTrue);

      // Clear sport filter
      state.setSport(SportType.basketball); // toggle off
      expect(state.selectedSport, isNull);

      // Filter by 3h
      state.setTimeFilter('3h');
      expect(state.filteredEvents.isNotEmpty, isTrue);

      // Filter by Weekend
      state.setTimeFilter('Weekend');
      expect(state.filteredEvents.isNotEmpty, isTrue);

      // Live tab
      state.setTopTabIndex(PskTab.live);
      expect(state.filteredEvents.every((e) => e.isLive), isTrue);

      state.dispose();
    });
  });
}
