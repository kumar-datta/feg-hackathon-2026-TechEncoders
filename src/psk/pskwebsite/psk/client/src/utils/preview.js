/**
 * Cover art + hover-preview clips for casino tiles.
 *
 * Assets are generated locally:
 *   tools/make_game_art.py     -> client/public/art/<theme>.jpg
 *   tools/make_demo_videos.py  -> client/public/demos/<engine>.mp4 | .webm
 *   tools/make_slot_demos.py   -> client/public/demos/slot-<theme>.mp4 | .webm
 *
 * Art and clip resolve through the SAME theme, so a game's hover preview
 * always matches the artwork on its tile. Nothing here is derived from
 * third-party game artwork.
 */

/** Strip Croatian diacritics so titles match the ASCII asset names. */
function normalise(s) {
  return String(s || '')
    .toLowerCase()
    .replace(/[čć]/g, 'c')
    .replace(/đ/g, 'd')
    .replace(/š/g, 's')
    .replace(/ž/g, 'z');
}

/** Theme nouns used by the title generator — each has its own cover + slot clip. */
const THEME_NOUNS = [
  'feniks', 'zmaj', 'hram', 'rudnik', 'karavan', 'sedam', 'kotac', 'piramida',
  'vitez', 'grom', 'delfin', 'vulkan', 'safir', 'kompas', 'galeb', 'jelen',
  'maslina', 'sidro', 'lampion', 'kovceg', 'bubanj', 'kraljica', 'amfora',
  'otok', 'zvono', 'kljuc', 'krila', 'tigar', 'orao', 'val'
];

/** Table/instant games are identified by engine and have bespoke assets. */
const ENGINE_THEMES = {
  roulette: 'roulette',
  blackjack: 'blackjack',
  crash: 'crash',
  mines: 'mines',
  dice: 'dice',
  wheel: 'wheel',
  baccarat: 'baccarat'
};

/**
 * Resolve a game to its theme.
 * Returns { theme, isEngineGame } — engine games use their own clip,
 * slots use the themed slot clip.
 */
function themeFor(game) {
  const engineTheme = ENGINE_THEMES[game?.engine];
  if (engineTheme) return { theme: engineTheme, isEngineGame: true };

  const title = normalise(game?.title);
  const noun = THEME_NOUNS.find(n => title.includes(n));
  return { theme: noun || 'default', isEngineGame: false };
}

/** Cover image for a game. Always resolves to something. */
export function artFor(game) {
  return `/art/${themeFor(game).theme}.jpg`;
}

/** Hover/preview clip for a game — themed per game, not per engine. */
export function previewFor(game) {
  const { theme, isEngineGame } = themeFor(game);

  // engine games (roulette, blackjack, …) have their own bespoke clip;
  // slots get the clip built for their theme, falling back to the generic one
  const slug = isEngineGame ? theme : (theme === 'default' ? 'slot' : `slot-${theme}`);

  return {
    slug,
    theme,
    webm: `/demos/${slug}.webm`,
    mp4: `/demos/${slug}.mp4`,
    poster: `/demos/${slug}.jpg`
  };
}

export default previewFor;
