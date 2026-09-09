/* ============================================================
   engines.jsx — playable demo games.

   Each engine animates locally, then reports the round to
   POST /api/casino/round, which is the authority on the wallet.
   ============================================================ */
import { useState, useRef, useEffect, useCallback } from 'react';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import { eur } from '../utils/format';

/* ------------------------------------------------------------------
   Shared bet bar + round settlement hook
   ------------------------------------------------------------------ */
function useRound(game) {
  const { user, setBalance, toast } = useApp();
  const { t } = useT();
  const [bet, setBet] = useState(1);
  const [lastWin, setLastWin] = useState(0);
  const [busy, setBusy] = useState(false);

  const canPlay = useCallback(() => {
    if (!user) { toast(t('game.loginRequired'), 'err'); return false; }
    if (bet <= 0) { toast(t('game.betPositive'), 'err'); return false; }
    if (bet > user.balance) { toast(t('game.insufficient'), 'err'); return false; }
    return true;
  }, [user, bet, toast, t]);

  /** Send the finished round to the server and sync the balance. */
  const settle = useCallback(async (win, detail = {}) => {
    try {
      const res = await api.casino.round({ gameId: game.id, bet, win, detail });
      setBalance(res.balance);
      setLastWin(win);
    } catch (err) {
      toast(err.message, 'err');
    } finally {
      setBusy(false);
    }
  }, [game.id, bet, setBalance, toast]);

  return { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t };
}

function BetBar({ bet, setBet, user, lastWin, min = 0.1, max = 100, children }) {
  const { t } = useT();
  return (
    <div className="g-bar">
      <div className="g-stat">
        <span>{t('common.stake')}</span>
        <b>
          <input
            className="stake-input"
            style={{ width: 96, height: 30, fontSize: 14 }}
            type="number" min={min} max={max} step="0.10"
            value={bet}
            onChange={(e) => setBet(Math.max(min, Math.min(max, Number(e.target.value) || min)))}
          />
        </b>
      </div>
      <div className="g-stat"><span>{t('common.balance')}</span><b>{eur(user?.balance ?? 0)}</b></div>
      <div className="g-stat"><span>{t('common.lastWin')}</span><b className="win">{eur(lastWin)}</b></div>
      <div className="grow" />
      {children}
    </div>
  );
}

/* ==================================================================
   1) SLOT — 5×3 reels, 5 paylines
   ================================================================== */
const PAYLINES = [[1,1,1,1,1],[0,0,0,0,0],[2,2,2,2,2],[0,1,2,1,0],[2,1,0,1,2]];
const PAYOUT = { 3: 4, 4: 12, 5: 45 };

