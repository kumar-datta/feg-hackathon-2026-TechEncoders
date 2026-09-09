import { Link } from 'react-router-dom';
import { useT } from '../i18n';

export default function Rules() {
  const { t } = useT();

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('rules.title')}</div>
      <h1 className="page-title">📜 {t('rules.title')}</h1>
      <p className="page-lede">{t('rules.lede')}</p>

      <div className="note warn">{t('rules.warn')}</div>

      <div className="prose">
        <h2>{t('rules.s1')}</h2>
        <p>{t('rules.s1body')}</p>

        <h2>{t('rules.s2')}</h2>
        <ul>{t('rules.s2list').map((x, i) => <li key={i}>{x}</li>)}</ul>

        <h2>{t('rules.s3')}</h2>
        <p>{t('rules.s3body1')}</p>
        <p>{t('rules.s3body2')}</p>

        <h2 id="bonusi">{t('rules.s4')}</h2>
        <p>{t('rules.s4body')}</p>

        <h2>{t('rules.s5')}</h2>
        <ul>{t('rules.s5list').map((x, i) => <li key={i}>{x}</li>)}</ul>

        <h2>{t('rules.s6')}</h2>
        <p>{t('rules.s6body')}</p>

        <h2 id="sukladnost">{t('rules.s7')}</h2>
        <p>{t('rules.s7body')}</p>

        <h2>{t('rules.s8')}</h2>
        <p>
          {t('rules.s8body')}{' '}
          <Link to="/odgovorno-igranje">{t('footer.responsible')}</Link>.
        </p>
      </div>
    </div>
  );
}
