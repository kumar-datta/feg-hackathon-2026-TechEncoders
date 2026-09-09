"""
gen_faq.py — FAQ RAG dataset (PART 4).

Outputs: data/rag/faq.json

RULE APPLIED THROUGHOUT: any answer whose truth depends on company policy
(processing times, limits, fees, accepted documents, eligibility) is written as a
*structural* answer and flagged requires_verified_source=true. The assistant must
route those to the official page rather than stating numbers. Nothing here invents
a policy.
"""
import json
import os

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')

CHECK = ('The exact details are published on the official page for this topic — '
         'please check there or contact support, as this varies by operator and region.')

rows = []


def F(cat, q, a, kw, pages, priority='medium', verify=False):
    rows.append({
        'id': f'faq_{cat.lower()}_{sum(1 for r in rows if r["category"] == cat) + 1:03d}',
        'question': q,
        'answer': a,
        'category': cat,
        'keywords': kw,
        'related_pages': pages,
        'source_type': 'FAQ',
        'priority': priority,
        'requires_verified_source': verify,
        'data_status': 'EXAMPLE_DATA',
    })


# ======================================================================
# ACCOUNT
# ======================================================================
F('ACCOUNT', 'How do I create an account?',
  'Open the registration page from the sign-up button in the header, provide the required '
  'details, and confirm your email or phone number if prompted. You must be of legal '
  'gambling age in your jurisdiction to register.',
  ['register', 'sign up', 'create account', 'new account'], ['page_profile'], 'high')

F('ACCOUNT', 'How do I log in?',
  'Use the login button in the site header and enter the username or email and password '
  'you registered with. If two-factor authentication is enabled on your account, you will '
  'also be asked for a verification code.',
  ['login', 'sign in', 'log in'], ['page_profile'], 'high')

F('ACCOUNT', 'I forgot my password. How do I reset it?',
  'Use the "forgot password" link on the login screen. A reset link or code is sent to the '
  'email address or phone number registered to the account. If you no longer have access to '
  'that address, contact support — they will not reset a password without verifying identity.',
  ['password', 'forgot', 'reset', 'recover'], ['page_profile', 'page_contact_support'], 'high')

F('ACCOUNT', 'How do I change my password?',
  'Open your profile settings and use the change-password option. You will be asked for your '
  'current password before setting a new one.',
  ['password', 'change', 'update', 'security'], ['page_profile'], 'medium')

F('ACCOUNT', 'How do I log out?',
  'Use the logout option in the account menu. If you are on a shared or public device, log '
  'out at the end of every session and avoid saving your password in the browser.',
  ['logout', 'sign out', 'exit'], ['page_profile'], 'medium')

F('ACCOUNT', 'How do I update my email address or phone number?',
  'Contact details are changed from your profile settings. Changing them may require '
  're-verification, and some operators restrict changes while a withdrawal is in progress.',
  ['email', 'phone', 'update', 'contact details'], ['page_profile'], 'medium', True)

F('ACCOUNT', 'Can I change my username?',
  'Whether a username can be changed after registration depends on the operator\'s account '
  'policy. ' + CHECK,
  ['username', 'change', 'nickname'], ['page_profile', 'page_contact_support'], 'low', True)

F('ACCOUNT', 'Can I have more than one account?',
  'Operators generally permit only one account per person. Duplicate accounts are usually '
  'restricted when detected. The exact rule is set out in the terms and conditions.',
  ['multiple accounts', 'duplicate', 'second account'], ['page_terms'], 'medium', True)

F('ACCOUNT', 'Why is my account restricted?',
  'Accounts can be restricted for several reasons, including incomplete verification, a '
  'security review, a self-exclusion or limit you set, or a terms-and-conditions issue. '
  'The specific reason for your account can only be given by support after they verify you.',
  ['restricted', 'blocked', 'suspended', 'locked'], ['page_contact_support', 'page_kyc'], 'high')

F('ACCOUNT', 'How do I close my account?',
  'Account closure is requested through support or, where offered, from account settings. '
  'What happens to a remaining balance and whether closure is reversible is set out in the '
  'account closure policy. ' + CHECK,
  ['close', 'delete', 'deactivate', 'remove account'],
  ['page_profile', 'page_contact_support', 'page_responsible_gaming'], 'medium', True)

F('ACCOUNT', 'How do I update my account settings?',
  'Open your profile from the account menu. Settings there typically cover contact details, '
  'communication preferences, security options and responsible gaming limits.',
  ['settings', 'preferences', 'profile'], ['page_profile'], 'medium')

F('ACCOUNT', 'How do I enable two-factor authentication?',
  'If two-factor authentication is offered, it is enabled from the security section of your '
  'profile settings. Turning it on is one of the most effective steps you can take to protect '
  'an account that holds funds.',
  ['2fa', 'two factor', 'security', 'authentication'], ['page_profile'], 'medium', True)