export function SlotGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const strip = [game.symbol, '🍒', '🔔', '💎', '7️⃣', '🍇', '🍋', '⭐', '👑', '🍀'];

  const [grid, setGrid] = useState(() =>
    Array.from({ length: 5 }, (_, c) => [0, 1, 2].map(r => strip[(c + r) % strip.length]))
  );
  const [spinning, setSpinning] = useState([false, false, false, false, false]);
  const [hits, setHits] = useState([]);
  const [msg, setMsg] = useState(() => t('game.slot.rules'));
  const timers = useRef([]);

  useEffect(() => () => timers.current.forEach(clearTimeout), []);

  const spin = () => {
    if (busy || !canPlay()) return;
    setBusy(true);
    setHits([]);
    setSpinning([true, true, true, true, true]);
    setMsg(t('game.slot.rolling'));

    const next = Array.from({ length: 5 }, () =>
      [0, 1, 2].map(() => strip[Math.floor(Math.random() * strip.length)])
    );

    timers.current.forEach(clearTimeout);
    timers.current = next.map((_, c) =>
      setTimeout(() => {
        setSpinning(s => s.map((v, i) => (i === c ? false : v)));
        setGrid(g => g.map((col, i) => (i === c ? next[c] : col)));

        if (c === 4) {
          let win = 0;
          const hitCells = [];
          for (const line of PAYLINES) {
            const first = next[0][line[0]];
            let n = 1;
            while (n < 5 && next[n][line[n]] === first) n++;
            if (n >= 3) {
              win += (bet / 5) * PAYOUT[n];
              for (let i = 0; i < n; i++) hitCells.push(`${i}-${line[i]}`);
            }
          }
          win = Math.round(win * 100) / 100;
          setHits(hitCells);
          setMsg(win > 0 ? t('game.slot.win', { amount: eur(win) }) : t('game.slot.noWin'));
          settle(win, { grid: next });
        }
      }, 450 + c * 260)
    );
  };

  return (
    <>
      <div className="g-stage">
        <div className="reels">
          {grid.map((col, c) => (
            <div className={'reel' + (spinning[c] ? ' spinning' : '')} key={c}>
              {col.map((sym, r) => (
                <div className={'cell' + (hits.includes(`${c}-${r}`) ? ' hit' : '')} key={r}>{sym}</div>
              ))}
            </div>
          ))}
        </div>

        <div style={{ marginTop: 10, fontSize: 12, color: 'var(--txt-mute)' }}>{msg}</div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={game.minBet} max={game.maxBet}>
          <button className="btn btn-accent btn-lg" onClick={spin} disabled={busy}>
            {busy ? t('game.slot.spinning') : t('game.slot.spin')}
          </button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.slot.footer', { rtp: game.rtp, vol: t(`data.volatility.${game.volatility}`), provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   2) ROULETTE — European single zero
   ================================================================== */
const WHEEL = [0,32,15,19,4,21,2,25,17,34,6,27,13,36,11,30,8,23,10,5,24,16,33,1,20,14,31,9,22,18,29,7,28,12,35,3,26];
const REDS = new Set([1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36]);
const colorOf = (n) => (n === 0 ? 'green' : REDS.has(n) ? 'red' : 'black');

const OUTSIDE = [
  ['red', 2, 'red'], ['black', 2, 'blk'],
  ['odd', 2, ''], ['even', 2, ''],
  ['low', 2, ''], ['high', 2, ''],
  ['d1', 3, ''], ['d2', 3, ''], ['d3', 3, ''],
  ['zero', 36, '']
];

export function RouletteGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [bets, setBets] = useState(() => new Set());
  const [deg, setDeg] = useState(0);
  const [result, setResult] = useState(null);
  const [msg, setMsg] = useState(() => t('game.roulette.prompt'));
  const timer = useRef(null);

  useEffect(() => () => clearTimeout(timer.current), []);

  const seg = 360 / WHEEL.length;
  const gradient = WHEEL.map((n, i) => {
    const c = colorOf(n) === 'green' ? '#12643a' : colorOf(n) === 'red' ? '#8b1717' : '#171b22';
    return `${c} ${i * seg}deg ${(i + 1) * seg}deg`;
  }).join(',');

  const toggleBet = (key) => {
    if (busy) return;
    setBets(prev => {
      const next = new Set(prev);
      next.has(key) ? next.delete(key) : next.add(key);
      setMsg(next.size ? t('game.roulette.selected', { n: next.size }) : t('game.roulette.prompt'));
      return next;
    });
  };

  const wins = (key, n) => {
    const col = colorOf(n);
    if (key.startsWith('n')) return Number(key.slice(1)) === n ? 36 : 0;
    switch (key) {
      case 'red':   return col === 'red' ? 2 : 0;
      case 'black': return col === 'black' ? 2 : 0;
      case 'odd':   return n !== 0 && n % 2 === 1 ? 2 : 0;
      case 'even':  return n !== 0 && n % 2 === 0 ? 2 : 0;
      case 'low':   return n >= 1 && n <= 18 ? 2 : 0;
      case 'high':  return n >= 19 ? 2 : 0;
      case 'd1':    return n >= 1 && n <= 12 ? 3 : 0;
      case 'd2':    return n >= 13 && n <= 24 ? 3 : 0;
      case 'd3':    return n >= 25 ? 3 : 0;
      case 'zero':  return n === 0 ? 36 : 0;
      default:      return 0;
    }
  };

  const spin = () => {
    if (busy) return;
    if (!bets.size) { setMsg(t('game.roulette.pickFirst')); return; }
    // the unit stake applies to each selected bet
    if (!canPlay()) return;

    setBusy(true);
    const idx = Math.floor(Math.random() * WHEEL.length);
    const n = WHEEL[idx];
    setDeg(d => d + 360 * 5 + (360 - idx * seg - seg / 2));
    setMsg(t('game.roulette.rolling'));

    timer.current = setTimeout(() => {
      setResult(n);
      let win = 0;
      bets.forEach(k => { win += bet * wins(k, n); });
      win = Math.round(win * 100) / 100;
      const colour = t(`game.roulette.colors.${colorOf(n)}`);
      setMsg(win > 0
        ? t('game.roulette.win', { n, color: colour, amount: eur(win) })
        : t('game.roulette.lose', { n, color: colour }));
      settle(win, { number: n, bets: [...bets] });
    }, 4600);
  };

  return (
    <>
      <div className="g-stage">
        <div className="wheel-wrap">
          <div className="wheel-ptr" />
          <div className="wheel" style={{ background: `conic-gradient(${gradient})`, transform: `rotate(${deg}deg)` }}>
            <div
              className="wheel-center"
              style={{ color: result == null ? 'var(--txt)' : colorOf(result) === 'red' ? '#ff6b6b' : colorOf(result) === 'green' ? '#3ddc84' : 'var(--txt)' }}
            >
              {result ?? '—'}
            </div>
          </div>
        </div>

        <div style={{ marginTop: 12, fontSize: 12, color: 'var(--txt-mute)' }}>{msg}</div>

        <div className="rt-board">
          {OUTSIDE.map(([key, , cls]) => (
            <button
              key={key}
              className={`rt-bet ${cls}${bets.has(key) ? ' on' : ''}`}
              onClick={() => toggleBet(key)}
            >
              {t(`game.roulette.bets.${key}`)}
            </button>
          ))}
        </div>

        <div className="rt-board" style={{ gridTemplateColumns: 'repeat(12,1fr)', marginTop: 6 }}>
          {Array.from({ length: 36 }, (_, i) => i + 1).map(n => (
            <button
              key={n}
              className={`rt-bet ${colorOf(n) === 'red' ? 'red' : 'blk'}${bets.has('n' + n) ? ' on' : ''}`}
              style={{ fontSize: 10 }}
              onClick={() => toggleBet('n' + n)}
            >
              {n}
            </button>
          ))}
        </div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.1} max={500}>
          <button className="btn btn-accent btn-lg" onClick={spin} disabled={busy}>
            {busy ? t('game.roulette.spinning') : t('game.roulette.spin')}
          </button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.roulette.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   3) BLACKJACK
   ================================================================== */
