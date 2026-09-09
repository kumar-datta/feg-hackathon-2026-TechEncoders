/// Query normalisation and fuzzy string matching — a port of the website's
/// `server/src/assistant/normalize.js`. Deterministic and dependency-free.
library;

/// Latin transliterations of common Hindi/Telugu command words.
const Map<String, String> commandWords = {
  // Hindi / Hinglish
  'kholo': 'open', 'kholna': 'open', 'khol': 'open',
  'dikhao': 'show', 'dikha': 'show', 'dikhaao': 'show',
  'karo': '', 'karna': '', 'kare': '', 'kar': '',
  'chahiye': 'want', 'chaiye': 'want',
  'jao': 'go', 'chalo': 'go', 'le': '', 'leke': '', 'wahan': 'there',
  'mujhe': 'me', 'mera': 'my', 'meri': 'my', 'mere': 'my',
  'hai': '', 'hain': '', 'kya': '', 'ka': '', 'ki': '', 'ke': '', 'ko': '', 'se': '',
  'wala': '', 'wale': '', 'wali': '',
  'kaise': 'how', 'kyu': 'why', 'kyun': 'why', 'kitna': 'how much', 'kaha': 'where',
  'paisa': 'money', 'paise': 'money', 'rupaye': 'money',
  'nikalo': 'withdraw', 'nikalna': 'withdraw', 'jama': 'deposit', 'dalo': 'deposit',
  'dalna': 'deposit', 'band': 'stop', 'rokna': 'stop', 'madad': 'help',
  'khelna': 'play', 'khelte': 'play', 'khel': 'play', 'satta': 'betting',
  // Telugu
  'cheyyi': '', 'cheyyandi': '', 'cheyyali': '', 'chupinchu': 'show', 'chudu': 'show',
  'kavali': 'want', 'teesukellu': 'take me', 'teesuko': 'take', 'teesukovali': 'withdraw',
  'vesali': 'deposit', 'vesaru': 'deposit', 'dabbu': 'money', 'aatalu': 'games',
  'vimanam': 'plane', 'sahayam': 'help', 'ela': 'how', 'aadali': 'play',
  'akkada': 'there', 'adi': 'that', 'ni': '', 'na': 'my', 'unnaya': 'are there',
};

const Map<String, String> _diacritics = {
  'č': 'c', 'ć': 'c', 'đ': 'd', 'š': 's', 'ž': 'z',
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a', 'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i', 'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u', 'ñ': 'n', 'ß': 'ss',
};

/// Strip diacritics and lowercase.
String fold(String? s) {
  final buf = StringBuffer();
  for (final rune in (s ?? '').toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buf.write(_diacritics[ch] ?? ch);
  }
  return buf.toString();
}

final RegExp _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
final RegExp _ws = RegExp(r'\s+');

/// Full normalisation: fold, strip punctuation, collapse whitespace.
String normalize(String? s) => fold(s).replaceAll(_nonWord, ' ').replaceAll(_ws, ' ').trim();

/// Tokenise into words.
List<String> tokens(String? s) => normalize(s).split(' ').where((t) => t.isNotEmpty).toList();

/// Function words that carry no topical signal. BM25's idf already discounts
/// them; the hashed-vector fallback does not, so it drops them explicitly.
const Set<String> stopwords = {
  'a', 'an', 'the', 'and', 'or', 'of', 'to', 'in', 'on', 'at', 'for', 'is', 'are', 'was', 'be',
  'do', 'does', 'did', 'how', 'what', 'why', 'when', 'where', 'which', 'who', 'can', 'could',
  'i', 'me', 'my', 'you', 'your', 'it', 'its', 'this', 'that', 'work', 'works', 'working',
  'please', 'plz', 'tell', 'about', 'with', 'from', 'there', 'here', 'get', 'have', 'has',
};

/// Tokens with stopwords removed; falls back to all tokens when nothing is left.
List<String> contentTokens(String? s) {
  final all = tokens(s);
  final kept = all.where((t) => !stopwords.contains(t)).toList();
  return kept.isEmpty ? all : kept;
}

class Translation {
  final String text;
  final int translatedCount;
  const Translation(this.text, this.translatedCount);
}

/// Translate command words to English so "aviator kholo" becomes "aviator open".
Translation translateCommands(String? s) {
  final out = <String>[];
  var translated = 0;
  for (final t in tokens(s)) {
    if (commandWords.containsKey(t)) {
      translated++;
      final rep = commandWords[t]!;
      if (rep.isNotEmpty) out.add(rep);
    } else {
      out.add(t);
    }
  }
  return Translation(out.join(' ').trim(), translated);
}

/// Rough language hint from the command words present.
String detectLanguage(String? s) {
  final t = tokens(s);
  const hi = ['kholo', 'dikhao', 'karo', 'chahiye', 'mujhe', 'mera', 'meri', 'paisa',
    'nikalna', 'jama', 'kaise', 'kyu', 'kitna', 'hai', 'wala', 'khelna', 'madad'];
  const te = ['cheyyi', 'chupinchu', 'kavali', 'teesukellu', 'dabbu', 'vimanam',
    'sahayam', 'ela', 'aadali', 'akkada', 'vesali', 'teesukovali'];
  final hiHits = t.where(hi.contains).length;
  final teHits = t.where(te.contains).length;
  final enHits = t.length - hiHits - teHits;
  if (teHits > 0) return enHits > 0 ? 'mixed_te' : 'te_latin';
  if (hiHits > 0) return enHits > 0 ? 'hinglish' : 'hi_latin';
  return 'en';
}

/// Character trigrams, used for fuzzy alias matching.
Set<String> trigrams(String s) {
  final p = '  ${normalize(s)} ';
  final out = <String>{};
  for (var i = 0; i < p.length - 2; i++) {
    out.add(p.substring(i, i + 3));
  }
  return out;
}

/// Dice coefficient over trigram sets — 0..1, tolerant of typos.
double trigramSimilarity(String a, String b) {
  final ta = trigrams(a);
  final tb = trigrams(b);
  if (ta.isEmpty || tb.isEmpty) return 0;
  var shared = 0;
  for (final g in ta) {
    if (tb.contains(g)) shared++;
  }
  return (2 * shared) / (ta.length + tb.length);
}

/// Levenshtein distance.
int levenshtein(String a, String b) {
  a = normalize(a);
  b = normalize(b);
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (i) => i);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0);
    cur[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      cur[j] = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost].reduce((x, y) => x < y ? x : y);
    }
    prev = cur;
  }
  return prev[b.length];
}

/// Normalised edit similarity, 0..1.
double editSimilarity(String a, String b) {
  final max = normalize(a).length > normalize(b).length ? normalize(a).length : normalize(b).length;
  if (max == 0) return 0;
  return 1 - levenshtein(a, b) / max;
}
