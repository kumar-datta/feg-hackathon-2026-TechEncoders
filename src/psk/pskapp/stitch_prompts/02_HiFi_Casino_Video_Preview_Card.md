# HIGH-FIDELITY DESIGN — Casino Game Card with Video Preview on Long-Press

## Screen: Mobile App — 390 × 844 px (iPhone 14)

---

## Context
On the PSK website, hovering over a casino game card triggers a **video demo clip** that plays inline — the generated WebM/MP4 gameplay loop replaces the static thumbnail. Clicking opens a **Game Preview Modal** with autoplay video, game metadata (RTP, volatility, bet range), and Play/Details buttons. The mobile app currently shows only **static icon placeholders** (a casino/table icon + title) with Demo and Play buttons. This design upgrades the casino card to support video previews via long-press and adds a rich game preview bottom sheet.

---

## Color Palette (exact PSK tokens)
| Token | Hex | Usage |
|---|---|---|
| Brand Blue | `#1752BF` | Header, category chip selected state |
| Accent Gold | `#FFDB01` | Play button, jackpot accent, badge |
| BG Dark | `#0E0E11` | Scaffold background |
| Surface Dark | `#22222B` | Card background |
| Surface Dark Panel | `#292933` | Preview modal stage, card thumbnail bg |
| Surface Dark Action | `#363644` | Provider chips, Demo button |
| Text White | `#FFFFFF` | Card title |
| Text Gray | `#DFDFE6` | Card provider name |
| Text Muted | `#B0B0C0` | Metadata labels |
| Alert Red | `#C52D16` | HOT / LIVE badge |
| Border Dark | `#2A2A35` | Card border |
| Live Green | `#0E7C1C` | Live badge, player count |

---

## Component: Upgraded Casino Game Card
*Replaces the current static icon card in the 2-column grid*

### Card Dimensions
- Grid: 2 columns, 10px gap, 10px horizontal padding
- Card aspect ratio: approximately 0.78 (width : height)
- Border-radius: 10px
- Background: `#22222B`
- Border: 1px solid `#2A2A35`

### Card Thumbnail Area (top ~60% of card)
- **Default state**: Shows a gradient background generated from the game's two hue values — `linear-gradient(135deg, hsl(hueA, 65%, 38%), hsl(hueB, 55%, 22%))`
- **Center content**: Game emoji icon (🎰 for slots, 🃏 for table games) at 36px + game title at 12px white, vertically centered
- **Overlay badge** (top-left, 6px inset):
  - EXCLUSIVE: `#1752BF` background, white text, 8px font, bold, 4px border-radius
  - HOT / NEW: `#C52D16` background
  - PSK BRAND: `#FFDB01` background, black text
  - JACKPOT: Gold gradient `#FFDB01` → `#D06406` background

### Card Thumbnail — Video Preview State (on long-press)
- When user long-presses the card (300ms), the thumbnail area transitions:
  - The static gradient/icon **fades out** (200ms, opacity 1→0)
  - A **looping video** fades in (200ms, opacity 0→1) filling the entire thumbnail area
  - Video plays **muted, looping, inline** (same as website `<video muted loop playsInline>`)
  - A small **▶ PREVIEW** tag appears top-right: `#0E7C1C` background with white text, 8px font, 4px border-radius, padding 2px 6px
- When user lifts finger or moves away: video pauses, static thumbnail fades back in

### Card Info Area (bottom ~40% of card)
- Padding: 8px all sides
- **Title**: Game name, `#FFFFFF`, 12px, weight 700, max 1 line, ellipsis overflow
- **Provider**: Provider name, `#B0B0C0`, 10px
- **Button row** (6px gap between):
  - **Demo button**: Outlined, `#363644` border, `#DFDFE6` text, 10px, 28px height, flex 1
  - **Play button**: Filled `#FFDB01` background, black text, 10px weight 700, 28px height, flex 1

---

## Component: Game Preview Bottom Sheet (on card tap)
*Slides up from bottom, replaces the current direct navigation to game screen*

### Sheet Dimensions
- Height: ~60% of screen (auto-sized to content)
- Background: `#18181E`
- Border-radius: 20px top-left, 20px top-right
- Drag handle: 40 × 4px bar, `#363644`, centered, 8px from top

### Preview Stage (video area)
- Full-width of sheet, 200px height
- Background: `#292933`
- **Video**: Autoplays the demo clip, muted, looping, covering the full stage with `object-fit: cover`
- **Overlay**: Bottom gradient from transparent → `#18181E` (20px fade at bottom)
- **Live tag** (bottom-left, 8px inset): "▶ PREVIEW" — `#0E7C1C` dot + white text, 11px

### Game Metadata
- **Title**: Game name, `#FFFFFF`, 18px, weight 700, margin-top 12px, padding 0 16px
- **Provider**: Provider name, `#B0B0C0`, 13px
- **Badges row** (if applicable): Horizontal row of small tags
  - Each tag: `#1752BF` background, white text, 10px, border-radius 4px, padding 2px 8px

### Action Buttons (side by side, 16px horizontal padding, 10px gap)
- **Play button**: Flex 1, `#FFDB01` background, black text "▶ Play", 16px weight 700, height 48px, border-radius 10px
- **Details button**: Flex 1, `#363644` background, `#DFDFE6` text "Details", 16px weight 500, height 48px, border-radius 10px

### Details Section (expanded when "Details" is tapped)
- Slides down with 200ms ease animation
- Table layout inside a `#22222B` panel, border-radius 10px, margin 12px 16px, padding 12px
- Rows (alternating subtle stripe — odd rows `#22222B`, even `#292933`):

| Label | Value |
|---|---|
| Provider | Playtech |
| Type | slot |
| RTP | 96.5% |
| Volatility | Medium |
| Lines | 25 |
| Bet Range | 0.20 € – 100.00 € |
| Jackpot | 342,910.88 € |

- Labels: `#B0B0C0`, 12px, left-aligned
- Values: `#DFDFE6`, 12px, weight 600, right-aligned
- Bottom note: *"All figures are illustrative. This is a demo environment."* — `#B0B0C0`, 10px, italic

---

## What to Render
Show **two states side by side** (or as a flow):

**Left / State 1**: The Casino tab screen as it currently looks, but with the upgraded game cards. Show the 2-column grid with 4 visible game cards:
- "Vatreni Cup" by Playtech — EXCLUSIVE badge, gradient thumbnail blue→dark
- "PSK HOT 40" by Fazi — PSK BRAND badge (yellow), gradient orange→dark
- One card is being **long-pressed** and shows the video preview playing (with ▶ PREVIEW tag)
- Fourth card normal static state

Above the grid: the PSK header bar (`#1752BF` background, PSK logo in white, utility icons), the top tabs (Sports · • Live · Casino · Live Casino NEW · Lotto), the category chips (🔥 Popular selected in blue, ✨ New, 💎 Jackpot, 🎰 Slots), provider chips (All selected, Playtech, Pragmatic Play, EGT Digital), and search bar.

**Right / State 2**: The Game Preview Bottom Sheet is open for "Vatreni Cup", showing the video playing in the stage area, the metadata, Play/Details buttons, and the details table expanded.

Behind the sheet: dimmed overlay showing the casino grid.

---

## Bottom Navigation Bar
Same PSK bottom nav as app:
- 5 tabs: **Live** (🕐 + red dot) · **Sports** (🌐) · **Betslip** (🎟) · **Casino** (highlighted `#1752BF`, blue underline) · **Menu** (☰)
- Background: `#18181E`, height 56px
- Selected: `#1752BF` icon + label, 3px blue bar on top
- Unselected: `#B0B0C0`
