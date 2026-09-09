import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';

/// Swipe & Bet — a card stack of suggested bets. Swipe right (or ✓) to add the
/// suggested market to the slip, left (or ✕) to reject, up (or ↷) to skip.
/// Arrow keys work on desktop/web, like the website.
class SwipeBetWidget extends StatefulWidget {
  final AppState state;

  const SwipeBetWidget({super.key, required this.state});

  @override
  State<SwipeBetWidget> createState() => _SwipeBetWidgetState();
}

class _SwipeBetWidgetState extends State<SwipeBetWidget> with SingleTickerProviderStateMixin {
  late List<SportEvent> _pool;
  int _index = 0;
  int _added = 0;
  int _skipped = 0;
  Offset _drag = Offset.zero;
  Offset _flyTarget = Offset.zero;
  bool _flying = false;
  late final AnimationController _fly = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _pool = List<SportEvent>.from(widget.state.events.where((e) => e.mainOdds.isNotEmpty))..shuffle(Random());
    if (_pool.length > 60) _pool = _pool.sublist(0, 60);
    _fly.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() {
          _flying = false;
          _drag = Offset.zero;
          _index++;
        });
        _fly.reset();
      }
    });
  }

  @override
  void dispose() {
    _fly.dispose();
    _focus.dispose();
    super.dispose();
  }

  SportEvent? get _current => _index < _pool.length ? _pool[_index] : null;

  /// Suggested market for the card — deterministic per event, like the website.
  OddOption _suggested(SportEvent e) => e.mainOdds[e.id.hashCode.abs() % e.mainOdds.length];

  void _advance(String direction, {required bool add}) {
    final cur = _current;
    if (cur == null || _flying) return;
    if (add) {
      final opt = _suggested(cur);
      if (!widget.state.isOddSelected(cur.id, 'Match Winner', opt.label)) {
        widget.state.toggleOdd(cur, 'Match Winner', opt);
      }
      _added++;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text('Added ${cur.homeTeam} – ${cur.awayTeam} (${opt.label} @ ${opt.value.toStringAsFixed(2)}) to your betslip'),
          backgroundColor: PskColors.brandBlue,
          duration: const Duration(seconds: 1),
        ));
    } else {
      _skipped++;
    }
    final w = MediaQuery.of(context).size.width;
    setState(() {
      _flying = true;
      _flyTarget = switch (direction) {
        'right' => Offset(w * 1.2, 40),
        'left' => Offset(-w * 1.2, 40),
        _ => Offset(0, -700),
      };
    });
    _fly.forward();
  }

  void _restart() {
    setState(() {
      _pool.shuffle(Random());
      _index = 0;
      _added = 0;
      _skipped = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final cur = _current;

    return KeyboardListener(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (e) {
        if (e is! KeyDownEvent) return;
        if (e.logicalKey == LogicalKeyboardKey.arrowRight) _advance('right', add: true);
        if (e.logicalKey == LogicalKeyboardKey.arrowLeft) _advance('left', add: false);
        if (e.logicalKey == LogicalKeyboardKey.arrowUp) _advance('up', add: false);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
        children: [
          Row(
            children: [
              const Icon(Icons.swipe, color: PskColors.accentGold, size: 28),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('👆 SWIPE & BET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
                    Text('Swipe right to add to betslip, left to skip. Build your ticket in seconds.',
                        style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Card stack
          SizedBox(
            height: 330,
            child: cur == null
                ? _doneCard(isDark)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_index + 1 < _pool.length)
                        Transform.translate(
                          offset: const Offset(6, 8),
                          child: Transform.scale(scale: 0.96, child: _ghostCard(_pool[_index + 1], isDark)),
                        ),
                      AnimatedBuilder(
                        animation: _fly,
                        builder: (context, child) {
                          final off = _flying ? Offset.lerp(_drag, _flyTarget, Curves.easeIn.transform(_fly.value))! : _drag;
                          final angle = (off.dx / 300).clamp(-0.3, 0.3);
                          return Transform.translate(
                            offset: off,
                            child: Transform.rotate(angle: angle, child: child),
                          );
                        },
                        child: GestureDetector(
                          onPanUpdate: (d) => setState(() => _drag += d.delta),
                          onPanEnd: (_) {
                            if (_drag.dx > 90) {
                              _advance('right', add: true);
                            } else if (_drag.dx < -90) {
                              _advance('left', add: false);
                            } else if (_drag.dy < -90) {
                              _advance('up', add: false);
                            } else {
                              setState(() => _drag = Offset.zero);
                            }
                          },
                          child: _card(cur, isDark),
                        ),
                      ),
                      if (_drag.dx.abs() > 30)
                        Positioned(
                          top: 18,
                          left: _drag.dx > 0 ? 24 : null,
                          right: _drag.dx < 0 ? 24 : null,
                          child: Transform.rotate(
                            angle: _drag.dx > 0 ? -0.3 : 0.3,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: _drag.dx > 0 ? PskColors.moneyGreen : PskColors.alertRed, width: 3),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(_drag.dx > 0 ? 'ADD' : 'SKIP',
                                  style: TextStyle(
                                      color: _drag.dx > 0 ? PskColors.moneyGreen : PskColors.alertRed, fontWeight: FontWeight.w900, fontSize: 22)),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),

          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _actionButton('✕', 'SKIP', PskColors.alertRed, () => _advance('left', add: false), enabled: cur != null),
              const SizedBox(width: 26),
              _actionButton('↷', 'NEXT', PskColors.textMuted, () => _advance('up', add: false), enabled: cur != null),
              const SizedBox(width: 26),
              _actionButton('✓', 'ADD', PskColors.moneyGreen, () => _advance('right', add: true), enabled: cur != null),
            ],
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text('← skip · ↑ next · → add to slip', style: TextStyle(color: PskColors.textMuted, fontSize: 10)),
          ),

          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? PskColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
            ),
            child: Column(
              children: [
                Text('On slip: ${state.betSlip.count} selection${state.betSlip.count == 1 ? '' : 's'} · total odds ${state.betSlip.totalOdds.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => state.setBottomNavIndex(PskBottomTab.betslip),
                    style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black, elevation: 0),
                    child: const Text('OPEN BETSLIP', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('How it works', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            '1. A random pool of up to 60 events is shuffled.\n'
            '2. Each card shows one event with a suggested market and odd.\n'
            '3. Swipe right to add the selection to your betslip.\n'
            '4. Swipe left to skip.\n'
            '5. When done, review the betslip and place your ticket.',
            style: TextStyle(color: PskColors.textMuted, fontSize: 12, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _card(SportEvent e, bool isDark) {
    final opt = _suggested(e);
    return Container(
      width: double.infinity,
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('${e.sport.icon} ${e.leagueCountry} · ${e.league}',
                    style: const TextStyle(fontSize: 12, color: PskColors.textMuted), overflow: TextOverflow.ellipsis),
              ),
              if (e.isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: PskColors.alertRed, borderRadius: BorderRadius.circular(4)),
                  child: Text('LIVE ${e.liveMinute ?? ''}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Team names scale down instead of overflowing on narrow phones.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.homeTeam, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text('—', style: TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold)),
                  ),
                  Text(e.awayTeam, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text(
                    e.isLive ? 'LIVE · ${e.liveMinute ?? ''} · Score ${e.homeScore ?? 0}:${e.awayScore ?? 0}' : 'Kickoff: ${e.startTime}',
                    style: TextStyle(fontSize: 12, color: e.isLive ? PskColors.alertRed : PskColors.textMuted, fontWeight: e.isLive ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(color: PskColors.surfaceDarkPanel, borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text('MARKET: ${opt.label}', style: const TextStyle(color: PskColors.textMuted, fontSize: 11, letterSpacing: 0.6)),
                const SizedBox(height: 4),
                Text(opt.value.toStringAsFixed(2), style: const TextStyle(color: PskColors.accentGold, fontSize: 34, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text('Code #${4800 + (e.id.hashCode % 200).abs()} · Card ${_index + 1}/${_pool.length}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _ghostCard(SportEvent e, bool isDark) => Container(
        width: double.infinity,
        height: 320,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? PskColors.surfaceDark.withValues(alpha: 0.7) : Colors.white70,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
        ),
        alignment: Alignment.topCenter,
        child: Text('Next: ${e.homeTeam} – ${e.awayTeam}', style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
      );

  Widget _doneCard(bool isDark) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? PskColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 10),
            const Text('All events reviewed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Total: ${_pool.length}   ·   Added to slip: $_added   ·   Skipped: $_skipped',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => widget.state.setTopTabIndex(PskTab.sports),
                  style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black, elevation: 0),
                  child: const Text('OPEN SPORTSBOOK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                OutlinedButton(onPressed: _restart, child: const Text('RESTART')),
              ],
            ),
          ],
        ),
      );

  Widget _actionButton(String glyph, String label, Color color, VoidCallback onTap, {required bool enabled}) {
    return Column(
      children: [
        Material(
          color: PskColors.surfaceDarkAction,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: enabled ? onTap : null,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 58,
              height: 58,
              child: Center(child: Text(glyph, style: TextStyle(color: enabled ? color : PskColors.textMuted, fontSize: 26, fontWeight: FontWeight.bold))),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: PskColors.textMuted, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
