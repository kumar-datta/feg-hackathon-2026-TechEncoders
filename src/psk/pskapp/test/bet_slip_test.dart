import 'package:flutter_test/flutter_test.dart';
import 'package:psk/models/bet_slip_model.dart';

void main() {
  group('BetSlipModel Calculation Tests', () {
    test('Calculates total odds and winnings correctly with 5% MT fee', () {
      const selections = [
        BetSelection(
          eventId: 'hnl_1',
          homeTeam: 'Dinamo Zagreb',
          awayTeam: 'Hajduk Split',
          league: 'SuperSport HNL',
          marketName: 'Match Winner',
          selectionLabel: '1',
          oddValue: 1.50,
        ),
        BetSelection(
          eventId: 'epl_1',
          homeTeam: 'Liverpool',
          awayTeam: 'Chelsea',
          league: 'Premier League',
          marketName: 'Match Winner',
          selectionLabel: '1',
          oddValue: 2.00,
        ),
      ];

      const betSlip = BetSlipModel(
        selections: selections,
        stake: 10.0,
      );

      // Total odds = 1.50 * 2.00 = 3.00
      expect(betSlip.totalOdds, 3.00);

      // MT Fee (5%) = 10.0 * 0.05 = 0.50 €
      expect(betSlip.mtFee, 0.50);

      // Net stake = 10.0 - 0.50 = 9.50 €
      expect(betSlip.netStake, 9.50);

      // Gross win = 9.50 * 3.00 = 28.50 €
      expect(betSlip.grossWin, 28.50);

      // Profit = 28.50 - 10.0 = 18.50 €
      // Tax (10%) = 1.85 €
      expect(betSlip.estimatedTax, 1.85);

      // Potential win = 28.50 - 1.85 = 26.65 €
      expect(betSlip.potentialWin, 26.65);
    });

    test('Empty betslip returns 0 odds and win', () {
      const betSlip = BetSlipModel(selections: [], stake: 10.0);
      expect(betSlip.totalOdds, 0.0);
      expect(betSlip.grossWin, 0.0);
      expect(betSlip.potentialWin, 0.0);
    });
  });
}
