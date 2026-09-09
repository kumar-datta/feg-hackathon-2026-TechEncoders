import 'dart:convert';

import 'package:http/http.dart' as http;

import '../navigation/psk_tabs.dart';
import 'assistant_models.dart';

/// Optional bridge to the website's assistant API (`POST /api/assistant/query`).
///
/// When a base URL is configured the app sends the message to the server —
/// which may be running an LLM (Groq / OpenAI / …) — and maps the web routes it
/// returns onto app routes. Anything that does not map is dropped rather than
/// guessed, so an unknown web path can never open the wrong screen.
class RemoteAssistantClient {
  final String baseUrl;
  final String sessionId;
  final http.Client _client;

  RemoteAssistantClient({required this.baseUrl, required this.sessionId, http.Client? client})
      : _client = client ?? http.Client();

  static const Map<String, String> _routeMap = {
    '/': 'tab:${PskTab.home}',
    '/oklade': 'tab:${PskTab.sports}',
    '/oklade?filter=live': 'tab:${PskTab.live}',
    '/casino': 'tab:${PskTab.casino}',
    '/live-casino': 'tab:${PskTab.liveCasino}',
    '/loto': 'tab:${PskTab.lotto}',
    '/virtualne-igre': 'tab:${PskTab.virtuals}',
    '/swipe-and-bet': 'tab:${PskTab.swipe}',
    '/arena': 'tab:${PskTab.arena}',
    '/forum': 'tab:${PskTab.forum}',
    '/promocije': 'tab:${PskTab.promos}',
    '/klub-prvaka': 'tab:${PskTab.championsClub}',
    '/checkout': 'sheet:betslip',
    '/listici': 'sheet:mybets',
    '/racun': 'screen:account',
    '/racun#deposit': 'sheet:deposit',
    '/racun#limiti': 'screen:limits',
    '/racun#samoiskljucenje': 'screen:self_exclusion',
    '/prijava': 'screen:login',
    '/registracija': 'screen:register',
    '/pomoc': 'screen:help',
    '/kontakt': 'screen:contact',
    '/pravila-igre': 'screen:rules',
    '/odgovorno-igranje': 'screen:responsible',
    '/pravila-privatnosti': 'screen:privacy',
  };

  static String? mapRoute(String? webRoute) {
    if (webRoute == null || webRoute.isEmpty) return null;
    final direct = _routeMap[webRoute];
    if (direct != null) return direct;
    final uri = Uri.tryParse(webRoute);
    if (uri == null) return null;
    if (uri.path == '/oklade' && uri.queryParameters['sport'] != null) {
      final s = uri.queryParameters['sport']!.toLowerCase();
      const sportMap = {
        'nogomet': 'football', 'kosarka': 'basketball', 'tenis': 'tennis', 'hokej': 'hockey',
        'rukomet': 'handball', 'esport': 'esport', 'odbojka': 'volleyball', 'pikado': 'darts', 'vaterpolo': 'waterPolo',
      };
      final mapped = sportMap[s];
      return mapped == null ? 'tab:${PskTab.sports}' : 'sport:$mapped';
    }
    if (uri.path == '/casino') return 'tab:${PskTab.casino}';
    return _routeMap[uri.path];
  }

  Future<AssistantReply> query(String message) async {
    final uri = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}/api/assistant/query');
    final res = await _client
        .post(uri,
            headers: {'Content-Type': 'application/json', 'Accept-Language': 'en'},
            body: jsonEncode({'message': message, 'session_id': sessionId}))
        .timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('assistant ${res.statusCode}');
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    final actions = <AssistantAction>[];
    for (final a in (data['actions'] as List<dynamic>? ?? [])) {
      final m = a as Map<String, dynamic>;
      final route = mapRoute(m['route'] as String?);
      if (route == null) continue;
      actions.add(AssistantAction(
        action: m['action'] as String? ?? 'OPEN_PAGE',
        label: m['label'] as String? ?? 'Open',
        entityId: m['entity_id'] as String? ?? '',
        entityType: m['entity_type'] as String? ?? 'PAGE',
        route: route,
        requiresAuth: m['requires_auth'] == true,
        requiresConfirmation: m['requires_confirmation'] == true,
        active: true,
      ));
    }

    final clar = (data['clarification'] as Map<String, dynamic>?)?['options'] as List<dynamic>? ?? [];
    return AssistantReply(
      intent: data['intent'] as String? ?? 'UNKNOWN',
      confidence: (data['confidence'] as num?)?.toDouble() ?? 0,
      answer: data['answer'] as String? ?? '',
      actions: actions,
      clarification: clar.map((c) => ClarificationOption.fromJson(c as Map<String, dynamic>)).toList(),
      sources: (data['sources'] as List<dynamic>? ?? [])
          .map((s) => AssistantSource.fromJson(s as Map<String, dynamic>))
          .toList(),
      requiresConfirmation: data['requires_confirmation'] == true,
      refusalReason: data['refusal_reason'] as String?,
      navigateRoute: mapRoute(data['navigate'] as String?),
      answerMode: data['answer_mode'] as String?,
    );
  }

  Future<bool> ping() async {
    try {
      final uri = Uri.parse('${baseUrl.replaceFirst(RegExp(r'/$'), '')}/api/assistant/status');
      final res = await _client.get(uri).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
