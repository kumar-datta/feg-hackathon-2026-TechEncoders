# PSK.demo — MERN sportsbook & casino UI

An **educational MERN application** (MongoDB, Express, React, Node) that reconstructs the
information architecture of a typical sports-betting and online-casino site: product
navigation, a sports tree, an odds grid, a bet slip, a filterable game catalogue, and the
usual supporting pages.

> **This is not a real betting site.** It is not affiliated with, endorsed by, or connected
> to any gambling operator. It accepts no payments, offers no real wagering, and represents
> no company. Every event, odd, game title and amount is generated data; account balances are
> fictional demo credits with no value. All code, styling, copy and game titles here were
> written from scratch for this project.

---

## Quick start

**Prerequisites:** Node.js 18+ and a running MongoDB (local install or an Atlas connection string).

```bash
# 1. install dependencies for both halves
npm run install:all

# 2. configure the server (optional — defaults work with a local MongoDB)
cp server/.env.example server/.env

# 3. populate the database
npm run seed

# 4. run the API and the client in two terminals
npm run server      # http://localhost:5000
npm run client      # http://localhost:5173
```

Then open <http://localhost:5173>.

**Demo login (created by the seed):** `demo` / `demo1234`

If MongoDB is not running, the API exits with a message instead of starting — start MongoDB or
point `MONGODB_URI` at an Atlas cluster.

---

## Project layout

```
psk/
├── server/                  Express + Mongoose API
│   ├── src/
│   │   ├── index.js         app entry, middleware, route mounting
│   │   ├── seed.js          populates MongoDB with the demo offer & catalogue
│   │   ├── config/db.js     Mongoose connection
│   │   ├── models/index.js  all schemas (15 collections)
│   │   ├── middleware/       JWT auth + central error handling
│   │   ├── routes/          auth, offer, casino, tickets, content
│   │   └── utils/generate.js seeded data generator (sports, leagues, games…)
│   └── .env.example
│
├── client/                  React + Vite front end
│   └── src/
│       ├── main.jsx / App.jsx      entry + routing
│       ├── api/client.js           typed fetch wrapper for the API
│       ├── context/AppContext.jsx  auth, wallet, bet slip, theme, toasts, modal
│       ├── components/             Header, Footer, Sidebar, BetSlip, EventRow, GameCard…
│       ├── games/engines.jsx       8 playable demo games
│       ├── pages/                  28 routed pages
│       └── styles/main.css         the whole design system
│
└── prototype/               the original static HTML pass, kept for reference
```

---

## What is implemented

### Sportsbook
- 30 sports, ~90 leagues and several hundred generated events with market gaps, live
  clocks and scores, mirroring how a real offer grid looks.
- Collapsible league blocks, market-set-aware column headers (`1 X 2` vs `1 2 H1 H2 …`).
- Filters: all / live / today / next 3 hours; sidebar filtering by sport and league.
- A full market board per event (`+N` button) with grouped markets.
- Bet slip shared across every page, persisted in `localStorage`, one selection per event,
  total odds, illustrative 10% deduction and net return.

### Betting flow
- Tickets are placed through `POST /api/tickets`. **The server re-reads every odd from the
  database** rather than trusting the browser, rejects closed events and duplicate events,
  debits the wallet and stores the ticket.
- Manual settlement resolves each selection with a probability derived from its odds.
- Tickets can be shared to the Arena feed and copied back onto your own slip.

### Casino
- ~440 games: generated slots plus hand-built table games and 12 live tables.
- Categories, provider pages, search, pagination and animated jackpot tiles.
- Thumbnails are drawn in CSS from two hues + an emoji, so there are no image assets.
- **Eight playable engines**: 5×3 slot with 5 paylines, European roulette, blackjack,
  crash, mines, dice, money wheel, baccarat.
- Every round posts to `POST /api/casino/round`, which validates the stake against the
  game's limits, caps the payout and updates the balance server-side.

### Other products
Lotto (6 games with animated draws), virtual races, Swipe & Bet (keyboard-driven quick
slip), Arena, promotions, forum, results, statistics, news, shops, loyalty tiers.

### Languages
- **Croatian and English**, switchable from the **language selector in the page footer**.
- The choice is stored per browser (`psk.lang`) and applies instantly — no reload.
- Covers the whole interface: navigation, bet slip, all eight game engines, every page,
  form labels, table headers, toasts and validation messages.
- Number, currency and date formatting follow the locale (`hr-HR` / `en-GB`).
- **Server messages are localised too**: the client sends `Accept-Language`, and
  `server/src/utils/messages.js` returns API errors in that language.
- Enumerable API data (sport names, casino categories, market labels, volatility) is
  translated client-side by key.

Adding a third language means dropping a new dictionary into `client/src/i18n/`,
registering it in `LANGUAGES`, and adding the matching block to the server catalogue.

### Account & safety
- JWT auth with bcrypt password hashing.
- Demo credit top-ups, play history, deposit/loss/session limits, and self-exclusion that is
  actually enforced by the auth middleware.
- Responsible-gaming page, 18+ notices and a persistent demo banner.

---

## API reference

| Method | Route | Purpose |
| --- | --- | --- |
| `GET` | `/api/health` | service check |
| `POST` | `/api/auth/register` · `/login` | account creation and sign-in |
| `GET` | `/api/auth/me` | current user |
| `POST` | `/api/auth/deposit` | add demo credits |
| `PUT` | `/api/auth/limits` | play limits / self-exclusion |
| `GET` | `/api/offer/sports` | sidebar tree with counts |
| `GET` | `/api/offer/events` | offer, grouped by league |
| `GET` | `/api/offer/events/:id` | one event + full market board |
| `GET` | `/api/casino/lobby` | lobby rails and jackpots |
| `GET` | `/api/casino/games` | catalogue with filters and paging |
| `POST` | `/api/casino/round` | settle one game round |
| `POST` | `/api/tickets` | place a ticket |
| `GET` | `/api/tickets` · `/shared` | my tickets · Arena feed |
| `POST` | `/api/tickets/:ref/settle` · `/share` | settle · share |
| `GET` | `/api/content/*` | promos, news, shops, lotteries, virtuals, threads, results, stats, search |

---

## Design notes

- **Dark-first theme** with a light variant; the choice is stored per browser and applied
  before first paint to avoid a flash.
- **No external assets.** No image files, icon fonts or web fonts — the logo, game art,
  roulette wheel and playing cards are all CSS.
- **Deterministic data.** The generator uses a fixed-seed PRNG, so reseeding always produces
  the same offer and catalogue.
- **Responsive.** Three-column desktop layout collapses to a drawer sidebar, a floating slip
  button and a bottom navigation bar on mobile.

## Not implemented

Real payments or KYC, video streams for live tables, automatic enforcement of the stored
play limits, and any connection to real sports data feeds.
