import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/psk_colors.dart';
import '../../models/casino_game.dart';
import '../../models/played_game_log.dart';
import '../../state/app_state.dart';
import '../../services/haptic_service.dart';

class SlotGameScreen extends StatefulWidget {
  final CasinoGame game;
  final bool isDemo;
  final AppState state;

  const SlotGameScreen({
    super.key,
    required this.game,
    required this.isDemo,
    required this.state,
  });

  @override
  State<SlotGameScreen> createState() => _SlotGameScreenState();
}

class _SlotGameScreenState extends State<SlotGameScreen> with TickerProviderStateMixin {
  late double _balance;
  final List<double> _stakes = [0.20, 0.50, 1.00, 2.00, 5.00, 10.00];
  int _stakeIndex = 2; // Default 1.00 €

  late List<String> _symbols;
  late String _scatterSymbol;
  late String _wildSymbol;

  // 5 Reels x 3 Rows
  late List<List<String>> _reels;
  final List<bool> _isReelSpinning = [false, false, false, false, false];

  bool _isSpinning = false;
  bool _isAutoSpin = false;
  int _autoSpinCount = 0;
  bool _isTurbo = false;

  double _lastWin = 0.0;
  String _winMessage = 'Press SPIN to play!';
  List<int> _highlightedLines = [];

  // Free Spins feature
  int _freeSpinsRemaining = 0;

  Timer? _spinTimer;
  Timer? _autoSpinTimer;
  Timer? _jackpotTicker;
  double _jackpotAmount = 184520.40;

  int _sessionSpins = 0;
  double _sessionTotalStake = 0.0;
  double _sessionTotalWin = 0.0;
  bool _lastSpinWasFree = false;
  final List<String> _sessionDetailedLogs = [];

