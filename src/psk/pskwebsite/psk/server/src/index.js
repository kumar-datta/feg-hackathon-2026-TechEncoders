import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { connectDB } from './config/db.js';
import { notFound, errorHandler } from './middleware/error.js';
import { attachLocale } from './utils/messages.js';

import authRoutes from './routes/auth.js';
import offerRoutes from './routes/offer.js';
import casinoRoutes from './routes/casino.js';
import ticketRoutes from './routes/tickets.js';
import contentRoutes from './routes/content.js';
import assistantRoutes from './routes/assistant.js';
import { ingest } from './assistant/ingest.js';

const app = express();
const PORT = process.env.PORT || 5000;

/* ---------------- middleware ---------------- */
app.use(helmet({ crossOriginResourcePolicy: false }));
app.use(cors({
  origin: process.env.CLIENT_ORIGIN || ['http://localhost:5173', 'http://127.0.0.1:5173'],
  credentials: true
}));
app.use(express.json({ limit: '256kb' }));
app.use(morgan('dev'));
app.use(attachLocale);   // adds req.lang + req.t

app.use('/api', rateLimit({
  windowMs: 60_000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: (req) => ({ error: req.t('error.rateLimit') })
}));

// tighter limit on credential endpoints
app.use('/api/auth/login', rateLimit({ windowMs: 15 * 60_000, max: 20 }));
app.use('/api/auth/register', rateLimit({ windowMs: 60 * 60_000, max: 10 }));

/* ---------------- routes ---------------- */
app.get('/api/health', (req, res) => res.json({
  ok: true,
  service: 'psk-demo-api',
  lang: req.lang,
  note: req.t('health.note'),
  time: new Date().toISOString()
}));

app.use('/api/auth', authRoutes);
app.use('/api/offer', offerRoutes);
app.use('/api/casino', casinoRoutes);
app.use('/api/tickets', ticketRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/assistant', assistantRoutes);

app.use(notFound);
app.use(errorHandler);

/* ---------------- start ---------------- */
connectDB()
  .then(() => ingest().catch((e) => {
    // the assistant is optional — a failure here must not stop the API
    console.warn('[assistant] ingest failed:', e.message);
  }))
  .then(() => {
    app.listen(PORT, () => {
      console.log(`[api] listening on http://localhost:${PORT}`);
      console.log(`[api] health check: http://localhost:${PORT}/api/health`);
    });
  })
  .catch(() => {
    console.error('[api] not started — database unavailable.');
    process.exit(1);
  });

export default app;
