# Two problems, two proofs of concept, one business case

This is the document for the evaluators. Two problems, chosen because the data proves they are real, each with an exact proof of concept (POC), the intelligence behind it, the numbers it should move, and how we prove it worked without harming anyone.

Everything here is grounded in the PSK app data (August 2026, 16,000 app visits) and the all-customer monthly figures. Where a number is an assumption, it is labelled as one.

---

## The one-line answer to the challenge

> People open the PSK app four to six times a day, and only one visit in four ends in an action. But half of those "failed" visits were never trying to act, and of the ones that were, the biggest single loss is a bug. So the way to more completed actions is not to push harder. It is to **read what each visit is for, and remove what stops it.**

That sentence gives us the two problems.

| | Problem 1 | Problem 2 |
|---|---|---|
| **Name** | The app cannot tell why you came | One tap away, and lost |
| **Challenge area** | Discovery, relevance, real-time guidance, measuring session quality | Converting intent at the final step |
| **What the data proved** | 51% of visits are ticket checks, glances or admin. Search, used in 2% of visits, doubles conversion | 19% of visits that add a pick never place it. On Android, 17% of single-bet attempts are rejected by the system and have to be retried |
| **POC** | **Intent-Aware Session Layer** | **Betslip Guardian** |
| **Metrics moved** | Session conversion, time to first action, value per session, a new Session Quality Index | Final-step conversion, actions per session, value per session |
| **Estimated value** | €1.5M to €2.5M extra stake per year (sportsbook) | €1.5M to €2.5M extra stake per year (sportsbook), plus a large friction saving on Android that is real but not money |

---

# Problem 1 — The app cannot tell why you came

## The problem, stated plainly

The home screen is the same for everyone. A person checking whether last night's bet won, a person following a live match, a person who wants to bet on Dinamo tonight and a person who has never opened the app before all see identical layouts. Each has to dig. Most give up before they find what they came for, or find it slowly.

## What the data proved

- We sorted 16,000 visits into natural groups. **24% are ticket checks** lasting 41 seconds. **19% are glances** lasting 6 seconds. **8% are account admin.** Only 16% are people who browsed the matches and chose not to bet.
- On iPhone, the most common thing after opening is going straight to ticket history, **47% of the time**. The home screen is in the way.
- **Search is used in 3% of iPhone visits and 1% of Android visits**. Those visits convert at **71% and 79%**, against 33% and 31% for everyone else. In the casino app, search is already the number one way people find a game.
- People bounce between the live list and a live match **42,000 times** in a month, because the list does not show what they need.
- Across all customers, the number of different sports per visit fell from 1.44 to 1.34 between March and August. People are exploring less. That is a discovery failure showing up in the money.

## The POC: Intent-Aware Session Layer

Three parts. The first two are already built and tested on the data.

### Part 1 — Intent detector (built)
Within the first three taps, decide what kind of visit this is. We trained it on the August data and tested it properly, holding out entire users so it could not cheat by recognising people.

| | Result |
|---|---|
| Correct kind of visit, out of 7 | **60%**, against 24% by guessing the most common kind |
| Catches ticket-check visits | **83%** of them |
| Catches glance visits | 72% |
| Catches casino visits | 62% |
| Catches marathons | 26%, the weakest, and the one that matters for safety, so the harm rules cover it separately |

Three taps is very little information. It gets better with every further tap and with the person's previous visit, both of which the live version would use.

### Part 2 — Session Quality Index (designed, computable from the data)
One score out of 100 for each visit, asking whether the visit was good **for the user**. Built from: did they complete what they came for, how fast, how much friction they hit, and whether they met anything relevant and new. A harm penalty is subtracted, and any visit showing harm signs is capped low regardless of how much was staked.

This replaces "did they bet" as the thing we optimise. A ticket check answered in 8 seconds scores well. A 106-minute marathon at 3am scores badly no matter how many bets it contained. **Because harm caps the score, no system that learns from it can ever learn that pressure works.**

### Part 3 — What the user sees (the build phase)
- **Home screen that reorders itself** to the detected intent, with one line saying why, and a switch back to the standard layout.
- **A visible search bar** on the home screen of both apps, understanding Croatian and English and everyday phrasing. Every result states why it matched: "Serie A, which you bet on most weeks".
- **Live list rows that carry the answer**, score, minute and the bet types this person usually takes, so the round trips stop.

### The intelligence behind it
| Piece | Method | Why it is explainable |
|---|---|---|
| Intent detector | Gradient boosting on the first three screens, hour, time since last visit | Reports which factors drove each decision. Starts from written rules on which screens were touched |
| Search | Keyword match plus meaning-based match, combined, re-ordered by this person's history | The matching words are highlighted and the ordering reason is written out |
| Layout choice | Learns which layout works per kind of visit, scored on the Session Quality Index, with harm as a hard limit | Every choice and outcome is logged |

