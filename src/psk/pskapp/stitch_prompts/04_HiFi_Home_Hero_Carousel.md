# HIGH-FIDELITY DESIGN — Home Screen with Hero Carousel & Quick Access Grid

## Screen: Mobile App — 390 × 844 px (iPhone 14)

---

## Context
The PSK website homepage features: a **hero carousel** with 3 auto-rotating slides (gradient backgrounds, headlines, CTA buttons), a **quick-access grid** (8 product shortcuts with live counts), **top offer events** with odds buttons, **live matches**, **casino game rails** with horizontal scrolling, **promo tiles**, and **news cards**. The mobile app currently jumps directly to the Sports/Casino tabs without a dedicated home/landing experience. This design adds a rich homepage as the default landing screen.

---

## Color Palette (exact PSK tokens)
| Token | Hex |
|---|---|
| Brand Blue | `#1752BF` |
| Brand Blue Dark | `#1447A6` |
| Accent Gold | `#FFDB01` |
| BG Dark | `#0E0E11` |
| Surface Dark | `#22222B` |
| Surface Dark Panel | `#292933` |
| Text White | `#FFFFFF` |
| Text Gray | `#DFDFE6` |
| Text Muted | `#B0B0C0` |
| Alert Red | `#C52D16` |
| Live Green | `#0E7C1C` |
| Money Green | `#35E94D` |
| Border Dark | `#2A2A35` |

---

## Layout (vertically scrollable)

### 1. Header Bar
- Standard PSK header: `#1752BF` background, hamburger ☰ left, PSK logo center-left (white SVG), right cluster: search 🔍 + QR scanner + tickets badge + profile avatar
- Below header: Top tabs (horizontal scroll): **Sports** (blue underline) · **• Live** (red dot) · **Casino** · **Live Casino** NEW · **Lotto** · **Virtuals**
- The "Home" state means no tab is actively underlined — or show a subtle home icon/state

### 2. Hero Carousel (auto-rotating, 3 slides)
- **Height**: 180px
- **Border-radius**: 12px
- **Margin**: 10px horizontal, 8px vertical
- **Auto-rotate**: Every 6 seconds with crossfade transition

**Slide 1 (Sports):**
- Gradient: `linear-gradient(115deg, #0A3FB0, #0B4BD4 45%, #17203A)`
- Eyebrow: "SPORTS BETTING" — `#75A6FF`, 10px, uppercase, letter-spacing 0.8px
- Title: **"500+ Live Events Today"** — white, 22px, weight 800
- Subtitle: "The best odds on football, basketball, tennis and more" — white 70% opacity, 12px
- Two buttons:
  - Primary: "View Offer" — `#FFDB01` background, black text, 12px weight 700, 32px height, border-radius 8px
  - Secondary: "Live Now →" — transparent, white text, 1px white/45% border, 12px, 32px height, border-radius 8px

**Slide 2 (Casino):**
- Gradient: `linear-gradient(115deg, #4A1D6E, #2A1046 45%, #140A24)`
- Eyebrow: "ONLINE CASINO"
- Title: **"2000+ Premium Games"**
- Subtitle: "Slots, roulette, blackjack, crash, and live dealers"
- Buttons: "Browse Casino" / "Live Casino →"

**Slide 3 (Lotto/Virtuals):**
- Gradient: `linear-gradient(115deg, #0B5C3A, #083F28 45%, #04210F)`
- Eyebrow: "LOTO & VIRTUALS"
- Title: **"Lottery Draws & Virtual Races"**
- Subtitle: "Try your luck with 6 lotto games and virtual sports"
- Buttons: "Open Loto" / "Virtual Races →"

**Carousel Navigation:**
- Left/right chevron arrows: 28×28 semi-transparent circles on card edges, white `‹` `›` icons
- Dot indicators below: 3 dots, 8px each, active dot `#FFDB01`, inactive `#363644`, 6px gap

### 3. Quick Access Grid (2×4 grid)
- Section header: "Quick Access" — `#FFFFFF`, 16px, weight 700
- Grid: 4 columns, 8px gap, margin 10px horizontal
- **Each card**: `#22222B` background, border-radius 10px, padding 12px, height ~72px
  - Icon: Emoji, 22px, top-center
  - Title: 11px, `#FFFFFF`, weight 600, center
  - Subtitle: 10px, `#B0B0C0`, center (dynamic count or description)

| Icon | Title | Subtitle |
|---|---|---|
| 🏆 | Sport | 512 events |
| 🔴 | Live | 48 events |
| 🎰 | Casino | 440 games |
| 🎥 | Live Casino | Real dealers |
| 🎱 | Loto | 6 draws |
| 🎮 | Virtuals | Races & more |
| 👆 | Swipe Bet | Quick picks |
| 🎁 | Promos | Bonuses |

### 4. Top Offer Section
- Section header: "⭐ Top Offer" left, "Full offer →" right link in `#75A6FF`
- Panel: `#22222B` background, border-radius 12px
- **Event rows** (show 3–4):
  - Left: Time "20:45" in `#B0B0C0` 11px, event name "Dinamo Zagreb – Hajduk Split" in `#FFFFFF` 13px weight 600, meta "🇭🇷 HNL · #4821" in `#B0B0C0` 11px
  - Right: 3 odds buttons (1, X, 2):
    - Default: `#292933` background, `#DFDFE6` text, 13px weight 700, 36px height, 48px width, border-radius 6px
    - Selected (in betslip): `#1752BF` background, white text
    - Unavailable: "–" in `#363644`, disabled

### 5. Live Now Section
- Section header: Red pulsing dot (6px `#C52D16`) + "Live Now" — `#FFFFFF` 16px weight 700, "All live →" link right
- Same event row format as top offer but with:
  - Minute indicator: "67'" in `#35E94D`, weight 700
  - Live score: "2:1" in `#C52D16`, weight 700

### 6. Casino Rails (horizontal scroll)
- Section header: "🔥 Popular" left, "See all (124) →" right
- **Horizontal scrolling row** of game cards (show 3–4 visible, peek of 5th)
- Each card: 130px wide × 170px tall, `#22222B` background, border-radius 10px, 1px `#2A2A35` border
  - Gradient thumbnail (top 60%), game title + provider + Demo/Play buttons (bottom 40%)
  - Same card design as prompt 02

### 7. Promo Tiles (2-column grid)
- Section header: "🎁 Promotions" left, "All promos →" right
- **2×2 grid** of promo cards:
  - Each: `#22222B` background, border-radius 10px
  - Top: 96px gradient banner with 🎁 emoji centered, gradient from `hsl(hueA, 70%, 44%)` to `hsl(hueB, 65%, 24%)`
  - Tag: "NEW" or "HOT" — `#FFDB01` background, black text, 8px, 4px border-radius
  - Title: 12px weight 700
  - Excerpt: 11px `#B0B0C0`, 2 lines max

### 8. News Cards (horizontal scroll)
- Section header: "📰 News" left, "All news →" right
- Horizontal scroll of cards, 200px wide each
  - Category tag: `#FFDB01` text, 10px weight 700
  - Date: `#B0B0C0`, 10px
  - Title: `#FFFFFF`, 13px weight 700
  - Excerpt: `#B0B0C0`, 11px, 2 lines

---

## What to Render
Show the **full home screen** scrolled about 30% down, so the hero carousel is partially scrolled up and the top offer + live sections are the primary focus. The hero should show Slide 1 (sports, blue gradient). Show the quick access grid fully visible. Show 3 event rows in the top offer and 2 in live. Show the casino rail peeking at the bottom.

The PSK bottom nav bar is visible at the bottom with no tab highlighted (or a home icon if present).
