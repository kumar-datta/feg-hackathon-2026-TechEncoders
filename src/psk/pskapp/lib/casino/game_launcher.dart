import 'package:flutter/material.dart';

import '../models/casino_game.dart';
import '../screens/casino/blackjack_game_screen.dart';
import '../screens/casino/roulette_game_screen.dart';
import '../screens/casino/slot_game_screen.dart';
import '../state/app_state.dart';

/// Routes a catalogue game into the playable engine — the one place that
/// decides which screen a title launches, shared by the casino grid, the home
/// rails, the preview sheet and the assistant.
class GameLauncher {
  GameLauncher._();

  static void play(BuildContext context, AppState state, CasinoGame game, {bool isDemo = false}) {
    final Widget target = switch (game.engine) {
      GameEngine.roulette => RouletteGameScreen(game: game, isDemo: isDemo, state: state),
      GameEngine.blackjack || GameEngine.baccarat => BlackjackGameScreen(game: game, isDemo: isDemo, state: state),
      _ => SlotGameScreen(game: game, isDemo: isDemo, state: state),
    };
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => target));
  }
}
