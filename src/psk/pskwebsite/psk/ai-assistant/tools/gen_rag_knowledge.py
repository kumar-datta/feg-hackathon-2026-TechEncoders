"""
gen_rag_knowledge.py — game knowledge (PART 3) and policy records (PART 5).

Outputs:
  data/rag/game_knowledge.json
  data/rag/policies.json

MOCK DATA. Game descriptions cover generic, publicly-known mechanics only.
Policy records are intentionally placeholders — see the note in each record.
"""
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')

RG_NOTE = ('Outcomes are determined by a random number generator and each round is '
           'independent of previous rounds. No strategy can predict or influence a '
           'result. Set a budget before playing and use the deposit and time limit '
           'tools if you want them.')


def w(rel, obj):
    path = os.path.normpath(os.path.join(OUT, rel))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)
    print(f'  {rel:40s} {len(obj):4d} records')


# ======================================================================
# PART 3 — game knowledge
# ======================================================================
GAMES = [
    {
        'game_id': 'game_aviator',
        'name': 'Aviator',
        'category': 'Crash Games',
        'description': (
            'Aviator is a crash-style game. Each round a multiplier starts at 1.00x and '
            'increases; at a randomly determined point the round ends. If you cash out '
            'before the round ends, your stake is multiplied by the value shown at that '
            'moment. If the round ends first, the stake for that round is lost.'),
        'how_to_play': (
            '1. Open the game and set your stake for the round. '
            '2. Wait for the round to begin — the multiplier starts rising. '
            '3. Press Cash Out at any point while the round is running to lock in the '
            'multiplier displayed at that instant. '
            '4. If the round ends before you cash out, that round is lost. '
            'Some versions let you place two stakes in one round and cash them out '
            'separately, and offer an auto cash-out setting that triggers at a chosen '
            'multiplier.'),
        'basic_rules': (
            'The stopping point of each round is generated randomly and independently. '
            'Past rounds have no bearing on future ones. A cash-out is only valid if it '
            'registers before the round ends. Minimum and maximum stakes are shown in '
            'the game interface.'),
        'terminology': [
            {'term': 'Multiplier', 'definition': 'The rising number that a stake is multiplied by if you cash out.'},
            {'term': 'Cash Out', 'definition': 'Ending your participation in the round to lock in the current multiplier.'},
            {'term': 'Auto Cash Out', 'definition': 'An optional setting that cashes out automatically at a chosen multiplier.'},
            {'term': 'Round', 'definition': 'A single play cycle from start to the point the multiplier stops.'},
            {'term': 'Bust', 'definition': 'The moment a round ends, after which cash-outs are no longer possible.'},
        ],
        'common_questions': [
            {'q': 'Can I predict when the round will end?',
             'a': 'No. Each round ends at a randomly determined point and is independent of every previous round. No pattern, history view or strategy can predict it.'},
            {'q': 'What happens if I lose connection mid-round?',
             'a': 'Behaviour depends on the game provider and whether an auto cash-out was set. Check the in-game rules, or contact support for your specific round.'},
            {'q': 'Can I cash out part of my stake?',
             'a': 'Some versions support two separate stakes per round that can be cashed out independently. The in-game interface shows whether this is available.'},
            {'q': 'Does the round history tell me what comes next?',
             'a': 'No. History is a record only. It has no predictive value because rounds are independent.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/aviator',
    },
    {
        'game_id': 'game_crash_classic',
        'name': 'Crash Classic',
        'category': 'Crash Games',
        'description': (
            'A crash game in which a multiplier climbs from 1.00x until the round ends at '
            'a randomly determined point. Players cash out during the round to lock in the '
            'multiplier reached at that moment.'),
        'how_to_play': (
            '1. Set your stake before the round starts. 2. Watch the multiplier climb. '
            '3. Cash out to secure the current multiplier. 4. If the round ends before '
            'you cash out, the stake for that round is lost.'),
        'basic_rules': (
            'Each round is independent and randomly determined. Cash-outs must register '
            'before the round ends. Stake limits are displayed in the game.'),
        'terminology': [
            {'term': 'Multiplier', 'definition': 'The value a stake is multiplied by on cash out.'},
            {'term': 'Cash Out', 'definition': 'Locking in the multiplier currently displayed.'},
            {'term': 'Round', 'definition': 'One complete play cycle.'},
        ],
        'common_questions': [
            {'q': 'Is there a safe multiplier to aim for?',
             'a': 'No multiplier is safer than another. The stopping point is random each round, so no target guarantees an outcome.'},
            {'q': 'How is the result generated?',
             'a': 'By a random number generator. Details of the provider\'s RNG and any fairness verification are shown in the game information panel.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/crash-classic',
    },
    {
        'game_id': 'game_roulette',
        'name': 'Roulette',
        'category': 'Table Games',
        'description': (
            'Roulette is a wheel game. Players place bets on the layout, a ball is spun '
            'around a numbered wheel, and bets are settled according to where the ball '
            'comes to rest.'),
        'how_to_play': (
            '1. Place chips on the betting layout during the betting window. You can bet '
            'on a single number, groups of numbers, colours, odd/even, or high/low ranges. '
            '2. Betting closes and the wheel is spun. 3. The winning number is announced '
            'and bets are settled automatically.'),
        'basic_rules': (
            'Bets are grouped as inside bets (on specific numbers or small groups) and '
            'outside bets (on larger groups such as colour or odd/even). Different bet '
            'types pay at different rates, shown in the game paytable. European wheels '
            'have a single zero; American wheels have an additional double zero. Bets '
            'placed after betting closes are not accepted.'),
        'terminology': [
            {'term': 'Inside Bet', 'definition': 'A bet on a specific number or a small group of adjacent numbers.'},
            {'term': 'Outside Bet', 'definition': 'A bet on a large group, such as red/black or odd/even.'},
            {'term': 'Straight Up', 'definition': 'A bet on one single number.'},
            {'term': 'Split', 'definition': 'A bet covering two adjacent numbers on the layout.'},
            {'term': 'Zero', 'definition': 'A pocket that is neither red nor black and is not odd or even.'},
        ],
        'common_questions': [
            {'q': 'Do previous spins affect the next one?',
             'a': 'No. Each spin is independent. A run of one colour does not make the other more likely on the following spin.'},
            {'q': 'What is the difference between European and American roulette?',
             'a': 'European wheels have a single zero pocket; American wheels have both a zero and a double zero, which changes the number of pockets on the wheel.'},
            {'q': 'When can I no longer place a bet?',
             'a': 'Once the betting window closes for that spin. The interface shows the remaining time.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/roulette',
    },
    {
        'game_id': 'game_blackjack',
        'name': 'Blackjack',
        'category': 'Table Games',
        'description': (
            'Blackjack is a card game in which players aim for a hand total closer to 21 '
            'than the dealer, without exceeding 21.'),
        'how_to_play': (
            '1. Place your bet. 2. You and the dealer receive cards. 3. Choose to hit '
            '(take another card), stand (keep your total), or use other options such as '
            'double or split where offered. 4. The dealer plays their hand according to '
            'fixed table rules. 5. Hands are compared and bets settled.'),
        'basic_rules': (
            'Number cards count as their face value, picture cards count as 10, and an ace '
            'counts as 1 or 11 whichever is more favourable to the hand. Going over 21 '
            'loses the hand immediately. The dealer follows fixed drawing rules shown at '
            'the table. Payouts for a blackjack and the availability of double, split, '
            'insurance and surrender vary by table — always check the table rules panel.'),
        'terminology': [
            {'term': 'Hit', 'definition': 'Take another card.'},
            {'term': 'Stand', 'definition': 'Take no further cards.'},
            {'term': 'Bust', 'definition': 'A hand total above 21, which loses immediately.'},
            {'term': 'Blackjack', 'definition': 'An ace with a ten-value card as the first two cards.'},
            {'term': 'Double Down', 'definition': 'Doubling the bet in exchange for exactly one more card, where offered.'},
            {'term': 'Split', 'definition': 'Separating a pair into two hands, where offered.'},
        ],
        'common_questions': [
            {'q': 'Does the dealer always draw to a set total?',
             'a': 'The dealer follows the fixed rule printed on that specific table. Check the rules panel for the table you are on, as it varies.'},
            {'q': 'Is card counting useful here?',
             'a': 'Online blackjack typically reshuffles frequently or uses continuous shuffling, so counting approaches do not apply. No approach changes the fact that each hand outcome is uncertain.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/blackjack',
    },
    {
        'game_id': 'game_poker',
        'name': 'Poker',
        'category': 'Table Games',
        'description': (
            'Poker is a card game in which players make hands from their own cards and, in '
            'community variants, shared cards, betting across a series of rounds.'),
        'how_to_play': (
            '1. Join a table and post any required blinds or antes. 2. Cards are dealt. '
            '3. Across the betting rounds you may fold, check, call, bet or raise. '
            '4. Remaining hands are compared at showdown and the pot is awarded.'),
        'basic_rules': (
            'Hand rankings run from high card up to the strongest combinations, and are '
            'listed in the game\'s help panel. Variant rules, blind structure and betting '
            'limits differ between tables — check the table information before joining.'),
        'terminology': [
            {'term': 'Blind', 'definition': 'A forced bet posted before cards are dealt.'},
            {'term': 'Fold', 'definition': 'Discard your hand and forfeit the current pot.'},
            {'term': 'Call', 'definition': 'Match the current bet.'},
            {'term': 'Raise', 'definition': 'Increase the current bet.'},
            {'term': 'Showdown', 'definition': 'Comparing remaining hands to decide the pot.'},
            {'term': 'Pot', 'definition': 'The total amount wagered in the current hand.'},
        ],
        'common_questions': [
            {'q': 'Where do I find the hand rankings?',
             'a': 'In the help or rules panel inside the poker client. Rankings are also listed on the game detail page.'},
            {'q': 'Do all tables use the same rules?',
             'a': 'No. Variant, blinds and betting limits differ per table and are shown before you join.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/poker',
    },
    {
        'game_id': 'game_baccarat',
        'name': 'Baccarat',
        'category': 'Table Games',
        'description': (
            'Baccarat is a card game where players bet on which of two hands — player or '
            'banker — will come closer to a total of nine, or whether the result is a tie.'),
        'how_to_play': (
            '1. Bet on player, banker or tie. 2. Two hands are dealt. 3. A third card may '
            'be drawn according to fixed drawing rules that require no decisions from you. '
            '4. The hand closer to nine wins and bets settle.'),
        'basic_rules': (
            'Card values: aces count one, cards two to nine count face value, and tens and '
            'picture cards count zero. Only the last digit of a total counts, so a total of '
            'fifteen counts as five. Third-card rules are fixed and applied automatically. '
            'Payout rates including any commission on banker bets are shown in the paytable.'),
        'terminology': [
            {'term': 'Player Bet', 'definition': 'A bet that the player hand wins.'},
            {'term': 'Banker Bet', 'definition': 'A bet that the banker hand wins.'},
            {'term': 'Tie Bet', 'definition': 'A bet that both hands finish equal.'},
            {'term': 'Natural', 'definition': 'A two-card total of eight or nine.'},
        ],
        'common_questions': [
            {'q': 'Do I decide whether to draw a third card?',
             'a': 'No. Third-card draws follow fixed rules applied automatically by the game.'},
            {'q': 'Do scoreboards and trend charts help?',
             'a': 'They record past results only. Each coup is independent, so they have no predictive value.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/baccarat',
    },
    {
        'game_id': 'game_dice',
        'name': 'Dice',
        'category': 'Instant Games',
        'description': (
            'An instant game where the result of each round is produced by a random dice '
            'roll, with bets placed on outcomes such as a range or a specific total.'),
        'how_to_play': (
            '1. Choose your bet type and stake. 2. Roll. 3. The result is generated '
            'randomly and the bet settles immediately.'),
        'basic_rules': (
            'Each roll is independent and randomly generated. Available bet types and '
            'their payout rates are listed in the game paytable.'),
        'terminology': [
            {'term': 'Roll', 'definition': 'A single randomly generated dice result.'},
            {'term': 'Over / Under', 'definition': 'A bet on the total being above or below a chosen value.'},
            {'term': 'Payout Rate', 'definition': 'The rate at which a winning bet type settles, shown in the paytable.'},
        ],
        'common_questions': [
            {'q': 'Are rolls linked to each other?',
             'a': 'No. Every roll is independent and randomly generated.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/games/dice',
    },
    {
        'game_id': 'category_slots',
        'name': 'Slots (general)',
        'category': 'Slots',
        'description': (
            'Slots are reel-based games. A spin places symbols on a grid, and combinations '
            'across defined paylines or ways settle according to the game\'s paytable.'),
        'how_to_play': (
            '1. Choose your stake per spin. 2. Spin the reels. 3. Winning combinations are '
            'evaluated automatically against the paytable. Features such as free spins or '
            'bonus rounds trigger according to each game\'s own rules.'),
        'basic_rules': (
            'Every spin result is produced by a random number generator and is independent '
            'of previous spins. Paylines, symbol values, volatility and feature rules are '
            'specific to each individual game and are documented in that game\'s info panel.'),
        'terminology': [
            {'term': 'Payline', 'definition': 'A defined pattern across the reels that is evaluated for combinations.'},
            {'term': 'Scatter', 'definition': 'A symbol that pays or triggers a feature regardless of payline position, where the game defines it.'},
            {'term': 'Wild', 'definition': 'A symbol that substitutes for others according to the game\'s rules.'},
            {'term': 'Paytable', 'definition': 'The in-game table listing symbol values and feature rules.'},
            {'term': 'Volatility', 'definition': 'A descriptive label for how a game\'s results tend to be distributed. It is not a prediction of any outcome.'},
        ],
        'common_questions': [
            {'q': 'Is a machine ever "due" for a win?',
             'a': 'No. Each spin is independent and randomly generated. A game is never due for any particular result regardless of how long it has been played.'},
            {'q': 'Does a bigger stake improve my chances?',
             'a': 'Stake size changes the amount at risk and the amount a combination settles for. It does not change how the result is generated.'},
            {'q': 'Where do I find a specific slot\'s rules?',
             'a': 'In that game\'s info or paytable panel, opened from inside the game.'},
        ],
        'responsible_gaming_note': RG_NOTE,
        'route': '/casino/slots',
    },
]

for g in GAMES:
    g['content_status'] = 'EXAMPLE_DATA'
    g['source_type'] = 'GAME_KNOWLEDGE'
    g['requires_verified_source'] = False


# ======================================================================
# PART 5 — policy records (placeholders by design)
# ======================================================================
PLACEHOLDER = '[REPLACE WITH ACTUAL COMPANY POLICY]'

POLICY_SPECS = [
    ('policy_terms_001', 'Terms & Conditions', 'TERMS',
     'Governs account use, eligibility, and the contractual relationship with the operator.'),
    ('policy_privacy_001', 'Privacy Policy', 'PRIVACY',
     'What personal data is collected, the basis for processing, retention and user rights.'),
    ('policy_responsible_gaming_001', 'Responsible Gaming Policy', 'RESPONSIBLE_GAMING',
     'Available player-protection tools and the operator\'s commitments.'),
    ('policy_age_restriction_001', 'Age Restriction', 'AGE_RESTRICTION',
     'The minimum legal age and how age is verified. Varies by jurisdiction.'),
    ('policy_kyc_001', 'KYC & Identity Verification', 'KYC',
     'Which documents are accepted, when verification is triggered, and how long review takes.'),
    ('policy_account_security_001', 'Account Security', 'ACCOUNT_SECURITY',
     'Password requirements, multi-factor options, and reporting unauthorised access.'),
    ('policy_self_exclusion_001', 'Self-Exclusion', 'SELF_EXCLUSION',
     'How to self-exclude, the available durations, and whether it can be reversed.'),
    ('policy_deposit_limits_001', 'Deposit Limits', 'DEPOSIT_LIMITS',
     'How limits are set, when increases take effect, and any cooling-off period.'),
    ('policy_withdrawal_001', 'Withdrawal Policy', 'WITHDRAWAL_POLICY',
     'Processing times, verification requirements, methods, and any limits or fees.'),
    ('policy_dispute_001', 'Dispute Handling', 'DISPUTE',
     'How to raise a dispute, response timeframes, and escalation including any ADR body.'),
    ('policy_account_closure_001', 'Account Closure', 'ACCOUNT_CLOSURE',
     'How to close an account and what happens to any remaining balance.'),
    ('policy_bonus_terms_001', 'Bonus Terms', 'BONUS_TERMS',
     'Wagering requirements, eligibility, game contribution, expiry and forfeiture.'),
    ('policy_complaints_001', 'Complaints Procedure', 'COMPLAINTS',
     'How complaints are logged, acknowledged and resolved.'),
    ('policy_aml_001', 'Anti-Money-Laundering', 'AML',
     'Source-of-funds checks and reporting obligations under the operating licence.'),
]

POLICIES = [{
    'id': pid,
    'title': title,
    'content': PLACEHOLDER,
    'category': category,
    'summary_of_what_belongs_here': belongs,
    'requires_verified_source': True,
    'jurisdiction': '[REPLACE — requirements differ by licensing jurisdiction]',
    'last_reviewed': None,
    'owner': 'legal_and_compliance',
    'source_type': 'POLICY',
    'assistant_behaviour_until_populated': (
        'Do not state specifics. Explain that the detail is published in the official '
        'policy page, link the user there, and offer to connect them to support.'),
    'data_status': 'PLACEHOLDER_REQUIRES_COMPANY_INPUT',
} for pid, title, category, belongs in POLICY_SPECS]


def main():
    print('rag knowledge:')
    w('rag/game_knowledge.json', GAMES)
    w('rag/policies.json', POLICIES)
    print(f'\n  NOTE: all {len(POLICIES)} policy records are placeholders and must be')
    print('  populated from your published legal documentation before launch.')


if __name__ == '__main__':
    main()
