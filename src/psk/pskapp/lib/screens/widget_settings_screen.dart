import 'package:flutter/material.dart';
import '../theme/psk_colors.dart';
import '../state/app_state.dart';
import '../models/widget_style.dart';
import '../services/screen_overlay_service.dart';
import '../services/lock_screen_notification_service.dart';

// The Live Match widget's own fixed palette — it looks the same regardless
// of the app's light/dark theme, so these previews use literal colors that
// mirror LiveMatchWidget.kt exactly rather than PskColors' theme-aware ones.
class _PulseTile {
  static const bg = Color(0xFF18181E);
  static const pill = Color(0xFF363644);
  static const white = Color(0xFFFFFFFF);
  static const muted = Color(0xFFB0B0C0);
  static const gold = Color(0xFFFFDB01);
  static const goldInk = Color(0xFF3A2F00);
  static const live = Color(0xFF0E7C1C);
  static const up = Color(0xFFC52D16);
  static const down = Color(0xFF35E94D);
}

/// PSK Pulse settings — widget opt-ins, screen overlay permissions,
/// 1-tap home-screen pinning, and responsible gaming guardrails.
class WidgetSettingsScreen extends StatefulWidget {
  final AppState state;

  const WidgetSettingsScreen({super.key, required this.state});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> with WidgetsBindingObserver {
  bool _hasOverlayPermission = false;
  bool _hasNotificationPermission = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (lifecycleState == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final overlay = await ScreenOverlayService.canDrawOverlays();
    final notif = await LockScreenNotificationService.areNotificationsEnabled();
    if (mounted) {
      setState(() {
        _hasOverlayPermission = overlay;
        _hasNotificationPermission = notif;
      });
    }
  }

  void _showPinFeedback(String widgetName, bool success) {
    debugPrint('[PSK Pulse] _showPinFeedback("$widgetName", success=$success) — mounted=$mounted');
    if (!mounted) {
      debugPrint('[PSK Pulse] _showPinFeedback — widget not mounted, SnackBar skipped.');
      return;
    }
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "$widgetName: request sent. If it doesn't land on your home screen, "
                    'your layout may be locked — see the tip above.'
                : 'Could not pin automatically. Please add from your launcher widgets menu.',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: success ? PskColors.moneyGreen : PskColors.alertRed,
          duration: const Duration(seconds: 3),
        ),
      );
      debugPrint('[PSK Pulse] _showPinFeedback — SnackBar shown.');
    } catch (e, st) {
      debugPrint('[PSK Pulse] _showPinFeedback — THREW while showing SnackBar: $e');
      debugPrint('[PSK Pulse] stack trace:\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final isDark = state.isDarkMode;
        final cardColor = isDark ? PskColors.surfaceDark : Colors.white;
        final borderColor = isDark ? PskColors.borderDark : PskColors.borderLight;

        return Scaffold(
          backgroundColor: isDark ? PskColors.bgDark : PskColors.bgLight,
          appBar: AppBar(
            backgroundColor: isDark ? PskColors.bgDarkSecondary : PskColors.brandBlue,
            foregroundColor: Colors.white,
            title: const Text('PSK Pulse Widgets & Overlay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              // --- PERMISSIONS SECTION ---
              Text(
                'SYSTEM & SCREEN OVERLAY PERMISSIONS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Required for floating live score bubbles over other apps, lock screen updates, '
                'and 1-tap home-screen widget placement.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),

              // Overlay Permission Card
              _permissionCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.layers_outlined,
                title: 'Screen Overlay Permission ("Appear on top")',
                description: 'Draws live floating scores and lock screen widgets over any screen.',
                isGranted: _hasOverlayPermission,
                buttonText: _hasOverlayPermission ? 'Configured' : 'Grant Overlay Permission',
                onAction: () async {
                  await ScreenOverlayService.requestOverlayPermission();
                  await Future.delayed(const Duration(milliseconds: 500));
                  _checkPermissions();
                },
              ),
              const SizedBox(height: 10),

              // Notification Permission Card
              _permissionCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.notifications_active_outlined,
                title: 'Lock Screen Notifications',
                description: 'Keeps high-priority, ongoing live match cards visible on the lock screen.',
                isGranted: _hasNotificationPermission,
                buttonText: _hasNotificationPermission ? 'Allowed' : 'Enable Notifications',
                onAction: () async {
                  final granted = await LockScreenNotificationService.requestPermission();
                  if (!granted) {
                    await ScreenOverlayService.openNotificationSettings();
                  }
                  _checkPermissions();
                },
              ),
              const SizedBox(height: 10),

              // Battery Optimization Tip Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF22242D) : const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? PskColors.borderDark : const Color(0xFFD0DCE5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.battery_charging_full, size: 18, color: PskColors.accentGold),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Battery Optimization Notice (Samsung / Android 14)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'To ensure 24/7 real-time live score updates without OEM system sleep delays, set Battery usage to "Unrestricted" in App Info.',
                            style: TextStyle(fontSize: 11, color: PskColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- FLOATING SCREEN OVERLAY ---
              Text(
                'FLOATING SCREEN OVERLAY (BUBBLE)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Displays a compact, draggable live score and odds card floating on top of all apps, '
                'your home screen, and the lock screen. Tap the bubble anytime to open the match.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.floatingOverlayEnabled ? PskColors.accentGold : borderColor,
                    width: state.floatingOverlayEnabled ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: state.floatingOverlayEnabled,
                      onChanged: (val) async {
                        if (val && !_hasOverlayPermission) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please grant "Appear on top" permission first.'),
                              backgroundColor: PskColors.brandBlueLight,
                            ),
                          );
                          await ScreenOverlayService.requestOverlayPermission();
                          return;
                        }
                        await state.setFloatingOverlayEnabled(val);
                      },
                      activeThumbColor: PskColors.accentGold,
                      secondary: const Icon(Icons.picture_in_picture_alt, color: PskColors.accentGold),
                      title: const Text(
                        'Floating Live Match Score Card',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        state.floatingOverlayEnabled
                            ? 'Active — Drag anywhere on screen. Tap to view match.'
                            : 'Off — Turn on to float live match over other apps.',
                        style: const TextStyle(fontSize: 11, color: PskColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // --- HOME-SCREEN WIDGETS ---
              Text(
                'HOME-SCREEN WIDGETS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Glance 1.1.1 widgets. Toggle data sync, or tap "Add to Home Screen" to place the widget instantly. '
                'Live Match rotates between score and wallet every 30s (the two dots at the bottom show which) '
                'while PSK is running.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _homeScreenLockHelpCard(cardColor: cardColor),
              const SizedBox(height: 16),

              _widgetCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.stadium,
                title: 'Live Match (2x2)',
                subtitle: 'Score, minute and odds for your tracked live match.',
                value: state.liveWidgetEnabled,
                onChanged: state.setLiveWidgetEnabled,
                onPinPressed: () async {
                  debugPrint('[PSK Pulse] "Add to Home Screen" tapped: Live Match');
                  try {
                    final ok = await ScreenOverlayService.pinWidget('live');
                    debugPrint('[PSK Pulse] Live Match pinWidget() -> $ok');
                    _showPinFeedback('Live Match Widget', ok);
                  } catch (e, st) {
                    debugPrint('[PSK Pulse] Live Match onPinPressed THREW: $e\n$st');
                  }
                },
              ),
              const SizedBox(height: 10),
              _widgetCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.receipt_long,
                title: 'Bet Slip (2x2 Square)',
                subtitle: 'Your open picks, odds and potential win. Resizable to 4x2.',
                value: state.slipWidgetEnabled,
                onChanged: state.setSlipWidgetEnabled,
                onPinPressed: () async {
                  debugPrint('[PSK Pulse] "Add to Home Screen" tapped: Bet Slip');
                  try {
                    final ok = await ScreenOverlayService.pinWidget('slip');
                    debugPrint('[PSK Pulse] Bet Slip pinWidget() -> $ok');
                    _showPinFeedback('Bet Slip Widget', ok);
                  } catch (e, st) {
                    debugPrint('[PSK Pulse] Bet Slip onPinPressed THREW: $e\n$st');
                  }
                },
              ),
              const SizedBox(height: 10),
              _widgetCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.bolt,
                title: 'Favorit Plus Boost (2x2)',
                subtitle: 'The current PSK Prednost boosted price.',
                value: state.boostWidgetEnabled,
                onChanged: state.setBoostWidgetEnabled,
                onPinPressed: () async {
                  debugPrint('[PSK Pulse] "Add to Home Screen" tapped: Favorit Plus Boost');
                  try {
                    final ok = await ScreenOverlayService.pinWidget('boost');
                    debugPrint('[PSK Pulse] Boost pinWidget() -> $ok');
                    _showPinFeedback('Favorit Plus Boost Widget', ok);
                  } catch (e, st) {
                    debugPrint('[PSK Pulse] Boost onPinPressed THREW: $e\n$st');
                  }
                },
              ),

              const SizedBox(height: 28),

              // --- LOCK SCREEN WIDGET ---
              Text(
                'LOCK SCREEN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A silent, updating notification card with public visibility, shown directly on your lock screen without unlocking.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              _widgetCard(
                cardColor: cardColor,
                borderColor: borderColor,
                icon: Icons.lock_clock,
                title: 'Lock Screen Widget',
                subtitle: 'Score, minute and odds on your lock screen. Goes dark during quiet hours.',
                value: state.lockScreenWidgetEnabled,
                onChanged: state.setLockScreenWidgetEnabled,
                onPinPressed: () async {
                  await ScreenOverlayService.openNotificationSettings();
                },
                pinButtonLabel: 'Notification Settings',
              ),

              const SizedBox(height: 28),

              // --- LIVE MATCH DESIGN ---
              Text(
                'LIVE MATCH DESIGN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pick how the Live Match tile looks on your home screen. '
                '"${LiveWidgetStyle.defaultStyle.label}" is the default.',
                style: const TextStyle(color: PskColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.92,
                children: LiveWidgetStyle.values
                    .map((style) => _styleOption(context, style, state.liveWidgetStyle == style))
                    .toList(),
              ),

              const SizedBox(height: 28),

              // --- GUARDRAILS ---
              Text(
                'GUARDRAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? PskColors.textMuted : PskColors.textDarkSecondary,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: state.selfExcluded ? PskColors.alertRed : borderColor,
                  ),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      value: state.selfExcluded,
                      onChanged: state.setSelfExcluded,
                      activeThumbColor: PskColors.alertRed,
                      secondary: const Icon(Icons.shield, color: PskColors.alertRed),
                      title: const Text(
                        "I'm self-excluded / at-risk",
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Locks every PSK Pulse tile and overlay to a neutral "closed" state — no '
                        'odds, no scores, no slip. Demo toggle only.',
                        style: TextStyle(fontSize: 11, color: PskColors.textMuted),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.isQuietHoursNow() ? Icons.bedtime : Icons.wb_sunny_outlined,
                      color: PskColors.brandBlueLight,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Quiet hours: 00:00–07:00',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.isQuietHoursNow()
                                ? 'Active now — home-screen tiles keep refreshing silently, and the lock-screen card goes dark until it ends.'
                                : 'Not active — tiles and the lock-screen card refresh normally.',
                            style: const TextStyle(fontSize: 11, color: PskColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _permissionCard({
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: PskColors.brandBlueLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGranted ? PskColors.moneyGreen.withAlpha(38) : PskColors.alertRed.withAlpha(38),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGranted ? Icons.check_circle : Icons.warning_amber_rounded,
                      size: 12,
                      color: isGranted ? PskColors.moneyGreen : PskColors.alertRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isGranted ? 'Granted' : 'Needed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isGranted ? PskColors.moneyGreen : PskColors.alertRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: const TextStyle(fontSize: 11, color: PskColors.textMuted)),
          if (!isGranted) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.security, size: 13),
                label: Text(buttonText, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PskColors.accentGold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Android has no public API for a third-party app to check (or change) a
  /// launcher's "Lock Home screen layout" setting — it's private to whichever
  /// launcher is installed. Stock Pixel Launcher in particular accepts a pin
  /// request and then silently cancels it (a toast easy to miss) when layout
  /// is locked, which looks exactly like "nothing happened". This card is the
  /// honest alternative to a check we can't actually perform: tell the user
  /// what to look for, and get them one tap closer to the right settings.
  Widget _homeScreenLockHelpCard({required Color cardColor}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PskColors.warningOrange.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_outline, color: PskColors.warningOrange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add to Home Screen doing nothing?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Some launchers (Pixel Launcher, Nova, One UI) silently cancel one-tap '
            'placement when your home screen layout is locked. Long-press an empty '
            'spot on your home screen, open "Home settings", and turn off "Lock '
            'Home screen layout" (wording varies) — then try Add again.',
            style: TextStyle(fontSize: 11, color: PskColors.textMuted),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                debugPrint('[PSK Pulse] "Open Home Settings" tapped');
                final ok = await ScreenOverlayService.openHomeSettings();
                debugPrint('[PSK Pulse] openHomeSettings() -> $ok');
                if (!ok && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Couldn't open Home settings on this device.")),
                  );
                }
              },
              icon: const Icon(Icons.settings, size: 14, color: PskColors.warningOrange),
              label: const Text(
                'Open Home Settings',
                style: TextStyle(fontSize: 11, color: PskColors.warningOrange, fontWeight: FontWeight.bold),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: PskColors.warningOrange),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetCard({
    required Color cardColor,
    required Color borderColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onPinPressed,
    String pinButtonLabel = 'Add to Home Screen',
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          SwitchListTile(
            value: value,
            onChanged: onChanged,
            activeThumbColor: PskColors.accentGold,
            secondary: Icon(icon, color: PskColors.brandBlueLight),
            title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: PskColors.textMuted)),
          ),
          if (onPinPressed != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onPinPressed,
                    icon: const Icon(Icons.push_pin_outlined, size: 13, color: PskColors.accentGold),
                    label: Text(
                      pinButtonLabel,
                      style: const TextStyle(fontSize: 11, color: PskColors.accentGold, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: PskColors.accentGold, width: 1),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _styleOption(BuildContext context, LiveWidgetStyle style, bool selected) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => widget.state.setLiveWidgetStyle(style),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? PskColors.accentGold : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _preview(style),
                    ),
                  ),
                  if (selected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: PskColors.accentGold, shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 12, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              style.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? PskColors.accentGold : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              style.description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, color: PskColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _preview(LiveWidgetStyle style) {
    switch (style) {
      case LiveWidgetStyle.classic:
        return _classicPreview();
      case LiveWidgetStyle.minimal:
        return _minimalPreview();
      case LiveWidgetStyle.oddsFocus:
        return _oddsFocusPreview();
      case LiveWidgetStyle.scoreboard:
        return _scoreboardPreview();
    }
  }

  Widget _previewOddsPill(String label, String value, Color valueColor, {double labelSize = 7, double valueSize = 10}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(color: _PulseTile.pill, borderRadius: BorderRadius.circular(4)),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: labelSize, color: _PulseTile.muted)),
            Text(value, style: TextStyle(fontSize: valueSize, color: valueColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _previewLiveBadge({double fontSize = 7}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(color: _PulseTile.live, borderRadius: BorderRadius.circular(8)),
      child: Text('LIVE', style: TextStyle(fontSize: fontSize, color: _PulseTile.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _classicPreview() {
    return Container(
      color: _PulseTile.bg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [_previewLiveBadge(), const SizedBox(width: 4), Text("67'", style: TextStyle(fontSize: 8, color: _PulseTile.muted))]),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Dinamo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8.5, color: _PulseTile.white, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  '2–1',
                  style: TextStyle(fontSize: 13, color: _PulseTile.gold, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Text(
                  'Hajduk',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 8.5, color: _PulseTile.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _previewOddsPill('1', '1.35', _PulseTile.down),
              _previewOddsPill('X', '4.80', _PulseTile.up),
              _previewOddsPill('2', '9.50', _PulseTile.up),
            ],
          ),
          const Spacer(),
          Text('SuperSport HNL', style: TextStyle(fontSize: 7, color: _PulseTile.muted)),
        ],
      ),
    );
  }

  Widget _minimalPreview() {
    return Container(
      color: _PulseTile.bg,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisSize: MainAxisSize.min, children: [_previewLiveBadge(), const SizedBox(width: 4), Text("67'", style: TextStyle(fontSize: 8, color: _PulseTile.muted))]),
          const SizedBox(height: 8),
          Text('2–1', style: TextStyle(fontSize: 24, color: _PulseTile.gold, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Dinamo vs Hajduk',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 8.5, color: _PulseTile.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _oddsFocusPreview() {
    return Container(
      color: _PulseTile.bg,
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dinamo 2–1 Hajduk', style: TextStyle(fontSize: 8, color: _PulseTile.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Expanded(
            child: Row(
              children: [
                _previewOddsPill('1', '1.35', _PulseTile.down, labelSize: 8, valueSize: 13),
                _previewOddsPill('X', '4.80', _PulseTile.up, labelSize: 8, valueSize: 13),
                _previewOddsPill('2', '9.50', _PulseTile.up, labelSize: 8, valueSize: 13),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('SuperSport HNL', style: TextStyle(fontSize: 7, color: _PulseTile.muted)),
        ],
      ),
    );
  }

  Widget _scoreboardPreview() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SuperSport HNL', style: TextStyle(fontSize: 6.5, color: _PulseTile.muted)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(color: _PulseTile.gold, borderRadius: BorderRadius.circular(6)),
                child: Text("67'", style: TextStyle(fontSize: 7, color: _PulseTile.goldInk, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Dinamo Zagreb', style: TextStyle(fontSize: 8, color: _PulseTile.white, fontWeight: FontWeight.bold)),
          Text('2 : 1', style: TextStyle(fontSize: 22, color: _PulseTile.gold, fontWeight: FontWeight.bold)),
          Text('Hajduk Split', style: TextStyle(fontSize: 8, color: _PulseTile.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
