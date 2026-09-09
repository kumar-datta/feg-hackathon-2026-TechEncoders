import 'package:flutter/material.dart';

import '../models/arena_ticket.dart';
import '../models/placed_bet_ticket.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import 'auth_dialog.dart';

/// PSK Arena — the social feed of shared tickets. Filter by Latest / Hot /
/// Winning, copy any ticket onto your slip, react, and share your own.
class ArenaForumWidget extends StatefulWidget {
  final AppState state;

  const ArenaForumWidget({super.key, required this.state});

  @override
  State<ArenaForumWidget> createState() => _ArenaForumWidgetState();
}

class _ArenaForumWidgetState extends State<ArenaForumWidget> {
  int _tab = 0; // 0 latest, 1 hot, 2 winning
  int _shown = 4;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final isForum = state.selectedTopTabIndex == PskTab.forum;

    var tickets = List<ArenaTicket>.from(state.arenaTickets);
    switch (_tab) {
      case 1:
        tickets.sort((a, b) => b.copiedCount.compareTo(a.copiedCount));
      case 2:
        tickets = tickets.where((t) => t.status == ArenaTicketStatus.won).toList();
      default:
        tickets.sort((a, b) => b.sharedAt.compareTo(a.sharedAt));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? PskColors.surfaceDarkPanel : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Icon(isForum ? Icons.forum : Icons.military_tech, color: PskColors.accentGold, size: 32),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isForum ? 'COMMUNITY FORUM' : '🏟️ PSK ARENA FEED',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                    const Text('See what other users are betting on. Copy tickets to your own betslip.',
                        style: TextStyle(color: PskColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Filter tabs
        Row(
          children: ['LATEST', 'HOT', 'WINNING'].asMap().entries.map((e) {
            final sel = _tab == e.key;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = e.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: sel ? PskColors.accentGold : PskColors.borderDark, width: sel ? 3 : 1)),
                  ),
                  alignment: Alignment.center,
                  child: Text(e.value,
                      style: TextStyle(fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.w500, color: sel ? null : PskColors.textMuted)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),

        if (tickets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: Text('No tickets here yet.', style: TextStyle(color: PskColors.textMuted))),
          ),
        ...tickets.take(_shown).map((t) => _ticketCard(t, isDark)),
        if (tickets.length > _shown)
          TextButton(onPressed: () => setState(() => _shown += 4), child: const Text('LOAD MORE TICKETS')),

        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? PskColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
          ),
          child: Column(
            children: [
              const Text('Share your latest ticket to the Arena feed.', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _shareFlow(context),
                  icon: const Icon(Icons.ios_share, size: 16),
                  label: const Text('SHARE MY TICKET', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: PskColors.brandBlue, foregroundColor: Colors.white, elevation: 0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _statusColor(ArenaTicketStatus s) => switch (s) {
        ArenaTicketStatus.won => PskColors.moneyGreen,
        ArenaTicketStatus.lost => PskColors.alertRed,
        ArenaTicketStatus.settled => PskColors.textMuted,
        ArenaTicketStatus.active => PskColors.accentGold,
      };

  Color _legColor(ArenaLegResult r) => switch (r) {
        ArenaLegResult.won => PskColors.moneyGreen,
        ArenaLegResult.lost => PskColors.alertRed,
        ArenaLegResult.voided => PskColors.textMuted,
        ArenaLegResult.pending => PskColors.brandBlueLight,
      };

  Widget _ticketCard(ArenaTicket t, bool isDark) {
    final state = widget.state;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.isMine ? PskColors.brandBlue : (isDark ? PskColors.borderDark : PskColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(radius: 16, backgroundColor: PskColors.brandBlue, child: Text(t.avatar, style: const TextStyle(fontSize: 16))),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text('@${t.user}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis)),
                          if (t.isMine) ...[
                            const SizedBox(width: 6),
                            const Text('you', style: TextStyle(color: PskColors.brandBlueLight, fontSize: 10)),
                          ],
                        ],
                      ),
                      Text('${t.title} · ${t.timeAgo}', style: const TextStyle(color: PskColors.textMuted, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor(t.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: _statusColor(t.status)),
                  ),
                  child: Text(t.status.label, style: TextStyle(color: _statusColor(t.status), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...t.selections.asMap().entries.map((e) {
            final s = e.value;
            final r = e.key < t.legResults.length ? t.legResults[e.key] : ArenaLegResult.pending;
            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 7),
              child: Row(
                children: [
                  Text('${e.key + 1}.', style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${s.homeTeam} — ${s.awayTeam}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                        Text('${s.marketName}: ${s.selectionLabel}', style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: PskColors.surfaceDarkAction, borderRadius: BorderRadius.circular(4)),
                    child: Text(s.oddValue.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white)),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 54,
                    child: Text(r.label, textAlign: TextAlign.right, style: TextStyle(color: _legColor(r), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
            child: Row(
              children: [
                _sum('STAKE', '${t.stake.toStringAsFixed(2)} €'),
                _sum('TOTAL ODDS', t.totalOdds.toStringAsFixed(2)),
                _sum(t.status == ArenaTicketStatus.won ? 'WON' : 'POTENTIAL', '${t.potentialWin.toStringAsFixed(2)} €',
                    color: t.status == ArenaTicketStatus.won ? PskColors.moneyGreen : PskColors.accentGold),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final n = state.copyArenaTicket(t);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('$n selection${n == 1 ? '' : 's'} copied to your betslip'),
                        backgroundColor: PskColors.brandBlue,
                        action: SnackBarAction(label: 'OPEN', textColor: PskColors.accentGold, onPressed: () => state.setBottomNavIndex(PskBottomTab.betslip)),
                      ));
                    },
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('COPY TO SLIP', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: PskColors.brandBlue, foregroundColor: Colors.white, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 8)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Share link copied: psk.demo/arena/${t.id}'),
                    backgroundColor: PskColors.liveGreen,
                  )),
                  icon: const Icon(Icons.share, size: 14),
                  label: const Text('SHARE', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => state.toggleArenaLike(t.id),
                  child: Row(
                    children: [
                      Icon(t.liked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined, size: 16, color: t.liked ? PskColors.accentGold : PskColors.textMuted),
                      const SizedBox(width: 3),
                      Text('${t.likes}', style: const TextStyle(fontSize: 11, color: PskColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            child: Text('${t.copiedCount} copies · ${t.likes} reactions', style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _sum(String label, String value, {Color? color}) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: PskColors.textMuted, fontSize: 9, letterSpacing: 0.5)),
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      );

  void _shareFlow(BuildContext context) {
    final state = widget.state;
    if (!state.isLoggedIn) {
      AuthDialog.show(context, state, isRegister: false);
      return;
    }
    final mine = state.placedTickets;
    if (mine.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Place a ticket first, then share it here.'),
        backgroundColor: PskColors.alertRed,
      ));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: PskColors.bgDarkSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Pick a ticket to share', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            ...mine.take(6).map((PlacedBetTicket t) => ListTile(
                  dense: true,
                  tileColor: PskColors.surfaceDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  title: Text('${t.id} · ${t.legs.length} legs · odds ${t.totalOdds.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                  subtitle: Text('${t.status.label} · stake ${t.stake.toStringAsFixed(2)} € · potential ${t.potentialWin.toStringAsFixed(2)} €',
                      style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                  trailing: const Icon(Icons.ios_share, color: PskColors.brandBlueLight, size: 18),
                  onTap: () {
                    state.shareTicketToArena(t);
                    Navigator.pop(ctx);
                    setState(() => _tab = 0);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Your ticket is now on the Arena feed!'),
                      backgroundColor: PskColors.liveGreen,
                    ));
                  },
                )),
          ],
        ),
      ),
    );
  }
}
