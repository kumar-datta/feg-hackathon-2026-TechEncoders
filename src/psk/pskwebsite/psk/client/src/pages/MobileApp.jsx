import { Link } from 'react-router-dom';
import { useT } from '../i18n';

const FEATURE_ICONS = ['⚡', '🔔', '🔴', '🎰', '🌓', '🛟'];
const DOWNLOAD_ICONS = ['🤖', '', '🎰'];

export default function MobileApp() {
  const { t } = useT();

  return (
    <div className="page narrow" style={{ maxWidth: 900 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('mobileApp.title')}</div>
      <h1 className="page-title">📱 {t('mobileApp.title')}</h1>
      <p className="page-lede">{t('mobileApp.lede')}</p>

      <div className="note warn">{t('mobileApp.warn')}</div>

      <div className="hero" style={{ marginTop: 24, background: 'linear-gradient(115deg,#0a3fb0,#0b4bd4 45%,#17203a)' }}>
        <span className="hero-eyebrow">{t('mobileApp.heroEyebrow')}</span>
        <h1 style={{ fontSize: 28 }}>{t('mobileApp.heroTitle')}</h1>
        <p>{t('mobileApp.heroText')}</p>
        <div className="hero-actions">
          <Link className="btn btn-accent btn-lg" to="/oklade">{t('sportsbook.offer')}</Link>
          <Link
            className="btn btn-ghost btn-lg"
            to="/casino"
            style={{ color: '#fff', borderColor: 'rgba(255,255,255,.45)' }}
          >
            {t('casino.title')}
          </Link>
        </div>
      </div>

      <section className="sec">
        <div className="sec-hd"><h2>{t('mobileApp.featuresTitle')}</h2></div>
        <div className="tile-grid">
          {t('mobileApp.features').map(([title, text], i) => (
            <div className="panel panel-bd" key={i}>
              <div style={{ fontSize: 26, marginBottom: 8 }}>{FEATURE_ICONS[i]}</div>
              <div style={{ fontWeight: 700, fontSize: 14, marginBottom: 4 }}>{title}</div>
              <div style={{ fontSize: 12.5, color: 'var(--txt-mute)' }}>{text}</div>
            </div>
          ))}
        </div>
      </section>

      <section className="sec">
        <div className="sec-hd"><h2>{t('mobileApp.downloadTitle')}</h2></div>
        <div className="quick-grid">
          {t('mobileApp.downloads').map(([name, sub], i) => (
            <div className="quick-card" key={i} style={{ opacity: .55, cursor: 'not-allowed' }}>
              <div className="ico">{DOWNLOAD_ICONS[i]}</div>
              <div className="t">{name}</div>
              <div className="s">{sub} — {t('mobileApp.unavailable')}</div>
            </div>
          ))}
        </div>
      </section>

      <section className="sec prose">
        <h2>{t('mobileApp.securityTitle')}</h2>
        <p>{t('mobileApp.securityBody')}</p>
      </section>
    </div>
  );
}
