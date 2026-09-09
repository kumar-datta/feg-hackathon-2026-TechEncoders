/**
 * intent.js — intent classification.
 *
 * Rules first, model second. The rule layer is deterministic, instant and
 * testable; the LLM is consulted only when the rules are not confident. That
 * keeps the common path fast and keeps behaviour predictable under load.
 */
import { normalize, translateCommands, tokens } from './normalize.js';
import { chat } from './llm.js';
import config from './config.js';

/** Ordered — the first matching rule wins, so safety rules sit at the top. */
const RULES = [
  // ---- responsible gaming outranks everything, including navigation ----
  { intent: 'RESPONSIBLE_GAMING', conf: 0.97, any: [
    'self exclude', 'self exclusion', 'selfexclusion', 'take a break', 'time out',
    'deposit limit', 'set a limit', 'limit my', 'stop gambling', 'stop playing',
    'gambling problem', 'addicted', 'addiction', 'block my account',
    'cant stop', 'cannot stop', 'chasing losses', 'lost too much',
    'responsible gaming', 'responsible gambling', 'gambling help',
  ]},
  { intent: 'RESPONSIBLE_GAMING', conf: 0.95, all: [['losing'], ['keep', 'cant', 'lot', 'all']] },

  // ---- questions beat navigation keywords -------------------------------
  // "why is my deposit pending" is a question ABOUT deposits, not a request to
  // open the deposit page. This rule must sit above the financial rules.
  { intent: 'GAME_INFO', conf: 0.92, any: [
    'how does', 'how do i play', 'how to play', 'how are results', 'rules of',
    'explain the', 'what is a crash', 'kaise khel', 'ela aadali', 'kaise khelte',
  ]},
  { intent: 'FAQ', conf: 0.90, all: [
    ['why', 'how', 'what', 'when', 'can', 'do', 'does', 'is', 'kyu', 'kaise', 'kitna', 'ela'],
    ['pending', 'failed', 'rejected', 'declined', 'stuck', 'long', 'minimum', 'maximum',
     'limit', 'fee', 'fees', 'need', 'required', 'take', 'happen', 'happens',
     'mean', 'means', 'eligible', 'cancel', 'change', 'reset', 'verify', 'contact'],
  ]},

  // ---- account data: must go to the API, never RAG ----
  { intent: 'ACCOUNT_DATA', conf: 0.93, any: [
    'my balance', 'account balance', 'how much do i have', 'how much money',
    'my winnings', 'did my withdrawal', 'is my kyc approved', 'my kyc status',
    'my last deposit', 'how much did i win', 'how much did i lose',
  ]},

  // ---- financial navigation ----
  { intent: 'DEPOSIT', conf: 0.94, any: [
    'deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge',
    'paisa dalo', 'paisa dalna', 'paise jama', 'dabbu vesali', 'fund my account',
  ]},
  { intent: 'WITHDRAW', conf: 0.94, any: [
    'withdraw', 'withdrawl', 'withdrawal', 'cash out', 'cashout', 'payout',
    'paisa nikalo', 'paisa nikalna', 'take out my money', 'dabbu teesuko',
  ]},

  // ---- account areas ----
  { intent: 'BET_HISTORY', conf: 0.94, any: [
    'bet history', 'my bets', 'past bets', 'previous bets', 'betting history',
    'bet dikhao', 'na bets',
  ]},
  { intent: 'KYC', conf: 0.94, any: [
    'kyc', 'verify my account', 'verification', 'upload document', 'identity check',
  ]},
  { intent: 'ACCOUNT', conf: 0.90, any: [
    'my profile', 'my account', 'account settings', 'change password', 'my wallet',
    'transaction history', 'notifications',
  ]},

  // ---- support ----
  { intent: 'SUPPORT', conf: 0.93, any: [
    'contact support', 'customer support', 'customer care', 'live chat', 'talk to agent',
    'talk to someone', 'complaint', 'complain', 'helpline', 'support se baat',
  ]},

  // ---- promotions ----
  { intent: 'PROMOTION', conf: 0.90, any: [
    'promotion', 'promo', 'offer', 'bonus', 'deals', 'free spin', 'wagering',
  ]},

  // ---- informational about games ----
  { intent: 'GAME_INFO', conf: 0.90, any: [
    'how does', 'how do i play', 'how to play', 'rules of', 'explain', 'what is',
    'what does', 'kaise khel', 'ela aadali', 'terminology', 'how are results',
  ]},

  // ---- navigation verbs ----
  { intent: 'NAVIGATE', conf: 0.88, any: [
    'open', 'take me', 'go to', 'show me', 'launch', 'start', 'play',
    'kholo', 'dikhao', 'le chalo', 'leke jao', 'cheyyi', 'chupinchu', 'teesukellu',
  ]},

  // ---- search ----
  { intent: 'SEARCH', conf: 0.80, any: [
    'find', 'search', 'list', 'what games', 'do you have', 'any games',
  ]},

  // ---- FAQ signals ----
  { intent: 'FAQ', conf: 0.82, any: [
    'why is', 'why was', 'how long', 'how many', 'can i', 'do i need',
    'what happens', 'is there', 'minimum', 'maximum', 'pending', 'failed', 'rejected',
    'kitna time', 'kyu',
  ]},
];

