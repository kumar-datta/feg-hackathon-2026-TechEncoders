"""
gen_navigation.py — builds the deterministic navigation layer.

Outputs:
  data/navigation/entities.json    (PART 1)
  data/navigation/pages.json       (PART 2)
  data/navigation/categories.json
  data/navigation/aliases.json     (PART 7 lookup table)
  data/intents/actions.json        (PART 9)

MOCK DATA. Routes are examples — replace with your real routing table.
"""
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')


def w(rel, obj):
    path = os.path.normpath(os.path.join(OUT, rel))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    n = len(obj) if isinstance(obj, list) else len(obj.get('records', obj))
    print(f'  {rel:44s} {n:4d} records')


def E(id, type, name, aliases, description, category, parent_id, route, keywords,
      status='active', requires_auth=False, requires_kyc=False):
    return {
        'id': id, 'type': type, 'name': name, 'aliases': aliases,
        'description': description, 'category': category, 'parent_id': parent_id,
        'route': route, 'keywords': keywords, 'status': status,
        'requires_auth': requires_auth, 'requires_kyc': requires_kyc,
        'data_status': 'EXAMPLE_DATA',
    }


# ======================================================================
# PART 1 — navigation entities
# ======================================================================
ENTITIES = [
    # ---------- top level ----------
    E('page_home', 'PAGE', 'Home',
      ['home', 'homepage', 'main page', 'start', 'front page', 'ghar', 'home page dikhao',
       'mukhya prishth', 'start page'],
      'Landing page with featured games, sports highlights and promotions.',
      'Navigation', None, '/', ['home', 'landing', 'main', 'start']),

    E('category_games', 'CATEGORY', 'Games',
      ['games', 'all games', 'game section', 'games page', 'khel', 'games dikhao',
       'game list', 'aatalu', 'saare games'],
      'Full catalogue of games across all categories.',
      'Games', 'page_home', '/games', ['games', 'catalogue', 'play', 'lobby']),

    E('category_casino', 'CATEGORY', 'Casino',
      ['casino', 'casino games', 'casino section', 'casino lobby', 'casino kholo',
       'casino dikhao', 'casino page'],
      'Casino lobby containing slots, table games and instant games.',
      'Casino', 'category_games', '/casino', ['casino', 'slots', 'table games', 'lobby']),

    E('category_live_casino', 'CATEGORY', 'Live Casino',
      ['live casino', 'live games', 'live dealer', 'live tables', 'live casino kholo',
       'real dealer', 'live wala casino'],
      'Casino tables hosted by live dealers and streamed in real time.',
      'Casino', 'category_casino', '/casino/live', ['live', 'dealer', 'streaming', 'tables']),

    E('category_sports', 'SPORT', 'Sports',
      ['sports', 'sportsbook', 'sports betting', 'betting', 'match betting',
       'sports dikhao', 'khel satta', 'sports page'],
      'Sportsbook with pre-match and in-play markets across multiple sports.',
      'Sports', 'page_home', '/sports', ['sports', 'betting', 'odds', 'matches']),

    # ---------- sports ----------
    E('sport_cricket', 'SPORT', 'Cricket',
      ['cricket', 'cricket betting', 'cricket matches', 'cricket page', 'crickt',
       'cricket dikhao', 'cricket satta', 'ipl', 'test match', 'odi', 't20'],
      'Cricket markets covering international and domestic fixtures.',
      'Sports', 'category_sports', '/sports/cricket', ['cricket', 'ipl', 't20', 'odi', 'test']),

    E('sport_football', 'SPORT', 'Football',
      ['football', 'soccer', 'football betting', 'footy', 'futbol', 'football dikhao',
       'football matches', 'soccer page'],
      'Football markets covering major leagues and cup competitions.',
      'Sports', 'category_sports', '/sports/football', ['football', 'soccer', 'league', 'goals']),

    E('sport_tennis', 'SPORT', 'Tennis',
      ['tennis', 'tennis betting', 'tenis', 'tennis matches', 'tennis dikhao'],
      'Tennis markets covering tour-level and challenger events.',
      'Sports', 'category_sports', '/sports/tennis', ['tennis', 'atp', 'wta', 'sets']),

    E('sport_horse_racing', 'SPORT', 'Horse Racing',
      ['horse racing', 'horses', 'racing', 'horse race', 'ghoda race', 'horse betting',
       'race card'],
      'Horse racing markets and race cards.',
      'Sports', 'category_sports', '/sports/horse-racing', ['horse', 'racing', 'race', 'track']),

    # ---------- game categories ----------
    E('category_crash_games', 'CATEGORY', 'Crash Games',
      ['crash games', 'crash', 'crash section', 'multiplier games', 'crash wale game',
       'crash game dikhao'],
      'Instant games where a rising multiplier ends at a random point.',
      'Games', 'category_games', '/games/crash', ['crash', 'multiplier', 'instant', 'cashout']),

    E('category_slots', 'CATEGORY', 'Slots',
      ['slots', 'slot games', 'slot machines', 'reels', 'slots dikhao', 'slot wala game',
       'slot section'],
      'Reel-based games with paylines and bonus features.',
      'Casino', 'category_casino', '/casino/slots', ['slots', 'reels', 'paylines', 'spin']),

    E('category_table_games', 'CATEGORY', 'Table Games',
      ['table games', 'tables', 'card games', 'table section'],
      'Card and table games including roulette, blackjack and baccarat.',
      'Casino', 'category_casino', '/casino/table-games', ['table', 'cards', 'dealer']),

    # ---------- individual games ----------
    E('game_aviator', 'GAME', 'Aviator',
      ['aviator', 'aviator game', 'plane game', 'plane wala game', 'aeroplane game',
       'aviater', 'aviyator', 'avaitor', 'avitor', 'crash plane', 'aviator crash game',
       'vimanam game', 'plane', 'udne wala game'],
      'A crash-style game where a multiplier rises until it stops at a random point. '
      'Players choose when to cash out before it ends.',
      'Crash Games', 'category_crash_games', '/games/aviator',
      ['crash', 'plane', 'multiplier', 'cashout', 'aviator']),

    E('game_crash_classic', 'GAME', 'Crash Classic',
      ['crash classic', 'classic crash', 'crash game', 'rocket game', 'crash original'],
      'A crash game where a multiplier climbs until a randomly determined stop point.',
      'Crash Games', 'category_crash_games', '/games/crash-classic',
      ['crash', 'multiplier', 'rocket', 'cashout']),

    E('game_roulette', 'GAME', 'Roulette',
      ['roulette', 'roulete', 'roullete', 'rulet', 'wheel game', 'roulette table',
       'roulette kholo', 'chakka game'],
      'A wheel game where players bet on where a ball comes to rest.',
      'Table Games', 'category_table_games', '/games/roulette',
      ['roulette', 'wheel', 'red', 'black', 'numbers']),

    E('game_blackjack', 'GAME', 'Blackjack',
      ['blackjack', 'black jack', 'blakjack', '21', 'twenty one', 'bj', 'cards 21'],
      'A card game where players aim for a hand total close to 21 without exceeding it.',
      'Table Games', 'category_table_games', '/games/blackjack',
      ['blackjack', 'cards', '21', 'dealer', 'hit', 'stand']),

    E('game_poker', 'GAME', 'Poker',
      ['poker', 'pokar', 'poker table', 'poker game', 'texas holdem', 'holdem'],
      'A card game where players form hands and bet across betting rounds.',
      'Table Games', 'category_table_games', '/games/poker',
      ['poker', 'cards', 'holdem', 'hand']),

    E('game_baccarat', 'GAME', 'Baccarat',
      ['baccarat', 'bacarat', 'bakara', 'punto banco'],
      'A card game where players bet on the player hand, banker hand, or a tie.',
      'Table Games', 'category_table_games', '/games/baccarat',
      ['baccarat', 'banker', 'player', 'tie']),

    E('game_dice', 'GAME', 'Dice',
      ['dice', 'dice game', 'pasa', 'pasha', 'dice roll'],
      'An instant game where the outcome is determined by a dice roll.',
      'Instant Games', 'category_games', '/games/dice',
      ['dice', 'roll', 'instant', 'over', 'under']),

    # ---------- promotions ----------
    E('page_promotions', 'PAGE', 'Promotions',
      ['promotions', 'promos', 'offers', 'deals', 'promotion page', 'offer dikhao',
       'promo', 'promotions kholo', 'offers page'],
      'Current promotional offers and campaigns.',
      'Promotions', 'page_home', '/promotions', ['promotions', 'offers', 'deals', 'campaign']),

    E('page_bonuses', 'PAGE', 'Bonuses',
      ['bonus', 'bonuses', 'my bonus', 'bonus page', 'bonus dikhao', 'bonus status',
       'bonus balance'],
      'Bonuses available to and active on the account, with their terms.',
      'Promotions', 'page_promotions', '/promotions/bonuses',
      ['bonus', 'wagering', 'terms', 'eligibility'], requires_auth=True),

    # ---------- wallet & money ----------
    E('page_wallet', 'ACCOUNT', 'Wallet',
      ['wallet', 'my wallet', 'balance', 'my balance', 'funds', 'wallet kholo',
       'paisa', 'balance dikhao', 'wallet page'],
      'Wallet overview showing balances and payment options.',
      'Account', 'page_home', '/wallet', ['wallet', 'balance', 'funds', 'money'],
      requires_auth=True),

    E('page_deposit', 'ACCOUNT', 'Deposit',
      ['deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge', 'paisa dalo',
       'deposit karo', 'money add karo', 'add cash', 'deposit page', 'paise jama karo',
       'dabbu vesaru', 'deposit kholo'],
      'Page for adding funds to the account balance.',
      'Account', 'page_wallet', '/wallet/deposit',
      ['deposit', 'add', 'topup', 'payment', 'fund'], requires_auth=True),

    E('page_withdraw', 'ACCOUNT', 'Withdraw',
      ['withdraw', 'withdrawal', 'cash out', 'cashout', 'take out money', 'paisa nikalo',
       'withdraw karo', 'money nikalna hai', 'payout', 'withdraw page', 'dabbu teesuko'],
      'Page for requesting a withdrawal of funds from the account.',
      'Account', 'page_wallet', '/wallet/withdraw',
      ['withdraw', 'payout', 'cashout', 'bank'], requires_auth=True, requires_kyc=True),

    E('page_transactions', 'ACCOUNT', 'Transactions',
      ['transactions', 'transaction history', 'payment history', 'statement',
       'transaction dikhao', 'my transactions', 'payment log'],
      'Record of deposits, withdrawals and other account transactions.',
      'Account', 'page_wallet', '/wallet/transactions',
      ['transactions', 'history', 'statement', 'payments'], requires_auth=True),

    E('page_bet_history', 'ACCOUNT', 'Bet History',
      ['bet history', 'my bets', 'betting history', 'past bets', 'bet dikhao',
       'mera bet history dikhao', 'my bet history', 'bets', 'previous bets',
       'bet list', 'na bets chupinchu'],
      'Record of placed bets with their status and settlement.',
      'Account', 'page_home', '/account/bet-history',
      ['bets', 'history', 'settled', 'pending'], requires_auth=True),

    # ---------- account ----------
    E('page_profile', 'ACCOUNT', 'Profile',
      ['profile', 'my profile', 'my account', 'account', 'account settings', 'settings',
       'profile kholo', 'account dikhao', 'my details'],
      'Account profile and personal settings.',
      'Account', 'page_home', '/account/profile',
      ['profile', 'account', 'settings', 'details'], requires_auth=True),

    E('page_kyc', 'ACCOUNT', 'KYC Verification',
      ['kyc', 'verification', 'verify account', 'identity verification', 'documents',
       'kyc karo', 'kyc status', 'verify me', 'document upload', 'kyc page'],
      'Identity verification page for submitting and tracking verification documents.',
      'Account', 'page_profile', '/account/kyc',
      ['kyc', 'verification', 'identity', 'documents'], requires_auth=True),

    E('page_notifications', 'ACCOUNT', 'Notifications',
      ['notifications', 'alerts', 'messages', 'inbox', 'notification dikhao'],
      'Account notifications and messages.',
      'Account', 'page_profile', '/account/notifications',
      ['notifications', 'alerts', 'messages'], requires_auth=True),

    # ---------- support & policy ----------
    E('page_help', 'SUPPORT', 'Help Center',
      ['help', 'help center', 'faq', 'faqs', 'support articles', 'help dikhao',
       'madad', 'help page', 'sahayam'],
      'Help articles and frequently asked questions.',
      'Support', 'page_home', '/help', ['help', 'faq', 'support', 'articles']),

    E('page_contact_support', 'SUPPORT', 'Contact Support',
      ['contact', 'contact support', 'support', 'customer support', 'customer care',
       'live chat', 'agent', 'talk to someone', 'support se baat karao', 'complaint',
       'helpline'],
      'Channels for contacting the customer support team.',
      'Support', 'page_help', '/help/contact',
      ['contact', 'support', 'chat', 'agent', 'complaint']),

    E('page_responsible_gaming', 'POLICY', 'Responsible Gaming',
      ['responsible gaming', 'responsible gambling', 'safer gambling', 'limits',
       'deposit limit', 'self exclusion', 'self-exclusion', 'take a break',
       'gambling help', 'addiction help', 'stop gambling', 'block my account'],
      'Responsible gaming tools including limits, time-outs, self-exclusion and support resources.',
      'Policy', 'page_home', '/responsible-gaming',
      ['responsible', 'limits', 'self-exclusion', 'safer', 'help']),

    E('page_terms', 'POLICY', 'Terms & Conditions',
      ['terms', 'terms and conditions', 't&c', 'tnc', 'terms of service', 'rules',
       'user agreement'],
      'Terms and conditions governing use of the service.',
      'Policy', 'page_home', '/legal/terms', ['terms', 'conditions', 'legal', 'agreement']),

    E('page_privacy', 'POLICY', 'Privacy Policy',
      ['privacy', 'privacy policy', 'data policy', 'data protection', 'gdpr'],
      'How personal data is collected, used and protected.',
      'Policy', 'page_home', '/legal/privacy', ['privacy', 'data', 'personal', 'protection']),
]


