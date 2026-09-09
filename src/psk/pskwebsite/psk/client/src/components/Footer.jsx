import { Link, NavLink } from 'react-router-dom';
import { useEffect, useState } from 'react';
import api from '../api/client';
import { useT, LANGUAGES } from '../i18n';
import LanguageSwitcher from './LanguageSwitcher';

export default function Footer() {
  const { t } = useT();
  const [payments, setPayments] = useState([]);

  useEffect(() => {
    api.content.payments().then(d => setPayments(d.payments || [])).catch(() => {});
  }, []);

  const columns = [
    {
      heading: t('footer.offer'),
      links: [
        [t('footer.sportsbook'), '/oklade'],
        [t('footer.liveBetting'), '/oklade?filter=live'],
        [t('nav.casino'), '/casino'],
        [t('nav.liveCasino'), '/live-casino'],
        [t('nav.loto'), '/loto'],
        [t('nav.virtuals'), '/virtualne-igre'],
        [t('nav.swipe'), '/swipe-and-bet'],
        [t('footer.promotions'), '/promocije']
      ]
    },
    {
      heading: t('footer.aboutUs'),
      links: [
        [t('footer.aboutProject'), '/o-nama'],
        [t('nav.shops'), '/poslovnice'],
        [t('nav.club'), '/klub-prvaka'],
        [t('nav.arena'), '/arena'],
        [t('nav.news'), '/novosti'],
        [t('footer.contact'), '/kontakt']
      ]
    },
    {
      heading: t('footer.rules'),
      links: [
        [t('footer.gameRules'), '/pravila-igre'],
        [t('footer.bonusRules'), '/pravila-igre#bonusi'],
        [t('footer.privacy'), '/pravila-privatnosti'],
        [t('footer.cookies'), '/pravila-privatnosti#kolacici'],
        [t('footer.dataProtection'), '/pravila-privatnosti#gdpr']
      ]
    },
    {
      heading: t('footer.support'),
      links: [
        [t('footer.faq'), '/pomoc'],
        [t('footer.contactForm'), '/kontakt'],
        [t('footer.responsible'), '/odgovorno-igranje'],
        [t('footer.selfExclusion'), '/odgovorno-igranje#samoiskljucenje'],
        [t('footer.limits'), '/odgovorno-igranje#limiti']
      ]
    }
  ];

  return (
    <>
      <footer className="site-footer">
        <div className="foot-inner">
          <div className="foot-cols">
            {columns.map(col => (
              <div className="foot-col" key={col.heading}>
                <h4>{col.heading}</h4>
                {col.links.map(([label, to]) => (
                  <Link key={label + to} to={to}>{label}</Link>
                ))}
              </div>
            ))}

            <div className="foot-col">
              <h4>{t('footer.app')}</h4>
              <Link to="/mobilna-aplikacija">{t('footer.androidApp')}</Link>
              <Link to="/mobilna-aplikacija">{t('footer.iosApp')}</Link>
              <Link to="/mobilna-aplikacija">{t('footer.casinoApp')}</Link>

              {/* language selector */}
              <h4 style={{ marginTop: 22 }}>{t('footer.language')}</h4>
              <LanguageSwitcher />

              <div className="foot-social" style={{ marginTop: 16 }}>
                <span className="icon-btn" title={t('footer.social')}>f</span>
                <span className="icon-btn" title={t('footer.social')}>ig</span>
                <span className="icon-btn" title={t('footer.social')}>x</span>
                <span className="icon-btn" title={t('footer.social')}>▶</span>
              </div>
            </div>
          </div>

          {payments.length > 0 && (
            <div style={{ marginTop: 26 }}>
              <h4 style={{ fontSize: 12, letterSpacing: '.6px', textTransform: 'uppercase', color: 'var(--txt-mute)' }}>
                {t('footer.payments')}
              </h4>
              <div className="foot-pay">
                {payments.map(p => <span className="pay-chip" key={p}>{p}</span>)}
              </div>
            </div>
          )}

          <div className="foot-legal">
            <p style={{ marginBottom: 10 }}>
              <span className="age-badge">18+</span>
              {t('footer.ageWarning')}{' '}
              <Link to="/odgovorno-igranje" style={{ color: 'var(--accent)' }}>
                {t('footer.responsible')}
              </Link>.
            </p>
            <p style={{ margin: 0 }}>
              <strong>{t('footer.disclaimerLead')}</strong> {t('footer.disclaimer')}
            </p>
            <p style={{ margin: '8px 0 0' }}>
              © {new Date().getFullYear()} PSK.demo — {t('footer.copyright')}
            </p>
          </div>
        </div>
      </footer>

      <nav className="mob-bar" aria-label={t('header.menu')}>
        {[
          ['/', '🏠', t('nav.home')],
          ['/oklade', '🏆', t('nav.sport')],
          ['/oklade?filter=live', '🔴', t('nav.live')],
          ['/casino', '🎰', t('nav.casino')],
          ['/listici', '🎫', t('nav.tickets')]
        ].map(([to, icon, label]) => (
          <NavLink key={label} to={to} className={({ isActive }) => (isActive ? 'is-active' : '')} end={to === '/'}>
            <span className="i">{icon}</span>{label}
          </NavLink>
        ))}
      </nav>
    </>
  );
}
