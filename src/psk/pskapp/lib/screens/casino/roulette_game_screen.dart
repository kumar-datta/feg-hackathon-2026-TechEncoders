import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/psk_colors.dart';
import '../../models/casino_game.dart';
import '../../models/played_game_log.dart';
import '../../state/app_state.dart';
import '../../services/haptic_service.dart';

class RouletteGameScreen extends StatefulWidget {
  final CasinoGame game;
  final bool isDemo;
  final AppState state;

  const RouletteGameScreen({
    super.key,
    required this.game,
    required this.isDemo,
    required this.state,
  });

  @override
  State<RouletteGameScreen> createState() => _RouletteGameScreenState();
}

class _RouletteGameScreenState extends State<RouletteGameScreen> with SingleTickerProviderStateMixin {
  late double _balance;
  final List<double> _chipValues = [1.0, 5.0, 10.0, 25.0, 50.0, 100.0];
  int _selectedChipIndex = 1; // Default 5€ chip

  // Placed Bets: Map of betKey -> amount
  final Map<String, double> _placedBets = {};
  final List<Map<String, dynamic>> _recentResults = [
    {'number': 17, 'color': 'black'},
    {'number': 32, 'color': 'red'},
    {'number': 0, 'color': 'green'},
    {'number': 7, 'color': 'red'},
    {'number': 24, 'color': 'black'},
  ];

  static const List<int> redNumbers = [
    1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36
  ];

  bool _isSpinning = false;
  int? _winningNumber;
  String _winningColor = '';
  double _lastWin = 0.0;
  String _statusMessage = 'Place your bets and tap SPIN';

  late AnimationController _wheelController;
  late Animation<double> _wheelAnimation;
  double _currentWheelAngle = 0.0;
  double _targetWheelAngle = 0.0;

  // Quantum Multipliers (e.g. 50x, 100x, 500x) for Quantum Roulette
  Map<int, int> _quantumMultipliers = {};

  int _sessionSpins = 0;
  double _sessionTotalStake = 0.0;
  double _sessionTotalWin = 0.0;
  double _lastRoundStake = 0.0;
  final List<String> _sessionDetailedLogs = [];