const SUITS = [['♠', false], ['♥', true], ['♦', true], ['♣', false]];
const RANKS = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];

const drawCard = () => {
  const [suit, red] = SUITS[Math.floor(Math.random() * 4)];
  return { rank: RANKS[Math.floor(Math.random() * 13)], suit, red };
};

const handValue = (hand) => {
  let total = 0, aces = 0;
  for (const c of hand) {
    if (c.rank === 'A') { total += 11; aces++; }
    else if (['J','Q','K'].includes(c.rank)) total += 10;
    else total += Number(c.rank);
  }
  while (total > 21 && aces) { total -= 10; aces--; }
  return total;
};

function PlayingCard({ card, hidden }) {
  if (hidden) return <div className="pcard back" />;
  return (
    <div className={'pcard' + (card.red ? ' red' : '')}>
      <span>{card.rank}{card.suit}</span>
      <span className="b">{card.rank}{card.suit}</span>
    </div>
  );
}

export function BlackjackGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [player, setPlayer] = useState([]);
  const [dealer, setDealer] = useState([]);
  const [live, setLive] = useState(false);
  const [reveal, setReveal] = useState(false);
  const [msg, setMsg] = useState(() => t('game.blackjack.prompt'));

  const finish = (text, win, dh = dealer) => {
    setLive(false);
    setReveal(true);
    setDealer(dh);
    setMsg(text);
    settle(Math.round(win * 100) / 100, { player: handValue(player), dealer: handValue(dh) });
  };

  const deal = () => {
    if (busy || !canPlay()) return;
    setBusy(true);
    const ph = [drawCard(), drawCard()];
    const dh = [drawCard(), drawCard()];
    setPlayer(ph); setDealer(dh); setReveal(false); setLive(true);
    setMsg(t('game.blackjack.yourTurn'));

    if (handValue(ph) === 21) {
      setLive(false); setReveal(true);
      setMsg(t('game.blackjack.blackjack'));
      settle(Math.round(bet * 2.5 * 100) / 100, { blackjack: true });
    }
  };

  const hit = () => {
    if (!live) return;
    const ph = [...player, drawCard()];
    setPlayer(ph);
    const v = handValue(ph);
    if (v > 21) {
      setLive(false); setReveal(true);
      setMsg(t('game.blackjack.bust', { v }));
      settle(0, { bust: v });
    }
  };

  const stand = () => {
    if (!live) return;
    const dh = [...dealer];
    while (handValue(dh) < 17) dh.push(drawCard());
    const p = handValue(player), d = handValue(dh);

    if (d > 21)      finish(t('game.blackjack.dealerBust', { d }), bet * 2, dh);
    else if (p > d)  finish(t('game.blackjack.win', { p, d }), bet * 2, dh);
    else if (p === d)finish(t('game.blackjack.push', { p, d }), bet, dh);
    else             finish(t('game.blackjack.lose', { d, p }), 0, dh);
  };

  return (
    <>
      <div className="g-stage">
        <div style={{ fontSize: 12, color: 'var(--txt-mute)', marginBottom: 6 }}>
          {t('game.blackjack.dealer')} {dealer.length > 0 && (reveal ? `(${handValue(dealer)})` : '(?)')}
        </div>
        <div className="cards-row">
          {dealer.map((c, i) => <PlayingCard key={i} card={c} hidden={!reveal && i === 1} />)}
        </div>

        <div style={{ fontSize: 12, color: 'var(--txt-mute)', margin: '14px 0 6px' }}>
          {t('game.blackjack.player')} {player.length > 0 && `(${handValue(player)})`}
        </div>
        <div className="cards-row">
          {player.map((c, i) => <PlayingCard key={i} card={c} />)}
        </div>

        <div style={{ marginTop: 12, fontWeight: 700, minHeight: 22 }}>{msg}</div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.5} max={200}>
          <button className="btn btn-primary" onClick={deal} disabled={live}>{t('game.blackjack.deal')}</button>
          <button className="btn btn-ghost" onClick={hit} disabled={!live}>{t('game.blackjack.hit')}</button>
          <button className="btn btn-ghost" onClick={stand} disabled={!live}>{t('game.blackjack.stand')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.blackjack.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   4) CRASH
   ================================================================== */
