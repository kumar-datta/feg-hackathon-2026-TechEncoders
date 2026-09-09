import { useEffect, useMemo, useRef, useState, useCallback } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import { eur, num, dateTime } from '../utils/format';

const DEDUCTION_RATE = 0.10;
const QUICK = [2, 5, 10, 20, 50];

/**
 * Deterministic "social proof" count derived from the slip itself, so it stays
 * stable while the user is on the page instead of flickering on every render.
 */
function seededCount(slip) {
  const seed = slip.reduce((acc, p) => acc + String(p.eventId).length + p.marketKey.charCodeAt(0), 7);
  let a = (seed * 2654435761) >>> 0;
  a ^= a >>> 15; a = Math.imul(a, 2246822507); a ^= a >>> 13;
  return 120 + (a >>> 0) % 2600;
}

export default function Checkout() {
  const { slip, stake, setStake, totalOdds, placeTicket, user, toast, removePick } = useApp();
  const { t } = useT();
  const navigate = useNavigate();

  const [busy, setBusy] = useState(false);
  const [placed, setPlaced] = useState(null);   // the confirmed ticket
  const [showLeave, setShowLeave] = useState(false);

  /** Snapshot the figures so the success card still shows them after the slip clears. */
  const gross = stake * totalOdds;
  const deduction = gross > stake ? (gross - stake) * DEDUCTION_RATE : 0;
  const net = gross - deduction;

  const baseCount = useMemo(() => (slip.length ? seededCount(slip) : 0), [slip]);
  const [viewers, setViewers] = useState(() => 8 + Math.floor(Math.random() * 40));

  // gentle drift so the "watching now" figure feels live
  useEffect(() => {
    const id = setInterval(() => {
      setViewers(v => Math.max(5, v + Math.round((Math.random() - 0.45) * 6)));
    }, 3000);
    return () => clearInterval(id);
  }, []);

  /* ------------------------------------------------------------------
     Guard the back navigation: push a sentinel entry, and when the user
     pops it show the "you would have won X" card instead of leaving.
     ------------------------------------------------------------------ */
  const allowLeave = useRef(false);

  useEffect(() => {
    if (placed || !slip.length) return;          // nothing to protect
    window.history.pushState({ pskCheckout: true }, '');

    const onPop = () => {
      if (allowLeave.current) return;
      window.history.pushState({ pskCheckout: true }, '');
      setShowLeave(true);
    };

    window.addEventListener('popstate', onPop);
    return () => window.removeEventListener('popstate', onPop);
  }, [placed, slip.length]);

  const leaveNow = useCallback(() => {
    allowLeave.current = true;
    setShowLeave(false);
    navigate('/oklade');
  }, [navigate]);

  const requestLeave = () => {
    if (placed || !slip.length) { navigate('/oklade'); return; }
    setShowLeave(true);
  };

  const confirm = async () => {
    if (!user) {
      toast(t('checkout.loginBody'), 'err');
      navigate('/prijava');
      return;
    }
    setBusy(true);
    try {
      allowLeave.current = true;                 // the slip is gone after this
      const ticket = await placeTicket();
      setPlaced(ticket);
      toast(t('slip.placedToast', { ref: ticket.ref }));
    } catch (err) {
      allowLeave.current = false;
      toast(err.message, 'err');
    } finally {
      setBusy(false);
    }
  };

  /* ---------------- success view ---------------- */
  if (placed) {
    return (
      <div className="page narrow" style={{ maxWidth: 560 }}>
        <div className="placed-card">
          <div className="placed-icon">✓</div>
          <h1 className="placed-title">{t('checkout.placedTitle')}</h1>
          <p className="placed-body">{t('checkout.placedBody')}</p>

          <div className="placed-ref">
            <span>{t('checkout.ref')}</span>
            <strong>{placed.ref}</strong>
          </div>

          <div className="placed-rows">
            <div className="sum-row"><span>{t('checkout.stake')}</span><strong>{eur(placed.stake)}</strong></div>
            <div className="sum-row"><span>{t('checkout.pairs')}</span><strong>{placed.selections.length}</strong></div>
            <div className="sum-row"><span>{t('checkout.totalOdds')}</span><strong>{num(placed.totalOdds)}</strong></div>
            <div className="sum-row"><span>{t('checkout.placedAt')}</span><strong>{dateTime(placed.createdAt || Date.now())}</strong></div>
            <div className="sum-row total"><span>{t('checkout.potential')}</span><strong>{eur(placed.potentialNet)}</strong></div>
          </div>

          <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
            <Link className="btn btn-accent btn-lg" style={{ flex: 1 }} to="/listici">{t('checkout.myTickets')}</Link>
            <Link className="btn btn-ghost btn-lg" style={{ flex: 1 }} to="/oklade">{t('checkout.newBet')}</Link>
          </div>

          <p className="placed-note">{t('checkout.demoNote')}</p>
        </div>
      </div>
    );
  }

  /* ---------------- empty slip ---------------- */
  if (!slip.length) {
    return (
      <div className="page narrow" style={{ maxWidth: 560, textAlign: 'center' }}>
        <div style={{ fontSize: 56, marginTop: 30 }}>🎫</div>
        <h1 className="page-title">{t('checkout.emptyTitle')}</h1>
        <p className="page-lede" style={{ margin: '0 auto 22px' }}>{t('checkout.emptyBody')}</p>
        <Link className="btn btn-accent btn-lg" to="/oklade">{t('checkout.openOffer')}</Link>
      </div>
    );
  }

  /* ---------------- checkout ---------------- */
  return (
    <div className="page" style={{ maxWidth: 1100 }}>
      <div className="crumbs">
        <Link to="/">{t('common.home')}</Link> › <Link to="/oklade">{t('sportsbook.offer')}</Link> › {t('checkout.title')}
      </div>
      <h1 className="page-title">🧾 {t('checkout.title')}</h1>
      <p className="page-lede">{t('checkout.lede')}</p>

      <div className="checkout-grid">
        {/* selections */}
        <div className="panel">
          <div className="panel-hd">
            <span>{t('checkout.selections')}</span>
            <span style={{ color: 'var(--txt-mute)', fontWeight: 600 }}>{slip.length}</span>
          </div>

          <div className="tbl-wrap">
            <table className="tbl">
              <thead>
                <tr>
                  <th>{t('sportsbook.event')}</th>
                  <th>{t('checkout.marketCol')}</th>
                  <th className="num">{t('checkout.oddsCol')}</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {slip.map((p, i) => (
                  <tr key={`${p.eventId}-${p.marketKey}`}>
                    <td>
                      <div style={{ fontWeight: 600 }}>{p.eventName}</div>
                      <div style={{ fontSize: 11, color: 'var(--txt-mute)' }}>
                        {p.leagueName} · {t('slip.code')} {p.code}
                      </div>
                    </td>
                    <td><span className="chip is-active" style={{ height: 24 }}>{p.marketKey}</span></td>
                    <td className="num" style={{ fontWeight: 800, color: 'var(--accent)' }}>{num(p.odds)}</td>
                    <td className="num">
                      <button className="pick-rm" style={{ position: 'static', display: 'block' }}
                              onClick={() => removePick(i)} title={t('slip.remove')}>✕</button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <div className="social-strip">
            <span className="social-dot" />
            {t('checkout.social', { n: baseCount.toLocaleString() })}
            <span className="social-sep">·</span>
            <span style={{ color: 'var(--accent)' }}>{t('checkout.socialLive', { n: viewers })}</span>
          </div>
        </div>

        {/* summary */}
        <div className="panel sticky-col">
          <div className="panel-hd"><span>{t('checkout.summary')}</span></div>
          <div className="panel-bd">
            <div className="quick-stakes">
              {QUICK.map(v => <button key={v} onClick={() => setStake(v)}>{v}€</button>)}
            </div>

            <div className="stake-row">
              <label htmlFor="ckStake">{t('checkout.stake')}</label>
              <input
                id="ckStake" className="stake-input" type="number" min="0.5" step="0.5"
                value={stake} onChange={(e) => setStake(e.target.value)}
              />
            </div>

            <div className="sum-row"><span>{t('checkout.pairs')}</span><strong>{slip.length}</strong></div>
            <div className="sum-row"><span>{t('checkout.totalOdds')}</span><strong>{num(totalOdds)}</strong></div>
            <div className="sum-row"><span>{t('checkout.gross')}</span><strong>{eur(gross)}</strong></div>
            <div className="sum-row"><span>{t('checkout.deduction')}</span><strong>-{eur(deduction)}</strong></div>
            <div className="sum-row total"><span>{t('checkout.potential')}</span><strong>{eur(net)}</strong></div>

            {user && (
              <div className="sum-row" style={{ marginTop: 8, borderTop: '1px dashed var(--line)', paddingTop: 8 }}>
                <span>{t('checkout.balanceAfter')}</span>
                <strong>{eur(Math.max(0, user.balance - stake))}</strong>
              </div>
            )}

            <button className="btn btn-accent btn-block btn-lg" style={{ marginTop: 14 }}
                    disabled={busy} onClick={confirm}>
              {busy ? t('checkout.confirming') : t('checkout.confirm')}
            </button>

            <button className="btn btn-ghost btn-block" style={{ marginTop: 8 }} onClick={requestLeave}>
              ← {t('checkout.back')}
            </button>

            <p style={{ fontSize: 11.5, color: 'var(--txt-mute)', marginTop: 12, marginBottom: 0 }}>
              {t('checkout.demoNote')}
            </p>
          </div>
        </div>
      </div>

      {/* leave-intent card */}
      {showLeave && (
        <div className="modal-back is-open" onMouseDown={(e) => { if (e.target === e.currentTarget) setShowLeave(false); }}>
          <div className="modal" style={{ maxWidth: 430 }}>
            <div className="modal-hd">
              <span>{t('checkout.leaveTitle')}</span>
              <button className="x" onClick={() => setShowLeave(false)} aria-label={t('common.close')}>×</button>
            </div>
            <div className="modal-bd">
              <p style={{ color: 'var(--txt-dim)' }}>{t('checkout.leaveBody')}</p>

              <div className="projected-card">
                <div className="projected-label">{t('checkout.leaveProjected')}</div>
                <div className="projected-amount">{eur(net)}</div>
                <div className="projected-meta">
                  {slip.length} × {t('checkout.pairs').toLowerCase()} · {t('checkout.totalOdds')} {num(totalOdds)} · {t('checkout.stake')} {eur(stake)}
                </div>
              </div>

              <div className="social-strip" style={{ marginTop: 14 }}>
                <span className="social-dot" />
                {t('checkout.social', { n: baseCount.toLocaleString() })}
              </div>
            </div>
            <div className="modal-ft">
              <button className="btn btn-ghost" onClick={leaveNow}>{t('checkout.leaveGo')}</button>
              <button className="btn btn-accent" onClick={() => setShowLeave(false)}>{t('checkout.leaveStay')}</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
