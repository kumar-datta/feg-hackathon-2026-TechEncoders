/**
 * gen_from_site.mjs — builds the navigation registry FROM THE ACTUAL SITE.
 *
 * The hand-written entities.json was generic gambling-site data: it pointed at
 * /games/aviator and /sports/cricket, neither of which exists here. That makes
 * the assistant confidently navigate to 404s.
 *
 * This reads the real routes out of client/src/App.jsx and the real catalogue
 * out of the running API, so every entity_id maps to a route that exists.
 *
 *   node ai-assistant/tools/gen_from_site.mjs
 *
 * Requires the API to be running (npm run server).
 */
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(HERE, '../..');
const DATA = path.resolve(HERE, '../data/navigation');
const API = process.env.API || 'http://localhost:5000/api';

const slugify = (s) => s.toLowerCase()
  .replace(/[čć]/g, 'c').replace(/đ/g, 'd').replace(/š/g, 's').replace(/ž/g, 'z')
  .replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');

async function get(p) {
  const r = await fetch(API + p);
  if (!r.ok) throw new Error(`${p} -> ${r.status}`);
  return r.json();
}

/** Confirm a route actually exists in the router. */
async function realRoutes() {
  const src = await fs.readFile(path.join(ROOT, 'client/src/App.jsx'), 'utf-8');
  return new Set([...src.matchAll(/path="([^"]+)"/g)].map((m) => m[1]));
}

const E = (o) => ({
  status: 'active', requires_auth: false, requires_kyc: false,
  data_status: 'GENERATED_FROM_LIVE_SITE', ...o,
});

/* ------------------------------------------------------------------
   Static pages — these mirror App.jsx exactly
   ------------------------------------------------------------------ */
const PAGES = [
  ['page_home', 'Home', '/', 'Navigation', null,
    ['home', 'homepage', 'main page', 'naslovna', 'ghar', 'start page'], ['home', 'landing']],
  ['page_sportsbook', 'Sportsbook', '/oklade', 'Sports', 'page_home',
    ['sports', 'sportsbook', 'betting', 'oklade', 'ponuda', 'sports betting', 'match betting',
     'sports dikhao', 'khel satta', 'bet on sports'], ['sports', 'betting', 'odds', 'oklade']],
  ['page_live_betting', 'Live Betting', '/oklade?filter=live', 'Sports', 'page_sportsbook',
    ['live', 'live betting', 'in play', 'inplay', 'uzivo', 'zivo', 'live odds', 'live matches'],
    ['live', 'in-play', 'uzivo']],
  ['page_casino', 'Casino', '/casino', 'Casino', 'page_home',
    ['casino', 'casino lobby', 'slots', 'casino games', 'casino kholo', 'casino dikhao'],
    ['casino', 'slots', 'games', 'lobby']],
  ['page_live_casino', 'Live Casino', '/live-casino', 'Casino', 'page_casino',
    ['live casino', 'live dealer', 'live tables', 'zivi casino', 'real dealer'],
    ['live', 'dealer', 'tables']],
  ['page_providers', 'Providers', '/provideri', 'Casino', 'page_casino',
    ['providers', 'provideri', 'game providers', 'studios'], ['provider', 'studio']],
  ['page_loto', 'Lottery', '/loto', 'Lottery', 'page_home',
    ['loto', 'lotto', 'lottery', 'numbers game', 'keno', 'bingo', 'loto dikhao'],
    ['loto', 'lottery', 'numbers', 'draw']],
  ['page_virtuals', 'Virtual Games', '/virtualne-igre', 'Virtual', 'page_home',
    ['virtual', 'virtuals', 'virtual games', 'virtualne igre', 'simulated games'],
    ['virtual', 'simulated', 'races']],
  ['page_swipe', 'Swipe & Bet', '/swipe-and-bet', 'Sports', 'page_home',
    ['swipe', 'swipe and bet', 'swipe bet', 'quick bet'], ['swipe', 'quick']],
  ['page_arena', 'Arena', '/arena', 'Community', 'page_home',
    ['arena', 'shared tickets', 'community tickets', 'psk arena'], ['arena', 'shared']],
  ['page_promotions', 'Promotions', '/promocije', 'Promotions', 'page_home',
    ['promotions', 'promocije', 'promo', 'offers', 'deals', 'bonus', 'bonuses',
     'offer dikhao', 'koi bonus hai'], ['promotions', 'offers', 'bonus']],
  ['page_forum', 'Forum', '/forum', 'Community', 'page_home',
    ['forum', 'community', 'discussion', 'threads'], ['forum', 'community']],
  ['page_results', 'Results', '/rezultati', 'Sports', 'page_home',
    ['results', 'rezultati', 'scores', 'match results'], ['results', 'scores']],
  ['page_statistics', 'Statistics', '/statistika', 'Sports', 'page_home',
    ['statistics', 'statistika', 'stats'], ['statistics', 'stats']],
  ['page_news', 'News', '/novosti', 'Content', 'page_home',
    ['news', 'novosti', 'articles', 'analysis'], ['news', 'articles']],
  ['page_shops', 'Shops', '/poslovnice', 'Info', 'page_home',
    ['shops', 'poslovnice', 'branches', 'locations', 'betting shops'], ['shops', 'locations']],
  ['page_mobile_app', 'Mobile App', '/mobilna-aplikacija', 'Info', 'page_home',
    ['app', 'mobile app', 'download', 'android', 'ios', 'mobilna aplikacija'],
    ['app', 'mobile', 'download']],
  ['page_champions_club', 'Champions Club', '/klub-prvaka', 'Promotions', 'page_home',
    ['champions club', 'klub prvaka', 'loyalty', 'vip', 'tiers', 'points'],
    ['loyalty', 'club', 'tiers']],
  ['page_search', 'Search', '/pretraga', 'Navigation', 'page_home',
    ['search', 'pretraga', 'find'], ['search', 'find']],
  ['page_login', 'Login', '/prijava', 'Account', 'page_home',
    ['login', 'log in', 'sign in', 'prijava', 'login karo'], ['login', 'signin']],
  ['page_register', 'Register', '/registracija', 'Account', 'page_home',
    ['register', 'sign up', 'registracija', 'create account', 'new account'],
    ['register', 'signup']],
  ['page_account', 'My Account', '/racun', 'Account', 'page_home',
    ['account', 'my account', 'profile', 'racun', 'wallet', 'balance', 'my profile',
     'account settings', 'profile kholo'], ['account', 'profile', 'wallet'], true],
  ['page_deposit', 'Deposit', '/racun#deposit', 'Account', 'page_account',
    ['deposit', 'add money', 'add funds', 'top up', 'topup', 'recharge', 'paisa dalo',
     'deposit karo', 'paise jama karo', 'dabbu vesali', 'add credits'],
    ['deposit', 'add', 'funds'], true],
  ['page_limits', 'Play Limits', '/racun#limiti', 'Responsible', 'page_account',
    ['limits', 'deposit limit', 'set limit', 'play limits', 'limit set karo', 'spending limit'],
    ['limits', 'control'], true],
  ['page_self_exclusion', 'Self-Exclusion', '/racun#samoiskljucenje', 'Responsible', 'page_account',
    ['self exclusion', 'self exclude', 'block my account', 'take a break', 'exclude me',
     'gambling band karo'], ['self-exclusion', 'break', 'block'], true],
  ['page_tickets', 'My Tickets', '/listici', 'Account', 'page_home',
    ['tickets', 'my tickets', 'listici', 'bet history', 'my bets', 'betting history',
     'past bets', 'mera bet history dikhao', 'na bets chupinchu'],
    ['tickets', 'bets', 'history'], true],
  ['page_checkout', 'Checkout', '/checkout', 'Account', 'page_home',
    ['checkout', 'confirm bet', 'place bet', 'bet slip'], ['checkout', 'confirm'], true],
  ['page_help', 'Help', '/pomoc', 'Support', 'page_home',
    ['help', 'pomoc', 'faq', 'help center', 'support articles', 'madad', 'sahayam'],
    ['help', 'faq', 'support']],
  ['page_contact', 'Contact Support', '/kontakt', 'Support', 'page_help',
    ['contact', 'contact support', 'support', 'customer care', 'agent', 'complaint',
     'support se baat karao', 'live chat'], ['contact', 'support', 'agent']],
  ['page_about', 'About', '/o-nama', 'Info', 'page_home',
    ['about', 'about us', 'o nama', 'about the project'], ['about', 'info']],
  ['page_rules', 'Game Rules', '/pravila-igre', 'Policy', 'page_home',
    ['rules', 'game rules', 'terms', 'pravila igre', 'terms and conditions', 'tnc'],
    ['rules', 'terms']],
  ['page_responsible_gaming', 'Responsible Gaming', '/odgovorno-igranje', 'Responsible', 'page_home',
    ['responsible gaming', 'responsible gambling', 'odgovorno igranje', 'safer gambling',
     'gambling help', 'addiction help', 'stop gambling', 'problem gambling'],
    ['responsible', 'safer', 'help']],
  ['page_privacy', 'Privacy Policy', '/pravila-privatnosti', 'Policy', 'page_home',
    ['privacy', 'privacy policy', 'data policy', 'pravila privatnosti', 'gdpr'],
    ['privacy', 'data']],
];

async function main() {
  const routes = await realRoutes();
  const entities = [];
  const problems = [];

  const checkRoute = (route, id) => {
    const base = route.split(/[?#]/)[0];
    if (!routes.has(base)) problems.push(`${id} -> ${route} (no such route in App.jsx)`);
  };

  // ---- static pages ----
  for (const [id, name, route, category, parent, aliases, keywords, auth] of PAGES) {
    checkRoute(route, id);
    entities.push(E({
      id, type: 'PAGE', name, aliases,
      description: `${name} page of the site.`,
      category, parent_id: parent, route, keywords,
      requires_auth: Boolean(auth),
    }));
  }

  // ---- sports (real slugs, real query-string route) ----
  const { sports } = await get('/offer/sports');
  const SPORT_ALIASES = {
    nogomet: ['football', 'soccer', 'futbol', 'football betting'],
    kosarka: ['basketball', 'nba', 'basket'],
    tenis: ['tennis', 'atp', 'wta'],
    rukomet: ['handball'],
    odbojka: ['volleyball'],
    hokej: ['hockey', 'ice hockey', 'nhl'],
    esport: ['esports', 'e sport', 'gaming', 'cs2', 'lol', 'dota'],
    boks: ['boxing'],
    mma: ['ufc', 'mixed martial arts'],
    'formula-1': ['f1', 'formula one', 'racing'],
    pikado: ['darts'],
    snooker: ['snooker', 'pool'],
    golf: ['golf'],
    biciklizam: ['cycling'],
    'am-nogomet': ['american football', 'nfl'],
    bejzbol: ['baseball', 'mlb'],
    vaterpolo: ['water polo'],
    sah: ['chess'],
    futsal: ['futsal'],
    badminton: ['badminton'],
    'konjicke-utrke': ['horse racing', 'horses', 'racing', 'ghoda race'],
  };

  for (const s of sports) {
    const id = `sport_${s.slug}`;
    const route = `/oklade?sport=${s.slug}`;
    entities.push(E({
      id, type: 'SPORT', name: s.name,
      aliases: [s.slug, s.name.toLowerCase(), ...(SPORT_ALIASES[s.slug] || []),
        `${s.name.toLowerCase()} betting`, `${s.slug} dikhao`],
      description: `${s.name} betting markets (${s.count} events).`,
      category: 'Sports', parent_id: 'page_sportsbook', route,
      keywords: [s.slug, 'betting', 'odds'],
    }));
  }

  // ---- games: table/instant games get their own entity ----
  const { games: allGames } = await get('/casino/games?limit=500');
  const { games: liveGames } = await get('/casino/games?live=true&limit=50');

  const notable = allGames.filter((g) => g.engine !== 'slot');
  const GAME_ALIASES = {
    'aviator-rush': ['aviator', 'plane game', 'plane wala game', 'aviater', 'avaitor',
      'udne wala game', 'vimanam game', 'crash plane', 'the plane one'],
    'crash-royale': ['crash', 'crash game', 'rocket game', 'crash classic'],
    'europski-rulet': ['roulette', 'rulet', 'roulete', 'european roulette', 'wheel game',
      'chakka game'],
    'rulet-pro': ['roulette pro', 'rulet pro'],
    'blackjack-classic': ['blackjack', 'black jack', '21', 'twenty one', 'blakjack', 'bj'],
    'mine-hunter': ['mines', 'mine game', 'minesweeper'],
    'kocka-duel': ['dice', 'dice game', 'pasa'],
  };

  for (const g of [...notable, ...liveGames]) {
    const id = `game_${g.slug}`;
    if (entities.some((e) => e.id === id)) continue;
    // games launch in a modal from the casino lobby, so deep-link via query string
    const route = g.isLive ? `/live-casino?game=${g.slug}` : `/casino?game=${g.slug}`;
    entities.push(E({
      id, type: 'GAME', name: g.title,
      aliases: [g.title.toLowerCase(), g.slug, ...(GAME_ALIASES[g.slug] || [])],
      description: `${g.title} by ${g.provider}. ${g.engine} game.`,
      category: g.isLive ? 'Live Casino' : 'Casino',
      parent_id: g.isLive ? 'page_live_casino' : 'page_casino',
      route,
      keywords: [g.engine, g.provider.toLowerCase()],
    }));
  }

  // ---- game category shortcuts that map to real casino filters ----
  const CATS = [
    ['category_slots', 'Slots', 'slots', ['slots', 'slot games', 'reels', 'slot machines',
      'slots dikhao', 'slot wala game']],
    ['category_jackpot', 'Jackpot Games', 'jackpot', ['jackpot', 'jackpots', 'jackpot games']],
    ['category_table', 'Table Games', 'table', ['table games', 'card games', 'tables']],
    ['category_new', 'New Games', 'new', ['new games', 'new', 'latest games', 'nove igre']],
    ['category_popular', 'Popular Games', 'popular', ['popular', 'popular games', 'top games']],
    ['category_instant', 'Instant Games', 'instant', ['instant games', 'instant', 'quick games']],
  ];
  for (const [id, name, key, aliases] of CATS) {
    entities.push(E({
      id, type: 'CATEGORY', name, aliases,
      description: `${name} in the casino lobby.`,
      category: 'Casino', parent_id: 'page_casino',
      route: `/casino?kategorija=${key}`,
      keywords: [key, 'casino'],
    }));
  }

  // ---- lotteries ----
  const { lotteries } = await get('/content/lotteries');
  for (const l of lotteries) {
    entities.push(E({
      id: `lottery_${slugify(l.slug)}`, type: 'GAME', name: l.name,
      aliases: [l.name.toLowerCase(), l.slug, l.slug.replace(/-/g, ' ')],
      description: `${l.name}: pick ${l.pick} of ${l.max}.`,
      category: 'Lottery', parent_id: 'page_loto',
      route: `/loto?igra=${l.slug}`,
      keywords: ['loto', 'lottery', 'numbers'],
    }));
  }

  // ---- alias table ----
  const aliasRows = [];
  const seen = new Set();
  for (const e of entities) {
    for (const a of [e.name.toLowerCase(), ...e.aliases]) {
      const key = a.toLowerCase().trim();
      if (!key || seen.has(key + '|' + e.id)) continue;
      seen.add(key + '|' + e.id);
      aliasRows.push({ alias: key, entity_id: e.id, entity_type: e.type, match_type: 'exact' });
    }
  }

  await fs.mkdir(DATA, { recursive: true });
  await fs.writeFile(path.join(DATA, 'entities.json'), JSON.stringify(entities, null, 2));
  await fs.writeFile(path.join(DATA, 'aliases.json'), JSON.stringify(aliasRows, null, 2));
  await fs.writeFile(path.join(DATA, 'categories.json'),
    JSON.stringify(entities.filter((e) => ['CATEGORY', 'SPORT'].includes(e.type)), null, 2));

  const byType = entities.reduce((a, e) => { a[e.type] = (a[e.type] || 0) + 1; return a; }, {});
  console.log('generated from the live site:');
  Object.entries(byType).forEach(([k, v]) => console.log(`  ${k.padEnd(10)} ${v}`));
  console.log(`  aliases    ${aliasRows.length}`);
  console.log(`\n  route check: ${problems.length ? problems.length + ' PROBLEMS' : 'all base routes exist in App.jsx'}`);
  problems.forEach((p) => console.log('    ✗ ' + p));
}

main().catch((e) => {
  console.error('failed:', e.message);
  console.error('Is the API running? (npm run server)');
  process.exit(1);
});
