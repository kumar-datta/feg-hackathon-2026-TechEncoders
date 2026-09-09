import 'normalize.dart';

class IntentResult {
  final String intent;
  final double confidence;
  final String method;
  const IntentResult(this.intent, this.confidence, this.method);
}

class _Rule {
  final String intent;
  final double conf;
  final List<String>? any;
  final List<List<String>>? all;
  const _Rule(this.intent, this.conf, {this.any, this.all});
}

/// Rule-based intent classification. Deterministic, instant and testable —
/// the website only escalates to an LLM when these rules are unsure, and the
/// app runs entirely on the rules (or on the remote assistant if configured).
class IntentClassifier {
  /// Ordered — the first matching rule wins, so safety rules sit at the top.
  static const List<_Rule> _rules = [
    _Rule('RESPONSIBLE_GAMING', 0.97, any: [
      'self exclude', 'self exclusion', 'selfexclusion', 'take a break', 'time out',
      'deposit limit', 'set a limit', 'limit my', 'stop gambling', 'stop playing',
      'gambling problem', 'addicted', 'addiction', 'block my account',
      'cant stop', 'cannot stop', 'chasing losses', 'lost too much',
      'responsible gaming', 'responsible gambling', 'gambling help',
    ]),
    _Rule('RESPONSIBLE_GAMING', 0.95, all: [['losing'], ['keep', 'cant', 'lot', 'all']]),

    // questions beat navigation keywords
    _Rule('GAME_INFO', 0.92, any: [
      'how does', 'how do i play', 'how to play', 'how are results', 'rules of',
      'explain the', 'what is a crash', 'kaise khel', 'ela aadali', 'kaise khelte',
    ]),
    _Rule('FAQ', 0.90, all: [
      ['why', 'how', 'what', 'when', 'can', 'do', 'does', 'is', 'kyu', 'kaise', 'kitna', 'ela'],
      ['pending', 'failed', 'rejected', 'declined', 'stuck', 'long', 'minimum', 'maximum',
       'limit', 'fee', 'fees', 'need', 'required', 'take', 'happen', 'happens',
       'mean', 'means', 'eligible', 'cancel', 'change', 'reset', 'verify', 'contact'],
    ]),

    // account data: must come from the app state, never RAG
    _Rule('ACCOUNT_DATA', 0.93, any: [
      'my balance', 'account balance', 'how much do i have', 'how much money',
      'my winnings', 'did my withdrawal', 'is my kyc approved', 'my kyc status',
      'my last deposit', 'how much did i win', 'how much did i lose', 'check my balance',
    ]),

    _Rule('DEPOSIT', 0.94, any: [
      'deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge',
      'paisa dalo', 'paisa dalna', 'paise jama', 'dabbu vesali', 'fund my account',
    ]),
    _Rule('WITHDRAW', 0.94, any: [
      'withdraw', 'withdrawl', 'withdrawal', 'cash out', 'cashout', 'payout',
      'paisa nikalo', 'paisa nikalna', 'take out my money', 'dabbu teesuko',
    ]),

    _Rule('BET_HISTORY', 0.94, any: [
      'bet history', 'my bets', 'past bets', 'previous bets', 'betting history',
      'bet dikhao', 'na bets', 'my tickets',
    ]),
    _Rule('KYC', 0.94, any: [
      'kyc', 'verify my account', 'verification', 'upload document', 'identity check',
    ]),
    _Rule('ACCOUNT', 0.90, any: [
      'my profile', 'my account', 'account settings', 'change password', 'my wallet',
      'transaction history', 'notifications',
    ]),

    _Rule('SUPPORT', 0.93, any: [
      'contact support', 'customer support', 'customer care', 'live chat', 'talk to agent',
      'talk to someone', 'complaint', 'complain', 'helpline', 'support se baat',
    ]),

    _Rule('PROMOTION', 0.90, any: [
      'promotion', 'promo', 'offer', 'bonus', 'deals', 'free spin', 'wagering',
    ]),

    _Rule('GAME_INFO', 0.90, any: [
      'how does', 'how do i play', 'how to play', 'rules of', 'explain', 'what is',
      'what does', 'kaise khel', 'ela aadali', 'terminology', 'how are results',
    ]),

    _Rule('NAVIGATE', 0.88, any: [
      'open', 'take me', 'go to', 'show me', 'launch', 'start', 'play',
      'kholo', 'dikhao', 'le chalo', 'leke jao', 'cheyyi', 'chupinchu', 'teesukellu',
    ]),

    _Rule('SEARCH', 0.80, any: [
      'find', 'search', 'list', 'what games', 'do you have', 'any games',
    ]),

    _Rule('FAQ', 0.82, any: [
      'why is', 'why was', 'how long', 'how many', 'can i', 'do i need',
      'what happens', 'is there', 'minimum', 'maximum', 'pending', 'failed', 'rejected',
      'kitna time', 'kyu',
    ]),
  ];

  /// Bare tokens that map to two or more plausible destinations.
  static const Set<String> _ambiguousTokens = {
    'money', 'paisa', 'paise', 'dabbu', 'bonus', 'history', 'limits', 'limit',
    'cards', 'game', 'games', 'open', 'show', 'bet', 'bets', 'live', 'table',
    'account', 'sports', 'casino', 'play', 'next', 'kholo', 'dikhao', 'verify',
    'help me', 'go back', 'cancel it', 'how much',
  };

  static bool isAmbiguousToken(String query) {
    final q = normalize(query);
    return q.isNotEmpty && _ambiguousTokens.contains(q);
  }

  static bool _matches(_Rule rule, String text, List<String> toks) {
    if (rule.any != null && rule.any!.any(text.contains)) return true;
    if (rule.all != null) {
      return rule.all!.every((group) => group.any((w) => toks.contains(w) || text.contains(w)));
    }
    return false;
  }

  static IntentResult classify(String query) {
    if (isAmbiguousToken(query)) return const IntentResult('AMBIGUOUS', 0.3, 'ambiguous_token');
    final raw = normalize(query);
    final translated = translateCommands(query).text;
    final text = '$raw $translated';
    final toks = tokens(text);
    for (final rule in _rules) {
      if (_matches(rule, text, toks)) return IntentResult(rule.intent, rule.conf, 'rules');
    }
    return const IntentResult('UNKNOWN', 0.25, 'rules');
  }
}
