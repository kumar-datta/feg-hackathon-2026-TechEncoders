import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';

/// Lotto — six draws, a number grid with hot numbers, quick pick, an animated
/// ball machine, and settled results.
class LottoView extends StatefulWidget {
  final AppState state;

  const LottoView({super.key, required this.state});

  @override
  State<LottoView> createState() => _LottoViewState();
}

class _LottoViewState extends State<LottoView> with SingleTickerProviderStateMixin {
  LotteryGame _game = ContentData.lotteries.first;
  final Set<int> _selected = {};
  List<int> _drawn = [];
  List<int>? _lastResult;
  int? _lastHits;
  double? _lastPrize;
  bool _drawing = false;
  double _stake = 1.0;
  Timer? _reveal;
  late final AnimationController _bounce = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  final _rng = Random();

  @override
  void dispose() {
    _reveal?.cancel();
    _bounce.dispose();
    super.dispose();
  }

  void _selectGame(LotteryGame g) {
    if (_drawing) return;
    setState(() {
      _game = g;
      _stake = g.price;
      _selected.clear();
      _drawn = [];
      _lastResult = null;
      _lastHits = null;
      _lastPrize = null;
    });
  }

  void _toggle(int n) {
    if (_drawing) return;
    setState(() {
      if (_selected.contains(n)) {
        _selected.remove(n);
      } else if (_selected.length < _game.pick) {
        _selected.add(n);
      }
    });
  }

  void _quickPick() {
    if (_drawing) return;
    final next = <int>{};
    while (next.length < _game.pick) {
      next.add(1 + _rng.nextInt(_game.max));
    }
    setState(() {
      _selected
        ..clear()
        ..addAll(next);
      _drawn = [];
    });
  }

  void _draw() {
    final state = widget.state;
    if (_drawing) return;
    if (!state.isLoggedIn) {
      AuthDialog.show(context, state, isRegister: false);
      return;
    }
    if (_selected.length != _game.pick) {
      _snack('Pick exactly ${_game.pick} numbers', error: true);
      return;
    }
    if (_stake > state.balance) {
      _snack('Insufficient balance. Please deposit funds.', error: true);
      return;
    }

    final pool = <int>{};
    while (pool.length < _game.pick) {
      pool.add(1 + _rng.nextInt(_game.max));
    }
    final numbers = pool.toList();

    setState(() {
      _drawing = true;
      _drawn = [];
      _lastResult = null;
    });

    var i = 0;
    _reveal = Timer.periodic(const Duration(milliseconds: 420), (t) {
      if (!mounted) return;
      setState(() => _drawn = numbers.take(i + 1).toList());
      i++;
      if (i >= numbers.length) {
        t.cancel();
        _settle(numbers);
      }
    });
  }

