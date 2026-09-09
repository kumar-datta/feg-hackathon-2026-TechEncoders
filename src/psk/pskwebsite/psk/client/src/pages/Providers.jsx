import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';

export default function Providers() {
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [q, setQ] = useState('');
  const { t } = useT();
  const navigate = useNavigate();

  useEffect(() => {
    api.casino.providers()
      .then(d => setProviders(d.providers))
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  const list = providers.filter(p => p.name.toLowerCase().includes(q.toLowerCase()));

  return (
    <div className="page" style={{ maxWidth: 1400 }}>
      <div className="crumbs">
        <Link to="/">{t('common.home')}</Link> › <Link to="/casino">{t('casino.title')}</Link> › {t('providers.title')}
      </div>
      <h1 className="page-title">🏢 {t('providers.title')}</h1>
      <p className="page-lede">{t('providers.lede')}</p>

      <div className="hdr-search" style={{ maxWidth: 420, height: 40, margin: '20px 0' }}>
        <span>🔍</span>
        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={t('providers.searchPlaceholder')}
          aria-label={t('providers.searchLabel')}
        />
      </div>

      {error && <ErrorBox error={error} />}
      {loading && <Loader />}

      {!loading && (
        <div className="provider-grid">
          {list.map(p => (
            <button
              className="provider-card"
              key={p.slug}
              onClick={() => navigate(`/casino?provider=${p.slug}`)}
            >
              {p.name}
              <span className="n">{p.games} {t('common.games')}</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
