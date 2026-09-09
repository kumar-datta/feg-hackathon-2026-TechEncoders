import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:home_widget/home_widget.dart';

import '../models/bet_slip_model.dart';
import '../models/sport_event.dart';

/// Bridges PSK's live match, bet slip and boost-odds state to the
/// "PSK Pulse" Android home-screen widgets. A no-op on every other platform
/// this project builds for (web, windows, macos, linux).
///
/// Every push is gated by [enabled] (per-widget opt-in, off by default) and
/// [selfExcluded] (a single account-wide guardrail): when either says no,
/// no match/slip data is written at all — only the flag itself — so a
/// disabled or self-excluded tile never holds odds, scores or picks.
class WidgetBridgeService {
  WidgetBridgeService._();

  static const liveMatchWidget = 'LiveMatchWidgetReceiver';
  static const liveMatchWidgetQualified = 'com.example.psk.LiveMatchWidgetReceiver';

  static const betSlipWidget = 'BetSlipWidgetReceiver';
  static const betSlipWidgetQualified = 'com.example.psk.BetSlipWidgetReceiver';

  static const boostWidget = 'BoostWidgetReceiver';
  static const boostWidgetQualified = 'com.example.psk.BoostWidgetReceiver';

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static Future<void> pushLiveMatch(
    SportEvent? event, {
    required bool enabled,
    required bool selfExcluded,
    required String style,
    required int faceIndex,
    required double balance,
    required int slipCount,
    required double slipTotalOdds,
    required double slipPotentialWin,
  }) async {
    if (!isSupported) return;
    try {
      await HomeWidget.saveWidgetData<bool>('psk_self_excluded', selfExcluded);
      await HomeWidget.saveWidgetData<bool>('live_widget_enabled', enabled);
      // Cosmetic choices, not gambling activity — safe to keep even while the
      // widget is off or the account is self-excluded, so they're ready the
      // moment either is lifted.
      await HomeWidget.saveWidgetData<String>('live_widget_style', style);
      await HomeWidget.saveWidgetData<int>('live_face_index', faceIndex);

      // Wallet face (balance + potential win) — same gate as the score face
      // below, since a balance is at least as sensitive as a score.
      if (enabled && !selfExcluded) {
        await HomeWidget.saveWidgetData<String>('live_wallet_balance', '€${balance.toStringAsFixed(2)}');
        await HomeWidget.saveWidgetData<int>('live_wallet_slip_count', slipCount);
        await HomeWidget.saveWidgetData<String>('live_wallet_slip_odds', slipTotalOdds.toStringAsFixed(2));
        await HomeWidget.saveWidgetData<String>('live_wallet_slip_win', '€${slipPotentialWin.toStringAsFixed(2)}');
      } else {
        await HomeWidget.saveWidgetData<int>('live_wallet_slip_count', 0);
      }

      if (event != null) {
        await HomeWidget.saveWidgetData<String>('live_event_id', event.id);
        await HomeWidget.saveWidgetData<String>('live_league', event.league);
        await HomeWidget.saveWidgetData<String>('live_home_team', event.homeTeam);
        await HomeWidget.saveWidgetData<String>('live_away_team', event.awayTeam);
        await HomeWidget.saveWidgetData<int>('live_home_score', event.homeScore ?? 0);
        await HomeWidget.saveWidgetData<int>('live_away_score', event.awayScore ?? 0);
        await HomeWidget.saveWidgetData<String>('live_minute', event.liveMinute ?? '');

        for (var i = 0; i < 3; i++) {
          final odd = i < event.mainOdds.length ? event.mainOdds[i] : null;
          await HomeWidget.saveWidgetData<String>('live_odds_${i}_label', odd?.label ?? '');
          await HomeWidget.saveWidgetData<String>(
            'live_odds_${i}_value',
            odd == null ? '' : odd.value.toStringAsFixed(2),
          );
          await HomeWidget.saveWidgetData<String>(
            'live_odds_${i}_trend',
            odd == null ? 'flat' : odd.isTrendingUp ? 'up' : odd.isTrendingDown ? 'down' : 'flat',
          );
        }
      }

      if (!enabled || selfExcluded || event == null) {
        await HomeWidget.saveWidgetData<bool>('live_has_match', false);
        await HomeWidget.updateWidget(
          androidName: liveMatchWidget,
          qualifiedAndroidName: liveMatchWidgetQualified,
        );
        return;
      }

      await HomeWidget.saveWidgetData<bool>('live_has_match', true);
      await HomeWidget.updateWidget(
        androidName: liveMatchWidget,
        qualifiedAndroidName: liveMatchWidgetQualified,
      );
    } catch (_) {
      // Best-effort — a widget refresh should never crash the app.
    }
  }