  @override
  void initState() {
    super.initState();
    _balance = widget.isDemo ? 1000.00 : widget.state.balance;
    if (widget.game.jackpotAmount != null) {
      _jackpotAmount = widget.game.jackpotAmount!;
    }
    _initThemeSymbols();
    _initReels();

    // Minor jackpot tick for atmosphere
    _jackpotTicker = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      setState(() {
        _jackpotAmount += (Random().nextDouble() * 0.45);
      });
    });
  }

  void _initThemeSymbols() {
    final title = widget.game.title.toLowerCase();
    if (title.contains('vatreni')) {
      _symbols = ['⚽', '🏆', '🧤', '🇭🇷', '🥇', '👟', '🏟️'];
      _scatterSymbol = '🏟️';
      _wildSymbol = '🏆';
    } else if (title.contains('olympus') || title.contains('gods')) {
      _symbols = ['⚡', '👑', '💎', '🏺', '💍', '⏳', '🏛️'];
      _scatterSymbol = '🏛️';
      _wildSymbol = '⚡';
    } else if (title.contains('bonanza') || title.contains('sweet') || title.contains('sugar')) {
      _symbols = ['🍭', '🍬', '🍇', '🍉', '🍌', '💖', '⭐'];
      _scatterSymbol = '🍭';
      _wildSymbol = '⭐';
    } else if (title.contains('ra') || title.contains('egypt')) {
      _symbols = ['📖', '🦅', '🏺', '👑', '🪲', '💎', '⭐'];
      _scatterSymbol = '📖';
      _wildSymbol = '👑';
    } else {
      // Classic Fruit / Shining Crown / 40 Burning Hot
      _symbols = ['7️⃣', '🔔', '⭐', '🍉', '🍇', '🍋', '🍒'];
      _scatterSymbol = '⭐';
      _wildSymbol = '7️⃣';
    }
  }

  void _initReels() {
    final rand = Random();
    _reels = List.generate(5, (_) => List.generate(3, (_) => _symbols[rand.nextInt(_symbols.length)]));
  }

  @override
  void dispose() {
    _saveSessionToHistory();
    _spinTimer?.cancel();
    _autoSpinTimer?.cancel();
    _jackpotTicker?.cancel();
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
          id: 'slot_${DateTime.now().millisecondsSinceEpoch}',
          gameId: widget.game.id,
          gameTitle: widget.game.title,
          category: 'Slots',
          provider: widget.game.provider,
          gameIcon: '🎰',
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

  double get _currentStake => _stakes[_stakeIndex];

  void _spin() {
    if (_isSpinning) return;

    final isFreeSpin = _freeSpinsRemaining > 0;
    _lastSpinWasFree = isFreeSpin;
    if (!isFreeSpin) {
      if (_balance < _currentStake) {
        setState(() {
          _winMessage = 'Insufficient balance! Please deposit or lower stake.';
          _isAutoSpin = false;
        });
        return;
      }
      _sessionSpins++;
      _sessionTotalStake += _currentStake;
      setState(() {
        _balance -= _currentStake;
        if (!widget.isDemo) {
          widget.state.deposit(-_currentStake);
        }
      });
    } else {
      setState(() {
        _freeSpinsRemaining--;
      });
    }

    HapticService.casinoAction();
    setState(() {
      _isSpinning = true;
      _lastWin = 0.0;
      _highlightedLines = [];
      _winMessage = isFreeSpin
          ? 'FREE SPIN! ($_freeSpinsRemaining remaining)'
          : 'Good Luck!';
      for (int i = 0; i < 5; i++) {
        _isReelSpinning[i] = true;
      }
    });

    final spinDuration = _isTurbo ? 400 : 900;
    final staggerInterval = _isTurbo ? 100 : 250;

    // Simulate animated reel rolling
    _spinTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final rand = Random();
      setState(() {
        for (int c = 0; c < 5; c++) {
          if (_isReelSpinning[c]) {
            _reels[c] = List.generate(3, (_) => _symbols[rand.nextInt(_symbols.length)]);
          }
        }
      });
    });

    // Staggered stop for each reel
    for (int col = 0; col < 5; col++) {
      final stopDelay = spinDuration + (col * staggerInterval);
      final currentCol = col;
      Timer(Duration(milliseconds: stopDelay), () {
        if (!mounted) return;
        setState(() {
          _isReelSpinning[currentCol] = false;
        });
        if (currentCol == 4) {
          // Last reel stopped
          _spinTimer?.cancel();
          _evaluateWins();
        }
      });
    }
  }

  void _evaluateWins() {
    final rand = Random();
    double winAmount = 0.0;
    List<int> winningLines = [];
    int scatterCount = 0;

    // Count scatters
    for (int c = 0; c < 5; c++) {
      for (int r = 0; r < 3; r++) {
        if (_reels[c][r] == _scatterSymbol) {
          scatterCount++;
        }
      }
    }

    // Paylines:
    // Line 0: Middle row [ [0,1], [1,1], [2,1], [3,1], [4,1] ]
    // Line 1: Top row    [ [0,0], [1,0], [2,0], [3,0], [4,0] ]
    // Line 2: Bottom row [ [0,2], [1,2], [2,2], [3,2], [4,2] ]
    // Line 3: V-shape    [ [0,0], [1,1], [2,2], [3,1], [4,0] ]
    // Line 4: Inverted-V [ [0,2], [1,1], [2,0], [3,1], [4,2] ]

    final paylines = [
      [[0, 1], [1, 1], [2, 1], [3, 1], [4, 1]],
      [[0, 0], [1, 0], [2, 0], [3, 0], [4, 0]],
      [[0, 2], [1, 2], [2, 2], [3, 2], [4, 2]],
      [[0, 0], [1, 1], [2, 2], [3, 1], [4, 0]],
      [[0, 2], [1, 1], [2, 0], [3, 1], [4, 2]],
    ];

    for (int lineIdx = 0; lineIdx < paylines.length; lineIdx++) {
      final line = paylines[lineIdx];
      final firstSym = _reels[line[0][0]][line[0][1]];
      int matchCount = 1;

      for (int i = 1; i < line.length; i++) {
        final sym = _reels[line[i][0]][line[i][1]];
        if (sym == firstSym || sym == _wildSymbol) {
          matchCount++;
        } else {
          break;
        }
      }

      if (matchCount >= 3) {
        winningLines.add(lineIdx);
        double multiplier = 1.5;
        if (matchCount == 3) multiplier = (firstSym == _wildSymbol ? 5.0 : 2.0);
        if (matchCount == 4) multiplier = (firstSym == _wildSymbol ? 25.0 : 8.0);
        if (matchCount == 5) multiplier = (firstSym == _wildSymbol ? 100.0 : 40.0);
        winAmount += (_currentStake * (multiplier / paylines.length));
      }
    }

    // Occasional exciting win booster
    if (winAmount == 0.0 && rand.nextDouble() < 0.28) {
      winAmount = _currentStake * (1.2 + rand.nextDouble() * 2.5);
      winningLines.add(0);
    }

    // Check Scatter Free Spins trigger (3+ scatters = 10 Free Spins)
    bool triggeredFreeSpins = false;
    if (scatterCount >= 3 && _freeSpinsRemaining == 0) {
      _freeSpinsRemaining = 10;
      triggeredFreeSpins = true;
      winAmount += (_currentStake * 5.0);
    }

    winAmount = double.parse(winAmount.toStringAsFixed(2));

    setState(() {
      _isSpinning = false;
      _lastWin = winAmount;
      _highlightedLines = winningLines;

      if (winAmount > 0) {
        HapticService.celebration();
        _balance += winAmount;
        if (!widget.isDemo) {
          widget.state.deposit(winAmount);
        }

        if (winAmount >= (_currentStake * 20)) {
          _winMessage = '🔥 MEGA WIN: ${winAmount.toStringAsFixed(2)} €! 🔥';
          _showBigWinDialog('MEGA WIN', winAmount);
        } else if (winAmount >= (_currentStake * 8)) {
          _winMessage = '🎉 BIG WIN: ${winAmount.toStringAsFixed(2)} €! 🎉';
        } else {
          _winMessage = 'Winner! +${winAmount.toStringAsFixed(2)} €';
        }
      } else {
        _winMessage = 'Better luck next spin!';
      }

      if (triggeredFreeSpins) {
        _winMessage = '🌟 10 FREE SPINS TRIGGERED! 🌟';
        _showBigWinDialog('FREE SPINS BONUS', 10, isFreeSpins: true);
      }
    });

    _sessionTotalWin += winAmount;
    final spinType = _lastSpinWasFree ? 'Free Spin' : 'Spin #$_sessionSpins';
    final outcome = winAmount > 0 ? 'Won +${winAmount.toStringAsFixed(2)} €' : 'No payout';
    _sessionDetailedLogs.add('$spinType: Bet ${(_lastSpinWasFree ? 0.0 : _currentStake).toStringAsFixed(2)} € • $outcome');

    // Auto-spin next round
    if (_isAutoSpin && _autoSpinCount > 0) {
      _autoSpinCount--;
      _autoSpinTimer = Timer(Duration(milliseconds: _isTurbo ? 400 : 1000), () {
        if (mounted && _isAutoSpin && _balance >= _currentStake) {
          _spin();
        } else {
          setState(() => _isAutoSpin = false);
        }
      });
    } else {
      _isAutoSpin = false;
    }
  }

  void _showBigWinDialog(String title, double amount, {bool isFreeSpins = false}) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B1B22), Color(0xFF0F2B64), Color(0xFF1B1B22)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PskColors.accentGold, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: PskColors.accentGold.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isFreeSpins ? '🎰 BONUS ROUND 🎰' : '🏆 CONGRATULATIONS! 🏆',
                style: const TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
              ),
              const SizedBox(height: 12),
              Text(
                isFreeSpins ? '10 FREE SPINS' : '+${amount.toStringAsFixed(2)} €',
                style: TextStyle(
                  color: isFreeSpins ? Colors.white : PskColors.accentGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PskColors.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PskColors.bgDark,
      appBar: AppBar(
        backgroundColor: PskColors.surfaceDark,
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
              Text(
                widget.game.provider,
                style: const TextStyle(fontSize: 10, color: PskColors.textMuted),
              ),
            ],
          ),
        ),
        actions: [
          // Paytable info
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70, size: 20),
            onPressed: () => _showPaytable(context),
          ),
          // User balance chip
          Center(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: PskColors.surfaceDarkAction,
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
            // Progressive Jackpot Banner
            if (widget.game.hasJackpot)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B1D0E), Color(0xFFC52D16), Color(0xFF8B1D0E)],
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.diamond, size: 16, color: PskColors.accentGold),
                      const SizedBox(width: 6),
                      const Text(
                        'PROGRESSIVE JACKPOT: ',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_jackpotAmount.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          color: PskColors.accentGold,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Free Spins Status Banner
            if (_freeSpinsRemaining > 0)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: PskColors.brandBlue,
                alignment: Alignment.center,
                child: Text(
                  'FREE SPINS: $_freeSpinsRemaining LEFT',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 8),

            // Main Slot Machine Reel Frame
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PskColors.accentGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Reels 5x3 Grid
                    Expanded(
                      child: Row(
                        children: List.generate(5, (colIdx) {
                          final isSpinning = _isReelSpinning[colIdx];
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E28),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSpinning
                                      ? PskColors.accentGold.withValues(alpha: 0.7)
                                      : Colors.white12,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (rowIdx) {
                                  final symbol = _reels[colIdx][rowIdx];
                                  final isHighlighted = _highlightedLines.isNotEmpty &&
                                      !isSpinning &&
                                      _isCellWinning(colIdx, rowIdx);

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? PskColors.accentGold.withValues(alpha: 0.25)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: isHighlighted
                                          ? Border.all(color: PskColors.accentGold, width: 1.5)
                                          : null,
                                    ),
                                    child: Center(
                                      child: Text(
                                        symbol,
                                        style: TextStyle(
                                          fontSize: 32,
                                          shadows: isHighlighted
                                              ? [
                                                  const Shadow(
                                                    color: PskColors.accentGold,
                                                    blurRadius: 12,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Win / Status Toast Strip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      decoration: BoxDecoration(
                        color: PskColors.bgDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _winMessage,
                            style: TextStyle(
                              color: _lastWin > 0 ? PskColors.accentGold : Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (_lastWin > 0)
                            Text(
                              'WIN: ${_lastWin.toStringAsFixed(2)} €',
                              style: const TextStyle(
                                color: PskColors.liveGreen,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Bottom Controls Dashboard
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF14141B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Stake & Multipliers Bar
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stake selector
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: PskColors.accentGold),
                              onPressed: _isSpinning || _stakeIndex <= 0
                                  ? null
                                  : () => setState(() => _stakeIndex--),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('TOTAL BET', style: TextStyle(color: PskColors.textMuted, fontSize: 9)),
                                Text(
                                  '${_currentStake.toStringAsFixed(2)} €',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: PskColors.accentGold),
                              onPressed: _isSpinning || _stakeIndex >= _stakes.length - 1
                                  ? null
                                  : () => setState(() => _stakeIndex++),
                            ),
                          ],
                        ),

                        const SizedBox(width: 8),

                        // Turbo toggle
                        IconButton(
                          icon: Icon(
                            Icons.flash_on,
                            color: _isTurbo ? PskColors.accentGold : Colors.white30,
                          ),
                          onPressed: () => setState(() => _isTurbo = !_isTurbo),
                        ),

                        const SizedBox(width: 6),

                        // Auto Spin Toggle
                        OutlinedButton(
                          onPressed: _isSpinning
                              ? null
                              : () {
                                  setState(() {
                                    if (_isAutoSpin) {
                                      _isAutoSpin = false;
                                    } else {
                                      _isAutoSpin = true;
                                      _autoSpinCount = 10;
                                      _spin();
                                    }
                                  });
                                },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isAutoSpin ? PskColors.accentGold : Colors.white24,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          ),
                          child: Text(
                            _isAutoSpin ? 'STOP ($_autoSpinCount)' : 'AUTO 10',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _isAutoSpin ? PskColors.accentGold : Colors.white70,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Primary SPIN Button
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: ElevatedButton(
                            onPressed: _isSpinning ? null : _spin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PskColors.accentGold,
                              foregroundColor: Colors.black,
                              shape: const CircleBorder(),
                              elevation: 8,
                              padding: EdgeInsets.zero,
                            ),
                            child: _isSpinning
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh, size: 28, color: Colors.black),
                                      Text(
                                        'SPIN',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
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

  bool _isCellWinning(int col, int row) {
    for (final lineIdx in _highlightedLines) {
      if (lineIdx == 0 && row == 1) return true;
      if (lineIdx == 1 && row == 0) return true;
      if (lineIdx == 2 && row == 2) return true;
      if (lineIdx == 3 && ((col == 0 && row == 0) || (col == 1 && row == 1) || (col == 2 && row == 2) || (col == 3 && row == 1) || (col == 4 && row == 0))) {
        return true;
      }
      if (lineIdx == 4 && ((col == 0 && row == 2) || (col == 1 && row == 1) || (col == 2 && row == 0) || (col == 3 && row == 1) || (col == 4 && row == 2))) {
        return true;
      }
    }
    return false;
  }

  void _showPaytable(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: PskColors.bgDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.game.title} Paytable',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: Text(_wildSymbol, style: const TextStyle(fontSize: 28)),
              title: const Text('WILD Symbol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Substitutes for all symbols on paylines except Scatter. 5x Wilds pays 100x!', style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
            ),
            ListTile(
              leading: Text(_scatterSymbol, style: const TextStyle(fontSize: 28)),
              title: const Text('SCATTER Symbol', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('3 or more Scatters anywhere triggers 10 Free Spins + 5x instant multiplier!', style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Paylines: 5 fixed paylines paying left to right. RTP: 96.50%',
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
