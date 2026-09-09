import jwt from 'jsonwebtoken';
import { User } from '../models/index.js';

export const JWT_SECRET = process.env.JWT_SECRET || 'psk-demo-dev-secret-change-me';

export function signToken(user) {
  return jwt.sign({ id: user._id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });
}

/** Attaches req.user when a valid Bearer token is present. */
export async function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (!token) return res.status(401).json({ error: req.t('auth.noToken') });

  try {
    const payload = jwt.verify(token, JWT_SECRET);
    const user = await User.findById(payload.id);
    if (!user) return res.status(401).json({ error: req.t('auth.noUser') });

    if (user.limits?.selfExcludedUntil && user.limits.selfExcludedUntil > new Date()) {
      return res.status(403).json({
        error: req.t('auth.selfExcluded'),
        until: user.limits.selfExcludedUntil
      });
    }
    req.user = user;
    next();
  } catch (err) {
    res.status(401).json({ error: req.t('auth.badToken') });
  }
}

/** Optional auth — sets req.user if a token happens to be valid. */
export async function maybeAuth(req, _res, next) {
  const header = req.headers.authorization || '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : null;
  if (token) {
    try {
      const payload = jwt.verify(token, JWT_SECRET);
      req.user = await User.findById(payload.id);
    } catch { /* ignore — stays anonymous */ }
  }
  next();
}