### Business intelligence dashboard for this POC
1. Mix of visit kinds, daily, with a 7-day smoothed line.
2. The six challenge measurements, **split by kind of visit**. This is the honest view: ticket checks are judged on speed, browsing visits on conversion.
3. Search adoption and search-visit conversion, daily.
4. Time to first action, per kind of visit, per app.
5. Session Quality Index distribution, and the share of visits flagged for harm. That last line must be flat or falling.

### The business case (sportsbook, all Croatian customers, from the August figures)

Base: 447,046 visits per month, €25.30 average stake per visit, 24.1% convert.

| Assumption | Value | Basis |
|---|---|---|
| Search adoption rises from ~2% to 15% of visits | +13 points | Casino app already shows 33% adoption when search is visible |
| Conversion lift for a visit that uses search | **+10 points** | The observed gap is +40 points, but people who search already know what they want. We assume only a quarter of the gap is caused by search itself |
| Extra converting visits per month | 447,046 × 13% × 10% ≈ **5,800** | |
| Extra stake per month | 5,800 × €25.30 ≈ **€147,000** | |
| Extra stake per year | **≈ €1.8M** | Range €1.5M to €2.5M depending on adoption |
| Casino app | Time to first game 55 s versus 28 s on the website; app stuck at 43% while website reached 50% | Reaching website parity is worth roughly a sixth more casino visits with a game in them. Not counted above, because casino visit volumes were not shared |

Note on money: stake is what customers bet, not what FEG earns. Sportsbook margin is typically 8 to 10% of stake, so the earnings figure is roughly a tenth of the stake figure. We state stake because it is what the data lets us measure.

**The value not in that table.** Ticket-check visits produce no stake and today count as failures. Making them fast and useful, with live scores in the list and follow-this-match options, is a retention play. It is the part most likely to show up at 30 and 90 days, and the part no competitor is optimising for.

---

# Problem 2 — One tap away, and lost

## The problem, stated plainly

Someone has picked a bet and put it in their slip. It is the strongest signal of intent the app ever sees. And then they leave. The challenge calls this out specifically. The data shows it is really two different problems wearing one label, and the bigger one is not the user's fault.

## What the data proved

- Of 5,568 visits that added a pick, **1,064 (19%) never placed it**. 667 on iPhone, 397 on Android.
- **On Android, single-bet attempts are accepted only 83% of the time.** On iPhone, 99.5%. Same users, same matches, same month. In August: 642 came back "closed", 451 "rejected". Something in the Android app mishandles the moment odds change or a market closes. **Important nuance from the retry analysis:** people retry and almost always succeed. 15% of Android visits with a placement hit at least one rejection, but only 15 of those 358 visits ended without an accepted ticket. So the defect costs time, trust and repeated taps, not lost bets. It belongs in the friction part of the Session Quality Index, not in the money column.
- **On iPhone the person is interrupted, not undecided.** Abandoners add fewer picks (4 against 9), half never open the betslip screen, and they close the app 43 seconds after the last pick, a quarter within 5 seconds.
- **The intent survives.** After abandoning, **40% come back within the hour and 39% place a bet in their next visit.** They did not change their minds. They lost the slip.
- **Where the pick came from matters.** Picks from a live match page get placed 88% of the time. From the "most bet matches" widget, 56%. Suggestions based on popularity are the worst performers in the app.

## The POC: Betslip Guardian

Three parts, in order of value.

### Part 1 — Stop the system rejecting good bets (no technology risk)
- Check the bet is still valid **before** submitting, not after.
- If the odds moved, show old and new price side by side, one tap to accept. Facts, not warnings.
- If the market closed, keep the slip and offer the same pick in the next open market.
- A once-only setting: "accept small odds changes automatically".
- Record the reason for every rejection, so this never needs detective work again.

Expected effect: 1,103 failed placement attempts a month in our sample alone disappear, and with them the retry loop. Direct money effect is small, because users already retry until accepted. The gain is friction removed at the exact moment of highest intent, which is what the challenge asks for, and it is the cheapest fix in this document.

### Part 2 — The slip that does not die
The slip survives between visits. On the next open, a quiet card: "Your slip, 3 picks. One price changed." It shows what changed and nothing more. No timer, no "hurry", no push notification. Easy to dismiss.

The person's usual stake is pre-filled, from their own history, so placing is one tap.

### Part 3 — Risk score, used only to help (built, tested)
A model that estimates, at the moment of the first pick, how likely this visit is to end without placing. Tested by holding out entire users.

| | Result |
|---|---|
| Ability to rank visits by risk (AUC) | **0.66** with a glass-box model, 0.67 with a more complex one |
| The riskiest 10% of visits | abandon at **41%**, against 19% overall |
| The riskiest 30% of visits | contain **52%** of all abandons |

This is a moderate score, and we say so. It uses only what is known at the first pick. The live version would also watch what happens next, the seconds since the last pick and whether a price moved, which is where most of the signal lives.