# ======================================================================
# PART 2 — pages
# ======================================================================
def P(page_id, page_name, page_type, route, parent_page, description,
      keywords, aliases, actions, requires_auth=False, requires_kyc=False):
    return {
        'page_id': page_id, 'page_name': page_name, 'page_type': page_type,
        'route': route, 'parent_page': parent_page, 'description': description,
        'keywords': keywords, 'aliases': aliases, 'available_actions': actions,
        'requires_auth': requires_auth, 'requires_kyc': requires_kyc,
        'data_status': 'EXAMPLE_DATA',
    }


PAGES = [
    P('page_home', 'Home', 'LANDING', '/', None,
      'Landing page with featured content, promotions and entry points to all products.',
      ['home', 'landing', 'featured'], ['home', 'homepage', 'main page'],
      ['OPEN_CATEGORY', 'OPEN_SPORT', 'OPEN_PROMOTIONS', 'OPEN_HELP']),

    P('page_games', 'Games', 'LISTING', '/games', 'page_home',
      'Browsable catalogue of all games with category filters and search.',
      ['games', 'catalogue', 'browse'], ['games', 'all games', 'game list'],
      ['OPEN_GAME', 'OPEN_CATEGORY']),

    P('page_game_detail', 'Game Details', 'DETAIL', '/games/{game_slug}', 'page_games',
      'Detail view for a single game, with description, rules summary and launch action.',
      ['game', 'details', 'rules', 'play'], ['game page', 'game details'],
      ['OPEN_GAME', 'OPEN_HELP', 'OPEN_RESPONSIBLE_GAMING']),

    P('page_casino', 'Casino', 'LISTING', '/casino', 'page_games',
      'Casino lobby with slots, table games and live dealer sections.',
      ['casino', 'slots', 'tables'], ['casino', 'casino lobby'],
      ['OPEN_GAME', 'OPEN_CATEGORY']),

    P('page_live_casino', 'Live Casino', 'LISTING', '/casino/live', 'page_casino',
      'Live dealer tables streamed in real time.',
      ['live', 'dealer', 'tables'], ['live casino', 'live games'],
      ['OPEN_GAME', 'OPEN_CATEGORY']),

    P('page_sports', 'Sports', 'LISTING', '/sports', 'page_home',
      'Sportsbook landing page listing sports and featured events.',
      ['sports', 'betting', 'odds'], ['sports', 'sportsbook'],
      ['OPEN_SPORT', 'OPEN_EVENT']),

    P('page_sports_event', 'Sports Event', 'DETAIL', '/sports/{sport}/{event_id}', 'page_sports',
      'Detail view for a single event with its available markets.',
      ['event', 'match', 'markets', 'odds'], ['match page', 'event page'],
      ['OPEN_EVENT', 'OPEN_BET_HISTORY']),

    P('page_wallet', 'Wallet', 'ACCOUNT', '/wallet', 'page_home',
      'Wallet overview with balance summary and links to deposit and withdraw.',
      ['wallet', 'balance', 'funds'], ['wallet', 'balance'],
      ['OPEN_DEPOSIT', 'OPEN_WITHDRAW', 'OPEN_WALLET'], requires_auth=True),

    P('page_deposit', 'Deposit', 'TRANSACTIONAL', '/wallet/deposit', 'page_wallet',
      'Page for adding funds, listing the available payment methods.',
      ['deposit', 'add funds', 'payment'], ['deposit', 'add money', 'top up'],
      ['OPEN_DEPOSIT', 'OPEN_HELP'], requires_auth=True),

    P('page_withdraw', 'Withdraw', 'TRANSACTIONAL', '/wallet/withdraw', 'page_wallet',
      'Page for requesting a withdrawal. May require completed verification.',
      ['withdraw', 'payout', 'cashout'], ['withdraw', 'cash out'],
      ['OPEN_WITHDRAW', 'OPEN_KYC', 'OPEN_HELP'], requires_auth=True, requires_kyc=True),

    P('page_transactions', 'Transactions', 'ACCOUNT', '/wallet/transactions', 'page_wallet',
      'Chronological record of account transactions.',
      ['transactions', 'history', 'statement'], ['transactions', 'payment history'],
      ['OPEN_WALLET', 'OPEN_HELP'], requires_auth=True),

    P('page_bet_history', 'Bet History', 'ACCOUNT', '/account/bet-history', 'page_home',
      'List of placed bets with status, stake and settlement.',
      ['bets', 'history', 'settled', 'pending'], ['bet history', 'my bets'],
      ['OPEN_BET_HISTORY', 'OPEN_HELP'], requires_auth=True),

    P('page_profile', 'Profile', 'ACCOUNT', '/account/profile', 'page_home',
      'Profile details and account settings.',
      ['profile', 'settings', 'account'], ['profile', 'my account'],
      ['OPEN_PROFILE', 'OPEN_KYC', 'OPEN_RESPONSIBLE_GAMING'], requires_auth=True),

    P('page_kyc', 'KYC', 'ACCOUNT', '/account/kyc', 'page_profile',
      'Identity verification: document upload and verification status.',
      ['kyc', 'verification', 'documents'], ['kyc', 'verify account'],
      ['OPEN_KYC', 'OPEN_SUPPORT'], requires_auth=True),

    P('page_promotions', 'Promotions', 'INFORMATIONAL', '/promotions', 'page_home',
      'Current promotional campaigns and their terms.',
      ['promotions', 'offers', 'bonus'], ['promotions', 'offers'],
      ['OPEN_PROMOTIONS', 'OPEN_HELP']),

    P('page_help', 'Help', 'SUPPORT', '/help', 'page_home',
      'Help centre with articles and frequently asked questions.',
      ['help', 'faq', 'articles'], ['help', 'faq'],
      ['OPEN_HELP', 'OPEN_SUPPORT']),

    P('page_support', 'Support', 'SUPPORT', '/help/contact', 'page_help',
      'Contact channels for the customer support team.',
      ['support', 'contact', 'chat', 'complaint'], ['support', 'contact us'],
      ['OPEN_SUPPORT']),

    P('page_responsible_gaming', 'Responsible Gaming', 'INFORMATIONAL',
      '/responsible-gaming', 'page_home',
      'Responsible gaming tools and external support resources.',
      ['responsible', 'limits', 'self-exclusion', 'help'],
      ['responsible gaming', 'limits', 'self exclusion'],
      ['OPEN_RESPONSIBLE_GAMING', 'OPEN_SUPPORT']),
]


