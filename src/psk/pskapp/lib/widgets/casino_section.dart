import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../casino/game_launcher.dart';
import '../models/casino_game.dart';
import '../state/app_state.dart';
import '../theme/psk_colors.dart';
import 'casino/game_preview_card.dart';
import 'user_quick_resume_section.dart';

/// The casino lobby: hero, jackpot ticker, category + provider chips, search,
/// and a 2-column grid of video-preview tiles.
class CasinoSection extends StatefulWidget {
  final AppState state;

  /// Live Casino tab: only live tables.
  final bool liveOnly;

  const CasinoSection({super.key, required this.state, this.liveOnly = false});

  @override
  State<CasinoSection> createState() => _CasinoSectionState();
}

class _CasinoSectionState extends State<CasinoSection> {
  String _selectedProvider = 'All';
  CasinoCategory _selectedCategory = CasinoCategory.popular;
  String _searchGame = '';
  double _platinumJackpot = 342910.88;
  Timer? _jackpotTimer;

  final List<String> _providers = ['All', 'Playtech', 'Pragmatic Play', 'EGT Digital', 'Novomatic', 'Fazi'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.liveOnly ? CasinoCategory.tableGames : (widget.state.takeRequestedCasinoCategory() ?? CasinoCategory.popular);
    _jackpotTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() => _platinumJackpot += Random().nextDouble() * 0.85);
    });
  }

  @override
  void didUpdateWidget(covariant CasinoSection old) {
    super.didUpdateWidget(old);
    final requested = widget.state.takeRequestedCasinoCategory();
    if (requested != null) _selectedCategory = requested;
    if (widget.liveOnly && !old.liveOnly) _selectedCategory = CasinoCategory.tableGames;
  }

  @override
  void dispose() {
    _jackpotTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isDark = state.isDarkMode;

    final filteredGames = state.casinoGames.where((g) {
      if (widget.liveOnly && !g.isTableGame) return false;
      if (_selectedProvider != 'All' && g.provider != _selectedProvider) return false;
      if (_selectedCategory != CasinoCategory.popular && g.category != _selectedCategory) return false;
      if (_searchGame.isNotEmpty && !g.title.toLowerCase().contains(_searchGame.toLowerCase())) return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 80),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0C2B64), Color(0xFF1752BF), Color(0xFF1A1A24)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PskColors.accentGold.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: PskColors.accentGold, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          widget.liveOnly ? 'LIVE CASINO' : 'PSK CASINO',
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.liveOnly ? 'Real dealers · 24/7 tables' : '2000+ Online Games',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.liveOnly ? 'Roulette, Blackjack & Baccarat' : 'Vatreni Cup & Jackpot Race!',
                  style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.liveOnly
                      ? 'Long-press any table to preview it live. Tap for details.'
                      : 'Long-press a game to preview it. Tap for details, RTP and bet range.',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // Progressive Jackpot Ticker
          if (!widget.liveOnly)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? PskColors.surfaceDarkPanel : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PskColors.accentGold, width: 1.2),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    const Icon(Icons.diamond, color: PskColors.accentGold, size: 24),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PLATINUM JACKPOT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: PskColors.textMuted, letterSpacing: 0.8)),
                        Text('${_platinumJackpot.toStringAsFixed(2)} €',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PskColors.accentGold)),
                      ],
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        final vatreni = state.casinoGames.firstWhere((g) => g.id == 'vatreni_cup', orElse: () => state.casinoGames.first);
                        GameLauncher.play(context, state, vatreni);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PskColors.accentGold,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: const Size(60, 32),
                      ),
                      child: const Text('PLAY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),

          if (state.isLoggedIn && state.gameHistory.isNotEmpty) UserQuickResumeSection(state: state, casinoOnly: true),

          // Category chips
          if (!widget.liveOnly)
            SizedBox(
              height: 46,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                itemCount: CasinoCategory.values.length,
                itemBuilder: (context, idx) {
                  final cat = CasinoCategory.values[idx];
                  final isSel = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text('${cat.icon} ${cat.title}'),
                      selected: isSel,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      selectedColor: PskColors.brandBlue,
                      backgroundColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : (isDark ? PskColors.textGray : Colors.black87),
                        fontSize: 12,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      ),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  );
                },
              ),
            ),

          // Provider chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _providers.length,
              itemBuilder: (context, idx) {
                final prov = _providers[idx];
                final isSel = _selectedProvider == prov;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(prov),
                    backgroundColor: isSel ? (isDark ? PskColors.brandBlueDark : PskColors.brandBlue) : (isDark ? PskColors.surfaceDark : Colors.white),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                      color: isSel ? Colors.white : (isDark ? PskColors.textMuted : PskColors.textDarkSecondary),
                    ),
                    side: BorderSide(color: isSel ? PskColors.brandBlueLight : (isDark ? PskColors.borderDark : PskColors.borderLight)),
                    onPressed: () => setState(() => _selectedProvider = prov),
                  ),
                );
              },
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search games (e.g. Vatreni Cup, Shining Crown)...',
                prefixIcon: const Icon(Icons.search, size: 18),
                isDense: true,
                filled: true,
                fillColor: isDark ? PskColors.surfaceDarkAction : Colors.grey.shade200,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (val) => setState(() => _searchGame = val),
            ),
          ),

          // Grid of preview tiles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: filteredGames.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('No games match your filters', style: TextStyle(color: PskColors.textMuted))),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredGames.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, idx) => GamePreviewCard(game: filteredGames[idx], state: state),
                  ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
