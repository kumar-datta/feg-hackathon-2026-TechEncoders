import { Link } from 'react-router-dom';
import { useT } from '../i18n';

export default function Privacy() {
  const { t } = useT();

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('privacy.title')}</div>
      <h1 className="page-title">🔒 {t('privacy.title')}</h1>
      <p className="page-lede">{t('privacy.lede')}</p>

      <div className="note warn">{t('privacy.warn')}</div>

      <div className="prose">
        <h2>{t('privacy.storedTitle')}</h2>
        <p>{t('privacy.storedLead')}</p>
        <ul>{t('privacy.stored').map((x, i) => <li key={i}>{x}</li>)}</ul>
        <p>{t('privacy.storedTail')}</p>

        <h2 id="kolacici">{t('privacy.browserTitle')}</h2>
        <p>{t('privacy.browserLead')}</p>
        <ul>{t('privacy.browser').map((x, i) => <li key={i}>{x}</li>)}</ul>
        <p>{t('privacy.browserTail')}</p>

        <h2>{t('privacy.thirdTitle')}</h2>
        <p>{t('privacy.thirdBody')}</p>

        <h2 id="gdpr">{t('privacy.accessTitle')}</h2>
        <p>{t('privacy.accessBody')}</p>

        <h2>{t('privacy.securityTitle')}</h2>
        <ul>{t('privacy.security').map((x, i) => <li key={i}>{x}</li>)}</ul>
        <p>{t('privacy.securityTail')}</p>

        <h2>{t('privacy.contactTitle')}</h2>
        <p>
          {t('privacy.contactBody')}{' '}
          <Link to="/kontakt">{t('footer.contactForm')}</Link>.
        </p>
      </div>
    </div>
  );
}