F('ACCOUNT', 'Someone may have accessed my account. What should I do?',
  'Change your password immediately, and enable two-factor authentication if it is available. '
  'Then contact support straight away so they can review account activity and secure it. Do '
  'not share your password or any verification code with anyone, including people claiming to '
  'be staff.',
  ['hacked', 'unauthorised', 'compromised', 'security'],
  ['page_profile', 'page_contact_support'], 'high')

F('ACCOUNT', 'Why do I keep getting logged out?',
  'Sessions expire after a period of inactivity for security. Frequent unexpected logouts can '
  'also be caused by browser settings that clear cookies, private browsing mode, or switching '
  'networks. If it persists after checking those, contact support.',
  ['logged out', 'session', 'expired'], ['page_contact_support'], 'low')

F('ACCOUNT', 'What personal details do I need to provide?',
  'Registration typically requires identifying details and contact information. Additional '
  'documents may be requested later for verification. Exactly what is collected and why is '
  'described in the privacy policy.',
  ['details', 'personal data', 'information'], ['page_privacy', 'page_kyc'], 'medium', True)

# ======================================================================
# KYC
# ======================================================================
F('KYC', 'What is KYC?',
  'KYC stands for "Know Your Customer". It is the identity verification process operators are '
  'required to carry out, confirming who you are and, in some cases, where your funds come from.',
  ['kyc', 'verification', 'identity'], ['page_kyc'], 'high')

F('KYC', 'Why do I need to complete KYC?',
  'Licensed gambling operators are legally required to verify customer identity. Verification '
  'supports age checks, anti-money-laundering obligations and account security. It is not '
  'optional where the licence requires it.',
  ['kyc', 'why', 'required', 'mandatory'], ['page_kyc', 'page_terms'], 'high')

F('KYC', 'Which documents are accepted for verification?',
  'Accepted document types are listed on the verification page in your account. They commonly '
  'include a government-issued photo ID and a proof of address, but the exact list depends on '
  'the operator and your jurisdiction. ' + CHECK,
  ['documents', 'id', 'passport', 'proof'], ['page_kyc'], 'high', True)

F('KYC', 'How do I upload my documents?',
  'Open the verification page in your account and use the upload option for each requested '
  'document. Make sure the whole document is visible, in focus, and not cropped at the edges — '
  'unclear images are the most common reason for a rejected submission.',
  ['upload', 'documents', 'submit'], ['page_kyc'], 'high')

F('KYC', 'How long does verification take?',
  'Review times depend on the operator and on how many submissions are in the queue. The '
  'expected timeframe is published on the verification page. ' + CHECK,
  ['how long', 'time', 'processing', 'review'], ['page_kyc', 'page_contact_support'], 'high', True)

F('KYC', 'How do I check my verification status?',
  'Your current status is shown on the verification page in your account, along with anything '
  'still outstanding.',
  ['status', 'check', 'progress', 'pending'], ['page_kyc'], 'high')

F('KYC', 'My verification failed. What now?',
  'The verification page normally states the reason. Common causes are an unclear or cropped '
  'image, an expired document, or details that do not match the account. Correct the issue and '
  'resubmit. If the reason is unclear, contact support.',
  ['failed', 'rejected', 'declined', 'resubmit'], ['page_kyc', 'page_contact_support'], 'high')

F('KYC', 'Do I have to verify before withdrawing?',
  'Most licensed operators require completed verification before a withdrawal is released. '
  'Whether it is required before depositing or playing varies. ' + CHECK,
  ['withdraw', 'before', 'required'], ['page_kyc', 'page_withdraw'], 'high', True)

F('KYC', 'Is my identity document stored securely?',
  'Handling, storage and retention of identity documents is governed by the privacy policy and '
  'applicable data protection law. The privacy policy sets out the specifics.',
  ['security', 'storage', 'data', 'privacy'], ['page_privacy', 'page_kyc'], 'medium', True)

F('KYC', 'Why was I asked for proof of my source of funds?',
  'Source-of-funds checks are part of anti-money-laundering obligations and can be triggered by '
  'a range of factors. They are a standard regulatory requirement, not an accusation. The '
  'documents accepted are listed on the verification page.',
  ['source of funds', 'aml', 'proof'], ['page_kyc', 'page_contact_support'], 'medium', True)

F('KYC', 'Can someone else verify on my behalf?',
  'No. Accounts are personal and verification must be completed by the account holder with '
  'their own documents. Using another person\'s documents or account is a terms breach.',
  ['someone else', 'behalf', 'third party'], ['page_kyc', 'page_terms'], 'medium')

# ======================================================================
# DEPOSIT
# ======================================================================
F('DEPOSIT', 'How do I deposit money?',
  'Open the deposit page from your wallet, choose a payment method, enter the amount, and '
  'follow the prompts for that method. You need to be logged in.',
  ['deposit', 'add money', 'top up', 'fund'], ['page_deposit', 'page_wallet'], 'high')