export function CrashGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const canvasRef = useRef(null);
  const rafRef = useRef(null);
  const startRef = useRef(0);
  const bustRef = useRef(2);
  const multRef = useRef(1);

  const [mult, setMult] = useState(1);
  const [running, setRunning] = useState(false);
  const [state, setState] = useState('idle'); // idle | running | bust | cashed
  const [history, setHistory] = useState([]);
  const [msg, setMsg] = useState(() => t('game.crash.prompt'));

  const draw = useCallback((m) => {
    const cv = canvasRef.current;
    if (!cv) return;
    const ctx = cv.getContext('2d');
    ctx.clearRect(0, 0, cv.width, cv.height);

    ctx.strokeStyle = 'rgba(255,255,255,.06)';
    for (let i = 1; i < 5; i++) {
      ctx.beginPath(); ctx.moveTo(0, i * 38); ctx.lineTo(cv.width, i * 38); ctx.stroke();
    }

    const prog = Math.min(1, (m - 1) / 9);
    ctx.beginPath();
    ctx.moveTo(0, cv.height);
    for (let x = 0; x <= cv.width * prog; x += 6) {
      const p = x / cv.width;
      ctx.lineTo(x, cv.height - Math.pow(p, 1.6) * cv.height * 1.5);
    }
    ctx.strokeStyle = '#ffcc00';
    ctx.lineWidth = 3;
    ctx.stroke();
    ctx.lineTo(cv.width * prog, cv.height);
    ctx.lineTo(0, cv.height);
    ctx.closePath();
    ctx.fillStyle = 'rgba(255,204,0,.13)';
    ctx.fill();
  }, []);

  useEffect(() => { draw(1); return () => cancelAnimationFrame(rafRef.current); }, [draw]);

  const endRound = (at) => {
    cancelAnimationFrame(rafRef.current);
    setRunning(false);
    startRef.current = 0;
    setHistory(h => [at, ...h].slice(0, 12));
  };

  const tick = (ts) => {
    if (!startRef.current) startRef.current = ts;
    const elapsed = (ts - startRef.current) / 1000;
    const m = Math.round(Math.pow(1.0718, elapsed * 8) * 100) / 100;
    multRef.current = m;

    if (m >= bustRef.current) {
      setMult(bustRef.current);
      setState('bust');
      setMsg(t('game.crash.bust', { mult: bustRef.current.toFixed(2) }));
      endRound(bustRef.current);
      settle(0, { bust: bustRef.current });
      return;
    }
    setMult(m);
    draw(m);
    rafRef.current = requestAnimationFrame(tick);
  };

  const start = () => {
    if (running || !canPlay()) return;
    setBusy(true);
    const r = Math.random();
    bustRef.current = Math.min(100, Math.max(1, Math.round((0.97 / (1 - r)) * 100) / 100));
    multRef.current = 1;
    setMult(1);
    setState('running');
    setRunning(true);
    setMsg(t('game.crash.running'));
    rafRef.current = requestAnimationFrame(tick);
  };

  const cashOut = () => {
    if (!running) return;
    const m = multRef.current;
    const win = Math.round(bet * m * 100) / 100;
    setState('cashed');
    setMsg(t('game.crash.cashed', { mult: m.toFixed(2), amount: eur(win) }));
    endRound(m);
    settle(win, { cashedAt: m });
  };

  return (
    <>
      <div className="g-stage">
        <div className="crash-box">
          <canvas ref={canvasRef} width="600" height="190" style={{ width: '100%', height: '100%' }} />
          <div className={'crash-mult' + (state === 'bust' ? ' bust' : state === 'cashed' ? ' cashed' : '')}>
            {mult.toFixed(2)}×{state === 'bust' ? ' 💥' : ''}
          </div>
        </div>

        <div style={{ marginTop: 10, fontSize: 12, color: 'var(--txt-mute)' }}>{msg}</div>

        <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap', justifyContent: 'center', marginTop: 10 }}>
          {history.map((h, i) => (
            <span className="pay-chip" key={i} style={{ color: h < 2 ? 'var(--live)' : 'var(--win)' }}>
              {h.toFixed(2)}×
            </span>
          ))}
        </div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.1} max={200}>
          <button className="btn btn-accent btn-lg" onClick={start} disabled={running}>{t('game.crash.start')}</button>
          <button className="btn btn-primary btn-lg" onClick={cashOut} disabled={!running}>{t('game.crash.cash')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.crash.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   5) MINES
   ================================================================== */
