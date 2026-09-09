import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { eur, dateOnly } from '../utils/format';

/* Pay table by number of matches — illustrative, not a real prize fund model. */
const PAY_TABLE = { 3: 2, 4: 8, 5: 40, 6: 400, 7: 5000, 8: 9000, 9: 14000, 10: 20000 };

function LottoTicket({ lottery, onClose }) {
  const { user, setBalance, toast } = useApp();
  const { t } = useT();
  const [selected, setSelected] = useState(() => new Set());
  const [drawn, setDrawn] = useState([]);
  const [bet, setBet] = useState(lottery.price);
  const [busy, setBusy] = useState(false);
  const [msg, setMsg] = useState(() => t('loto.ticketPrompt', { pick: lottery.pick, max: lottery.max }));

  const toggle = (n) => {
    if (busy) return;
    setSelected(prev => {
      const next = new Set(prev);
      if (next.has(n)) next.delete(n);
      else if (next.size < lottery.pick) next.add(n);
      return next;
    });
  };

  const random = () => {
    if (busy) return;
    const next = new Set();
    while (next.size < lottery.pick) next.add(1 + Math.floor(Math.random() * lottery.max));
    setSelected(next);
    setDrawn([]);
  };

  const draw = async () => {
    if (busy) return;
    if (!user) { toast(t('game.loginRequired'), 'err'); return; }
    if (selected.size !== lottery.pick) { toast(t('loto.pickExactly', { pick: lottery.pick }), 'err'); return; }
    if (bet > user.balance) { toast(t('game.insufficient'), 'err'); return; }

    setBusy(true);
    setDrawn([]);
    setMsg(t('loto.drawingNow'));

    const pool = new Set();
    while (pool.size < lottery.pick) pool.add(1 + Math.floor(Math.random() * lottery.max));
    const numbers = [...pool];

    // reveal one ball at a time
    numbers.forEach((n, i) => {
      setTimeout(() => setDrawn(d => [...d, n]), 420 * (i + 1));
    });

    setTimeout(async () => {
      const hits = numbers.filter(n => selected.has(n)).length;
      const win = hits >= 3 ? Math.round(bet * (PAY_TABLE[hits] || 2) * 100) / 100 : 0;
      setMsg(hits >= 3
        ? t('loto.hits', { n: hits, amount: eur(win) })
        : t('loto.noHits', { n: hits }));

      try {
        // lottery rounds settle through the same wallet endpoint as casino games
        const res = await api.casino.round({
          gameId: lottery.gameId, bet, win, detail: { picked: [...selected], drawn: numbers, hits }
        });
        setBalance(res.balance);
      } catch (err) {
        toast(err.message, 'err');
      }
      setBusy(false);
    }, 420 * (numbers.length + 1));
  };

  return (
    <div className="g-stage">
      <p style={{ fontSize: 13, color: 'var(--txt-dim)' }}>
        {lottery.name} · {t('loto.drawing', { info: lottery.drawInfo })}
      </p>

      <div className="ball-grid" style={{ margin: '14px 0' }}>
        {Array.from({ length: lottery.max }, (_, i) => i + 1).map(n => (
          <button
            key={n}
            className={
              'ball' +
              (drawn.includes(n) ? ' drawn' : selected.has(n) ? ' on' : '')
            }
            onClick={() => toggle(n)}
          >
            {n}
          </button>
        ))}
      </div>

      <div style={{ fontWeight: 700, minHeight: 22 }}>
        {msg} {!busy && drawn.length === 0 && `(${selected.size}/${lottery.pick})`}
      </div>

      <div className="g-bar">
        <div className="g-stat">
          <span>{t('common.stake')}</span>
          <b>
            <input
              className="stake-input"
              style={{ width: 96, height: 30, fontSize: 14 }}
              type="number" min="0.5" step="0.5"
              value={bet}
              onChange={(e) => setBet(Math.max(0.5, Number(e.target.value) || 0.5))}
            />
          </b>
        </div>
        <div className="g-stat"><span>{t('common.balance')}</span><b>{eur(user?.balance ?? 0)}</b></div>
        <div className="grow" />
        <button className="btn btn-ghost" onClick={random} disabled={busy}>{t('loto.randomPick')}</button>
        <button className="btn btn-accent btn-lg" onClick={draw} disabled={busy}>{t('loto.draw')}</button>
      </div>

      <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginTop: 12, textAlign: 'left' }}>
        {t('loto.ticketFooter', { jackpot: eur(lottery.jackpot), price: eur(lottery.price) })}
      </p>
    </div>
  );
}

