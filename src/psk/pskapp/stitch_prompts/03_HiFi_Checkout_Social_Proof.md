# HIGH-FIDELITY DESIGN — Checkout Flow with Social Proof & Leave-Intent Guard

## Screen: Mobile App — 390 × 844 px (iPhone 14)

---

## Context
The PSK website has a rich checkout page with: a detailed selections table, "social proof" counters ("1,847 users placed similar bets" + "28 watching now"), quick-stake buttons, a projected-return summary, and a **leave-intent modal** that shows "You would have won X €" when the user tries to navigate away. The mobile app currently has a basic betslip sheet but lacks the full checkout experience. This design adds a dedicated checkout screen with all the persuasion patterns.

---

## Color Palette (exact PSK tokens)
| Token | Hex | Usage |
|---|---|---|
| Brand Blue | `#1752BF` | Header, market key chips, odds text |
| Accent Gold | `#FFDB01` | Confirm button, total return highlight |
| BG Dark | `#0E0E11` | Screen background |
| BG Dark Secondary | `#18181E` | Panel backgrounds |
| Surface Dark | `#22222B` | Card/panel background |
| Surface Dark Panel | `#292933` | Summary panel, detail rows |
| Surface Dark Action | `#363644` | Quick stake buttons inactive, back button |
| Text White | `#FFFFFF` | Primary text |
| Text Gray | `#DFDFE6` | Secondary text |
| Text Muted | `#B0B0C0` | Labels, meta info |
| Money Green | `#35E94D` | Potential return amount, social proof dot |
| Alert Red | `#C52D16` | Remove selection button |
| Live Green | `#0E7C1C` | "Watching now" text |
| Border Dark | `#2A2A35` | Dividers |

---

## Screen 1: Checkout Page (Full Betslip Review)

### Header
- Standard PSK app header: `#1752BF` background, PSK logo white left, back arrow ← left of logo
- Title below header: "🧾 CHECKOUT" — `#FFFFFF`, 18px, weight 700
- Subtitle: "Review your selections and confirm your bet" — `#B0B0C0`, 12px

### Selections Card (scrollable panel)
- Background: `#22222B`, border-radius 12px, margin 10px horizontal
- **Card header**: "Selections" left, count badge "3" right — `#B0B0C0`, weight 600
- **Each selection row** (separated by 1px `#2A2A35` divider):
  - **Event name**: "Dinamo Zagreb – Hajduk Split" — `#FFFFFF`, 13px, weight 600
  - **Meta**: "🇭🇷 HNL · Code 4821" — `#B0B0C0`, 11px
  - **Market chip**: "1" inside a `#1752BF` rounded chip, 24px height, white text
  - **Odds**: "2.15" — `#FFDB01`, 15px, weight 800, right side
  - **Remove button**: "✕" in 20×20 circle, `#C52D16` background, top-right corner of row, 10px font

### Social Proof Strip
- Below the selections card, full width, padding 10px 16px
- Left: Pulsing green dot (6px, `#35E94D`, with 2s pulse animation) + "1,847 users placed similar bets" — `#DFDFE6`, 12px
- Right: "· 28 watching now" — `#0E7C1C`, 12px, weight 600
- The "watching now" number should have a subtle fade transition feel (as if it updates live)

### Summary Panel (sticky at bottom or scrolls below)
- Background: `#22222B`, border-radius 12px, padding 16px, margin 10px horizontal

#### Quick Stake Buttons
- Horizontal row of 5 buttons: **2€** · **5€** · **10€** · **20€** · **50€**
- Each: 48px wide, 36px tall, `#363644` background, `#DFDFE6` text, 13px weight 600, border-radius 8px
- Selected/active: `#1752BF` background, white text

#### Stake Input
- Label: "Stake" — `#B0B0C0`, 12px
- Input: Full width, `#292933` background, `#FFFFFF` text, 16px, border-radius 8px, height 44px
- Value shown: "10.00" with "€" suffix inside the field
- Numeric keyboard hint

