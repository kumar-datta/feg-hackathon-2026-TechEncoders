/// The available home-screen designs for the PSK Pulse Live Match widget.
/// [key] is what's persisted and what the Android Glance widget reads to
/// pick its layout — keep it stable once shipped.
enum LiveWidgetStyle {
  classic,
  minimal,
  oddsFocus,
  scoreboard;

  String get key {
    switch (this) {
      case LiveWidgetStyle.classic:
        return 'classic';
      case LiveWidgetStyle.minimal:
        return 'minimal';
      case LiveWidgetStyle.oddsFocus:
        return 'odds_focus';
      case LiveWidgetStyle.scoreboard:
        return 'scoreboard';
    }
  }

  String get label {
    switch (this) {
      case LiveWidgetStyle.classic:
        return 'Classic';
      case LiveWidgetStyle.minimal:
        return 'Minimal';
      case LiveWidgetStyle.oddsFocus:
        return 'Odds Focus';
      case LiveWidgetStyle.scoreboard:
        return 'Scoreboard';
    }
  }

  String get description {
    switch (this) {
      case LiveWidgetStyle.classic:
        return 'Score, minute and all three odds at a glance.';
      case LiveWidgetStyle.minimal:
        return 'Just the score and the clock — nothing else.';
      case LiveWidgetStyle.oddsFocus:
        return 'Odds take center stage, score stays small.';
      case LiveWidgetStyle.scoreboard:
        return 'Stadium scoreboard look, big centered score.';
    }
  }

  static const LiveWidgetStyle defaultStyle = LiveWidgetStyle.classic;

  static LiveWidgetStyle fromKey(String? key) {
    for (final style in LiveWidgetStyle.values) {
      if (style.key == key) return style;
    }
    return defaultStyle;
  }
}
