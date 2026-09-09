import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';

/// Virtual races — race type selector, countdown to the next race, a runner
/// list with odds, an animated track, and recent results.
class VirtualsView extends StatefulWidget {
  final AppState state;

  const VirtualsView({super.key, required this.state});

  @override
  State<VirtualsView> createState() => _VirtualsViewState();
}

class _Runner {
  final int number;
  final String name;
  final String jockey;
  final String form;
  final double odds;
  double position = 0;
  _Runner(this.number, this.name, this.jockey, this.form, this.odds);
}

class _RaceResult {
  final String race;
  final String winner;
  final double odds;
  final DateTime at;
  final bool userWon;
  _RaceResult(this.race, this.winner, this.odds, this.at, this.userWon);
}

class _VirtualsViewState extends State<VirtualsView> {
  VirtualGame _game = ContentData.virtuals.first;
  late List<_Runner> _runners;
  int _raceNo = 147;
  int? _selected;
  double _stake = 2.0;
  bool _running = false;
  bool _finished = false;
  int _countdown = 161;
  Timer? _tick;
  Timer? _raceTimer;
  final List<_RaceResult> _results = [];
  final _rng = Random();

  static const _cups = ['Meadow Cup', 'Harbour Stakes', 'Sunset Sprint', 'Golden Mile', 'Winter Derby', 'Coastal Chase'];
  static const _lane = [PskColors.alertRed, PskColors.brandBlue, Color(0xFF0B5C3A), PskColors.warningOrange, Color(0xFF7B2CBF), PskColors.accentGold, Color(0xFF00A6A6), Color(0xFFB0B0C0), Color(0xFFE91E63), Color(0xFF8BC34A), Color(0xFF3F51B5), Color(0xFF795548)];

