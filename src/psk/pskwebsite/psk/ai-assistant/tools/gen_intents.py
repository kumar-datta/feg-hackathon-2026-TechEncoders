"""
gen_intents.py — intent, alias, ambiguity and follow-up datasets.

Outputs:
  data/intents/intent_examples.json     (PART 6)
  data/intents/nl_alias_queries.json    (PART 7)
  data/intents/ambiguous_queries.json   (PART 8)
  data/intents/followups.json           (PART 10)

Language tags: en | hinglish | hi_latin | te_latin | mixed
Transliterations are written as users actually type them (Latin script, no diacritics).
"""
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')


def w(rel, obj):
    path = os.path.normpath(os.path.join(OUT, rel))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    print(f'  {rel:42s} {len(obj):4d} records')


# ======================================================================
# PART 6 — intent examples
# ======================================================================
intents = []


def Q(query, intent, entity, entity_id, etype, action, conf,
      confirm=False, lang='en'):
    intents.append({
        'query': query, 'intent': intent, 'entity': entity, 'entity_id': entity_id,
        'entity_type': etype, 'expected_action': action, 'confidence': conf,
        'requires_confirmation': confirm, 'language': lang,
    })


# ---------- NAVIGATE: games ----------
for q, c in [('take me to aviator', 0.98), ('open aviator', 0.98), ('aviator', 0.90),
             ('launch aviator game', 0.97), ('i want to play aviator', 0.95),
             ('go to the plane game', 0.93), ('open the plane game', 0.93),
             ('start aviator', 0.96), ('aviator game kholo', 0.96),
             ('aviator dikhao', 0.95), ('aviater open karo', 0.92),
             ('avaitor', 0.85), ('play aviator now', 0.96)]:
    lang = 'hinglish' if any(w in q for w in ('kholo', 'dikhao', 'karo')) else 'en'
    Q(q, 'NAVIGATE', 'Aviator', 'game_aviator', 'GAME', 'OPEN_GAME', c, lang=lang)

for q, c in [('open roulette', 0.97), ('take me to roulette', 0.97), ('roulette table', 0.93),
             ('play roulette', 0.95), ('roulete', 0.88), ('roulette kholo', 0.95)]:
    Q(q, 'NAVIGATE', 'Roulette', 'game_roulette', 'GAME', 'OPEN_GAME', c,
      lang='hinglish' if 'kholo' in q else 'en')

for q, c in [('open blackjack', 0.97), ('play 21', 0.88), ('blackjack table', 0.94),
             ('take me to blackjack', 0.97), ('blakjack', 0.86)]:
    Q(q, 'NAVIGATE', 'Blackjack', 'game_blackjack', 'GAME', 'OPEN_GAME', c)

for q, c in [('open poker', 0.96), ('poker table', 0.93), ('play texas holdem', 0.90)]:
    Q(q, 'NAVIGATE', 'Poker', 'game_poker', 'GAME', 'OPEN_GAME', c)

Q('open baccarat', 'NAVIGATE', 'Baccarat', 'game_baccarat', 'GAME', 'OPEN_GAME', 0.96)
Q('play dice game', 'NAVIGATE', 'Dice', 'game_dice', 'GAME', 'OPEN_GAME', 0.94)

# ---------- NAVIGATE: categories ----------
for q, c in [('show crash games', 0.95), ('crash games', 0.92), ('open crash section', 0.94),
             ('crash wale game dikhao', 0.92)]:
    Q(q, 'NAVIGATE', 'Crash Games', 'category_crash_games', 'CATEGORY', 'OPEN_CATEGORY', c,
      lang='hinglish' if 'dikhao' in q else 'en')

for q, c in [('open slots', 0.96), ('show me slots', 0.95), ('slot games', 0.93),
             ('slots dikhao', 0.94)]:
    Q(q, 'NAVIGATE', 'Slots', 'category_slots', 'CATEGORY', 'OPEN_CATEGORY', c,
      lang='hinglish' if 'dikhao' in q else 'en')

for q, c in [('open casino', 0.95), ('casino lobby', 0.94), ('take me to casino', 0.95),
             ('casino kholo', 0.94)]:
    Q(q, 'NAVIGATE', 'Casino', 'category_casino', 'CATEGORY', 'OPEN_CATEGORY', c,
      lang='hinglish' if 'kholo' in q else 'en')

for q, c in [('live casino', 0.95), ('open live dealer games', 0.94),
             ('show live tables', 0.93)]:
    Q(q, 'NAVIGATE', 'Live Casino', 'category_live_casino', 'CATEGORY', 'OPEN_CATEGORY', c)

Q('all games', 'NAVIGATE', 'Games', 'category_games', 'CATEGORY', 'OPEN_CATEGORY', 0.92)
Q('open table games', 'NAVIGATE', 'Table Games', 'category_table_games', 'CATEGORY',
  'OPEN_CATEGORY', 0.95)

