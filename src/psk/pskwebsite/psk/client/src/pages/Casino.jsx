import { useEffect, useState, useCallback } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import api from '../api/client';
import GameCard from '../components/GameCard';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import useGameLauncher from '../games/useGameLauncher';
import { eur } from '../utils/format';

export default function Casino() {
  const { open } = useGameLauncher();
  const { t } = useT();
  const [params, setParams] = useSearchParams();

  const category = params.get('kategorija') || 'lobby';
  const provider = params.get('provider') || '';
  const [q, setQ] = useState(params.get('q') || '');

  const [categories, setCategories] = useState([]);
  const [providers, setProviders] = useState([]);
  const [lobby, setLobby] = useState(null);
  const [games, setGames] = useState([]);
  const [total, setTotal] = useState(0);
  const [page, setPage] = useState(1);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const isLobby = category === 'lobby' && !provider && !q;

  useEffect(() => {
    Promise.all([api.casino.categories(), api.casino.providers()])
      .then(([c, p]) => { setCategories(c.categories); setProviders(p.providers); })
      .catch(setError);
  }, []);

  const load = useCallback(() => {
    setLoading(true);
    setError(null);

    if (isLobby) {
      api.casino.lobby()
        .then(setLobby)
        .catch(setError)
        .finally(() => setLoading(false));
    } else {
      api.casino.games({ category, provider, q, page, limit: 60 })
        .then(d => { setGames(d.games); setTotal(d.total); })
        .catch(setError)
        .finally(() => setLoading(false));
    }
  }, [isLobby, category, provider, q, page]);

  useEffect(() => { load(); }, [load]);

  /* deep-link: /casino?game=<slug> opens that game directly, which is how the
     assistant navigates to a game (games live in a modal, not on their own route) */
  useEffect(() => {
    const slug = params.get('game');
    if (!slug) return;
    let cancelled = false;
    api.casino.game(slug)
      .then((d) => { if (!cancelled && d.game) open(d.game); })
      .catch(() => {});
    return () => { cancelled = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.get('game')]);

  /* debounce the search box */
  useEffect(() => {
    const id = setTimeout(() => {
      const next = {};
      if (category !== 'lobby') next.kategorija = category;
      if (provider) next.provider = provider;
      if (q) next.q = q;
      setParams(next, { replace: true });
      setPage(1);
    }, 300);
    return () => clearTimeout(id);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  const setCategory = (id) => {
    setPage(1);
    setParams(id === 'lobby' ? {} : { kategorija: id });
  };

  const activeName = provider
    ? (providers.find(p => p.slug === provider)?.name || provider)
    : t('data.categories.' + category);

  return (
    <div className="page" style={{ maxWidth: 1500 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('casino.title')}</div>
      <h1 className="page-title">🎰 {t('casino.title')}</h1>
      <p className="page-lede">{t('casino.lede')}</p>

      {/* search */}
      <div className="hdr-search" style={{ maxWidth: '100%', flex: 1, height: 40, margin: '20px 0 16px' }}>
        <span>🔍</span>
        <input
          type="search"
          value={q}
          onChange={(e) => setQ(e.target.value)}
          placeholder={t('casino.searchPlaceholder')}
          aria-label={t('casino.searchLabel')}
        />
      </div>

      {/* categories */}
      <div className="cat-bar" style={{ marginBottom: 18 }}>
        {categories.map(c => (
          <button
            key={c.id}
            className={'chip' + (category === c.id && !provider ? ' is-active' : '')}
            onClick={() => setCategory(c.id)}
          >
            {c.icon} {t('data.categories.' + c.id)}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {/* jackpot strip */}
      {!loading && isLobby && lobby?.jackpots?.length > 0 && (
        <div className="jp-strip" style={{ marginBottom: 24 }}>
          {lobby.jackpots.map((g, i) => (
            <div className="jp-card" key={g.id}>
              <div className="lbl">{t('casino.jackpotTiers')[i] || t('casino.jackpot')}</div>
              <div className="amt">{eur(g.jackpot)}</div>
              <div className="sub">{g.title}</div>
            </div>
          ))}
        </div>
      )}

      {/* lobby rails */}
      {!loading && isLobby && lobby?.rails?.map(rail => (
        <section className="sec" key={rail.id}>
          <div className="sec-hd">
            <h2>{rail.icon} {t('data.categories.' + rail.id)}</h2>
            <button className="more" onClick={() => setCategory(rail.id)}>
              {t('common.seeAll')} ({rail.total}) →
            </button>
          </div>
          <div className="game-grid">
            {rail.games.map(g => <GameCard key={g.id} game={g} onOpen={open} />)}
          </div>
        </section>
      ))}

      {/* provider grid in the lobby */}
      {!loading && isLobby && providers.length > 0 && (
        <section className="sec">
          <div className="sec-hd">
            <h2>🏢 {t('casino.providers')}</h2>
            <Link className="more" to="/provideri">{t('casino.allProviders', { n: providers.length })} →</Link>
          </div>
          <div className="provider-grid">
            {providers.slice(0, 18).map(p => (
              <button
                className="provider-card"
                key={p.slug}
                onClick={() => { setPage(1); setParams({ provider: p.slug }); }}
              >
                {p.name}<span className="n">{p.games} {t('common.games')}</span>
              </button>
            ))}
          </div>
        </section>
      )}

      {/* filtered grid */}
      {!loading && !isLobby && (
        <>
          <div className="sec-hd">
            <h2>{activeName}</h2>
            <span className="more">{t('casino.gamesCount', { n: total })}</span>
          </div>

          {games.length === 0 ? (
            <Empty>{t('casino.noGames')}</Empty>
          ) : (
            <div className="game-grid dense">
              {games.map(g => <GameCard key={g.id} game={g} onOpen={open} />)}
            </div>
          )}

          {total > 60 && (
            <div style={{ display: 'flex', gap: 10, justifyContent: 'center', marginTop: 24 }}>
              <button className="btn btn-ghost" disabled={page === 1} onClick={() => setPage(p => p - 1)}>
                ← {t('common.prev')}
              </button>
              <span style={{ alignSelf: 'center', color: 'var(--txt-mute)', fontSize: 13 }}>
                {t('common.page')} {page} / {Math.ceil(total / 60)}
              </span>
              <button
                className="btn btn-ghost"
                disabled={page >= Math.ceil(total / 60)}
                onClick={() => setPage(p => p + 1)}
              >
                {t('common.next')} →
              </button>
            </div>
          )}
        </>
      )}
    </div>
  );
}
