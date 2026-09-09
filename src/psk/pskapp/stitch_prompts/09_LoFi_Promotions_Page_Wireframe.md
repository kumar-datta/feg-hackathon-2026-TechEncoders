# LOW-FIDELITY WIREFRAME — PROMOTIONS_PAGE // BONUS_OFFERS

## DEVICE_FRAME: MOBILE // 390 × 844

---

## STYLE_RULES
- **NO COLORS** — black `#000000`, white `#FFFFFF`, grays `#999999` / `#CCCCCC` / `#E5E5E5`
- **FONT**: Monospace only (Courier New / JetBrains Mono)
- **AESTHETIC**: Brutalist, technical wireframe — labels in UPPER_SNAKE_CASE
- **BORDERS**: 1px solid black, 0px border-radius
- **NO SHADOWS, NO GRADIENTS, NO ICONS**

---

## LAYOUT

```
┌──────────────────────────────────┐
│ ≡  PSK_SYSTEM // REF:PROMO       Q │
├──────────────────────────────────┤
│ // MODULE_PATH: CONTENT >        │
│ /  PROMOTIONS                    │
│                                  │
│ ━━━━━━ PROMOTIONS                │
│ PAGE                             │
│ ───BONUSES // OFFERS //          │
│    CAMPAIGNS                     │
│                                  │
│ DESCRIPTION:                     │
│ "Active promotions, welcome      │
│  bonuses, and seasonal           │
│  campaigns."                     │
│                                  │
├──────────────────────────────────┤
│                                  │
│ FILTER_CHIPS:                    │
│ ┌─────┐ ┌──────┐ ┌───────────┐  │
│ │ ALL │ │SPORT │ │ CASINO    │  │
│ │ ___ │ │      │ │           │  │
│ └─────┘ └──────┘ └───────────┘  │
│ ┌───────┐ ┌─────────────────┐   │
│ │ LOTO  │ │ NEW_MEMBERS     │   │
│ └───────┘ └─────────────────┘   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ FEATURED_PROMO:                  │
│ ┌────────────────────────────┐   │
│ │ ┌────────────────────────┐ │   │
│ │ │                        │ │   │
│ │ │    BANNER_AREA         │ │   │
│ │ │    ///////////////     │ │   │
│ │ │    // GRADIENT //      │ │   │
│ │ │    ///////////////     │ │   │
│ │ │                        │ │   │
│ │ └────────────────────────┘ │   │
│ │                            │   │
│ │ TAG: [ NEW ]               │   │
│ │                            │   │
│ │ TITLE:                     │   │
│ │ "Welcome Bonus — 100%      │   │
│ │  Match on First Deposit"   │   │
│ │                            │   │
│ │ EXCERPT:                   │   │
│ │ "Get double your first     │   │
│ │  deposit up to 500 EUR.    │   │
│ │  Valid for new accounts    │   │
│ │  only. T&Cs apply..."     │   │
│ │                            │   │
│ │ VALID_UNTIL: 30_SEP_2026   │   │
│ │                            │   │
│ │ ┌────────────────────────┐ │   │
│ │ │ [ VIEW_DETAILS ]       │ │   │
│ │ └────────────────────────┘ │   │
│ └────────────────────────────┘   │
│                                  │
│ PROMO_GRID: (2_COLUMNS)         │
│                                  │
│ ┌─────────────┐ ┌────────────┐  │
│ │ ┌─────────┐ │ │ ┌────────┐ │  │
│ │ │ BANNER  │ │ │ │ BANNER │ │  │
│ │ │ /////// │ │ │ │ ////// │ │  │
│ │ └─────────┘ │ │ └────────┘ │  │
│ │             │ │            │  │
│ │ TAG: [HOT]  │ │ TAG:[SPORT]│  │
│ │             │ │            │  │
│ │ "Cashback   │ │ "Free Bet  │  │
│ │  Weekend"   │ │  Friday"   │  │
│ │             │ │            │  │
│ │ "Get 10%    │ │ "Place 5   │  │
│ │  cashback   │ │  bets, get │  │
│ │  on all     │ │  1 free    │  │
│ │  casino..." │ │  bet..."   │  │
│ │             │ │            │  │
│ │ [VIEW]      │ │ [VIEW]     │  │
│ └─────────────┘ └────────────┘  │
│                                  │
│ ┌─────────────┐ ┌────────────┐  │
│ │ ┌─────────┐ │ │ ┌────────┐ │  │
│ │ │ BANNER  │ │ │ │ BANNER │ │  │
│ │ │ /////// │ │ │ │ ////// │ │  │
│ │ └─────────┘ │ │ └────────┘ │  │
│ │             │ │            │  │
│ │ TAG:[CASINO]│ │ TAG:[LOTO] │  │
│ │             │ │            │  │
│ │ "Jackpot    │ │ "Lucky 7   │  │
│ │  Race"      │ │  Draw"     │  │
│ │             │ │            │  │
│ │ "Win a      │ │ "Every 7th │  │
│ │  share of   │ │  ticket    │  │
│ │  50K..."    │ │  wins..."  │  │
│ │             │ │            │  │
│ │ [VIEW]      │ │ [VIEW]     │  │
│ └─────────────┘ └────────────┘  │
│                                  │
├──────────────────────────────────┤
│                                  │
│ PROMO_DETAIL_VIEW:               │
│ (MODAL // BOTTOM_SHEET)          │
│                                  │
│ ┌────────────────────────────┐   │
│ │ TITLE: "Welcome Bonus"    │   │
│ │                            │   │
│ │ FULL_DESCRIPTION:          │   │
│ │ "Register a new account    │   │
│ │  and make your first       │   │
│ │  deposit. We will match    │   │
│ │  100% up to 500 EUR.       │   │
│ │  Wagering requirements:    │   │
│ │  5x on sports, 25x on     │   │
│ │  casino."                  │   │
│ │                            │   │
│ │ TERMS_TABLE:               │   │
│ │ ┌────────────┬───────────┐ │   │
│ │ │ MIN_DEPOSIT│ 10_EUR    │ │   │
│ │ ├────────────┼───────────┤ │   │
│ │ │ MAX_BONUS  │ 500_EUR   │ │   │
│ │ ├────────────┼───────────┤ │   │
│ │ │ WAGERING   │ 5X/25X    │ │   │
│ │ ├────────────┼───────────┤ │   │
│ │ │ VALID      │ 30_DAYS   │ │   │
│ │ ├────────────┼───────────┤ │   │
│ │ │ PRODUCTS   │ ALL       │ │   │
│ │ └────────────┴───────────┘ │   │
│ │                            │   │
│ │ ┌────────────────────────┐ │   │
│ │ │ [ CLAIM_BONUS ]        │ │   │
│ │ └────────────────────────┘ │   │
│ │ ┌────────────────────────┐ │   │
│ │ │ [ FULL_TERMS ]         │ │   │
│ │ └────────────────────────┘ │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│ LIVE    SPORTS  BETSLIP  CASINO  │
│  ●                         MENU  │
└──────────────────────────────────┘
```

## ANNOTATIONS

- **FILTER_CHIPS**: Category filter — ALL (default, underlined), SPORT, CASINO, LOTO, NEW_MEMBERS
- **FEATURED_PROMO**: Full-width card at top for the highlighted/newest promotion
  - BANNER_AREA: Hatched rectangle (////) representing a gradient banner image
  - TAG: Category badge — `[ NEW ]`, `[ HOT ]`, `[ SPORT ]`, `[ CASINO ]`, `[ LOTO ]`
  - TITLE + EXCERPT + VALID_UNTIL date + VIEW_DETAILS button
- **PROMO_GRID**: 2-column grid for remaining promotions, each with smaller banner, tag, title, excerpt, and [VIEW] button
- **PROMO_DETAIL_VIEW**: Bottom sheet or modal that opens on tap, showing full description, terms table, and CLAIM_BONUS / FULL_TERMS buttons

## STATES_TO_SHOW
Render two side-by-side frames:
1. PROMO_LIST — showing the featured promo card + 4 grid cards with filter chips
2. PROMO_DETAIL — showing the detail bottom sheet open for "Welcome Bonus" with the terms table
