import { useState } from 'react';
import { NavLink, Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import { eur } from '../utils/format';

export default function Header() {
  const { toggleTheme, theme, user, logout, setDrawerOpen } = useApp();
  const { t } = useT();
  const [q, setQ] = useState('');
  const navigate = useNavigate();

  const mainNav = [
    { to: '/oklade', label: t('nav.sport') },
    { to: '/oklade?filter=live', label: t('nav.live'), live: true },
    { to: '/casino', label: t('nav.casino'), badge: t('casino.new') },
    { to: '/live-casino', label: t('nav.liveCasino') },
    { to: '/loto', label: t('nav.loto') },
    { to: '/virtualne-igre', label: t('nav.virtuals') },
    { to: '/forum', label: t('nav.forum') },
    { to: '/arena', label: t('nav.arena') },
    { to: '/promocije', label: t('nav.promo') },
    { to: '/swipe-and-bet', label: t('nav.swipe') }
  ];

  const subNav = [
    { to: '/', label: t('nav.home') },
    { to: '/mobilna-aplikacija', label: t('nav.mobileApp') },
    { to: '/rezultati', label: t('nav.results') },
    { to: '/statistika', label: t('nav.statistics') },
    { to: '/novosti', label: t('nav.news') },
    { to: '/klub-prvaka', label: t('nav.club') },
    { to: '/pomoc', label: t('nav.help') },
    { to: '/poslovnice', label: t('nav.shops') }
  ];

  const submitSearch = (e) => {
    e.preventDefault();
    const term = q.trim();
    if (term) navigate(`/pretraga?q=${encodeURIComponent(term)}`);
  };

  return (
    <>
      <div className="demo-bar">{t('demoBar')}</div>

      <header className="site-header">
        <div className="hdr-top">
          <button className="burger" onClick={() => setDrawerOpen(o => !o)} aria-label={t('header.menu')}>☰</button>

          <Link className="logo" to="/">
            <span className="logo-mark">PSK</span>
            <span className="logo-txt">PSK<em>.demo</em></span>
          </Link>

          <div className="hdr-spacer" />

          <form className="hdr-search" onSubmit={submitSearch}>
            <span aria-hidden="true">🔍</span>
            <input
              type="search"
              value={q}
              onChange={(e) => setQ(e.target.value)}
              placeholder={t('header.searchPlaceholder')}
              aria-label={t('header.searchLabel')}
            />
          </form>

          <button className="theme-pill" onClick={toggleTheme} title={t('header.theme')} aria-label={t('header.theme')}>
            <span aria-hidden="true">{theme === 'dark' ? '☾' : '☀'}</span>
            <span>{theme === 'dark' ? t('header.themeDark') : t('header.themeLight')}</span>
          </button>
          <Link className="icon-btn" to="/pomoc" title={t('header.help')} aria-label={t('header.help')}>?</Link>

          {user ? (
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <div className="balance-pill">
                <span className="bal-amt">{eur(user.balance)}</span>
                <Link className="bal-add" to="/racun" title={t('header.deposit')}>+</Link>
              </div>
              <Link className="icon-btn" to="/racun" title={user.username} aria-label={t('header.account')}>👤</Link>
              <button className="icon-btn" onClick={logout} title={t('header.logout')} aria-label={t('header.logout')}>⏻</button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: 8 }}>
              <Link className="btn btn-ghost" to="/prijava">{t('header.login')}</Link>
              <Link className="btn btn-accent" to="/registracija">{t('header.register')}</Link>
            </div>
          )}
        </div>

        <nav className="hdr-nav" aria-label={t('header.menu')}>
          <div className="hdr-nav-inner">
            {mainNav.map(n => (
              <NavLink
                key={n.label}
                to={n.to}
                className={({ isActive }) => 'nav-link' + (isActive ? ' is-active' : '')}
                end={n.to === '/oklade'}
              >
                {n.live && <span className="dot-live" />}
                {n.label}
                {n.badge && <span className="tag-new">{n.badge}</span>}
              </NavLink>
            ))}
          </div>
        </nav>

        <nav className="hdr-sub" aria-label={t('header.menu')}>
          <div className="hdr-sub-inner">
            {subNav.map(n => (
              <NavLink
                key={n.to}
                to={n.to}
                className={({ isActive }) => 'sub-link' + (isActive ? ' is-active' : '')}
                end={n.to === '/'}
              >
                {n.label}
              </NavLink>
            ))}
          </div>
        </nav>
      </header>
    </>
  );
}
