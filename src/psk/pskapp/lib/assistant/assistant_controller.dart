import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/app_state.dart';
import 'assistant_models.dart';
import 'assistant_service.dart';
import 'remote_assistant_client.dart';

/// Chat state for the floating assistant: transcript, busy flag, unread badge,
/// and which engine answers (on-device pipeline or the website API).
class AssistantController extends ChangeNotifier {
  static const _keyHistory = 'psk_assistant_history';
  static const _keySession = 'psk_assistant_session';
  static const _keyRemoteUrl = 'psk_assistant_remote_url';

  final AppState appState;
  final AssistantService service = AssistantService();

  final List<ChatMessage> _messages = [];
  bool _busy = false;
  bool _open = false;
  int _unread = 0;
  String _sessionId = '';
  String _remoteUrl = '';
  bool _remoteHealthy = false;

  /// Consumed by the UI once per reply: the route the assistant decided is safe
  /// to open automatically.
  String? _pendingNavigate;

  AssistantController(this.appState) {
    _restore();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get busy => _busy;
  bool get isOpen => _open;
  int get unread => _unread;
  String get remoteUrl => _remoteUrl;
  bool get usesRemote => _remoteUrl.isNotEmpty && _remoteHealthy;
  String get modeLabel => usesRemote ? 'Connected · website assistant' : 'On-device RAG · Online';
  bool get ready => service.isReady;

  String? takePendingNavigate() {
    final r = _pendingNavigate;
    _pendingNavigate = null;
    return r;
  }

  Future<void> _restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sessionId = prefs.getString(_keySession) ?? '';
      if (_sessionId.isEmpty) {
        _sessionId = 'app_${Random().nextInt(1 << 30).toRadixString(36)}${DateTime.now().millisecondsSinceEpoch.toRadixString(36)}';
        await prefs.setString(_keySession, _sessionId);
      }
      _remoteUrl = prefs.getString(_keyRemoteUrl) ?? '';
      final raw = prefs.getString(_keyHistory);
      if (raw != null && raw.isNotEmpty) {
        final list = jsonDecode(raw) as List<dynamic>;
        _messages.addAll(list.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>)));
      }
    } catch (_) {}
    await service.initialize(appState.casinoGames);
    if (_remoteUrl.isNotEmpty) _checkRemote();
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recent = _messages.length > 20 ? _messages.sublist(_messages.length - 20) : _messages;
      await prefs.setString(_keyHistory, jsonEncode(recent.map((m) => m.toJson()).toList()));
    } catch (_) {}
  }

  Future<void> setRemoteUrl(String url) async {
    _remoteUrl = url.trim();
    _remoteHealthy = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyRemoteUrl, _remoteUrl);
    } catch (_) {}
    notifyListeners();
    if (_remoteUrl.isNotEmpty) await _checkRemote();
  }

  Future<void> _checkRemote() async {
    _remoteHealthy = await RemoteAssistantClient(baseUrl: _remoteUrl, sessionId: _sessionId).ping();
    notifyListeners();
  }

  void setOpen(bool open) {
    _open = open;
    if (open) _unread = 0;
    notifyListeners();
  }

  void clearHistory() {
    _messages.clear();
    service.session.reset();
    _persist();
    notifyListeners();
  }

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || _busy) return;

    _messages.add(ChatMessage(role: 'user', content: message, at: DateTime.now()));
    _busy = true;
    notifyListeners();

    try {
      AssistantReply reply;
      if (usesRemote) {
        try {
          reply = await RemoteAssistantClient(baseUrl: _remoteUrl, sessionId: _sessionId).query(message);
        } catch (_) {
          _remoteHealthy = false;
          reply = await service.handle(message, authenticated: appState.isLoggedIn);
        }
      } else {
        // a short pause so the typing indicator reads as a real turn
        await Future<void>.delayed(const Duration(milliseconds: 350));
        reply = await service.handle(message, authenticated: appState.isLoggedIn);
      }

      _messages.add(ChatMessage(
        role: 'assistant',
        content: reply.answer,
        at: DateTime.now(),
        actions: reply.actions,
        clarification: reply.clarification,
        sources: reply.sources,
        intent: reply.intent,
        refusal: reply.refusalReason,
      ));
      if (reply.navigateRoute != null) _pendingNavigate = reply.navigateRoute;
      if (!_open) _unread++;
    } catch (_) {
      _messages.add(ChatMessage(
        role: 'assistant',
        content: 'I cannot reach the assistant right now. Try again in a moment.',
        at: DateTime.now(),
        error: true,
      ));
    } finally {
      _busy = false;
      _persist();
      notifyListeners();
    }
  }
}
