import 'package:shared_preferences/shared_preferences.dart';
import '../models/widget_style.dart';

/// Persists which of the PSK Pulse widget designs the user picked, so the
/// choice survives app restarts (the widget itself reads the same value
/// straight from Android's SharedPreferences — see WidgetBridgeService).
class WidgetStyleService {
  WidgetStyleService._();

  static const _keyLiveStyle = 'psk_live_widget_style_choice';

  static Future<LiveWidgetStyle> loadLiveStyle() async {
    final prefs = await SharedPreferences.getInstance();
    return LiveWidgetStyle.fromKey(prefs.getString(_keyLiveStyle));
  }

  static Future<void> saveLiveStyle(LiveWidgetStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLiveStyle, style.key);
  }
}