F('DEPOSIT', 'What payment methods can I use?',
  'The methods available to you are listed on the deposit page, and depend on your region and '
  'account. ' + CHECK,
  ['payment methods', 'options', 'card', 'upi', 'bank'], ['page_deposit'], 'high', True)

F('DEPOSIT', 'What is the minimum deposit?',
  'Minimum amounts are shown on the deposit page next to each payment method, and differ '
  'between methods. ' + CHECK,
  ['minimum', 'min', 'smallest', 'limit'], ['page_deposit'], 'high', True)

F('DEPOSIT', 'What is the maximum deposit?',
  'Maximum amounts per transaction and per period are shown on the deposit page and may also '
  'be affected by any deposit limit you have set yourself. ' + CHECK,
  ['maximum', 'max', 'limit', 'cap'], ['page_deposit', 'page_responsible_gaming'], 'medium', True)

F('DEPOSIT', 'My deposit is pending. What does that mean?',
  'A pending deposit has been initiated but not yet confirmed. Some methods settle instantly '
  'while others take longer to clear. If it stays pending beyond the timeframe shown for that '
  'method, contact support with the transaction reference.',
  ['pending', 'processing', 'not credited', 'waiting'],
  ['page_transactions', 'page_contact_support'], 'high')

F('DEPOSIT', 'My deposit failed but money left my account. What should I do?',
  'Failed transactions where funds have left your account are usually reversed by the payment '
  'provider, though the timeframe is set by them rather than the operator. Keep your bank '
  'reference and contact support so they can trace it.',
  ['failed', 'debited', 'money taken', 'not credited'],
  ['page_transactions', 'page_contact_support'], 'high')

F('DEPOSIT', 'I was charged twice for one deposit.',
  'Contact support with both transaction references. Duplicate charges are investigated against '
  'the payment provider\'s records, and any confirmed duplicate is handled under the operator\'s '
  'refund process.',
  ['duplicate', 'charged twice', 'double'], ['page_transactions', 'page_contact_support'], 'high')

F('DEPOSIT', 'Why was my deposit declined?',
  'Declines usually come from the payment provider rather than the operator — common causes '
  'include insufficient funds, card restrictions on gambling transactions, expired card details, '
  'or a bank security block. Your bank can tell you the specific reason.',
  ['declined', 'rejected', 'failed', 'error'], ['page_deposit', 'page_contact_support'], 'high')

F('DEPOSIT', 'How long does a deposit take to appear?',
  'Most methods credit quickly, but timing varies by method and provider. The expected time is '
  'shown next to each method on the deposit page. ' + CHECK,
  ['how long', 'time', 'instant', 'delay'], ['page_deposit'], 'medium', True)

F('DEPOSIT', 'Are there fees for depositing?',
  'Any fee applied by the operator is displayed before you confirm. Your bank or payment '
  'provider may apply its own charges separately. ' + CHECK,
  ['fees', 'charges', 'cost'], ['page_deposit'], 'medium', True)

F('DEPOSIT', 'Can I deposit using someone else\'s card?',
  'No. Payment methods must be in the account holder\'s own name. Using a third party\'s payment '
  'method is a terms breach and will typically block withdrawals.',
  ['someone else', 'third party', 'not my card'], ['page_terms', 'page_deposit'], 'high')

F('DEPOSIT', 'Can I cancel a deposit?',
  'Once a deposit is confirmed it generally cannot be cancelled. If you deposited by mistake or '
  'feel you are spending more than you intended, contact support and consider setting a deposit '
  'limit or taking a break.',
  ['cancel', 'reverse', 'undo', 'mistake'],
  ['page_contact_support', 'page_responsible_gaming'], 'medium')

F('DEPOSIT', 'How do I set a deposit limit?',
  'Deposit limits are set from the responsible gaming section of your account. Reductions '
  'usually apply immediately while increases often take effect only after a delay.',
  ['limit', 'deposit limit', 'control', 'cap'], ['page_responsible_gaming'], 'high', True)

# ======================================================================
# WITHDRAWAL
# ======================================================================
F('WITHDRAWAL', 'How do I withdraw money?',
  'Open the withdrawal page from your wallet, choose a method, enter the amount and confirm. '
  'Verification usually needs to be complete before a withdrawal can be released.',
  ['withdraw', 'cash out', 'payout', 'take money'],
  ['page_withdraw', 'page_wallet', 'page_kyc'], 'high')

F('WITHDRAWAL', 'How long does a withdrawal take?',
  'Processing time depends on the operator\'s review process and on your payment provider. The '
  'published timeframe is on the withdrawal page. I can\'t give you a specific time — that '
  'figure has to come from the official policy. ' + CHECK,
  ['how long', 'time', 'processing', 'when'],
  ['page_withdraw', 'page_contact_support'], 'high', True)

