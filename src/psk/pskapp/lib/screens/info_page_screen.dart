import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/psk_colors.dart';

enum InfoPage { help, contact, rules, responsible, privacy }

/// Static support pages the assistant can route to — Help & FAQ, Contact,
/// Game Rules, Responsible Gaming and Privacy. They exist so every registry
/// route lands on a real screen.
class InfoPageScreen extends StatelessWidget {
  final AppState state;
  final InfoPage page;

  const InfoPageScreen({super.key, required this.state, required this.page});

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final content = _content[page]!;
    return Scaffold(
      backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: isDark ? PskColors.bgDark : PskColors.brandBlue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(content.lede, style: const TextStyle(color: PskColors.textMuted, fontSize: 13, height: 1.5)),
          const SizedBox(height: 16),
          ...content.sections.map((s) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? PskColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text(s.$2, style: const TextStyle(color: PskColors.textMuted, fontSize: 12.5, height: 1.5)),
                  ],
                ),
              )),
          if (page == InfoPage.responsible)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: PskColors.brandBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PskColors.brandBlue),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your tools', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('Self-exclusion', style: TextStyle(fontSize: 13)),
                      subtitle: const Text('Pauses widgets, rewards and incentives', style: TextStyle(fontSize: 11)),
                      value: state.selfExcluded,
                      activeThumbColor: PskColors.accentGold,
                      onChanged: (v) => state.setSelfExcluded(v),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              '🔞 Gambling can be addictive. Play responsibly. This is a demo — no real money is involved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: PskColors.textMuted, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

  static final Map<InfoPage, _InfoContent> _content = {
    InfoPage.help: const _InfoContent(
      'Help & FAQ',
      'Answers to the most common questions. The PSK Assistant searches this same content — ask it anything.',
      [
        ('How do I place a bet?', 'Tap any odd in the sportsbook to add it to your betslip, set a stake, then review and confirm at checkout.'),
        ('How do deposits work?', 'This is a demo: the Deposit sheet adds fictional credits instantly. No payment method is ever charged.'),
        ('What is cash-out?', 'On an in-play ticket you can settle early for the amount shown in My Bets. The value updates as matches progress.'),
        ('Why was my bet rejected?', 'Most rejections are an insufficient balance or a closed event. Check your wallet and the event status.'),
        ('How do I use the video previews?', 'Long-press any casino tile to play its demo clip, or tap it to open the preview sheet with Play and Details.'),
      ],
    ),
    InfoPage.contact: const _InfoContent(
      'Contact Support',
      'Support can verify your account and help with anything the assistant cannot answer from the help content.',
      [
        ('Live chat', 'Available 08:00–24:00 every day from this screen in the full app. In the demo, the PSK Assistant handles chat.'),
        ('Email', 'podrska@psk.demo — replies within one working day.'),
        ('Phone', '+385 1 000 0000 (demo number).'),
        ('Complaints', 'Written complaints are acknowledged within 48 hours and resolved within 14 days.'),
      ],
    ),
    InfoPage.rules: const _InfoContent(
      'Game Rules',
      'General rules for sports betting, casino games and bonuses. Product-specific rules are shown inside each game.',
      [
        ('Sports betting', 'Odds are fixed at the time the ticket is confirmed. A ticket with one lost selection loses. Voided selections settle at odds 1.00.'),
        ('Casino', 'Results are produced by a random number generator. Each round is independent; RTP figures are long-run averages.'),
        ('Lotto & virtuals', 'Draws and races are simulated on the device for demonstration. Pay tables are illustrative.'),
        ('Bonuses', 'Bonus credits carry wagering requirements listed on each promotion. Max bet with bonus funds is 5 € per ticket.'),
      ],
    ),
    InfoPage.responsible: const _InfoContent(
      'Responsible Gaming',
      'Betting should be entertainment, never a way to make money or to recover losses. These tools help you stay in control.',
      [
        ('Set limits', 'Deposit, loss and session limits can be set in My Account. Lowering a limit applies immediately; raising one takes 24 hours.'),
        ('Take a break', 'A cooling-off period blocks play for 24 hours to 6 weeks. Self-exclusion blocks play for 6 months or longer and cannot be lifted early.'),
        ('Warning signs', 'Chasing losses, betting money needed for bills, hiding play from others, or feeling unable to stop are signs to seek help.'),
        ('Get help', 'Free and confidential support: Hrvatski zavod za javno zdravstvo helpline 0800 8888 (demo), or your GP.'),
      ],
    ),
    InfoPage.privacy: const _InfoContent(
      'Privacy Policy',
      'What the app stores and why. This is a demo build — nothing leaves the device unless you connect the optional remote assistant.',
      [
        ('Data on the device', 'Your demo session, wallet, betslip, tickets, game history and assistant chat history are stored locally with SharedPreferences.'),
        ('Assistant', 'On-device mode never sends your messages anywhere. If you configure a remote assistant URL, messages are sent to that server.'),
        ('Widgets & notifications', 'PSK Pulse widgets and the lock-screen card read the same local state and are disabled under self-exclusion.'),
        ('Your rights', 'Log out to clear the session, or clear the app data to remove everything.'),
      ],
    ),
  };
}

class _InfoContent {
  final String title;
  final String lede;
  final List<(String, String)> sections;
  const _InfoContent(this.title, this.lede, this.sections);
}
