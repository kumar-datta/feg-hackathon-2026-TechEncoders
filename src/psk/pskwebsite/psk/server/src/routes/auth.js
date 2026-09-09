import { Router } from 'express';
import bcrypt from 'bcryptjs';
import { User } from '../models/index.js';
import { signToken, requireAuth } from '../middleware/auth.js';

const router = Router();

const publicUser = (u) => ({
  id: u._id,
  username: u.username,
  email: u.email,
  balance: u.balance,
  limits: u.limits,
  favourites: u.favourites,
  createdAt: u.createdAt
});

/* POST /api/auth/register */
router.post('/register', async (req, res, next) => {
  try {
    const { username, email, password } = req.body;

    if (!username || !email || !password)
      return res.status(400).json({ error: req.t('auth.missingFields') });
    if (username.length < 3)
      return res.status(400).json({ error: req.t('auth.usernameShort') });
    if (password.length < 8)
      return res.status(400).json({ error: req.t('auth.passwordShort') });

    const clash = await User.findOne({ $or: [{ username }, { email: email.toLowerCase() }] });
    if (clash) return res.status(409).json({ error: req.t('auth.taken') });

    const user = await User.create({
      username,
      email: email.toLowerCase(),
      password: await bcrypt.hash(password, 10),
      balance: 500                       // demo credits
    });

    res.status(201).json({ token: signToken(user), user: publicUser(user) });
  } catch (err) { next(err); }
});

/* POST /api/auth/login */
router.post('/login', async (req, res, next) => {
  try {
    const { username, password } = req.body;
    if (!username || !password)
      return res.status(400).json({ error: req.t('auth.missingCreds') });

    const user = await User.findOne({
      $or: [{ username }, { email: String(username).toLowerCase() }]
    }).select('+password');

    if (!user || !(await bcrypt.compare(password, user.password)))
      return res.status(401).json({ error: req.t('auth.badCreds') });

    res.json({ token: signToken(user), user: publicUser(user) });
  } catch (err) { next(err); }
});

/* GET /api/auth/me */
router.get('/me', requireAuth, (req, res) => {
  res.json({ user: publicUser(req.user) });
});

/* POST /api/auth/deposit — demo credits only */
router.post('/deposit', requireAuth, async (req, res, next) => {
  try {
    const amount = Number(req.body.amount);
    if (!Number.isFinite(amount) || amount <= 0 || amount > 1000)
      return res.status(400).json({ error: req.t('auth.badAmount') });

    req.user.balance = Math.round((req.user.balance + amount) * 100) / 100;
    await req.user.save();
    res.json({ balance: req.user.balance });
  } catch (err) { next(err); }
});

/* PUT /api/auth/limits — responsible-gaming controls */
router.put('/limits', requireAuth, async (req, res, next) => {
  try {
    const { dailyDeposit, dailyLoss, sessionMins, selfExcludeDays } = req.body;
    const l = req.user.limits;

    if (dailyDeposit !== undefined) l.dailyDeposit = Math.max(0, Number(dailyDeposit) || 0);
    if (dailyLoss !== undefined)    l.dailyLoss    = Math.max(0, Number(dailyLoss) || 0);
    if (sessionMins !== undefined)  l.sessionMins  = Math.max(0, Number(sessionMins) || 0);
    if (selfExcludeDays) {
      const days = Math.min(365, Math.max(1, Number(selfExcludeDays)));
      l.selfExcludedUntil = new Date(Date.now() + days * 86400000);
    }

    await req.user.save();
    res.json({ limits: req.user.limits });
  } catch (err) { next(err); }
});

/* POST /api/auth/favourites/:gameId — toggle */
router.post('/favourites/:gameId', requireAuth, async (req, res, next) => {
  try {
    const id = req.params.gameId;
    const i = req.user.favourites.findIndex(f => String(f) === id);
    if (i > -1) req.user.favourites.splice(i, 1);
    else req.user.favourites.push(id);
    await req.user.save();
    res.json({ favourites: req.user.favourites });
  } catch (err) { next(err); }
});

export default router;
