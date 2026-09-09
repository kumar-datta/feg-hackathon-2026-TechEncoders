import 'package:flutter/services.dart';

/// Centralized tactile feedback service for PSK.
/// Provides native vibration and impact sensations for sportsbook odds,
/// betslip actions, cash-outs, and casino gaming.
class HapticService {
  HapticService._();

  static bool _enabled = true;
  static bool get isEnabled => _enabled;

  static void setEnabled(bool value) {
    _enabled = value;
  }

  /// Triggered when an odds pill is tapped on a sports event card.
  static Future<void> oddsSelected() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Triggered when a bet ticket is submitted.
  static Future<void> betPlaced() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  /// Triggered when Early Cash-Out is confirmed.
  static Future<void> cashOut() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggered on casino slot lever pull, roulette ball launch, or blackjack deal.
  static Future<void> casinoAction() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  /// Triggered when a winning spin, blackjack win, or settled bet payout occurs.
  static Future<void> celebration() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Subtle click when switching main navigation tabs or sport pills.
  static Future<void> tabClick() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (_) {}
  }
}
