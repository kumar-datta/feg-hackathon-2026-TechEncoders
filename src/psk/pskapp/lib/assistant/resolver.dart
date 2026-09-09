import 'assistant_models.dart';
import 'normalize.dart';

/// Deterministic entity resolution — the ladder from the website's resolver.js:
///   1. exact alias match                    -> 0.98
///   2. normalised exact                     -> 0.95
///   3. command-translated exact             -> 0.93   ("aviator kholo")
///   4. alias contained in the query         -> 0.88
///   5. token overlap / keyword match        -> 0.60-0.85
///   6. trigram + edit similarity (typos)    -> 0.55-0.90
///
/// The model never chooses a route. It gets an entity_id from here, and the
/// action layer maps that id to a route from the registry.
class EntityResolver {
  static const double navigateDirect = 0.90;
  static const double navigateWithHint = 0.70;
  static const double clarify = 0.45;

  List<AssistantEntity> _entities = [];
  final Map<String, List<String>> _aliasIndex = {};

  void load(List<AssistantEntity> entities) {
    _entities = entities;
    _aliasIndex.clear();
    void add(String alias, String id) {
      final key = normalize(alias);
      if (key.isEmpty) return;
      final list = _aliasIndex.putIfAbsent(key, () => []);
      if (!list.contains(id)) list.add(id);
    }

    for (final e in entities) {
      add(e.name, e.id);
      for (final a in e.aliases) {
        add(a, e.id);
      }
    }
  }

  AssistantEntity? getEntity(String id) {
    for (final e in _entities) {
      if (e.id == id) return e;
    }
    return null;
  }

  List<AssistantEntity> get all => _entities;

  ResolvedEntity? _hit(String id, double confidence, String method) {
    final e = getEntity(id);
    if (e == null) return null;
    return ResolvedEntity(
      entityId: e.id,
      entityType: e.type,
      name: e.name,
      route: e.route,
      requiresAuth: e.requiresAuth,
      active: e.active,
      confidence: (confidence * 100).round() / 100,
      method: method,
    );
  }

  static final RegExp _navPrefix = RegExp(
    r'^(please\s+)?(can you\s+)?(take me to|take me|bring me to|go to|goto|navigate to|open up|open|show me|show|launch|start|play|i want to play|i want to|i wanna|find me|find)\s+',
    caseSensitive: false,
  );
  static final RegExp _article = RegExp(r'^(the|a|an)\s+', caseSensitive: false);
  static final RegExp _trailing = RegExp(r'\s+(page|section|game|now|please|plz)$', caseSensitive: false);

  ResolveResult resolve(String query, {String? typeHint}) {
    final q = normalize(query);
    if (q.isEmpty) return const ResolveResult(best: null, candidates: [], ambiguous: false);

    String stripNav(String t) =>
        t.replaceFirst(_navPrefix, '').replaceFirst(_article, '').replaceFirst(_trailing, '').trim();
    final qStripped = normalize(stripNav(q));

    final scores = <String, _Score>{};
    void bump(String id, double conf, String method) {
      final cur = scores[id];
      if (cur == null || conf > cur.conf) scores[id] = _Score(conf, method);
    }

    // ---- 1 & 2: exact / normalised exact ----
    String? exactKey;
    if (_aliasIndex.containsKey(q)) {
      exactKey = q;
    } else if (qStripped.isNotEmpty && _aliasIndex.containsKey(qStripped)) {
      exactKey = qStripped;
    }
    if (exactKey != null) {
      final ids = _aliasIndex[exactKey]!;
      final conf = ids.length == 1 ? 0.98 : 0.55;
      for (final id in ids) {
        bump(id, conf, ids.length == 1 ? 'exact_alias' : 'ambiguous_alias');
      }
    }

    // ---- 3: command-word translation ----
    final tr = translateCommands(query);
    final translated = tr.text;
    if (tr.translatedCount > 0 && translated.isNotEmpty && translated != q) {
      if (_aliasIndex.containsKey(translated)) {
        for (final id in _aliasIndex[translated]!) {
          bump(id, 0.93, 'translated_exact');
        }
      }
      const drop = ['open', 'show', 'go', 'there', 'want', 'play', 'me', 'my', 'take'];
      final stripped = translated.split(' ').where((t) => !drop.contains(t)).join(' ');
      if (stripped.isNotEmpty && _aliasIndex.containsKey(stripped)) {
        for (final id in _aliasIndex[stripped]!) {
          bump(id, 0.92, 'translated_stripped');
        }
      }
    }

    // ---- 4: alias appears inside the query ----
    final haystacks = [q, qStripped, translated].where((h) => h.isNotEmpty).toList();
    _aliasIndex.forEach((alias, ids) {
      if (alias.length < 4) return;
      for (final hay in haystacks) {
        if (hay == alias) continue;
        if (hay.contains(alias)) {
          final conf = (0.72 + alias.length / 60).clamp(0.0, 0.90);
          for (final id in ids) {
            bump(id, conf, 'alias_contained');
          }
        }
      }
    });

    // ---- 5: token / keyword overlap ----
    final qTokens = tokens(translated.isNotEmpty ? translated : q).toSet();
    for (final e in _entities) {
      final kw = <String>{...tokens(e.name), for (final k in e.keywords) ...tokens(k)};
      if (kw.isEmpty) continue;
      var shared = 0;
      for (final t in qTokens) {
        if (kw.contains(t)) shared++;
      }
      if (shared > 0) {
        bump(e.id, (0.5 + shared * 0.12).clamp(0.0, 0.85), 'keyword_overlap');
      }
    }

    // ---- 6: fuzzy (typos) ----
    if (q.length >= 4) {
      _aliasIndex.forEach((alias, ids) {
        if ((alias.length - q.length).abs() > 6) return;
        final tri = trigramSimilarity(q, alias);
        if (tri < 0.42) return;
        final edit = editSimilarity(q, alias);
        final sim = tri * 0.6 + edit * 0.4;
        if (sim >= 0.55) {
          for (final id in ids) {
            bump(id, sim.clamp(0.0, 0.90), 'fuzzy');
          }
        }
      });
    }

    var ranked = scores.entries
        .map((e) => _hit(e.key, e.value.conf, e.value.method))
        .whereType<ResolvedEntity>()
        .toList();

    if (typeHint != null) {
      ranked = ranked
          .map((r) => r.entityType == typeHint ? r.withConfidence((r.confidence + 0.04).clamp(0, 0.99)) : r)
          .toList();
    }

    // an inactive entity must never be navigated to
    ranked = ranked.map((r) => r.active ? r : r.withConfidence(r.confidence.clamp(0, 0.3))).toList();
    ranked.sort((a, b) => b.confidence.compareTo(a.confidence));

    final best = ranked.isEmpty ? null : ranked.first;
    final runnerUp = ranked.length > 1 ? ranked[1] : null;

    final tooClose = best != null &&
        runnerUp != null &&
        best.confidence - runnerUp.confidence < 0.06 &&
        best.confidence < navigateDirect;

    final ambiguous = best == null || best.confidence < clarify || tooClose;
    return ResolveResult(best: best, candidates: ranked.take(5).toList(), ambiguous: ambiguous);
  }
}

class _Score {
  final double conf;
  final String method;
  _Score(this.conf, this.method);
}
