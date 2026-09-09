# LOW-FIDELITY WIREFRAME — ARENA_SOCIAL_FEED // TICKET_SHARING

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
│ ≡  PSK_SYSTEM // REF:ARENA       Q │
├──────────────────────────────────┤
│ // MODULE_PATH: SOCIAL > ARENA   │
│ /                                │
│ ━━━━━━ ARENA                     │
│ FEED                             │
│ ───SHARED_TICKETS //             │
│    SOCIAL_BETTING_FEED           │
│                                  │
│ DESCRIPTION:                     │
│ "See what other users are        │
│  betting on. Copy tickets to     │
│  your own betslip."              │
│                                  │
├──────────────────────────────────┤
│                                  │
│ FILTER_TABS:                     │
│ ┌──────┐ ┌──────┐ ┌──────────┐  │
│ │LATEST│ │ HOT  │ │ WINNING  │  │
│ │ ___  │ │      │ │          │  │
│ └──────┘ └──────┘ └──────────┘  │
│                                  │
├──────────────────────────────────┤
│                                  │
│ TICKET_CARD_001:                 │
│ ┌────────────────────────────┐   │
│ │ USER: MARKO_K              │   │
│ │ TIME: 2_MIN_AGO            │   │
│ │ STATUS: [ ACTIVE ]         │   │
│ │                            │   │
│ │ SELECTIONS:                │   │
│ │ ┌────────────────────────┐ │   │
│ │ │ 1. DINAMO — HAJDUK     │ │   │
│ │ │    MARKET: 1           │ │   │
│ │ │    ODDS: 2.15          │ │   │
│ │ │    RESULT: [ PENDING ] │ │   │
│ │ ├────────────────────────┤ │   │
│ │ │ 2. REAL_M — BARCELONA  │ │   │
│ │ │    MARKET: X           │ │   │
│ │ │    ODDS: 3.40          │ │   │
│ │ │    RESULT: [ WON ]     │ │   │
│ │ ├────────────────────────┤ │   │
│ │ │ 3. LAKERS — CELTICS    │ │   │
│ │ │    MARKET: 2           │ │   │
│ │ │    ODDS: 1.85          │ │   │
│ │ │    RESULT: [ PENDING ] │ │   │
│ │ └────────────────────────┘ │   │
│ │                            │   │
│ │ SUMMARY:                   │   │
│ │ STAKE: 10.00_EUR           │   │
│ │ TOTAL_ODDS: 13.53          │   │
│ │ POTENTIAL: 122.21_EUR      │   │
│ │                            │   │
│ │ ACTIONS:                   │   │
│ │ ┌──────────┐ ┌───────────┐│   │
│ │ │[ COPY_TO │ │ [ SHARE ] ││   │
│ │ │  SLIP  ] │ │           ││   │
│ │ └──────────┘ └───────────┘│   │
│ │                            │   │
│ │ SOCIAL: 14_COPIES //       │   │
│ │         3_REACTIONS        │   │
│ └────────────────────────────┘   │
│                                  │
│ TICKET_CARD_002:                 │
│ ┌────────────────────────────┐   │
│ │ USER: ANA_P                │   │
│ │ TIME: 15_MIN_AGO           │   │
│ │ STATUS: [ WON ]            │   │
│ │                            │   │
│ │ SELECTIONS:                │   │
│ │ ┌────────────────────────┐ │   │
│ │ │ 1. BAYERN — DORTMUND   │ │   │
│ │ │    MARKET: 1            │ │   │
│ │ │    ODDS: 1.75           │ │   │
│ │ │    RESULT: [ WON ]      │ │   │
│ │ ├────────────────────────┤ │   │
│ │ │ 2. CHELSEA — ARSENAL   │ │   │
│ │ │    MARKET: 2            │ │   │
│ │ │    ODDS: 2.20           │ │   │
│ │ │    RESULT: [ WON ]      │ │   │
│ │ └────────────────────────┘ │   │
│ │                            │   │
│ │ SUMMARY:                   │   │
│ │ STAKE: 20.00_EUR           │   │
│ │ TOTAL_ODDS: 3.85           │   │
│ │ WON: 69.30_EUR             │   │
│ │                            │   │
│ │ ACTIONS:                   │   │
│ │ ┌──────────┐ ┌───────────┐│   │
│ │ │[ COPY_TO │ │ [ SHARE ] ││   │
│ │ │  SLIP  ] │ │           ││   │
│ │ └──────────┘ └───────────┘│   │
│ │                            │   │
│ │ SOCIAL: 42_COPIES //       │   │
│ │         8_REACTIONS        │   │
│ └────────────────────────────┘   │
│                                  │
│ [ LOAD_MORE_TICKETS ]            │
│                                  │
├──────────────────────────────────┤
│                                  │
│ SHARE_YOUR_TICKET:               │
│ ┌────────────────────────────┐   │
│ │ "Share your latest ticket  │   │
│ │  to the Arena feed."       │   │
│ │                            │   │
│ │ [ SHARE_MY_TICKET ]        │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│ LIVE    SPORTS  BETSLIP  CASINO  │
│  ●                         MENU  │
└──────────────────────────────────┘
```

## ANNOTATIONS

- **FILTER_TABS**: Three tabs at top — LATEST (default, underlined), HOT (most copied), WINNING (settled as won)
- **TICKET_CARD**: Each shared ticket is a full card showing:
  - USERNAME + timestamp
  - STATUS tag: `[ ACTIVE ]`, `[ WON ]`, `[ LOST ]`, `[ SETTLED ]`
  - List of selections with event name, market, odds, individual result status
  - Summary with stake, total odds, potential/actual return
  - Two action buttons: COPY_TO_SLIP (copies all selections to user's own betslip) and SHARE (generates a shareable link)
  - Social metrics: copy count + reaction count
- **COPY_TO_SLIP_FLOW**:
  1. User taps `[ COPY_TO_SLIP ]`
  2. All selections from the shared ticket are added to user's betslip
  3. Toast notification: "3 selections copied to your betslip"
  4. User can then modify stake and place their own ticket
- **SHARE_FLOW**: User taps `[ SHARE_MY_TICKET ]` → selects from their tickets → posts to Arena feed
- **RESULT_STATES**:
  - `[ PENDING ]` — event not yet played
  - `[ WON ]` — selection won
  - `[ LOST ]` — selection lost
  - `[ VOID ]` — event cancelled

## STATES_TO_SHOW
Render one full-height wireframe showing the feed with 2 ticket cards visible (one ACTIVE, one WON), the filter tabs, and the "Share your ticket" CTA at the bottom.
