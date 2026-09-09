import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../widgets/betslip_sheet.dart';

class BetslipScreen extends StatelessWidget {
  final AppState state;

  const BetslipScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: state.isDarkMode ? PskColors.bgDark : PskColors.bgLight,
      body: BetslipSheet(state: state),
    );
  }
}
