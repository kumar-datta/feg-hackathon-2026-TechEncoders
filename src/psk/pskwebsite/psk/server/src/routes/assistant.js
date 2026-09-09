import { Router } from 'express';
import rateLimit from 'express-rate-limit';
import { handleQuery, assistantStatus } from '../assistant/index.js';
import { maybeAuth } from '../middleware/auth.js';
import { resolve } from '../assistant/resolver.js';

const router = Router();

/* The assistant is cheap when deterministic but can call a paid API, so it gets
   its own tighter limit than the global one. */
const limiter = rateLimit({
  windowMs: 60_000,
  max: 30,
  standardHeaders: true,
  legacyHeaders: false,
  message: (req) => ({ error: req.t ? req.t('error.rateLimit') : 'Too many requests.' }),
});

/* GET /api/assistant/status — what mode is it running in? */
router.get('/status', (_req, res) => {
  res.json({ ok: true, ...assistantStatus() });
});

/* POST /api/assistant/query */
router.post('/query', limiter, maybeAuth, async (req, res, next) => {
  try {
    const { message, session_id: sessionId } = req.body || {};

    if (typeof message !== 'string' || !message.trim()) {
      return res.status(400).json({ error: 'A message is required.' });
    }
    if (message.length > 500) {
      return res.status(400).json({ error: 'Message is too long (500 characters max).' });
    }

    // The assistant is told only what it needs for gating — never balances.
    const user = {
      authenticated: Boolean(req.user),
      kyc_status: req.user ? 'verified' : 'unknown',
      language: req.lang || 'en',
    };

    const result = await handleQuery(message, {
      sessionId: sessionId || `anon_${req.ip}`,
      user,
    });

    res.json(result);
  } catch (err) {
    next(err);
  }
});

/* GET /api/assistant/resolve?q= — entity resolution only, useful for debugging
   and for a type-ahead in the widget. */
router.get('/resolve', (req, res) => {
  const q = String(req.query.q || '');
  if (!q) return res.json({ best: null, candidates: [] });
  const { best, candidates, ambiguous } = resolve(q);
  res.json({ best, candidates, ambiguous });
});

export default router;