# ---------- NAVIGATE: sports ----------
for q, c in [('cricket betting page', 0.96), ('open cricket', 0.95), ('show cricket matches', 0.93),
             ('cricket dikhao', 0.94), ('ipl betting', 0.88), ('crickt', 0.85)]:
    Q(q, 'NAVIGATE', 'Cricket', 'sport_cricket', 'SPORT', 'OPEN_SPORT', c,
      lang='hinglish' if 'dikhao' in q else 'en')

for q, c in [('open football', 0.96), ('soccer betting', 0.93), ('football matches', 0.93),
             ('futbol', 0.86)]:
    Q(q, 'NAVIGATE', 'Football', 'sport_football', 'SPORT', 'OPEN_SPORT', c)

Q('open tennis', 'NAVIGATE', 'Tennis', 'sport_tennis', 'SPORT', 'OPEN_SPORT', 0.96)
Q('horse racing page', 'NAVIGATE', 'Horse Racing', 'sport_horse_racing', 'SPORT',
  'OPEN_SPORT', 0.95)
Q('open sportsbook', 'NAVIGATE', 'Sports', 'category_sports', 'SPORT', 'OPEN_SPORT', 0.95)
Q('sports betting', 'NAVIGATE', 'Sports', 'category_sports', 'SPORT', 'OPEN_SPORT', 0.92)

# ---------- DEPOSIT (financial: always confirm) ----------
for q, c in [('i want to deposit', 0.96), ('add money', 0.95), ('deposit page', 0.97),
             ('top up my account', 0.94), ('how do i add funds', 0.85),
             ('paisa dalna hai', 0.93), ('deposit karna hai', 0.94),
             ('paise jama karo', 0.92), ('recharge my wallet', 0.93),
             ('dabbu vesali', 0.88)]:
    lang = 'te_latin' if 'dabbu' in q else ('hinglish' if any(
        w in q for w in ('paisa', 'karna', 'paise', 'karo')) else 'en')
    Q(q, 'DEPOSIT', 'Deposit', 'page_deposit', 'PAGE', 'OPEN_DEPOSIT', c,
      confirm=True, lang=lang)

# ---------- WITHDRAW (financial: always confirm) ----------
for q, c in [('i want to withdraw', 0.96), ('withdraw my money', 0.96),
             ('cash out', 0.90), ('withdrawal page', 0.97),
             ('paisa nikalna hai', 0.94), ('withdraw karna hai', 0.94),
             ('mera paisa nikalo', 0.93), ('dabbu teesukovali', 0.87),
             ('take out my winnings', 0.92)]:
    lang = 'te_latin' if 'dabbu' in q else ('hinglish' if any(
        w in q for w in ('paisa', 'karna', 'nikalo')) else 'en')
    Q(q, 'WITHDRAW', 'Withdraw', 'page_withdraw', 'PAGE', 'OPEN_WITHDRAW', c,
      confirm=True, lang=lang)

# ---------- BET_HISTORY ----------
for q, c in [('show my bet history', 0.97), ('my bets', 0.93), ('bet history', 0.97),
             ('mera bet history dikhao', 0.95), ('past bets', 0.92),
             ('where are my bets', 0.91), ('na bets chupinchu', 0.86),
             ('previous bets dikhao', 0.93)]:
    lang = 'te_latin' if 'chupinchu' in q else ('hinglish' if 'dikhao' in q else 'en')
    Q(q, 'BET_HISTORY', 'Bet History', 'page_bet_history', 'PAGE', 'OPEN_BET_HISTORY', c,
      lang=lang)

# ---------- ACCOUNT ----------
for q, c in [('open my profile', 0.97), ('account settings', 0.95), ('my account', 0.93),
             ('profile kholo', 0.94), ('change my password', 0.88)]:
    Q(q, 'ACCOUNT', 'Profile', 'page_profile', 'PAGE', 'OPEN_PROFILE', c,
      lang='hinglish' if 'kholo' in q else 'en')

Q('show my wallet', 'ACCOUNT', 'Wallet', 'page_wallet', 'PAGE', 'OPEN_WALLET', 0.96)
Q('transaction history', 'ACCOUNT', 'Transactions', 'page_transactions', 'PAGE',
  'OPEN_WALLET', 0.94)

# ---------- KYC ----------
for q, c in [('verify my account', 0.95), ('kyc page', 0.97), ('upload documents', 0.92),
             ('kyc status', 0.94), ('kyc karna hai', 0.93), ('how do i verify', 0.88)]:
    Q(q, 'KYC', 'KYC Verification', 'page_kyc', 'PAGE', 'OPEN_KYC', c,
      lang='hinglish' if 'karna' in q else 'en')

