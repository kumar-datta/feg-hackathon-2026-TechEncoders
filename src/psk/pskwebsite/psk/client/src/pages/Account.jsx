import { useEffect, useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import api from '../api/client';
import { useApp } from '../context/AppContext';
import { Loader } from '../components/Loader';
import { useT } from '../i18n';
import { eur, dateTime } from '../utils/format';

const DEPOSITS = [10, 25, 50, 100];

export default function Account() {
  const { user, setBalance, logout, toast, refreshUser } = useApp();
  const { t } = useT();
  const navigate = useNavigate();

  const [rounds, setRounds] = useState([]);
  const [tickets, setTickets] = useState([]);
  const [limits, setLimits] = useState({ dailyDeposit: 0, dailyLoss: 0, sessionMins: 0 });
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (!user) { setLoading(false); return; }
    setLimits({
      dailyDeposit: user.limits?.dailyDeposit || 0,
      dailyLoss: user.limits?.dailyLoss || 0,
      sessionMins: user.limits?.sessionMins || 0
    });
    Promise.allSettled([api.casino.rounds(), api.tickets.mine()])
      .then(([r, tk]) => {
        if (r.status === 'fulfilled') setRounds(r.value.rounds);
        if (tk.status === 'fulfilled') setTickets(tk.value.tickets);
      })
      .finally(() => setLoading(false));
  }, [user]);

  if (!user) {
    return (
      <div className="page narrow">
        <h1 className="page-title">{t('account.title')}</h1>
        <p className="page-lede">{t('account.needLogin')}</p>
        <div style={{ display: 'flex', gap: 10, marginTop: 20 }}>
          <Link className="btn btn-accent" to="/prijava">{t('header.login')}</Link>
          <Link className="btn btn-ghost" to="/registracija">{t('header.register')}</Link>
        </div>
      </div>
    );
  }

  const deposit = async (amount) => {
    setBusy(true);
    try {
      const res = await api.auth.deposit(amount);
      setBalance(res.balance);
      toast(t('account.deposited', { amount: eur(amount) }));
    } catch (err) {
      toast(err.message, 'err');
    } finally {
      setBusy(false);
    }
  };

  const saveLimits = async (e) => {
    e.preventDefault();
    setBusy(true);
    try {
      await api.auth.limits(limits);
      await refreshUser();
      toast(t('account.limitsSaved'));
    } catch (err) {
      toast(err.message, 'err');
    } finally {
      setBusy(false);
    }
  };

  const selfExclude = async (days) => {
    if (!window.confirm(t('account.selfExcludeConfirm', { n: days }))) return;
    try {
      await api.auth.limits({ selfExcludeDays: days });
      toast(t('account.selfExcluded', { n: days }), 'info');
      logout();
      navigate('/');
    } catch (err) {
      toast(err.message, 'err');
    }
  };

  const totalStaked = rounds.reduce((a, r) => a + (r.bet || 0), 0);
  const totalWon = rounds.reduce((a, r) => a + (r.win || 0), 0);

  return (
    <div className="page" style={{ maxWidth: 1100 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('account.title')}</div>
      <h1 className="page-title">👤 {user.username}</h1>
      <p className="page-lede">{t('account.openedOn', { date: dateTime(user.createdAt) })}</p>

      <div className="quick-grid" style={{ marginTop: 24 }}>
        <div className="quick-card">
          <div className="ico">💰</div>
          <div className="t">{eur(user.balance)}</div>
          <div className="s">{t('account.cards.balance')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">🎫</div>
          <div className="t">{tickets.length}</div>
          <div className="s">{t('account.cards.tickets')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">🎰</div>
          <div className="t">{rounds.length}</div>
          <div className="s">{t('account.cards.rounds')}</div>
        </div>
        <div className="quick-card">
          <div className="ico">📈</div>
          <div className="t" style={{ color: totalWon >= totalStaked ? 'var(--win)' : 'var(--live)' }}>
            {eur(totalWon - totalStaked)}
          </div>
          <div className="s">{t('account.cards.net')}</div>
        </div>
      </div>

      {/* deposit */}
      <section className="sec">
        <div className="sec-hd"><h2>{t('account.depositTitle')}</h2></div>
        <div className="panel panel-bd">
          <p style={{ color: 'var(--txt-dim)', fontSize: 13.5 }}>
            {t('account.depositBody')}
          </p>
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            {DEPOSITS.map(a => (
              <button key={a} className="btn btn-accent" disabled={busy} onClick={() => deposit(a)}>
                + {eur(a)}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* limits */}
      <section className="sec" id="limiti">
        <div className="sec-hd"><h2>{t('account.limitsTitle')}</h2></div>
        <div className="panel panel-bd">
          <form className="form-grid" onSubmit={saveLimits} style={{ gridTemplateColumns: 'repeat(auto-fit,minmax(200px,1fr))' }}>
            <div className="field">
              <label htmlFor="dd">{t('account.limitDeposit')}</label>
              <input id="dd" type="number" min="0" value={limits.dailyDeposit}
                onChange={(e) => setLimits(l => ({ ...l, dailyDeposit: e.target.value }))} />
            </div>
            <div className="field">
              <label htmlFor="dl">{t('account.limitLoss')}</label>
              <input id="dl" type="number" min="0" value={limits.dailyLoss}
                onChange={(e) => setLimits(l => ({ ...l, dailyLoss: e.target.value }))} />
            </div>
            <div className="field">
              <label htmlFor="sm">{t('account.limitSession')}</label>
              <input id="sm" type="number" min="0" value={limits.sessionMins}
                onChange={(e) => setLimits(l => ({ ...l, sessionMins: e.target.value }))} />
            </div>
            <div style={{ display: 'flex', alignItems: 'flex-end' }}>
              <button className="btn btn-primary btn-block" disabled={busy}>{t('account.saveLimits')}</button>
            </div>
          </form>
          <div className="note">
            {t('account.limitsNote')}
          </div>
        </div>
      </section>

      {/* self exclusion */}
      <section className="sec" id="samoiskljucenje">
        <div className="sec-hd"><h2>{t('account.selfExclusionTitle')}</h2></div>
        <div className="panel panel-bd">
          <p style={{ color: 'var(--txt-dim)', fontSize: 13.5 }}>
            {t('account.selfExclusionBody')}
          </p>
          <div style={{ display: 'flex', gap: 10, flexWrap: 'wrap' }}>
            {[1, 7, 30, 90].map(d => (
              <button key={d} className="btn btn-ghost" onClick={() => selfExclude(d)}>
                {d} {d === 1 ? t('account.day') : t('account.days')}
              </button>
            ))}
          </div>
        </div>
      </section>

      {/* history */}
      <section className="sec">
        <div className="sec-hd">
          <h2>{t('account.historyTitle')}</h2>
          <Link className="more" to="/listici">{t('slip.myTickets')} →</Link>
        </div>
        {loading ? <Loader /> : rounds.length === 0 ? (
          <div className="slip-empty" style={{ padding: 40 }}>{t('account.noRounds')}</div>
        ) : (
          <div className="panel tbl-wrap">
            <table className="tbl">
              <thead>
                <tr><th>{t('account.tbl.game')}</th><th>{t('account.tbl.time')}</th><th className="num">{t('account.tbl.bet')}</th><th className="num">{t('account.tbl.win')}</th></tr>
              </thead>
              <tbody>
                {rounds.slice(0, 25).map(r => (
                  <tr key={r._id}>
                    <td>{r.game?.symbol} {r.game?.title || r.engine}</td>
                    <td style={{ color: 'var(--txt-mute)', fontSize: 12 }}>{dateTime(r.createdAt)}</td>
                    <td className="num">{eur(r.bet)}</td>
                    <td className="num" style={{ color: r.win > 0 ? 'var(--win)' : 'var(--txt-mute)', fontWeight: 700 }}>
                      {eur(r.win)}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>

      <div style={{ marginTop: 30 }}>
        <button className="btn btn-ghost" onClick={() => { logout(); navigate('/'); }}>{t('header.logout')}</button>
      </div>
    </div>
  );
}
