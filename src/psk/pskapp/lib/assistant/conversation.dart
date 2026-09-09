import 'assistant_models.dart';

/// Per-session state and pronoun resolution. "Take me there" only works if
/// there is a resolvable referent; with an empty focus stack we ask, never guess.
class ConversationSession {
  static const int maxFocus = 5;

  final List<FocusEntry> focusStack = [];
  PendingClarification? pendingClarification;
  PendingConfirmation? pendingConfirmation;

  void pushFocus(String entityId, String entityType, String name) {
    focusStack.removeWhere((f) => f.entityId == entityId);
    focusStack.insert(0, FocusEntry(entityId, entityType, name));
    if (focusStack.length > maxFocus) focusStack.removeRange(maxFocus, focusStack.length);
  }

  FocusEntry? resolveReference() => focusStack.isEmpty ? null : focusStack.first;

  void clearPending() {
    pendingClarification = null;
    pendingConfirmation = null;
  }

  void reset() {
    focusStack.clear();
    clearPending();
  }

  static const List<String> _referential = [
    'there', 'it', 'that', 'this one', 'that one', 'that game', 'this game',
    'take me there', 'open it', 'show me that', 'go there', 'launch that',
    'same one', 'the one', 'wahan', 'wahan le chalo', 'usko', 'wo wala', 'woh',
    'akkada', 'adi', 'daani',
  ];

  /// Word-boundary aware so "deposit" is not read as containing "it".
  static bool isReferential(String query) {
    final q = query.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
    if (q.isEmpty || q.length > 40) return false;
    final words = q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toSet();
    for (final phrase in _referential) {
      if (q == phrase) return true;
      if (phrase.contains(' ')) {
        final re = RegExp('\\b${phrase.replaceAll(RegExp(r'\s+'), r'\s+')}\\b');
        if (re.hasMatch(q)) return true;
      } else if (words.contains(phrase)) {
        return true;
      }
    }
    return false;
  }

  static const List<String> _affirm = ['yes', 'y', 'yeah', 'yep', 'ok', 'okay', 'sure', 'go', 'go ahead',
    'do it', 'confirm', 'haan', 'ha', 'theek hai', 'sari', 'avunu', 'please do'];
  static const List<String> _deny = ['no', 'n', 'nope', 'cancel', 'stop', 'wait', 'nahi', 'nahin', 'ledu',
    'not now', 'never mind', 'nevermind'];

  static String _clean(String q) => q.toLowerCase().trim().replaceAll(RegExp(r'[^a-z\s]'), '');

  static bool isAffirmation(String q) {
    final s = _clean(q);
    return _affirm.any((a) => s == a || s.startsWith('$a '));
  }

  static bool isDenial(String q) {
    final s = _clean(q);
    return _deny.any((d) => s == d || s.startsWith('$d '));
  }
}

class FocusEntry {
  final String entityId;
  final String entityType;
  final String name;
  FocusEntry(this.entityId, this.entityType, this.name);
}

class PendingClarification {
  final String query;
  final List<ClarificationOption> options;
  PendingClarification(this.query, this.options);
}

class PendingConfirmation {
  final String entityId;
  final String intent;
  PendingConfirmation(this.entityId, this.intent);
}