  @override
  void initState() {
    super.initState();
    _balance = widget.isDemo ? 1000.00 : widget.state.balance;

    _wheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _wheelAnimation = CurvedAnimation(
      parent: _wheelController,
      curve: Curves.decelerate,
    );

    _wheelController.addListener(() {
      setState(() {
        _currentWheelAngle = _targetWheelAngle * _wheelAnimation.value;
      });
    });

    _wheelController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSpinComplete();
      }
    });
  }

  @override
  void dispose() {
    _saveSessionToHistory();
    _wheelController.dispose();
    super.dispose();
  }

  void _saveSessionToHistory() {
    if (_sessionSpins > 0) {
      final net = _sessionTotalWin - _sessionTotalStake;
      final summary = net >= 0
          ? 'Won ${_sessionTotalWin.toStringAsFixed(2)} € over $_sessionSpins spin${_sessionSpins > 1 ? 's' : ''}'
          : 'Staked ${_sessionTotalStake.toStringAsFixed(2)} € over $_sessionSpins spin${_sessionSpins > 1 ? 's' : ''}';
      widget.state.addGameLog(
        PlayedGameLog(
          id: 'roulette_${DateTime.now().millisecondsSinceEpoch}',
          gameId: widget.game.id,
          gameTitle: widget.game.title,
          category: 'Table Games',
          provider: widget.game.provider,
          gameIcon: '🎡',
          timestamp: DateTime.now(),
          stake: double.parse(_sessionTotalStake.toStringAsFixed(2)),
          winAmount: double.parse(_sessionTotalWin.toStringAsFixed(2)),
          roundsPlayed: _sessionSpins,
          summary: summary,
          detailedLogs: List.unmodifiable(_sessionDetailedLogs),
        ),
      );
    }
  }

  double get _currentChip => _chipValues[_selectedChipIndex];

  double get _totalBetAmount =>
      _placedBets.values.fold(0.0, (sum, val) => sum + val);

  void _placeBet(String betKey) {
    if (_isSpinning) return;
    if (_balance < _currentChip) {
      setState(() {
        _statusMessage = 'Insufficient balance for this chip!';
      });
      return;
    }

    HapticService.oddsSelected();
    setState(() {
      _placedBets[betKey] = (_placedBets[betKey] ?? 0.0) + _currentChip;
      _balance -= _currentChip;
      if (!widget.isDemo) {
        widget.state.deposit(-_currentChip);
      }
      final curVal = _placedBets[betKey]!.toStringAsFixed(0);
      final label = betKey.toUpperCase();
      _statusMessage = 'Bet on $label: $curVal €';
    });
  }

  void _clearBets() {
    if (_isSpinning || _placedBets.isEmpty) return;
    setState(() {
      final refund = _totalBetAmount;
      _balance += refund;
      if (!widget.isDemo) {
        widget.state.deposit(refund);
      }
      _placedBets.clear();
      _statusMessage = 'Bets cleared';
    });
  }

  void _spin() {
    if (_isSpinning || _placedBets.isEmpty) return;

    _lastRoundStake = _totalBetAmount;
    _sessionSpins++;
    _sessionTotalStake += _lastRoundStake;

    HapticService.casinoAction();
    final rand = Random();
    final winNum = rand.nextInt(37); // 0 to 36
    final winCol = winNum == 0 ? 'green' : (redNumbers.contains(winNum) ? 'red' : 'black');

    // Generate Quantum Multipliers if Quantum Roulette
    final isQuantum = widget.game.title.toLowerCase().contains('quantum');
    final Map<int, int> qMultipliers = {};
    if (isQuantum) {
      final multiList = [50, 100, 200, 500];
      for (int i = 0; i < 3; i++) {
        final luckyNum = rand.nextInt(37);
        qMultipliers[luckyNum] = multiList[rand.nextInt(multiList.length)];
      }
    }

    setState(() {
      _isSpinning = true;
      _winningNumber = winNum;
      _winningColor = winCol;
      _quantumMultipliers = qMultipliers;
      _statusMessage = 'Wheel spinning... Good luck!';
      _lastWin = 0.0;
      // Target spin rotation: at least 6 full revolutions + slice offset
      _targetWheelAngle = _currentWheelAngle + (pi * 2 * 6) + (winNum * (pi * 2 / 37));
    });

    _wheelController.reset();
    _wheelController.forward();
  }

  void _onSpinComplete() {
    final winNum = _winningNumber!;
    final winCol = _winningColor;
    double totalPayout = 0.0;

    // Check Straight-Up bets
    final straightKey = 'num_$winNum';
    if (_placedBets.containsKey(straightKey)) {
      final stake = _placedBets[straightKey]!;
      final multi = _quantumMultipliers[winNum] ?? 36;
      totalPayout += stake * multi;
    }

    // Check Outside bets (only if not 0)
    if (winNum > 0) {
      // Red / Black
      if (_placedBets.containsKey(winCol)) {
        totalPayout += _placedBets[winCol]! * 2;
      }
      // Even / Odd
      final isEven = (winNum % 2 == 0);
      if (isEven && _placedBets.containsKey('even')) {
        totalPayout += _placedBets['even']! * 2;
      } else if (!isEven && _placedBets.containsKey('odd')) {
        totalPayout += _placedBets['odd']! * 2;
      }
      // Low (1-18) / High (19-36)
      if (winNum <= 18 && _placedBets.containsKey('low')) {
        totalPayout += _placedBets['low']! * 2;
      } else if (winNum >= 19 && _placedBets.containsKey('high')) {
        totalPayout += _placedBets['high']! * 2;
      }
      // Dozens (1-12, 13-24, 25-36)
      if (winNum <= 12 && _placedBets.containsKey('doz_1')) {
        totalPayout += _placedBets['doz_1']! * 3;
      } else if (winNum <= 24 && _placedBets.containsKey('doz_2')) {
        totalPayout += _placedBets['doz_2']! * 3;
      } else if (winNum >= 25 && _placedBets.containsKey('doz_3')) {
        totalPayout += _placedBets['doz_3']! * 3;
      }
    }

    totalPayout = double.parse(totalPayout.toStringAsFixed(2));

    _sessionTotalWin += totalPayout;
    final net = totalPayout - _lastRoundStake;
    final netText = net > 0 ? '+${net.toStringAsFixed(2)} €' : net < 0 ? '${net.toStringAsFixed(2)} €' : '0.00 €';
    _sessionDetailedLogs.add('Spin #$_sessionSpins: Staked ${_lastRoundStake.toStringAsFixed(2)} € • Ball landed on $winNum (${winCol.toUpperCase()}) • Win ${totalPayout.toStringAsFixed(2)} € ($netText)');

    setState(() {
      _isSpinning = false;
      _lastWin = totalPayout;
      _recentResults.insert(0, {'number': winNum, 'color': winCol});
      if (_recentResults.length > 8) _recentResults.removeLast();

      if (totalPayout > 0) {
        HapticService.celebration();
        _balance += totalPayout;
        if (!widget.isDemo) {
          widget.state.deposit(totalPayout);
        }
        _statusMessage = '🎉 $winNum ${winCol.toUpperCase()}! You won ${totalPayout.toStringAsFixed(2)} €! 🎉';
      } else {
        _statusMessage = 'Result: $winNum ${winCol.toUpperCase()}. Try again!';
      }
      _placedBets.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1A11), // Deep Casino Felt Green
      appBar: AppBar(
        backgroundColor: const Color(0xFF09140C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.game.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  if (widget.isDemo)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('DEMO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Text('European 37 Pockets • Single Zero', style: TextStyle(fontSize: 10, color: PskColors.textMuted)),
            ],
          ),
        ),
        actions: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.5)),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 13, color: PskColors.accentGold),
                    const SizedBox(width: 5),
                    Text(
                      '${_balance.toStringAsFixed(2)} €',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Recent Numbers History Strip
            Container(
              height: 36,
              color: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Text('HISTORY:', style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recentResults.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 6),
                      itemBuilder: (context, idx) {
                        final res = _recentResults[idx];
                        Color badgeColor = res['color'] == 'green'
                            ? PskColors.liveGreen
                            : (res['color'] == 'red' ? PskColors.alertRed : Colors.grey.shade900);

                        return Center(
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: badgeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white38),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${res['number']}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Animated Roulette Wheel & Ball Visualizer
            Container(
              height: 140,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF1B3D23), Color(0xFF09140C)],
                  radius: 0.9,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Wheel Graphic
                  Transform.rotate(
                    angle: _currentWheelAngle,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: PskColors.accentGold, width: 3),
                        gradient: const SweepGradient(
                          colors: [
                            Colors.red, Colors.black, Colors.red, Colors.black,
                            Colors.red, Colors.black, Colors.green, Colors.black,
                            Colors.red, Colors.black, Colors.red, Colors.black,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.7),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: PskColors.accentGold,
                          ),
                          child: const Icon(Icons.star, size: 24, color: Colors.black),
                        ),
                      ),
                    ),
                  ),

                  // Center Outcome Badge
                  if (_winningNumber != null && !_isSpinning)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: _winningColor == 'green'
                            ? PskColors.liveGreen
                            : (_winningColor == 'red' ? PskColors.alertRed : Colors.black87),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: PskColors.accentGold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: PskColors.accentGold.withValues(alpha: 0.6),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Text(
                        'WIN: $_winningNumber',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),

            // Status message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.black45,
              alignment: Alignment.center,
              child: Text(
                _statusMessage,
                style: TextStyle(
                  color: _lastWin > 0 ? PskColors.accentGold : Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Interactive Roulette Betting Table
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Single Zero Button
                    _buildBetButton('num_0', '0', PskColors.liveGreen, isFullWidth: true),
                    const SizedBox(height: 4),

                    // Grid of Numbers (1-36 in 12 rows of 3)
                    Table(
                      children: List.generate(12, (row) {
                        return TableRow(
                          children: List.generate(3, (col) {
                            final num = (row * 3) + col + 1;
                            final isRed = redNumbers.contains(num);
                            final color = isRed ? PskColors.alertRed : const Color(0xFF1E1E24);
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: _buildBetButton('num_$num', '$num', color),
                            );
                          }),
                        );
                      }),
                    ),

                    const SizedBox(height: 6),

                    // Dozens (1st 12, 2nd 12, 3rd 12)
                    Row(
                      children: [
                        Expanded(child: _buildBetButton('doz_1', '1st 12', const Color(0xFF1752BF))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('doz_2', '2nd 12', const Color(0xFF1752BF))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('doz_3', '3rd 12', const Color(0xFF1752BF))),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Outside Bets: 1-18, EVEN, RED, BLACK, ODD, 19-36
                    Row(
                      children: [
                        Expanded(child: _buildBetButton('low', '1-18', const Color(0xFF1C2D42))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('even', 'EVEN', const Color(0xFF1C2D42))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('red', 'RED', PskColors.alertRed)),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('black', 'BLACK', const Color(0xFF1E1E24))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('odd', 'ODD', const Color(0xFF1C2D42))),
                        const SizedBox(width: 4),
                        Expanded(child: _buildBetButton('high', '19-36', const Color(0xFF1C2D42))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Chip Selector & Spin Controls
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              color: Colors.black87,
              child: Column(
                children: [
                  // Chips selector
                  SizedBox(
                    height: 44,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _chipValues.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 10),
                      itemBuilder: (context, idx) {
                        final val = _chipValues[idx];
                        final isSel = _selectedChipIndex == idx;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedChipIndex = idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getChipColor(val),
                              border: Border.all(
                                color: isSel ? PskColors.accentGold : Colors.white24,
                                width: isSel ? 2.5 : 1,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: PskColors.accentGold.withValues(alpha: 0.5),
                                        blurRadius: 8,
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${val.toStringAsFixed(0)}€',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Bottom Action Buttons (Clear, Total, Spin)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        OutlinedButton(
                          onPressed: _isSpinning || _placedBets.isEmpty ? null : _clearBets,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Colors.white24),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          child: const Text('CLEAR', style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL BET', style: TextStyle(color: Colors.white54, fontSize: 9)),
                            Text(
                              '${_totalBetAmount.toStringAsFixed(2)} €',
                              style: const TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _isSpinning || _placedBets.isEmpty ? null : _spin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PskColors.accentGold,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: _isSpinning
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                              : const Text('SPIN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBetButton(String betKey, String label, Color bgColor, {bool isFullWidth = false}) {
    final betOnThis = _placedBets[betKey] ?? 0.0;
    final hasBet = betOnThis > 0.0;

    return InkWell(
      onTap: () => _placeBet(betKey),
      child: Container(
        height: isFullWidth ? 32 : 36,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: hasBet ? PskColors.accentGold : Colors.white24,
            width: hasBet ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            if (hasBet)
              Positioned(
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: PskColors.accentGold,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${betOnThis.toStringAsFixed(0)}€',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 9),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getChipColor(double value) {
    if (value <= 1.0) return Colors.blueGrey;
    if (value <= 5.0) return Colors.red.shade700;
    if (value <= 10.0) return Colors.blue.shade700;
    if (value <= 25.0) return Colors.green.shade700;
    if (value <= 50.0) return Colors.orange.shade800;
    return Colors.purple.shade700;
  }
}
