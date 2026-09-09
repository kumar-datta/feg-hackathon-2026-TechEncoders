import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { eur } from '../utils/format';

export default function Statistics() {
  const { t } = useT();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.content.stats()
      .then(setData)
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  if (loading) return <div className="page"><Loader /></div>;
  if (error) return <div className="page"><ErrorBox error={error} /></div>;

  const maxEvents = Math.max(...data.bySport.map(s => s.events), 1);
  const maxGames = Math.max(...data.byProvider.map(p => p.games), 1);

  return (
    <div className="page" style={{ maxWidth: 1200 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.statistics')}</div>
      <h1 className="page-title">📊 {t('stats.title')}</h1>
      <p className="page-lede">{t('stats.lede')}</p>

      <div className="quick-grid" style={{ marginTop: 24 }}>
        <div className="quick-card">
          <div className="ico">🏆</div>
          <div className="t">{data.totals.events}</div>
          <div className="s">{t('stats.cards.events')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">🔴</div>
          <div className="t">{data.totals.live}</div>
          <div className="s">{t('stats.cards.live')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">🎰</div>
          <div className="t">{data.totals.games}</div>
          <div className="s">{t('stats.cards.games')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">💰</div>
          <div className="t">{eur(data.totals.jackpotPool)}</div>
          <div className="s">{t('stats.cards.jackpot')}</div>
        </div>
      </div>

      <section className="sec">
        <div className="sec-hd"><h2>{t('stats.bySport')}</h2></div>
        <div className="panel tbl-wrap">
          <table className="tbl">
            <thead>
              <tr><th>{t('stats.tbl.sport')}</th><th>{t('stats.tbl.share')}</th><th className="num">{t('stats.tbl.live')}</th><th className="num">{t('stats.tbl.total')}</th></tr>
            </thead>
            <tbody>
              {data.bySport.map(s => (
                <tr key={s.sport}>
                  <td>{s.icon} {s.sport}</td>
                  <td style={{ width: '45%' }}>
                    <div style={{ background: 'var(--bg-elev-2)', borderRadius: 4, height: 8, overflow: 'hidden' }}>
                      <div style={{
                        width: `${(s.events / maxEvents) * 100}%`,
                        height: '100%',
                        background: 'linear-gradient(90deg,var(--brand-300),var(--accent))'
                      }} />
                    </div>
                  </td>
                  <td className="num" style={{ color: s.live ? 'var(--live)' : 'var(--txt-mute)' }}>{s.live}</td>
                  <td className="num" style={{ fontWeight: 700 }}>{s.events}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="sec">
        <div className="sec-hd"><h2>{t('stats.byProvider')}</h2></div>
        <div className="panel tbl-wrap">
          <table className="tbl">
            <thead>
              <tr><th>{t('stats.tbl.provider')}</th><th>{t('stats.tbl.share')}</th><th className="num">{t('stats.tbl.games')}</th></tr>
            </thead>
            <tbody>
              {data.byProvider.map(p => (
                <tr key={p.provider}>
                  <td>{p.provider}</td>
                  <td style={{ width: '55%' }}>
                    <div style={{ background: 'var(--bg-elev-2)', borderRadius: 4, height: 8, overflow: 'hidden' }}>
                      <div style={{
                        width: `${(p.games / maxGames) * 100}%`,
                        height: '100%',
                        background: 'linear-gradient(90deg,var(--brand),var(--brand-300))'
                      }} />
                    </div>
                  </td>
                  <td className="num" style={{ fontWeight: 700 }}>{p.games}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </section>

      <section className="sec prose">
        <h2>{t('stats.noteTitle')}</h2>
        <p>{t('stats.noteBody')}</p>
      </section>
    </div>
  );
}
