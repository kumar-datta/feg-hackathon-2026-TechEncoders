import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/psk_colors.dart';
import '../../models/casino_game.dart';
import '../../models/played_game_log.dart';
import '../../state/app_state.dart';
import '../../services/haptic_service.dart';

enum Suit { spades, hearts, diamonds, clubs }

class PlayingCard {
  final String rank;
  final Suit suit;
  final int value;
  final bool isFaceDown;

  const PlayingCard({
    required this.rank,
    required this.suit,
    required this.value,
    this.isFaceDown = false,
  });

  bool get isRed => suit == Suit.hearts || suit == Suit.diamonds;

  String get suitSymbol {
    switch (suit) {
      case Suit.spades:
        return '♠';
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
    }
  }

  PlayingCard copyWith({bool? isFaceDown}) {
    return PlayingCard(
      rank: rank,
      suit: suit,
      value: value,
      isFaceDown: isFaceDown ?? this.isFaceDown,
    );
  }
}

class BlackjackGameScreen extends StatefulWidget {
  final CasinoGame game;
  final bool isDemo;
  final AppState state;

  const BlackjackGameScreen({
    super.key,
    required this.game,
    required this.isDemo,
    required this.state,
  });

  @override
  State<BlackjackGameScreen> createState() => _BlackjackGameScreenState();
}

class _BlackjackGameScreenState extends State<BlackjackGameScreen> {
  late double _balance;
  final List<double> _chips = [5.0, 10.0, 25.0, 50.0, 100.0];
  int _selectedChipIndex = 1; // 10.0 € default

  double _currentBet = 0.0;
  List<PlayingCard> _deck = [];
  List<PlayingCard> _dealerHand = [];
  List<PlayingCard> _playerHand = [];

  bool _isDealing = false;
  bool _isHandActive = false;
  bool _canDouble = false;
  String _gameMessage = 'Select chip and tap DEAL to play!';
  double _lastWin = 0.0;

  int _sessionHands = 0;
  double _sessionTotalStake = 0.0;
  double _sessionTotalWin = 0.0;
  final List<String> _sessionDetailedLogs = [];

  @override
  void initState() {
    super.initState();
    _balance = widget.isDemo ? 1000.00 : widget.state.balance;
    _currentBet = _chips[_selectedChipIndex];
    _initDeck();
  }

  @override
  void dispose() {
    _saveSessionToHistory();
    super.dispose();
  }

  void _saveSessionToHistory() {
    if (_sessionHands > 0) {
      final net = _sessionTotalWin - _sessionTotalStake;
      final summary = net >= 0
          ? 'Won ${_sessionTotalWin.toStringAsFixed(2)} € over $_sessionHands hand${_sessionHands > 1 ? 's' : ''}'
          : 'Staked ${_sessionTotalStake.toStringAsFixed(2)} € over $_sessionHands hand${_sessionHands > 1 ? 's' : ''}';
      widget.state.addGameLog(
        PlayedGameLog(
          id: 'bj_${DateTime.now().millisecondsSinceEpoch}',
          gameId: widget.game.id,
          gameTitle: widget.game.title,
          category: 'Table Games',
          provider: widget.game.provider,
          gameIcon: '♠️',
          timestamp: DateTime.now(),
          stake: double.parse(_sessionTotalStake.toStringAsFixed(2)),
          winAmount: double.parse(_sessionTotalWin.toStringAsFixed(2)),
          roundsPlayed: _sessionHands,
          summary: summary,
          detailedLogs: List.unmodifiable(_sessionDetailedLogs),
        ),
      );
    }
  }

  void _initDeck() {
    final List<PlayingCard> cards = [];
    const ranks = ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A'];

    for (final suit in Suit.values) {
      for (final rank in ranks) {
        int val;
        if (rank == 'A') {
          val = 11;
        } else if (rank == 'K' || rank == 'Q' || rank == 'J' || rank == '10') {
          val = 10;
        } else {
          val = int.parse(rank);
        }
        cards.add(PlayingCard(rank: rank, suit: suit, value: val));
      }
    }
    cards.shuffle(Random());
    _deck = cards;
  }

  PlayingCard _drawCard({bool faceDown = false}) {
    if (_deck.length < 10) {
      _initDeck();
    }
    final card = _deck.removeLast();
    return card.copyWith(isFaceDown: faceDown);
  }

  int _calculateScore(List<PlayingCard> hand, {bool includeHidden = false}) {
    int total = 0;
    int aces = 0;

    for (final card in hand) {
      if (card.isFaceDown && !includeHidden) continue;
      total += card.value;
      if (card.rank == 'A') aces++;
    }

    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }

    return total;
  }

  void _startDeal() {
    if (_isDealing || _isHandActive) return;
    if (_balance < _currentBet) {
      setState(() => _gameMessage = 'Insufficient balance! Please deposit.');
      return;
    }

    HapticService.casinoAction();
    _sessionHands++;
    _sessionTotalStake += _currentBet;
    setState(() {
      _isDealing = true;
      _lastWin = 0.0;
      _balance -= _currentBet;
      if (!widget.isDemo) {
        widget.state.deposit(-_currentBet);
      }
      _dealerHand = [];
      _playerHand = [];
      _gameMessage = 'Dealing cards...';
    });

    Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _playerHand.add(_drawCard());
      });

      Timer(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        setState(() {
          _dealerHand.add(_drawCard());
        });

        Timer(const Duration(milliseconds: 300), () {
          if (!mounted) return;
          setState(() {
            _playerHand.add(_drawCard());
          });

          Timer(const Duration(milliseconds: 300), () {
            if (!mounted) return;
            setState(() {
              _dealerHand.add(_drawCard(faceDown: true)); // Hole card
              _isDealing = false;
              _isHandActive = true;
              _canDouble = _balance >= _currentBet;

              final pScore = _calculateScore(_playerHand);
              if (pScore == 21) {
                // Natural Blackjack!
                _stand();
              } else {
                _gameMessage = 'Your turn: Hit, Stand or Double?';
              }
            });
          });
        });
      });
    });
  }

  void _hit() {
    if (!_isHandActive || _isDealing) return;

    HapticService.oddsSelected();
    setState(() {
      _canDouble = false;
      _playerHand.add(_drawCard());
      final score = _calculateScore(_playerHand);

      if (score > 21) {
        // Player Bust
        _endHand(isPlayerBust: true);
      } else if (score == 21) {
        _stand();
      } else {
        _gameMessage = 'Hand total: $score. Hit or Stand?';
      }
    });
  }

  void _doubleDown() {
    if (!_canDouble || !_isHandActive || _balance < _currentBet) return;

    _sessionTotalStake += _currentBet;
    setState(() {
      _balance -= _currentBet;
      if (!widget.isDemo) {
        widget.state.deposit(-_currentBet);
      }
      _currentBet *= 2;
      _canDouble = false;
      _playerHand.add(_drawCard());
      _stand();
    });
  }

  void _stand() {
    if (!_isHandActive || _isDealing) return;

    setState(() {
      _isHandActive = false;
      _isDealing = true;
      _gameMessage = "Dealer's turn...";
      // Reveal dealer hole card
      _dealerHand[1] = _dealerHand[1].copyWith(isFaceDown: false);
    });

    _playDealerTurn();
  }

  void _playDealerTurn() {
    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final dealerScore = _calculateScore(_dealerHand, includeHidden: true);
      if (dealerScore < 17) {
        setState(() {
          _dealerHand.add(_drawCard());
        });
      } else {
        timer.cancel();
        _endHand();
      }
    });
  }

  void _endHand({bool isPlayerBust = false}) {
    final pScore = _calculateScore(_playerHand);
    final dScore = _calculateScore(_dealerHand, includeHidden: true);
    double win = 0.0;
    String message = '';

    if (isPlayerBust) {
      message = '💥 BUST! Dealer wins with $dScore.';
    } else if (dScore > 21) {
      win = _currentBet * 2;
      message = '🎉 Dealer busts! You win ${win.toStringAsFixed(2)} €! 🎉';
    } else if (_playerHand.length == 2 && pScore == 21 && dScore != 21) {
      // Natural Blackjack pays 3:2 (2.5x total return)
      win = _currentBet * 2.5;
      message = '⭐ BLACKJACK! Pays 3:2: ${win.toStringAsFixed(2)} €! ⭐';
    } else if (pScore > dScore) {
      win = _currentBet * 2;
      message = '🏆 You win! $pScore to $dScore (+${win.toStringAsFixed(2)} €)';
    } else if (pScore == dScore) {
      win = _currentBet; // Push
      message = '🤝 PUSH (Tie at $pScore). Stake returned.';
    } else {
      message = 'Dealer wins ($dScore vs $pScore). Try again!';
    }

    win = double.parse(win.toStringAsFixed(2));

    _sessionTotalWin += win;
    final handResult = isPlayerBust
        ? 'Hand #$_sessionHands: Bet ${_currentBet.toStringAsFixed(2)} € • BUST with $pScore vs Dealer $dScore • Lost'
        : win > _currentBet
            ? 'Hand #$_sessionHands: Bet ${_currentBet.toStringAsFixed(2)} € • Player ($pScore) vs Dealer ($dScore) • Won +${(win - _currentBet).toStringAsFixed(2)} €'
            : win == _currentBet
                ? 'Hand #$_sessionHands: Bet ${_currentBet.toStringAsFixed(2)} € • PUSH (Tie at $pScore) • Stake returned'
                : 'Hand #$_sessionHands: Bet ${_currentBet.toStringAsFixed(2)} € • Player ($pScore) vs Dealer ($dScore) • Lost';
    _sessionDetailedLogs.add(handResult);

    setState(() {
      _isDealing = false;
      _isHandActive = false;
      _lastWin = win;
      _gameMessage = message;

      if (win > 0) {
        HapticService.celebration();
        _balance += win;
        if (!widget.isDemo) {
          widget.state.deposit(win);
        }
      }
      _currentBet = _chips[_selectedChipIndex]; // reset bet to selected chip
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C2417), // Classic Casino Green Felt
      appBar: AppBar(
        backgroundColor: const Color(0xFF07170E),
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
              const Text('Blackjack pays 3:2 • Dealer stands on 17', style: TextStyle(fontSize: 10, color: PskColors.textMuted)),
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
            // Dealer Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.casino, size: 14, color: PskColors.accentGold),
                          const SizedBox(width: 6),
                          Text(
                            _dealerHand.isNotEmpty
                                ? 'DEALER (${_calculateScore(_dealerHand, includeHidden: !_isHandActive)})'
                                : 'DEALER',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Dealer Cards Row
                    Expanded(
                      child: Center(
                        child: _dealerHand.isEmpty
                            ? _buildEmptyCardSlot()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _dealerHand.map(_buildCardWidget).toList(),
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Table Center Felt Decal & Result Toast
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.black38,
              child: Column(
                children: [
                  Text(
                    _gameMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _lastWin > 0 ? PskColors.accentGold : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (_isHandActive)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'CURRENT BET: ${_currentBet.toStringAsFixed(2)} €',
                        style: const TextStyle(color: PskColors.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),

            // Player Area
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    // Player Cards Row
                    Expanded(
                      child: Center(
                        child: _playerHand.isEmpty
                            ? _buildEmptyCardSlot()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _playerHand.map(_buildCardWidget).toList(),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, size: 14, color: PskColors.accentGold),
                          const SizedBox(width: 6),
                          Text(
                            _playerHand.isNotEmpty
                                ? 'YOU (${_calculateScore(_playerHand)})'
                                : 'YOU',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Controls Bar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              color: const Color(0xFF07170E),
              child: Column(
                children: [
                  if (!_isHandActive) ...[
                    // Bet Selection Phase
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('BET CHIPS:', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 16),
                          Text(
                            'STAKE: ${_currentBet.toStringAsFixed(2)} €',
                            style: const TextStyle(color: PskColors.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _chips.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final chip = _chips[idx];
                          final isSel = _selectedChipIndex == idx;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedChipIndex = idx;
                              _currentBet = chip;
                            }),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSel ? PskColors.accentGold : PskColors.brandBlue,
                                border: Border.all(color: Colors.white, width: isSel ? 2 : 1),
                                boxShadow: [
                                  if (isSel)
                                    BoxShadow(
                                      color: PskColors.accentGold.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                    ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${chip.toStringAsFixed(0)}€',
                                style: TextStyle(
                                  color: isSel ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _isDealing ? null : _startDeal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PskColors.accentGold,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('DEAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                    ),
                  ] else ...[
                    // In-Game Play Phase (Hit, Stand, Double)
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDealing ? null : _hit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PskColors.liveGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('HIT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isDealing ? null : _stand,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PskColors.alertRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('STAND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                        ),
                        if (_canDouble) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isDealing ? null : _doubleDown,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: PskColors.brandBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text('DOUBLE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCardSlot() {
    return Container(
      width: 65,
      height: 95,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, style: BorderStyle.solid),
      ),
      child: const Center(
        child: Icon(Icons.style_outlined, color: Colors.white24, size: 28),
      ),
    );
  }

  Widget _buildCardWidget(PlayingCard card) {
    if (card.isFaceDown) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 65,
        height: 95,
        decoration: BoxDecoration(
          color: const Color(0xFF1752BF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PskColors.accentGold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 38,
            height: 58,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white24),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'PSK',
                style: TextStyle(
                  color: PskColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      );
    }

    final cardLabel = card.rank + card.suitSymbol;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 65,
      height: 95,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              cardLabel,
              style: TextStyle(
                color: card.isRed ? Colors.red : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            card.suitSymbol,
            style: TextStyle(
              color: card.isRed ? Colors.red : Colors.black,
              fontSize: 26,
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              cardLabel,
              style: TextStyle(
                color: card.isRed ? Colors.red : Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