  @override
  void initState() {
    super.initState();
    _newRace();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _running) return;
      setState(() {
        _countdown--;
        if (_countdown <= 0) {
          _newRace();
          _countdown = _game.intervalSeconds - 19;
        }
      });
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _raceTimer?.cancel();
    super.dispose();
  }

  void _newRace() {
    final names = List<String>.from(ContentData.runnerNames)..shuffle(_rng);
    final jockeys = List<String>.from(ContentData.jockeys)..shuffle(_rng);
    _runners = List.generate(_game.runners, (i) {
      final form = List.generate(5, (_) => 1 + _rng.nextInt(6)).join('-');
      final odds = (1.8 + _rng.nextDouble() * 9 * 100).round() / 100;
      return _Runner(i + 1, names[i % names.length], '${jockeys[i % jockeys.length]} / ${jockeys[(i + 3) % jockeys.length]}', form, odds);
    });
    _raceNo++;
    _selected = null;
    _finished = false;
  }

  void _selectGame(VirtualGame g) {
    if (_running) return;
    setState(() {
      _game = g;
      _countdown = 40 + _rng.nextInt(120);
      _newRace();
    });
  }

  void _start() {
    final state = widget.state;
    if (_running) return;
    if (!state.isLoggedIn) {
      AuthDialog.show(context, state, isRegister: false);
      return;
    }
    if (_selected == null) {
      _snack('Pick a runner first', error: true);
      return;
    }
    if (_stake > state.balance) {
      _snack('Insufficient balance. Please deposit funds.', error: true);
      return;
    }
    setState(() {
      _running = true;
      _finished = false;
      for (final r in _runners) {
        r.position = 0;
      }
    });
    var ticks = 0;
    _raceTimer = Timer.periodic(const Duration(milliseconds: 220), (t) {
      if (!mounted) return;
      ticks++;
      setState(() {
        for (final r in _runners) {
          r.position = min(1.0, r.position + (_rng.nextDouble() * 3) / 40);
        }
      });
      if (ticks >= 18 || _runners.any((r) => r.position >= 1.0)) {
        t.cancel();
        _finish();
      }
    });
  }

  void _finish() {
    final winner = _runners.reduce((a, b) => a.position >= b.position ? a : b);
    final picked = _runners[_selected!];
    final userWon = winner == picked;
    final win = userWon ? (_stake * picked.odds * 100).round() / 100 : 0.0;
    widget.state.settleInstantRound(
      gameId: 'virtual_${_game.slug}',
      title: '${_game.name} — Race $_raceNo',
      category: 'Virtuals',
      icon: _game.icon,
      stake: _stake,
      win: win,
      summary: 'Winner: ${winner.name} @ ${winner.odds.toStringAsFixed(2)} · you picked ${picked.name}',
      logs: _runners.map((r) => '#${r.number} ${r.name} — ${(r.position * 100).round()}%').toList(),
    );
    setState(() {
      _running = false;
      _finished = true;
      _results.insert(0, _RaceResult('Race $_raceNo — ${_cups[_raceNo % _cups.length]}', winner.name, winner.odds, DateTime.now(), userWon));
      _countdown = _game.intervalSeconds - 19;
    });
    _snack(userWon ? '🏆 ${winner.name} wins — you won ${win.toStringAsFixed(2)} €!' : '${winner.name} wins. Better luck next race.',
        error: !userWon);
    Future<void>.delayed(const Duration(seconds: 4), () {
      if (mounted && !_running) setState(_newRace);
    });
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? PskColors.alertRed : PskColors.liveGreen,
    ));
  }

  String _mmss(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

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
          child: Text('🎮 Virtual Races', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text('Bet on simulated horse and greyhound races every few minutes',
              style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
        ),

        // Race type selector
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ContentData.virtuals.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final g = ContentData.virtuals[i];
              final sel = g == _game;
              return GestureDetector(
                onTap: () => _selectGame(g),
                child: Container(
                  width: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: sel ? PskColors.surfaceDarkPanel : panel,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      // 3 px accent bar marks the selected race type
                      Container(width: 3, color: sel ? PskColors.brandBlue : Colors.transparent),
                      const SizedBox(width: 9),
                      Text(g.icon, style: const TextStyle(fontSize: 26)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(g.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(g.intervalLabel, style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Upcoming race card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_running ? 'Race in progress' : 'Next Race', style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
                  const Spacer(),
                  Text(_running ? '🔴 LIVE' : _mmss(_countdown),
                      style: const TextStyle(color: PskColors.alertRed, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              Text('Race $_raceNo — ${_cups[_raceNo % _cups.length]}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_game.track, style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
            ],
          ),
        ),

        // Track visualisation
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          height: 200,
          decoration: BoxDecoration(color: PskColors.surfaceDarkPanel, borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                right: 18,
                top: 8,
                bottom: 8,
                child: Column(
                  children: List.generate(12, (i) => Expanded(child: Container(width: 2, color: i.isEven ? Colors.white54 : Colors.transparent))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 26, 40, 10),
                child: Column(
                  children: List.generate(_runners.length, (i) {
                    final r = _runners[i];
                    return Expanded(
                      child: LayoutBuilder(
                        builder: (context, c) => Stack(
                          children: [
                            Positioned(
                              left: 0,
                              right: 0,
                              top: c.maxHeight / 2 - 0.5,
                              child: Container(height: 1, color: Colors.white10),
                            ),
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 200),
                              left: r.position * (c.maxWidth - 16),
                              top: max(0, c.maxHeight / 2 - 7),
                              child: Container(
                                width: 14,
                                height: 14,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: _lane[i % _lane.length],
                                  shape: BoxShape.circle,
                                  border: Border.all(color: _selected == i ? Colors.white : Colors.transparent, width: 2),
                                ),
                                child: Text('${r.number}', style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Positioned(
                left: 10,
                top: 8,
                child: Row(
                  children: [
                    Container(width: 7, height: 7, decoration: const BoxDecoration(color: PskColors.alertRed, shape: BoxShape.circle)),
                    const SizedBox(width: 5),
                    Text(_running ? 'LIVE' : (_finished ? 'RESULT' : 'NEXT UP'),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (!_running && !_finished)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _start,
                    child: Container(
                      color: Colors.black26,
                      alignment: Alignment.center,
                      child: const Text('Tap to watch race', style: TextStyle(color: PskColors.textMuted, fontSize: 13)),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Runners
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(
            children: [
              const Text('Runners', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [1.0, 2.0, 5.0, 10.0]
                        .map((v) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: ChoiceChip(
                                label: Text('${v.toStringAsFixed(0)} €', style: const TextStyle(fontSize: 10)),
                                selected: _stake == v,
                                onSelected: _running ? null : (_) => setState(() => _stake = v),
                                selectedColor: PskColors.brandBlue,
                                labelStyle: TextStyle(color: _stake == v ? Colors.white : PskColors.textGray),
                                visualDensity: VisualDensity.compact,
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        ..._runners.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          final sel = _selected == i;
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 3, 16, 3),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: sel ? PskColors.brandBlue : Colors.transparent),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: _lane[i % _lane.length], shape: BoxShape.circle),
                  child: Text('${r.number}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text(r.jockey, style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
                      Text(r.form, style: const TextStyle(color: PskColors.textGray, fontSize: 10, fontFamily: 'monospace')),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _running ? null : () => setState(() => _selected = sel ? null : i),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 60,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: sel ? PskColors.brandBlue : PskColors.surfaceDarkPanel,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r.odds.toStringAsFixed(2),
                        style: TextStyle(color: sel ? Colors.white : PskColors.accentGold, fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _running ? null : _start,
              style: ElevatedButton.styleFrom(
                backgroundColor: PskColors.accentGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                !state.isLoggedIn
                    ? 'LOG IN TO BET'
                    : (_selected == null ? 'PICK A RUNNER' : 'BET ${_stake.toStringAsFixed(0)} € ON #${_runners[_selected!].number} · START RACE'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ),

        // Results
        if (_results.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 6),
            child: Text('Recent Results', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final r = _results[i];
                final ago = DateTime.now().difference(r.at).inMinutes;
                return Container(
                  width: 180,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.race, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text('🏆 ${r.winner}', style: const TextStyle(fontSize: 12)),
                      Row(
                        children: [
                          Text(r.odds.toStringAsFixed(2), style: const TextStyle(color: PskColors.moneyGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                          const Spacer(),
                          Text(ago < 1 ? 'just now' : '$ago min ago', style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Text('Races are simulated on the device for demonstration. Odds and form are generated.',
              style: TextStyle(color: PskColors.textMuted, fontSize: 10)),
        ),
      ],
    );
  }
}
