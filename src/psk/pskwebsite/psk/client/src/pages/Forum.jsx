import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';

export default function Forum() {
  const { t } = useT();
  const [category, setCategory] = useState('Sve');
  const [threads, setThreads] = useState([]);
  const [categories, setCategories] = useState(['Sve']);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api.content.threads({ category })
      .then(d => { setThreads(d.threads); setCategories(d.categories); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [category]);

  useEffect(() => { load(); }, [load]);

  return (
    <div className="page" style={{ maxWidth: 1100 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('forum.title')}</div>
      <h1 className="page-title">💬 {t('forum.title')}</h1>
      <p className="page-lede">{t('forum.lede')}</p>

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
        threads.length === 0 ? <Empty>{t('forum.noThreads')}</Empty> : (
          <div className="panel">
            {threads.map(th => (
              <Link
                key={th.slug}
                to={`/forum/${th.slug}`}
                className="evt"
                style={{ gridTemplateColumns: '1fr auto', '--cols': 0 }}
              >
                <div className="evt-main">
                  <div className="evt-teams">
                    <div className="evt-team" style={{ fontWeight: 700 }}>{th.title}</div>
                    <div className="evt-meta">
                      <span className="tag-new">{th.category}</span>
                      <span>@{th.author}</span>
                      <span>{t('forum.replies', { n: th.replies?.length || 0 })}</span>
                      <span>{t('forum.views', { n: th.views })}</span>
                    </div>
                  </div>
                </div>
                <span style={{ color: 'var(--accent)', fontWeight: 700, fontSize: 12 }}>{t('common.open')} →</span>
              </Link>
            ))}
          </div>
        )
      )}

      <section className="sec prose">
        <h2>{t('forum.rulesTitle')}</h2>
        <ul>
          {t('forum.rules').map((r, i) => <li key={i}>{r}</li>)}
        </ul>
      </section>
    </div>
  );
}
