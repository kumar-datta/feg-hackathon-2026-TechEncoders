/// Hard safety refusals — checked in code before any retrieval, exactly as on
/// the website (`generate.js`). They are not a suggestion to a model.
class Refusal {
  final String id;
  final RegExp test;
  final String message;
  const Refusal(this.id, this.test, this.message);
}

class RefusalChecker {
  static final List<Refusal> _refusals = [
    Refusal(
      'PRIVATE_DATA_OTHER_USER',
      RegExp(r"\b(user|account|player)\s+\w+[\d_]|someone else'?s? (account|bet|balance)|another (user|player)", caseSensitive: false),
      "I can't access anyone else's account information. If you need help with your own account, support can verify you and assist.",
    ),
    Refusal(
      'CREDENTIAL',
      RegExp(r'\b(tell|give|show)\s+me\s+my\s+password|what.{0,10}my password\b', caseSensitive: false),
      'Passwords are never retrievable — not by me and not by support. You can set a new one from the login screen using "forgot password".',
    ),
    Refusal(
      'SELF_EXCLUSION_CIRCUMVENTION',
      RegExp(r'(get around|bypass|remove|lift|cancel|undo|reverse).{0,24}(self.?exclusion|self.?exclude)|unblock.{0,20}(so i can|to)\s*(play|bet|gamble)', caseSensitive: false),
      "I can't help with that. A self-exclusion is designed not to be lifted early — that is the point of it. If you're finding this period difficult, free and confidential support is available and I can point you to it.",
    ),
    Refusal(
      'UNDERAGE',
      RegExp(r"\bi(?:'m| am)\s*(?:1[0-7]|under\s*18|a minor)\b|\bmy (son|daughter|child|kid)\b.{0,40}(play|bet|account)", caseSensitive: false),
      "I can't help with that. Gambling is strictly for adults who meet the legal age in their jurisdiction, and accounts are personal to the account holder.",
    ),
    Refusal(
      'GUARANTEED_WIN',
      RegExp(
        r'\b(guarantee|guaranteed|sure.?shot|always win|never lose|100% win|foolproof|fool proof)\b|\b(system|trick|hack|strategy|method|formula|cheat|algorithm)\b[^.?!]{0,30}\b(to |for |that )?\b(beat|win|winning|crack|predict)\b|\bbeat\b[^.?!]{0,20}\b(the )?(system|game|casino|roulette|slots?|blackjack|aviator|crash)\b',
        caseSensitive: false,
      ),
      "There's no strategy or system that can guarantee a win. Game outcomes are produced by a random number generator and each round is independent, so nothing can predict or influence a result. Treat any paid \"system\" claiming otherwise as false.",
    ),
    Refusal(
      'LOSS_CHASING',
      RegExp(r'\b(recover|win back|get back|make back|recoup).{0,30}(loss|losses|money|lost)|what should i play.{0,20}(recover|win back)|\bchase my losses\b', caseSensitive: false),
      "I'm not able to suggest what to play to recover losses. Trying to win losses back is one of the clearest warning signs of gambling harm, and because outcomes are independent, past losses make nothing more likely now. Free confidential support is available, and you can set limits or take a break at any time.",
    ),
    Refusal(
      'HARMFUL_STAKE_ADVICE',
      RegExp(r'\b(rent|loan|borrow|debt|savings|salary|credit card)\b.{0,40}\b(bet|stake|gamble|deposit|play)\b|\bbet (my|the) (rent|savings|last)\b', caseSensitive: false),
      "I can't advise on that, and I'd gently say that staking money you need for living costs or borrowing to gamble is a serious risk sign. Only ever stake what you can afford to lose. Free confidential support is available if this feels hard to control.",
    ),
    Refusal(
      'ENCOURAGE_SPEND',
      RegExp(r'\b(convince|persuade|encourage|talk) me (to|into) (deposit|bet|play|gamble)|should i (deposit|bet) more\b', caseSensitive: false),
      "That's not something I'll do. Deciding whether and how much to spend is entirely yours, and I won't try to influence it. If you want, I can help you set a deposit limit instead.",
    ),
    Refusal(
      'PROMPT_INJECTION',
      RegExp(r'ignore (your|all|previous) (instruction|rule|prompt)|developer mode|you are now|pretend (the|that).{0,30}(withdrawal|time|policy)|disregard (your|the) (rules|instructions)', caseSensitive: false),
      "I can't change how I work based on instructions in a message. I can still help you find a game, a page, or an answer from the help content.",
    ),
    Refusal(
      'ODDS_PREDICTION',
      RegExp(r'\b(odds of winning|chance of winning|probability of winning|will i win|am i going to win|is .{0,20}due (for|to))\b', caseSensitive: false),
      "I can't give you odds or predict an outcome. Results are randomly generated and every round is independent, so nothing is ever \"due\" and no past pattern predicts the next result. Each game publishes its own information in its info panel.",
    ),
    Refusal(
      'BEST_PAYING',
      RegExp(r'\b(which|what) (game|slot|machine).{0,24}(best|most|highest|biggest).{0,16}(pay|payout|win|return)|best (paying|payout) (game|slot)', caseSensitive: false),
      "I can't rank games by payout or point to one as better than another — that would imply an outcome nobody can predict. I can show you the catalogue so you can browse by type or theme.",
    ),
  ];

  static Refusal? check(String query) {
    for (final r in _refusals) {
      if (r.test.hasMatch(query)) return r;
    }
    return null;
  }
}
