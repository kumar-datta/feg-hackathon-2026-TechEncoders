/**
 * seed.js — populate MongoDB with the demo offer and catalogue.
 *
 *   npm run seed          upsert (keeps users/tickets)
 *   npm run seed:fresh    drop collections first
 */
import 'dotenv/config';
import mongoose from 'mongoose';
import bcrypt from 'bcryptjs';

import { connectDB } from './config/db.js';
import {
  Sport, League, Event, Provider, Game, User, Promo, News,
  Shop, Lottery, Draw, Virtual, Thread
} from './models/index.js';
import {
  makeRng, pick, rint, slugify,
  SPORTS, LEAGUES, TEAMS, OUTRIGHT_FIELDS, MARKET_SETS, oddsFor,
  PROVIDERS, generateSlots, TABLE_GAMES, LIVE_TABLES,
  LOTTERIES, VIRTUALS, PROMOS, NEWS, SHOPS, THREADS, FORUM_REPLIES
} from './utils/generate.js';

const DROP = process.argv.includes('--drop');

async function run() {
  await connectDB();

  if (DROP) {
    console.log('[seed] dropping collections...');
    await Promise.all([
      Sport, League, Event, Provider, Game, Promo, News, Shop, Lottery, Draw, Virtual, Thread
    ].map(M => M.deleteMany({})));
  }

  /* ---------------- sports + leagues ---------------- */
  console.log('[seed] sports & leagues...');
  const sportDocs = {};
  for (let i = 0; i < SPORTS.length; i++) {
    const s = SPORTS[i];
    sportDocs[s.slug] = await Sport.findOneAndUpdate(
      { slug: s.slug },
      { ...s, order: i },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
  }

  const leagueDocs = {};
  for (const [sportSlug, list] of Object.entries(LEAGUES)) {
    const sport = sportDocs[sportSlug];
    if (!sport) continue;
    for (const [slug, name, flag] of list) {
      leagueDocs[slug] = await League.findOneAndUpdate(
        { sport: sport._id, slug },
        { slug, name, flag, sport: sport._id },
        { upsert: true, new: true, setDefaultsOnInsert: true }
      );
    }
  }

  /* ---------------- events ---------------- */
  console.log('[seed] events...');
  await Event.deleteMany({});
  const r = makeRng(778899);
  const events = [];
  let code = 1000;

  for (const s of SPORTS) {
    const sport = sportDocs[s.slug];
    const keys = MARKET_SETS[s.marketSet];
    const isOutright = s.marketSet === 'outright';

    for (const [lgSlug] of (LEAGUES[s.slug] || [])) {
      const league = leagueDocs[lgSlug];
      if (!league) continue;

      const pool = isOutright ? (OUTRIGHT_FIELDS[lgSlug] || ['A', 'B', 'C'])
                              : (TEAMS[lgSlug] || ['Tim A', 'Tim B', 'Tim C', 'Tim D']);
      const n = s.slug === 'nogomet' ? rint(4, 11, r) : isOutright ? rint(3, 7, r) : rint(3, 9, r);

      for (let i = 0; i < n; i++) {
        const live = r() < 0.16;
        let home = pick(pool, r), away = null, name = home;
        if (!isOutright) {
          let guard = 0;
          do { away = pick(pool, r); guard++; } while (away === home && guard < 25);
          name = `${home} - ${away}`;
        }

        const markets = {};
        for (const k of keys) {
          if (!isOutright && r() < 0.07) continue;   // gaps, like a real grid
          markets[k] = oddsFor(k, r);
        }

        events.push({
          code: code++,
          name, home, away,
          sport: sport._id,
          league: league._id,
          startsAt: new Date(Date.now() + (live ? -rint(5, 80, r) : rint(20, 8600, r)) * 60000),
          live,
          outright: isOutright,
          minute: live ? rint(3, 88, r) : 0,
          score: live
            ? (s.slug === 'kosarka' ? `${rint(48, 96, r)}:${rint(48, 96, r)}`
              : s.slug === 'tenis'  ? `${rint(0, 2, r)}:${rint(0, 2, r)}`
              : `${rint(0, 4, r)}:${rint(0, 4, r)}`)
            : '',
          markets,
          marketCount: rint(28, 210, r)
        });
      }
    }
  }
  await Event.insertMany(events);
  console.log(`[seed]   ${events.length} events`);

  /* ---------------- providers + games ---------------- */
  console.log('[seed] providers & games...');
  const providerDocs = {};
  for (const name of [...PROVIDERS, 'PSK Studio']) {
    providerDocs[name] = await Provider.findOneAndUpdate(
      { slug: slugify(name) },
      { slug: slugify(name), name },
      { upsert: true, new: true, setDefaultsOnInsert: true }
    );
  }

  await Game.deleteMany({});
  const slots = generateSlots(420);
  const gr = makeRng(9911);

  const gameDocs = [
    ...slots.map(g => ({
      slug: g.slug, title: g.title, provider: providerDocs[g.providerName]._id,
      engine: g.engine, categories: g.categories, symbol: g.symbol,
      hueA: g.hueA, hueB: g.hueB, rtp: g.rtp, volatility: g.volatility,
      lines: g.lines, minBet: g.minBet, maxBet: g.maxBet,
      jackpot: g.jackpot, popularity: g.popularity, isLive: false
    })),
    ...TABLE_GAMES.map(g => ({
      slug: slugify(g.title), title: g.title, provider: providerDocs[g.providerName]._id,
      engine: g.engine, categories: g.categories, symbol: g.symbol,
      hueA: g.hueA, hueB: g.hueB, rtp: g.rtp, volatility: g.volatility,
      lines: 0, minBet: 0.1, maxBet: 100, jackpot: 0,
      popularity: rint(500, 1000, gr), isLive: false
    })),
    ...LIVE_TABLES.map(g => ({
      slug: slugify(g.title), title: g.title, provider: providerDocs[g.providerName]._id,
      engine: g.engine, categories: g.categories, symbol: g.symbol,
      hueA: g.hueA, hueB: g.hueB, rtp: 97, volatility: 'Srednja',
      lines: 0, minBet: 0.5, maxBet: 500, jackpot: 0,
      popularity: rint(400, 1000, gr), isLive: true, players: rint(12, 480, gr)
    }))
  ];
  await Game.insertMany(gameDocs);
  console.log(`[seed]   ${gameDocs.length} games`);

  /* ---------------- content ---------------- */
  console.log('[seed] content...');
  for (const p of PROMOS) {
    await Promo.findOneAndUpdate({ slug: p.slug }, {
      ...p,
      terms: { turnover: '5×', minOdds: 1.5, days: 30, minDeposit: 10 }
    }, { upsert: true, setDefaultsOnInsert: true });
  }

  for (let i = 0; i < NEWS.length; i++) {
    const a = NEWS[i];
    await News.findOneAndUpdate({ slug: a.slug }, {
      ...a,
      body: `${a.excerpt}\n\nOvaj tekst je generirani demonstracijski sadržaj koji služi za prikaz izgleda stranice s novostima. U stvarnom sustavu ovdje bi stajala uredničaka analiza s podacima o formi, sastavima i statistici.`,
      publishedAt: new Date(Date.now() - i * 86400000)
    }, { upsert: true, setDefaultsOnInsert: true });
  }

  await Shop.deleteMany({});
  await Shop.insertMany(SHOPS.map(s => ({
    ...s,
    lat: 44 + Math.random() * 2.5,
    lng: 14 + Math.random() * 4
  })));

  for (const l of LOTTERIES) {
    await Lottery.findOneAndUpdate({ slug: l.slug }, l, { upsert: true, setDefaultsOnInsert: true });
  }

  await Draw.deleteMany({});
  const dr = makeRng(5150);
  const draws = [];
  for (const l of LOTTERIES) {
    const lot = await Lottery.findOne({ slug: l.slug });
    for (let k = 0; k < 5; k++) {
      const nums = new Set();
      while (nums.size < l.pick) nums.add(1 + Math.floor(dr() * l.max));
      draws.push({
        lottery: lot._id,
        round: `2026/${String(180 - k).padStart(3, '0')}`,
        numbers: [...nums].sort((a, b) => a - b),
        fund: Math.floor(dr() * l.jackpot),
        drawnAt: new Date(Date.now() - (k + 1) * 2 * 86400000)
      });
    }
  }
  await Draw.insertMany(draws);

  for (const v of VIRTUALS) {
    await Virtual.findOneAndUpdate({ slug: v.slug }, v, { upsert: true, setDefaultsOnInsert: true });
  }

  const tr = makeRng(2024);
  for (const t of THREADS) {
    await Thread.findOneAndUpdate({ slug: t.slug }, {
      ...t,
      views: rint(40, 3200, tr),
      replies: Array.from({ length: rint(2, 5, tr) }, () => ({
        author: pick(['marko_92', 'arena_king', 'zlatna_serija', 'kvota_lovac', 'hattrick'], tr),
        body: pick(FORUM_REPLIES, tr),
        createdAt: new Date(Date.now() - rint(1, 200, tr) * 3600000)
      }))
    }, { upsert: true, setDefaultsOnInsert: true });
  }

  /* ---------------- demo user ---------------- */
  const existing = await User.findOne({ username: 'demo' });
  if (!existing) {
    await User.create({
      username: 'demo',
      email: 'demo@psk.local',
      password: await bcrypt.hash('demo1234', 10),
      balance: 500
    });
    console.log('[seed] demo user created — demo / demo1234');
  }

  console.log('[seed] done.');
  await mongoose.disconnect();
}

run().catch(err => {
  console.error('[seed] failed:', err);
  process.exit(1);
});
