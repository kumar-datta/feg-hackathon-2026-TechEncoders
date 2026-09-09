import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import GameCard from '../components/GameCard';
import { Loader } from '../components/Loader';
import useGameLauncher from '../games/useGameLauncher';
import { num, time, dateOnly } from '../utils/format';

const SLIDE_STYLE = [
  { bg: 'linear-gradient(115deg,#0a3fb0,#0b4bd4 45%,#17203a)', primary: '/oklade', secondary: '/oklade?filter=live' },
  { bg: 'linear-gradient(115deg,#4a1d6e,#2a1046 45%,#140a24)', primary: '/casino', secondary: '/live-casino' },
  { bg: 'linear-gradient(115deg,#0b5c3a,#083f28 45%,#04210f)', primary: '/loto', secondary: '/virtualne-igre' }
];

const QUICK = [
  ['🏆', 'sport', '/oklade'],
  ['🔴', 'live', '/oklade?filter=live'],
  ['🎰', 'casino', '/casino'],
  ['🎥', 'liveCasino', '/live-casino'],
  ['🎱', 'loto', '/loto'],
  ['🎮', 'virtuals', '/virtualne-igre'],
  ['👆', 'swipe', '/swipe-and-bet'],
  ['🎁', 'promo', '/promocije']
];

export default function Home() {
  const { hasPick, togglePick, toast } = useApp();
  const { t } = useT();
  const { open } = useGameLauncher();

  const [slide, setSlide] = useState(0);
  const [stats, setStats] = useState(null);
  const [top, setTop] = useState([]);
  const [live, setLive] = useState([]);
  const [rails, setRails] = useState([]);
  const [promos, setPromos] = useState([]);
  const [news, setNews] = useState([]);
  const [loading, setLoading] = useState(true);

  const slides = t('home.slides');

  useEffect(() => {
    const id = setInterval(() => setSlide(s => (s + 1) % SLIDE_STYLE.length), 6000);
    return () => clearInterval(id);
  }, []);

  useEffect(() => {
    let cancelled = false;
    Promise.allSettled([
      api.content.stats(),
      api.offer.events({ filter: 'all', limit: 10 }),
      api.offer.events({ filter: 'live', limit: 10 }),
      api.casino.lobby(),
      api.content.promos(),
      api.content.news()
    ]).then(([s, tp, l, c, p, n]) => {
      if (cancelled) return;
      if (s.status === 'fulfilled') setStats(s.value.totals);
      if (tp.status === 'fulfilled') setTop(tp.value.events.slice(0, 10));
      if (l.status === 'fulfilled') setLive(l.value.events.slice(0, 10));
      if (c.status === 'fulfilled') setRails(c.value.rails.slice(0, 3));
      if (p.status === 'fulfilled') setPromos(p.value.promos.slice(0, 4));
      if (n.status === 'fulfilled') setNews(n.value.news.slice(0, 4));
      setLoading(false);
    });
    return () => { cancelled = true; };
  }, []);

  const quickSub = (key) => {
    if (key === 'sport' && stats) return `${stats.events} ${t('common.events')}`;
    if (key === 'live' && stats) return `${stats.live} ${t('common.events')}`;
    if (key === 'casino' && stats) return `${stats.games} ${t('common.games')}`;
    if (key === 'liveCasino') return t('home.liveCasinoSub');
    if (key === 'loto') return t('home.lotoSub');
    if (key === 'virtuals') return t('home.virtualsSub');
    if (key === 'swipe') return t('home.swipeSub');
    if (key === 'promo') return t('home.promoSub');
    return t('home.quickOpen');
  };

  const OfferRow = ({ event }) => {
    const cols = event.marketSet === '12'
      ? ['1', '2', 'H1']
      : event.marketSet === 'outright' ? ['Tečaj'] : ['1', 'X', '2'];
    return (
      <div className="evt" style={{ '--cols': cols.length }}>
        <div className="evt-main">
          <div className="evt-time">
            {event.live ? <span className="evt-live-min">{event.minute}'</span> : time(event.startsAt)}
          </div>
          <div className="evt-teams">
            <div className="evt-team">{event.name}</div>
            <div className="evt-meta">
              <span>{event.flag} {event.leagueName}</span>
              {event.live && event.score
                ? <span style={{ color: 'var(--live)', fontWeight: 700 }}>{event.score}</span>
                : <span>#{event.code}</span>}
            </div>
          </div>
        </div>
        {cols.map(k => {
          const odds = event.markets?.[k];
          if (odds == null) return <button key={k} className="odd is-empty" disabled>–</button>;
          return (
            <button
              key={k}
              className={'odd' + (hasPick(event.id, k) ? ' is-picked' : '')}
              onClick={() => {
                togglePick(event, k, odds);
                toast(hasPick(event.id, k) ? t('home.removedFromSlip') : t('home.addedToSlip'), 'info');
              }}
            >
              {num(odds)}
            </button>
          );
        })}
        <span />
      </div>
    );
  };

  const s = slides[slide] || slides[0];
  const style = SLIDE_STYLE[slide];

  return (
    <div className="page" style={{ maxWidth: 1400 }}>
      {/* hero */}
      <div className="carousel">
        <div className="hero" style={{ background: style.bg }}>
          <span className="hero-eyebrow">{s.eyebrow}</span>
          <h1>{s.title}</h1>
          <p>{s.text}</p>
          <div className="hero-actions">
            <Link className="btn btn-accent btn-lg" to={style.primary}>{s.primary}</Link>
            <Link
              className="btn btn-ghost btn-lg"
              to={style.secondary}
              style={{ color: '#fff', borderColor: 'rgba(255,255,255,.45)' }}
            >
              {s.secondary}
            </Link>
          </div>
        </div>
        <button
          className="carousel-arrow prev"
          onClick={() => setSlide((slide - 1 + SLIDE_STYLE.length) % SLIDE_STYLE.length)}
          aria-label={t('common.prev')}
        >‹</button>
        <button
          className="carousel-arrow next"
          onClick={() => setSlide((slide + 1) % SLIDE_STYLE.length)}
          aria-label={t('common.next')}
        >›</button>
      </div>
      <div className="carousel-dots">
        {SLIDE_STYLE.map((_, i) => (
          <button key={i} className={i === slide ? 'is-active' : ''} onClick={() => setSlide(i)} aria-label={`${i + 1}`} />
        ))}
      </div>

      {/* quick links */}
      <section className="sec">
        <div className="sec-hd"><h2>{t('home.quickAccess')}</h2></div>
        <div className="quick-grid">
          {QUICK.map(([icon, key, to]) => (
            <Link className="quick-card" to={to} key={key}>
              <div className="ico">{icon}</div>
              <div className="t">{t('home.quick.' + key)}</div>
              <div className="s">{quickSub(key)}</div>
            </Link>
          ))}
        </div>
      </section>

      {loading && <Loader />}

      {/* top offer */}
      {top.length > 0 && (
        <section className="sec">
          <div className="sec-hd">
            <h2>⭐ {t('home.topOffer')}</h2>
            <Link className="more" to="/oklade">{t('home.wholeOffer')} →</Link>
          </div>
          <div className="panel">{top.map(e => <OfferRow key={e.id} event={e} />)}</div>
        </section>
      )}

      {/* live */}
      {live.length > 0 && (
        <section className="sec">
          <div className="sec-hd">
            <h2><span className="dot-live" /> {t('home.liveNow')}</h2>
            <Link className="more" to="/oklade?filter=live">{t('home.allLive')} →</Link>
          </div>
          <div className="panel">{live.map(e => <OfferRow key={e.id} event={e} />)}</div>
        </section>
      )}

      {/* casino rails */}
      {rails.map(rail => (
        <section className="sec" key={rail.id}>
          <div className="sec-hd">
            <h2>{rail.icon} {t('data.categories.' + rail.id)}</h2>
            <Link className="more" to={`/casino?kategorija=${rail.id}`}>
              {t('common.seeAll')} ({rail.total}) →
            </Link>
          </div>
          <div className="game-grid">
            {rail.games.map(g => <GameCard key={g.id} game={g} onOpen={open} />)}
          </div>
        </section>
      ))}

      {/* promos */}
      {promos.length > 0 && (
        <section className="sec">
          <div className="sec-hd">
            <h2>🎁 {t('home.promos')}</h2>
            <Link className="more" to="/promocije">{t('home.allPromos')} →</Link>
          </div>
          <div className="tile-grid">
            {promos.map(p => (
              <Link className="panel" to="/promocije" key={p.slug} style={{ display: 'block' }}>
                <div style={{
                  height: 96,
                  background: `linear-gradient(140deg,hsl(${p.hueA} 70% 44%),hsl(${p.hueB} 65% 24%))`,
                  display: 'grid', placeItems: 'center', fontSize: 30
                }}>🎁</div>
                <div className="panel-bd">
                  <span className="tag-new">{p.tag}</span>
                  <div style={{ fontWeight: 700, margin: '8px 0 4px', fontSize: 14 }}>{p.title}</div>
                  <div style={{ fontSize: 12.5, color: 'var(--txt-mute)' }}>{p.body.slice(0, 90)}…</div>
                </div>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* news */}
      {news.length > 0 && (
        <section className="sec">
          <div className="sec-hd">
            <h2>📰 {t('home.news')}</h2>
            <Link className="more" to="/novosti">{t('home.allNews')} →</Link>
          </div>
          <div className="tile-grid">
            {news.map(a => (
              <Link className="panel" to={`/novosti/${a.slug}`} key={a.slug} style={{ display: 'block' }}>
                <div className="panel-bd">
                  <div style={{ fontSize: 11, color: 'var(--accent)', fontWeight: 700 }}>
                    {a.category} · {dateOnly(a.publishedAt)}
                  </div>
                  <div style={{ fontWeight: 700, margin: '6px 0 4px', fontSize: 14 }}>{a.title}</div>
                  <div style={{ fontSize: 12.5, color: 'var(--txt-mute)' }}>{a.excerpt}</div>
                </div>
              </Link>
            ))}
          </div>
        </section>
      )}

      {/* about */}
      <section className="sec prose">
        <h2>{t('home.aboutTitle')}</h2>
        <p>{t('home.aboutBody')}</p>
        <h3>{t('home.implementedTitle')}</h3>
        <ul>
          {t('home.implemented').map((item, i) => <li key={i}>{item}</li>)}
        </ul>
        <h3>{t('home.noteTitle')}</h3>
        <p>{t('home.noteBody')}</p>
      </section>
    </div>
  );
}