# ======================================================================
# PART 9 — actions
# ======================================================================
ACTIONS = [
    ('OPEN_GAME', 'GAME', False, False, False, 'Launch a specific game.'),
    ('OPEN_CATEGORY', 'CATEGORY', False, False, False, 'Open a game category or lobby.'),
    ('OPEN_SPORT', 'SPORT', False, False, False, 'Open a sport section in the sportsbook.'),
    ('OPEN_EVENT', 'EVENT', False, False, False, 'Open a specific sporting event.'),
    ('OPEN_DEPOSIT', 'PAGE', True, False, True, 'Open the deposit page. Financial — confirm first.'),
    ('OPEN_WITHDRAW', 'PAGE', True, True, True, 'Open the withdrawal page. Financial — confirm first.'),
    ('OPEN_WALLET', 'PAGE', True, False, False, 'Open the wallet overview.'),
    ('OPEN_BET_HISTORY', 'PAGE', True, False, False, 'Open the bet history page.'),
    ('OPEN_PROFILE', 'PAGE', True, False, False, 'Open the account profile.'),
    ('OPEN_KYC', 'PAGE', True, False, False, 'Open the identity verification page.'),
    ('OPEN_PROMOTIONS', 'PAGE', False, False, False, 'Open the promotions page.'),
    ('OPEN_HELP', 'PAGE', False, False, False, 'Open the help centre.'),
    ('OPEN_SUPPORT', 'PAGE', False, False, False, 'Open support contact channels.'),
    ('OPEN_RESPONSIBLE_GAMING', 'PAGE', False, False, False,
     'Open responsible gaming tools. Always permitted, never gated.'),
]

