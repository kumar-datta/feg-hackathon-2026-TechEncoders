import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/psk_header.dart';

/// Promotions — filter chips, a featured promo, a 2-column grid and a detail
/// bottom sheet with the terms table.
class PromotionsView extends StatefulWidget {
  final AppState state;

  const PromotionsView({super.key, required this.state});

  @override
  State<PromotionsView> createState() => _PromotionsViewState();
}

class _PromotionsViewState extends State<PromotionsView> {
  String _tag = 'All';

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final promos = ContentData.promos.where((p) => _tag == 'All' || p.tag == _tag).toList();
    final featured = promos.where((p) => p.featured).firstOrNull ?? (promos.isNotEmpty ? promos.first : null);
    final rest = promos.where((p) => p != featured).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 14, 16, 2),
          child: Text('🎁 Promotions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text('Active promotions, welcome bonuses, and seasonal campaigns',
              style: TextStyle(color: PskColors.textMuted, fontSize: 12)),
        ),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ContentData.promoTags.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final t = ContentData.promoTags[i];
              final sel = t == _tag;
              return ChoiceChip(
                label: Text(t),
                selected: sel,
                onSelected: (_) => setState(() => _tag = t),
                selectedColor: PskColors.brandBlue,
                backgroundColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                labelStyle: TextStyle(color: sel ? Colors.white : (isDark ? PskColors.textGray : Colors.black87), fontSize: 12),
                side: BorderSide.none,
              );
            },
          ),
        ),
        if (featured != null) _featured(featured, isDark),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 230,
            ),
            itemBuilder: (_, i) => _card(rest[i], isDark),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Text(
            'Read the terms before opting in: wagering requirements, minimum odds and deadlines apply. Bonuses are never a reason to play more than you planned.',
            style: TextStyle(color: PskColors.textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _banner(Promotion p, double height, double emojiSize) => Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              HSLColor.fromAHSL(1, p.hueA.toDouble(), 0.7, 0.44).toColor(),
              HSLColor.fromAHSL(1, p.hueB.toDouble(), 0.65, 0.24).toColor(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        alignment: Alignment.center,
        child: Text('🎁', style: TextStyle(fontSize: emojiSize)),
      );

  Widget _tagChip(String badge) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: badge == 'NEW' || badge == 'HOT' ? PskColors.accentGold : PskColors.brandBlue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(badge,
            style: TextStyle(color: badge == 'NEW' || badge == 'HOT' ? Colors.black : Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
      );

  Widget _featured(Promotion p, bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _banner(p, 130, 40),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [_tagChip(p.badge), const SizedBox(width: 6), _tagChip(p.tag.toUpperCase())]),
                const SizedBox(height: 8),
                Text(p.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(p.excerpt, style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Text('Valid until ${_date(p.validUntil)}', style: const TextStyle(color: PskColors.brandBlueLight, fontSize: 11)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openDetail(p),
                    style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black, elevation: 0),
                    child: const Text('VIEW DETAILS', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(Promotion p, bool isDark) {
    return InkWell(
      onTap: () => _openDetail(p),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: isDark ? PskColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _banner(p, 80, 28),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tagChip(p.badge),
                    const SizedBox(height: 4),
                    Text(p.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Expanded(
                      child: Text(p.excerpt, style: const TextStyle(fontSize: 10, color: PskColors.textMuted), maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                    const Text('VIEW →', style: TextStyle(color: PskColors.brandBlueLight, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Promotion p) {
    final state = widget.state;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: PskColors.bgDarkSecondary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: PskColors.surfaceDarkAction, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 12),
                ClipRRect(borderRadius: BorderRadius.circular(10), child: _banner(p, 96, 32)),
                const SizedBox(height: 12),
                Row(children: [_tagChip(p.badge), const SizedBox(width: 6), _tagChip(p.tag.toUpperCase())]),
                const SizedBox(height: 8),
                Text(p.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(p.body, style: const TextStyle(color: PskColors.textGray, fontSize: 13, height: 1.5)),
                const SizedBox(height: 14),
                const Text('Terms', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(color: PskColors.surfaceDark, borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    children: [
                      _termRow('Min deposit', p.terms.minDeposit > 0 ? '${p.terms.minDeposit.toStringAsFixed(0)} €' : '—', 0),
                      _termRow('Max bonus', p.terms.maxBonus > 0 ? '${p.terms.maxBonus.toStringAsFixed(0)} €' : '—', 1),
                      _termRow('Wagering', p.terms.wagering, 2),
                      _termRow('Min odds', p.terms.minOdds.toStringAsFixed(2), 3),
                      _termRow('Valid', p.terms.validDays > 0 ? '${p.terms.validDays} days' : 'Ongoing', 4),
                      _termRow('Products', p.terms.products, 5),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (!state.isLoggedIn) {
                        AuthDialog.show(context, state, isRegister: true);
                        return;
                      }
                      if (p.tag == 'New members') {
                        PskHeader.showDepositModal(context, state);
                      } else if (p.tag == 'Casino') {
                        state.setTopTabIndex(PskTab.casino);
                      } else if (p.tag == 'Loto') {
                        state.setTopTabIndex(PskTab.lotto);
                      } else if (p.tag == 'Club') {
                        state.setTopTabIndex(PskTab.championsClub);
                      } else {
                        state.setTopTabIndex(PskTab.sports);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Opted in to "${p.title}". Terms apply.'),
                        backgroundColor: PskColors.liveGreen,
                      ));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: PskColors.accentGold, foregroundColor: Colors.black, elevation: 0),
                    child: Text(p.cta.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(backgroundColor: PskColors.surfaceDarkAction, foregroundColor: PskColors.textGray),
                    child: const Text('FULL TERMS'),
                  ),
                ),
                const SizedBox(height: 6),
                const Text('Demo promotion — no real bonus is credited. Wagering and other terms are illustrative.',
                    style: TextStyle(color: PskColors.textMuted, fontSize: 10, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _termRow(String k, String v, int i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: i.isOdd ? PskColors.surfaceDarkPanel : Colors.transparent,
        child: Row(
          children: [
            Text(k, style: const TextStyle(color: PskColors.textMuted, fontSize: 12)),
            const Spacer(),
            Text(v, style: const TextStyle(color: PskColors.textGray, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  String _date(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