const CELLS = 25, BOMBS = 3;

export function MinesGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [bombs, setBombs] = useState(() => new Set());
  const [opened, setOpened] = useState(() => new Set());
  const [live, setLive] = useState(false);
  const [msg, setMsg] = useState(() => t('game.mines.prompt'));

  const multiplier = (k) => {
    let m = 1;
    for (let i = 0; i < k; i++) m *= (CELLS - i) / (CELLS - BOMBS - i);
    return Math.round(m * 0.97 * 100) / 100;
  };

  const start = () => {
    if (live || !canPlay()) return;
    setBusy(true);
    const b = new Set();
    while (b.size < BOMBS) b.add(Math.floor(Math.random() * CELLS));
    setBombs(b);
    setOpened(new Set());
    setLive(true);
    setMsg(t('game.mines.playing'));
  };

  const open = (i) => {
    if (!live || opened.has(i)) return;
    if (bombs.has(i)) {
      setLive(false);
      setOpened(new Set([...opened, i]));
      setMsg(t('game.mines.boom'));
      settle(0, { hitMine: i });
      return;
    }
    const next = new Set([...opened, i]);
    setOpened(next);
    setMsg(t('game.mines.safe', { n: next.size, mult: multiplier(next.size) }));
  };

  const cashOut = () => {
    if (!live || opened.size === 0) { setMsg(t('game.mines.needOne')); return; }
    const win = Math.round(bet * multiplier(opened.size) * 100) / 100;
    setLive(false);
    setMsg(t('game.mines.cashed', { mult: multiplier(opened.size), amount: eur(win) }));
    settle(win, { safe: opened.size });
  };

  return (
    <>
      <div className="g-stage">
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(5,1fr)', gap: 6, maxWidth: 320, margin: '0 auto' }}>
          {Array.from({ length: CELLS }, (_, i) => {
            const isOpen = opened.has(i);
            const isBomb = bombs.has(i);
            const showBomb = !live && isBomb && opened.size > 0;
            return (
              <button
                key={i}
                className="rt-bet"
                style={{
                  height: 52, fontSize: 18,
                  background: isOpen && isBomb ? 'var(--live)'
                    : isOpen ? 'rgba(33,192,122,.25)' : undefined
                }}
                onClick={() => open(i)}
                disabled={!live}
              >
                {isOpen ? (isBomb ? '💣' : '💎') : showBomb ? '💣' : ''}
              </button>
            );
          })}
        </div>

        <div style={{ marginTop: 12, fontWeight: 700, minHeight: 22 }}>{msg}</div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.1} max={100}>
          <button className="btn btn-accent" onClick={start} disabled={live}>{t('game.mines.start')}</button>
          <button className="btn btn-primary" onClick={cashOut} disabled={!live}>{t('game.mines.cash')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.mines.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   6) DICE
   ================================================================== */