ACTION_RECORDS = [{
    'action': a,
    'requires_entity_type': et,
    'requires_auth': auth,
    'requires_kyc': kyc,
    'confirm_before_execute': confirm,
    'description': desc,
    'route_source': 'entity_registry',
    'llm_may_generate_url': False,
} for a, et, auth, kyc, confirm, desc in ACTIONS]

INTENT_ACTION_MAP = [
    {'intent': 'NAVIGATE', 'entity_type': 'GAME', 'action': 'OPEN_GAME'},
    {'intent': 'NAVIGATE', 'entity_type': 'CATEGORY', 'action': 'OPEN_CATEGORY'},
    {'intent': 'NAVIGATE', 'entity_type': 'SPORT', 'action': 'OPEN_SPORT'},
    {'intent': 'NAVIGATE', 'entity_type': 'EVENT', 'action': 'OPEN_EVENT'},
    {'intent': 'NAVIGATE', 'entity_type': 'PAGE', 'action': 'OPEN_PAGE_BY_ID'},
    {'intent': 'DEPOSIT', 'entity_type': 'PAGE', 'action': 'OPEN_DEPOSIT'},
    {'intent': 'WITHDRAW', 'entity_type': 'PAGE', 'action': 'OPEN_WITHDRAW'},
    {'intent': 'BET_HISTORY', 'entity_type': 'PAGE', 'action': 'OPEN_BET_HISTORY'},
    {'intent': 'ACCOUNT', 'entity_type': 'PAGE', 'action': 'OPEN_PROFILE'},
    {'intent': 'KYC', 'entity_type': 'PAGE', 'action': 'OPEN_KYC'},
    {'intent': 'PROMOTION', 'entity_type': 'PAGE', 'action': 'OPEN_PROMOTIONS'},
    {'intent': 'SUPPORT', 'entity_type': 'PAGE', 'action': 'OPEN_SUPPORT'},
    {'intent': 'RESPONSIBLE_GAMING', 'entity_type': 'PAGE', 'action': 'OPEN_RESPONSIBLE_GAMING'},
    {'intent': 'FAQ', 'entity_type': None, 'action': 'ANSWER_FROM_RAG'},
    {'intent': 'GAME_INFO', 'entity_type': 'GAME', 'action': 'ANSWER_FROM_RAG'},
    {'intent': 'SEARCH', 'entity_type': None, 'action': 'SHOW_SEARCH_RESULTS'},
    {'intent': 'AMBIGUOUS', 'entity_type': None, 'action': 'ASK_CLARIFICATION'},
    {'intent': 'UNKNOWN', 'entity_type': None, 'action': 'FALLBACK_TO_SUPPORT'},
]


