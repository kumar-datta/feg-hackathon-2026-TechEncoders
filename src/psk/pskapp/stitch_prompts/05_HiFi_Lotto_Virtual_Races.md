# HIGH-FIDELITY DESIGN — Lotto Draws & Virtual Races Screens

## Screen: Mobile App — 390 × 844 px (iPhone 14)

---

## Context
The PSK website has a full **Lotto** page with 6 lottery games (animated draws, ball selections, jackpots) and a **Virtual Races** page with horse/dog racing simulations, race schedules, and results. The mobile app has these in the top tab bar but lacks dedicated, richly designed screens. This design adds premium lotto and virtual racing experiences.

---

## Color Palette (exact PSK tokens)
| Token | Hex |
|---|---|
| Brand Blue | `#1752BF` |
| Accent Gold | `#FFDB01` |
| BG Dark | `#0E0E11` |
| Surface Dark | `#22222B` |
| Surface Dark Panel | `#292933` |
| Surface Dark Action | `#363644` |
| Text White | `#FFFFFF` |
| Text Gray | `#DFDFE6` |
| Text Muted | `#B0B0C0` |
| Money Green | `#35E94D` |
| Alert Red | `#C52D16` |
| Warning Orange | `#D06406` |
| Border Dark | `#2A2A35` |

---

## Screen A: Lotto Page

### Header & Navigation
- PSK header bar: `#1752BF` background, PSK logo, utility icons
- Top tabs: Sports · Live · Casino · Live Casino · **Lotto** (selected, blue underline) · Virtuals
- Page title: "🎱 Lotto" — `#FFFFFF`, 20px, weight 700
- Subtitle: "Choose your numbers and try your luck in 6 lottery draws" — `#B0B0C0`, 12px

### Lotto Game Selector (horizontal scrolling cards)
- **6 lotto game cards** in a horizontal scroll, 140px wide × 100px tall each
- Each card: Gradient background (unique per game), border-radius 12px, padding 12px
  - Game icon emoji (28px) centered top
  - Game name below: white, 12px, weight 700
  - Next draw time: `#B0B0C0`, 10px
  - Jackpot amount: `#FFDB01`, 13px, weight 800

| Game | Gradient | Icon | Jackpot |
|---|---|---|---|
| Loto 7/39 | `#1752BF` → `#0A3FB0` | 🎱 | 1,250,000 € |
| Joker | `#4A1D6E` → `#2A1046` | 🃏 | 845,000 € |
| EuroJackpot | `#0B5C3A` → `#083F28` | 🌍 | 42,000,000 € |
| Bingo | `#C52D16` → `#8B1F10` | 🔴 | 125,000 € |
| Keno | `#D06406` → `#8B4300` | ⭐ | 500,000 € |
| Quick Pick | `#363644` → `#22222B` | ⚡ | 50,000 € |

- Selected card: 2px `#FFDB01` border, slight scale-up 1.03x

### Selected Game Detail Area

#### Number Grid
- Title: "Pick 7 numbers from 1–39" — `#DFDFE6`, 14px, weight 600
- Grid: 6 columns, numbers 1–39 as circular buttons
  - Default: `#292933` background, `#DFDFE6` text, 38px diameter, 12px font
  - Selected: `#1752BF` background, white text, subtle glow `0 0 8px rgba(23, 82, 191, 0.5)`
  - Hot number (frequently drawn): Small `#C52D16` dot top-right
- "Quick Pick" button below grid: `#363644` background, `#DFDFE6` text "🎲 Random Pick", full width, 40px height, border-radius 8px

#### Draw Animation Area
- 220px height, `#22222B` background, border-radius 12px, centered
- Shows a **lottery ball machine** illustration:
  - Glass dome shape with `#292933` fill, white 10% opacity border
  - Inside: 7 numbered balls bouncing gently (animation hint: slight offset positions)
  - Each ball: 32px diameter, gradient from hueA → hueB (matching game), white number text, weight 800
  - Below machine: "Next draw: Today 20:00" — `#FFDB01`, 12px, weight 600
- "DRAW NOW" button: `#FFDB01` background, black text, full width, 48px height, border-radius 10px, weight 700

#### Results Section
- "Latest Results" header with date "08 Sep 2026"
- Winning numbers row: 7 balls in a horizontal line, 28px each, `#1752BF` background, white text
- "Your matches: 3/7" — `#35E94D` if ≥3, `#C52D16` if ≤2
- Prize: "25.00 €" if won, or "No win this round" in `#B0B0C0`

---

## Screen B: Virtual Races Page

### Header & Navigation
- PSK header, top tabs with **Virtuals** selected (blue underline)
- Page title: "🎮 Virtual Races" — `#FFFFFF`, 20px, weight 700
- Subtitle: "Bet on simulated horse and greyhound races every 3 minutes" — `#B0B0C0`, 12px

### Race Type Selector
- Two large cards side by side, 10px gap:
  - **Horse Racing**: `#22222B` background, 🐎 icon 32px, "Horse Racing" white 14px weight 700, "Every 3 min" `#B0B0C0` 11px
  - **Greyhound**: Same layout with 🐕 icon
- Selected: `#1752BF` left border 3px, `#2A2A35` → slightly lighter background

### Upcoming Race Card
- "Next Race" + countdown timer "02:41" in `#C52D16`, 13px weight 700
- Race name: "Race 147 — Meadow Cup" — `#FFFFFF`, 16px, weight 700
- Track: "Ascot Virtual" — `#B0B0C0`, 12px

### Runner List (vertical cards)
- Each runner row: `#22222B` background, border-radius 8px, padding 12px, margin 6px
  - **Position number**: Large number in colored circle (1=`#C52D16`, 2=`#1752BF`, 3=`#0B5C3A`, etc.), 32px
  - **Name**: "Thunder Bolt" — `#FFFFFF`, 13px, weight 600
  - **Jockey/Trainer**: "J. Smith / K. Patel" — `#B0B0C0`, 10px
  - **Form**: "1-3-2-1-4" — `#DFDFE6`, 10px, monospace
  - **Odds button**: `#292933` background, `#FFDB01` text "3.50", 13px weight 700, 36px height, 60px width, border-radius 6px
    - Selected (in betslip): `#1752BF` background, white text

### Race Visualization Area (placeholder for animation)
- 200px height, `#292933` background, border-radius 12px
- Show a **track illustration**: Horizontal lanes with colored dots representing horses
- Finish line on the right (dashed white vertical line)
- "🔴 LIVE" tag top-left, red dot pulsing + white text
- "Tap to watch race" overlay text — `#B0B0C0`, centered, 13px

### Past Results
- "Recent Results" header
- Horizontal scroll of result cards, each 180px wide:
  - Race name, winner name, winning odds in `#35E94D`, time "3 min ago" in `#B0B0C0`

---

## What to Render
**Screen A (Lotto)**: Show the full lotto page with "Loto 7/39" selected, the number grid with 5 numbers selected (highlighted blue), the draw animation area with balls inside the machine, and the "DRAW NOW" button.

**Screen B (Virtuals)**: Show the virtual races page with horse racing selected, an upcoming race card with countdown, 4 visible runner rows with odds buttons (one selected/in betslip), and the race visualization placeholder.

Show both screens side by side as separate mobile frames.