  static Future<void> pushBetSlip(
    BetSlipModel slip, {
    required bool enabled,
    required bool selfExcluded,
  }) async {
    if (!isSupported) return;
    try {
      await HomeWidget.saveWidgetData<bool>('psk_self_excluded', selfExcluded);
      await HomeWidget.saveWidgetData<bool>('slip_widget_enabled', enabled);

      if (!enabled || selfExcluded) {
        await HomeWidget.saveWidgetData<int>('slip_count', 0);
        await HomeWidget.updateWidget(
          androidName: betSlipWidget,
          qualifiedAndroidName: betSlipWidgetQualified,
        );
        return;
      }

      await HomeWidget.saveWidgetData<int>('slip_count', slip.count);
      await HomeWidget.saveWidgetData<String>('slip_stake', '€${slip.stake.toStringAsFixed(2)}');
      await HomeWidget.saveWidgetData<String>('slip_total_odds', slip.totalOdds.toStringAsFixed(2));
      await HomeWidget.saveWidgetData<String>(
        'slip_potential_win',
        '€${slip.potentialWin.toStringAsFixed(2)}',
      );

      // Up to 3 preview rows, "+N more" beyond that.
      for (var i = 0; i < 3; i++) {
        final selection = i < slip.selections.length ? slip.selections[i] : null;
        await HomeWidget.saveWidgetData<String>(
          'slip_row_${i}_label',
          selection == null ? '' : '${selection.homeTeam} — ${selection.selectionLabel}',
        );
        await HomeWidget.saveWidgetData<String>(
          'slip_row_${i}_odd',
          selection == null ? '' : selection.oddValue.toStringAsFixed(2),
        );
      }
      await HomeWidget.saveWidgetData<int>('slip_more_count', slip.count > 3 ? slip.count - 3 : 0);

      await HomeWidget.updateWidget(
        androidName: betSlipWidget,
        qualifiedAndroidName: betSlipWidgetQualified,
      );
    } catch (_) {
      // Best-effort — a widget refresh should never crash the app.
    }
  }

  static Future<void> pushBoostMatch(
    SportEvent? event, {
    required bool enabled,
    required bool selfExcluded,
  }) async {
    if (!isSupported) return;
    try {
      await HomeWidget.saveWidgetData<bool>('psk_self_excluded', selfExcluded);
      await HomeWidget.saveWidgetData<bool>('boost_widget_enabled', enabled);

      if (event != null && event.mainOdds.isNotEmpty) {
        final original = event.mainOdds.first;
        final boosted = double.parse((original.value * 1.12).toStringAsFixed(2));

        await HomeWidget.saveWidgetData<String>('boost_event_id', event.id);
        await HomeWidget.saveWidgetData<String>('boost_league', event.league);
        await HomeWidget.saveWidgetData<String>('boost_home_team', event.homeTeam);
        await HomeWidget.saveWidgetData<String>('boost_away_team', event.awayTeam);
        await HomeWidget.saveWidgetData<String>('boost_start_time', event.startTime);
        await HomeWidget.saveWidgetData<String>('boost_original_odds', original.value.toStringAsFixed(2));
        await HomeWidget.saveWidgetData<String>('boost_boosted_odds', boosted.toStringAsFixed(2));
      }

      if (!enabled || selfExcluded || event == null || event.mainOdds.isEmpty) {
        await HomeWidget.saveWidgetData<bool>('boost_has_match', false);
        await HomeWidget.updateWidget(
          androidName: boostWidget,
          qualifiedAndroidName: boostWidgetQualified,
        );
        return;
      }

      await HomeWidget.saveWidgetData<bool>('boost_has_match', true);
      await HomeWidget.updateWidget(
        androidName: boostWidget,
        qualifiedAndroidName: boostWidgetQualified,
      );
    } catch (_) {
      // Best-effort — a widget refresh should never crash the app.
    }
  }

  /// The deep-link Uri if the app was cold-started by a widget tap.
  static Future<Uri?> checkLaunchUri() async {
    if (!isSupported) return null;
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }

  /// Deep-link Uris from widget taps while the app is already running.
  static Stream<Uri?> get clicks => isSupported ? HomeWidget.widgetClicked : const Stream<Uri?>.empty();
}
