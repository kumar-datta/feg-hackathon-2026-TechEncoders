import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../models/bet_slip_model.dart';
import '../state/app_state.dart';
import '../screens/checkout_screen.dart';

class BetslipSheet extends StatefulWidget {
  final AppState state;
  final bool isBottomSheet;

  const BetslipSheet({super.key, required this.state, this.isBottomSheet = false});

  static void show(BuildContext context, AppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ListenableBuilder(
        listenable: state,
        builder: (context, _) => BetslipSheet(state: state, isBottomSheet: true),
      ),
    );
  }

  @override
  State<BetslipSheet> createState() => _BetslipSheetState();
}

class _BetslipSheetState extends State<BetslipSheet> {
  final _stakeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _stakeController.text = widget.state.betSlip.stake.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _stakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final betSlip = state.betSlip;
    final sheetHeight = widget.isBottomSheet ? MediaQuery.of(context).size.height * 0.85 : double.infinity;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: isDark ? PskColors.bgDark : PskColors.bgLight,
        borderRadius: widget.isBottomSheet ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.zero,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            // Drag handle & Header
            Container(
              padding: EdgeInsets.fromLTRB(16, widget.isBottomSheet ? 12 : 16, 16, 8),
              decoration: BoxDecoration(
                color: isDark ? PskColors.bgDarkSecondary : PskColors.surfaceLight,
                borderRadius: widget.isBottomSheet ? const BorderRadius.vertical(top: Radius.circular(16)) : BorderRadius.zero,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? PskColors.borderDark : PskColors.borderLight,
                  ),
                ),
              ),
              child: Column(
                children: [
                  if (widget.isBottomSheet)
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.confirmation_number, color: PskColors.accentGold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'BETSLIP (${betSlip.count})',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (betSlip.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: PskColors.alertRed),
                              tooltip: 'Clear betslip',
                              onPressed: () => state.clearBetSlip(),
                            ),
                          if (widget.isBottomSheet)
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              onPressed: () => Navigator.pop(context),
                            ),
                        ],
                      ),
                    ],
                  ),
                // System / Single / Accumulator Tabs
                const SizedBox(height: 6),
                Row(
                  children: BetSlipType.values.map((t) {
                    final isSel = betSlip.type == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => state.setBetSlipType(t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isSel ? PskColors.brandBlueLight : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t.title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? PskColors.brandBlueLight : (isDark ? PskColors.textMuted : PskColors.textDarkSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Body: Selections list or Empty state
          Expanded(
            child: betSlip.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sports_soccer,
                          size: 56,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Your betslip is empty',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Click on any match odds to add selections to your betslip.',
                          style: TextStyle(color: PskColors.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: betSlip.selections.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final s = betSlip.selections[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? PskColors.surfaceDark : PskColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDark ? PskColors.borderDark : PskColors.borderLight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.league,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${s.homeTeam} - ${s.awayTeam}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text.rich(
                                    TextSpan(
                                      text: '${s.marketName}: ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: s.selectionLabel,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: PskColors.brandBlueLight,
                                          ),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: PskColors.brandBlue,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    s.oddValue.toStringAsFixed(2),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                InkWell(
                                  onTap: () => state.removeSelection(s.id),
                                  child: const Icon(Icons.close, size: 18, color: PskColors.alertRed),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bottom Section: Stake chips + Calculations + "Place Bet"
          if (betSlip.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? PskColors.bgDarkSecondary : PskColors.surfaceLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? PskColors.borderDark : PskColors.borderLight,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    // Quick stake chips
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [2.0, 5.0, 10.0, 20.0, 50.0].map((amt) {
                          final isSel = betSlip.stake == amt;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: InkWell(
                              onTap: () {
                                state.setStake(amt);
                                _stakeController.text = amt.toStringAsFixed(0);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isSel
                                      ? PskColors.brandBlue
                                      : (isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '+${amt.toStringAsFixed(0)} €',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stake input + total odds
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDark ? PskColors.borderDark : PskColors.borderLight,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Text('Stake: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Expanded(
                                  child: TextField(
                                    controller: _stakeController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      suffixText: '€',
                                    ),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    onChanged: (val) {
                                      final parsed = double.tryParse(val);
                                      if (parsed != null && parsed > 0) {
                                        state.setStake(parsed);
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TOTAL ODDS', style: TextStyle(fontSize: 10, color: PskColors.textMuted)),
                            Text(
                              betSlip.totalOdds.toStringAsFixed(2),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PskColors.accentGold),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Fee & Win breakdown
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Processing fee (5%):', style: TextStyle(fontSize: 11, color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary)),
                        Text('${betSlip.mtFee.toStringAsFixed(2)} €', style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Potential Win (net):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                        Text(
                          '${betSlip.potentialWin.toStringAsFixed(2)} €',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: PskColors.moneyGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // "REVIEW & CONFIRM" — opens the checkout screen
                    ElevatedButton(
                      onPressed: () {
                        if (widget.isBottomSheet) Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => CheckoutScreen(state: state)),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PskColors.brandBlue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        state.isLoggedIn ? 'REVIEW & PLACE BET' : 'REVIEW BET (LOG IN TO PLACE)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  );
}
}