What the score is used for: deciding who sees the resume card and who gets the pre-filled stake. **It is never used to interrupt, notify or hurry anyone.**

The glass-box version reads out its own reasoning. Factors that make abandonment **less** likely: the pick came from a live match page, the person has tickets running, they were following live matches before picking. Factors that make it **more** likely: the pick came from bet history or an "after bet" prompt or the home widget, and basketball or combat sports picks. Every one of those can be explained to a colleague in a sentence.

### The intelligence behind it
| Piece | Method | Why it is explainable |
|---|---|---|
| Pre-validation | Rules, checked against the live odds feed (the `EPS_Offers` file shows this feed exists) | Rules |
| Risk score | Logistic model, a readable sum of simple parts | Prints its reasons |
| Monitoring | Daily acceptance rate per app and bet type, with automatic alert on a drop | The Android problem would have been caught in days, not found by accident months later |

### Business intelligence dashboard for this POC
1. Acceptance rate per app per bet type, daily, with an alert line. **This chart alone justifies the POC.**
2. Final-step conversion: added a pick, placed it, was accepted. Three bars per app.
3. Abandon rate and **recovery rate**: of abandoned slips, how many were placed from the resume card.
4. Time from first pick to placement, the "thinking time", which should not get shorter. If it does, we are pressuring people.
5. Share of abandons where a price moved in between, once the odds feed is joined.
6. Harm-flagged visit share, which must not rise.

### The business case (sportsbook, all Croatian customers)

| Piece | Assumption | Working | Stake per month |
|---|---|---|---|
| Android fix | Only about 4% of failing visits end without an accepted ticket (15 of 358 in the sample), so direct recovery is small | 447,046 × 35% × 37% × 15% failing × 4% lost ≈ 350 visits | **≈ €9,000** (the real value is friction, counted in SQI) |
| Slip that survives | 40% of visits reach the slip, 19% abandon, and we recover **one abandoner in five** beyond those who already come back on their own | 447,046 × 40% × 19% × 20% ≈ 6,800 extra converting visits | **≈ €172,000** |
| Total | | | **≈ €181,000 per month, ≈ €2.2M per year** (range €1.5M to €2.5M) |

Same note as before: earnings are roughly a tenth of stake. The Android fix is different in kind from everything else here: it is not a bet on user behaviour changing, it is a defect at the moment of highest intent. We first estimated it as lost money; the retry analysis showed users fight through it, so we moved it to the friction column. We would rather correct that ourselves than have it found.

---

# How we prove it, and how we prove we did no harm

Both POCs are tested the same way: half the users get the new version, half keep the current one, and we compare. Nothing else is credible.

| Measure | Role | Pass condition |
|---|---|---|
| Session Quality Index | Primary | Higher in the new version |
| Final-step conversion | Primary | Higher |
| Session conversion, per kind of visit | Secondary | Higher for browsing kinds. **Unchanged for ticket-check kinds**, because we are not trying to make those people bet |
| Time to first action | Secondary | Lower |
| Value per visit | Secondary | Higher |
| **Harm-flagged visit share** | **Guardrail** | **Must not rise. If it does, the idea fails regardless of everything else** |
| Visits per person | Guardrail | Must not rise |
| Thinking time from first pick to placement | Guardrail | Must not shorten |
| Still active at 30 and 90 days | The real test | Higher, or at least not lower |

On 30 and 90 day retention: the data we were given covers one month, so we cannot compute it yet. We have designed for it, and the customer IDs do persist across months in the spending files, so it is measurable once FEG shares more history.

---

# What the evaluators would see in a five-minute demo

1. A real August visit replayed tap by tap. After three taps the intent detector says "ticket check, 83% confident" and the home screen reorders to show the ticket with the live score in the list. The visit ends in 9 seconds. Its Session Quality Index is 88. Under today's measurement it was a failure.
2. A second visit: three picks added on Android, submitted, rejected. The Betslip Guardian version shows the price change side by side, one tap, accepted. Then the dashboard: the Android acceptance line, and what it would have looked like with the fix.
3. A third visit: picks added, app closed after 6 seconds. Next open, 40 minutes later: the resume card. One tap. Placed.
4. The harm panel: a 3am marathon visit. Every feature above is switched off. The plain app. The guardrail line on the dashboard, flat.

---

# Why these two, and not the other eight ideas

The other ideas in `ideation.md` are real, and several are cheap. But evaluators asked for two problems with proof. These two were chosen because:

- **The evidence is strongest.** A 17-point acceptance gap between two apps and a 24% share of visits that were never trying to bet are not subtle findings.
- **They cover the challenge's whole span.** Problem 1 is discovery, relevance, real-time guidance and measurement. Problem 2 is the final step. Between them, all five innovation areas.
- **Part of each is already working.** The intent detector and the risk score exist and have been tested on real data. The rest is engineering, not research.
- **One of them is a pure friction fix.** The Android rejection loop has no behavioural assumptions in it at all, and removing it needs no model.
