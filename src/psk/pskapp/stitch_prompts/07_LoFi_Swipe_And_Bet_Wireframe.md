# LOW-FIDELITY WIREFRAME — SWIPE_AND_BET // QUICK_PICK_ENGINE

## DEVICE_FRAME: MOBILE // 390 × 844

---

## STYLE_RULES
- **NO COLORS** — black `#000000`, white `#FFFFFF`, grays `#999999` / `#CCCCCC` / `#E5E5E5`
- **FONT**: Monospace only (Courier New / JetBrains Mono)
- **AESTHETIC**: Brutalist, technical wireframe — labels in UPPER_SNAKE_CASE
- **BORDERS**: 1px solid black, 0px border-radius (all sharp rectangles)
- **NO SHADOWS, NO GRADIENTS, NO ICONS** — text-only, brackets for buttons
- **CARDS**: Simple bordered rectangles with dashed borders for swipe-away state

---

## LAYOUT

```
┌──────────────────────────────────┐
│ ≡  PSK_SYSTEM // REF:SWIPE       Q │
├──────────────────────────────────┤
│ // MODULE_PATH: PRODUCTS >       │
│ /  SWIPE_AND_BET                 │
│                                  │
│ ━━━━━━ SWIPE_AND                 │
│ BET                              │
│ ───QUICK_PICK // TINDER_STYLE    │
│    BETTING_INTERFACE             │
│                                  │
│ DESCRIPTION:                     │
│ "Swipe right to add to betslip,  │
│  left to skip. Build your ticket │
│  in seconds."                    │
│                                  │
├──────────────────────────────────┤
│                                  │
│  CARD_STACK:                     │
│                                  │
│  ┌────────────────────────────┐  │
│  │                            │  │
│  │  LEAGUE_META:              │  │
│  │  HR // HNL_PRVA_LIGA       │  │
│  │                            │  │
│  │                            │  │
│  │  EVENT_NAME:               │  │
│  │  ┌────────────────────┐    │  │
│  │  │ DINAMO_ZAGREB      │    │  │
│  │  │       —            │    │  │
│  │  │ HAJDUK_SPLIT       │    │  │
│  │  └────────────────────┘    │  │
│  │                            │  │
│  │  STATUS:                   │  │
│  │  KICKOFF: 20:45 // 09_SEP  │  │
│  │                            │  │
│  │  ┌────────────────────┐    │  │
│  │  │  MARKET_KEY: 1     │    │  │
│  │  │                    │    │  │
│  │  │  ODDS_VALUE:       │    │  │
│  │  │      2.15          │    │  │
│  │  │                    │    │  │
│  │  └────────────────────┘    │  │
│  │                            │  │
│  │  CODE: #4821 // CARD 12/60 │  │
│  │                            │  │
│  └────────────────────────────┘  │
│                                  │
│  // GHOST_CARD behind (offset):  │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│  :  NEXT_EVENT_CARD           :  │
│  :  (STACKED_BEHIND)          :  │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                                  │
├──────────────────────────────────┤
│                                  │
│  ACTION_BUTTONS:                 │
│                                  │
│  ┌────┐    ┌────┐    ┌────┐     │
│  │ X  │    │ >> │    │ ✓  │     │
│  │SKIP│    │NEXT│    │ ADD│     │
│  └────┘    └────┘    └────┘     │
│                                  │
│  KEYBOARD_HINTS:                 │
│  ARROW_LEFT = SKIP               │
│  ARROW_UP   = NEXT               │
│  ARROW_RIGHT = ADD_TO_SLIP       │
│                                  │
├──────────────────────────────────┤
│                                  │
│  BETSLIP_COUNTER:                │
│  ON_SLIP: 3_SELECTIONS           │
│                                  │
│  ┌────────────────────────────┐  │
│  │ [ OPEN_IN_SPORTSBOOK ]    │  │
│  └────────────────────────────┘  │
│                                  │
├──────────────────────────────────┤
│                                  │
│  HOW_IT_WORKS:                   │
│                                  │
│  1. EVENTS_LOADED: Random pool   │
│     of 60 events shuffled        │
│  2. EACH_CARD: Shows one event   │
│     with a suggested market/odd  │
│  3. SWIPE_RIGHT: Adds the        │
│     selection to your betslip    │
│  4. SWIPE_LEFT: Skips to next    │
│  5. WHEN_DONE: Review betslip    │
│     and place your ticket        │
│                                  │
├──────────────────────────────────┤
│ LIVE    SPORTS  BETSLIP  CASINO  │
│  ●                         MENU  │
└──────────────────────────────────┘
```

## ANNOTATIONS

- **CARD_STACK**: Stacked card pattern — front card fully visible, behind card shows as dashed outline offset 4px right and 4px down
- **SWIPE_ANIMATION**: When swiped right, card exits frame-right with rotation. When swiped left, exits frame-left. Text annotation: `// GONE_RIGHT` or `// GONE_LEFT`
- **CARD_CONTENT**:
  - LEAGUE_META: Country flag text (HR, EN, etc.) + league name
  - EVENT_NAME: Two team names stacked with dash separator
  - MARKET_KEY: The suggested bet type (1, X, 2, H1, H2, etc.)
  - ODDS_VALUE: Large centered number in a bordered box
  - CODE: Event reference code + position counter
- **ACTION_BUTTONS**: Three equally-spaced square buttons:
  - [ X ] SKIP — reject, card flies left
  - [ >> ] NEXT — neutral skip, card flies up
  - [ ✓ ] ADD — add to betslip, card flies right
- **LIVE_EVENTS**: If the event is live, show `STATUS: LIVE // 67' // SCORE: 2:1` instead of kickoff time
- **DONE_STATE**: When all 60 cards are exhausted, show:
  ```
  ┌────────────────────────────┐
  │  ALL_EVENTS_REVIEWED       │
  │                            │
  │  TOTAL: 60                 │
  │  ADDED_TO_SLIP: 8          │
  │  SKIPPED: 52               │
  │                            │
  │  [ OPEN_SPORTSBOOK ]       │
  └────────────────────────────┘
  ```

## STATES_TO_SHOW
Render two side-by-side frames:
1. ACTIVE_STATE — card visible with event details, action buttons below
2. SWIPING_STATE — card tilted 15° with dashed outline at original position, next card becoming visible behind
