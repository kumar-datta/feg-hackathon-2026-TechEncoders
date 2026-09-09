import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import { eur, num, dateTime } from '../utils/format';

const TABS = [['listici', 'tickets'], ['inspiracija', 'inspiration']];

export default function Arena() {
  const { togglePick, toast } = useApp();
  const { t } = useT();
  const [tab, setTab] = useState('listici');
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    api.tickets.shared()
      .then(d => setTickets(d.tickets))
      .catch(setError)
      .finally(() => setLoading(false));
  }, []);

  const copyTicket = async (ticket) => {
    let added = 0;
    for (const sel of ticket.selections) {
      try {
        const { event } = await api.offer.event(sel.event);
        if (event.markets?.[sel.marketKey] != null) {
          togglePick(event, sel.marketKey, event.markets[sel.marketKey]);
          added++;
        }
      } catch { /* skip selections no longer in the offer */ }
    }
    toast(added ? t('arena.copied', { n: added }) : t('arena.copyFailed'), added ? 'ok' : 'err');
  };

  return (
    <div className="page" style={{ maxWidth: 1300 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('arena.title')}</div>
      <h1 className="page-title">🏟️ {t('arena.title')}</h1>
      <p className="page-lede">
        {t('arena.lede')} <Link to="/listici">{t('slip.myTickets')}</Link>.
      </p>

      <div className="cat-bar" style={{ margin: '22px 0' }}>
        {TABS.map(([id, key]) => (
          <button key={id} className={'chip' + (tab === id ? ' is-active' : '')} onClick={() => setTab(id)}>
            {t('arena.tabs.' + key)}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} />}
      {loading && <Loader />}

      {!loading && tab === 'listici' && (
        tickets.length === 0 ? (
          <Empty>{t('arena.empty')}</Empty>
        ) : (
          <div className="tile-grid" style={{ gridTemplateColumns: 'repeat(auto-fill,minmax(300px,1fr))' }}>
            {tickets.map(tk => (
              <div className="panel" key={tk.ref}>
                <div className="panel-hd">
                  <span>@{tk.user?.username || t('arena.player')}</span>
                  <span style={{
                    color: tk.status === 'won' ? 'var(--win)'
                      : tk.status === 'lost' ? 'var(--live)' : 'var(--accent)'
                  }}>
                    {t('arena.statuses.' + (tk.status === 'won' ? 'won' : tk.status === 'lost' ? 'lost' : 'open'))}
                  </span>
                </div>

                <div>
                  {tk.selections.map((s, i) => (
                    <div className="pick" key={i}>
                      <div className="pick-top">
                        <span className="pick-mkt">{s.marketKey}</span>
                        <span className="pick-odd">{num(s.odds)}</span>
                      </div>
                      <div className="pick-evt">{s.eventName}</div>
                      <div className="pick-lg">{s.leagueName} · {t('slip.code')} {s.code}</div>
                    </div>
                  ))}
                </div>

                <div className="slip-foot">
                  <div className="sum-row"><span>{t('slip.totalOdds')}</span><strong>{num(tk.totalOdds)}</strong></div>
                  <div className="sum-row"><span>{t('slip.stake')}</span><strong>{eur(tk.stake)}</strong></div>
                  <div className="sum-row total"><span>{t('slip.potential')}</span><strong>{eur(tk.potentialNet)}</strong></div>
                  <div style={{ fontSize: 11, color: 'var(--txt-mute)', marginTop: 8 }}>
                    {dateTime(tk.createdAt)}
                  </div>
                  <button className="btn btn-ghost btn-block" style={{ marginTop: 10 }} onClick={() => copyTicket(tk)}>
                    {t('arena.copy')}
                  </button>
                </div>
              </div>
            ))}
          </div>
        )
      )}

      {!loading && tab === 'inspiracija' && (
        <div className="prose">
          <h2>{t('arena.howTitle')}</h2>
          <p>{t('arena.howLead')}</p>
          <ul>
            {t('arena.howPoints').map(([head, body], i) => (
              <li key={i}><strong>{head}</strong> — {body}</li>
            ))}
          </ul>
          <h3>{t('arena.noteTitle')}</h3>
          <p>{t('arena.noteBody')}</p>
        </div>
      )}
    </div>
  );
}