# ---------- PROMOTION ----------
for q, c in [('show promotions', 0.96), ('any offers', 0.90), ('bonus page', 0.94),
             ('promo dikhao', 0.93), ('current deals', 0.90), ('my bonuses', 0.93)]:
    eid = 'page_bonuses' if 'bonus' in q else 'page_promotions'
    name = 'Bonuses' if 'bonus' in q else 'Promotions'
    Q(q, 'PROMOTION', name, eid, 'PAGE', 'OPEN_PROMOTIONS', c,
      lang='hinglish' if 'dikhao' in q else 'en')

# ---------- SUPPORT ----------
for q, c in [('contact support', 0.97), ('i need help', 0.85), ('talk to an agent', 0.94),
             ('customer care', 0.94), ('support se baat karao', 0.93),
             ('i want to complain', 0.91), ('live chat', 0.93)]:
    Q(q, 'SUPPORT', 'Contact Support', 'page_contact_support', 'PAGE', 'OPEN_SUPPORT', c,
      lang='hinglish' if 'baat' in q else 'en')

# ---------- RESPONSIBLE_GAMING (always answer, never gate) ----------
for q, c in [('set a deposit limit', 0.96), ('i want to self exclude', 0.97),
             ('take a break from gambling', 0.95), ('block my account', 0.92),
             ('i think i have a gambling problem', 0.97),
             ('how do i stop gambling', 0.95), ('responsible gaming', 0.97),
             ('i cant stop playing', 0.94), ('limit my spending', 0.94)]:
    Q(q, 'RESPONSIBLE_GAMING', 'Responsible Gaming', 'page_responsible_gaming', 'PAGE',
      'OPEN_RESPONSIBLE_GAMING', c)

# ---------- GAME_INFO (informational, do not navigate) ----------
for q, c in [('how does aviator work', 0.96), ('aviator rules', 0.95),
             ('explain the plane game', 0.90), ('what is a crash game', 0.93),
             ('how to play blackjack', 0.95), ('roulette rules', 0.95),
             ('what is rtp', 0.94), ('how do slots work', 0.93),
             ('baccarat rules explain karo', 0.90), ('what does volatility mean', 0.92),
             ('poker hand rankings', 0.92), ('aviator kaise khelte hain', 0.92)]:
    eid = ('game_aviator' if 'aviator' in q or 'plane' in q else
           'game_blackjack' if 'blackjack' in q else
           'game_roulette' if 'roulette' in q else
           'game_baccarat' if 'baccarat' in q else
           'game_poker' if 'poker' in q else
           'category_slots' if 'slot' in q else
           'category_crash_games' if 'crash' in q else None)
    Q(q, 'GAME_INFO', None, eid, 'GAME', 'ANSWER_FROM_RAG', c,
      lang='hinglish' if any(w in q for w in ('karo', 'kaise')) else 'en')

# ---------- FAQ ----------
for q, c in [('how long do withdrawals take', 0.95), ('why is my deposit pending', 0.94),
             ('what documents do i need for kyc', 0.95), ('how do i reset my password', 0.95),
             ('what is wagering requirement', 0.94), ('why was my bet rejected', 0.93),
             ('minimum deposit amount', 0.92), ('can i cancel a bet', 0.93),
             ('why is my account restricted', 0.92), ('what payment methods are there', 0.93),
             ('is there a mobile app', 0.90), ('how do i claim a bonus', 0.93),
             ('withdrawal kitna time lagta hai', 0.91), ('kyc kyu chahiye', 0.90)]:
    Q(q, 'FAQ', None, None, None, 'ANSWER_FROM_RAG', c,
      lang='hinglish' if any(w in q for w in ('kitna', 'kyu', 'lagta', 'chahiye')) else 'en')

# ---------- SEARCH ----------
for q, c in [('show me all crash games', 0.90), ('find games with jackpots', 0.85),
             ('search for card games', 0.88), ('what games do you have', 0.82),
             ('list live dealer tables', 0.87)]:
    Q(q, 'SEARCH', None, None, None, 'SHOW_SEARCH_RESULTS', c)

# ---------- UNKNOWN / out of scope ----------
for q in ['what is the weather today', 'tell me a joke', 'who won the world cup in 1998',
          'what is your name', 'can you write me a poem', 'asdfghjkl']:
    Q(q, 'UNKNOWN', None, None, None, 'FALLBACK_TO_SUPPORT', 0.2)


# ======================================================================
# PART 7 — natural language / alias / multilingual mapping
# ======================================================================
nl = []


def NL(query, entity_id, canonical, lang, note=''):
    nl.append({
        'query': query, 'canonical_entity_id': entity_id, 'canonical_name': canonical,
        'language': lang, 'note': note,
    })


