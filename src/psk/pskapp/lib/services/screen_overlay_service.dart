import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import '../models/sport_event.dart';

/// Service that interacts with native Android system-level overlay APIs
/// and Glance widget pinning.
///
/// Handles:
/// - Screen Overlay Permission check and request (`Settings.canDrawOverlays`)
/// - Draggable Floating Live Score card over all apps and lock screen
/// - 1-Tap Home Screen Glance widget pinning
class ScreenOverlayService {
  ScreenOverlayService._();

  static const MethodChannel _channel = MethodChannel('com.example.psk/overlay');

  static bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Checks if the app has `android.permission.SYSTEM_ALERT_WINDOW` permission.
  static Future<bool> canDrawOverlays() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('canDrawOverlays');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens Android Settings > "Appear on top" / "Display over other apps" for PSK.
  static Future<bool> requestOverlayPermission() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('requestOverlayPermission');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Opens the app's notification settings for lock screen banner configuration.
  static Future<bool> openNotificationSettings() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openNotificationSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Starts the floating live score overlay bubble.
  static Future<bool> startFloatingOverlay(SportEvent? event) async {
    if (!isSupported) return false;
    try {
      final homeTeam = event?.homeTeam ?? 'Dinamo Zagreb';
      final awayTeam = event?.awayTeam ?? 'Hajduk Split';
      final homeScore = event?.homeScore ?? 2;
      final awayScore = event?.awayScore ?? 1;
      final minute = event?.liveMinute ?? "67'";
      final league = event?.league ?? 'SuperSport HNL';

      String o1 = '1.35';
      String oX = '4.80';
      String o2 = '9.50';

      if (event != null && event.mainOdds.isNotEmpty) {
        for (final odd in event.mainOdds) {
          if (odd.label == '1') o1 = odd.value.toStringAsFixed(2);
          if (odd.label == 'X') oX = odd.value.toStringAsFixed(2);
          if (odd.label == '2') o2 = odd.value.toStringAsFixed(2);
        }
      }

      final res = await _channel.invokeMethod<bool>('startFloatingOverlay', {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'minute': minute,
        'league': league,
        'odds1': o1,
        'oddsX': oX,
        'odds2': o2,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Updates the floating overlay with real-time match fluctuations.
  static Future<bool> updateFloatingOverlay(SportEvent? event) async {
    if (!isSupported) return false;
    try {
      final homeTeam = event?.homeTeam ?? 'Dinamo Zagreb';
      final awayTeam = event?.awayTeam ?? 'Hajduk Split';
      final homeScore = event?.homeScore ?? 2;
      final awayScore = event?.awayScore ?? 1;
      final minute = event?.liveMinute ?? "67'";
      final league = event?.league ?? 'SuperSport HNL';

      String o1 = '1.35';
      String oX = '4.80';
      String o2 = '9.50';

      if (event != null && event.mainOdds.isNotEmpty) {
        for (final odd in event.mainOdds) {
          if (odd.label == '1') o1 = odd.value.toStringAsFixed(2);
          if (odd.label == 'X') oX = odd.value.toStringAsFixed(2);
          if (odd.label == '2') o2 = odd.value.toStringAsFixed(2);
        }
      }

      final res = await _channel.invokeMethod<bool>('updateFloatingOverlay', {
        'homeTeam': homeTeam,
        'awayTeam': awayTeam,
        'homeScore': homeScore,
        'awayScore': awayScore,
        'minute': minute,
        'league': league,
        'odds1': o1,
        'oddsX': oX,
        'odds2': o2,
      });
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Stops and removes the floating overlay.
  static Future<bool> stopFloatingOverlay() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('stopFloatingOverlay');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if the floating overlay bubble is currently visible.
  static Future<bool> isFloatingOverlayRunning() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('isFloatingOverlayRunning');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Prompts Android's native widget pin dialog to add the Glance widget to home screen.
  /// [type] can be 'live', 'slip', or 'boost'.
  static Future<bool> pinWidget(String type) async {
    debugPrint('[PSK Pulse] pinWidget("$type") called — isSupported=$isSupported');
    if (!isSupported) {
      debugPrint('[PSK Pulse] pinWidget("$type") — not Android, aborting.');
      return false;
    }
    try {
      debugPrint('[PSK Pulse] pinWidget("$type") — invoking platform channel "com.example.psk/overlay"...');
      final res = await _channel.invokeMethod<bool>('pinWidget', {'type': type});
      debugPrint('[PSK Pulse] pinWidget("$type") — native side returned: $res');
      return res ?? false;
    } catch (e, st) {
      debugPrint('[PSK Pulse] pinWidget("$type") — THREW: $e');
      debugPrint('[PSK Pulse] stack trace:\n$st');
      return false;
    }
  }

  /// Opens Android's Settings > Home screen. There is no public API to read
  /// or change a launcher's "Lock Home screen layout" setting — it's private
  /// to whichever launcher app is installed — so this is the closest system
  /// screen available; from there (or by long-pressing the home screen) the
  /// user reaches their launcher's own settings, where that toggle lives.
  static Future<bool> openHomeSettings() async {
    if (!isSupported) return false;
    try {
      final res = await _channel.invokeMethod<bool>('openHomeSettings');
      return res ?? false;
    } catch (_) {
      return false;
    }
  }
}
