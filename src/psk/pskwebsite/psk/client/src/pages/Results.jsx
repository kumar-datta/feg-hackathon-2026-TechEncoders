import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import { dateTime } from '../utils/format';

export default function Results() {
  const [results, setResults] = useState([]);
  const { t } = useT();
  const [sport, setSport] = useState('__all');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.content.results()
      .then(d => setResults(d.results))
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  const sports = ['__all', ...Array.from(new Set(results.map(r => r.sport).filter(Boolean)))];
  const list = sport === '__all' ? results : results.filter(r => r.sport === sport);

  return (
    <div className="page" style={{ maxWidth: 1200 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('results.title')}</div>
      <h1 className="page-title">📋 {t('results.title')}</h1>
      <p className="page-lede">{t('results.lede')}</p>

      {!loading && sports.length > 1 && (
        <div className="cat-bar" style={{ margin: '22px 0' }}>
          {sports.map(s => (
            <button key={s} className={'chip' + (sport === s ? ' is-active' : '')} onClick={() => setSport(s)}>
              {s === '__all' ? t('common.all') : s}
            </button>
          ))}
        </div>
      )}

      {error && <ErrorBox error={error} />}
      {loading && <Loader />}

      {!loading && !error && (
        list.length === 0 ? <Empty>{t('results.none')}</Empty> : (
          <div className="panel tbl-wrap">
            <table className="tbl">
              <thead>
                <tr>
                  <th>{t('results.tbl.sport')}</th><th>{t('results.tbl.competition')}</th><th>{t('results.tbl.event')}</th>
                  <th>{t('results.tbl.time')}</th><th className="num">{t('results.tbl.result')}</th>
                </tr>
              </thead>
              <tbody>
                {list.map(r => (
                  <tr key={r.id}>
                    <td>{r.sportIcon} {r.sport}</td>
                    <td>{r.flag} {r.league}</td>
                    <td style={{ fontWeight: 600 }}>{r.name}</td>
                    <td style={{ color: 'var(--txt-mute)', fontSize: 12 }}>{dateTime(r.startsAt)}</td>
                    <td className="num" style={{ fontWeight: 800, color: r.live ? 'var(--live)' : 'var(--accent)' }}>
                      {r.live ? `${r.score || '0:0'} (${r.minute}')` : r.score}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}
    </div>
  );
}
