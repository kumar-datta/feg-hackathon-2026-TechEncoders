import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox } from '../components/Loader';
import { useT } from '../i18n';
import { eur } from '../utils/format';

export default function Promotions() {
  const { setModal, closeModal } = useApp();
  const { t } = useT();
  const [tag, setTag] = useState('Sve');
  const [promos, setPromos] = useState([]);
  const [tags, setTags] = useState(['Sve']);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api.content.promos({ tag })
      .then(d => { setPromos(d.promos); setTags(d.tags); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [tag]);

  useEffect(() => { load(); }, [load]);

  const open = (p) => setModal({
    title: p.title,
    content: (
      <>
        <p>{p.body}</p>
        <div className="note">{t('promos.modalNote')}</div>
        <h3 style={{ fontSize: 14, marginTop: 18 }}>{t('promos.termsTitle')}</h3>
        <table className="tbl">
          <tbody>
            <tr><td>{t('promos.terms.turnover')}</td><td className="num">{p.terms?.turnover || '5×'}</td></tr>
            <tr><td>{t('promos.terms.minOdds')}</td><td className="num">{p.terms?.minOdds || '1.50'}</td></tr>
            <tr><td>{t('promos.terms.deadline')}</td><td className="num">{p.terms?.days || 30} {t('promos.terms.days')}</td></tr>
            <tr><td>{t('promos.terms.minDeposit')}</td><td className="num">{eur(p.terms?.minDeposit || 10)}</td></tr>
          </tbody>
        </table>
      </>
    ),
    footer: <button className="btn btn-ghost" onClick={closeModal}>{t('common.close')}</button>
  });

  return (
    <div className="page" style={{ maxWidth: 1300 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('promos.title')}</div>
      <h1 className="page-title">🎁 {t('promos.title')}</h1>
      <p className="page-lede">{t('promos.lede')}</p>

      <div className="cat-bar" style={{ margin: '22px 0' }}>
        {tags.map(tg => (
          <button key={tg} className={'chip' + (tag === tg ? ' is-active' : '')} onClick={() => setTag(tg)}>
            {tg === 'Sve' ? t('common.all') : tg}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && (
        <div className="tile-grid">
          {promos.map(p => (
            <div className="panel" key={p.slug}>
              <div style={{
                height: 130,
                background: `linear-gradient(140deg,hsl(${p.hueA} 70% 44%),hsl(${p.hueB} 65% 24%))`,
                display: 'grid', placeItems: 'center', fontSize: 40
              }}>🎁</div>
              <div className="panel-bd">
                <span className="tag-new">{p.tag}</span>
                <h3 style={{ margin: '10px 0 6px', fontSize: 16 }}>{p.title}</h3>
                <p style={{ fontSize: 13, color: 'var(--txt-dim)' }}>{p.body}</p>
                <button className="btn btn-accent btn-block" onClick={() => open(p)}>{p.cta}</button>
              </div>
            </div>
          ))}
        </div>
      )}

      <section className="sec prose">
        <h2>{t('promos.readTitle')}</h2>
        <p>{t('promos.readLead')}</p>
        <ul>
          {t('promos.readPoints').map(([head, body], i) => (
            <li key={i}><strong>{head}</strong> — {body}</li>
          ))}
        </ul>
        <p>{t('promos.readTail')} <Link to="/pravila-igre">{t('footer.gameRules')}</Link>.</p>
      </section>
    </div>
  );
}