const FACES = ['⚀','⚁','⚂','⚃','⚄','⚅'];

export function DiceGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [face, setFace] = useState('🎲🎲');
  const [sel, setSel] = useState('under');
  const [msg, setMsg] = useState(() => t('game.dice.prompt'));
  const iv = useRef(null);

  useEffect(() => () => clearInterval(iv.current), []);

  const OPTIONS = [['under', 2], ['seven', 5], ['over', 2]];

  const roll = () => {
    if (busy || !canPlay()) return;
    setBusy(true);
    let n = 0;
    iv.current = setInterval(() => {
      setFace(FACES[Math.floor(Math.random() * 6)] + FACES[Math.floor(Math.random() * 6)]);
      if (++n > 12) {
        clearInterval(iv.current);
        const a = 1 + Math.floor(Math.random() * 6);
        const b = 1 + Math.floor(Math.random() * 6);
        setFace(FACES[a - 1] + FACES[b - 1]);
        const sum = a + b;
        const pay = OPTIONS.find(o => o[0] === sel)[1];
        const hit = sel === 'seven' ? sum === 7 : sel === 'under' ? sum < 7 : sum > 7;
        const win = hit ? Math.round(bet * pay * 100) / 100 : 0;
        setMsg(hit ? t('game.dice.win', { sum, amount: eur(win) }) : t('game.dice.lose', { sum }));
        settle(win, { sum, pick: sel });
      }
    }, 70);
  };

  return (
    <>
      <div className="g-stage">
        <div style={{ fontSize: 56, letterSpacing: 10 }}>{face}</div>
        <div style={{ marginTop: 8, fontWeight: 700, minHeight: 22 }}>{msg}</div>

        <div className="rt-board" style={{ gridTemplateColumns: 'repeat(3,1fr)', maxWidth: 420, margin: '14px auto 0' }}>
          {OPTIONS.map(([key]) => (
            <button
              key={key}
              className={'rt-bet' + (sel === key ? ' on' : '')}
              onClick={() => !busy && setSel(key)}
            >
              {t('game.dice.' + key)}
            </button>
          ))}
        </div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.1} max={200}>
          <button className="btn btn-accent btn-lg" onClick={roll} disabled={busy}>{t('game.dice.roll')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.dice.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   7) MONEY WHEEL
   ================================================================== */