AV = ('game_aviator', 'Aviator')
for q, lang, note in [
    ('open aviator', 'en', ''), ('aviator kholo', 'hinglish', 'kholo = open'),
    ('aviator dikhao', 'hinglish', 'dikhao = show'),
    ('aviator ki leke jao', 'hinglish', 'take me to'),
    ('plane wala game open karo', 'hinglish', 'the plane one'),
    ('mujhe aviator khelna hai', 'hi_latin', 'I want to play'),
    ('aviator game chahiye', 'hi_latin', 'I want'),
    ('vimanam game open cheyyi', 'te_latin', 'vimanam = plane'),
    ('aviator ni open cheyyandi', 'te_latin', 'polite open'),
    ('aviator kavali', 'te_latin', 'kavali = I want'),
    ('where aviator', 'en', 'incomplete grammar'),
    ('aviater', 'en', 'misspelling'), ('avaitor game', 'en', 'misspelling'),
    ('avitor', 'en', 'misspelling'), ('the plane one', 'en', 'colloquial'),
    ('udne wala game', 'hinglish', 'the flying one'),
    ('aviator plz', 'en', 'abbreviation'), ('aviatr open', 'en', 'typo'),
]:
    NL(q, AV[0], AV[1], lang, note)

for q, lang, note in [
    ('crash games dikhao', 'hinglish', ''), ('crash wale game', 'hinglish', ''),
    ('show crash games', 'en', ''), ('crash section kholo', 'hinglish', ''),
    ('crash games kavali', 'te_latin', ''),
]:
    NL(q, 'category_crash_games', 'Crash Games', lang, note)

for q, lang, note in [
    ('cricket betting page', 'en', ''), ('cricket dikhao', 'hinglish', ''),
    ('cricket satta', 'hinglish', 'satta = betting, informal'),
    ('cricket matches chahiye', 'hi_latin', ''),
    ('cricket ki page open cheyyi', 'te_latin', ''),
    ('crickt', 'en', 'misspelling'), ('ipl betting kholo', 'hinglish', ''),
]:
    NL(q, 'sport_cricket', 'Cricket', lang, note)

for q, lang, note in [
    ('mera bet history dikhao', 'hinglish', ''), ('bet history', 'en', ''),
    ('meri bets dikhao', 'hi_latin', ''), ('na bets chupinchu', 'te_latin', 'show my bets'),
    ('my bets kaha hai', 'hinglish', 'where are'),
    ('past bets', 'en', 'incomplete'),
]:
    NL(q, 'page_bet_history', 'Bet History', lang, note)

for q, lang, note in [
    ('paisa dalna hai', 'hinglish', 'want to put money in'),
    ('deposit karo', 'hinglish', ''), ('add money', 'en', ''),
    ('paise jama karne hai', 'hi_latin', ''),
    ('dabbu vesali', 'te_latin', 'want to deposit'),
    ('top up', 'en', 'abbreviation'), ('recharge karna hai', 'hinglish', ''),
]:
    NL(q, 'page_deposit', 'Deposit', lang, note)

for q, lang, note in [
    ('paisa nikalna hai', 'hinglish', 'want to take money out'),
    ('withdraw karo', 'hinglish', ''), ('cash out', 'en', ''),
    ('mera paisa nikalo', 'hi_latin', ''),
    ('dabbu teesukovali', 'te_latin', 'want to withdraw'),
    ('withdrawl', 'en', 'misspelling'),
]:
    NL(q, 'page_withdraw', 'Withdraw', lang, note)

for q, lang, note in [
    ('kyc karna hai', 'hinglish', ''), ('verify my account', 'en', ''),
    ('kyc kaise kare', 'hi_latin', 'how to do KYC'),
    ('document upload cheyyali', 'te_latin', ''),
    ('kyc', 'en', 'single token'),
]:
    NL(q, 'page_kyc', 'KYC Verification', lang, note)

for q, lang, note in [
    ('help chahiye', 'hi_latin', ''), ('support se baat karao', 'hinglish', ''),
    ('customer care number', 'en', ''), ('madad karo', 'hi_latin', 'help me'),
    ('sahayam kavali', 'te_latin', 'need help'), ('agent se baat', 'hinglish', ''),
]:
    NL(q, 'page_contact_support', 'Contact Support', lang, note)

for q, lang, note in [
    ('roulette kholo', 'hinglish', ''), ('roulete', 'en', 'misspelling'),
    ('chakka game', 'hinglish', 'wheel game, colloquial'),
    ('roulette kavali', 'te_latin', ''),
]:
    NL(q, 'game_roulette', 'Roulette', lang, note)

for q, lang, note in [
    ('offers dikhao', 'hinglish', ''), ('koi bonus hai kya', 'hi_latin', 'is there any bonus'),
    ('promotions', 'en', ''), ('offers unnaya', 'te_latin', 'are there offers'),
]:
    NL(q, 'page_promotions', 'Promotions', lang, note)

for q, lang, note in [
    ('gambling band karo', 'hinglish', 'stop my gambling'),
    ('mujhe rokna hai', 'hi_latin', 'I want to stop'),
    ('self exclusion', 'en', ''), ('limit set karo', 'hinglish', ''),
    ('aapali', 'te_latin', 'stop'),
]:
    NL(q, 'page_responsible_gaming', 'Responsible Gaming', lang, note)


