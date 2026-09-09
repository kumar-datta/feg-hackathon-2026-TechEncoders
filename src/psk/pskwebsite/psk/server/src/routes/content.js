import { Router } from 'express';
import { Promo, News, Shop, Lottery, Draw, Virtual, Thread, Event, Game } from '../models/index.js';
import { PAYMENTS } from '../utils/generate.js';

const router = Router();

/* ---------------- promotions ---------------- */
router.get('/promos', async (req, res, next) => {
  try {
    const query = { active: true };
    if (req.query.tag && req.query.tag !== 'Sve') query.tag = req.query.tag;
    const promos = await Promo.find(query).sort({ createdAt: 1 }).lean();
    const tags = await Promo.distinct('tag', { active: true });
    res.json({ promos, tags: ['Sve', ...tags] });
  } catch (err) { next(err); }
});

router.get('/promos/:slug', async (req, res, next) => {
  try {
    const promo = await Promo.findOne({ slug: req.params.slug }).lean();
    if (!promo) return res.status(404).json({ error: 'Promocija nije pronađena.' });
    res.json({ promo });
  } catch (err) { next(err); }
});

/* ---------------- news ---------------- */
router.get('/news', async (req, res, next) => {
  try {
    const query = {};
    if (req.query.category && req.query.category !== 'Sve') query.category = req.query.category;
    const news = await News.find(query).sort({ publishedAt: -1 }).lean();
    const categories = await News.distinct('category');
    res.json({ news, categories: ['Sve', ...categories] });
  } catch (err) { next(err); }
});

router.get('/news/:slug', async (req, res, next) => {
  try {
    const article = await News.findOne({ slug: req.params.slug }).lean();
    if (!article) return res.status(404).json({ error: 'Članak nije pronađen.' });
    res.json({ article });
  } catch (err) { next(err); }
});

/* ---------------- shops ---------------- */
router.get('/shops', async (req, res, next) => {
  try {
    const query = {};
    if (req.query.city && req.query.city !== 'Sve') query.city = req.query.city;
    const shops = await Shop.find(query).sort({ city: 1, address: 1 }).lean();
    const cities = await Shop.distinct('city');
    res.json({ shops, cities: ['Sve', ...cities.sort()] });
  } catch (err) { next(err); }
});

/* ---------------- lotteries ---------------- */
router.get('/lotteries', async (_req, res, next) => {
  try {
    const lotteries = await Lottery.find().lean();
    const draws = await Draw.find().populate('lottery', 'name slug').sort({ drawnAt: -1 }).limit(30).lean();
    res.json({ lotteries, draws });
  } catch (err) { next(err); }
});

/* ---------------- virtuals ---------------- */
router.get('/virtuals', async (_req, res, next) => {
  try {
    const virtuals = await Virtual.find().lean();
    res.json({ virtuals });
  } catch (err) { next(err); }
});

/* ---------------- forum ---------------- */
router.get('/threads', async (req, res, next) => {
  try {
    const query = {};
    if (req.query.category && req.query.category !== 'Sve') query.category = req.query.category;
    const threads = await Thread.find(query).sort({ updatedAt: -1 }).lean();
    const categories = await Thread.distinct('category');
    res.json({ threads, categories: ['Sve', ...categories] });
  } catch (err) { next(err); }
});

router.get('/threads/:slug', async (req, res, next) => {
  try {
    const thread = await Thread.findOneAndUpdate(
      { slug: req.params.slug }, { $inc: { views: 1 } }, { new: true }
    ).lean();
    if (!thread) return res.status(404).json({ error: 'Tema nije pronađena.' });
    res.json({ thread });
  } catch (err) { next(err); }
});

/* ---------------- results & statistics ---------------- */
router.get('/results', async (req, res, next) => {
  try {
    const query = { startsAt: { $lt: new Date() } };
    const events = await Event.find(query)
      .populate('sport', 'slug name icon')
      .populate('league', 'slug name flag')
      .sort({ startsAt: -1 }).limit(120).lean();

    res.json({
      results: events.map(e => ({
        id: e._id, code: e.code, name: e.name,
        sport: e.sport?.name, sportIcon: e.sport?.icon,
        league: e.league?.name, flag: e.league?.flag,
        startsAt: e.startsAt,
        live: e.live, minute: e.minute,
        score: e.score || (e.live ? '' : '—')
      }))
    });
  } catch (err) { next(err); }
});

router.get('/stats', async (_req, res, next) => {
  try {
    const [eventCount, liveCount, gameCount, jackpotAgg] = await Promise.all([
      Event.countDocuments(),
      Event.countDocuments({ live: true }),
      Game.countDocuments(),
      Game.aggregate([{ $group: { _id: null, total: { $sum: '$jackpot' } } }])
    ]);

    const bySport = await Event.aggregate([
      { $group: { _id: '$sport', n: { $sum: 1 }, live: { $sum: { $cond: ['$live', 1, 0] } } } },
      { $lookup: { from: 'sports', localField: '_id', foreignField: '_id', as: 's' } },
      { $unwind: '$s' },
      { $project: { _id: 0, sport: '$s.name', icon: '$s.icon', events: '$n', live: 1 } },
      { $sort: { events: -1 } }
    ]);

    const byProvider = await Game.aggregate([
      { $group: { _id: '$provider', n: { $sum: 1 } } },
      { $lookup: { from: 'providers', localField: '_id', foreignField: '_id', as: 'p' } },
      { $unwind: '$p' },
      { $project: { _id: 0, provider: '$p.name', games: '$n' } },
      { $sort: { games: -1 } }, { $limit: 20 }
    ]);

    res.json({
      totals: {
        events: eventCount,
        live: liveCount,
        games: gameCount,
        jackpotPool: jackpotAgg[0]?.total || 0
      },
      bySport, byProvider
    });
  } catch (err) { next(err); }
});

/* ---------------- misc ---------------- */
router.get('/payments', (_req, res) => res.json({ payments: PAYMENTS }));

/* GET /api/content/search?q= — cross-product search */
router.get('/search', async (req, res, next) => {
  try {
    const q = String(req.query.q || '').trim();
    if (!q) return res.json({ events: [], games: [] });
    const rx = new RegExp(q.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

    const [events, games] = await Promise.all([
      Event.find({ name: rx })
        .populate('sport', 'slug name icon').populate('league', 'slug name flag')
        .limit(40).lean(),
      Game.find({ title: rx }).populate('provider', 'name slug').limit(60).lean()
    ]);

    res.json({
      events: events.map(e => ({
        id: e._id, name: e.name, code: e.code,
        sport: e.sport?.slug, league: e.league?.slug,
        leagueName: e.league?.name, flag: e.league?.flag
      })),
      games: games.map(g => ({
        id: g._id, slug: g.slug, title: g.title,
        provider: g.provider?.name, engine: g.engine,
        symbol: g.symbol, hueA: g.hueA, hueB: g.hueB,
        categories: g.categories, jackpot: g.jackpot,
        rtp: g.rtp, volatility: g.volatility, minBet: g.minBet, maxBet: g.maxBet
      }))
    });
  } catch (err) { next(err); }
});

export default router;
