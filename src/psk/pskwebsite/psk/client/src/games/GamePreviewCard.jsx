import { useEffect, useRef, useState } from 'react';
import { useT } from '../i18n';
import { eur } from '../utils/format';
import previewFor, { artFor } from '../utils/preview';

/**
 * The card shown when a casino tile is clicked: the demo clip plays here,
 * with Play (routes into the real engine) and Details side by side.
 */
export default function GamePreviewCard({ game, onPlay }) {
  const { t } = useT();
  const preview = previewFor(game);
  const videoRef = useRef(null);
  const [showDetails, setShowDetails] = useState(false);

  // autoplay the demo as soon as the card opens
  useEffect(() => {
    const v = videoRef.current;
    if (!v) return;
    v.play().catch(() => {});
  }, []);

  const badges = [
    game.categories?.includes('new') && t('casino.new'),
    game.categories?.includes('exclusive') && t('casino.exclusive'),
    game.categories?.includes('jackpot') && t('casino.jackpot'),
    game.isLive && t('casino.live')
  ].filter(Boolean);

  return (
    <div className="gp-card">
      <div className="gp-stage">
        <img className="gp-art" src={artFor(game)} alt="" />
        <video
          ref={videoRef}
          className="gp-video"
          poster={preview.poster}
          muted
          loop
          playsInline
          autoPlay
          aria-label={`${game.title} demo`}
        >
          <source src={preview.webm} type="video/webm" />
          <source src={preview.mp4} type="video/mp4" />
        </video>
        <span className="gp-live-tag">▶ {t('casino.previewTag')}</span>
      </div>

      <div className="gp-meta">
        <div className="gp-title">{game.title}</div>
        <div className="gp-prov">{game.provider}</div>
        {badges.length > 0 && (
          <div className="gp-badges">
            {badges.map(b => <span className="tag-new" key={b}>{b}</span>)}
          </div>
        )}
      </div>

      <div className="gp-actions">
        <button className="btn btn-accent btn-lg" style={{ flex: 1 }} onClick={() => onPlay(game)}>
          ▶ {t('common.play')}
        </button>
        <button className="btn btn-ghost btn-lg" style={{ flex: 1 }} onClick={() => setShowDetails(v => !v)}>
          {t('common.details')}
        </button>
      </div>

      {showDetails && (
        <div className="gp-details">
          <table className="tbl">
            <tbody>
              <tr><td>{t('common.provider')}</td><td className="num">{game.provider}</td></tr>
              <tr><td>{t('casino.info.type')}</td><td className="num">{game.engine}</td></tr>
              <tr><td>{t('casino.info.rtp')}</td><td className="num">{game.rtp ? `${game.rtp}%` : '—'}</td></tr>
              <tr>
                <td>{t('casino.info.volatility')}</td>
                <td className="num">{game.volatility ? t('data.volatility.' + game.volatility) : '—'}</td>
              </tr>
              <tr><td>{t('casino.info.lines')}</td><td className="num">{game.lines || '—'}</td></tr>
              <tr><td>{t('casino.info.betRange')}</td><td className="num">{eur(game.minBet)} – {eur(game.maxBet)}</td></tr>
              <tr><td>{t('casino.info.jackpot')}</td><td className="num">{game.jackpot ? eur(game.jackpot) : t('casino.info.none')}</td></tr>
            </tbody>
          </table>
          <p className="gp-note">{t('casino.info.note')}</p>
        </div>
      )}
    </div>
  );
}