# ======================================================================
# PART 8 — ambiguous queries
# ======================================================================
amb = []


def A(query, candidates, question, reason):
    amb.append({
        'query': query,
        'possible_entities': candidates,
        'clarification_question': question,
        'requires_confirmation': True,
        'reason': reason,
    })


A('open the game', ['game_aviator', 'game_roulette', 'game_blackjack', 'category_games'],
  'Which game would you like to open?', 'No game named; too many candidates.')
A('take me there', [], 'Where would you like to go? I have lost track of what "there" refers to.',
  'Pronoun with no resolvable referent in conversation state.')
A('open that one', [], 'Which one did you mean?', 'Demonstrative with empty focus stack.')
A('show cricket', ['sport_cricket'],
  'Do you want cricket betting markets, or live cricket scores?',
  'Entity is clear but the user goal is not.')
A('show casino', ['category_casino', 'category_live_casino'],
  'Do you want the main casino lobby or live dealer tables?', 'Two plausible destinations.')
A('play the crash game', ['game_aviator', 'game_crash_classic', 'category_crash_games'],
  'We have a few crash games — did you mean Aviator, Crash Classic, or the full list?',
  'Several games match the description.')
A('open it', [], 'Open what, exactly?', 'Pronoun with no referent.')
A('cards', ['game_blackjack', 'game_poker', 'game_baccarat', 'category_table_games'],
  'Which card game — blackjack, poker or baccarat?', 'Category term matching several games.')
A('money', ['page_deposit', 'page_withdraw', 'page_wallet'],
  'Do you want to deposit, withdraw, or view your wallet?',
  'Financial term with opposite possible meanings — never guess.')
A('bonus', ['page_promotions', 'page_bonuses'],
  'Do you want current promotions, or the bonuses on your account?', 'Two related pages.')
A('history', ['page_bet_history', 'page_transactions'],
  'Bet history or transaction history?', 'Ambiguous between two account pages.')
A('limits', ['page_responsible_gaming', 'page_deposit'],
  'Do you mean responsible gaming limits, or deposit limits on payment methods?',
  'Term spans a safety tool and a payment constraint.')
A('verify', ['page_kyc', 'page_profile'],
  'Do you want to start identity verification, or check your verification status?',
  'Action vs status.')
A('sports', ['category_sports', 'sport_cricket', 'sport_football'],
  'Which sport, or would you like the full sportsbook?', 'Parent vs children.')
A('open live', ['category_live_casino', 'category_sports'],
  'Live casino tables, or live in-play sports betting?', '"Live" spans two products.')
A('table', ['category_table_games', 'game_roulette', 'game_blackjack'],
  'Which table game did you have in mind?', 'Generic term.')
A('the wheel game', ['game_roulette', 'game_aviator'],
  'Do you mean Roulette, or something else?', 'Descriptive phrase matching more than one.')
A('start playing', ['category_games', 'category_casino'],
  'What would you like to play?', 'Intent clear, target absent.')
A('help', ['page_help', 'page_contact_support', 'page_responsible_gaming'],
  'Do you want help articles, to contact support, or responsible gaming support?',
  'Overloaded word — one branch is a safety route, so never guess.')
A('my account', ['page_profile', 'page_wallet', 'page_bet_history'],
  'Which part of your account — profile, wallet, or bet history?', 'Parent term.')
A('show me the offers', ['page_promotions', 'page_bonuses'],
  'Promotions available, or bonuses already on your account?', 'Two pages.')
A('open games', ['category_games', 'category_casino'],
  'The full game catalogue, or the casino lobby?', 'Overlapping destinations.')
A('withdraw problem', ['page_withdraw', 'page_contact_support', 'page_kyc'],
  'Are you trying to make a withdrawal, or do you need help with one that is stuck?',
  'Could be navigation or a support issue.')
A('that game with the plane', ['game_aviator'],
  'Do you mean Aviator?', 'Single strong candidate but phrased indirectly — confirm.')
A('the one i played yesterday', [],
  'I do not have access to your play history. Which game was it?',
  'Requires per-user data the assistant must not access.')
A('same as last time', [], 'Could you tell me which game or page you mean?',
  'Reference to prior session state.')
A('open bet', ['page_bet_history', 'category_sports'],
  'Do you want to place a bet, or view your existing bets?', 'Opposite intents.')
A('deposit withdraw', ['page_deposit', 'page_withdraw'],
  'Which one — deposit or withdraw?', 'Both financial terms present.')
A('game', ['category_games'], 'Which game are you looking for?', 'Single generic token.')
A('open', [], 'What would you like me to open?', 'Verb with no object.')
A('show', [], 'What would you like to see?', 'Verb with no object.')
A('next', [], 'What would you like to do next?', 'No context.')
A('go back', [], 'Where would you like to go?', 'Navigation verb, no target.')
A('cricket football', ['sport_cricket', 'sport_football'],
  'Which one — cricket or football?', 'Two entities named.')