F('WITHDRAWAL', 'Why is my withdrawal still pending?',
  'A pending withdrawal is normally awaiting review, outstanding verification, or processing by '
  'the payment provider. Check the withdrawal page for any outstanding requirement, then contact '
  'support with the reference if it exceeds the published timeframe.',
  ['pending', 'processing', 'waiting', 'delay'],
  ['page_withdraw', 'page_kyc', 'page_contact_support'], 'high')

F('WITHDRAWAL', 'My withdrawal was rejected. Why?',
  'Common reasons include incomplete verification, a mismatch between the withdrawal method and '
  'the deposit method, an unmet bonus wagering requirement, or a limit. The exact reason for your '
  'request can only be confirmed by support.',
  ['rejected', 'declined', 'failed', 'refused'],
  ['page_withdraw', 'page_kyc', 'page_contact_support'], 'high')

F('WITHDRAWAL', 'What is the minimum withdrawal amount?',
  'Minimum withdrawal amounts are shown on the withdrawal page per method. ' + CHECK,
  ['minimum', 'min', 'smallest'], ['page_withdraw'], 'medium', True)

F('WITHDRAWAL', 'Is there a withdrawal limit?',
  'Any limits per transaction, per day or per period are published on the withdrawal page or in '
  'the terms. ' + CHECK,
  ['limit', 'maximum', 'cap', 'max'], ['page_withdraw', 'page_terms'], 'medium', True)

F('WITHDRAWAL', 'Can I withdraw to a different method than I deposited with?',
  'Operators commonly require withdrawals to return to the original payment method where '
  'possible, for anti-money-laundering reasons. The applicable rule is in the withdrawal policy. '
  + CHECK,
  ['different method', 'another account', 'change method'],
  ['page_withdraw', 'page_terms'], 'medium', True)

F('WITHDRAWAL', 'Can I cancel a withdrawal request?',
  'Some operators allow a pending withdrawal to be cancelled before it is processed. If that '
  'option exists it appears next to the pending request. Consider whether cancelling to keep '
  'playing is what you actually want.',
  ['cancel', 'reverse', 'stop'], ['page_withdraw', 'page_responsible_gaming'], 'medium', True)

F('WITHDRAWAL', 'Are there fees for withdrawing?',
  'Any operator fee is shown before you confirm the request. Your payment provider may apply '
  'separate charges. ' + CHECK,
  ['fees', 'charges', 'deduction'], ['page_withdraw'], 'medium', True)

F('WITHDRAWAL', 'Why do I need to verify before withdrawing?',
  'Identity verification before payout is a standard regulatory requirement for licensed '
  'operators. It confirms the account holder and the destination of funds.',
  ['verify', 'kyc', 'why', 'required'], ['page_kyc', 'page_withdraw'], 'high')

F('WITHDRAWAL', 'My withdrawal is approved but the money has not arrived.',
  'Once approved, the funds move through your payment provider or bank, which adds its own '
  'settlement time. If it exceeds the published timeframe, contact support with the payment '
  'reference so it can be traced.',
  ['not received', 'approved', 'missing', 'not arrived'],
  ['page_transactions', 'page_contact_support'], 'high')

F('WITHDRAWAL', 'Can I withdraw bonus funds?',
  'Bonus funds normally carry wagering requirements that must be met before any related balance '
  'can be withdrawn. The applicable terms are attached to each specific bonus.',
  ['bonus', 'wagering', 'withdraw bonus'], ['page_bonuses', 'page_withdraw'], 'high', True)

F('WITHDRAWAL', 'Where do I see my withdrawal history?',
  'Withdrawals appear in your transaction history along with their current status.',
  ['history', 'past', 'record', 'status'], ['page_transactions'], 'medium')

# ======================================================================
# BETTING
# ======================================================================
F('BETTING', 'How do I place a bet?',
  'Choose an event or market, select the outcome you want, enter a stake in the bet slip and '
  'confirm. The bet slip shows the stake and the potential return before you place it.',
  ['place bet', 'bet', 'stake', 'wager'], ['page_sports', 'page_bet_history'], 'high')

F('BETTING', 'Can I cancel a bet after placing it?',
  'Placed bets generally cannot be cancelled. Some operators offer a cash-out option on '
  'selected markets, which settles a bet early at a value they offer at that moment. '
  'Availability varies. ' + CHECK,
  ['cancel', 'undo', 'remove bet', 'cash out'], ['page_bet_history'], 'high', True)

F('BETTING', 'Where can I see my bet history?',
  'Your bet history is in the account section and lists placed bets with stake, selection and '
  'current status.',
  ['bet history', 'my bets', 'past bets', 'record'], ['page_bet_history'], 'high')

F('BETTING', 'What does a pending bet mean?',
  'A pending bet has been accepted but the event or market has not yet been settled. It moves '
  'to settled once the result is confirmed.',
  ['pending', 'open', 'unsettled', 'waiting'], ['page_bet_history'], 'medium')

