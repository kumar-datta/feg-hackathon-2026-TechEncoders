import { Router } from 'express';
import { Game, Provider, Round } from '../models/index.js';
import { requireAuth } from '../middleware/auth.js';
import { CATEGORIES } from '../utils/generate.js';

const router = Router();

const shape = (g) => ({
  id: g._id,
  slug: g.slug,
  title: g.title,
  provider: g.provider?.name || 'Nepoznat',
  providerSlug: g.provider?.slug,
  engine: g.engine,
  categories: g.categories,
  symbol: g.symbol,
  hueA: g.hueA,
  hueB: g.hueB,
  rtp: g.rtp,
  volatility: g.volatility,
  lines: g.lines,
  minBet: g.minBet,
  maxBet: g.maxBet,
  jackpot: g.jackpot,
  isLive: g.isLive,
  players: g.players
});

/* GET /api/casino/categories */
router.get('/categories', (_req, res) => res.json({ categories: CATEGORIES }));

/* GET /api/casino/providers */
router.get('/providers', async (_req, res, next) => {
  try {
    const providers = await Provider.find().sort({ name: 1 }).lean();
    const counts = await Game.aggregate([{ $group: { _id: '$provider', n: { $sum: 1 } } }]);
    const byId = Object.fromEntries(counts.map(c => [String(c._id), c.n]));
    res.json({
      providers: providers
        .map(p => ({ slug: p.slug, name: p.name, games: byId[String(p._id)] || 0 }))
        .filter(p => p.games > 0)
    });
  } catch (err) { next(err); }
});

/* GET /api/casino/games?category=&provider=&q=&live=&page=&limit= */
router.get('/games', async (req, res, next) => {
  try {
    const { category, provider, q, live, page = 1, limit = 60 } = req.query;
    const query = {};

    query.isLive = live === 'true';
    if (category && !['lobby', 'all'].includes(category)) query.categories = category;
    if (provider) {
      const p = await Provider.findOne({ slug: provider });
      if (!p) return res.json({ games: [], total: 0 });
      query.provider = p._id;
    }
    if (q) query.title = new RegExp(String(q).replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'i');

    const lim = Math.min(Number(limit) || 60, 200);
    const skip = (Math.max(1, Number(page)) - 1) * lim;

    const [docs, total] = await Promise.all([
      Game.find(query).populate('provider', 'name slug')
        .sort({ popularity: -1, title: 1 }).skip(skip).limit(lim),
      Game.countDocuments(query)
    ]);

    res.json({ games: docs.map(shape), total, page: Number(page), limit: lim });
  } catch (err) { next(err); }
});

/* GET /api/casino/lobby — the rails shown on the casino landing page */
router.get('/lobby', async (_req, res, next) => {
  try {
    const rails = [
      { id: 'favourites', name: 'PSK favoriti',      icon: '⭐' },
      { id: 'new',        name: 'Nove igre',         icon: '✨' },
      { id: 'popular',    name: 'Popularno',         icon: '🔥' },
      { id: 'table',      name: 'Igre na stolovima', icon: '🃏' },
      { id: 'jackpot',    name: 'Jackpot igre',      icon: '💰' },
      { id: 'buy-bonus',  name: 'Buy Bonus',         icon: '🎁' },
      { id: 'small-bets', name: 'Mali ulozi',        icon: '🪙' },
      { id: 'megaways',   name: 'Megaways',          icon: '🌀' }
    ];

    const filled = await Promise.all(rails.map(async r => {
      const [games, total] = await Promise.all([
        Game.find({ categories: r.id, isLive: false })
          .populate('provider', 'name slug').sort({ popularity: -1 }).limit(12),
        Game.countDocuments({ categories: r.id, isLive: false })
      ]);
      return { ...r, total, games: games.map(shape) };
    }));

    const jackpots = await Game.find({ jackpot: { $gt: 0 } })
      .populate('provider', 'name slug').sort({ jackpot: -1 }).limit(4);

    res.json({ rails: filled.filter(r => r.games.length), jackpots: jackpots.map(shape) });
  } catch (err) { next(err); }
});

/* GET /api/casino/games/:slug */
router.get('/games/:slug', async (req, res, next) => {
  try {
    const g = await Game.findOne({ slug: req.params.slug }).populate('provider', 'name slug');
    if (!g) return res.status(404).json({ error: req.t('casino.gameNotFound') });
    res.json({ game: shape(g) });
  } catch (err) { next(err); }
});

/* ------------------------------------------------------------------
   POST /api/casino/round — settle one demo round.
   The client engine plays the animation; the server is the authority
   on the wallet, validating the bet and recording the round.
   ------------------------------------------------------------------ */
router.post('/round', requireAuth, async (req, res, next) => {
  try {
    const { gameId, bet, win = 0, detail = {} } = req.body;

    const stake = Number(bet);
    const payout = Math.max(0, Number(win) || 0);

    if (!Number.isFinite(stake) || stake <= 0)
      return res.status(400).json({ error: req.t('casino.badStake') });

    const game = await Game.findById(gameId);
    if (!game) return res.status(404).json({ error: req.t('casino.gameNotFound') });
    if (stake < game.minBet || stake > game.maxBet)
      return res.status(400).json({ error: req.t('casino.stakeRange', { min: game.minBet, max: game.maxBet }) });
    if (req.user.balance < stake)
      return res.status(400).json({ error: req.t('casino.insufficient') });

    // sanity cap so a tampered client cannot mint credits
    if (payout > stake * 5000)
      return res.status(400).json({ error: req.t('casino.winTooLarge') });

    req.user.balance = Math.round((req.user.balance - stake + payout) * 100) / 100;
    await req.user.save();

    await Round.create({
      user: req.user._id, game: game._id, engine: game.engine,
      bet: stake, win: payout, detail
    });

    res.json({ balance: req.user.balance, bet: stake, win: payout });
  } catch (err) { next(err); }
});

/* GET /api/casino/rounds — recent play history */
router.get('/rounds', requireAuth, async (req, res, next) => {
  try {
    const rounds = await Round.find({ user: req.user._id })
      .populate('game', 'title symbol slug')
      .sort({ createdAt: -1 }).limit(50);
    res.json({ rounds });
  } catch (err) { next(err); }
});

export default router;