A('slots or crash', ['category_slots', 'category_crash_games'],
  'Which would you prefer — slots or crash games?', 'Explicit either/or.')
A('best game', ['category_games'],
  'I cannot recommend a game as better than another. Would you like to browse the catalogue?',
  'Implies a recommendation the assistant must not make.')
A('which game pays most', [],
  'I cannot say — outcomes are random and no game can be described as paying more. '
  'Would you like the game catalogue or the responsible gaming page?',
  'Requests an unsupported financial claim; refuse and redirect.')
A('open my page', ['page_profile', 'page_wallet'],
  'Which page — your profile or your wallet?', 'Possessive but vague.')
A('i want to play something', ['category_games', 'category_casino'],
  'Any particular type — slots, table games, or crash games?', 'No target.')
A('show live games', ['category_live_casino', 'category_sports'],
  'Live casino tables, or live sports?', 'Ambiguous "live".')
A('kholo', ['—'], 'What would you like me to open?', 'Hinglish verb with no object.')
A('dikhao', ['—'], 'What would you like me to show you?', 'Hinglish verb with no object.')
A('wo wala', [], 'Which one do you mean?', 'Hindi demonstrative with no referent.')
A('adi open cheyyi', [], 'Which one would you like me to open?',
  'Telugu demonstrative with no referent.')
A('paisa', ['page_deposit', 'page_withdraw', 'page_wallet'],
  'Do you want to deposit, withdraw, or check your wallet?', 'Hinglish for money — ambiguous.')
A('bet', ['category_sports', 'page_bet_history'],
  'Do you want to place a bet or see your bet history?', 'Noun/verb ambiguity.')
A('is it working', [], 'Is what not working? Tell me which game or page and I can help.',
  'Technical complaint with no subject.')
A('this is not loading', [], 'Which page or game is not loading?',
  'Complaint with no subject.')
A('cancel it', [], 'What would you like to cancel?',
  'Destructive action with no referent — must never guess.')
A('how much', [], 'How much of what? I cannot see account balances, but I can point you to your wallet.',
  'Incomplete, and may be asking for account data the assistant cannot access.')
A('when will i get it', ['page_withdraw', 'page_transactions'],
  'Are you asking about a withdrawal, a deposit, or a bonus?',
  'Timing question with no subject; answer would otherwise invent a policy.')
A('play now', ['category_games'], 'What would you like to play?', 'No target.')


# ======================================================================
# PART 10 — follow-up / multi-turn
# ======================================================================
fu = []


def FU(turns, expected, note=''):
    fu.append({'turns': turns, 'expected_resolution': expected, 'note': note})


def U(t):
    return {'role': 'user', 'content': t}


def Aa(t, focus=None):
    d = {'role': 'assistant', 'content': t}
    if focus:
        d['focus_entity_id'] = focus
    return d


FU([U('How does Aviator work?'),
    Aa('Explains the crash mechanic, grounded in game_knowledge.', 'game_aviator'),
    U('Take me there.')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_aviator', 'action': 'OPEN_GAME',
    'confidence': 0.94, 'resolved_from': 'focus_stack[0]'},
   'Classic pronoun resolution against the focus stack.')

FU([U('What is a crash game?'),
    Aa('Explains crash mechanics generally.', 'category_crash_games'),
    U('show me them')],
   {'intent': 'NAVIGATE', 'entity_id': 'category_crash_games', 'action': 'OPEN_CATEGORY',
    'confidence': 0.90, 'resolved_from': 'focus_stack[0]'})

FU([U('Tell me about roulette'),
    Aa('Explains roulette rules.', 'game_roulette'),
    U('open it')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_roulette', 'action': 'OPEN_GAME',
    'confidence': 0.93, 'resolved_from': 'focus_stack[0]'})

FU([U('how do i play blackjack'),
    Aa('Explains blackjack.', 'game_blackjack'),
    U('play that one')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_blackjack', 'action': 'OPEN_GAME',
    'confidence': 0.92, 'resolved_from': 'focus_stack[0]'})

FU([U('what documents do i need for kyc'),
    Aa('Lists document categories, flags policy source.', 'page_kyc'),
    U('take me to that page')],
   {'intent': 'NAVIGATE', 'entity_id': 'page_kyc', 'action': 'OPEN_KYC',
    'confidence': 0.94, 'resolved_from': 'focus_stack[0]'})

FU([U('how long do withdrawals take'),
    Aa('Explains it depends on the published policy; does not invent a number.', 'page_withdraw'),
    U('ok take me there')],
   {'intent': 'WITHDRAW', 'entity_id': 'page_withdraw', 'action': 'OPEN_WITHDRAW',
    'confidence': 0.93, 'requires_confirmation': True, 'resolved_from': 'focus_stack[0]'},
   'Financial destination — confirm even though the referent is clear.')

