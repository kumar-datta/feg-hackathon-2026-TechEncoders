import { useCallback } from 'react';
import { useApp } from '../context/AppContext';
import { useT } from '../i18n';
import GameEngine from './engines';
import GamePreviewCard from './GamePreviewCard';

/**
 * Casino tiles call `open(game)`, which shows the preview card (demo clip +
 * Play / Details). Play then swaps the modal over to the real engine.
 */
export default function useGameLauncher() {
  const { setModal } = useApp();
  const { t } = useT();

  /** Launch the playable engine. */
  const play = useCallback((game) => {
    setModal({
      title: `${game.symbol} ${game.title}`,
      wide: true,
      content: <GameEngine game={game} />
    });
  }, [setModal]);

  /** Preview card shown when a tile is clicked. */
  const open = useCallback((game) => {
    setModal({
      title: `${game.symbol} ${game.title}`,
      content: <GamePreviewCard game={game} onPlay={play} />
    });
  }, [setModal, play]);

  return { open, play, info: open };
}