#### Summary Rows (12px vertical gap between each)
| Label (left, `#B0B0C0`, 13px) | Value (right, `#DFDFE6`, 13px, weight 600) |
|---|---|
| Pairs | 3 |
| Total odds | 12.48 |
| Gross return | 124.80 € |
| Deduction (10%) | -11.48 € |
| **Potential return** | **113.32 €** |

- The "Potential return" row: `#35E94D` text for the amount, `#FFFFFF` for the label, weight 700, 15px font
- Dashed divider `#2A2A35` above the potential return row
- Below: "Balance after: 90.00 €" — `#B0B0C0`, 12px, dashed top border

#### Confirm Button
- Full width, height 52px, `#FFDB01` background, black text "CONFIRM BET", 15px weight 700, border-radius 10px
- Below it: "← Back to offer" — `#363644` background, `#DFDFE6` text, full width, 44px height, border-radius 10px

#### Demo Note
- "This is a demo. No real money is involved." — `#B0B0C0`, 10px, centered, italic, margin-top 8px

---

## Screen 2: Leave-Intent Modal (overlay)

When the user taps back or swipes to go back:

### Overlay
- `rgba(14, 14, 17, 0.7)` dimming the checkout screen behind

### Modal Card
- Centered vertically, max-width 340px, margin 25px horizontal
- Background: `#22222B`, border-radius 16px

#### Modal Header
- "Wait! Are you sure?" — `#FFFFFF`, 17px, weight 700
- Close `×` button top-right, 28×28 circle, `#363644`, white icon

#### Modal Body (padding 20px)
- "You're about to leave your bet behind." — `#B0B0C0`, 13px

#### Projected Return Card (inside modal)
- Background: Gradient `#0C2B64` → `#1752BF` → `#1A1A24`, border-radius 12px, padding 16px
- Label: "You could win" — `#75A6FF`, 11px, uppercase, letter-spacing 0.6px
- **Amount**: "113.32 €" — `#FFDB01`, 28px, weight 800
- Meta: "3 × pairs · Odds 12.48 · Stake 10.00 €" — `#B0B0C0`, 11px

#### Social Strip (inside modal)
- Pulsing green dot + "1,847 users placed similar bets" — `#DFDFE6`, 11px

#### Modal Footer Buttons (side by side, 10px gap)
- **"Leave anyway"**: `#363644` background, `#DFDFE6` text, flex 1, 44px height, border-radius 8px
- **"Stay & Bet"**: `#FFDB01` background, black text, flex 1, 44px height, border-radius 8px, weight 700

---

## Screen 3: Bet Placed Success Card

### Full-screen card (after successful ticket placement)
- Centered content, max-width 360px

#### Success Icon
- 64×64 px circle, `#0E7C1C` background, white ✓ checkmark 28px
- Subtle 1s scale-in animation (0.5→1.0 with spring bounce)

#### Title
- "Bet Placed!" — `#FFFFFF`, 22px, weight 800

#### Body
- "Your ticket has been submitted. Good luck!" — `#B0B0C0`, 13px

#### Reference
- "Reference" label left, **"PSK-7821-4902"** bold right — `#DFDFE6` on `#292933` row, padding 12px, border-radius 8px

#### Summary Rows (inside `#22222B` panel, border-radius 12px, padding 16px)

| Label | Value |
|---|---|
| Stake | 10.00 € |
| Pairs | 3 |
| Total odds | 12.48 |
| Placed at | 09 Sep 2026, 08:14 |
| **Potential return** | **113.32 €** (green `#35E94D`) |

#### Action Buttons (side by side, 10px gap)
- **"My Tickets"**: `#FFDB01` background, black text, flex 1, 48px height, border-radius 10px
- **"New Bet"**: `#363644` background, `#DFDFE6` text, flex 1, 48px height, border-radius 10px

#### Demo Note
- "This is a demo environment. No real money was wagered." — `#B0B0C0`, 10px, italic, centered

---

## What to Render
Show all **3 states as a horizontal flow** (left → center → right) or as 3 separate screens:
1. Checkout page with 3 selections, social proof strip, summary panel with 10€ stake
2. Leave-intent modal overlaying the checkout (showing the projected return card)
3. Success card with the confirmed ticket details