F('BETTING', 'What does a settled bet mean?',
  'A settled bet has been resolved against the official result and any return has been applied '
  'to your balance.',
  ['settled', 'resolved', 'closed', 'finished'], ['page_bet_history'], 'medium')

F('BETTING', 'Why was my bet rejected?',
  'Bets are commonly rejected when odds or the market changed before the bet registered, the '
  'market closed, the stake was outside the accepted limits, or the balance was insufficient. '
  'The rejection message usually names the reason.',
  ['rejected', 'declined', 'not accepted', 'failed'],
  ['page_bet_history', 'page_contact_support'], 'high')

F('BETTING', 'Why did the odds change before my bet was placed?',
  'Odds move in response to market activity, and in-play odds can change very quickly. If odds '
  'change between selection and confirmation, the bet may be re-quoted or rejected depending on '
  'your accept-changes setting.',
  ['odds changed', 'price', 'moved'], ['page_sports'], 'medium')

F('BETTING', 'When will my bet be settled?',
  'Settlement follows confirmation of the official result for that event. Some markets settle '
  'immediately, others wait for an official confirmation. If a bet stays unsettled well after '
  'the event ended, contact support.',
  ['settle', 'when', 'result', 'payout'], ['page_bet_history', 'page_contact_support'], 'medium')

F('BETTING', 'What happens if an event is cancelled or abandoned?',
  'Void and abandonment rules are defined in the sports betting rules and vary by sport and '
  'market. ' + CHECK,
  ['cancelled', 'abandoned', 'void', 'postponed'], ['page_terms', 'page_contact_support'], 'medium', True)

F('BETTING', 'I think my bet was settled incorrectly.',
  'Contact support with the bet reference from your bet history. Settlement is checked against '
  'the official result source, and corrections are made where an error is confirmed.',
  ['wrong', 'incorrect', 'dispute', 'error'],
  ['page_bet_history', 'page_contact_support'], 'high')

F('BETTING', 'What is a bet slip?',
  'The bet slip is the panel that collects your selections before you place them. It shows each '
  'selection, lets you enter a stake, and displays the combined odds and potential return.',
  ['bet slip', 'slip', 'selections'], ['page_sports'], 'medium')

F('BETTING', 'What is an accumulator?',
  'An accumulator combines several selections into one bet. Every selection must win for the bet '
  'to return; if any one loses, the whole bet loses. Combining selections increases both the '
  'potential return and the chance of losing the bet.',
  ['accumulator', 'acca', 'parlay', 'multi', 'combo'], ['page_sports'], 'medium')

F('BETTING', 'What does "in-play" betting mean?',
  'In-play (or live) betting is placing bets after an event has started, with odds updating as '
  'the event progresses. Markets can suspend without warning when something significant happens.',
  ['in play', 'live betting', 'during match'], ['page_sports'], 'medium')

F('BETTING', 'Is there a maximum stake?',
  'Stake limits vary by market and are enforced when you place the bet. The applicable maximum '
  'is shown if your stake exceeds it. ' + CHECK,
  ['maximum stake', 'limit', 'max bet'], ['page_sports', 'page_terms'], 'medium', True)

# ======================================================================
# GAMES
# ======================================================================
F('GAMES', 'How do I find a specific game?',
  'Use the search box in the games or casino lobby, or browse by category. You can also ask me '
  'for a game by name and I will take you to it.',
  ['find', 'search', 'locate', 'game'], ['page_games', 'page_casino'], 'high')

F('GAMES', 'What game categories are available?',
  'Games are grouped into categories such as slots, table games, live casino and crash games. '
  'The lobby shows the full set of categories currently available to you.',
  ['categories', 'types', 'sections'], ['page_games', 'page_casino'], 'medium')

F('GAMES', 'Where do I find the rules for a game?',
  'Each game has an information or paytable panel inside the game itself, which is the '
  'authoritative source for that game\'s rules and payouts. Summaries are also shown on the '
  'game detail page.',
  ['rules', 'how to play', 'paytable', 'info'], ['page_game_detail', 'page_help'], 'high')

F('GAMES', 'Can I try a game without staking money?',
  'Where a demo or practice mode is offered, it appears as an option on the game. Availability '
  'differs by game and by jurisdiction. ' + CHECK,
  ['demo', 'free play', 'practice', 'try'], ['page_games'], 'medium', True)

F('GAMES', 'Why is a game unavailable to me?',
  'A game can be unavailable because it is under maintenance, has been withdrawn by the '
  'provider, or is not licensed for your region. The lobby only lists games available to your '
  'account.',
  ['unavailable', 'missing', 'not working', 'blocked'],
  ['page_games', 'page_contact_support'], 'medium')

F('GAMES', 'How are game results decided?',
  'Casino game outcomes are produced by a random number generator. Each round is independent, '
  'so previous results have no influence on the next one.',
  ['rng', 'random', 'fair', 'results'], ['page_help', 'page_responsible_gaming'], 'high')

