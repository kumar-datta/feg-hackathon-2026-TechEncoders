import { Link } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

export default function Responsible() {
  const { user } = useApp();
  const { t } = useT();

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('responsible.title')}</div>
      <h1 className="page-title">🛟 {t('responsible.title')}</h1>
      <p className="page-lede">{t('responsible.lede')}</p>

      <div className="note warn">{t('responsible.warn')}</div>

      <div className="prose">
        <h2>{t('responsible.principlesTitle')}</h2>
        <ul>{t('responsible.principles').map((x, i) => <li key={i}>{x}</li>)}</ul>

        <h2 id="limiti">{t('responsible.limitsTitle')}</h2>
        <p>{t('responsible.limitsLead')}</p>
        <ul>
          {t('responsible.limits').map(([head, body], i) => (
            <li key={i}><strong>{head}</strong> — {body}</li>
          ))}
        </ul>
        <p>{t('responsible.limitsNote')}</p>

        <h2 id="samoiskljucenje">{t('responsible.exclusionTitle')}</h2>
        <p>{t('responsible.exclusionBody')}</p>
        <p>
          {user
            ? <Link className="btn btn-ghost" to="/racun#samoiskljucenje">{t('responsible.exclusionCta')}</Link>
            : <Link className="btn btn-ghost" to="/prijava">{t('responsible.exclusionLogin')}</Link>}
        </p>

        <h2>{t('responsible.signsTitle')}</h2>
        <p>{t('responsible.signsLead')}</p>
        <ul>{t('responsible.signs').map((x, i) => <li key={i}>{x}</li>)}</ul>

        <h2>{t('responsible.helpTitle')}</h2>
        <p>{t('responsible.helpBody1')}</p>
        <p>{t('responsible.helpBody2')}</p>

        <h2>{t('responsible.minorsTitle')}</h2>
        <p>{t('responsible.minorsBody')}</p>
      </div>
    </div>
  );
}
