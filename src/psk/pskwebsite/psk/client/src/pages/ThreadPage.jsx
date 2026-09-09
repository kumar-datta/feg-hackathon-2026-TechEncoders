import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import api from '../api/client';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { dateTime } from '../utils/format';

export default function ThreadPage() {
  const { slug } = useParams();
  const { t } = useT();
  const [thread, setThread] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    api.content.thread(slug)
      .then(d => setThread(d.thread))
      .catch(setError)
      .finally(() => setLoading(false));
  }, [slug]);

  if (loading) return <div className="page narrow"><Loader /></div>;
  if (error) return <div className="page narrow"><ErrorBox error={error} /></div>;

  return (
    <div className="page narrow">
      <div className="crumbs">
        <Link to="/">{t('common.home')}</Link> › <Link to="/forum">{t('forum.title')}</Link> › {thread.category}
      </div>

      <h1 className="page-title">{thread.title}</h1>
      <p className="page-lede">
        <span className="tag-new">{thread.category}</span>{' '}
        @{thread.author} · {t('forum.views', { n: thread.views })} · {t('forum.replies', { n: thread.replies?.length || 0 })}
      </p>

      <div className="panel" style={{ marginTop: 22 }}>
        <div className="panel-bd">
          <div style={{ fontWeight: 700, marginBottom: 6 }}>@{thread.author}</div>
          <p style={{ margin: 0, color: 'var(--txt-dim)' }}>{thread.body}</p>
          <div style={{ fontSize: 11, color: 'var(--txt-mute)', marginTop: 10 }}>
            {dateTime(thread.createdAt)}
          </div>
        </div>
      </div>

      <div className="sec-hd" style={{ marginTop: 26 }}>
        <h2 style={{ fontSize: 16 }}>{t('forum.repliesTitle')}</h2>
      </div>

      <div className="panel">
        {(thread.replies || []).map((r, i) => (
          <div key={i} style={{ padding: 14, borderBottom: '1px solid var(--line-soft)' }}>
            <div style={{ fontWeight: 700, fontSize: 13, marginBottom: 4 }}>@{r.author}</div>
            <p style={{ margin: 0, fontSize: 13.5, color: 'var(--txt-dim)' }}>{r.body}</p>
            <div style={{ fontSize: 11, color: 'var(--txt-mute)', marginTop: 8 }}>
              {dateTime(r.createdAt)}
            </div>
          </div>
        ))}
      </div>

      <div className="note" style={{ marginTop: 22 }}>{t('forum.postDisabled')}</div>

      <div style={{ marginTop: 20 }}>
        <Link className="btn btn-ghost" to="/forum">← {t('forum.backToForum')}</Link>
      </div>
    </div>
  );
}
