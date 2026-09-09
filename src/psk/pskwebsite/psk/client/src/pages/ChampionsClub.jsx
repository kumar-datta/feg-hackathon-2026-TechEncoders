import { Link } from 'react-router-dom';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';

const TIER_META = [
  { points: 0,     colour: '#8a5a2b' },
  { points: 1000,  colour: '#9aa7b8' },
  { points: 5000,  colour: '#d4a017' },
  { points: 15000, colour: '#c0d6e4' }
];

export default function ChampionsClub() {
  const { user } = useApp();
  const { t } = useT();

  const names = t('club.tiers');
  const tiers = TIER_META.map((m, i) => ({ ...m, ...names[i] }));

  // demo points derived from the account balance so the page has something to show
  const points = user ? Math.floor(user.balance * 3) : 0;
  const tier = [...tiers].reverse().find(x => points >= x.points) || tiers[0];
  const next = tiers.find(x => x.points > points);

  return (
    <div className="page narrow" style={{ maxWidth: 900 }}>
      <div className="crumbs"><Link to="/">{t('common.home')}</Link> › {t('club.title')}</div>
      <h1 className="page-title">🏅 {t('club.title')}</h1>
      <p className="page-lede">{t('club.lede')}</p>

      {user ? (
        <div className="panel" style={{ marginTop: 22 }}>
          <div className="panel-hd">
            <span>{t('club.yourTier')}</span>
            <span style={{ color: tier.colour, fontWeight: 800 }}>{tier.name}</span>
          </div>
          <div className="panel-bd">
            <div className="sum-row"><span>{t('club.points')}</span><strong>{points}</strong></div>
            {next ? (
              <>
                <div className="sum-row">
                  <span>{t('club.toNext', { tier: next.name })}</span>
                  <strong>{t('club.pointsShort', { n: next.points - points })}</strong>
                </div>
                <div style={{ background: 'var(--bg-elev-2)', borderRadius: 4, height: 10, overflow: 'hidden', marginTop: 12 }}>
                  <div style={{
                    width: `${Math.min(100, (points / next.points) * 100)}%`,
                    height: '100%',
                    background: 'linear-gradient(90deg,var(--brand-300),var(--accent))'
                  }} />
                </div>
              </>
            ) : (
              <div className="sum-row total"><span>{t('common.status')}</span><strong>{t('club.maxTier')}</strong></div>
            )}
          </div>
        </div>
      ) : (
        <div className="note" style={{ marginTop: 22 }}>
          {t('club.loginPrompt')}{' '}
          <Link to="/prijava" style={{ color: 'var(--accent)' }}>{t('header.login')}</Link>
        </div>
      )}

      <section className="sec">
        <div className="sec-hd"><h2>{t('club.tiersTitle')}</h2></div>
        <div className="tile-grid">
          {tiers.map(x => (
            <div className="panel" key={x.name} style={{ borderColor: tier.name === x.name ? x.colour : undefined }}>
              <div className="panel-hd">
                <span style={{ color: x.colour }}>{x.name}</span>
                <span style={{ fontSize: 11, color: 'var(--txt-mute)' }}>{t('club.fromPoints', { n: x.points })}</span>
              </div>
              <div className="panel-bd">
                <ul style={{ margin: 0, paddingLeft: 18, fontSize: 13, color: 'var(--txt-dim)' }}>
                  {x.perks.map(p => <li key={p} style={{ marginBottom: 6 }}>{p}</li>)}
                </ul>
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="sec prose">
        <h2>{t('club.howTitle')}</h2>
        <p>{t('club.howBody')}</p>
        <h3>{t('club.watchTitle')}</h3>
        <p>
          {t('club.watchBody')}{' '}
          <Link to="/odgovorno-igranje">{t('footer.responsible')}</Link>.
        </p>
      </section>
    </div>
  );
}
