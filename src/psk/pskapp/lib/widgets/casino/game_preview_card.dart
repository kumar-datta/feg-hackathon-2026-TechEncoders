import 'package:flutter/material.dart';

import '../../casino/game_launcher.dart';
import '../../casino/game_preview_assets.dart';
import '../../models/casino_game.dart';
import '../../state/app_state.dart';
import '../../theme/psk_colors.dart';
import 'game_preview_sheet.dart';
import 'preview_video.dart';

/// Casino tile with an inline video preview.
///
/// Website behaviour: hovering plays the demo clip, clicking opens the preview
/// modal. On a phone there is no hover, so a **long-press** plays the clip and a
/// tap opens the preview sheet; on desktop/web hover still works.
class GamePreviewCard extends StatefulWidget {
  final CasinoGame game;
  final AppState state;
  final bool compact;

  const GamePreviewCard({super.key, required this.game, required this.state, this.compact = false});

  @override
  State<GamePreviewCard> createState() => _GamePreviewCardState();
}

class _GamePreviewCardState extends State<GamePreviewCard> {
  bool _playing = false;

  void _setPlaying(bool v) {
    if (_playing == v) return;
    setState(() => _playing = v);
  }

  Color _badgeColor(String badge) {
    if (badge == 'EXCLUSIVE' || badge == 'VIP CLUB') return PskColors.brandBlue;
    if (badge == 'PSK BRAND') return PskColors.accentGold;
    if (badge.contains('JACKPOT') || badge == 'PROGRESSIVE') return PskColors.warningOrange;
    if (badge.contains('LIVE')) return PskColors.liveGreen;
    return PskColors.alertRed;
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final isDark = widget.state.isDarkMode;
    final clip = GamePreviewAssets.clipFor(game);
    final art = GamePreviewAssets.artFor(game);

    final thumb = Stack(
      fit: StackFit.expand,
      children: [
        // gradient from the game's two hues, like the website's thumbGradient()
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                HSLColor.fromAHSL(1, game.hueA.toDouble(), 0.65, 0.38).toColor(),
                HSLColor.fromAHSL(1, game.hueB.toDouble(), 0.55, 0.22).toColor(),
              ],
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: _playing ? 0 : 1,
          duration: const Duration(milliseconds: 200),
          child: Image.asset(art, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
        ),
        PreviewVideo(asset: clip.video, poster: clip.poster, playing: _playing),
        if (!_playing)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 18, 8, 6),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC0E0E11)],
                ),
              ),
              child: Row(
                children: [
                  Text(game.emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      game.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (game.badge.isNotEmpty)
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _badgeColor(game.badge),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                game.badge,
                style: TextStyle(
                  color: game.badge == 'PSK BRAND' ? Colors.black : Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        if (game.hasJackpot && game.jackpotAmount != null && !_playing)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
              child: Text(
                '${game.jackpotAmount!.toStringAsFixed(0)} €',
                style: const TextStyle(color: PskColors.accentGold, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        if (_playing)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: PskColors.liveGreen, borderRadius: BorderRadius.circular(4)),
              child: const Text(
                '▶ PREVIEW',
                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => _setPlaying(true),
      onExit: (_) => _setPlaying(false),
      child: GestureDetector(
        onTap: () => GamePreviewSheet.show(context, widget.state, game),
        onLongPressStart: (_) => _setPlaying(true),
        onLongPressEnd: (_) => _setPlaying(false),
        onLongPressCancel: () => _setPlaying(false),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? PskColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: thumb),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      game.provider,
                      style: TextStyle(fontSize: 10, color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => GameLauncher.play(context, widget.state, game, isDemo: true),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(36, 28),
                              side: BorderSide(color: isDark ? PskColors.surfaceDarkAction : Colors.black26),
                              foregroundColor: isDark ? PskColors.textGray : Colors.black87,
                            ),
                            child: const FittedBox(fit: BoxFit.scaleDown, child: Text('Demo', style: TextStyle(fontSize: 10))),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => GameLauncher.play(context, widget.state, game),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PskColors.accentGold,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(36, 28),
                              elevation: 0,
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Play', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