function matches(rule, text, toks) {
  if (rule.any && rule.any.some((p) => text.includes(p))) return true;
  if (rule.all) {
    return rule.all.every((group) => group.some((w) => toks.includes(w) || text.includes(w)));
  }
  return false;
}

/** Bare tokens that map to two or more plausible destinations. */
const AMBIGUOUS_TOKENS = new Set([
  'money', 'paisa', 'paise', 'dabbu', 'bonus', 'history', 'limits', 'limit',
  'cards', 'game', 'games', 'open', 'show', 'bet', 'bets', 'live', 'table',
  'account', 'sports', 'casino', 'play', 'next', 'kholo', 'dikhao', 'verify',
  'help me', 'go back', 'cancel it', 'how much',
]);

export function isAmbiguousToken(query) {
  const q = normalize(query);
  if (!q) return false;
  return AMBIGUOUS_TOKENS.has(q);
}

/** Fast deterministic pass. */
export function classifyRules(query) {
  if (isAmbiguousToken(query)) {
    return { intent: 'AMBIGUOUS', confidence: 0.3, method: 'ambiguous_token' };
  }
  const raw = normalize(query);
  const { text: translated } = translateCommands(query);
  const text = `${raw} ${translated}`;
  const toks = tokens(text);

  for (const rule of RULES) {
    if (matches(rule, text, toks)) {
      return { intent: rule.intent, confidence: rule.conf, method: 'rules' };
    }
  }
  return { intent: 'UNKNOWN', confidence: 0.25, method: 'rules' };
}

const VALID = new Set(['NAVIGATE', 'SEARCH', 'GAME_INFO', 'FAQ', 'DEPOSIT', 'WITHDRAW',
  'BET_HISTORY', 'ACCOUNT', 'ACCOUNT_DATA', 'KYC', 'PROMOTION', 'SUPPORT',
  'RESPONSIBLE_GAMING', 'AMBIGUOUS', 'UNKNOWN']);

const SYSTEM = `You classify user messages for a betting website assistant.
Reply with ONLY one label from this list, nothing else:
NAVIGATE SEARCH GAME_INFO FAQ DEPOSIT WITHDRAW BET_HISTORY ACCOUNT ACCOUNT_DATA KYC PROMOTION SUPPORT RESPONSIBLE_GAMING AMBIGUOUS UNKNOWN

Guidance:
- NAVIGATE: user wants to be taken to a specific page or game.
- GAME_INFO: user asks how a game works or its rules.
- FAQ: general how/why question about the service.
- ACCOUNT_DATA: asks for their own balance, bets, or verification status.
- RESPONSIBLE_GAMING: any sign of gambling harm, limits, or self-exclusion. Prefer this label whenever it is plausible.
- AMBIGUOUS: too vague to act on.
Messages may be in English, Hindi or Telugu written in Latin script.`;

/**
 * Classify with rules, escalating to the model only when rules are unsure.
 */
export async function classify(query) {
  const ruled = classifyRules(query);
  if (ruled.confidence >= 0.85 || !config.enabled) return ruled;

  const out = await chat({
    system: SYSTEM,
    messages: [{ role: 'user', content: query }],
    temperature: 0,
    // Reasoning models (gpt-oss, o-series, some Qwen builds) spend tokens on
    // hidden reasoning before emitting text. A tight cap makes them return an
    // empty string, which silently disables the classifier — so budget for it.
    maxTokens: 220,
  });

  if (!out) return ruled;

  // Extract the first valid label anywhere in the output rather than assuming
  // the whole response is the label.
  const label = (out.toUpperCase().match(/\b[A-Z_]{3,20}\b/g) || [])
    .find((token) => VALID.has(token));
  if (!label) return ruled;

  // trust the model a little more than an unsure rule, but never treat it as certain
  return { intent: label, confidence: Math.max(ruled.confidence, 0.8), method: 'llm' };
}

export default { classify, classifyRules };
