# HIGH-FIDELITY DESIGN — AI Assistant Chat Widget (RAG-Powered)

## Screen: Mobile App — 390 × 844 px (iPhone 14)

---

## Context
PSK is a sports-betting & casino mobile app. The header is solid `#1752BF` blue, bottom nav has 5 tabs (Live, Sports, Betslip, Casino, Menu), and the accent color is `#FFDB01` gold-yellow. The website version already has a floating AI assistant with RAG retrieval that answers FAQs, navigates to games ("open Aviator Rush"), shows source citations, and handles Hinglish/Telugu queries. The **mobile app has no AI assistant at all**. This design adds one as a floating chat panel.

---

## Color Palette (use exactly these)
| Token | Hex | Usage |
|---|---|---|
| Brand Blue | `#1752BF` | Header, primary buttons, FAB, user chat bubbles |
| Brand Blue Hover | `#2065E4` | FAB gradient center |
| Brand Blue Light | `#75A6FF` | Links, source citation text |
| Accent Gold | `#FFDB01` | CTA highlights, confirmation buttons |
| BG Dark | `#0E0E11` | Screen backdrop behind overlay |
| BG Dark Secondary | `#18181E` | Chat panel background |
| Surface Dark | `#22222B` | Header bar, input bar background |
| Surface Dark Panel | `#292933` | Assistant bubbles, suggestion chips, input field |
| Surface Dark Action | `#363644` | Close button, drag handle, inactive send button |
| Surface Dark Hover | `#40404F` | Pressed states |
| Text White | `#FFFFFF` | Primary text on dark, user bubble text |
| Text Gray | `#DFDFE6` | Assistant message text |
| Text Muted | `#B0B0C0` | Subtitles, timestamps, disclaimer |
| Alert Red | `#C52D16` | Unread notification dot |
| Border Dark | `#2A2A35` | Dividers |
| Live Green | `#0E7C1C` | Online status dot |

## Typography
- **Font**: Inter (or system San Francisco on iOS)
- **Weights**: 400 regular, 600 semibold, 700 bold

---

## Component: Floating Action Button (FAB)
- **Position**: Fixed bottom-right, 16px from right edge, 12px above the bottom nav bar (the PSK bottom nav with Live · Sports · Betslip · Casino · Menu icons)
- **Size**: 56 × 56 px circle
- **Background**: Radial gradient `#2065E4` center → `#1752BF` edge
- **Shadow**: `0 4px 16px rgba(23, 82, 191, 0.45)`
- **Icon**: White `#FFFFFF` speech-bubble SVG with three dots (⋯ pattern), 24 px
- **Unread badge**: 12 × 12 px red `#C52D16` circle with white "2", top-right corner, 2px white stroke border
- **Animation**: 2-second pulsing glow ring expanding from FAB edge, opacity 0.15 → 0.35

---

## Component: Chat Panel (slides up when FAB is tapped)
- **Height**: 85% of screen
- **Background**: `#18181E`
- **Border-radius**: 20px top-left, 20px top-right
- **Backdrop overlay**: `rgba(14, 14, 17, 0.6)` dimming the screen behind

### Drag Handle
- Centered at top of panel, 40 × 4 px rounded bar, `#363644`, border-radius 2px, margin-top 8px

### Header Bar (56px height)
- **Background**: `#22222B`
- **Left**: 36 × 36 px circle with gradient `#1752BF` → `#75A6FF`, containing sparkle icon ✦ in white 18px
  - Next to it:
    - **Title**: "PSK Assistant" — `#FFFFFF`, 15px, weight 700
    - **Subtitle**: Row containing 6px green `#0E7C1C` dot + "AI-powered · Online" — `#B0B0C0`, 11px
- **Right**: Close `×` button — 32 × 32 px circle, `#363644` background, white icon 16px
- **Bottom border**: 1px solid `#2A2A35`

### Welcome State (when no messages exist)
- Vertically centered in the chat body area:
  - Sparkle ✦ icon — 48px, inside a 72 × 72 px circle with gradient `#1752BF` → `#2065E4`
  - Below: **"Hi! I can help you find games, navigate the app, or answer questions."** — `#DFDFE6`, 14px, centered, max-width 260px, line-height 20px
