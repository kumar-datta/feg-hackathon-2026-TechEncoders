import { Link, useNavigate } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import { eur, num } from '../utils/format';

const DEDUCTION_RATE = 0.10;
const QUICK = [2, 5, 10, 20, 50];

export default function BetSlip() {
  const {
    slip, stake, setStake, removePick, clearSlip, totalOdds,
    user, toast, setModal, closeModal
  } = useApp();
  const { t } = useT();

  const navigate = useNavigate();

  const gross = stake * totalOdds;
  const deduction = gross > stake ? (gross - stake) * DEDUCTION_RATE : 0;
  const net = gross - deduction;

  /** The slip no longer places the bet directly — it hands off to /checkout. */
  const submit = () => {
    if (!user) {
      setModal({
        title: t('slip.loginTitle'),
        content: (
          <>
            <p>{t('slip.loginBody')}</p>
            <p style={{ color: 'var(--txt-mute)', fontSize: 13 }}>{t('slip.loginNote')}</p>
          </>
        ),
        footer: (
          <>
            <button className="btn btn-ghost" onClick={() => { closeModal(); navigate('/registracija'); }}>
              {t('header.register')}
            </button>
            <button className="btn btn-primary" onClick={() => { closeModal(); navigate('/prijava'); }}>
              {t('auth.signIn')}
            </button>
          </>
        )
      });
      return;
    }
    navigate('/checkout');
  };

  return (
    <div className="panel slip">
      <div className="slip-tabs">
        <button className="slip-tab is-active">
          {t('slip.title')} {slip.length > 0 && <span className="cnt">{slip.length}</span>}
        </button>
        <Link className="slip-tab" to="/listici" style={{ textAlign: 'center' }}>{t('slip.myTickets')}</Link>
      </div>

      <div className="slip-body">
        {slip.length === 0 ? (
          <div className="slip-empty">
            <span className="big">🎫</span>
            {t('slip.empty')}<br />{t('slip.emptyHint')}
          </div>
        ) : (
          slip.map((p, i) => (
            <div className="pick" key={`${p.eventId}-${p.marketKey}`}>
              <button className="pick-rm" onClick={() => removePick(i)} title={t('slip.remove')}>✕</button>
              <div className="pick-top">
                <span className="pick-mkt">{p.marketKey}</span>
                <span className="pick-odd">{num(p.odds)}</span>
              </div>
              <div className="pick-evt">{p.eventName}</div>
              <div className="pick-lg">{p.leagueName} · {t('slip.code')} {p.code}</div>
            </div>
          ))
        )}
      </div>

      <div className="slip-foot">
        <div className="quick-stakes">
          {QUICK.map(v => (
            <button key={v} onClick={() => setStake(v)}>{v}€</button>
          ))}
        </div>

        <div className="stake-row">
          <label htmlFor="stakeInput">{t('slip.stake')}</label>
          <input
            id="stakeInput"
            className="stake-input"
            type="number"
            min="0.5"
            step="0.5"
            value={stake}
            onChange={(e) => setStake(e.target.value)}
          />
        </div>

        <div className="sum-row"><span>{t('slip.pairs')}</span><strong>{slip.length}</strong></div>
        <div className="sum-row"><span>{t('slip.totalOdds')}</span><strong>{num(totalOdds)}</strong></div>
        <div className="sum-row"><span>{t('slip.gross')}</span><strong>{eur(gross)}</strong></div>
        <div className="sum-row"><span>{t('slip.deduction')}</span><strong>-{eur(deduction)}</strong></div>
        <div className="sum-row total"><span>{t('slip.potential')}</span><strong>{eur(net)}</strong></div>

        <button
          className="btn btn-accent btn-block btn-lg"
          style={{ marginTop: 12 }}
          disabled={!slip.length}
          onClick={submit}
        >
          {t('slip.place')}
        </button>

        {slip.length > 0 && (
          <button className="btn btn-ghost btn-block" style={{ marginTop: 8 }} onClick={clearSlip}>
            {t('slip.clear')}
          </button>
        )}
      </div>
    </div>
  );
}
