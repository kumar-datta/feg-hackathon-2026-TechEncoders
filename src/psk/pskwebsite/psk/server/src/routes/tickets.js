import { Router } from 'express';
import { Ticket, Event } from '../models/index.js';
import { requireAuth, maybeAuth } from '../middleware/auth.js';
import { MARKET_LABELS } from '../utils/generate.js';

const router = Router();

const DEDUCTION_RATE = 0.10;   // illustrative payout deduction

function makeRef() {
  return 'T' + Date.now().toString(36).toUpperCase().slice(-6) +
         Math.floor(Math.random() * 900 + 100);
}

/* ------------------------------------------------------------------
   POST /api/tickets — place a bet.
   Odds are re-read from the database so a tampered client cannot
   submit its own prices.
   ------------------------------------------------------------------ */
router.post('/', requireAuth, async (req, res, next) => {
  try {
    const { selections, stake } = req.body;

    if (!Array.isArray(selections) || selections.length === 0)
      return res.status(400).json({ error: req.t('ticket.empty') });
    if (selections.length > 30)
      return res.status(400).json({ error: req.t('ticket.tooMany') });

    const amount = Number(stake);
    if (!Number.isFinite(amount) || amount < 0.5)
      return res.status(400).json({ error: req.t('ticket.minStake') });
    if (amount > req.user.balance)
      return res.status(400).json({ error: req.t('ticket.insufficient') });

    // one selection per event
    const seen = new Set();
    const resolved = [];

    for (const sel of selections) {
      if (seen.has(String(sel.eventId)))
        return res.status(400).json({ error: req.t('ticket.duplicateEvent') });
      seen.add(String(sel.eventId));

      const ev = await Event.findById(sel.eventId).populate('league', 'name');
      if (!ev) return res.status(400).json({ error: req.t('ticket.eventGone') });
      if (ev.status !== 'open')
        return res.status(400).json({ error: req.t('ticket.eventClosed', { name: ev.name }) });

      const markets = ev.markets instanceof Map ? Object.fromEntries(ev.markets) : ev.markets;
      const odds = markets[sel.marketKey];
      if (odds == null)
        return res.status(400).json({ error: req.t('ticket.marketGone', { market: sel.marketKey }) });

      resolved.push({
        event: ev._id,
        eventName: ev.name,
        leagueName: ev.league?.name || '',
        marketKey: sel.marketKey,
        marketLabel: MARKET_LABELS[sel.marketKey] || sel.marketKey,
        odds,
        code: ev.code,
        result: 'open'
      });
    }

    const totalOdds = +resolved.reduce((a, s) => a * s.odds, 1).toFixed(2);
    const gross = +(amount * totalOdds).toFixed(2);
    const deduction = +((gross - amount) * DEDUCTION_RATE).toFixed(2);
    const net = +(gross - deduction).toFixed(2);

    req.user.balance = Math.round((req.user.balance - amount) * 100) / 100;
    await req.user.save();

    const ticket = await Ticket.create({
      ref: makeRef(),
      user: req.user._id,
      selections: resolved,
      stake: amount,
      totalOdds,
      potentialGross: gross,
      deduction,
      potentialNet: net
    });

    res.status(201).json({ ticket, balance: req.user.balance });
  } catch (err) { next(err); }
});

/* GET /api/tickets — my tickets */
router.get('/', requireAuth, async (req, res, next) => {
  try {
    const { status } = req.query;
    const query = { user: req.user._id };
    if (status) query.status = status;
    const tickets = await Ticket.find(query).sort({ createdAt: -1 }).limit(100);
    res.json({ tickets });
  } catch (err) { next(err); }
});

/* GET /api/tickets/shared — the Arena feed */
router.get('/shared', maybeAuth, async (_req, res, next) => {
  try {
    const tickets = await Ticket.find({ shared: true })
      .populate('user', 'username')
      .sort({ createdAt: -1 }).limit(40);
    res.json({ tickets });
  } catch (err) { next(err); }
});

/* GET /api/tickets/:ref */
router.get('/:ref', requireAuth, async (req, res, next) => {
  try {
    const ticket = await Ticket.findOne({ ref: req.params.ref, user: req.user._id });
    if (!ticket) return res.status(404).json({ error: req.t('ticket.notFound') });
    res.json({ ticket });
  } catch (err) { next(err); }
});

/* POST /api/tickets/:ref/share */
router.post('/:ref/share', requireAuth, async (req, res, next) => {
  try {
    const ticket = await Ticket.findOne({ ref: req.params.ref, user: req.user._id });
    if (!ticket) return res.status(404).json({ error: req.t('ticket.notFound') });
    ticket.shared = !ticket.shared;
    await ticket.save();
    res.json({ ticket });
  } catch (err) { next(err); }
});

/* ------------------------------------------------------------------
   POST /api/tickets/:ref/settle — demo settlement.
   Each selection is resolved randomly; a fully correct ticket pays out.
   ------------------------------------------------------------------ */
router.post('/:ref/settle', requireAuth, async (req, res, next) => {
  try {
    const ticket = await Ticket.findOne({ ref: req.params.ref, user: req.user._id });
    if (!ticket) return res.status(404).json({ error: req.t('ticket.notFound') });
    if (ticket.status !== 'open') return res.status(400).json({ error: req.t('ticket.alreadySettled') });

    ticket.selections.forEach(s => {
      // higher odds → lower implied chance, which keeps the demo plausible
      s.result = Math.random() < (1 / s.odds) * 0.96 ? 'won' : 'lost';
    });

    const allWon = ticket.selections.every(s => s.result === 'won');
    ticket.status = allWon ? 'won' : 'lost';
    ticket.payout = allWon ? ticket.potentialNet : 0;

    if (allWon) {
      req.user.balance = Math.round((req.user.balance + ticket.payout) * 100) / 100;
      await req.user.save();
    }
    await ticket.save();

    res.json({ ticket, balance: req.user.balance });
  } catch (err) { next(err); }
});

export default router;
