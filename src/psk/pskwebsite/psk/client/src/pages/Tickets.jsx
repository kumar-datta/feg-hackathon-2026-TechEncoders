import { useEffect, useState, useCallback } from 'react';
import { Link } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader, ErrorBox, Empty } from '../components/Loader';
import { useT } from '../i18n';
import { eur, num, dateTime } from '../utils/format';

const FILTERS = [['', 'all'], ['open', 'open'], ['won', 'won'], ['lost', 'lost']];

const STATUS_COLOR = {
  open: 'var(--accent)', won: 'var(--win)', lost: 'var(--live)', void: 'var(--txt-mute)'
};

export default function Tickets() {
  const { user, setBalance, toast } = useApp();
  const { t } = useT();
  const [status, setStatus] = useState('');
  const [tickets, setTickets] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const load = useCallback(() => {
    if (!user) { setLoading(false); return; }
    setLoading(true);
    api.tickets.mine({ status })
      .then(d => setTickets(d.tickets))
      .catch(setError)
      .finally(() => setLoading(false));
  }, [user, status]);

  useEffect(() => { load(); }, [load]);

  if (!user) {
    return (
      <div className="page narrow">
        <h1 className="page-title">{t('tickets.title')}</h1>
        <p className="page-lede">{t('tickets.needLogin')}</p>
        <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
          <Link className="btn btn-accent" to="/prijava">{t('header.login')}</Link>
          <Link className="btn btn-ghost" to="/registracija">{t('header.register')}</Link>
        </div>
      </div>
    );
  }

  const settle = async (ref) => {
    try {
      const res = await api.tickets.settle(ref);
      setBalance(res.balance);
      toast(res.ticket.status === 'won'
        ? t('tickets.settledWon', { ref, amount: eur(res.ticket.payout) })
        : t('tickets.settledLost', { ref }),
        res.ticket.status === 'won' ? 'ok' : 'info');
      load();
    } catch (err) {
      toast(err.message, 'err');
    }
  };

  const share = async (ref) => {
    try {
      const res = await api.tickets.share(ref);
      toast(res.ticket.shared ? t('tickets.shared') : t('tickets.unshared'));
      load();
    } catch (err) {
      toast(err.message, 'err');
    }
  };

  return (
    <div className="page" style={{ maxWidth: 1200 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('tickets.title')}</div>
      <h1 className="page-title">🎫 {t('tickets.title')}</h1>
      <p className="page-lede">{t('tickets.lede')}</p>

      <div className="cat-bar" style={{ margin: '22px 0' }}>
        {FILTERS.map(([key, lbl]) => (
          <button key={key} className={'chip' + (status === key ? ' is-active' : '')} onClick={() => setStatus(key)}>
            {t('tickets.filters.' + lbl)}
          </button>
        ))}
      </div>

      {error && <ErrorBox error={error} onRetry={load} />}
      {loading && <Loader />}

      {!loading && !error && (
        tickets.length === 0 ? (
          <Empty>
            {t('tickets.empty')}{' '}
            <Link to="/oklade" style={{ color: 'var(--accent)' }}>{t('tickets.emptyCta')}</Link> {t('tickets.emptyTail')}
          </Empty>
        ) : (
          <div className="tile-grid" style={{ gridTemplateColumns: 'repeat(auto-fill,minmax(320px,1fr))' }}>
            {tickets.map(tk => {
              const colour = STATUS_COLOR[tk.status] || STATUS_COLOR.open;
              return (
                <div className="panel" key={tk.ref}>
                  <div className="panel-hd">
                    <span>{tk.ref}</span>
                    <span style={{ color: colour }}>{t('tickets.statuses.' + tk.status)}</span>
                  </div>

                  <div>
                    {tk.selections.map((sel, i) => (
                      <div className="pick" key={i}>
                        <div className="pick-top">
                          <span className="pick-mkt">
                            {sel.marketKey}
                            {sel.result !== 'open' && (
                              <span style={{ marginLeft: 6, color: sel.result === 'won' ? 'var(--win)' : 'var(--live)' }}>
                                {sel.result === 'won' ? '✓' : '✕'}
                              </span>
                            )}
                          </span>
                          <span className="pick-odd">{num(sel.odds)}</span>
                        </div>
                        <div className="pick-evt">{sel.eventName}</div>
                        <div className="pick-lg">{sel.leagueName} · {t('slip.code')} {sel.code}</div>
                      </div>
                    ))}
                  </div>

                  <div className="slip-foot">
                    <div className="sum-row"><span>{t('tickets.stake')}</span><strong>{eur(tk.stake)}</strong></div>
                    <div className="sum-row"><span>{t('tickets.totalOdds')}</span><strong>{num(tk.totalOdds)}</strong></div>
                    <div className="sum-row"><span>{t('tickets.deduction')}</span><strong>-{eur(tk.deduction)}</strong></div>
                    <div className="sum-row total">
                      <span>{tk.status === 'won' ? t('tickets.paidOut') : t('tickets.potential')}</span>
                      <strong>{eur(tk.status === 'won' ? tk.payout : tk.potentialNet)}</strong>
                    </div>
                    <div style={{ fontSize: 11, color: 'var(--txt-mute)', marginTop: 8 }}>
                      {dateTime(tk.createdAt)}
                    </div>

                    <div style={{ display: 'flex', gap: 8, marginTop: 10 }}>
                      {tk.status === 'open' && (
                        <button className="btn btn-accent" style={{ flex: 1 }} onClick={() => settle(tk.ref)}>
                          {t('tickets.settle')}
                        </button>
                      )}
                      <button className="btn btn-ghost" style={{ flex: 1 }} onClick={() => share(tk.ref)}>
                        {tk.shared ? t('tickets.unshare') : t('tickets.share')}
                      </button>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )
      )}
    </div>
  );
}