- **Suggestion chips** (2 × 2 grid, 8px gap):
  - Each chip: `#292933` background, border-radius 20px, padding 10px 16px
  - Text: `#DFDFE6`, 12px, weight 500
  - Chip 1: "🎰 Open Aviator Rush"
  - Chip 2: "⚽ Show football bets"
  - Chip 3: "❓ How does Crash work?"
  - Chip 4: "💰 Check my balance"

### Chat Message Bubbles
**User message:**
- Alignment: Right
- Background: `#1752BF`
- Text: `#FFFFFF`, 13px, weight 400
- Border-radius: 16px 16px 4px 16px
- Max-width: 75% of panel width
- Padding: 12px 16px
- Timestamp below bubble: `#B0B0C0`, 10px, right-aligned, "08:12"

**Assistant message:**
- Alignment: Left
- Avatar: 24 × 24 px circle, `#1752BF`, with ✦ icon 12px white — to the left
- Background: `#292933`
- Text: `#DFDFE6`, 13px, weight 400, line-height 19px
- Border-radius: 16px 16px 16px 4px
- Max-width: 80% of panel width
- Padding: 12px 16px

**Action button** (inside assistant bubble, for navigation):
- Full width of bubble content, height 36px
- Background: `#1752BF`, border-radius 8px
- Text: white, 12px, weight 600, e.g. "▶ Open Aviator Rush"
- Arrow icon → on the right side
- If requires confirmation: 2px border `#FFDB01`, lock icon 🔒

**Source citations** (below assistant text):
- Collapsed: "📄 2 sources" — `#75A6FF`, 11px, tappable
- Expanded: Bulleted list of source titles — `#B0B0C0`, 11px
- Policy flag: " · Needs verified source" in `#D06406` (warning orange)

**Clarification options** (when assistant is ambiguous):
- Vertical stack of buttons below the assistant bubble
- Each: `#363644` background, `#DFDFE6` text, border-radius 10px, 40px height, 13px font, full bubble width
- 6px gap between buttons

**Typing indicator:**
- Assistant-style bubble, `#292933` background, 44px width
- Three dots: 6px circles, `#B0B0C0`, staggered bounce animation (0.2s delay between each)

### Input Bar (bottom of panel)
- **Background**: `#22222B`
- **Input field**: `#292933` background, `#DFDFE6` text, placeholder "Ask me anything..." in `#B0B0C0`, border-radius 24px, height 40px, padding-left 16px
- **Send button**: 36 × 36 px circle, right side inside input field
  - Active (text present): `#1752BF` background, white ➤ icon
  - Inactive (empty): `#363644` background, `#B0B0C0` ➤ icon
- **Bottom padding**: Additional safe-area inset

### Disclaimer Footer
- Below input: **"AI answers are informational only. Verify important details."** — `#B0B0C0`, 9px, centered, 4px padding

---

## What to Render
Show the panel in **open state with a conversation in progress**:

1. **User bubble**: "How does Aviator work?"
2. **Assistant bubble**: "Aviator Rush is a crash-style game where a multiplier rises from 1.00× and you cash out before it crashes. The longer you wait, the higher the multiplier — but if it crashes before you cash out, you lose your stake."
   - Below text: Source citation "📄 1 source" (collapsed)
   - Below source: Action button "▶ Open Aviator Rush"
3. **User bubble**: "thanks, what about roulette?"
4. **Typing indicator** (three bouncing dots)

The input field shows empty with placeholder "Ask me anything..."

Behind the panel, show the dimmed overlay with the PSK app's casino screen faintly visible (blue header with PSK logo, game cards). The FAB is in its `×` close state.

---

## Bottom Navigation Bar (visible behind overlay)
The PSK bottom nav bar (same as in the app screenshots):
- Background: `#18181E`
- 5 tabs equally spaced: **Live** (clock icon with red dot) · **Sports** (globe icon) · **Betslip** (ticket icon) · **Casino** (grid icon, highlighted blue `#1752BF`) · **Menu** (hamburger icon)
- Selected tab: `#1752BF` icon + text, with 3px blue underline
- Unselected: `#B0B0C0` icon + text
- Font: 10px, weight 500
