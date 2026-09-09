import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';

/// Champions Club — loyalty progress card, tier ladder, rewards shop, points
/// history and earning rules.
class ChampionsClubView extends StatefulWidget {
  final AppState state;

  const ChampionsClubView({super.key, required this.state});

  @override
  State<ChampionsClubView> createState() => _ChampionsClubViewState();
}

class _ChampionsClubViewState extends State<ChampionsClubView> {
  int _historyShown = 6;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final panel = isDark ? PskColors.surfaceDark : Colors.white;
    final points = state.loyaltyPoints;
    final tier = state.loyaltyTier;
    final next = state.nextLoyaltyTier;
    final progress = next == null ? 1.0 : ((points - tier.points) / (next.points - tier.points)).clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 2),
          child: Text('🏅 Champions Club', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Text('Loyalty programme · tier system · rewards', style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
        ),

        // Progress card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF0C2B64), PskColors.brandBlue, Color(0xFF1A1A24)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: !state.isLoggedIn
              ? Column(
                  children: [
                    const Text('Log in to see your tier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => AuthDialog.show(context, state, isRegister: false),
                      style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black),
                      child: const Text('LOG IN'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CURRENT TIER', style: TextStyle(color: PskColors.brandBlueLight, fontSize: 10, letterSpacing: 0.8)),
                            Text(tier.name.toUpperCase(),
                                style: TextStyle(color: Color(tier.colour), fontSize: 22, fontWeight: FontWeight.w800)),
                            const Text('Member since Jan 2026', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('POINTS', style: TextStyle(color: PskColors.brandBlueLight, fontSize: 10, letterSpacing: 0.8)),
                            Text(_fmt(points), style: const TextStyle(color: PskColors.accentGold, fontSize: 26, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation(PskColors.accentGold),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      next == null
                          ? 'Highest tier reached'
                          : '${(progress * 100).round()}% · Next tier: ${next.name} · ${_fmt(next.points - points)} points needed',
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    const Divider(color: Colors.white12, height: 22),
                    Row(
                      children: [
                        _stat('Bets placed', '${state.monthlyBetsPlaced}'),
                        _stat('Casino rounds', '${state.monthlyCasinoRounds}'),
                        _stat('Total wagered', '${state.monthlyWagered.toStringAsFixed(0)} €'),
                      ],
                    ),
                  ],
                ),
        ),

        // Tier ladder
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text('Tier ladder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        ...ContentData.tiers.reversed.map((t) {
          final you = state.isLoggedIn && t.name == tier.name;
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: panel,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: you ? Color(t.colour) : (isDark ? PskColors.borderDark : PskColors.borderLight), width: you ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: Color(t.colour).withValues(alpha: 0.2), shape: BoxShape.circle, border: Border.all(color: Color(t.colour))),
                  alignment: Alignment.center,
                  child: const Icon(Icons.emoji_events, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        children: [
                          Text(t.name, style: TextStyle(color: Color(t.colour), fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${_fmt(t.points)}+ pts', style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                          if (you) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: PskColors.accentGold, borderRadius: BorderRadius.circular(4)),
                              child: const Text('YOU', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(t.perks.join(' · '), style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),

        // Rewards shop
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('Redeem Points', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ContentData.rewards.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 150,
            ),
            itemBuilder: (_, i) {
              final r = ContentData.rewards[i];
              final can = state.isLoggedIn && points >= r.cost;
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: panel,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.icon, style: const TextStyle(fontSize: 22)),
                    const SizedBox(height: 4),
                    Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(r.description, style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
                    const Spacer(),
                    Row(
                      children: [
                        Text('${r.cost} pts',
                            style: TextStyle(color: can ? PskColors.accentGold : PskColors.textMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: can
                                ? () {
                                    final ok = state.redeemReward(r);
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                      content: Text(ok ? 'Redeemed ${r.title} for ${r.cost} points' : 'Not enough points'),
                                      backgroundColor: ok ? PskColors.liveGreen : PskColors.alertRed,
                                    ));
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PskColors.brandBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              elevation: 0,
                            ),
                            child: const Text('REDEEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Points history
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text('Points history', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              if (state.loyaltyHistory.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text('No activity yet — place a bet or spin a slot to earn points.',
                      style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
                ),
              ...state.loyaltyHistory.take(_historyShown).map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 56,
                          child: Text('${h.date.day.toString().padLeft(2, '0')}.${h.date.month.toString().padLeft(2, '0')}.',
                              style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                        ),
                        Expanded(child: Text(h.action, style: const TextStyle(fontSize: 12))),
                        Text('${h.points >= 0 ? '+' : ''}${h.points}',
                            style: TextStyle(
                                color: h.points >= 0 ? PskColors.moneyGreen : PskColors.alertRed, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  )),
              if (state.loyaltyHistory.length > _historyShown)
                TextButton(
                  onPressed: () => setState(() => _historyShown += 6),
                  child: const Text('LOAD MORE', style: TextStyle(fontSize: 11)),
                ),
            ],
          ),
        ),

        // Earning rules
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('How points are earned', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...ContentData.earningRules.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Text('• ${e.key}', style: const TextStyle(fontSize: 12)),
                        const Spacer(),
                        Text(e.value, style: const TextStyle(color: PskColors.accentGold, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
              const SizedBox(height: 6),
              const Text('Tier evaluation: monthly · Points expiry: 6 months',
                  style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
              const SizedBox(height: 6),
              const Text(
                'Loyalty programmes encourage more frequent play. Benefits should never become a reason to play more than you planned.',
                style: TextStyle(color: PskColors.textMuted, fontSize: 10, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stat(String label, String value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: const TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 0.5)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      );

  static String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
