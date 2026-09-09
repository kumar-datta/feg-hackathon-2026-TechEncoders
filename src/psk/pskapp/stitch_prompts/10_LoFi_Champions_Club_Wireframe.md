# LOW-FIDELITY WIREFRAME — CHAMPIONS_CLUB // LOYALTY_TIERS

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
│ ≡  PSK_SYSTEM // REF:LOYALTY      Q │
├──────────────────────────────────┤
│ // MODULE_PATH: ACCOUNT >        │
│ /  CHAMPIONS_CLUB                │
│                                  │
│ ━━━━━━ CHAMPIONS                 │
│ CLUB                             │
│ ───LOYALTY_PROGRAM //            │
│    TIER_SYSTEM // REWARDS        │
│                                  │
├──────────────────────────────────┤
│                                  │
│ USER_PROGRESS_CARD:              │
│ ┌────────────────────────────┐   │
│ │                            │   │
│ │ CURRENT_TIER: SILVER       │   │
│ │ MEMBER_SINCE: JAN_2026     │   │
│ │                            │   │
│ │ POINTS_BALANCE: 2,450      │   │
│ │                            │   │
│ │ PROGRESS_BAR:              │   │
│ │ [████████████░░░░░░░░] 61% │   │
│ │                            │   │
│ │ NEXT_TIER: GOLD            │   │
│ │ POINTS_NEEDED: 1,550       │   │
│ │                            │   │
│ │ MONTHLY_ACTIVITY:          │   │
│ │ BETS_PLACED: 47            │   │
│ │ CASINO_ROUNDS: 312         │   │
│ │ TOTAL_WAGERED: 1,280_EUR   │   │
│ │                            │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ TIER_LADDER:                     │
│                                  │
│ ┌────────────────────────────┐   │
│ │                            │   │
│ │ TIER_5: PLATINUM           │   │
│ │ ┌──────────────────────┐   │   │
│ │ │ POINTS: 20,000+      │   │   │
│ │ │ PERKS:               │   │   │
│ │ │  - VIP_MANAGER       │   │   │
│ │ │  - 15%_CASHBACK      │   │   │
│ │ │  - EXCLUSIVE_EVENTS  │   │   │
│ │ │  - PRIORITY_WITHDRAW │   │   │
│ │ │  - BIRTHDAY_BONUS    │   │   │
│ │ └──────────────────────┘   │   │
│ │          |                 │   │
│ │ TIER_4: GOLD               │   │
│ │ ┌──────────────────────┐   │   │
│ │ │ POINTS: 4,000+       │   │   │
│ │ │ PERKS:               │   │   │
│ │ │  - 10%_CASHBACK      │   │   │
│ │ │  - WEEKLY_FREE_BETS  │   │   │
│ │ │  - HIGHER_BET_LIMITS │   │   │
│ │ │  - MONTHLY_BONUS     │   │   │
│ │ └──────────────────────┘   │   │
│ │          |                 │   │
│ │ TIER_3: SILVER  [ YOU ]    │   │
│ │ ┌──────────────────────┐   │   │
│ │ │ POINTS: 1,500+       │   │   │
│ │ │ PERKS:               │   │   │
│ │ │  - 5%_CASHBACK       │   │   │
│ │ │  - BONUS_SPINS       │   │   │
│ │ │  - PROMO_ACCESS      │   │   │
│ │ └──────────────────────┘   │   │
│ │          |                 │   │
│ │ TIER_2: BRONZE             │   │
│ │ ┌──────────────────────┐   │   │
│ │ │ POINTS: 500+         │   │   │
│ │ │ PERKS:               │   │   │
│ │ │  - 2%_CASHBACK       │   │   │
│ │ │  - DAILY_REWARDS     │   │   │
│ │ └──────────────────────┘   │   │
│ │          |                 │   │
│ │ TIER_1: STARTER            │   │
│ │ ┌──────────────────────┐   │   │
│ │ │ POINTS: 0+           │   │   │
│ │ │ PERKS:               │   │   │
│ │ │  - BASIC_ACCESS      │   │   │
│ │ │  - STREAK_REWARDS    │   │   │
│ │ └──────────────────────┘   │   │
│ │                            │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ REWARDS_SHOP:                    │
│                                  │
│ SECTION_HEADER: "Redeem Points"  │
│                                  │
│ ┌─────────────┐ ┌────────────┐  │
│ │             │ │            │  │
│ │ REWARD_001  │ │ REWARD_002 │  │
│ │             │ │            │  │
│ │ "Free Bet   │ │ "Bonus     │  │
│ │  5_EUR"     │ │  Spins x10"│  │
│ │             │ │            │  │
│ │ COST:       │ │ COST:      │  │
│ │ 200_PTS     │ │ 150_PTS    │  │
│ │             │ │            │  │
│ │ [ REDEEM ]  │ │ [ REDEEM ] │  │
│ └─────────────┘ └────────────┘  │
│                                  │
│ ┌─────────────┐ ┌────────────┐  │
│ │             │ │            │  │
│ │ REWARD_003  │ │ REWARD_004 │  │
│ │             │ │            │  │
│ │ "Cashback   │ │ "Merch     │  │
│ │  Boost"     │ │  Voucher"  │  │
│ │             │ │            │  │
│ │ COST:       │ │ COST:      │  │
│ │ 500_PTS     │ │ 1000_PTS   │  │
│ │             │ │            │  │
│ │ [ REDEEM ]  │ │ [ REDEEM ] │  │
│ └─────────────┘ └────────────┘  │
│                                  │
├──────────────────────────────────┤
│                                  │
│ POINTS_HISTORY:                  │
│                                  │
│ ┌────────────────────────────┐   │
│ │ DATE       ACTION    PTS   │   │
│ │ ─────────────────────────  │   │
│ │ 09_SEP  BET_PLACED   +12  │   │
│ │ 09_SEP  CASINO_PLAY  +45  │   │
│ │ 08_SEP  DAILY_LOGIN   +5  │   │
│ │ 08_SEP  REDEEMED    -200  │   │
│ │ 07_SEP  BET_WON      +30  │   │
│ │ 07_SEP  STREAK_D5    +25  │   │
│ │                            │   │
│ │ [ LOAD_MORE ]              │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ EARNING_RULES:                   │
│ ┌────────────────────────────┐   │
│ │                            │   │
│ │ HOW_POINTS_ARE_EARNED:     │   │
│ │                            │   │
│ │ - SPORTS_BET: 1_PT / 1_EUR│   │
│ │ - CASINO_PLAY: 2_PT/1_EUR │   │
│ │ - DAILY_LOGIN: 5_PTS      │   │
│ │ - STREAK_BONUS: UP_TO_25  │   │
│ │ - WINNING_BET: 2X_POINTS  │   │
│ │                            │   │
│ │ TIER_EVALUATION: MONTHLY   │   │
│ │ POINTS_EXPIRY: 6_MONTHS    │   │
│ │                            │   │
│ └────────────────────────────┘   │
│                                  │
├──────────────────────────────────┤
│ LIVE    SPORTS  BETSLIP  CASINO  │
│  ●                         MENU  │
└──────────────────────────────────┘
```

## ANNOTATIONS

- **USER_PROGRESS_CARD**: Shows current tier, points balance, progress bar (ASCII style using █ and ░), points needed for next tier, and monthly activity stats
- **PROGRESS_BAR**: ASCII representation — filled blocks `████` for completed portion, empty `░░░░` for remaining
- **TIER_LADDER**: Vertical ladder showing all 5 tiers from top (Platinum) to bottom (Starter)
  - Each tier box: tier name, points threshold, list of perks
  - Current tier marked with `[ YOU ]` annotation
  - Tiers connected with pipe `|` characters
- **REWARDS_SHOP**: 2-column grid of redeemable rewards
  - Each reward: name, description, point cost, `[ REDEEM ]` button
  - Disabled if insufficient points (show cost in gray)
- **POINTS_HISTORY**: Simple table showing date, action, and points earned/spent
  - Positive points prefixed with `+`
  - Negative (redemptions) prefixed with `-`
  - `[ LOAD_MORE ]` for pagination
- **EARNING_RULES**: How points accumulate — per-product rates, daily login bonus, streak multiplier

## STATES_TO_SHOW
Render one full-length wireframe showing the complete Champions Club page with all sections visible (scroll view). The user is at SILVER tier with 2,450 points, 61% progress toward GOLD.
