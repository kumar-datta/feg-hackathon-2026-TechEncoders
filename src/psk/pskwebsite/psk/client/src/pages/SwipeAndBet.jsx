import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { num, dateTime } from '../utils/format';

export default function SwipeAndBet() {
  const { slip, togglePick, toast } = useApp();
  const { t } = useT();
  const [pool, setPool] = useState([]);
  const [index, setIndex] = useState(0);
  const [flying, setFlying] = useState('');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.offer.events({ filter: 'all', limit: 60 })
      .then(d => {
        const usable = d.events
          .filter(e => !e.outright && Object.keys(e.markets || {}).length > 0)
          .sort(() => Math.random() - 0.5);
        setPool(usable);
      })
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  const current = pool[index];
  const marketKey = current
    ? Object.keys(current.markets)[Math.floor((current.code || 0) % Object.keys(current.markets).length)]
    : null;

  const advance = useCallback((direction, add) => {
    if (!current) return;
    setFlying(direction);

    if (add && marketKey) {
      togglePick(current, marketKey, current.markets[marketKey]);
      toast(t('swipe.added', { name: current.name }));
    }

    setTimeout(() => {
      setFlying('');
      setIndex(i => i + 1);
    }, 280);
  }, [current, marketKey, togglePick, toast, t]);

  useEffect(() => {
    const onKey = (e) => {
      if (e.key === 'ArrowRight') advance('right', true);
      if (e.key === 'ArrowLeft')  advance('left', false);
      if (e.key === 'ArrowUp')    advance('up', false);
    };
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, [advance]);

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.swipe')}</div>
      <h1 className="page-title">👆 {t('swipe.title')}</h1>
      <p className="page-lede">{t('swipe.lede')}</p>

      {error && <ErrorBox error={error} />}
      {loading && <Loader />}

      {!loading && !error && (
        <>
          <div className="sw-stack" style={{ marginTop: 28 }}>
            {!current ? (
              <div className="sw-card" style={{ alignItems: 'center', justifyContent: 'center', textAlign: 'center' }}>
                <div style={{ fontSize: 40 }}>🎉</div>
                <p style={{ marginTop: 12 }}>{t('swipe.done')}</p>
                <Link className="btn btn-accent" to="/oklade">{t('swipe.openOffer')}</Link>
              </div>
            ) : (
              <div className={'sw-card' + (flying ? ` gone-${flying}` : '')}>
                <div style={{ fontSize: 12, color: 'var(--txt-mute)' }}>
                  {current.flag} {current.leagueName}
                </div>
                <div style={{ fontSize: 22, fontWeight: 800, margin: '14px 0' }}>{current.name}</div>
                <div style={{ fontSize: 12.5, color: 'var(--txt-dim)' }}>
                  {current.live
                    ? <span style={{ color: 'var(--live)', fontWeight: 700 }}>{t('sportsbook.liveShort')} {current.minute}' · {current.score}</span>
                    : dateTime(current.startsAt)}
                </div>

                <div style={{ flex: 1 }} />

                <div style={{ textAlign: 'center', padding: 20, background: 'var(--bg-elev-2)', borderRadius: 'var(--radius)' }}>
                  <div style={{ fontSize: 12, color: 'var(--txt-mute)', textTransform: 'uppercase', letterSpacing: '.6px' }}>
                    {marketKey}
                  </div>
                  <div style={{ fontSize: 38, fontWeight: 900, color: 'var(--accent)', marginTop: 6 }}>
                    {num(current.markets[marketKey])}
                  </div>
                </div>

                <div style={{ fontSize: 11, color: 'var(--txt-mute)', textAlign: 'center', marginTop: 12 }}>
                  {t('slip.code')} {current.code} · {t('swipe.suggestion', { i: index + 1, total: pool.length })}
                </div>
              </div>
            )}
          </div>

          <div className="sw-actions">
            <button className="sw-btn no" onClick={() => advance('left', false)} title={t('swipe.reject')} disabled={!current}>✕</button>
            <button className="sw-btn skip" onClick={() => advance('up', false)} title={t('swipe.skip')} disabled={!current}>↷</button>
            <button className="sw-btn yes" onClick={() => advance('right', true)} title={t('swipe.accept')} disabled={!current}>✓</button>
          </div>

          <p style={{ textAlign: 'center', color: 'var(--txt-mute)', fontSize: 12.5, marginTop: 16 }}>
            {t('swipe.onSlip', { n: slip.length })}
          </p>

          <div style={{ textAlign: 'center', marginTop: 20 }}>
            <Link className="btn btn-accent btn-lg" to="/oklade">{t('swipe.openInOffer')}</Link>
          </div>
        </>
      )}

      <section className="sec prose">
        <h2>{t('swipe.howTitle')}</h2>
        <p>{t('swipe.howBody')}</p>
      </section>
    </div>
  );
}
