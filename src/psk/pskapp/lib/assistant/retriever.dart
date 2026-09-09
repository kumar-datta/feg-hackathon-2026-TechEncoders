import 'assistant_models.dart';
import 'bm25.dart';
import 'normalize.dart';

/// Hybrid retrieval over the knowledge corpus: BM25 + hashed-vector cosine,
/// fused with Reciprocal Rank Fusion because the two score scales differ.
class Retriever {
  static const int topK = 5;
  static const int candidatePool = 20;
  static const double vectorWeight = 0.6;
  static const double bm25Weight = 0.4;
  static const int rrfK = 60;
  static const double retrievalFloor = 0.12;

  final Bm25Index _bm25 = Bm25Index();
  final LexicalVectorStore _vectors = LexicalVectorStore();
  int _chunkCount = 0;

  int get chunkCount => _chunkCount;

  void build(List<KnowledgeChunk> chunks) {
    _chunkCount = chunks.length;
    for (final c in chunks) {
      _bm25.add(c.chunkId, '${c.title} ${c.content} ${c.keywords.join(' ')}', c);
      _vectors.add(c.chunkId, '${c.title}\n${c.content}', c);
    }
    _bm25.build();
  }

  static final RegExp _explainer = RegExp(r'\b(how (does|do|to)|what is|explain|rules|kaise|ela)\b', caseSensitive: false);
  static final RegExp _explainerId = RegExp(r'__(overview|howto|rules)$');
  static final RegExp _overviewId = RegExp(r'__overview$');
  static final RegExp _qaId = RegExp(r'__q\d+$');

  List<RetrievalHit> retrieve(String query, {String? category, String? gameId}) {
    final translated = translateCommands(query).text;
    final searchText = translated.length > 2 ? '$query $translated' : query;

    final vecHits = _vectors.search(searchText, limit: candidatePool);
    final lexHits = _bm25.search(searchText, limit: candidatePool);

    final scores = <String, RetrievalHit>{};
    void fuse(List<ScoredDoc> list, double weight, String method) {
      for (var rank = 0; rank < list.length; rank++) {
        final item = list[rank];
        final inc = weight / (rrfK + rank + 1);
        final cur = scores[item.id];
        if (cur != null) {
          cur.score += inc;
          cur.methods.add(method);
        } else {
          scores[item.id] = RetrievalHit(item.payload, inc, [method]);
        }
      }
    }

    fuse(vecHits, vectorWeight, 'vector');
    fuse(lexHits, bm25Weight, 'bm25');

    var fused = scores.values.toList();

    // soft filters — applied after fusion so a confident lexical hit survives
    if (category != null) {
      for (final f in fused) {
        if (f.chunk.category == category) f.score *= 1.6;
      }
    }
    if (gameId != null) {
      for (final f in fused) {
        if (f.chunk.gameId == gameId) f.score *= 2.0;
      }
    }

    // an explanatory question about a game wants that game's overview/how-to
    // chunk, not an incidental Q&A that happens to share vocabulary. Scoped to
    // the named game so an unrelated overview cannot ride the boost.
    if (gameId != null && _explainer.hasMatch(query)) {
      final hasExplainer = fused.any((f) => f.chunk.gameId == gameId && _explainerId.hasMatch(f.chunk.chunkId));
      for (final f in fused) {
        if (f.chunk.gameId != gameId) continue;
        if (_overviewId.hasMatch(f.chunk.chunkId)) {
          f.score *= 3.0; // "how does X work" wants the overview first
        } else if (_explainerId.hasMatch(f.chunk.chunkId)) {
          f.score *= 2.5;
        } else if (_qaId.hasMatch(f.chunk.chunkId)) {
          f.score *= hasExplainer ? 0.25 : 0.7;
        }
      }
    }

    // priority is a tiebreaker, never a filter
    for (final f in fused) {
      f.score *= switch (f.chunk.priority) { 'high' => 1.12, 'low' => 0.94, _ => 1.0 };
    }

    fused.sort((a, b) => b.score.compareTo(a.score));
    final max = fused.isEmpty ? 1.0 : fused.first.score;
    for (final f in fused) {
      f.score = f.score / max;
    }
    return fused.where((f) => f.score >= retrievalFloor).take(topK).toList();
  }

  static const List<MapEntry<String, List<String>>> _categoryHints = [
    MapEntry('DEPOSIT', ['deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge', 'jama', 'vesali']),
    MapEntry('WITHDRAWAL', ['withdraw', 'withdrawal', 'withdrawl', 'payout', 'cash out', 'cashout', 'nikal', 'teesuko']),
    MapEntry('KYC', ['kyc', 'verif', 'document', 'identity', 'passport']),
    MapEntry('BETTING', ['bet', 'stake', 'odds', 'accumulator', 'settled', 'wager']),
    MapEntry('PROMOTIONS', ['bonus', 'promo', 'offer', 'wagering', 'free spin']),
    MapEntry('ACCOUNT', ['password', 'login', 'log in', 'profile', 'username', 'restricted']),
    MapEntry('RESPONSIBLE_GAMING', ['self exclu', 'take a break', 'addict', 'problem gambl', 'deposit limit']),
    MapEntry('TECHNICAL', ['loading', 'error', 'not working', 'froze', 'app keeps']),
    MapEntry('SUPPORT', ['support', 'complaint', 'contact', 'agent']),
    MapEntry('GAMES', ['slot', 'rtp', 'volatility', 'demo mode']),
  ];

  /// Knowledge-base games named in a question. The website gets this for free
  /// from its entity registry (Aviator is a real game there); the app's
  /// catalogue has no crash game, so the corpus game is inferred from the text.
  static const List<MapEntry<String, List<String>>> _gameHints = [
    MapEntry('game_crash', ['aviator', 'crash', 'plane', 'vimanam', 'multiplier', 'cash out before']),
    MapEntry('game_roulette', ['roulette', 'rulet', 'wheel', 'red or black']),
    MapEntry('game_blackjack', ['blackjack', 'black jack', '21', 'poker', 'hit or stand']),
    MapEntry('game_baccarat', ['baccarat', 'banker', 'punto banco']),
    MapEntry('game_dice', ['dice', 'sic bo', 'craps']),
    MapEntry('category_slots', ['slot', 'slots', 'reels', 'paylines', 'free spins', 'scatter', 'volatility']),
  ];

  static String? inferGame(String query) {
    final q = ' ${query.toLowerCase()} ';
    String? best;
    var bestLen = 0;
    for (final entry in _gameHints) {
      for (final h in entry.value) {
        if (q.contains(h) && h.length > bestLen) {
          best = entry.key;
          bestLen = h.length;
        }
      }
    }
    return best;
  }

  /// Deposit and withdrawal FAQs are lexically near-identical, so route by
  /// category: the longest matching hint wins.
  static String? inferCategory(String query) {
    final q = query.toLowerCase();
    String? best;
    var bestLen = 0;
    for (final entry in _categoryHints) {
      for (final h in entry.value) {
        if (q.contains(h) && h.length > bestLen) {
          best = entry.key;
          bestLen = h.length;
        }
      }
    }
    return best;
  }
}