const SEGMENTS = [1,2,5,1,10,1,2,20,1,5,2,40,1,2,5,1,10,2,1,5];
const SEG_COLORS = { 1:'#1d4ed8', 2:'#0f766e', 5:'#a16207', 10:'#7c2d12', 20:'#701a75', 40:'#991b1b' };

export function WheelGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [sel, setSel] = useState(1);
  const [deg, setDeg] = useState(0);
  const [result, setResult] = useState(null);
  const [msg, setMsg] = useState(() => t('game.wheel.prompt'));
  const timer = useRef(null);

  useEffect(() => () => clearTimeout(timer.current), []);

  const seg = 360 / SEGMENTS.length;
  const gradient = SEGMENTS.map((v, i) => `${SEG_COLORS[v]} ${i * seg}deg ${(i + 1) * seg}deg`).join(',');

  const spin = () => {
    if (busy || !canPlay()) return;
    setBusy(true);
    const idx = Math.floor(Math.random() * SEGMENTS.length);
    const val = SEGMENTS[idx];
    setDeg(d => d + 360 * 6 + (360 - idx * seg - seg / 2));
    setMsg(t('game.wheel.rolling'));

    timer.current = setTimeout(() => {
      setResult(val);
      const win = val === sel ? Math.round(bet * val * 100) / 100 : 0;
      setMsg(win ? t('game.wheel.win', { v: val, amount: eur(win) }) : t('game.wheel.lose', { v: val, sel }));
      settle(win, { landed: val, pick: sel });
    }, 4600);
  };

  return (
    <>
      <div className="g-stage">
        <div className="wheel-wrap">
          <div className="wheel-ptr" />
          <div className="wheel" style={{ background: `conic-gradient(${gradient})`, transform: `rotate(${deg}deg)` }}>
            <div className="wheel-center">{result ? `${result}×` : '—'}</div>
          </div>
        </div>

        <div style={{ marginTop: 12, fontWeight: 700, minHeight: 22 }}>{msg}</div>

        <div className="rt-board" style={{ gridTemplateColumns: 'repeat(6,1fr)', maxWidth: 460, margin: '12px auto 0' }}>
          {[1, 2, 5, 10, 20, 40].map(v => (
            <button key={v} className={'rt-bet' + (sel === v ? ' on' : '')} onClick={() => !busy && setSel(v)}>
              {v}×
            </button>
          ))}
        </div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.5} max={500}>
          <button className="btn btn-accent btn-lg" onClick={spin} disabled={busy}>{t('game.wheel.spin')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.wheel.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   8) BACCARAT
   ================================================================== */