FU([U('show me slots'),
    Aa('Opens the slots category.', 'category_slots'),
    U('actually show crash instead')],
   {'intent': 'NAVIGATE', 'entity_id': 'category_crash_games', 'action': 'OPEN_CATEGORY',
    'confidence': 0.93, 'resolved_from': 'new_entity_overrides_focus'},
   'Topic change: the new entity replaces the focus, it does not merge with it.')

FU([U('open cricket'),
    Aa('Opens cricket.', 'sport_cricket'),
    U('and football?')],
   {'intent': 'NAVIGATE', 'entity_id': 'sport_football', 'action': 'OPEN_SPORT',
    'confidence': 0.91, 'resolved_from': 'elliptical_new_entity'},
   'Elliptical follow-up carrying the previous verb.')

FU([U('what is wagering requirement'),
    Aa('Explains wagering, flags terms as policy-dependent.', 'page_bonuses'),
    U('where do i see mine')],
   {'intent': 'PROMOTION', 'entity_id': 'page_bonuses', 'action': 'OPEN_PROMOTIONS',
    'confidence': 0.90, 'resolved_from': 'focus_stack[0]'})

FU([U('aviator kaise khelte hain'),
    Aa('Explains Aviator in the user language register.', 'game_aviator'),
    U('wahan le chalo')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_aviator', 'action': 'OPEN_GAME',
    'confidence': 0.92, 'resolved_from': 'focus_stack[0]'},
   'Hinglish follow-up: "wahan le chalo" = take me there.')

FU([U('vimanam game ela aadali'),
    Aa('Explains Aviator.', 'game_aviator'),
    U('akkada ki teesukellu')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_aviator', 'action': 'OPEN_GAME',
    'confidence': 0.90, 'resolved_from': 'focus_stack[0]'},
   'Telugu follow-up: "take me there".')

FU([U('hi'),
    Aa('Greets and offers options.', None),
    U('take me there')],
   {'intent': 'AMBIGUOUS', 'entity_id': None, 'action': 'ASK_CLARIFICATION',
    'clarification_question': 'Where would you like to go?'},
   'Empty focus stack — must ask, never guess.')

FU([U('how does aviator work'),
    Aa('Explains Aviator.', 'game_aviator'),
    U('what about roulette'),
    Aa('Explains roulette.', 'game_roulette'),
    U('open it')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_roulette', 'action': 'OPEN_GAME',
    'confidence': 0.92, 'resolved_from': 'focus_stack[0]'},
   'Most recent entity wins, not the first mentioned.')

FU([U('i want to deposit'),
    Aa('Confirms before navigating to a financial page.', 'page_deposit'),
    U('yes')],
   {'intent': 'DEPOSIT', 'entity_id': 'page_deposit', 'action': 'OPEN_DEPOSIT',
    'confidence': 0.97, 'resolved_from': 'confirmation_accepted'})

FU([U('i want to deposit'),
    Aa('Confirms before navigating.', 'page_deposit'),
    U('no wait')],
   {'intent': 'AMBIGUOUS', 'entity_id': None, 'action': 'ASK_CLARIFICATION',
    'clarification_question': 'No problem — what would you like to do instead?'},
   'Confirmation declined: cancel the pending action, do not proceed.')

FU([U('show me the plane game'),
    Aa('Asks: did you mean Aviator?', 'game_aviator'),
    U('yes that one')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_aviator', 'action': 'OPEN_GAME',
    'confidence': 0.96, 'resolved_from': 'clarification_accepted'})

FU([U('open the game'),
    Aa('Asks which game.', None),
    U('aviator')],
   {'intent': 'NAVIGATE', 'entity_id': 'game_aviator', 'action': 'OPEN_GAME',
    'confidence': 0.97, 'resolved_from': 'clarification_answered'})

FU([U('my withdrawal is stuck'),
    Aa('Explains common causes; does not state a processing time.', 'page_withdraw'),
    U('can you check it for me')],
   {'intent': 'SUPPORT', 'entity_id': 'page_contact_support', 'action': 'OPEN_SUPPORT',
    'confidence': 0.93, 'resolved_from': 'requires_account_data'},
   'Assistant cannot read account state — hand off rather than speculate.')

FU([U('how much is in my wallet'),
    Aa('States it cannot access balances and offers the wallet page.', 'page_wallet'),
    U('ok open it')],
   {'intent': 'ACCOUNT', 'entity_id': 'page_wallet', 'action': 'OPEN_WALLET',
    'confidence': 0.94, 'resolved_from': 'focus_stack[0]'})

