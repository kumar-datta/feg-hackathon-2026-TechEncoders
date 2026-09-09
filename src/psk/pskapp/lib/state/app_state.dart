import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sport_event.dart';
import '../models/bet_slip_model.dart';
import '../models/casino_game.dart';
import '../models/demo_user.dart';
import '../models/daily_streak.dart';
import '../models/widget_style.dart';
import '../models/placed_bet_ticket.dart';
import '../models/played_game_log.dart';
import '../models/arena_ticket.dart';
import '../models/loyalty.dart';
import '../data/mock_psk_data.dart';
import '../data/content_data.dart';
import '../navigation/psk_tabs.dart';
import '../services/widget_bridge_service.dart';
import '../services/streak_service.dart';
import '../services/widget_style_service.dart';
import '../services/lock_screen_notification_service.dart';
import '../services/haptic_service.dart';
import '../services/screen_overlay_service.dart';

class AppState extends ChangeNotifier {
  int _currentBottomNavIndex = PskBottomTab.none; // Home has no bottom tab
  int _selectedTopTabIndex = PskTab.home;

  /// Casino category a deep link / the assistant asked the lobby to open with.
  CasinoCategory? _requestedCasinoCategory;

  // Champions Club loyalty ledger (points are derived from activity; the
  // ledger records redemptions and bonuses). Persisted per device.
  List<LoyaltyEntry> _loyaltyHistory = [];

  // PSK Arena social feed — seeded community tickets plus anything you share.
  List<ArenaTicket> _arenaTickets = [];

  // Play limits (My Account). Display-only in this demo, like the website.
  double _dailyDepositLimit = 100;
  double _weeklyLossLimit = 250;
  int _sessionLimitMinutes = 60;
  String _timeFilter = 'All';
  SportType? _selectedSport;
  String _searchQuery = '';
  bool _isDarkMode = true;
  bool _isLoggedIn = false;
  String _username = 'Guest';
  String _userBadge = 'Guest';
  String _userAvatar = '👤';
  double _balance = 125.50;

  BetSlipModel _betSlip = const BetSlipModel(stake: 5.0);
  List<PlacedBetTicket> _placedTickets = [];
  List<SportEvent> _events = [];
  List<CasinoGame> _casinoGames = [];
  List<PlayedGameLog> _gameHistory = [];
  Timer? _liveSimulationTimer;
  Timer? _pulseRotationTimer;

  /// Which face the Live Match widget and lock-screen card are currently
  /// showing: 0 = live score, 1 = balance / potential win. Flips every 30s
  /// via [_startPulseRotation] — see its doc comment for the honest caveat
  /// on what "every 30 seconds" can and can't mean on a home-screen widget.
  int _pulseFaceIndex = 0;

  /// Set when a home-screen widget tap asks for a specific live match's
  /// Pitch Tracker to be opened once the main navigation is on screen.
  String? _pendingLiveEventId;

  // PSK Pulse widgets — default to enabled so newly placed widgets work immediately.
  // Can be toggled or self-excluded in PSK Pulse settings.
  bool _liveWidgetEnabled = true;
  bool _slipWidgetEnabled = true;
  bool _boostWidgetEnabled = true;
  bool _selfExcluded = false;
  bool _lockScreenWidgetEnabled = false;
  bool _floatingOverlayEnabled = false;
  LiveWidgetStyle _liveWidgetStyle = LiveWidgetStyle.defaultStyle;

  // Persistence keys
  static const _keyThemeMode = 'psk_is_dark_mode';
  static const _keyIsLoggedIn = 'psk_is_logged_in';
  static const _keyUsername = 'psk_username';
  static const _keyUserBadge = 'psk_user_badge';
  static const _keyUserAvatar = 'psk_user_avatar';
  static const _keyBalance = 'psk_balance';
  static const _keyLiveEnabled = 'psk_widget_live_enabled';
  static const _keySlipEnabled = 'psk_widget_slip_enabled';
  static const _keyBoostEnabled = 'psk_widget_boost_enabled';
  static const _keyLockEnabled = 'psk_widget_lock_enabled';
  static const _keyOverlayEnabled = 'psk_floating_overlay_enabled';
  static const _keyBetSlipSelections = 'psk_betslip_selections';
  static const _keyBetSlipStake = 'psk_betslip_stake';
  static const _keyPlacedTickets = 'psk_placed_tickets';
  static const _keyGameHistory = 'psk_game_history';
  static const _keyLoyaltyHistory = 'psk_loyalty_history';
  static const _keyDepositLimit = 'psk_limit_deposit';
  static const _keyLossLimit = 'psk_limit_loss';
  static const _keySessionLimit = 'psk_limit_session';

  // Daily streak — see lib/screens/daily_streak_screen.dart. Persisted
  // per-device via StreakService, not per demo login.
  int _currentStreak = 0;
  int _longestStreak = 0;
  DateTime? _lastClaimDate;
  int _bonusSpins = 0;

  AppState() {
    _events = MockPskData.getSportsEvents();
    _casinoGames = MockPskData.getCasinoGames();
    _seedArena();
    _startLiveSimulation();
    _startPulseRotation();
    _syncLiveWidget();
    _syncSlipWidget();
    _syncBoostWidget();
    _syncLockScreenWidget();
    _loadStreak();
    _loadWidgetStyle();
    restorePersistedState();
  }

