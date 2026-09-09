import 'dart:async';

import 'package:flutter/material.dart';

import '../data/content_data.dart';
import '../models/casino_game.dart';
import '../models/sport_event.dart';
import '../navigation/psk_tabs.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import '../widgets/casino/game_preview_card.dart';
import '../widgets/live_pitch_tracker.dart';
import '../widgets/user_quick_resume_section.dart';

/// The landing screen — hero carousel, quick access grid, top offer, live now,
/// casino rails with video-preview tiles, promo tiles and news. Mirrors the
/// website's Home page.
class HomeView extends StatefulWidget {
  final AppState state;

  const HomeView({super.key, required this.state});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _pager = PageController();
  int _slide = 0;
  Timer? _rotate;

  static const _slides = [
    _Slide(
      colors: [Color(0xFF0A3FB0), Color(0xFF0B4BD4), Color(0xFF17203A)],
      eyebrow: 'SPORTS BETTING',
      title: '500+ Live Events Today',
      text: 'The best odds on football, basketball, tennis and more',
      primary: 'View Offer',
      secondary: 'Live Now →',
      primaryTab: PskTab.sports,
      secondaryTab: PskTab.live,
    ),
    _Slide(
      colors: [Color(0xFF4A1D6E), Color(0xFF2A1046), Color(0xFF140A24)],
      eyebrow: 'ONLINE CASINO',
      title: '2000+ Premium Games',
      text: 'Slots, roulette, blackjack, crash, and live dealers',
      primary: 'Browse Casino',
      secondary: 'Live Casino →',
      primaryTab: PskTab.casino,
      secondaryTab: PskTab.liveCasino,
    ),
    _Slide(
      colors: [Color(0xFF0B5C3A), Color(0xFF083F28), Color(0xFF04210F)],
      eyebrow: 'LOTO & VIRTUALS',
      title: 'Lottery Draws & Virtual Races',
      text: 'Try your luck with 6 lotto games and virtual sports',
      primary: 'Open Loto',
      secondary: 'Virtual Races →',
      primaryTab: PskTab.lotto,
      secondaryTab: PskTab.virtuals,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rotate = Timer.periodic(const Duration(seconds: 6), (_) => _go((_slide + 1) % _slides.length));
  }

  @override
  void dispose() {
    _rotate?.cancel();
    _pager.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (!_pager.hasClients) return;
    _pager.animateToPage(i, duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;
    final events = state.events;
    final top = events.where((e) => !e.isLive).take(4).toList();
    final live = state.liveEvents.take(3).toList();
    final rails = <CasinoCategory, List<CasinoGame>>{
      CasinoCategory.popular: state.casinoGames.where((g) => g.category == CasinoCategory.popular).toList(),
      CasinoCategory.jackpot: state.casinoGames.where((g) => g.hasJackpot).toList(),
      CasinoCategory.newGames: state.casinoGames.where((g) => g.isNew).toList(),
    };

    return ListView(
      padding: const EdgeInsets.only(bottom: 90),
      children: [
        _hero(),
        if (state.isLoggedIn) UserQuickResumeSection(state: state),
        _sectionHeader('Quick Access'),
        _quickGrid(state, isDark),
        _sectionHeader('⭐ Top Offer', trailing: 'Full offer →', onTrailing: () => state.setTopTabIndex(PskTab.sports)),
        _eventPanel(top, isDark),
        if (live.isNotEmpty) ...[
          _sectionHeader('Live Now', liveDot: true, trailing: 'All live →', onTrailing: () => state.setTopTabIndex(PskTab.live)),
          _eventPanel(live, isDark),
        ],
        for (final entry in rails.entries)
          if (entry.value.isNotEmpty) ...[
            _sectionHeader(
              '${entry.key.icon} ${entry.key.title}',
              trailing: 'See all (${entry.value.length}) →',
              onTrailing: () {
                state.requestCasinoCategory(entry.key);
                state.setTopTabIndex(PskTab.casino);
              },
            ),
            SizedBox(
              height: 190,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: entry.value.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) => SizedBox(
                  width: 130,
                  child: GamePreviewCard(game: entry.value[i], state: state, compact: true),
                ),
              ),
            ),
          ],
        _sectionHeader('🎁 Promotions', trailing: 'All promos →', onTrailing: () => state.setTopTabIndex(PskTab.promos)),
        _promoGrid(isDark),
        _sectionHeader('📰 News', trailing: 'All news →'),
        _newsRail(isDark),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '🔞 PSK.demo is an educational demo. No real money, no real betting. Play responsibly.',
            textAlign: TextAlign.center,
            style: TextStyle(color: PskColors.textMuted, fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    return Column(
      children: [
        Container(
          height: 180,
          margin: const EdgeInsets.fromLTRB(10, 8, 10, 6),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PageView.builder(
                  controller: _pager,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _slide = i),
                  itemBuilder: (_, i) => _slideCard(_slides[i]),
                ),
              ),
              Positioned(left: 6, top: 76, child: _arrow('‹', () => _go((_slide - 1 + _slides.length) % _slides.length))),
              Positioned(right: 6, top: 76, child: _arrow('›', () => _go((_slide + 1) % _slides.length))),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (i) => GestureDetector(
              onTap: () => _go(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: i == _slide ? 16 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: i == _slide ? PskColors.accentGold : PskColors.surfaceDarkAction,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _arrow(String glyph, VoidCallback onTap) => InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: Color(0x66000000), shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Text(glyph, style: const TextStyle(color: Colors.white, fontSize: 18, height: 1)),
        ),
      );

  Widget _slideCard(_Slide s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(40, 14, 40, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: s.colors,
          stops: const [0, 0.45, 1],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          transform: const GradientRotation(0.4),
        ),
      ),
      // Bound the width so text wraps, then scale down if the slide is too
      // short for the copy on a small phone.
      child: LayoutBuilder(
        builder: (context, c) => FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: c.maxWidth,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.eyebrow, style: const TextStyle(color: PskColors.brandBlueLight, fontSize: 10, letterSpacing: 0.8)),
                const SizedBox(height: 4),
                Text(s.title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1)),
                const SizedBox(height: 4),
                Text(s.text, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 10),
                _slideButtons(s),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slideButtons(_Slide s) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: () => widget.state.setTopTabIndex(s.primaryTab),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PskColors.accentGold,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(s.primary, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  onPressed: () => widget.state.setTopTabIndex(s.secondaryTab),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(s.secondary, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
    );
  }

  Widget _sectionHeader(String title, {String? trailing, VoidCallback? onTrailing, bool liveDot = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 8),
      child: Row(
        children: [
          if (liveDot) ...[
            Container(width: 8, height: 8, decoration: const BoxDecoration(color: PskColors.alertRed, shape: BoxShape.circle)),
            const SizedBox(width: 6),
          ],
          Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          if (trailing != null)
            InkWell(
              onTap: onTrailing,
              child: Text(trailing, style: const TextStyle(color: PskColors.brandBlueLight, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _quickGrid(AppState state, bool isDark) {
    final items = <(String, String, String, VoidCallback)>[
      ('🏆', 'Sport', '${state.events.length} events', () => state.setTopTabIndex(PskTab.sports)),
      ('🔴', 'Live', '${state.liveEvents.length} events', () => state.setTopTabIndex(PskTab.live)),
      ('🎰', 'Casino', '${state.casinoGames.length} games', () => state.setTopTabIndex(PskTab.casino)),
      ('🎥', 'Live Casino', 'Real dealers', () => state.setTopTabIndex(PskTab.liveCasino)),
      ('🎱', 'Loto', '${ContentData.lotteries.length} draws', () => state.setTopTabIndex(PskTab.lotto)),
      ('🎮', 'Virtuals', 'Races & more', () => state.setTopTabIndex(PskTab.virtuals)),
      ('👆', 'Swipe Bet', 'Quick picks', () => state.setTopTabIndex(PskTab.swipe)),
      ('🎁', 'Promos', 'Bonuses', () => state.setTopTabIndex(PskTab.promos)),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: 86,
        ),
        itemBuilder: (_, i) {
          final it = items[i];
          return InkWell(
            onTap: it.$4,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? PskColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(it.$1, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 2),
                  Text(it.$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(it.$3, style: const TextStyle(fontSize: 9, color: PskColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _eventPanel(List<SportEvent> events, bool isDark) {
    final state = widget.state;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? PskColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
      ),
      child: Column(
        children: [
          for (var i = 0; i < events.length; i++) ...[
            if (i > 0) Divider(height: 1, color: isDark ? PskColors.borderDark : PskColors.borderLight),
            InkWell(
              onTap: events[i].isLive ? () => LivePitchTracker.show(context, events[i]) : null,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 44,
                      child: events[i].isLive
                          ? Text(events[i].liveMinute ?? 'LIVE',
                              style: const TextStyle(color: PskColors.moneyGreen, fontSize: 11, fontWeight: FontWeight.bold))
                          : Text(_timeOf(events[i].startTime), style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${events[i].homeTeam} – ${events[i].awayTeam}',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          Row(
                            children: [
                              Flexible(
                                child: Text('${events[i].sport.icon} ${events[i].league}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: PskColors.textMuted, fontSize: 11)),
                              ),
                              if (events[i].isLive && events[i].homeScore != null) ...[
                                const SizedBox(width: 8),
                                Text('${events[i].homeScore}:${events[i].awayScore}',
                                    style: const TextStyle(color: PskColors.alertRed, fontSize: 11, fontWeight: FontWeight.bold)),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    ...events[i].mainOdds.take(3).map((o) {
                      final sel = state.isOddSelected(events[i].id, 'Match Winner', o.label);
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          onTap: () => state.toggleOdd(events[i], 'Match Winner', o),
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            width: 46,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: sel ? PskColors.brandBlue : PskColors.surfaceDarkPanel,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(o.value.toStringAsFixed(2),
                                style: TextStyle(color: sel ? Colors.white : PskColors.textGray, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _timeOf(String startTime) {
    final m = RegExp(r'\d{1,2}:\d{2}').firstMatch(startTime);
    return m?.group(0) ?? startTime;
  }

  Widget _promoGrid(bool isDark) {
    final promos = ContentData.promos.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: promos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 190,
        ),
        itemBuilder: (_, i) {
          final p = promos[i];
          return InkWell(
            onTap: () => widget.state.setTopTabIndex(PskTab.promos),
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
                  Container(
                    height: 80,
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
                    child: const Text('🎁', style: TextStyle(fontSize: 30)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: PskColors.accentGold, borderRadius: BorderRadius.circular(4)),
                          child: Text(p.badge, style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 4),
                        Text(p.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(p.excerpt, style: const TextStyle(fontSize: 10, color: PskColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _newsRail(bool isDark) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: ContentData.news.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final a = ContentData.news[i];
          return Container(
            width: 200,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? PskColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? PskColors.borderDark : PskColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(a.category, style: const TextStyle(color: PskColors.accentGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${a.publishedAt.day} ${months[a.publishedAt.month - 1]}', style: const TextStyle(color: PskColors.textMuted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(a.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(a.excerpt, style: const TextStyle(fontSize: 11, color: PskColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Slide {
  final List<Color> colors;
  final String eyebrow;
  final String title;
  final String text;
  final String primary;
  final String secondary;
  final int primaryTab;
  final int secondaryTab;
  const _Slide({
    required this.colors,
    required this.eyebrow,
    required this.title,
    required this.text,
    required this.primary,
    required this.secondary,
    required this.primaryTab,
    required this.secondaryTab,
  });
}
