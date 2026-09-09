# Final solution — FEG Hackathon Challenge 1

**One system, four parts, one new way of measuring.** Everything below is justified by a number we computed from the PSK data. Nothing here uses pressure.

---

## The answer in one sentence

> People already open the app 4 to 6 times a day. Half those visits were never about betting, and the ones that were get lost in a seven-screen hunt or a basket that dies when the app closes. **So we do not push people to act. We read why they came, shorten the path, and hold their intent when they leave.**

---

## What we build

Four parts. Parts 1 and 3 are already trained and tested on real data.

### Part 1 · Read why they came
Within the first three taps, work out what kind of visit this is: checking a ticket, glancing, browsing matches, following a live game, playing casino, doing account admin.

**Why:** 24% of visits are ticket checks lasting 41 seconds. 19% are 6-second glances. 8% are account admin. Just over half of all visits were never going to end in a bet.

**Status:** built. Correct 60% of the time across seven kinds, against 24% by guessing. Catches ticket checks 83% of the time. Uses only the first three taps, the hour, and time since the last visit.

**What the user sees:** the home screen reorders itself. Ticket checkers get their bet, with the live score already in the list. Live followers get the live list. One line says why, and a switch returns to the normal layout.

### Part 2 · Shorten the path
Four concrete changes, each from a specific finding.

| Change | The finding behind it |
|---|---|
| **A visible search bar on the home screen** | Search is used in 1–3% of visits and those convert twice as well. In the casino app it is already the number one way people find a game, and it reaches an action in 1.1 steps, the fastest path anywhere |
| **Show the 20 core bet types first, the rest on demand** | 20 bet types carry 80% of all bets, out of 32,981 offered. A focused customer uses 5. That is the "generic layout" problem, measured |
| **After depositing, land on live matches, not home** | Deposit → home → account is the worst path in the app: 15% reach a pick. Deposit → live list is the best: 93% |
| **"Add another from this league" on the basket** | People building a multi-bet walk the whole sport → league → matches tree again for every extra pick. The hunt is between picks, not before the first one |

**Why it matters:** the median visit crosses 7 screens before its first pick. A quarter cross 13 or more. Only 20% pick within three screens. Once someone reaches a single match's page they pick 87% of the time, so the interest is not the problem. The distance is.

### Part 3 · Hold the intent
The basket survives the visit for 24 hours. On the next open, a calm card: "Your slip, 3 picks. One price changed." It shows what changed and nothing else. No timer, no "hurry", no push notification, easy to dismiss.

**Why 24 hours:** a third of people who abandon a bet later bet on that exact same match, typically 3 hours later, 94% within a day. They did not change their minds. They lost the basket and had to find the match again.

Three supporting fixes:
- **A single pick sitting alone is the warning sign.** Nearly half those visits end without confirming, seven times the normal rate. The basket gets a clear summary at that moment: what you picked, what you would win, one tap.
- **Stop treating "bet again" on an old ticket as intent.** Those picks get confirmed 2% of the time. It is curiosity, not a decision, and it should not trigger the final-step flow.
- **Fix the Android rejection loop.** 17% of single-bet attempts come back rejected or closed, against under 1% on iPhone. People retry and nearly always get through, so this costs 1,103 wasted attempts a month and the trust that goes with them, not the bets. Check the bet is valid before submitting; if the price moved, show old and new side by side with one tap to accept.

**Status:** the risk score behind this is built. It ranks visits by chance of abandoning, and the riskiest 30% contain 52% of all abandons. It is a glass-box model that states its own reasons. It is used **only** to decide who sees the card and whose usual stake is pre-filled. Never to notify, never to hurry.

### Part 4 · Measure it honestly
A **Session Quality Index**: one score out of 100 per visit, asking whether the visit was good *for the user*. Built from four things: did they complete what they came for, how fast, how much friction they hit, and did they meet anything relevant and new. A harm penalty is subtracted, and any visit showing harm signs is capped low no matter how much was staked.

Every challenge metric is then reported **per kind of visit**. Ticket checks are judged on speed. Browsing visits on conversion.

