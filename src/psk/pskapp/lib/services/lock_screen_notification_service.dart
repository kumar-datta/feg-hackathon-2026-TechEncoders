import 'dart:io' show Platform;
import 'dart:ui' show Color;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/sport_event.dart';

/// PSK Pulse's "lock screen widget".
///
/// Android removed native lock-screen (Keyguard) widgets in 5.0 — there is
/// no API left to place an interactive tile there. The real, current
/// equivalent is what this does instead: a silent, ongoing, publicly-visible
/// notification that Android renders directly on the lock screen and keeps
/// updating in place, no unlock required to read it.
///
/// Same guardrails as the home-screen widgets, plus one of its own: unlike a
/// home-screen tile (which the user has to pull by looking at their home
/// screen), a lock-screen card is visible the instant the screen wakes, so
/// it also goes dark during quiet hours rather than only staying silent.
class LockScreenNotificationService {
  LockScreenNotificationService._();

  static const _channelId = 'psk_pulse_lock_screen';
  static const _channelName = 'PSK Pulse — Live Match';
  static const _channelDescription =
      'A silent, updating card for your tracked live match, shown on the lock screen.';
  static const _notificationId = 7001;
  static const _pskGold = Color(0xFFFFDB01);

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  static bool get isInitialized => _initialized;

  /// Sets up the plugin and the tap-to-open callback. Safe to call once at
  /// app startup — does not itself show anything or ask for permission.
  static Future<void> initialize({required void Function(String? payload) onTapped}) async {
    if (!isSupported || _initialized) return;
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (response) => onTapped(response.payload),
      );

      // Explicitly register notification channel for Android 8.0+ / Android 14 lock screen
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        await androidImpl.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDescription,
            importance: Importance.max,
            playSound: false,
            enableVibration: false,
            showBadge: true,
          ),
        );
      }

      _initialized = true;
    } catch (_) {
      // Best-effort — the lock-screen card just won't be available.
    }
  }

  /// Checks if notifications are currently enabled for this app.
  static Future<bool> areNotificationsEnabled() async {
    if (!isSupported) return false;
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final enabled = await androidImpl.areNotificationsEnabled();
        return enabled ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// Requests Android 13+'s runtime notification permission. Call this when
  /// the user turns the lock-screen widget on, not proactively at launch.
  static Future<bool> requestPermission() async {
    if (!isSupported) return false;
    try {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        return granted ?? false;
      }
    } catch (_) {
      // Denied or unavailable
    }
    return false;
  }

  static Future<void> sync(
    SportEvent? event, {
    required bool enabled,
    required bool selfExcluded,
    required bool quietHours,
    required int faceIndex,
    required double balance,
    required int slipCount,
    required double slipTotalOdds,
    required double slipPotentialWin,
  }) async {
    if (!isSupported || !_initialized) return;
    try {
      if (!enabled || selfExcluded || quietHours || event == null) {
        await _plugin.cancel(id: _notificationId);
        return;
      }

      final String title;
      final String body;
      if (faceIndex == 1) {
        // Wallet face — rotates in every ~30s alongside the score face.
        title = 'PSK Pulse — Your Wallet';
        body = slipCount > 0
            ? 'Balance: €${balance.toStringAsFixed(2)}\n'
                '$slipCount picks • odds ${slipTotalOdds.toStringAsFixed(2)} • '
                'potential win €${slipPotentialWin.toStringAsFixed(2)}'
            : 'Balance: €${balance.toStringAsFixed(2)}\nNo active picks';
      } else {
        final oddsText = event.mainOdds.map((o) => '${o.label}: ${o.value.toStringAsFixed(2)}').join('   ');
        title = 'LIVE — ${event.league}';
        body =
            '${event.homeTeam} ${event.homeScore ?? 0}–${event.awayScore ?? 0} '
            '${event.awayTeam} • ${event.liveMinute ?? "LIVE"}'
            '${oddsText.isEmpty ? '' : '\n$oddsText'}';
      }

      await _plugin.show(
        id: _notificationId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.max,
            priority: Priority.max,
            ongoing: true,
            silent: true,
            playSound: false,
            enableVibration: false,
            onlyAlertOnce: true,
            autoCancel: false,
            showWhen: true,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.status,
            color: _pskGold,
            styleInformation: BigTextStyleInformation(body),
          ),
        ),
        payload: 'psk://live/${event.id}',
      );
    } catch (_) {
      // Best-effort — a lock-screen refresh should never crash the app.
    }
  }
}