  void _settle(List<int> numbers) {
    final hits = numbers.where(_selected.contains).length;
    final mult = ContentData.lotteryPayTable[hits];
    final win = hits >= 3 && mult != null ? (_stake * mult * 100).round() / 100 : 0.0;
    widget.state.settleInstantRound(
      gameId: 'loto_${_game.slug}',
      title: _game.name,
      category: 'Lottery',
      icon: _game.icon,
      stake: _stake,
      win: win,
      summary: '$hits/${_game.pick} matched · ${win > 0 ? 'won ${win.toStringAsFixed(2)} €' : 'no win'}',
      logs: ['Picked: ${_selected.join(', ')}', 'Drawn: ${numbers.join(', ')}', 'Hits: $hits'],
    );
    setState(() {
      _drawing = false;
      _lastResult = numbers;
      _lastHits = hits;
      _lastPrize = win;
    });
    _snack(win > 0 ? '🎉 $hits matches — you won ${win.toStringAsFixed(2)} €!' : '$hits matches — no win this round.',
        error: win == 0);
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? PskColors.alertRed : PskColors.liveGreen,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final panel = isDark ? PskColors.surfaceDark : Colors.white;

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 2),
          child: Text('🎱 Lotto', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text('Choose your numbers and try your luck in 6 lottery draws',
              style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
        ),

        // Game selector
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            itemCount: ContentData.lotteries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final g = ContentData.lotteries[i];
              final sel = g == _game;
              return GestureDetector(
                onTap: () => _selectGame(g),
                child: AnimatedScale(
                  scale: sel ? 1.03 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: Container(
                    width: 140,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          HSLColor.fromAHSL(1, g.hueA.toDouble(), 0.7, 0.42).toColor(),
                          HSLColor.fromAHSL(1, g.hueB.toDouble(), 0.65, 0.22).toColor(),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? PskColors.accentGold : Colors.transparent, width: 2),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(g.icon, style: const TextStyle(fontSize: 22)),
                          Text(g.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(g.drawInfo, style: const TextStyle(color: Colors.white70, fontSize: 9)),
                          Text('${_fmt(g.jackpot)} €', style: const TextStyle(color: PskColors.accentGold, fontSize: 13, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Number grid
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: Text('Pick ${_game.pick} numbers from 1–${_game.max}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              Text('${_selected.length}/${_game.pick}', style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_game.max, (i) {
              final n = i + 1;
              final sel = _selected.contains(n);
              final drawn = _drawn.contains(n);
              final hot = _game.hotNumbers.contains(n);
              return GestureDetector(
                onTap: () => _toggle(n),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: drawn ? PskColors.accentGold : (sel ? PskColors.brandBlue : PskColors.surfaceDarkPanel),
                        shape: BoxShape.circle,
                        boxShadow: sel ? [BoxShadow(color: PskColors.brandBlue.withValues(alpha: 0.5), blurRadius: 8)] : null,
                      ),
                      child: Text('$n',
                          style: TextStyle(
                            color: drawn ? Colors.black : (sel ? Colors.white : PskColors.textGray),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ),
                    if (hot)
                      Positioned(
                        top: 1,
                        right: 1,
                        child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: PskColors.alertRed, shape: BoxShape.circle)),
                      ),
                  ],
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            height: 40,
            child: TextButton.icon(
              onPressed: _quickPick,
              icon: const Text('🎲'),
              label: const Text('Random Pick'),
              style: TextButton.styleFrom(
                backgroundColor: PskColors.surfaceDarkAction,
                foregroundColor: PskColors.textGray,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              Icon(Icons.circle, size: 7, color: PskColors.alertRed),
              SizedBox(width: 4),
              Text('= frequently drawn number', style: TextStyle(color: PskColors.textMuted, fontSize: 10)),
            ],
          ),
        ),

        // Draw machine
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          height: 220,
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 190,
                    height: 150,
                    decoration: BoxDecoration(
                      color: PskColors.surfaceDarkPanel,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(95), bottom: Radius.circular(20)),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: AnimatedBuilder(
                      animation: _bounce,
                      builder: (context, _) {
                        final balls = _drawn.isNotEmpty ? _drawn : (_selected.isNotEmpty ? _selected.toList() : List.generate(_game.pick, (i) => i + 1));
                        return Stack(
                          children: List.generate(min(balls.length, 10), (i) {
                            final t = _bounce.value * 2 * pi + i * 1.3;
                            final x = 24.0 + (i % 5) * 30 + sin(t) * 6;
                            final y = 40.0 + (i ~/ 5) * 44 + cos(t * 1.4) * 10;
                            final lit = _drawn.contains(balls[i]) && _drawing || _lastResult != null && _drawn.contains(balls[i]);
                            return Positioned(
                              left: x,
                              top: y,
                              child: Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: lit
                                        ? const [PskColors.accentGold, PskColors.warningOrange]
                                        : [
                                            HSLColor.fromAHSL(1, _game.hueA.toDouble(), 0.7, 0.5).toColor(),
                                            HSLColor.fromAHSL(1, _game.hueB.toDouble(), 0.65, 0.3).toColor(),
                                          ],
                                  ),
                                ),
                                child: Text('${balls[i]}',
                                    style: TextStyle(color: lit ? Colors.black : Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_drawing ? 'Drawing…' : 'Next draw: ${_game.drawInfo}',
                    style: const TextStyle(color: PskColors.accentGold, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),

        // Stake + draw button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('Stake', style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
                const SizedBox(width: 8),
                ...[0.5, 1.0, 2.0, 5.0].map((v) => Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('${v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2)} €', style: const TextStyle(fontSize: 11)),
                        selected: _stake == v,
                        onSelected: _drawing ? null : (_) => setState(() => _stake = v),
                        selectedColor: PskColors.brandBlue,
                        labelStyle: TextStyle(color: _stake == v ? Colors.white : PskColors.textGray),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    )),
                const SizedBox(width: 12),
                Text('Balance ${state.balance.toStringAsFixed(2)} €', style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _drawing ? null : _draw,
              style: ElevatedButton.styleFrom(
                backgroundColor: PskColors.accentGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(state.isLoggedIn ? 'DRAW NOW' : 'LOG IN TO PLAY', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ),

        // Results
        if (_lastResult != null)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Latest Results', style: TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text(_today(), style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _lastResult!
                      .map((n) => Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selected.contains(n) ? PskColors.accentGold : PskColors.brandBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text('$n',
                                style: TextStyle(
                                    color: _selected.contains(n) ? Colors.black : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Text('Your matches: $_lastHits/${_game.pick}',
                    style: TextStyle(color: (_lastHits ?? 0) >= 3 ? PskColors.moneyGreen : PskColors.alertRed, fontWeight: FontWeight.bold)),
                Text((_lastPrize ?? 0) > 0 ? 'Prize: ${_lastPrize!.toStringAsFixed(2)} €' : 'No win this round',
                    style: TextStyle(color: (_lastPrize ?? 0) > 0 ? PskColors.accentGold : PskColors.textMuted, fontSize: 13)),
              ],
            ),
          ),

        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text(
            'Draws are simulated on the device for demonstration. Pay table: 3 hits ×2 · 4 ×8 · 5 ×40 · 6 ×400 · 7 ×5000. All figures are illustrative.',
            style: TextStyle(color: PskColors.textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  String _today() {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
  }

  static String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