export function BaccaratGame({ game }) {
  const { user, bet, setBet, lastWin, busy, setBusy, canPlay, settle, t } = useRound(game);
  const [player, setPlayer] = useState([]);
  const [bank, setBank] = useState([]);
  const [sel, setSel] = useState('player');
  const [msg, setMsg] = useState(() => t('game.baccarat.prompt'));

  const cardValue = (c) => (c.rank === 'A' ? 1 : ['10','J','Q','K'].includes(c.rank) ? 0 : Number(c.rank));
  const total = (hand) => hand.reduce((a, c) => a + cardValue(c), 0) % 10;

  const OPTIONS = [['player', 2], ['bank', 1.95], ['tie', 9]];

  const deal = () => {
    if (busy || !canPlay()) return;
    setBusy(true);
    const ph = [drawCard(), drawCard()];
    const bh = [drawCard(), drawCard()];
    if (total(ph) <= 5) ph.push(drawCard());
    if (total(bh) <= 5) bh.push(drawCard());
    setPlayer(ph); setBank(bh);

    const p = total(ph), b = total(bh);
    const outcome = p > b ? 'player' : b > p ? 'bank' : 'tie';
    const pay = OPTIONS.find(o => o[0] === sel)[1];
    const win = outcome === sel ? Math.round(bet * pay * 100) / 100 : 0;
    const label = t('game.baccarat.' + outcome);

    setMsg(win
      ? t('game.baccarat.win', { side: label, p, b, amount: eur(win) })
      : t('game.baccarat.lose', { side: label, p, b }));
    settle(win, { player: p, bank: b, pick: sel });
  };

  return (
    <>
      <div className="g-stage">
        <div style={{ display: 'flex', gap: 26, justifyContent: 'center', flexWrap: 'wrap' }}>
          <div>
            <div style={{ fontSize: 12, color: 'var(--txt-mute)', marginBottom: 6 }}>
              {t('game.baccarat.player')} {player.length > 0 && `(${total(player)})`}
            </div>
            <div className="cards-row">{player.map((c, i) => <PlayingCard key={i} card={c} />)}</div>
          </div>
          <div>
            <div style={{ fontSize: 12, color: 'var(--txt-mute)', marginBottom: 6 }}>
              {t('game.baccarat.bank')} {bank.length > 0 && `(${total(bank)})`}
            </div>
            <div className="cards-row">{bank.map((c, i) => <PlayingCard key={i} card={c} />)}</div>
          </div>
        </div>

        <div style={{ marginTop: 12, fontWeight: 700, minHeight: 22 }}>{msg}</div>

        <div className="rt-board" style={{ gridTemplateColumns: 'repeat(3,1fr)', maxWidth: 420, margin: '12px auto 0' }}>
          {OPTIONS.map(([key]) => (
            <button key={key} className={'rt-bet' + (sel === key ? ' on' : '')} onClick={() => !busy && setSel(key)}>
              {t('game.baccarat.bet' + key.charAt(0).toUpperCase() + key.slice(1))}
            </button>
          ))}
        </div>

        <BetBar bet={bet} setBet={setBet} user={user} lastWin={lastWin} min={0.5} max={500}>
          <button className="btn btn-accent btn-lg" onClick={deal} disabled={busy}>{t('game.baccarat.deal')}</button>
        </BetBar>
      </div>
      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12 }}>
        {t('game.baccarat.footer', { provider: game.provider })}
      </p>
    </>
  );
}

/* ==================================================================
   Dispatcher
   ================================================================== */
const ENGINES = {
  slot: SlotGame,
  roulette: RouletteGame,
  blackjack: BlackjackGame,
  crash: CrashGame,
  mines: MinesGame,
  dice: DiceGame,
  wheel: WheelGame,
  baccarat: BaccaratGame
};

export default function GameEngine({ game }) {
  const Engine = ENGINES[game.engine] || SlotGame;
  return <Engine game={game} />;
}
