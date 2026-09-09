import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useT } from '../i18n';

export default function Help() {
  const { t } = useT();
  const [open, setOpen] = useState(() => new Set([0]));

  const faq = t('help.faq');

  const toggle = (i) =>
    setOpen(prev => {
      const next = new Set(prev);
      next.has(i) ? next.delete(i) : next.add(i);
      return next;
    });

  const tiles = [
    ['✉️', 'contact', '/kontakt'],
    ['📜', 'rules', '/pravila-igre'],
    ['🛟', 'responsible', '/odgovorno-igranje'],
    ['ℹ️', 'about', '/o-nama']
  ];

  return (
    <div className="page narrow">
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('nav.help')}</div>
      <h1 className="page-title">❓ {t('help.title')}</h1>
      <p className="page-lede">{t('help.lede')}</p>

      <div style={{ marginTop: 26 }}>
        {faq.map(([q, a], i) => (
          <div className={'acc-item' + (open.has(i) ? ' is-open' : '')} key={i}>
            <button className="acc-hd" onClick={() => toggle(i)}>
              <span>{q}</span>
              <span className="c">+</span>
            </button>
            <div className="acc-bd">{a}</div>
          </div>
        ))}
      </div>

      <section className="sec">
        <div className="sec-hd"><h2>{t('help.moreTitle')}</h2></div>
        <div className="quick-grid">
          {tiles.map(([icon, key, to]) => (
            <Link className="quick-card" to={to} key={key}>
              <div className="ico">{icon}</div>
              <div className="t">{t('help.tiles.' + key)}</div>
              <div className="s">{t('help.tiles.' + key + 'Sub')}</div>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
