import { Router } from 'express';
import { Sport, League, Event } from '../models/index.js';
import { MARKET_SETS, MARKET_LABELS } from '../utils/generate.js';

const router = Router();

/** Shape an Event document for the client. */
const shape = (e) => ({
  id: e._id,
  code: e.code,
  name: e.name,
  home: e.home,
  away: e.away,
  sport: e.sport?.slug || e.sport,
  sportName: e.sport?.name,
  sportIcon: e.sport?.icon,
  marketSet: e.sport?.marketSet || '1x2',
  league: e.league?.slug || e.league,
  leagueName: e.league?.name,
  flag: e.league?.flag,
  startsAt: e.startsAt,
  live: e.live,
  outright: e.outright,
  minute: e.minute,
  score: e.score,
  markets: e.markets instanceof Map ? Object.fromEntries(e.markets) : (e.markets || {}),
  marketCount: e.marketCount,
  status: e.status
});

/* GET /api/offer/meta — market keys + labels for the grid header */
router.get('/meta', (_req, res) => {
  res.json({ marketSets: MARKET_SETS, marketLabels: MARKET_LABELS });
});

/* GET /api/offer/sports — sidebar tree with counts */
router.get('/sports', async (_req, res, next) => {
  try {
    const sports = await Sport.find().sort({ order: 1 }).lean();
    const counts = await Event.aggregate([
      { $group: { _id: '$sport', total: { $sum: 1 }, live: { $sum: { $cond: ['$live', 1, 0] } } } }
    ]);
    const byId = Object.fromEntries(counts.map(c => [String(c._id), c]));

    const leagues = await League.find().lean();
    const leaguesBySport = leagues.reduce((acc, l) => {
      (acc[String(l.sport)] = acc[String(l.sport)] || []).push({ slug: l.slug, name: l.name, flag: l.flag });
      return acc;
    }, {});

    res.json({
      sports: sports.map(s => ({
        slug: s.slug,
        name: s.name,
        icon: s.icon,
        marketSet: s.marketSet,
        count: byId[String(s._id)]?.total || 0,
        live: byId[String(s._id)]?.live || 0,
        leagues: leaguesBySport[String(s._id)] || []
      })),
      liveTotal: counts.reduce((a, c) => a + c.live, 0),
      total: counts.reduce((a, c) => a + c.total, 0)
    });
  } catch (err) { next(err); }
});

/* GET /api/offer/events?sport=&league=&filter=&q=&limit= */
router.get('/events', async (req, res, next) => {
  try {
    const { sport, league, filter = 'all', q, limit = 300 } = req.query;
    const query = {};

    if (filter === 'live') {
      query.live = true;
    } else {
      if (sport) {
        const s = await Sport.findOne({ slug: sport });
        if (!s) return res.json({ events: [], groups: [] });
        query.sport = s._id;
      }
      if (league) {
        const l = await League.findOne({ slug: league });
        if (l) query.league = l._id;
      }
      if (filter === 'today') {
        const start = new Date(); start.setHours(0, 0, 0, 0);
        const end = new Date(start); end.setDate(end.getDate() + 1);
        query.startsAt = { $gte: start, $lt: end };
      }
      if (filter === 'soon') {
        query.live = false;
        query.startsAt = { $gte: new Date(), $lte: new Date(Date.now() + 3 * 3600e3) };
      }
    }
    if (q) query.name = new RegExp(String(q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

    const docs = await Event.find(query)
      .populate('sport', 'slug name icon marketSet')
      .populate('league', 'slug name flag')
      .sort({ live: -1, startsAt: 1 })
      .limit(Math.min(Number(limit) || 300, 1000));

    const events = docs.map(shape);

    // group by league so the client can render collapsible blocks directly
    const groups = [];
    const index = new Map();
    for (const e of events) {
      if (!index.has(e.league)) {
        index.set(e.league, { league: e.league, leagueName: e.leagueName, flag: e.flag, events: [] });
        groups.push(index.get(e.league));
      }
      index.get(e.league).events.push(e);
    }

    res.json({ count: events.length, events, groups });
  } catch (err) { next(err); }
});

/* GET /api/offer/events/:id — single event with a full market board */
router.get('/events/:id', async (req, res, next) => {
  try {
    const e = await Event.findById(req.params.id)
      .populate('sport', 'slug name icon marketSet')
      .populate('league', 'slug name flag');
    if (!e) return res.status(404).json({ error: req.t('offer.eventNotFound') });

    const base = shape(e);

    // deterministic extra markets derived from the event code
    let a = e.code >>> 0;
    const rnd = () => {
      a |= 0; a = (a + 0x6D2B79F5) | 0;
      let t = Math.imul(a ^ (a >>> 15), 1 | a);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    };

    const board = [
      { name: 'Konačni ishod',        keys: MARKET_SETS[base.marketSet] },
      { name: 'Ukupno golova / poena',keys: ['0-1', '0-2', '2+', '3+', '4+', '5+'] },
      { name: 'Poluvrijeme',          keys: ['1P 1', '1P X', '1P 2'] },
      { name: 'Hendikep',             keys: ['H -1', 'H 0', 'H +1'] },
      { name: 'Kombinacije',          keys: ['1 i GG', '2 i GG', '1 i 2+', '2 i 2+'] }
    ].map(g => ({
      name: g.name,
      markets: g.keys.map(k => ({
        key: k,
        label: MARKET_LABELS[k] || k,
        odds: base.markets[k] != null ? base.markets[k] : +(1.2 + rnd() * 6).toFixed(2)
      }))
    }));

    res.json({ event: base, board });
  } catch (err) { next(err); }
});

export default router;
