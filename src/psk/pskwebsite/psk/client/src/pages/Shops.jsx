import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';

export default function Shops() {
  const { t } = useT();
  const [city, setCity] = useState('Sve');
  const [shops, setShops] = useState([]);
  const [cities, setCities] = useState(['Sve']);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api.content.shops({ city })
      .then(d => { setShops(d.shops); setCities(d.cities); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [city]);

  useEffect(() => { load(); }, [load]);

  return (
    <div className="page" style={{ maxWidth: 1100 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('shops.title')}</div>
      <h1 className="page-title">📍 {t('shops.title')}</h1>
      <p className="page-lede">{t('shops.lede')}</p>

      <div className="cat-bar" style={{ margin: '22px 0' }}>
        {cities.map(c => (
          <button key={c} className={'chip' + (city === c ? ' is-active' : '')} onClick={() => setCity(c)}>
            {c === 'Sve' ? t('common.all') : c}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && !error && (
        shops.length === 0 ? <Empty>{t('shops.none')}</Empty> : (
          <div className="panel tbl-wrap">
            <table className="tbl">
              <thead>
                <tr><th>{t('shops.tbl.city')}</th><th>{t('shops.tbl.address')}</th><th>{t('shops.tbl.hours')}</th><th>{t('shops.tbl.kind')}</th></tr>
              </thead>
              <tbody>
                {shops.map(s => (
                  <tr key={s._id}>
                    <td style={{ fontWeight: 700 }}>{s.city}</td>
                    <td>{s.address}</td>
                    <td style={{ color: 'var(--accent)' }}>{s.hours}</td>
                    <td style={{ color: 'var(--txt-mute)', fontSize: 12 }}>{s.kind}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )
      )}

      <div className="note">{t('shops.mapNote')}</div>
    </div>
  );
}
