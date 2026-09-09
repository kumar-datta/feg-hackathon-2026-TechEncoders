import { useState } from 'react';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

/**
 * Sports tree used by the sportsbook.
 * `data` comes from GET /api/offer/sports.
 */
export default function Sidebar({ data, activeSport, activeLeague, onSelect }) {
  const [open, setOpen] = useState(() => new Set(activeSport ? [activeSport] : ['nogomet']));
  const [filter, setFilter] = useState('');
  const { drawerOpen, setDrawerOpen } = useApp();
  const { t } = useT();

  const toggle = (slug) =>
    setOpen(prev => {
      const next = new Set(prev);
      next.has(slug) ? next.delete(slug) : next.add(slug);
      return next;
    });

  const sports = (data?.sports || []).filter(s =>
    !filter || s.name.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <>
      {drawerOpen && <div className="drawer-back is-open" onClick={() => setDrawerOpen(false)} />}

      <div className={'sidebar-col' + (drawerOpen ? ' is-open' : '')}>
        <div className="panel sidebar">
          <div className="panel-hd">
            <span>{t('sportsbook.sports')}</span>
            <button
              onClick={() => { onSelect({ filter: 'live' }); setDrawerOpen(false); }}
              style={{ color: 'var(--live)', fontSize: 11, fontWeight: 700 }}
            >
              {t('sportsbook.liveShort')} {data?.liveTotal ?? 0}
            </button>
          </div>

          <div className="side-search">
            <input
              type="search"
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              placeholder={t('sportsbook.filterSports')}
              aria-label={t('sportsbook.filterSports')}
            />
          </div>

          <div className="side-list scroll-y">
            {sports.length === 0 && (
              <div style={{ padding: 20, color: 'var(--txt-mute)', fontSize: 13 }}>
                {t('sportsbook.noSports')}
              </div>
            )}

            {sports.map(s => (
              <div key={s.slug}>
                <button
                  className={'sport-row' + (open.has(s.slug) ? ' is-open' : '')}
                  onClick={() => { toggle(s.slug); onSelect({ sport: s.slug, league: null, filter: 'all' }); }}
                >
                  <span className="sport-ico">{s.icon}</span>
                  <span className="sport-name">{t(`data.sports.${s.slug}`)}</span>
                  <span className="sport-count">{s.count}</span>
                  <span className="sport-caret">▶</span>
                </button>

                <div className={'league-list' + (open.has(s.slug) ? ' is-open' : '')}>
                  {s.leagues.map(l => (
                    <button
                      key={l.slug}
                      className={'league-row' + (activeLeague === l.slug ? ' is-active' : '')}
                      onClick={() => { onSelect({ sport: s.slug, league: l.slug, filter: 'all' }); setDrawerOpen(false); }}
                    >
                      <span>{l.flag} {l.name}</span>
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </>
  );
}
