import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { dateOnly } from '../utils/format';

export default function ArticlePage() {
  const { slug } = useParams();
  const { t } = useT();
  const [article, setArticle] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    api.content.article(slug)
      .then(d => setArticle(d.article))
      .catch(setError)
      .finally(() => setLoading(false));
  }, [slug]);

  if (loading) return <div className="page narrow"><Loader /></div>;
  if (error) return <div className="page narrow"><ErrorBox error={error} /></div>;

  return (
    <div className="page narrow">
      <div className="crumbs">
        <Link to="/">{t('common.home')}</Link> › <Link to="/novosti">{t('nav.news')}</Link> › {article.category}
      </div>

      <h1 className="page-title">{article.title}</h1>
      <p className="page-lede">
        <span className="tag-new">{article.category}</span> · {dateOnly(article.publishedAt)}
      </p>

      <div className="prose" style={{ marginTop: 24 }}>
        {String(article.body || article.excerpt)
          .split('\n')
          .filter(Boolean)
          .map((para, i) => <p key={i}>{para}</p>)}
      </div>

      <div className="note">{t('news.articleNote')}</div>

      <div style={{ marginTop: 20 }}>
        <Link className="btn btn-ghost" to="/novosti">← {t('news.allNews')}</Link>
      </div>
    </div>
  );
}
