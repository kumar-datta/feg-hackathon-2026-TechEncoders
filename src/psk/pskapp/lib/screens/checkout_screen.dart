import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/placed_bet_ticket.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/my_bets_sheet.dart';

/// Checkout: review selections, social proof, quick stakes and the projected
/// return, a leave-intent guard that shows "you could win X" when the user
/// backs out, and the success card once the ticket is placed.
class CheckoutScreen extends StatefulWidget {
  final AppState state;

  const CheckoutScreen({super.key, required this.state});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _stakeController = TextEditingController();
  PlacedBetTicket? _placed;
  bool _busy = false;
  int _viewers = 8 + Random().nextInt(40);
  Timer? _viewerTimer;

  static const _quick = [2.0, 5.0, 10.0, 20.0, 50.0];

  @override
  void initState() {
    super.initState();
    _stakeController.text = widget.state.betSlip.stake.toStringAsFixed(2);
    // gentle drift so the "watching now" figure feels live
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() => _viewers = max(5, _viewers + ((Random().nextDouble() - 0.45) * 6).round()));
    });
  }

  @override
  void dispose() {
    _viewerTimer?.cancel();
    _stakeController.dispose();
    super.dispose();
  }

  /// Deterministic "social proof" count derived from the slip itself, so it
  /// stays stable on the page instead of flickering on every rebuild.
  int _seededCount() {
    final slip = widget.state.betSlip.selections;
    var seed = 7;
    for (final p in slip) {
      seed += p.eventId.length + p.selectionLabel.codeUnitAt(0);
    }
    var a = (seed * 2654435761) & 0xFFFFFFFF;
    a ^= a >> 15;
    a = (a * 2246822507) & 0xFFFFFFFF;
    a ^= a >> 13;
    return 120 + a % 2600;
  }

  String _fmtInt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  Future<bool> _confirmLeave() async {
    final state = widget.state;
    if (_placed != null || state.betSlip.isEmpty) return true;
    final leave = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xB30E0E11),
      builder: (ctx) => _LeaveIntentDialog(state: state, socialCount: _fmtInt(_seededCount())),
    );
    return leave == true;
  }

  Future<void> _confirm() async {
    final state = widget.state;
    if (!state.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please log in to place your bet.'),
        backgroundColor: PskColors.alertRed,
      ));
      AuthDialog.show(context, state, isRegister: false);
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final ticket = state.placeBet();
    if (!mounted) return;
    setState(() => _busy = false);
    if (ticket == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Insufficient balance. Please deposit funds.'),
        backgroundColor: PskColors.alertRed,
      ));
      return;
    }
    setState(() => _placed = ticket);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return PopScope(
          canPop: _placed != null || state.betSlip.isEmpty,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            if (await _confirmLeave() && context.mounted) Navigator.of(context).pop();
          },
          child: Scaffold(
            backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
            appBar: AppBar(
              backgroundColor: isDark ? PskColors.bgDark : PskColors.brandBlue,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (await _confirmLeave() && context.mounted) Navigator.of(context).pop();
                },
              ),
              title: const Text('🧾 CHECKOUT'),
            ),
            body: _placed != null
                ? _successCard(_placed!, isDark)
                : state.betSlip.isEmpty
                    ? _emptyState()
                    : _checkout(isDark),
          ),
        );
      },
    );
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎫', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text('Your slip is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Pick an odd from the offer to get started.',
                  style: TextStyle(color: PskColors.textMuted, fontSize: 13)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.state.setTopTabIndex(PskTab.sports);
                },
                style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black),
                child: const Text('OPEN OFFER'),
              ),
            ],
          ),
        ),
      );

  Widget _checkout(bool isDark) {
    final state = widget.state;
    final slip = state.betSlip;
    final panelColor = isDark ? PskColors.surfaceDark : Colors.white;
    final border = isDark ? PskColors.borderDark : PskColors.borderLight;

    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 24),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 10),
          child: Text('Review your selections and confirm your bet',
              style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
        ),

        // Selections card
        Container(
          decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  children: [
                    const Text('Selections', style: TextStyle(color: PskColors.textMuted, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: PskColors.surfaceDarkAction, borderRadius: BorderRadius.circular(10)),
                      child: Text('${slip.count}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              for (var i = 0; i < slip.selections.length; i++) ...[
                Divider(height: 1, color: border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${slip.selections[i].homeTeam} – ${slip.selections[i].awayTeam}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              '${slip.selections[i].league} · ${slip.selections[i].marketName} · Code ${4800 + (slip.selections[i].eventId.hashCode % 200).abs()}',
                              style: const TextStyle(color: PskColors.textMuted, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 24,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: PskColors.brandBlue, borderRadius: BorderRadius.circular(12)),
                        child: Text(slip.selections[i].selectionLabel,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 10),
                      Text(slip.selections[i].oddValue.toStringAsFixed(2),
                          style: const TextStyle(color: PskColors.accentGold, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => state.removeSelection(slip.selections[i].id),
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: PskColors.alertRed, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Social proof strip
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            children: [
              const _PulsingDot(),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: '${_fmtInt(_seededCount())} users placed similar bets',
                    style: const TextStyle(color: PskColors.textGray, fontSize: 12),
                    children: [
                      const TextSpan(text: ' · '),
                      TextSpan(
                        text: '$_viewers watching now',
                        style: const TextStyle(color: PskColors.liveGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Summary panel
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: panelColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _quick.map((v) {
                  final sel = (slip.stake - v).abs() < 0.001;
                  return InkWell(
                    onTap: () {
                      state.setStake(v);
                      _stakeController.text = v.toStringAsFixed(2);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 52,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: sel ? PskColors.brandBlue : PskColors.surfaceDarkAction,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${v.toStringAsFixed(0)}€',
                          style: TextStyle(color: sel ? Colors.white : PskColors.textGray, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Stake', style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: PskColors.surfaceDarkPanel, borderRadius: BorderRadius.circular(8)),
                child: TextField(
                  controller: _stakeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(border: InputBorder.none, suffixText: '€', suffixStyle: TextStyle(color: PskColors.textMuted)),
                  onChanged: (v) {
                    final parsed = double.tryParse(v.replaceAll(',', '.'));
                    if (parsed != null && parsed > 0) state.setStake(parsed);
                  },
                ),
              ),
              const SizedBox(height: 14),
              _row('Pairs', '${slip.count}'),
              _row('Total odds', slip.totalOdds.toStringAsFixed(2)),
              _row('Gross return', '${slip.grossWin.toStringAsFixed(2)} €'),
              _row('Processing fee (5%)', '-${slip.mtFee.toStringAsFixed(2)} €'),
              _row('Deduction (10%)', '-${slip.estimatedTax.toStringAsFixed(2)} €'),
              const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: _DashedLine()),
              Row(
                children: [
                  const Text('Potential return', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${slip.potentialWin.toStringAsFixed(2)} €',
                      style: const TextStyle(color: PskColors.moneyGreen, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              if (state.isLoggedIn) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 6), child: _DashedLine()),
                Text('Balance after: ${max(0, state.balance - slip.stake).toStringAsFixed(2)} €',
                    style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
              ],
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _busy ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PskColors.accentGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(_busy ? 'CONFIRMING…' : (state.isLoggedIn ? 'CONFIRM BET' : 'LOG IN & CONFIRM'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  onPressed: () async {
                    final nav = Navigator.of(context);
                    if (await _confirmLeave()) nav.pop();
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: PskColors.surfaceDarkAction,
                    foregroundColor: PskColors.textGray,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('← Back to offer'),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text('This is a demo. No real money is involved.',
                    style: TextStyle(color: PskColors.textMuted, fontSize: 10, fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(label, style: const TextStyle(color: PskColors.textMuted, fontSize: 13)),
            const Spacer(),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _successCard(PlacedBetTicket t, bool isDark) {
    final placedAt = t.placedAt;
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr =
        '${placedAt.day.toString().padLeft(2, '0')} ${months[placedAt.month - 1]} ${placedAt.year}, ${placedAt.hour.toString().padLeft(2, '0')}:${placedAt.minute.toString().padLeft(2, '0')}';
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.elasticOut,
                builder: (context, v, child) => Transform.scale(scale: v, child: child),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(color: PskColors.liveGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Bet Placed!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              const Text('Your ticket has been submitted. Good luck!', style: TextStyle(color: PskColors.textMuted, fontSize: 13)),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: PskColors.surfaceDarkPanel, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Text('Reference', style: TextStyle(color: PskColors.textGray)),
                    const Spacer(),
                    Text(t.id, style: const TextStyle(color: PskColors.textGray, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? PskColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _row('Stake', '${t.stake.toStringAsFixed(2)} €'),
                    _row('Pairs', '${t.legs.length}'),
                    _row('Total odds', t.totalOdds.toStringAsFixed(2)),
                    _row('Placed at', dateStr),
                    Row(
                      children: [
                        const Text('Potential return', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text('${t.potentialWin.toStringAsFixed(2)} €',
                            style: const TextStyle(color: PskColors.moneyGreen, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          MyBetsSheet.show(context, widget.state);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PskColors.accentGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('My Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.state.setTopTabIndex(PskTab.sports);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: PskColors.surfaceDarkAction,
                          foregroundColor: PskColors.textGray,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('New Bet'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('This is a demo environment. No real money was wagered.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: PskColors.textMuted, fontSize: 10, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaveIntentDialog extends StatelessWidget {
  final AppState state;
  final String socialCount;
  const _LeaveIntentDialog({required this.state, required this.socialCount});

  @override
  Widget build(BuildContext context) {
    final slip = state.betSlip;
    return Dialog(
      backgroundColor: PskColors.surfaceDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Wait! Are you sure?', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context, false),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(color: PskColors.surfaceDarkAction, shape: BoxShape.circle),
                      child: const Icon(Icons.close, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text("You're about to leave your bet behind.", style: TextStyle(color: PskColors.textMuted, fontSize: 13)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C2B64), PskColors.brandBlue, Color(0xFF1A1A24)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('YOU COULD WIN',
                        style: TextStyle(color: PskColors.brandBlueLight, fontSize: 11, letterSpacing: 0.6)),
                    const SizedBox(height: 4),
                    Text('${slip.potentialWin.toStringAsFixed(2)} €',
                        style: const TextStyle(color: PskColors.accentGold, fontSize: 28, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(
                      '${slip.count} × pairs · Odds ${slip.totalOdds.toStringAsFixed(2)} · Stake ${slip.stake.toStringAsFixed(2)} €',
                      style: const TextStyle(color: PskColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const _PulsingDot(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('$socialCount users placed similar bets',
                        style: const TextStyle(color: PskColors.textGray, fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          backgroundColor: PskColors.surfaceDarkAction,
                          foregroundColor: PskColors.textGray,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Leave anyway'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PskColors.accentGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Stay & Bet', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_c),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: PskColors.moneyGreen, shape: BoxShape.circle),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final n = (c.maxWidth / 8).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                color: PskColors.borderDark,
              ),
            ),
          ),
        );
      },
    );
  }
}
