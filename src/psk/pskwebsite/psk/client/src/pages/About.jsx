import { Link } from 'react-router-dom';
import { useT } from '../i18n';

export default function About() {
  const { t } = useT();

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('about.title')}</div>
      <h1 className="page-title">ℹ️ {t('about.title')}</h1>
      <p className="page-lede">{t('about.lede')}</p>

      <div className="note warn">{t('about.warn')}</div>

      <div className="prose">
        <h2>{t('about.goalTitle')}</h2>
        <p>{t('about.goalBody')}</p>

        <h2>{t('about.techTitle')}</h2>
        <ul>
          {t('about.tech').map(([head, body], i) => (
            <li key={i}><strong>{head}</strong> — {body}</li>
          ))}
        </ul>

        <h2>{t('about.archTitle')}</h2>
        <p>{t('about.archBody')}</p>

        <h3>{t('about.whyTitle')}</h3>
        <p>{t('about.whyBody')}</p>

        <h2>{t('about.dataTitle')}</h2>
        <p>{t('about.dataBody')}</p>

        <h2>{t('about.missingTitle')}</h2>
        <ul>{t('about.missing').map((x, i) => <li key={i}>{x}</li>)}</ul>

        <h2 id="karijera">{t('about.nameTitle')}</h2>
        <p>
          {t('about.nameBody')}{' '}
          <Link to="/pravila-igre">{t('footer.gameRules')}</Link>
          {' · '}
          <Link to="/pravila-privatnosti">{t('footer.privacy')}</Link>.
        </p>
      </div>
    </div>
  );
}
