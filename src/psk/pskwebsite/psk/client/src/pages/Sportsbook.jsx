import { useEffect, useState, useCallback } from 'react';
import { useSearchParams } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import Sidebar from '../components/Sidebar';
import BetSlip from '../components/BetSlip';
import EventRow from '../components/EventRow';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import { num } from '../utils/format';

const FILTERS = ['all', 'live', 'today', 'soon'];

export default function Sportsbook() {
  const { hasPick, togglePick, setModal, closeModal, toast } = useApp();
  const { t } = useT();
  const [params, setParams] = useSearchParams();

  const sport  = params.get('sport')  || 'nogomet';
  const league = params.get('league') || '';
  const filter = params.get('filter') || 'all';

  const [tree, setTree] = useState(null);
  const [meta, setMeta] = useState(null);
  const [groups, setGroups] = useState([]);
  const [count, setCount] = useState(0);
  const [collapsed, setCollapsed] = useState(() => new Set());
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  /* sidebar tree + market metadata (once) */
  useEffect(() => {
    Promise.all([api.offer.sports(), api.offer.meta()])
      .then(([t, m]) => { setTree(t); setMeta(m); })
      .catch(setError);
  }, []);

  /* offer, refetched whenever the query changes */
  const load = useCallback(() => {
    setLoading(true);
    setError(null);
    api.offer.events({ sport, league, filter, limit: 400 })
      .then(d => { setGroups(d.groups); setCount(d.count); })
      .catch(setError)
      .finally(() => setLoading(false));
  }, [sport, league, filter]);

  useEffect(() => { load(); }, [load]);

  /* keep live prices moving */
  useEffect(() => {
    if (filter !== 'live') return;
    const id = setInterval(load, 20000);
    return () => clearInterval(id);
  }, [filter, load]);

  const select = ({ sport: s, league: l, filter: f }) => {
    const next = {};
    if (f === 'live') { next.filter = 'live'; }
    else {
      if (s) next.sport = s;
      if (l) next.league = l;
      if (f && f !== 'all') next.filter = f;
    }
    setParams(next);
  };

  const activeSport = tree?.sports?.find(s => s.slug === sport);
  const columns = meta?.marketSets?.[activeSport?.marketSet || '1x2'] || ['1', 'X', '2'];

  const toggleGroup = (slug) =>
    setCollapsed(prev => {
      const next = new Set(prev);
      next.has(slug) ? next.delete(slug) : next.add(slug);
      return next;
    });

  /* full market board */
  const openMarkets = async (event) => {
    try {
      const { event: ev, board } = await api.offer.event(event.id);
      setModal({
        title: `${ev.sportIcon || '🏆'} ${ev.name}`,
        wide: true,
        content: (
          <>
            <div style={{ fontSize: 12, color: 'var(--txt-mute)', marginBottom: 14 }}>
              {ev.flag} {ev.leagueName} · {t('slip.code')} {ev.code}
              {ev.live && <span style={{ color: 'var(--live)' }}> · {t('sportsbook.liveShort')} {ev.minute}' {ev.score}</span>}
            </div>

            {board.map(group => (
              <div style={{ marginBottom: 18 }} key={group.name}>
                <div style={{
                  fontSize: 12, fontWeight: 700, color: 'var(--txt-mute)',
                  marginBottom: 8, textTransform: 'uppercase'
                }}>
                  {t('data.marketGroups.' + group.name)}
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill,minmax(96px,1fr))', gap: 6 }}>
                  {group.markets.map(m => (
                    <button
                      key={m.key}
                      className="odd"
                      style={{ height: 42, flexDirection: 'column' }}
                      onClick={() => {
                        togglePick({ ...ev, markets: { ...ev.markets, [m.key]: m.odds } }, m.key, m.odds);
                        toast(t('sportsbook.addedToSlip', { key: m.key }));
                      }}
                    >
                      <span style={{ fontSize: 10, color: 'var(--txt-mute)' }}>{m.key}</span>
                      <span>{num(m.odds)}</span>
                    </button>
                  ))}
                </div>
              </div>
            ))}
          </>
        ),
        footer: <button className="btn btn-ghost" onClick={closeModal}>{t('common.close')}</button>
      });
    } catch (err) {
      toast(err.message, 'err');
    }
  };

  return (
    <div className="layout">
      <Sidebar data={tree} activeSport={sport} activeLeague={league} onSelect={select} />

      <div>
        <div className="panel">
          <div className="offer-toolbar">
            <strong style={{ fontSize: 15, marginRight: 6 }}>
              {activeSport ? `${activeSport.icon} ${t('data.sports.' + activeSport.slug)}` : t('sportsbook.offer')}
            </strong>
            {FILTERS.map(key => (
              <button
                key={key}
                className={
                  'chip' + (filter === key ? ' is-active' : '') + (key === 'live' ? ' is-live' : '')
                }
                onClick={() => select({ sport, league, filter: key })}
              >
                {t('sportsbook.filters.' + key)}{key === 'live' && tree ? ` ${tree.liveTotal}` : ''}
              </button>
            ))}
            <span style={{ flex: 1 }} />
            <span style={{ fontSize: 12, color: 'var(--txt-mute)' }}>{t('sportsbook.eventsCount', { n: count })}</span>
          </div>

          {error && <div style={{ padding: 14 }}><ErrorBox error={error} onRetry={load} /></div>}
          {loading && <Loader />}

          {!loading && !error && groups.length === 0 && (
            <Empty>{t('sportsbook.noEvents')}</Empty>
          )}

          {!loading && groups.map(group => (
            <div className="league-block" key={group.league}>
              <button className="league-hd" onClick={() => toggleGroup(group.league)}>
                <span className="flag">{group.flag}</span>
                <span>{group.leagueName}</span>
                <span className="cnt">{group.events.length}</span>
              </button>

              {!collapsed.has(group.league) && (
                <>
                  <div className="mk-head" style={{ '--cols': columns.length }}>
                    <span>{t('sportsbook.event')}</span>
                    {columns.map(c => <span key={c}>{c}</span>)}
                    <span />
                  </div>
                  {group.events.map(ev => (
                    <EventRow key={ev.id} event={ev} columns={columns} onOpenMarkets={openMarkets} />
                  ))}
                </>
              )}
            </div>
          ))}
        </div>
      </div>

      <div className="slip-col sticky-col">
        <BetSlip />
      </div>
    </div>
  );
}
