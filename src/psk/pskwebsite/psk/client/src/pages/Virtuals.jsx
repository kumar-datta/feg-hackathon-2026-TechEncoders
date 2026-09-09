import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { eur, thumbGradient } from '../utils/format';

function VirtualRace({ virtual, gameId }) {
  const { user, setBalance, toast } = useApp();
  const { t } = useT();

  const count = Math.max(2, virtual.runners || 6);
  const [runners] = useState(() =>
    t('virtuals.colours').slice(0, count).map((c, i) => ({
      name: `${c} #${i + 1}`,
      odds: Math.round((1.8 + Math.random() * 9) * 100) / 100
    }))
  );

  const [sel, setSel] = useState(0);
  const [bet, setBet] = useState(2);
  const [positions, setPositions] = useState(() => runners.map(() => 0));
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState(() => t('virtuals.racePrompt'));

  const start = () => {
    if (busy) return;
    if (!user) { toast(t('game.loginRequired'), 'err'); return; }
    if (bet > user.balance) { toast(t('game.insufficient'), 'err'); return; }

    setBusy(true);
    setMsg(t('virtuals.running'));
    const pos = runners.map(() => 0);
    let ticks = 0;

    const iv = setInterval(async () => {
      ticks++;
      runners.forEach((_, i) => { pos[i] += Math.random() * 3; });
      setPositions([...pos]);

      if (ticks >= 18) {
        clearInterval(iv);
        const winner = pos.indexOf(Math.max(...pos));
        const win = winner === sel ? Math.round(bet * runners[sel].odds * 100) / 100 : 0;
        setMsg(win
          ? t('virtuals.winner', { name: runners[winner].name, amount: eur(win) })
          : t('virtuals.loser', { name: runners[winner].name }));

        try {
          const res = await api.casino.round({
            gameId, bet, win, detail: { race: virtual.slug, winner: runners[winner].name, pick: runners[sel].name }
          });
          setBalance(res.balance);
        } catch (err) {
          toast(err.message, 'err');
        }
        setBusy(false);
      }
    }, 220);
  };

  return (
    <>
      <p style={{ color: 'var(--txt-dim)', fontSize: 13.5 }}>{virtual.description}</p>

      <div className="rt-board" style={{ gridTemplateColumns: 'repeat(2,1fr)', margin: '14px 0' }}>
        {runners.map((rn, i) => (
          <button
            key={rn.name}
            className={'rt-bet' + (sel === i ? ' on' : '')}
            style={{ height: 40, justifyContent: 'space-between', padding: '0 12px', display: 'flex', alignItems: 'center' }}
            onClick={() => !busy && setSel(i)}
          >
            <span>{rn.name}</span>
            <span style={{ color: 'var(--accent)' }}>{rn.odds.toFixed(2)}</span>
          </button>
        ))}
      </div>

      <div className="g-stage" style={{ padding: 12 }}>
        <div style={{ fontSize: 13, textAlign: 'left', fontFamily: 'monospace', lineHeight: 1.9 }}>
          {runners.map((rn, i) => (
            <div key={rn.name}>
              {rn.name.padEnd(14, ' ')} {'▬'.repeat(Math.floor(positions[i]))}
            </div>
          ))}
        </div>
      </div>

      <div style={{ marginTop: 12, fontWeight: 700, minHeight: 22 }}>{msg}</div>

      <div className="g-bar">
        <div className="g-stat">
          <span>{t('common.stake')}</span>
          <b>
            <input
              className="stake-input"
              style={{ width: 90, height: 30, fontSize: 14 }}
              type="number" min="0.5" step="0.5"
              value={bet}
              onChange={(e) => setBet(Math.max(0.5, Number(e.target.value) || 0.5))}
            />
          </b>
        </div>
        <div className="g-stat"><span>{t('common.balance')}</span><b>{eur(user?.balance ?? 0)}</b></div>
        <div className="grow" />
        <button className="btn btn-accent btn-lg" onClick={start} disabled={busy}>{t('virtuals.startRound')}</button>
      </div>
    </>
  );
}

export default function Virtuals() {
  const { setModal } = useApp();
  const { t } = useT();
  const [virtuals, setVirtuals] = useState([]);
  const [gameId, setGameId] = useState(null);
  const [tick, setTick] = useState(0);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    Promise.all([api.content.virtuals(), api.casino.games({ category: 'instant', limit: 1 })])
      .then(([v, g]) => { setVirtuals(v.virtuals); setGameId(g.games[0]?.id); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => {
    const id = setInterval(() => setTick(t => t + 1), 1000);
    return () => clearInterval(id);
  }, []);

  const open = (v) => setModal({
    title: `${v.icon} ${v.name}`,
    wide: true,
    content: <VirtualRace virtual={v} gameId={gameId} />
  });

  const countdown = (i) => {
    const secs = 40 + ((Math.floor(Date.now() / 1000) * 7 + i * 23) % 200);
    return `${String(Math.floor(secs / 60)).padStart(2, '0')}:${String(secs % 60).padStart(2, '0')}`;
  };

  return (
    <div className="page" style={{ maxWidth: 1400 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.virtuals')}</div>
      <h1 className="page-title">🎮 {t('virtuals.title')}</h1>
      <p className="page-lede">{t('virtuals.lede')}</p>

      {error && <ErrorBox error={error} />}
      {loading && <Loader />}

      {!loading && (
        <div className="game-grid" style={{ marginTop: 24 }}>
          {virtuals.map(v => (
            <div className="game-card" key={v.slug}>
              <div className="game-thumb" style={{ background: thumbGradient(v.hueA, v.hueB) }}>
                <span className="game-badge">{v.intervalLabel}</span>
                <span className="sym">{v.symbol}</span>
                <div className="game-ovl">
                  <button className="btn btn-accent" onClick={() => open(v)}>{t('virtuals.start')}</button>
                </div>
                <div className="game-name">
                  {v.name}
                  <div className="game-prov">{t('virtuals.newRoundEvery', { interval: v.intervalLabel })}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}

      {!loading && virtuals.length > 0 && (
        <section className="sec">
          <div className="sec-hd"><h2>{t('virtuals.schedule')}</h2></div>
          <div className="panel tbl-wrap">
            <table className="tbl">
              <thead>
                <tr><th>{t('virtuals.tbl.game')}</th><th>{t('virtuals.tbl.next')}</th><th>{t('virtuals.tbl.interval')}</th><th>{t('virtuals.tbl.runners')}</th><th className="num">{t('virtuals.tbl.status')}</th></tr>
              </thead>
              <tbody key={tick}>
                {virtuals.map((v, i) => (
                  <tr key={v.slug}>
                    <td>{v.icon} {v.name}</td>
                    <td style={{ fontWeight: 700, color: 'var(--accent)', fontVariantNumeric: 'tabular-nums' }}>
                      {countdown(i)}
                    </td>
                    <td>{v.intervalLabel}</td>
                    <td>{v.runners || '—'}</td>
                    <td className="num"><span style={{ color: 'var(--win)' }}>{t('virtuals.open')}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}

      <section className="sec prose">
        <h2>{t('virtuals.whatTitle')}</h2>
        <p>{t('virtuals.whatBody')}</p>
        <h3>{t('virtuals.howTitle')}</h3>
        <p>{t('virtuals.howBody')}</p>
      </section>
    </div>
  );
}
