/**
 * normalize.js — query normalisation and fuzzy string matching.
 *
 * Everything here is deterministic and dependency-free. Most navigation traffic
 * is resolved by these functions without any model call.
 */

/** Latin transliterations of common Hindi/Telugu command words. */
const COMMAND_WORDS = {
  // Hindi / Hinglish
  kholo: 'open', kholna: 'open', khol: 'open',
  dikhao: 'show', dikha: 'show', dikhaao: 'show',
  karo: '', karna: '', kare: '', kar: '',
  chahiye: 'want', chaiye: 'want',
  jao: 'go', chalo: 'go', 'le': '', leke: '', wahan: 'there',
  mujhe: 'me', mera: 'my', meri: 'my', mere: 'my',
  hai: '', hain: '', kya: '', ka: '', ki: '', ke: '', ko: '', se: '',
  wala: '', wale: '', wali: '',
  kaise: 'how', kyu: 'why', kyun: 'why', kitna: 'how much', kaha: 'where',
  paisa: 'money', paise: 'money', rupaye: 'money',
  nikalo: 'withdraw', nikalna: 'withdraw', jama: 'deposit', dalo: 'deposit',
  dalna: 'deposit', band: 'stop', rokna: 'stop', madad: 'help',
  khelna: 'play', khelte: 'play', khel: 'play', satta: 'betting',
  // Telugu
  cheyyi: '', cheyyandi: '', cheyyali: '', chupinchu: 'show', chudu: 'show',
  kavali: 'want', teesukellu: 'take me', teesuko: 'take', teesukovali: 'withdraw',
  vesali: 'deposit', vesaru: 'deposit', dabbu: 'money', aatalu: 'games',
  vimanam: 'plane', sahayam: 'help', ela: 'how', aadali: 'play',
  akkada: 'there', adi: 'that', ni: '', na: 'my', unnaya: 'are there',
};

/** Strip diacritics and lowercase. */
export function fold(s) {
  return String(s || '')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[čć]/g, 'c')
    .replace(/đ/g, 'd')
    .replace(/š/g, 's')
    .replace(/ž/g, 'z');
}

/** Full normalisation: fold, strip punctuation, collapse whitespace. */
export function normalize(s) {
  return fold(s)
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Tokenise into words. */
export function tokens(s) {
  return normalize(s).split(' ').filter(Boolean);
}

/**
 * Translate command words to their English equivalent so a mixed-language
 * query becomes searchable against English aliases.
 * "aviator kholo" -> "aviator open"
 */
export function translateCommands(s) {
  const out = [];
  let translated = 0;
  for (const t of tokens(s)) {
    if (Object.prototype.hasOwnProperty.call(COMMAND_WORDS, t)) {
      translated++;
      const rep = COMMAND_WORDS[t];
      if (rep) out.push(rep);
    } else {
      out.push(t);
    }
  }
  return { text: out.join(' ').trim(), translatedCount: translated };
}

/** Rough language hint from the command words present. */
export function detectLanguage(s) {
  const t = tokens(s);
  const hi = ['kholo', 'dikhao', 'karo', 'chahiye', 'mujhe', 'mera', 'meri', 'paisa',
    'nikalna', 'jama', 'kaise', 'kyu', 'kitna', 'hai', 'wala', 'khelna', 'madad'];
  const te = ['cheyyi', 'chupinchu', 'kavali', 'teesukellu', 'dabbu', 'vimanam',
    'sahayam', 'ela', 'aadali', 'akkada', 'vesali', 'teesukovali'];
  const hiHits = t.filter((x) => hi.includes(x)).length;
  const teHits = t.filter((x) => te.includes(x)).length;
  const enHits = t.length - hiHits - teHits;

  if (teHits > 0) return enHits > 0 ? 'mixed_te' : 'te_latin';
  if (hiHits > 0) return enHits > 0 ? 'hinglish' : 'hi_latin';
  return 'en';
}

/** Character trigrams, used for fuzzy alias matching. */
export function trigrams(s) {
  const p = `  ${normalize(s)} `;
  const out = new Set();
  for (let i = 0; i < p.length - 2; i++) out.add(p.slice(i, i + 3));
  return out;
}

/** Dice coefficient over trigram sets — 0..1, tolerant of typos. */
export function trigramSimilarity(a, b) {
  const A = trigrams(a);
  const B = trigrams(b);
  if (!A.size || !B.size) return 0;
  let shared = 0;
  for (const g of A) if (B.has(g)) shared++;
  return (2 * shared) / (A.size + B.size);
}

/** Levenshtein distance, capped for short strings. */
export function levenshtein(a, b) {
  a = normalize(a);
  b = normalize(b);
  if (a === b) return 0;
  if (!a.length) return b.length;
  if (!b.length) return a.length;

  let prev = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    const cur = [i];
    for (let j = 1; j <= b.length; j++) {
      cur[j] = Math.min(
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + (a[i - 1] === b[j - 1] ? 0 : 1)
      );
    }
    prev = cur;
  }
  return prev[b.length];
}

/** Normalised edit similarity, 0..1. */
export function editSimilarity(a, b) {
  const max = Math.max(normalize(a).length, normalize(b).length);
  if (!max) return 0;
  return 1 - levenshtein(a, b) / max;
}

export default { fold, normalize, tokens, translateCommands, detectLanguage,
  trigrams, trigramSimilarity, levenshtein, editSimilarity };