  /// Rotates the Live Match widget and lock-screen card between the live
  /// score and the wallet (balance / potential win) every 30 seconds.
  ///
  /// Honest caveat: Glance widgets and notifications can't run their own
  /// timers — the only thing that can push new content is this app process,
  /// same as the live-score ticker above. So this rotation runs for as long
  /// as PSK is alive (foreground, or not yet killed in the background), not
  /// as a true always-on background service.
  void _startPulseRotation() {
    _pulseRotationTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _pulseFaceIndex = (_pulseFaceIndex + 1) % 2;
      _syncLiveWidget();
      _syncLockScreenWidget();
    });
  }

  /// Restores user theme, session, wallet balance, betslip, and placed tickets from SharedPreferences.
  Future<void> restorePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (prefs.containsKey(_keyThemeMode)) {
        _isDarkMode = prefs.getBool(_keyThemeMode) ?? true;
      }
      if (prefs.containsKey(_keyIsLoggedIn)) {
        _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
        _username = prefs.getString(_keyUsername) ?? 'Guest';
        _userBadge = prefs.getString(_keyUserBadge) ?? 'Guest';
        _userAvatar = prefs.getString(_keyUserAvatar) ?? '👤';
      }
      if (prefs.containsKey(_keyBalance)) {
        _balance = prefs.getDouble(_keyBalance) ?? 125.50;
      }
      if (prefs.containsKey(_keyLiveEnabled)) {
        _liveWidgetEnabled = prefs.getBool(_keyLiveEnabled) ?? true;
      }
      if (prefs.containsKey(_keySlipEnabled)) {
        _slipWidgetEnabled = prefs.getBool(_keySlipEnabled) ?? true;
      }
      if (prefs.containsKey(_keyBoostEnabled)) {
        _boostWidgetEnabled = prefs.getBool(_keyBoostEnabled) ?? true;
      }
      if (prefs.containsKey(_keyLockEnabled)) {
        _lockScreenWidgetEnabled = prefs.getBool(_keyLockEnabled) ?? false;
      }
      if (prefs.containsKey(_keyOverlayEnabled)) {
        _floatingOverlayEnabled = prefs.getBool(_keyOverlayEnabled) ?? false;
      }

      // Restore betslip
      if (prefs.containsKey(_keyBetSlipSelections)) {
        final rawSlip = prefs.getString(_keyBetSlipSelections);
        final stake = prefs.getDouble(_keyBetSlipStake) ?? 5.0;
        if (rawSlip != null && rawSlip.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(rawSlip) as List<dynamic>;
          final selections = jsonList.map((item) {
            final m = item as Map<String, dynamic>;
            return BetSelection(
              eventId: m['eventId'] as String? ?? '',
              homeTeam: m['homeTeam'] as String? ?? '',
              awayTeam: m['awayTeam'] as String? ?? '',
              league: m['league'] as String? ?? '',
              marketName: m['marketName'] as String? ?? 'Match Winner',
              selectionLabel: m['selectionLabel'] as String? ?? '1',
              oddValue: (m['oddValue'] as num?)?.toDouble() ?? 1.0,
              isLive: m['isLive'] as bool? ?? false,
            );
          }).toList();
          _betSlip = _betSlip.copyWith(selections: selections, stake: stake);
        }
      }

      // Restore placed tickets
      if (prefs.containsKey(_keyPlacedTickets)) {
        final rawTickets = prefs.getString(_keyPlacedTickets);
        if (rawTickets != null && rawTickets.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(rawTickets) as List<dynamic>;
          _placedTickets = jsonList
              .map((item) => PlacedBetTicket.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (_isLoggedIn && _placedTickets.isEmpty) {
        final matched = DemoUserProfile.demoProfiles.where(
          (p) => p.username.toLowerCase() == _username.toLowerCase(),
        ).firstOrNull;
        if (matched != null) {
          _placedTickets = List<PlacedBetTicket>.from(matched.recentTickets);
        }
      }

      // Restore loyalty ledger and play limits
      if (prefs.containsKey(_keyLoyaltyHistory)) {
        final raw = prefs.getString(_keyLoyaltyHistory);
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(raw) as List<dynamic>;
          _loyaltyHistory = jsonList.map((e) => LoyaltyEntry.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      _dailyDepositLimit = prefs.getDouble(_keyDepositLimit) ?? _dailyDepositLimit;
      _weeklyLossLimit = prefs.getDouble(_keyLossLimit) ?? _weeklyLossLimit;
      _sessionLimitMinutes = prefs.getInt(_keySessionLimit) ?? _sessionLimitMinutes;

      // Restore game history
      if (prefs.containsKey(_keyGameHistory)) {
        final rawHistory = prefs.getString(_keyGameHistory);
        if (rawHistory != null && rawHistory.isNotEmpty) {
          final List<dynamic> jsonList = jsonDecode(rawHistory) as List<dynamic>;
          _gameHistory = jsonList
              .map((item) => PlayedGameLog.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      } else if (_isLoggedIn && _gameHistory.isEmpty) {
        final matched = DemoUserProfile.demoProfiles.where(
          (p) => p.username.toLowerCase() == _username.toLowerCase(),
        ).firstOrNull;
        if (matched != null) {
          _gameHistory = List<PlayedGameLog>.from(matched.recentGames);
        }
      }

      notifyListeners();
      _syncLiveWidget();
      _syncSlipWidget();
      _syncBoostWidget();
      _syncLockScreenWidget();
    } catch (_) {
      // Best effort in test environments or initial runs
    }
  }

  /// Saves all current state to SharedPreferences immediately.
  Future<void> savePersistedState() async {
    await _saveTheme();
    await _saveAuth();
    await _saveWallet();
    await _saveWidgetsConfig();
    await _saveBetSlip();
    await _savePlacedTickets();
    await _saveGameHistory();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyThemeMode, _isDarkMode);
    } catch (_) {}
  }

  Future<void> _saveAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, _isLoggedIn);
      await prefs.setString(_keyUsername, _username);
      await prefs.setString(_keyUserBadge, _userBadge);
      await prefs.setString(_keyUserAvatar, _userAvatar);
      await prefs.setDouble(_keyBalance, _balance);
    } catch (_) {}
  }

  Future<void> _saveWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyBalance, _balance);
    } catch (_) {}
  }

  Future<void> _saveWidgetsConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLiveEnabled, _liveWidgetEnabled);
      await prefs.setBool(_keySlipEnabled, _slipWidgetEnabled);
      await prefs.setBool(_keyBoostEnabled, _boostWidgetEnabled);
      await prefs.setBool(_keyLockEnabled, _lockScreenWidgetEnabled);
      await prefs.setBool(_keyOverlayEnabled, _floatingOverlayEnabled);
    } catch (_) {}
  }

  Future<void> _saveBetSlip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _betSlip.selections.map((s) => {
        'eventId': s.eventId,
        'homeTeam': s.homeTeam,
        'awayTeam': s.awayTeam,
        'league': s.league,
        'marketName': s.marketName,
        'selectionLabel': s.selectionLabel,
        'oddValue': s.oddValue,
        'isLive': s.isLive,
      }).toList();
      await prefs.setString(_keyBetSlipSelections, jsonEncode(list));
      await prefs.setDouble(_keyBetSlipStake, _betSlip.stake);
    } catch (_) {}
  }

  Future<void> _savePlacedTickets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_placedTickets.map((t) => t.toJson()).toList());
      await prefs.setString(_keyPlacedTickets, data);
    } catch (_) {}
  }

  Future<void> _saveGameHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(_gameHistory.map((g) => g.toJson()).toList());
      await prefs.setString(_keyGameHistory, data);
    } catch (_) {}
  }

  Future<void> _saveLoyalty() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyLoyaltyHistory, jsonEncode(_loyaltyHistory.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> _saveLimits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyDepositLimit, _dailyDepositLimit);
      await prefs.setDouble(_keyLossLimit, _weeklyLossLimit);
      await prefs.setInt(_keySessionLimit, _sessionLimitMinutes);
    } catch (_) {}
  }

  void addGameLog(PlayedGameLog log) {
    _gameHistory.insert(0, log);
    _saveGameHistory();
    // Champions Club: casino play earns 2 pts per euro staked.
    final pts = (log.stake * 2).round();
    if (pts > 0) _addLoyalty('Casino play · ${log.gameTitle}', pts, save: true);
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Instant games (lotto draws, virtual races): stake, win, log, points.
  // ------------------------------------------------------------------

  /// Settles one instant-game round against the wallet. Returns false when the
  /// player is logged out or cannot cover the stake.
  bool settleInstantRound({
    required String gameId,
    required String title,
    required String category,
    required String icon,
    required double stake,
    required double win,
    required String summary,
    List<String> logs = const [],
  }) {
    if (!_isLoggedIn || _balance < stake) return false;
    _balance = double.parse((_balance - stake + win).toStringAsFixed(2));
    _saveWallet();
    addGameLog(PlayedGameLog(
      id: '${gameId}_${DateTime.now().millisecondsSinceEpoch}',
      gameId: gameId,
      gameTitle: title,
      category: category,
      provider: 'PSK',
      gameIcon: icon,
      timestamp: DateTime.now(),
      stake: stake,
      winAmount: win,
      roundsPlayed: 1,
      summary: summary,
      detailedLogs: logs,
    ));
    if (win > stake) HapticService.cashOut();
    _syncLiveWidget();
    _syncLockScreenWidget();
    return true;
  }

  // ------------------------------------------------------------------
  // Champions Club
  // ------------------------------------------------------------------

  void _addLoyalty(String action, int points, {bool save = false}) {
    _loyaltyHistory.insert(0, LoyaltyEntry(date: DateTime.now(), action: action, points: points));
    if (_loyaltyHistory.length > 60) _loyaltyHistory = _loyaltyHistory.sublist(0, 60);
    if (save) _saveLoyalty();
  }

  /// Points = welcome bonus + 1 pt/€ on tickets + 2 pt/€ on casino + streak,
  /// minus redemptions. Recomputed from activity so it stays consistent.
  int get loyaltyPoints {
    if (!_isLoggedIn) return 0;
    var pts = 500;
    for (final t in _placedTickets) {
      pts += t.stake.round();
      if (t.status == TicketStatus.won) pts += t.stake.round();
    }
    for (final g in _gameHistory) {
      pts += (g.stake * 2).round();
    }
    pts += currentStreak * 5;
    for (final e in _loyaltyHistory) {
      if (e.points < 0) pts += e.points;
    }
    return pts < 0 ? 0 : pts;
  }

  List<LoyaltyEntry> get loyaltyHistory {
    // the derived ledger: persisted entries plus activity-derived lines
    final derived = <LoyaltyEntry>[
      ..._loyaltyHistory,
      for (final t in _placedTickets)
        LoyaltyEntry(date: t.placedAt, action: 'Bet placed · ${t.id}', points: t.stake.round()),
      for (final t in _placedTickets.where((t) => t.status == TicketStatus.won))
        LoyaltyEntry(date: t.settledAt ?? t.placedAt, action: 'Bet won · ${t.id}', points: t.stake.round()),
      for (final g in _gameHistory)
        LoyaltyEntry(date: g.timestamp, action: 'Casino play · ${g.gameTitle}', points: (g.stake * 2).round()),
      if (currentStreak > 0)
        LoyaltyEntry(date: _lastClaimDate ?? DateTime.now(), action: 'Streak day $currentStreak', points: currentStreak * 5),
    ];
    // persisted redemptions/bonuses are already in _loyaltyHistory; drop the
    // duplicate "Casino play" lines that addGameLog also wrote there
    final seen = <String>{};
    final out = <LoyaltyEntry>[];
    for (final e in derived) {
      final key = '${e.date.millisecondsSinceEpoch ~/ 1000}|${e.action}|${e.points}';
      if (seen.add(key)) out.add(e);
    }
    out.sort((a, b) => b.date.compareTo(a.date));
    return out;
  }

  LoyaltyTier get loyaltyTier {
    var tier = ContentData.tiers.first;
    for (final t in ContentData.tiers) {
      if (loyaltyPoints >= t.points) tier = t;
    }
    return tier;
  }

  LoyaltyTier? get nextLoyaltyTier {
    for (final t in ContentData.tiers) {
      if (t.points > loyaltyPoints) return t;
    }
    return null;
  }

  int get monthlyBetsPlaced {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return _placedTickets.where((t) => t.placedAt.isAfter(cutoff)).length;
  }

  int get monthlyCasinoRounds {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return _gameHistory.where((g) => g.timestamp.isAfter(cutoff)).fold(0, (a, g) => a + g.roundsPlayed);
  }

  double get monthlyWagered {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final bets = _placedTickets.where((t) => t.placedAt.isAfter(cutoff)).fold(0.0, (a, t) => a + t.stake);
    final casino = _gameHistory.where((g) => g.timestamp.isAfter(cutoff)).fold(0.0, (a, g) => a + g.stake);
    return bets + casino;
  }

  /// Spends points on a reward. Free bets credit the wallet; spins add bonus
  /// spins; the rest are recorded as redeemed.
  bool redeemReward(LoyaltyReward reward) {
    if (!_isLoggedIn || loyaltyPoints < reward.cost) return false;
    _addLoyalty('Redeemed · ${reward.title}', -reward.cost);
    if (reward.id == 'free_bet_5') _balance += 5;
    if (reward.id == 'spins_10') _bonusSpins += 10;
    _saveLoyalty();
    _saveWallet();
    HapticService.betPlaced();
    notifyListeners();
    return true;
  }

  // ------------------------------------------------------------------
  // PSK Arena
  // ------------------------------------------------------------------

  void _seedArena() {
    final seeds = MockPskData.getArenaTickets();
    final now = DateTime.now();
    _arenaTickets = seeds.asMap().entries.map((e) {
      final i = e.key;
      final t = e.value;
      final selections = t['selections'] as List<BetSelection>;
      final status = i == 1 || i == 4
          ? ArenaTicketStatus.won
          : i == 3
              ? ArenaTicketStatus.lost
              : ArenaTicketStatus.active;
      final legs = selections.asMap().entries.map((s) {
        if (status == ArenaTicketStatus.won) return ArenaLegResult.won;
        if (status == ArenaTicketStatus.lost) return s.key == selections.length - 1 ? ArenaLegResult.lost : ArenaLegResult.won;
        return s.key == 0 ? ArenaLegResult.won : ArenaLegResult.pending;
      }).toList();
      return ArenaTicket(
        id: 'ARENA-${1000 + i}',
        user: t['user'] as String,
        avatar: t['avatar'] as String,
        title: t['title'] as String,
        stake: t['stake'] as double,
        totalOdds: t['odds'] as double,
        potentialWin: t['potentialWin'] as double,
        likes: t['likes'] as int,
        copiedCount: t['copiedCount'] as int,
        selections: selections,
        legResults: legs,
        status: status,
        sharedAt: now.subtract(Duration(minutes: 2 + i * 13)),
      );
    }).toList();
  }

  List<ArenaTicket> get arenaTickets => List.unmodifiable(_arenaTickets);

  /// Copies all selections from a shared ticket onto the slip (one selection
  /// per event, like the website). Returns the number of selections copied.
  int copyArenaTicket(ArenaTicket ticket) {
    final updated = List<BetSelection>.from(_betSlip.selections);
    var added = 0;
    for (final s in ticket.selections) {
      final idx = updated.indexWhere((u) => u.eventId == s.eventId && u.marketName == s.marketName);
      if (idx >= 0) {
        updated[idx] = s;
      } else {
        updated.add(s);
      }
      added++;
    }
    _betSlip = _betSlip.copyWith(selections: updated);
    final i = _arenaTickets.indexWhere((t) => t.id == ticket.id);
    if (i >= 0) _arenaTickets[i] = ticket.copyWith(copiedCount: ticket.copiedCount + 1);
    _saveBetSlip();
    HapticService.oddsSelected();
    notifyListeners();
    _syncSlipWidget();
    return added;
  }

  void toggleArenaLike(String id) {
    final i = _arenaTickets.indexWhere((t) => t.id == id);
    if (i < 0) return;
    final t = _arenaTickets[i];
    _arenaTickets[i] = t.copyWith(liked: !t.liked, likes: t.liked ? t.likes - 1 : t.likes + 1);
    notifyListeners();
  }

  void shareTicketToArena(PlacedBetTicket ticket, {String? title}) {
    final status = switch (ticket.status) {
      TicketStatus.won => ArenaTicketStatus.won,
      TicketStatus.lost => ArenaTicketStatus.lost,
      TicketStatus.cashedOut => ArenaTicketStatus.settled,
      TicketStatus.inPlay => ArenaTicketStatus.active,
    };
    _arenaTickets.removeWhere((t) => t.id == 'MINE-${ticket.id}');
    _arenaTickets.insert(
      0,
      ArenaTicket(
        id: 'MINE-${ticket.id}',
        user: _username,
        avatar: _userAvatar,
        title: title ?? '${ticket.legs.length}-fold · ${ticket.legs.first.selection.league}',
        stake: ticket.stake,
        totalOdds: ticket.totalOdds,
        potentialWin: ticket.potentialWin,
        likes: 0,
        copiedCount: 0,
        selections: ticket.legs.map((l) => l.selection).toList(),
        legResults: ticket.legs
            .map((l) => switch (l.outcome) {
                  LegOutcome.won => ArenaLegResult.won,
                  LegOutcome.lost => ArenaLegResult.lost,
                  _ => ArenaLegResult.pending,
                })
            .toList(),
        status: status,
        sharedAt: DateTime.now(),
        isMine: true,
      ),
    );
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Casino lobby deep links + play limits
  // ------------------------------------------------------------------

  void requestCasinoCategory(CasinoCategory category) {
    _requestedCasinoCategory = category;
  }

  CasinoCategory? takeRequestedCasinoCategory() {
    final c = _requestedCasinoCategory;
    _requestedCasinoCategory = null;
    return c;
  }

  double get dailyDepositLimit => _dailyDepositLimit;
  double get weeklyLossLimit => _weeklyLossLimit;
  int get sessionLimitMinutes => _sessionLimitMinutes;

  void setDailyDepositLimit(double v) {
    _dailyDepositLimit = v;
    _saveLimits();
    notifyListeners();
  }

  void setWeeklyLossLimit(double v) {
    _weeklyLossLimit = v;
    _saveLimits();
    notifyListeners();
  }

  void setSessionLimitMinutes(int v) {
    _sessionLimitMinutes = v;
    _saveLimits();
    notifyListeners();
  }

  Future<void> _loadWidgetStyle() async {
    try {
      _liveWidgetStyle = await WidgetStyleService.loadLiveStyle();
      notifyListeners();
      _syncLiveWidget();
    } catch (_) {
      // Ignored in headless tests or when storage unavailable
    }
  }

  Future<void> _loadStreak() async {
    try {
      final data = await StreakService.load();
      _currentStreak = data.currentStreak;
      _longestStreak = data.longestStreak;
      _lastClaimDate = data.lastClaimDate;
      notifyListeners();
    } catch (_) {
      // Ignored in headless tests or when storage unavailable
    }
  }

  @override
  void dispose() {
    _liveSimulationTimer?.cancel();
    _pulseRotationTimer?.cancel();
    super.dispose();
  }

  // Getters
  int get currentBottomNavIndex => _currentBottomNavIndex;
  int get selectedTopTabIndex => _selectedTopTabIndex;
  String get timeFilter => _timeFilter;
  SportType? get selectedSport => _selectedSport;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get userBadge => _userBadge;
  String get userAvatar => _userAvatar;
  double get balance => _balance;
  BetSlipModel get betSlip => _betSlip;
  List<PlacedBetTicket> get placedTickets => List.unmodifiable(_placedTickets);
  List<PlacedBetTicket> get activeTickets => _placedTickets.where((t) => t.isInPlay).toList();
  List<PlacedBetTicket> get settledTickets => _placedTickets.where((t) => t.isSettled).toList();
  int get activeTicketsCount => activeTickets.length;
  List<SportEvent> get events => _events;
  List<CasinoGame> get casinoGames => _casinoGames;
  List<PlayedGameLog> get gameHistory => List.unmodifiable(_gameHistory);

  List<SportEvent> get filteredEvents {
    return _events.where((e) {
      if (_selectedSport != null && e.sport != _selectedSport) {
        return false;
      }
      if (_selectedTopTabIndex == PskTab.live && !e.isLive) {
        return false;
      }
      if (_timeFilter == 'Today' &&
          !e.startTime.contains('Today') &&
          !e.startTime.contains('Tonight') &&
          !e.startTime.contains('h)') &&
          !e.isLive) {
        return false;
      }
      if (_timeFilter == 'Tomorrow' && !e.startTime.contains('Tomorrow')) {
        return false;
      }
      if (_timeFilter == '3h' &&
          !e.isLive &&
          !e.startTime.contains('1h') &&
          !e.startTime.contains('2h') &&
          !e.startTime.contains('3h')) {
        return false;
      }
      if (_timeFilter == 'Weekend' &&
          !e.startTime.contains('Weekend') &&
          !e.startTime.contains('Saturday') &&
          !e.startTime.contains('Sunday')) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final match = e.homeTeam.toLowerCase().contains(q) ||
            e.awayTeam.toLowerCase().contains(q) ||
            e.league.toLowerCase().contains(q);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  List<SportEvent> get liveEvents => _events.where((e) => e.isLive).toList();

  String? get pendingLiveEventId => _pendingLiveEventId;

  /// The match "PSK Pulse" widgets track — the flagship live fixture if it's
  /// still in play, otherwise whichever match is currently live.
  SportEvent? get trackedLiveMatch {
    for (final e in _events) {
      if (e.id == 'live_1' && e.isLive) return e;
    }
    return liveEvents.isNotEmpty ? liveEvents.first : null;
  }

  /// The match the Favorit Plus / Prednost boost widget tracks — the first
  /// event PSK has boosted.
  SportEvent? get trackedBoostMatch {
    for (final e in _events) {
      if (e.hasFavoritPlus) return e;
    }
    return null;
  }

  bool get liveWidgetEnabled => _liveWidgetEnabled;
  bool get slipWidgetEnabled => _slipWidgetEnabled;
  bool get boostWidgetEnabled => _boostWidgetEnabled;
  bool get lockScreenWidgetEnabled => _lockScreenWidgetEnabled;
  bool get floatingOverlayEnabled => _floatingOverlayEnabled;
  bool get selfExcluded => _selfExcluded;
  LiveWidgetStyle get liveWidgetStyle => _liveWidgetStyle;

  bool isQuietHoursNow() {
    final hour = DateTime.now().hour;
    return hour >= 0 && hour < 7;
  }

  void setLiveWidgetStyle(LiveWidgetStyle style) {
    if (_liveWidgetStyle == style) return;
    _liveWidgetStyle = style;
    notifyListeners();
    WidgetStyleService.saveLiveStyle(style);
    _syncLiveWidget();
  }

  // Daily streak
  int get bonusSpins => _bonusSpins;
  int get longestStreak => _longestStreak;

  /// The streak as it stands right now — 0 once more than a day has passed
  /// since the last claim, even if that break hasn't been "claimed away" yet.
  int get currentStreak => _lastClaimDate == null || _daysSinceLastClaim() > 1 ? 0 : _currentStreak;

  bool get claimedToday => _lastClaimDate != null && _daysSinceLastClaim() == 0;

  /// Rewards are a login perk, and pause entirely under self-exclusion —
  /// same guardrail principle as the PSK Pulse widgets: never dangle an
  /// incentive in front of an at-risk or excluded account.
  bool get canClaimDailyReward => _isLoggedIn && !_selfExcluded && !claimedToday;

  /// What the next claim would grant, for the "Claim Day X" preview.
  StreakReward get nextStreakReward => DailyStreakRewards.forStreakCount(_projectedNextStreak());

  int _daysSinceLastClaim() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(_lastClaimDate!.year, _lastClaimDate!.month, _lastClaimDate!.day);
    return today.difference(last).inDays;
  }

  int _projectedNextStreak() {
    if (_lastClaimDate == null) return 1;
    final gap = _daysSinceLastClaim();
    if (gap == 0) return _currentStreak; // already claimed today
    if (gap == 1) return _currentStreak + 1; // consecutive day — streak continues
    return 1; // missed a day or more — streak restarts
  }

  /// Claims today's reward and returns it, or null if [canClaimDailyReward]
  /// is false. Credits the reward to the balance (cash) or bonus spins.
  StreakReward? claimDailyReward() {
    if (!canClaimDailyReward) return null;

    final newStreak = _projectedNextStreak();
    _currentStreak = newStreak;
    if (newStreak > _longestStreak) _longestStreak = newStreak;
    _lastClaimDate = DateTime.now();

    final reward = DailyStreakRewards.forStreakCount(newStreak);
    if (reward.type == StreakRewardType.bonusCash) {
      _balance += reward.amount;
    } else {
      _bonusSpins += reward.amount.toInt();
    }

    StreakService.save(StreakData(
      currentStreak: _currentStreak,
      longestStreak: _longestStreak,
      lastClaimDate: _lastClaimDate,
    ));

    notifyListeners();
    return reward;
  }

  // Home-screen widget deep links
  void requestOpenLiveEvent(String eventId) {
    _pendingLiveEventId = eventId;
    setTopTabIndex(PskTab.live); // also notifies listeners
  }

  void clearPendingLiveEvent() {
    _pendingLiveEventId = null;
  }

  void openBetSlipTab() {
    setBottomNavIndex(PskBottomTab.betslip);
  }

  void openBoostMatch(String eventId) {
    setTopTabIndex(PskTab.sports);
  }

  void goHome() => setTopTabIndex(PskTab.home);

  // PSK Pulse widget settings
  void setLiveWidgetEnabled(bool value) {
    _liveWidgetEnabled = value;
    _saveWidgetsConfig();
    notifyListeners();
    _syncLiveWidget();
  }

  void setSlipWidgetEnabled(bool value) {
    _slipWidgetEnabled = value;
    _saveWidgetsConfig();
    notifyListeners();
    _syncSlipWidget();
  }

  void setBoostWidgetEnabled(bool value) {
    _boostWidgetEnabled = value;
    _saveWidgetsConfig();
    notifyListeners();
    _syncBoostWidget();
  }

  void setLockScreenWidgetEnabled(bool value) {
    _lockScreenWidgetEnabled = value;
    _saveWidgetsConfig();
    notifyListeners();
    if (value) {
      LockScreenNotificationService.requestPermission();
    }
    _syncLockScreenWidget();
  }

  Future<void> setFloatingOverlayEnabled(bool value) async {
    _floatingOverlayEnabled = value;
    _saveWidgetsConfig();
    notifyListeners();
    if (value && !_selfExcluded) {
      final canDraw = await ScreenOverlayService.canDrawOverlays();
      if (!canDraw) {
        await ScreenOverlayService.requestOverlayPermission();
      }
      await ScreenOverlayService.startFloatingOverlay(trackedLiveMatch);
    } else {
      await ScreenOverlayService.stopFloatingOverlay();
    }
  }

  void setSelfExcluded(bool value) {
    _selfExcluded = value;
    notifyListeners();
    _syncLiveWidget();
    _syncSlipWidget();
    _syncBoostWidget();
    _syncLockScreenWidget();
    if (value) {
      ScreenOverlayService.stopFloatingOverlay();
    } else if (_floatingOverlayEnabled) {
      ScreenOverlayService.startFloatingOverlay(trackedLiveMatch);
    }
  }

  void _syncLiveWidget() {
    WidgetBridgeService.pushLiveMatch(
      trackedLiveMatch,
      enabled: _liveWidgetEnabled,
      selfExcluded: _selfExcluded,
      style: _liveWidgetStyle.key,
      faceIndex: _pulseFaceIndex,
      balance: _balance,
      slipCount: _betSlip.count,
      slipTotalOdds: _betSlip.totalOdds,
      slipPotentialWin: _betSlip.potentialWin,
    );
  }

  void _syncSlipWidget() {
    WidgetBridgeService.pushBetSlip(
      _betSlip,
      enabled: _slipWidgetEnabled,
      selfExcluded: _selfExcluded,
    );
  }

  void _syncBoostWidget() {
    WidgetBridgeService.pushBoostMatch(
      trackedBoostMatch,
      enabled: _boostWidgetEnabled,
      selfExcluded: _selfExcluded,
    );
  }

  void _syncLockScreenWidget() {
    LockScreenNotificationService.sync(
      trackedLiveMatch,
      enabled: _lockScreenWidgetEnabled,
      selfExcluded: _selfExcluded,
      quietHours: isQuietHoursNow(),
      faceIndex: _pulseFaceIndex,
      balance: _balance,
      slipCount: _betSlip.count,
      slipTotalOdds: _betSlip.totalOdds,
      slipPotentialWin: _betSlip.potentialWin,
    );
  }

  // Navigation Setters
  void setBottomNavIndex(int index) {
    if (_currentBottomNavIndex != index) {
      HapticService.tabClick();
    }
    _currentBottomNavIndex = index;
    if (index == PskBottomTab.live) {
      _selectedTopTabIndex = PskTab.live;
    } else if (index == PskBottomTab.sports) {
      _selectedTopTabIndex = PskTab.sports;
    } else if (index == PskBottomTab.casino) {
      _selectedTopTabIndex = PskTab.casino;
    }
    notifyListeners();
  }

  void setTopTabIndex(int index) {
    if (_selectedTopTabIndex != index) {
      HapticService.tabClick();
    }
    _selectedTopTabIndex = index;
    if (index == PskTab.sports) {
      _currentBottomNavIndex = PskBottomTab.sports;
    } else if (index == PskTab.live) {
      _currentBottomNavIndex = PskBottomTab.live;
    } else if (index == PskTab.casino || index == PskTab.liveCasino) {
      _currentBottomNavIndex = PskBottomTab.casino;
    } else {
      _currentBottomNavIndex = PskBottomTab.none;
    }
    notifyListeners();
  }

  void setTimeFilter(String filter) {
    _timeFilter = filter;
    notifyListeners();
  }

  void setSport(SportType? sport) {
    if (_selectedSport == sport) {
      _selectedSport = null; // Toggle off
    } else {
      _selectedSport = sport;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }

  void setThemeMode(bool isDark) {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      _saveTheme();
      notifyListeners();
    }
  }

  // Betslip Management
  bool isOddSelected(String eventId, String marketName, String label) {
    return _betSlip.selections.any(
      (s) => s.eventId == eventId && s.marketName == marketName && s.selectionLabel == label,
    );
  }

  void toggleOdd(SportEvent event, String marketName, OddOption option) {
    HapticService.oddsSelected();

    final existingIndex = _betSlip.selections.indexWhere(
      (s) => s.eventId == event.id && s.marketName == marketName,
    );

    List<BetSelection> updated = List.from(_betSlip.selections);

    if (existingIndex >= 0) {
      final current = updated[existingIndex];
      if (current.selectionLabel == option.label) {
        // Remove if tapping same
        updated.removeAt(existingIndex);
      } else {
        // Replace with new option
        updated[existingIndex] = BetSelection(
          eventId: event.id,
          homeTeam: event.homeTeam,
          awayTeam: event.awayTeam,
          league: event.league,
          marketName: marketName,
          selectionLabel: option.label,
          oddValue: option.value,
          isLive: event.isLive,
        );
      }
    } else {
      // Add new
      updated.add(BetSelection(
        eventId: event.id,
        homeTeam: event.homeTeam,
        awayTeam: event.awayTeam,
        league: event.league,
        marketName: marketName,
        selectionLabel: option.label,
        oddValue: option.value,
        isLive: event.isLive,
      ));
    }

    _betSlip = _betSlip.copyWith(selections: updated);
    _saveBetSlip();
    notifyListeners();
    _syncSlipWidget();
    _syncLiveWidget();
    _syncLockScreenWidget();
  }

  void removeSelection(String id) {
    final updated = _betSlip.selections.where((s) => s.id != id).toList();
    _betSlip = _betSlip.copyWith(selections: updated);
    _saveBetSlip();
    notifyListeners();
    _syncSlipWidget();
    _syncLiveWidget();
    _syncLockScreenWidget();
  }

  void clearBetSlip() {
    _betSlip = _betSlip.copyWith(selections: []);
    _saveBetSlip();
    notifyListeners();
    _syncSlipWidget();
    _syncLiveWidget();
    _syncLockScreenWidget();
  }

  void setStake(double stake) {
    _betSlip = _betSlip.copyWith(stake: stake);
    _saveBetSlip();
    notifyListeners();
    _syncSlipWidget();
    _syncLiveWidget();
    _syncLockScreenWidget();
  }

  void setBetSlipType(BetSlipType type) {
    _betSlip = _betSlip.copyWith(type: type);
    _saveBetSlip();
    notifyListeners();
  }

  /// Places the bet and returns the created PlacedBetTicket if successful.
  PlacedBetTicket? placeBet() {
    if (_betSlip.isEmpty) return null;
    if (_balance < _betSlip.stake) return null;

    final ticketId = 'HR-${Random().nextInt(89999) + 10000}-2026';
    final legs = _betSlip.selections.map((s) {
      final liveMatch = _events.where((e) => e.id == s.eventId).firstOrNull;
      return PlacedBetLeg(
        selection: s,
        outcome: LegOutcome.winning,
        currentScore: liveMatch != null && liveMatch.homeScore != null
            ? '${liveMatch.homeScore}–${liveMatch.awayScore}'
            : null,
        matchMinute: liveMatch?.liveMinute,
      );
    }).toList();

    final ticket = PlacedBetTicket(
      id: ticketId,
      placedAt: DateTime.now(),
      stake: _betSlip.stake,
      totalOdds: _betSlip.totalOdds,
      potentialWin: _betSlip.potentialWin,
      legs: legs,
      status: TicketStatus.inPlay,
    );

    _balance -= _betSlip.stake;
    _placedTickets.insert(0, ticket);
    _betSlip = _betSlip.copyWith(selections: []);

    _saveWallet();
    _saveBetSlip();
    _savePlacedTickets();

    HapticService.betPlaced();
    notifyListeners();
    _syncSlipWidget();
    _syncLiveWidget();
    _syncLockScreenWidget();
    return ticket;
  }

  /// Cashes out an active in-play ticket early.
  bool cashOutTicket(String ticketId) {
    final index = _placedTickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return false;

    final ticket = _placedTickets[index];
    if (!ticket.isInPlay) return false;

    final amount = ticket.currentCashOutValue;
    if (amount <= 0) return false;

    _balance += amount;
    _placedTickets[index] = ticket.copyWith(
      status: TicketStatus.cashedOut,
      cashedOutAmount: amount,
      settledAt: DateTime.now(),
    );

    _saveWallet();
    _savePlacedTickets();

    HapticService.cashOut();
    notifyListeners();
    return true;
  }

  void copyTicket(List<BetSelection> selections) {
    _betSlip = _betSlip.copyWith(selections: selections);
    _currentBottomNavIndex = PskBottomTab.betslip;
    _saveBetSlip();
    notifyListeners();
    _syncSlipWidget();
  }

  // Auth & Wallet
  void login(String username, String password) {
    final cleanUser = username.trim();
    final matched = DemoUserProfile.demoProfiles.where(
      (p) => p.username.toLowerCase() == cleanUser.toLowerCase(),
    ).firstOrNull;

    if (matched != null) {
      loginAsDemo(matched);
      return;
    }

    _isLoggedIn = true;
    _username = cleanUser.isNotEmpty ? cleanUser : 'Player_PSK';
    _userAvatar = '👤';
    _userBadge = 'Club Member';
    _balance = 125.50;
    _saveAuth();
    notifyListeners();
  }

  void loginAsDemo(DemoUserProfile profile) {
    _isLoggedIn = true;
    _username = profile.username;
    _userAvatar = profile.avatar;
    _userBadge = profile.badge;
    _balance = profile.startingBalance;
    _gameHistory = List<PlayedGameLog>.from(profile.recentGames);
    _placedTickets = List<PlacedBetTicket>.from(profile.recentTickets);
    _saveAuth();
    _saveGameHistory();
    _savePlacedTickets();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _username = 'Guest';
    _userBadge = 'Guest';
    _userAvatar = '👤';
    _balance = 125.50;
    _gameHistory = [];
    _placedTickets = [];
    _loyaltyHistory = [];
    _arenaTickets.removeWhere((t) => t.isMine);
    _saveAuth();
    _saveGameHistory();
    _savePlacedTickets();
    _saveLoyalty();
    notifyListeners();
  }

  void deposit(double amount) {
    _balance += amount;
    _saveWallet();
    notifyListeners();
    _syncLiveWidget();
    _syncLockScreenWidget();
  }

  // Live simulation ticker for realistic in-play experience
  void _startLiveSimulation() {
    final random = Random();
    _liveSimulationTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_events.isEmpty) return;

      bool changed = false;
      _events = _events.map((e) {
        if (!e.isLive) return e;

        // Football matches: increment minute occasionally
        if (e.sport == SportType.football && e.liveMinute != null && e.liveMinute!.contains('\'')) {
          final currentMin = int.tryParse(e.liveMinute!.replaceAll('\'', ''));
          if (currentMin != null && currentMin < 90 && random.nextInt(3) == 0) {
            changed = true;
            return e.copyWith(liveMinute: '${currentMin + 1}\'');
          }
        }

        // Fluctuating odds on random live matches
        if (random.nextInt(4) == 0 && e.mainOdds.isNotEmpty) {
          final odds = List<OddOption>.from(e.mainOdds);
          final randIndex = random.nextInt(odds.length);
          final current = odds[randIndex];
          final delta = (random.nextBool() ? 0.05 : -0.05);
          final newValue = double.parse(max(1.05, current.value + delta).toStringAsFixed(2));

          odds[randIndex] = current.copyWith(
            previousValue: current.value,
            value: newValue,
          );
          changed = true;
          return e.copyWith(mainOdds: odds);
        }

        return e;
      }).toList();

      // Sync live score updates into open bet tickets
      if (_placedTickets.isNotEmpty) {
        bool ticketsUpdated = false;
        _placedTickets = _placedTickets.map((ticket) {
          if (!ticket.isInPlay) return ticket;
          final updatedLegs = ticket.legs.map((leg) {
            final event = _events.where((e) => e.id == leg.selection.eventId).firstOrNull;
            if (event != null && event.isLive) {
              final newScore = '${event.homeScore ?? 0}–${event.awayScore ?? 0}';
              if (leg.currentScore != newScore || leg.matchMinute != event.liveMinute) {
                ticketsUpdated = true;
                return leg.copyWith(
                  currentScore: newScore,
                  matchMinute: event.liveMinute,
                );
              }
            }
            return leg;
          }).toList();
          return ticket.copyWith(legs: updatedLegs);
        }).toList();

        if (ticketsUpdated) {
          changed = true;
          _savePlacedTickets();
        }
      }

      if (changed) {
        notifyListeners();
        _syncLiveWidget();
        _syncBoostWidget();
        if (_floatingOverlayEnabled && !_selfExcluded) {
          ScreenOverlayService.updateFloatingOverlay(trackedLiveMatch);
        }
      }
      // Re-checked every tick, not just on change, so a quiet-hours boundary
      // (e.g. the clock crossing 00:00 or 07:00) still gets picked up.
      _syncLockScreenWidget();
    });
  }
}