**Why this is the important part:** if a ticket check counts as a failure, every improvement you try will aim at making that person bet. That is exactly the pressure the challenge forbids, and it happens by accident, through the measurement. Fixing the measurement is what makes the rest safe.

---

## What moves, and by how much

| Challenge metric | How this moves it |
|---|---|
| **Time to First Action** | Shortest path from 7 screens toward 3. Search, core-markets-first, deposit routing |
| **Session Conversion Rate** | Wider search use, and picks that no longer get lost |
| **Final-step Conversion** | Slip survives, single-pick summary, Android fix, re-bet taps no longer counted as intent |
| **Actions per Session** | "Add another from this league" removes the walk between picks |
| **Value per Session** | More completed intent per visit, plus non-money value from ticket checks made fast and useful |
| **Sessions per User** | Deliberately **not** a target. It is watched as a guardrail, not pushed |
| **New: Session Quality Index** | The score everything is optimised against, with harm capped |

**Money, stated honestly.** Roughly €3M to €5M extra stake a year across the Croatian sportsbook, midpoint about €4M. Sportsbook margin is 8 to 10% of stake, so earnings are roughly a tenth of that. Assumptions are listed in `poc-plan.md`; the largest is that search adoption reaches 15% and causes a quarter of the conversion gap we observe.

---

## The guardrail, built in rather than bolted on

- **Harm-flagged visits switch everything off.** Night marathons, sessions over two hours, rapid reopening, rising stake. Those visits see the plain app and the responsible-gambling tools. No personalisation, no slip resume, no suggestions.
- **The flagged-visit rate is reported next to every uplift number, in the same chart.** If it rises, the idea fails, regardless of conversion.
- **Thinking time must not shorten.** People who confirm take about 97 seconds from first pick. If our version makes that faster, we are rushing people, and we treat it as a failure.
- **Nothing uses loss history to time a prompt.** Written down explicitly.
- **The one thing we refuse to optimise:** the rules found that the easiest way to lift raw conversion is to encourage the marathon pattern, which converts 100% of the time. The Session Quality Index caps those visits so no learning system can ever discover that.

---

## How we prove it

Half the users get the new version, half keep the current one.

| Measure | Pass condition |
|---|---|
| Session Quality Index | Higher |
| Final-step conversion | Higher |
| Conversion for browsing visits | Higher |
| Conversion for ticket-check visits | **Unchanged.** We are not trying to make those people bet |
| Time to first action | Lower |
| Harm-flagged visit share | **Must not rise** |
| Thinking time before confirming | Must not shorten |
| Still active at 30 and 90 days | Higher, or at least not lower |

The 30 and 90 day check is the real test. Anyone can lift conversion for a week with pressure. Uplift that survives three months only happens when the product genuinely got more useful.

---

## The five-minute demo

1. **A real August visit replayed.** After three taps the detector says "ticket check, confident". The home screen reorders, the live score is already in the list, the visit ends in 9 seconds with a quality score of 88. Under today's measurement it counts as a failure.
2. **The path, before and after.** The same person hunting a match across 9 screens, then finding it in 2 with search.
3. **The lost basket.** Three picks added, app closed after 6 seconds. Forty minutes later, the card. One tap. Placed. Then the number behind it: a third of abandoned matches are bet on later anyway, typically 3 hours on.
4. **The Android loop.** Bet submitted, rejected, retried, accepted. Then the fixed version: price change shown side by side, one tap.
5. **The harm panel.** A 3am marathon. Everything above switched off. The guardrail line on the dashboard, flat.

---

## Why this wins the brief

- **It answers the actual question.** The brief asks for confident, informed actions without pushing anyone. We found that pushing would come from the measurement, not from intent, and fixed the measurement first.
- **It covers all five innovation areas.** Discovery and relevance (Part 2), engagement across categories (adaptive layout, core markets), real-time guidance (Part 1), the final step (Part 3), and a better way to measure session quality (Part 4).
- **Two pieces already work.** The intent detector and the risk score are trained and tested on real data, held out by user so they cannot cheat.
- **Every claim has a number behind it**, and where we were wrong we say so. We first wrote up the Android defect as lost bets. The retry analysis showed users fight through it, so we moved it from the money column to the friction column ourselves.
