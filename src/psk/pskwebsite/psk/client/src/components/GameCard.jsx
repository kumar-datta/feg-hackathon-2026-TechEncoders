import { useRef, useState } from 'react';
import { useT } from '../i18n';
import { eur, thumbGradient } from '../utils/format';
import previewFor, { artFor } from '../utils/preview';

/**
 * Casino tile.
 *
 * Hover plays the generated demo clip only — no buttons appear over the art.
 * Clicking opens the preview modal, which is where Play / Details live.
 */
export default function GameCard({ game, onOpen }) {
  const { t } = useT();
  const preview = previewFor(game);
  const art = artFor(game);

  const videoRef = useRef(null);
  const [playing, setPlaying] = useState(false);

  const badge =
    game.categories?.includes('new')       ? { text: t('casino.new'), cls: '' } :
    game.categories?.includes('exclusive') ? { text: t('casino.exclusive'), cls: '' } :
    game.categories?.includes('jackpot')   ? { text: t('casino.jackpot'), cls: ' jp' } :
    game.isLive                            ? { text: t('casino.live'), cls: ' live' } : null;

  const enter = () => {
    const v = videoRef.current;
    if (!v) return;
    setPlaying(true);
    v.currentTime = 0;
    // play() rejects when the browser blocks autoplay — fall back to the still art
    v.play().catch(() => setPlaying(false));
  };

  const leave = () => {
    const v = videoRef.current;
    setPlaying(false);
    if (v) { v.pause(); v.currentTime = 0; }
  };

  const open = () => onOpen?.(game);

  return (
    <div
      className="game-card"
      role="button"
      tabIndex={0}
      onMouseEnter={enter}
      onMouseLeave={leave}
      onFocus={enter}
      onBlur={leave}
      onClick={open}
      onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); open(); } }}
      aria-label={`${game.title} — ${game.provider}`}
    >
      <div className="game-thumb" style={{ background: thumbGradient(game.hueA, game.hueB) }}>
        <img className="game-art" src={art} alt="" loading="lazy" decoding="async" />

        {badge && <span className={'game-badge' + badge.cls}>{badge.text}</span>}
        {game.jackpot > 0 && <span className="game-jp-amt">{eur(game.jackpot)}</span>}
        {game.isLive && game.players > 0 && <span className="game-jp-amt">👥 {game.players}</span>}

        <video
          ref={videoRef}
          className={'game-video' + (playing ? ' is-playing' : '')}
          poster={preview.poster}
          muted
          loop
          playsInline
          preload="none"
          aria-hidden="true"
        >
          <source src={preview.webm} type="video/webm" />
          <source src={preview.mp4} type="video/mp4" />
        </video>

        <div className="game-name">
          {game.title}
          <div className="game-prov">{game.provider}</div>
        </div>
      </div>
    </div>
  );
}
