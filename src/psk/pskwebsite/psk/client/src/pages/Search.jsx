import { useEffect, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import api from '../api/client';
import GameCard from '../components/GameCard';
import { Loader, ErrorBox } from '../components/Loader';
import useGameLauncher from '../games/useGameLauncher';
import { useT } from '../i18n';

export default function Search() {
  const [params] = useSearchParams();
  const q = params.get('q') || '';
  const { open } = useGameLauncher();
  const { t } = useT();

  const [results, setResults] = useState({ events: [], games: [] });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!q) { setLoading(false); return; }
    setLoading(true);
    api.content.search(q)
      .then(setResults)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [q]);

  return (
    <div className="page" style={{ maxWidth: 1400 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('common.search')}</div>
      <h1 className="page-title">{t('search.title')}</h1>
      <p className="page-lede">
        {q
          ? t('search.lede', { q, events: results.events.length, games: results.games.length })
          : t('search.prompt')}
      </p>

      {error && <ErrorBox error={error} />}
      {loading && q && <Loader />}

      {!loading && q && (
        <>
          <section className="sec">
            <div className="sec-hd"><h2>🏆 {t('search.events')}</h2></div>
            {results.events.length === 0 ? (
              <p style={{ color: 'var(--txt-mute)' }}>{t('search.noEvents')}</p>
            ) : (
              <div className="panel">
                {results.events.map(e => (
                  <Link
                    key={e.id}
                    className="evt"
                    style={{ gridTemplateColumns: '1fr auto', '--cols': 0 }}
                    to={`/oklade?sport=${e.sport}&league=${e.league}`}
                  >
                    <div className="evt-main">
                      <div className="evt-teams">
                        <div className="evt-team">{e.name}</div>
                        <div className="evt-meta">
                          <span>{e.flag} {e.leagueName}</span>
                          <span>#{e.code}</span>
                        </div>
                      </div>
                    </div>
                    <span style={{ color: 'var(--accent)', fontWeight: 700 }}>{t('common.open')} →</span>
                  </Link>
                ))}
              </div>
            )}
          </section>

          <section className="sec">
            <div className="sec-hd"><h2>🎰 {t('search.games')}</h2></div>
            {results.games.length === 0 ? (
              <p style={{ color: 'var(--txt-mute)' }}>{t('search.noGames')}</p>
            ) : (
              <div className="game-grid dense">
                {results.games.map(g => (
                  <GameCard key={g.id} game={g} onOpen={open} />
                ))}
              </div>
            )}
          </section>
        </>
      )}
    </div>
  );
}
