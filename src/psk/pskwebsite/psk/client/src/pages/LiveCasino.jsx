import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import GameCard from '../components/GameCard';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import useGameLauncher from '../games/useGameLauncher';
import { useT } from '../i18n';

const TABS = [
  ['all', 'all', '🎬'],
  ['roulette', 'roulette', '🎡'],
  ['table', 'table', '🃏'],
  ['game-shows', 'shows', '🎪']
];

export default function LiveCasino() {
  const { open } = useGameLauncher();
  const { t } = useT();
  const [tab, setTab] = useState('all');
  const [tables, setTables] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    setLoading(true);
    api.casino.games({ live: true, category: tab === 'all' ? '' : tab, limit: 60 })
      .then(d => setTables(d.games))
      .catch(setError)
      .finally(() => setLoading(false));
  }, [tab]);

  useEffect(() => { load(); }, [load]);

  /* deep-link: /live-casino?game=<slug> opens that table directly */
  useEffect(() => {
    const slug = new URLSearchParams(window.location.search).get('game');
    if (!slug) return;
    let cancelled = false;
    api.casino.game(slug)
      .then((d) => { if (!cancelled && d.game) open(d.game); })
      .catch(() => {});
    return () => { cancelled = true; };
  }, []);

  return (
    <div className="page" style={{ maxWidth: 1500 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('liveCasino.title')}</div>
      <h1 className="page-title">🎥 {t('liveCasino.title')}</h1>
      <p className="page-lede">{t('liveCasino.lede')}</p>

      <div className="cat-bar" style={{ margin: '22px 0 18px' }}>
        {TABS.map(([id, key, icon]) => (
          <button key={id} className={'chip' + (tab === id ? ' is-active' : '')} onClick={() => setTab(id)}>
            {icon} {t('liveCasino.tabs.' + key)}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && !error && (
        tables.length === 0
          ? <Empty>{t('liveCasino.noTables')}</Empty>
          : (
            <div className="game-grid">
              {tables.map(g => <GameCard key={g.id} game={g} onOpen={open} />)}
            </div>
          )
      )}

      <section className="sec prose">
        <h2>{t('liveCasino.howTitle')}</h2>
        <p>{t('liveCasino.howBody')}</p>
      </section>
    </div>
  );
}
