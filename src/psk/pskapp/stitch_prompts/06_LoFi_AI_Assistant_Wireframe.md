# LOW-FIDELITY WIREFRAME — AI_ASSISTANT // RAG_CHAT_PANEL

## DEVICE_FRAME: MOBILE // 390 × 844

---

## STYLE_RULES
- **NO COLORS** — everything is black `#000000`, white `#FFFFFF`, and grays `#999999` / `#CCCCCC` / `#E5E5E5`
- **FONT**: Monospace only (Courier New, JetBrains Mono, or similar)
- **AESTHETIC**: Brutalist, technical, wireframe — all labels use UPPER_SNAKE_CASE
- **BORDERS**: 1px solid black `#000000`, no rounded corners (use sharp rectangles, 0px border-radius)
- **NO SHADOWS, NO GRADIENTS, NO ICONS** — use text labels and brackets instead
- **BUTTONS**: Outlined rectangles with text like `[ ACTION_NAME ]`
- **INDICATORS**: Use `[ ● ]` for dots, `[---]` for loading bars, `/_/` for input fields

---

## LAYOUT

```
┌──────────────────────────────────┐
│ ≡  PSK_SYSTEM // REF:ASSISTANT   Q │
├──────────────────────────────────┤
│ // MODULE_PATH: TOOLS > AI_CHAT │
│                                  │
│ ━━━━━━ ASSISTANT                 │
│ CHAT_PANEL                       │
│ ───CONTEXT: RAG_RETRIEVAL //     │
│       ENTITY_RESOLUTION          │
├──────────────────────────────────┤
│                                  │
│ WELCOME_STATE                    │
│                                  │
│         [ ✦ ]                    │
│                                  │
│  GREETING_TEXT:                   │
│  "I can help you find games,     │
│   navigate the app, or answer    │
│   questions about PSK."          │
│                                  │
│  SUGGESTION_CHIPS:               │
│  ┌──────────┐ ┌──────────────┐  │
│  │ OPEN_     │ │ SHOW_        │  │
│  │ AVIATOR   │ │ FOOTBALL     │  │
│  └──────────┘ └──────────────┘  │
│  ┌──────────┐ ┌──────────────┐  │
│  │ HOW_DOES │ │ CHECK_MY_    │  │
│  │ CRASH_   │ │ BALANCE      │  │
│  │ WORK     │ │              │  │
│  └──────────┘ └──────────────┘  │
│                                  │
├──────────────────────────────────┤
│ CONVERSATION_STATE               │
│                                  │
│              ┌─────────────────┐ │
│              │ USER_MSG:       │ │
│              │ "how does       │ │
│              │  aviator work?" │ │
│              └─────────────────┘ │
│                                  │
│ ┌──────────────────────┐         │
│ │ ASSISTANT_MSG:       │         │
│ │ "Aviator Rush is a   │         │
│ │  crash-style game    │         │
│ │  where a multiplier  │         │
│ │  rises from 1.00×    │         │
│ │  and you cash out    │         │
│ │  before it crashes." │         │
│ │                      │         │
│ │ SOURCES: [1_SOURCE]  │         │
│ │ ┌──────────────────┐ │         │
│ │ │ [ OPEN_AVIATOR ] │ │         │
│ │ └──────────────────┘ │         │
│ └──────────────────────┘         │
│                                  │
│ ┌──────────────────────┐         │
│ │ ASSISTANT_MSG:       │         │
│ │ CLARIFICATION:       │         │
│ │ "Did you mean:"      │         │
│ │ ┌──────────────────┐ │         │
│ │ │ [ ROULETTE ]     │ │         │
│ │ └──────────────────┘ │         │
│ │ ┌──────────────────┐ │         │
│ │ │ [ BLACKJACK ]    │ │         │
│ │ └──────────────────┘ │         │
│ │ ┌──────────────────┐ │         │
│ │ │ [ CRASH_GAME ]   │ │         │
│ │ └──────────────────┘ │         │
│ └──────────────────────┘         │
│                                  │
│ TYPING_INDICATOR: [ . . . ]      │
│                                  │
├──────────────────────────────────┤
│ INPUT_BAR:                       │
│ ┌────────────────────┐ ┌──────┐ │
│ │ /_QUERY_INPUT_/    │ │ SEND │ │
│ └────────────────────┘ └──────┘ │
│                                  │
│ DISCLAIMER_TEXT:                  │
│ "AI answers are informational    │
│  only. Verify important details."│
├──────────────────────────────────┤
│ LIVE    SPORTS  BETSLIP  CASINO  │
│  ●                         MENU  │
└──────────────────────────────────┘
```

## ANNOTATIONS

- **FAB_TRIGGER**: 56×56 square button, bottom-right, labeled `[ AI ]`, before panel opens
- **PANEL_HEIGHT**: 85% of screen, slides up from bottom
- **DRAG_HANDLE**: `[————]` centered bar at top of panel
- **USER_BUBBLES**: Right-aligned rectangles, 1px black border
- **ASSISTANT_BUBBLES**: Left-aligned rectangles, 1px black border
- **ACTION_BUTTONS**: Full-width rectangles inside assistant bubbles
- **SOURCE_CITATIONS**: Collapsed `SOURCES: [N_SOURCES]` — expands to bulleted list
- **CLARIFICATION_OPTIONS**: Stacked button rectangles when intent is AMBIGUOUS
- **TYPING**: Three dots `[ . . . ]` in an assistant-style rectangle
- **INPUT_FIELD**: Rectangle with `/_PLACEHOLDER_/` text, SEND button right
- **CLOSE_BUTTON**: `[ X ]` top-right of header

## STATES_TO_SHOW
Render two side-by-side frames:
1. WELCOME_STATE — with suggestion chips, no messages
2. CONVERSATION_STATE — with 2 messages + clarification + typing indicator

## NOTES
- The RAG retrieval pipeline: intent classification → entity resolution → BM25 + vector hybrid → RRF ranking → answer generation
- Source citations show which data chunks were used
- Navigation actions route via entity_id → route lookup (never model-generated URLs)
- Safety refusals for financial queries, self-exclusion bypass, and system-beating requests