F('GAMES', 'What does RTP mean?',
  'RTP ("return to player") is a theoretical figure calculated by the game provider over a very '
  'large number of rounds. It describes long-run modelled behaviour of the game — it is not a '
  'prediction of any session and does not indicate what you will get back. Each game publishes '
  'its own figure in its info panel.',
  ['rtp', 'return to player', 'percentage'], ['page_game_detail'], 'medium')

F('GAMES', 'What does volatility mean?',
  'Volatility is a descriptive label the provider assigns to how a game\'s results tend to be '
  'distributed. It is a description of the game\'s design, not a forecast, and it does not tell '
  'you what any individual session will do.',
  ['volatility', 'variance', 'risk'], ['page_game_detail'], 'low')

F('GAMES', 'My game froze or disconnected mid-round. What happens?',
  'Most providers restore an interrupted round when you reopen the game, and unresolved rounds '
  'are settled according to the provider\'s rules. If a round or balance still looks wrong after '
  'reopening, contact support with the approximate time.',
  ['froze', 'disconnected', 'crashed', 'stuck'],
  ['page_contact_support', 'page_help'], 'high')

F('GAMES', 'Is there a strategy that guarantees winning?',
  'No. Game outcomes are randomly generated and independent, so no strategy, betting pattern or '
  'system can predict or influence results, and none can guarantee a return. Treat any claim '
  'otherwise — including paid "systems" — as false.',
  ['strategy', 'system', 'guaranteed', 'trick', 'hack'],
  ['page_responsible_gaming'], 'high')

F('GAMES', 'What are live casino games?',
  'Live casino games are hosted by a human dealer and streamed in real time, with bets placed '
  'through the interface. They follow the same published rules as the equivalent table game.',
  ['live casino', 'live dealer', 'streaming'], ['page_live_casino'], 'medium')

F('GAMES', 'How do crash games work?',
  'In a crash game a multiplier rises during a round and stops at a randomly determined point. '
  'Cashing out before it stops settles the stake at the multiplier shown at that instant. If '
  'the round ends first, that round\'s stake is lost.',
  ['crash', 'aviator', 'multiplier', 'cash out'],
  ['category_crash_games', 'page_game_detail'], 'high')

# ======================================================================
# PROMOTIONS
# ======================================================================
F('PROMOTIONS', 'Where can I see current promotions?',
  'Active promotions are listed on the promotions page, each with its own terms.',
  ['promotions', 'offers', 'deals', 'current'], ['page_promotions'], 'high')

F('PROMOTIONS', 'Am I eligible for a promotion?',
  'Eligibility conditions are stated in each promotion\'s own terms and can depend on factors '
  'such as account status, region and previous participation. The promotion page shows whether '
  'you qualify.',
  ['eligible', 'qualify', 'eligibility'], ['page_promotions', 'page_bonuses'], 'high', True)

F('PROMOTIONS', 'What are wagering requirements?',
  'A wagering requirement is the amount that must be staked, under the promotion\'s conditions, '
  'before funds connected to a bonus can be withdrawn. The multiplier, qualifying games and time '
  'limit are set out in each promotion\'s terms.',
  ['wagering', 'playthrough', 'rollover', 'requirement'], ['page_bonuses'], 'high', True)

F('PROMOTIONS', 'How do I claim a bonus?',
  'Claim steps are on the promotion itself — some apply automatically, others need an opt-in or '
  'a code entered at deposit. Read the terms before claiming, since a bonus can restrict '
  'withdrawals until its conditions are met.',
  ['claim', 'activate', 'opt in', 'code'], ['page_promotions', 'page_bonuses'], 'high')

F('PROMOTIONS', 'Why did my bonus expire?',
  'Bonuses carry a validity period stated in their terms, and expire if the conditions are not '
  'met within it. Expired bonuses generally cannot be reinstated.',
  ['expired', 'ended', 'gone', 'validity'], ['page_bonuses'], 'medium', True)

F('PROMOTIONS', 'Can I withdraw while a bonus is active?',
  'Withdrawing with an active bonus can forfeit the bonus and anything derived from it, '
  'depending on its terms. Check the specific bonus before requesting a withdrawal.',
  ['withdraw', 'active bonus', 'forfeit'], ['page_bonuses', 'page_withdraw'], 'high', True)

F('PROMOTIONS', 'Can I cancel a bonus?',
  'Where bonus cancellation is offered it appears in the bonuses section of your account. What '
  'happens to any balance associated with it is defined in the bonus terms.',
  ['cancel bonus', 'remove', 'forfeit'], ['page_bonuses'], 'medium', True)

F('PROMOTIONS', 'Do all games count towards wagering?',
  'Games usually contribute at different rates, and some are excluded entirely. The contribution '
  'table is part of each promotion\'s terms.',
  ['contribution', 'games count', 'excluded'], ['page_bonuses'], 'medium', True)

