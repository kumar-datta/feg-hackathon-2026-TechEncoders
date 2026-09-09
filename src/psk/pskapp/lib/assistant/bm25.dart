import 'dart:math' as math;

import 'assistant_models.dart';
import 'normalize.dart';

/// In-memory lexical index. At a few hundred chunks a plain in-process BM25 is
/// instant and needs no infrastructure.
class Bm25Index {
  static const double _k1 = 1.5;
  static const double _b = 0.75;

  final List<_Doc> _docs = [];
  final Map<String, int> _df = {};
  double _avgLen = 0;

  void add(String id, String text, KnowledgeChunk payload) {
    final t = tokens(text);
    final tf = <String, int>{};
    for (final term in t) {
      tf[term] = (tf[term] ?? 0) + 1;
    }
    _docs.add(_Doc(id, t.length, tf, payload));
    for (final term in tf.keys) {
      _df[term] = (_df[term] ?? 0) + 1;
    }
  }

  void build() {
    final total = _docs.fold<int>(0, (a, d) => a + d.len);
    _avgLen = _docs.isEmpty ? 0 : total / _docs.length;
  }

  double _idf(String term) {
    final n = _docs.length;
    final df = _df[term] ?? 0;
    return math.log(1 + (n - df + 0.5) / (df + 0.5));
  }

  List<ScoredDoc> search(String query, {int limit = 20}) {
    final qTerms = tokens(query);
    if (qTerms.isEmpty || _docs.isEmpty) return [];

    final scored = <ScoredDoc>[];
    for (final d in _docs) {
      var score = 0.0;
      for (final term in qTerms) {
        final f = d.tf[term];
        if (f == null) continue;
        final norm = 1 - _b + _b * (d.len / (_avgLen == 0 ? 1 : _avgLen));
        score += _idf(term) * ((f * (_k1 + 1)) / (f + _k1 * norm));
      }
      if (score > 0) scored.add(ScoredDoc(d.id, score, d.payload));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    final max = scored.isEmpty ? 1.0 : scored.first.score;
    return scored.take(limit).map((s) => ScoredDoc(s.id, s.score / max, s.payload)).toList();
  }
}

class _Doc {
  final String id;
  final int len;
  final Map<String, int> tf;
  final KnowledgeChunk payload;
  _Doc(this.id, this.len, this.tf, this.payload);
}

class ScoredDoc {
  final String id;
  final double score;
  final KnowledgeChunk payload;
  ScoredDoc(this.id, this.score, this.payload);
}

/// Deterministic hashed bag-of-words vector — the website's "lexical fallback"
/// used when no embedding API is configured. Weaker than a real embedding but
/// catches lexical overlap the BM25 pass may weigh differently.
class LexicalVectorStore {
  static const int _dim = 512;
  final List<_VecItem> _items = [];

  static int _hash(String s) {
    var h = 2166136261;
    for (final c in s.codeUnits) {
      h ^= c;
      h = (h * 16777619) & 0xFFFFFFFF;
    }
    return h;
  }

  static List<double> vectorFor(String text) {
    final v = List<double>.filled(_dim, 0);
    final counts = <String, int>{};
    for (final tok in contentTokens(text)) {
      counts[tok] = (counts[tok] ?? 0) + 1;
    }
    counts.forEach((tok, n) {
      final w = 1 + math.log(n);
      v[_hash(tok) % _dim] += w;
      v[_hash('$tok#2') % _dim] += w * 0.5;
    });
    var norm = 0.0;
    for (final x in v) {
      norm += x * x;
    }
    norm = math.sqrt(norm);
    if (norm == 0) norm = 1;
    return v.map((x) => x / norm).toList();
  }

  void add(String id, String text, KnowledgeChunk payload) {
    _items.add(_VecItem(id, vectorFor(text), payload));
  }

  List<ScoredDoc> search(String text, {int limit = 20}) {
    if (_items.isEmpty) return [];
    final q = vectorFor(text);
    final scored = _items.map((it) {
      var dot = 0.0;
      for (var i = 0; i < _dim; i++) {
        dot += q[i] * it.vector[i];
      }
      return ScoredDoc(it.id, dot, it.payload);
    }).toList();
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }
}

class _VecItem {
  final String id;
  final List<double> vector;
  final KnowledgeChunk payload;
  _VecItem(this.id, this.vector, this.payload);
}