export default function Loto() {
  const { setModal } = useApp();
  const { t } = useT();
  const [lotteries, setLotteries] = useState([]);
  const [draws, setDraws] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    Promise.all([api.content.lotteries(), api.casino.games({ category: 'instant', limit: 1 })])
      .then(([d]) => { setLotteries(d.lotteries); setDraws(d.draws); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  useEffect(() => { load(); }, [load]);

  const openTicket = async (lottery) => {
    // lottery rounds are booked against an instant-game record so the wallet
    // endpoint has a valid game reference
    let gameId = null;
    try {
      const d = await api.casino.games({ category: 'instant', limit: 1 });
      gameId = d.games[0]?.id;
    } catch { /* handled below */ }

    setModal({
      title: `🎱 ${lottery.name}`,
      wide: true,
      content: <LottoTicket lottery={{ ...lottery, gameId }} />
    });
  };

  return (
    <div className="page">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.loto')}</div>
      <h1 className="page-title">🎱 {t('loto.title')}</h1>
      <p className="page-lede">{t('loto.lede')}</p>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && (
        <div className="tile-grid" style={{ marginTop: 24 }}>
          {lotteries.map(l => (
            <div className="panel" key={l.slug}>
              <div className="panel-hd">
                <span>{l.name}</span>
                <span style={{ color: 'var(--accent)' }}>{eur(l.jackpot)}</span>
              </div>
              <div className="panel-bd">
                <p style={{ fontSize: 13, color: 'var(--txt-dim)', marginBottom: 6 }}>
                  {t('loto.pickRange', { pick: l.pick, max: l.max })}
                </p>
                <p style={{ fontSize: 12, color: 'var(--txt-mute)', marginBottom: 14 }}>
                  {t('loto.drawing', { info: l.drawInfo })}
                </p>
                <button className="btn btn-accent btn-block" onClick={() => openTicket(l)}>
                  {t('loto.buyTicket')}
                </button>
              </div>
            </div>
          ))}
        </div>
      )}

      {draws.length > 0 && (
        <section className="sec">
          <div className="sec-hd"><h2>{t('loto.lastDraws')}</h2></div>
          <div className="panel tbl-wrap">
            <table className="tbl">
              <thead>
                <tr><th>{t('loto.tbl.game')}</th><th>{t('loto.tbl.round')}</th><th>{t('loto.tbl.date')}</th><th>{t('loto.tbl.numbers')}</th><th className="num">{t('loto.tbl.fund')}</th></tr>
              </thead>
              <tbody>
                {draws.map(d => (
                  <tr key={d._id}>
                    <td>{d.lottery?.name}</td>
                    <td>{d.round}</td>
                    <td>{dateOnly(d.drawnAt)}</td>
                    <td style={{ fontWeight: 700, color: 'var(--accent)' }}>{d.numbers.join(' · ')}</td>
                    <td className="num">{eur(d.fund)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      )}

      <section className="sec prose">
        <h2>{t('loto.howTitle')}</h2>
        <p>{t('loto.howBody')}</p>
        <h3>{t('loto.responsibleTitle')}</h3>
        <p>
          {t('loto.responsibleBody')}{' '}
          <Link to="/odgovorno-igranje">{t('footer.responsible')}</Link>.
        </p>
      </section>
    </div>
  );
}