F('PROMOTIONS', 'Where do I see my active bonuses?',
  'Active bonuses, their remaining requirements and their expiry are shown in the bonuses section '
  'of your account.',
  ['active', 'my bonus', 'status', 'progress'], ['page_bonuses'], 'medium')

# ======================================================================
# TECHNICAL
# ======================================================================
F('TECHNICAL', 'The page will not load. What should I do?',
  'Refresh first, then try clearing the browser cache or opening the site in a private window to '
  'rule out a stale cached file. Switching between wifi and mobile data identifies a network '
  'issue. If it persists across devices, contact support.',
  ['not loading', 'blank', 'stuck', 'slow'], ['page_contact_support'], 'medium')

F('TECHNICAL', 'The app keeps crashing.',
  'Make sure the app is updated to the latest version, restart the device, and check available '
  'storage. If it continues, report it to support with your device model and OS version — that '
  'detail is what makes it reproducible.',
  ['app', 'crash', 'closing', 'freeze'], ['page_contact_support'], 'medium')

F('TECHNICAL', 'A game will not open.',
  'Reload the page and check whether other games open. A single game failing usually points to '
  'maintenance on that game; all games failing points to your connection or session. If it '
  'persists, contact support and name the game.',
  ['game not opening', 'error', 'blank', 'loading'],
  ['page_games', 'page_contact_support'], 'medium')

F('TECHNICAL', 'I keep getting a payment error.',
  'Payment errors usually originate with the payment provider. Check your card or account '
  'details are current, confirm your bank is not blocking gambling transactions, and try an '
  'alternative method. Your bank can give the specific decline reason.',
  ['payment error', 'declined', 'transaction failed'],
  ['page_deposit', 'page_contact_support'], 'high')

F('TECHNICAL', 'My connection keeps dropping during play.',
  'Try a more stable network and close bandwidth-heavy apps. Live and in-play products are the '
  'most sensitive to connection quality. If a round was interrupted, reopen the game — most '
  'providers restore it.',
  ['connection', 'disconnect', 'network', 'unstable'], ['page_contact_support'], 'medium')

F('TECHNICAL', 'My balance looks wrong.',
  'Refresh first, since the display can lag behind a pending transaction. Then check your '
  'transaction history for the entries you expect. If the figures still do not reconcile, '
  'contact support — I cannot see or verify account balances.',
  ['balance', 'wrong', 'missing money', 'incorrect'],
  ['page_transactions', 'page_contact_support'], 'high')

F('TECHNICAL', 'Which browsers are supported?',
  'The site targets current versions of the major browsers. Using an outdated browser is a '
  'frequent cause of layout and playback problems. Specific supported versions are listed in '
  'the help centre. ' + CHECK,
  ['browser', 'supported', 'compatibility'], ['page_help'], 'low', True)

F('TECHNICAL', 'Is there a mobile app?',
  'App availability differs by platform and region. The help centre lists what is available and '
  'the official download source. Only install from official sources — unofficial builds are a '
  'common vector for credential theft.',
  ['app', 'mobile', 'download', 'android', 'ios'], ['page_help'], 'medium', True)

F('TECHNICAL', 'The site looks broken or misaligned.',
  'Clear the cache and hard-refresh, since a partially cached stylesheet is the usual cause. '
  'Also check browser zoom and any extensions such as ad blockers, which can hide elements.',
  ['broken', 'layout', 'display', 'css'], ['page_contact_support'], 'low')

# ======================================================================
# SUPPORT
# ======================================================================
F('SUPPORT', 'How do I contact support?',
  'Support channels are listed on the contact page, and typically include live chat and email. '
  'I can take you there.',
  ['contact', 'support', 'help', 'chat', 'agent'], ['page_contact_support'], 'high')

F('SUPPORT', 'What are support hours?',
  'Operating hours for each channel are published on the contact page. ' + CHECK,
  ['hours', 'available', 'open', 'time'], ['page_contact_support'], 'medium', True)

F('SUPPORT', 'How do I make a complaint?',
  'Complaints are raised through the support channels and follow the published complaints '
  'procedure, which sets out how they are logged, acknowledged and escalated. ' + CHECK,
  ['complaint', 'complain', 'unhappy', 'escalate'],
  ['page_contact_support', 'page_terms'], 'high', True)

F('SUPPORT', 'What if my complaint is not resolved?',
  'Licensed operators publish an escalation route, which commonly includes an independent '
  'dispute resolution body or the regulator. The applicable route is set out in the complaints '
  'policy. ' + CHECK,
  ['unresolved', 'escalate', 'dispute', 'regulator'],
  ['page_terms', 'page_contact_support'], 'high', True)

F('SUPPORT', 'What information should I include when contacting support?',
  'Include your account identifier, the date and time of the issue, and any transaction or bet '
  'reference. Screenshots help. Never send your password — support will never ask for it.',
  ['information', 'details', 'reference', 'what to send'],
  ['page_contact_support'], 'medium')

