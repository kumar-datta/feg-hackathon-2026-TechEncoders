import { Link } from 'react-router-dom';
import { useT } from '../i18n';

export default function NotFound() {
  const { t } = useT();
  return (
    <div className="page narrow" style={{ textAlign: 'center', paddingTop: 60 }}>
      <div style={{ fontSize: 64, marginBottom: 12 }}>🔍</div>
      <h1 className="page-title">{t('notFound.title')}</h1>
      <p className="page-lede" style={{ margin: '0 auto' }}>{t('notFound.lede')}</p>

      <div style={{ display: 'flex', gap: 10, justifyContent: 'center', flexWrap: 'wrap', marginTop: 26 }}>
        <Link className="btn btn-accent btn-lg" to="/">{t('common.home')}</Link>
        <Link className="btn btn-ghost btn-lg" to="/oklade">{t('sportsbook.offer')}</Link>
        <Link className="btn btn-ghost btn-lg" to="/casino">{t('casino.title')}</Link>
      </div>
    </div>
  );
}