def main():
    print('navigation layer:')
    w('navigation/entities.json', ENTITIES)
    w('navigation/pages.json', PAGES)

    categories = [e for e in ENTITIES if e['type'] in ('CATEGORY', 'SPORT')]
    w('navigation/categories.json', categories)

    # flat alias -> entity_id lookup, the fast path for exact matching
    alias_rows = []
    seen = set()
    for e in ENTITIES:
        for a in [e['name'].lower()] + e['aliases']:
            key = a.lower().strip()
            if (key, e['id']) in seen:
                continue
            seen.add((key, e['id']))
            alias_rows.append({
                'alias': key,
                'entity_id': e['id'],
                'entity_type': e['type'],
                'match_type': 'exact',
            })
    w('navigation/aliases.json', alias_rows)

    w('intents/actions.json', {
        'actions': ACTION_RECORDS,
        'intent_action_map': INTENT_ACTION_MAP,
        'note': 'route_source is always entity_registry. The executor accepts an '
                'entity_id and looks up the route; it has no code path that accepts '
                'a URL produced by the model.',
    })

    # integrity check: every parent_id must exist
    ids = {e['id'] for e in ENTITIES}
    orphans = [e['id'] for e in ENTITIES if e['parent_id'] and e['parent_id'] not in ids]
    dupes = [i for i in ids if [e['id'] for e in ENTITIES].count(i) > 1]
    print(f'\n  entities={len(ENTITIES)} pages={len(PAGES)} aliases={len(alias_rows)}')
    print(f'  orphan parents: {orphans or "none"}')
    print(f'  duplicate ids : {dupes or "none"}')


if __name__ == '__main__':
    main()