F('SUPPORT', 'How long does support take to reply?',
  'Response times differ by channel and are published on the contact page. ' + CHECK,
  ['response time', 'how long', 'reply', 'wait'], ['page_contact_support'], 'medium', True)

F('SUPPORT', 'Can support tell me why my account was restricted?',
  'Yes, once they have verified your identity. I cannot access account-specific information, so '
  'restriction reasons always come from support directly.',
  ['restricted', 'reason', 'why', 'blocked'], ['page_contact_support'], 'high')

# ======================================================================
# RESPONSIBLE GAMING
# ======================================================================
F('RESPONSIBLE_GAMING', 'How do I set a deposit limit?',
  'Deposit limits are set in the responsible gaming section of your account. You can normally set '
  'daily, weekly or monthly limits. Lowering a limit typically applies straight away, while '
  'raising one takes effect only after a delay.',
  ['deposit limit', 'limit', 'control', 'budget'], ['page_responsible_gaming'], 'high')

F('RESPONSIBLE_GAMING', 'How do I take a break from gambling?',
  'The responsible gaming section offers time-out and self-exclusion options. A time-out is a '
  'short cooling-off period; self-exclusion is a longer, stricter block that generally cannot be '
  'reversed before it ends.',
  ['break', 'time out', 'cool off', 'pause', 'stop'], ['page_responsible_gaming'], 'high')

F('RESPONSIBLE_GAMING', 'What is self-exclusion?',
  'Self-exclusion blocks access to your account for a period you choose. It is designed not to be '
  'reversible during that period, which is the point of it. Details of durations and scope are on '
  'the responsible gaming page.',
  ['self exclusion', 'exclude', 'block', 'ban'], ['page_responsible_gaming'], 'high', True)

F('RESPONSIBLE_GAMING', 'How do I know if gambling is becoming a problem?',
  'Common warning signs include spending more than you planned, chasing losses, gambling to '
  'escape stress, hiding it from people close to you, or borrowing to fund it. If any of these '
  'sound familiar, support is available — the responsible gaming page lists tools and independent '
  'organisations that help confidentially and free of charge.',
  ['problem', 'addiction', 'help', 'signs', 'control'], ['page_responsible_gaming'], 'high')

F('RESPONSIBLE_GAMING', 'Can I set a limit on how long I play?',
  'Where session or reality-check tools are offered, they are in the responsible gaming section. '
  'A reality check interrupts play at an interval you choose to show how long you have been on.',
  ['time limit', 'session', 'reality check', 'duration'], ['page_responsible_gaming'], 'medium', True)

F('RESPONSIBLE_GAMING', 'Can I get my losses back?',
  'No. Bets that have been settled stand, and losses cannot be reversed or refunded. If you are '
  'trying to recover losses, that is one of the clearest warning signs of harm — the responsible '
  'gaming page lists free, confidential support.',
  ['losses', 'refund', 'get back', 'recover', 'chasing'],
  ['page_responsible_gaming', 'page_contact_support'], 'high')

F('RESPONSIBLE_GAMING', 'Is gambling a way to make money?',
  'No. Gambling is a form of paid entertainment, not a source of income. Games are designed so '
  'that outcomes are random and the operator retains a margin over time. Only ever stake money '
  'you can afford to lose.',
  ['make money', 'income', 'profit', 'earn', 'job'], ['page_responsible_gaming'], 'high')

F('RESPONSIBLE_GAMING', 'What is the minimum age to gamble?',
  'A minimum legal age applies and is verified during registration and KYC. The exact age depends '
  'on your jurisdiction and is stated in the terms. Accounts found to belong to under-age users '
  'are closed.',
  ['age', 'minimum age', '18', 'underage'], ['page_terms', 'page_responsible_gaming'], 'high', True)

F('RESPONSIBLE_GAMING', 'Where can I get independent help?',
  'The responsible gaming page lists independent organisations that provide free and confidential '
  'support, separately from the operator. If you are in immediate crisis, contact your local '
  'emergency services.',
  ['help', 'support', 'counselling', 'helpline', 'independent'],
  ['page_responsible_gaming'], 'high')


def main():
    path = os.path.normpath(os.path.join(OUT, 'rag/faq.json'))
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(rows, f, ensure_ascii=False, indent=2)

    from collections import Counter
    by_cat = Counter(r['category'] for r in rows)
    verify = sum(1 for r in rows if r['requires_verified_source'])

    print(f'  rag/faq.json{"":28s} {len(rows):4d} records')
    for c, n in sorted(by_cat.items(), key=lambda x: -x[1]):
        print(f'    {c:22s} {n:3d}')
    print(f'\n  flagged requires_verified_source: {verify} '
          f'({verify * 100 // len(rows)}% — these must not state specifics until '
          f'your real policy is loaded)')


if __name__ == '__main__':
    main()