FU([U('i keep losing money'),
    Aa('Responds with responsible gaming support, does not suggest more play.',
       'page_responsible_gaming'),
    U('show me that')],
   {'intent': 'RESPONSIBLE_GAMING', 'entity_id': 'page_responsible_gaming',
    'action': 'OPEN_RESPONSIBLE_GAMING', 'confidence': 0.96},
   'Distress signal outranks every other intent, including navigation.')

FU([U('what games do you have'),
    Aa('Lists categories.', 'category_games'),
    U('the second one')],
   {'intent': 'AMBIGUOUS', 'entity_id': None, 'action': 'ASK_CLARIFICATION',
    'clarification_question': 'Which one did you mean? You can tell me the name.'},
   'Ordinal reference into a list the model may misindex — safer to ask.')

FU([U('open aviator'),
    Aa('Opens Aviator.', 'game_aviator'),
    U('how do i cash out here')],
   {'intent': 'GAME_INFO', 'entity_id': 'game_aviator', 'action': 'ANSWER_FROM_RAG',
    'confidence': 0.93, 'resolved_from': 'focus_stack[0]'},
   '"here" resolves to the currently open entity.')

FU([U('show promotions'),
    Aa('Opens promotions.', 'page_promotions'),
    U('am i eligible for any')],
   {'intent': 'PROMOTION', 'entity_id': 'page_bonuses', 'action': 'ANSWER_FROM_RAG',
    'confidence': 0.88, 'note': 'Answer generically; per-account eligibility needs an API call.'})

FU([U('cricket'),
    Aa('Asks whether markets or scores.', 'sport_cricket'),
    U('markets')],
   {'intent': 'NAVIGATE', 'entity_id': 'sport_cricket', 'action': 'OPEN_SPORT',
    'confidence': 0.95, 'resolved_from': 'clarification_answered'})

FU([U('set a deposit limit'),
    Aa('Explains limits and opens responsible gaming.', 'page_responsible_gaming'),
    U('actually i want to deposit more')],
   {'intent': 'DEPOSIT', 'entity_id': 'page_deposit', 'action': 'OPEN_DEPOSIT',
    'confidence': 0.90, 'requires_confirmation': True,
    'note': 'Honour the request, but do not encourage it; keep the limit tool visible.'},
   'User reverses a protective action — comply without nudging either way.')

FU([U('is there a mobile app'),
    Aa('Explains availability is region-dependent; warns against unofficial downloads.',
       'page_help'),
    U('open help')],
   {'intent': 'NAVIGATE', 'entity_id': 'page_help', 'action': 'OPEN_HELP',
    'confidence': 0.95, 'resolved_from': 'explicit_entity'})

FU([U('open blackjack'),
    Aa('Opens Blackjack.', 'game_blackjack'),
    U('what are the rules again')],
   {'intent': 'GAME_INFO', 'entity_id': 'game_blackjack', 'action': 'ANSWER_FROM_RAG',
    'confidence': 0.94, 'resolved_from': 'focus_stack[0]'},
   'Informational follow-up on the currently open entity — answer, do not re-navigate.')

FU([U('take me to slots'),
    Aa('Opens slots.', 'category_slots'),
    U('which one should i pick')],
   {'intent': 'AMBIGUOUS', 'entity_id': None, 'action': 'ASK_CLARIFICATION',
    'clarification_question': 'I cannot recommend one game over another. Would you like '
                              'to browse by theme or feature instead?'},
   'Solicits a recommendation — decline, then offer a neutral way to browse.')

# extend follow-ups with systematic pronoun variants
for pronoun, conf in [('open it', 0.93), ('show me that', 0.92), ('go there', 0.92),
                      ('take me to it', 0.93), ('launch that', 0.91), ('that game', 0.91),
                      ('this one', 0.90), ('open that game', 0.92)]:
    for gid, gname in [('game_aviator', 'Aviator'), ('game_roulette', 'Roulette'),
                       ('game_blackjack', 'Blackjack')]:
        FU([U(f'tell me about {gname.lower()}'),
            Aa(f'Explains {gname}.', gid),
            U(pronoun)],
           {'intent': 'NAVIGATE', 'entity_id': gid, 'action': 'OPEN_GAME',
            'confidence': conf, 'resolved_from': 'focus_stack[0]'})


def main():
    print('intents layer:')
    w('intents/intent_examples.json', intents)
    w('intents/nl_alias_queries.json', nl)
    w('intents/ambiguous_queries.json', amb)
    w('intents/followups.json', fu)

    from collections import Counter
    print('\n  intent distribution:')
    for k, v in Counter(i['intent'] for i in intents).most_common():
        print(f'    {k:22s} {v:3d}')
    print('\n  language distribution (intents):')
    for k, v in Counter(i['language'] for i in intents).most_common():
        print(f'    {k:22s} {v:3d}')
    print('\n  language distribution (alias set):')
    for k, v in Counter(n['language'] for n in nl).most_common():
        print(f'    {k:22s} {v:3d}')


if __name__ == '__main__':
    main()
