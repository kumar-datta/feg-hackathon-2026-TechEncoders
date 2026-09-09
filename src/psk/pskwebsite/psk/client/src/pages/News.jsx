import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import { dateOnly } from '../utils/format';

export default function News() {
  const { t } = useT();
  const [category, setCategory] = useState('Sve');
  const [news, setNews] = useState([]);
  const [categories, setCategories] = useState(['Sve']);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api.content.news({ category })
      .then(d => { setNews(d.news); setCategories(d.categories); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [category]);

  useEffect(() => { load(); }, [load]);

  return (
    <div className="page" style={{ maxWidth: 1200 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.news')}</div>
      <h1 className="page-title">📰 {t('news.title')}</h1>
      <p className="page-lede">{t('news.lede')}</p>

      <div className="cat-bar" style={{ margin: '22px 0' }}>
        {categories.map(c => (
          <button key={c} className={'chip' + (category === c ? ' is-active' : '')} onClick={() => setCategory(c)}>
            {c === 'Sve' ? t('common.all') : c}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && !error && (
        news.length === 0 ? <Empty>{t('news.none')}</Empty> : (
          <div className="tile-grid">
            {news.map(a => (
              <Link className="panel" to={`/novosti/${a.slug}`} key={a.slug} style={{ display: 'block' }}>
                <div className="panel-bd">
                  <div style={{ fontSize: 11, color: 'var(--accent)', fontWeight: 700 }}>
                    {a.category} · {dateOnly(a.publishedAt)}
                  </div>
                  <h3 style={{ margin: '8px 0 6px', fontSize: 15 }}>{a.title}</h3>
                  <p style={{ fontSize: 13, color: 'var(--txt-mute)', margin: 0 }}>{a.excerpt}</p>
                </div>
              </Link>
            ))}
          </div>
        )
      )}
    </div>
  );
}
