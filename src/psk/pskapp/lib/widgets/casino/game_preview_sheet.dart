import 'package:flutter/material.dart';

import '../../casino/game_launcher.dart';
import '../../casino/game_preview_assets.dart';
import '../../models/casino_game.dart';
import '../../state/app_state.dart';
import '../../theme/psk_colors.dart';
import 'preview_video.dart';

/// The bottom sheet shown when a casino tile is tapped: the demo clip
/// autoplays, with Play / Details underneath — the mobile version of the
/// website's GamePreviewCard modal.
class GamePreviewSheet extends StatefulWidget {
  final CasinoGame game;
  final AppState state;

  const GamePreviewSheet({super.key, required this.game, required this.state});

  static Future<void> show(BuildContext context, AppState state, CasinoGame game) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x990E0E11),
      builder: (_) => GamePreviewSheet(game: game, state: state),
    );
  }

  @override
  State<GamePreviewSheet> createState() => _GamePreviewSheetState();
}

class _GamePreviewSheetState extends State<GamePreviewSheet> {
  bool _showDetails = false;

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    final isDark = widget.state.isDarkMode;
    final clip = GamePreviewAssets.clipFor(game);
    final badges = <String>[
      if (game.isNew) 'NEW',
      if (game.isExclusive) 'EXCLUSIVE',
      if (game.hasJackpot) 'JACKPOT',
      if (game.isTableGame) 'LIVE TABLE',
      if (game.badge.isNotEmpty && !['NEW', 'EXCLUSIVE', 'JACKPOT'].contains(game.badge)) game.badge,
    ];

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? PskColors.bgDarkSecondary : PskColors.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: PskColors.surfaceDarkAction,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Preview stage
              SizedBox(
                height: 200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: PskColors.surfaceDarkPanel),
                    PreviewVideo(asset: clip.video, poster: clip.poster, playing: true),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, isDark ? PskColors.bgDarkSecondary : PskColors.surfaceLight],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: PskColors.liveGreen, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            '▶ PREVIEW',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(color: Color(0xCC363644), shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Metadata
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${game.emoji} ${game.title}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : PskColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(game.provider, style: const TextStyle(color: PskColors.textMuted, fontSize: 13)),
                    if (badges.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: badges
                            .map((b) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: PskColors.brandBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(b, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          GameLauncher.play(context, widget.state, game);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PskColors.accentGold,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('▶ Play', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showDetails = !_showDetails),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PskColors.surfaceDarkAction,
                          foregroundColor: PskColors.textGray,
                          minimumSize: const Size(0, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(_showDetails ? 'Hide details' : 'Details', style: const TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    GameLauncher.play(context, widget.state, game, isDemo: true);
                  },
                  child: const Text('Try demo mode (1000 € play credits)', style: TextStyle(color: PskColors.brandBlueLight, fontSize: 12)),
                ),
              ),

              // Details
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: _showDetails ? _details(game, isDark) : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _details(CasinoGame game, bool isDark) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Provider', game.provider),
      MapEntry('Type', game.engine.slug),
      MapEntry('RTP', '${game.rtp.toStringAsFixed(1)}%'),
      MapEntry('Volatility', game.volatility.label),
      MapEntry('Lines', game.lines == 0 ? '—' : '${game.lines}'),
      MapEntry('Bet Range', '${game.minBet.toStringAsFixed(2)} € – ${game.maxBet.toStringAsFixed(2)} €'),
      MapEntry('Jackpot', game.jackpotAmount != null ? '${_fmt(game.jackpotAmount!)} €' : 'None'),
      if (game.isTableGame) MapEntry('Players at table', '${game.players}'),
    ];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : PskColors.bgLightSecondary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
              color: i.isOdd ? (isDark ? PskColors.surfaceDarkPanel : Colors.white) : Colors.transparent,
              child: Row(
                children: [
                  Text(rows[i].key, style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
                  const Spacer(),
                  Text(
                    rows[i].value,
                    style: TextStyle(
                      color: isDark ? PskColors.textGray : PskColors.textDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'All figures are illustrative. This is a demo environment.',
            style: TextStyle(color: PskColors.textMuted, fontSize: 10, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    final parts = s.split('.');
    final buf = StringBuffer();
    final digits = parts[0];
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return '$buf.${parts[1]}';
  }
}
