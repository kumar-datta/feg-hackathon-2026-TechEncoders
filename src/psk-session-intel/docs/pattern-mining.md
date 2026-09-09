# Data cubes and pattern mining on PSK app sessions

A research note. What we built, which algorithms we ran, what they found, and what each finding means for the four kinds of "browsing" in the problem framing. Every number is reproducible from `analysis/09_cubes.py`, `10_pattern_mining.py`, `11_prefix_ngrams.py` and `12_deferred_fixture.py`; outputs are in `analysis/out/`.

Data: 16,095 native-app visits from 113 heavy users, August 2026, plus all-customer betting rows (`SB_Player`, 15,738 customers, 16 to 31 August) and monthly market totals (`SB_MOM`). Terms are in [glossary.md](glossary.md).

---

## 1. The question we are actually answering

"Sessions end in browsing" hides four different situations, and each wants a different fix:

| Intent type | What the person is doing | What would help |
|---|---|---|
| **A. Undecided** | Researching, does not know what to bet on yet | Relevance, context at the decision point |
| **B. Decided, cannot find it** | Knows what they want, the entry point is buried | Search, shortcuts, adaptive layout |
| **C. Decided, hesitating** | Pick in the slip, will not confirm | Clarity at the final step, a slip that survives |
| **D. No intent today** | Habitual open, checking a score or a ticket | Speed, and not being treated as a conversion target |

A single funnel cannot tell these apart. So the first job was to build cubes that can be sliced by *kind of visit* and *kind of customer*, and then mine them for the paths that separate the four.

---

## 2. The cubes

Each cube is a flat CSV with every dimension as a column, so it can be pivoted in any tool.

| Cube | Dimensions | Measures | Rows |
|---|---|---|---|
| `cube_session` | platform × kind of visit × customer breadth × hour band × weekday/weekend × visit index in day | visits, customers, conversion, reach-final, final conversion, actions, adds, median time-to-action, median length, single-event share | 1,325 |
| `cube_funnel` | platform × entry source of the first pick × number of picks × breadth × hour band | visits reaching the slip, placed rate, accepted rate, median time-to-first-pick | 120 |
| `cube_time` | day × hour × platform | visits, customers, conversion, actions, visits over two hours | 2,137 |
| `cube_casino` | page × element tapped × demo/real × studio | launches, customers, repeat share, distinct games | 119 |
| `cube_market` | sport × live/prematch × bet type (all customers) | bets, stake, customers | 3,231 |
| `cube_mom` | month × sport × bet type (market totals) | tickets, stake, fixtures | 6,807 |

**A customer-breadth dimension as a tenure proxy.** We have no sign-up dates, so "first-time visitor versus ten-year specialist" cannot be measured directly. The closest signal in the data is *repertoire*: how many distinct bet types a customer used in 16 days. We cut the 127 log users with sportsbook rows into terciles:

| Breadth | Distinct bet types (median) | Bets in 16 days (median) | Live share |
|---|---|---|---|
| Focused | 5.5 | 67 | 36% |
| Mid | 21 | 260 | 50% |
| Broad | 82 | 437 | 45% |

Among *all* 15,738 customers, 31% used three or fewer bet types and produced 5% of stake; 17% used more than thirty and produced 44%. The "generic layout" problem is real at both ends: novices are drowning in markets they never use, specialists are scrolling past them.

---

## 3. Methods

| Method | What it does | Settings |
|---|---|---|
| **n-gram sequence mining** (§4.1) | Counts every pair and triple of consecutive screens; compares how often each appears in visits that reach a pick versus those that do not. Run on the *pre-action prefix only*, so action events cannot leak into the lift | min support 2%, consecutive duplicates collapsed |
| **PrefixSpan** (§4.2) | Finds frequent *gapped* sequences (A, then later B, then later C), the standard algorithm for sequential patterns | min support 5%, max length 4, own implementation |
| **Absorbing Markov chain** (§4.3) | Treats screens as states and "action" and "exit" as absorbing ends; solves for the probability of reaching an action from every screen, expected steps remaining, and the entropy of each screen's next-step distribution (a confusion measure) | states with ≥30 visits, per platform |
| **Apriori association rules** (§4.4) | Finds combinations of visit attributes that predict an outcome, with support, confidence and lift | itemsets up to size 3, min support 1%, min 30 visits per rule |
| **Intent taxonomy** (§5) | Rule-based assignment of every sportsbook visit to A/B/C/D using screens seen, picks added, search use and length | see §5 |
| **Fixture-level cross-session tracking** (§6) | Follows the match a person abandoned to see whether they bet on it later | player × fixture join across visits |
| **Chasing proxy** (§7) | Pick added within 60 seconds of placing a ticket | per visit, per player |

---

## 4. Results

### 4.1 Which paths lead to a pick, and which lead nowhere

Lift is the reach-a-pick rate of visits containing the path, divided by the base rate (iPhone 48.7%, Android 42.1%).

**Paths that lead nowhere (lowest lift):**

| Platform | Path | Share of visits | Reach a pick | Lift |
|---|---|---|---|---|
| iPhone | account web page → homepage → my account | 2.6% | 15% | 0.30 |
| iPhone | account web page → homepage | 4.0% | 22% | 0.45 |
| iPhone | homepage → my account | 13.7% | 36% | 0.73 |
| iPhone | homepage → ticket history | **41%** | 40% | 0.82 |
| iPhone | ticket history → ticket detail → ticket history | 25% | 42% | 0.86 |
| Android | unnamed start → ticket history | **44%** | 28% | 0.65 |
| Android | account → account web view → account | 2.1% | 27% | 0.64 |
| Android | ticket history → ticket detail → ticket history | 23% | 28% | 0.67 |

**Paths that lead to a pick (highest lift):**

| Platform | Path | Share | Reach a pick | Lift |
|---|---|---|---|---|
| iPhone | matches overview → match detail | 13.8% | 87% | 1.78 |
| iPhone | leagues → matches overview → match detail | 13.2% | 87% | 1.78 |
| iPhone | live list → live match | 25.5% | 77% | 1.58 |
| iPhone | my account → live list → live match | 2.1% | 91% | 1.88 |
| Android | competition → match detail | 11.9% | 85% | 2.01 |
| Android | account → live list | 2.1% | 93% | 2.21 |
| Android | leagues → competition → match detail | 11.2% | 85% | 2.02 |

Reading: the moment a person reaches a *match detail* page, the visit is very likely to produce a pick. The cost is everything before that. The deposit web page is a dead end: three in four people who bounce from it back to home leave without a pick. And the single most common opening move on both apps, straight to ticket history, is below base rate. Notably, "account → live list" has the highest lift of all: people who deposit and then go to live matches almost always bet. The deposit page should hand people to the live list, not back to home.

### 4.2 Frequent gapped sequences (PrefixSpan)

**Non-converting iPhone visits, n = 4,018.** The top four patterns, covering 19 to 25% of these visits each, are all permutations of *homepage … ticket history … ticket detail … ticket history*. The first non-ticket pattern, at 13%, is *homepage … sports … leagues … matches overview*: a research visit through the prematch tree that never produced a pick. That is intent type A, and it is a minority.

**Converting iPhone visits, path before the first placement, n = 2,122.** The top patterns are *ADD … leagues … matches overview … ADD* (35%) and *ADD … live match … ADD … betslip* (33%). People assembling a multi-pick ticket navigate the league tree between every pick. The "hunt" is not before the first pick, it is *between* picks. A "add another from this league" shortcut on the betslip would remove most of these steps.

**Android** shows the same shapes: non-converting visits are *unnamed start … ticket history … ticket detail* (25%); converting visits are *leagues … competition … ADD* (43%) and *live list … live match … ADD* (41%).

### 4.3 Conversion potential of every screen (absorbing Markov chain)

For each screen: the probability that a visit currently on that screen reaches an action before leaving, the direct exit rate, and the entropy of what people do next (higher = more scattered).

| iPhone screen | Visits | P(reach action) | Direct exit | Next-step entropy (bits) |
|---|---|---|---|---|
| Betslip | 7,336 | 0.54 | 1.8% | 3.11 |
| Match detail | 10,295 | 0.43 | 1.1% | 2.11 |
| Matches overview | 21,283 | 0.42 | 0.6% | 2.06 |
| Leagues | 15,776 | 0.42 | 0.6% | 1.17 |
| Live match | 18,530 | 0.38 | 1.1% | 2.46 |
| Ticket detail | 16,195 | 0.34 | 5.5% | 2.36 |
| Homepage | 9,805 | 0.34 | 6.2% | 2.69 |
| Ticket history | 15,130 | 0.34 | 4.2% | 1.57 |
| Account web page | 2,858 | 0.34 | **11.6%** | 2.37 |
| Menu | 193 | 0.32 | 9.3% | 2.93 |

| Android screen | Visits | P(reach action) | Direct exit | Entropy |
|---|---|---|---|---|
| Match detail | 9,194 | 0.39 | 0.3% | 1.83 |
| Competition | 22,115 | 0.37 | 0.4% | 1.88 |
| Leagues | 15,750 | 0.37 | 0.9% | 0.92 |
| Live match | 8,320 | 0.33 | 1.3% | 2.21 |
| Unnamed screen | 19,515 | 0.31 | **11.5%** | **3.50** |
| Ticket detail | 9,771 | 0.26 | 9.0% | 2.27 |
| Ticket history | 10,207 | 0.26 | 7.7% | 1.62 |

Three things stand out. The **betslip has the highest entropy on iPhone** (3.1 bits): after adding a pick, people scatter in every direction, which is where a clearer "you are one tap away, here is your payout" summary belongs. The **Android unnamed screen** has both the highest exit rate and the highest entropy, and it is 19,500 visits: an instrumentation hole that hides the real dead end. And the **casino search screen** reaches an action with probability 0.965 in 1.1 expected steps: the fastest path anywhere in either app.

### 4.4 Attribute rules (Apriori)

Outcome base rates on sportsbook apps: no action 59%, converted 33%, abandoned at the final step 7.7%.

| Rule | Visits | Confidence | Lift |
|---|---|---|---|
| exactly one pick added → abandoned | 603 | 45% | 5.8 |
| one pick & iPhone → abandoned | 295 | 54% | 7.0 |
| one pick & live screens used → abandoned | 498 | 39% | 5.0 |
| browsing-kind visit & 30 s to 5 min & iPhone → abandoned | 297 | 39% | 5.0 |
| two or three picks & first screen homepage → abandoned | 326 | 37% | 4.8 |
| focused customer & unnamed start & under 30 s → no action | 410 | 100% | 1.7 |
| account-kind visit & under 30 s → no action | 403 | 100% | 1.7 |
| marathon-kind visit & evening → converted | 449+ | 100% | 3.0 |

The strongest signal in the whole rule set is **a single pick**. Nearly half of visits with exactly one pick end without placing, seven times the base rate on iPhone. The funnel cube agrees: with one pick, placement rates are 70% from a live page, 55% from a prematch page, 47% from a widget, and **2% when the pick came from bet history**. That last number says the "re-bet" control on old tickets is producing accidental or exploratory picks that nobody intends to place. It should not count as intent, and it should not fire the final-step flow.

---

## 5. The four intent types, quantified

Rules: a visit is **converted quick** if it acted after seeing fewer than four market screens and within three minutes of its first pick; **converted after a hunt** otherwise; **C, hesitating** if a pick was added and nothing placed; **A, undecided** if no pick, three or more distinct market screens, and at least a minute; **B, cannot find** if search was used and no pick followed; **D, no intent today** otherwise.

| | Android | iPhone |
|---|---|---|
| D · No intent today | **59.6%** | **50.4%** |
| Converted after a hunt | 16.9% | 20.7% |
| Converted quick | 14.7% | 13.9% |
| C · Decided, hesitating | 5.2% | **10.8%** |
| A · Undecided research | 3.5% | 3.9% |
| B · Decided, cannot find (as a failure) | 0.1% | 0.2% |

Three corrections to the intuitive picture:

1. **Type D dominates.** Half to three-fifths of visits were never going to bet. On focused customers it is 69%; at night, 64%. Any measure that counts these as failures will drive the product toward pressure.
2. **Type A is small.** Genuine "I browsed and could not decide" is under 4% of visits. Research sessions exist, but they are not the bulk of browsing.
3. **Type B does not show up as a failure. It shows up as cost inside conversions.** People who search almost always find and pick, so "searched and gave up" is near zero. But the hunt is visible elsewhere: the median visit sees **7 screens before its first pick**, a quarter see 13 or more, and only **20% pick within three screens**. Converted-after-hunt outnumbers converted-quick on both platforms. The right measure of type B is *path length to first pick*, not a failure class.

Type C is twice as common on iPhone as Android (10.8% vs 5.2%), consistent with the earlier final-step finding.

---

## 6. Intent survives across visits, at the level of the match

For 912 abandoned sportsbook visits with a known match: **34.8% of players later placed a bet on one of the exact matches they had abandoned** (iPhone 38.8%, Android 29.5%). Typical delay 3.3 hours; only 17% within the hour, but **94% within 24 hours**.

Looking from the other side: 5.1% of all placed matches had first been added to a slip in an *earlier* visit, with a median research span of 4.1 hours. And 17% of player-match pairs were bet on in more than one visit.

This is the evidence for "continue where you left off". The abandoned pick is not noise: one time in three it is the same bet, placed hours later, after the person has had to find the match again from scratch. A slip that survives the visit, with a neutral "prices have moved" note, removes that re-entry cost. The 24-hour horizon also says the slip should persist for a day, not an hour, and that nothing needs to be "urgent" about it.

---

## 7. Guardrail-relevant patterns

**Quick re-bet.** 28% of visits with a placement add another pick within 60 seconds of placing. By kind of visit: marathon 51% (3.8 per visit), browsing 16%, live-follow 7%. 23 of 66 frequent bettors do it in more than 30% of their visits. We cannot tell from this data whether it is ticket-building (several singles on one match, common in Croatian betting), or chasing. It needs ticket outcomes to calibrate. Until then it is a *watch* signal, and the harm layer treats a visit that combines it with marathon length and night hours as flagged.

**What must not be optimised.** The Apriori rules show that the easiest way to lift raw conversion would be to encourage the marathon pattern, which converts at 100%. The Session Quality Index caps those visits precisely so no optimiser can learn that.

---

## 8. A correction to an earlier claim

Earlier documents described the Android rejection problem as lost bets. The retry anatomy shows otherwise: of 2,398 Android visits with a placement, 358 (15%) hit at least one rejection, but only **15** ended without an accepted ticket. Typical sequences are "rejected → accepted" and "closed → accepted". The defect costs 1,103 failed attempts a month in this sample, plus the time and trust that go with them, not the bets themselves. The POC plan and findings have been corrected; the fix is still the cheapest in the portfolio, and it now sits in the friction column rather than the money column.

---

## 9. Where the money sits: market concentration

All customers, 16 days: **20 bet types account for 80% of bets** out of 32,981 offered. **1,002 matches out of 30,400** carry 80% of bets; the top 1% of matches carry 67%. 67 competitions out of 1,181 carry 80%. The monthly totals show the same twenty bet types at 80% in June, July and August.

For a focused customer (five bet types in use), the current layout presents roughly 6,000 times more market variety than they touch. An adaptive layout that leads with the twenty core markets for focused customers, and exposes the long tail to broad ones, is not guesswork: the data says who uses what.

Casino confirms the same shape from the other side: launches from the search page are **95% repeat games**, from "my games" 98%, from the lobby grid only 52%. Search in the casino is not discovery. It is the shortcut people use because the game they want is buried, which is type B in its purest form.

---

## 10. What the data cannot tell us, and what research should add

- **No search query text.** We see that search was used, not what was typed. Zero-result query mining, the classic unmet-intent signal, needs the query strings.
- **No ticket outcomes.** We cannot separate chasing from ticket-building, or say whether people re-bet after a loss.
- **No odds at the moment of the pick.** The odds feed exists (one day) but has no match ID matching the logs. Whether the price moved while someone hesitated is the top open question for type C.
- **No reason for rejections**, so the Android defect is inferred, not observed.
- **No tenure**, so breadth stands in for it. A sign-up date column would replace the proxy.

Qualitative work that would resolve the remaining ambiguity: an exit-intent micro-survey shown only after a pick is added and the app is backgrounded, with four options and free text; think-aloud sessions with focused and broad customers at the moment of a first pick; and a diary study on habitual openers to separate "the session is the entertainment" from "the session is supposed to end in a bet".

---

## 11. Related work

Pointers for the write-up, to be verified against the originals:

- Agrawal and Srikant, 1994, *Fast algorithms for mining association rules* (Apriori).
- Pei et al., 2001, *PrefixSpan: mining sequential patterns efficiently by prefix-projected pattern growth*.
- Montgomery, Li, Srinivasan and Liechty, 2004, *Modeling online browsing and path analysis using clickstream data*, Marketing Science (Markov path models of purchase).
- Li, Huffman and Tokuda, 2009, *Good abandonment in mobile and PC internet search*, SIGIR. The notion that a session ending without an action can be a successful session, which is the basis for our treatment of type D.
- Hidasi et al., 2016, *Session-based recommendations with recurrent neural networks* (GRU4Rec), for the later recommender stage.
- Braverman and Shaffer, 2012, *How do gamblers start gambling: identifying behavioural markers for high-risk internet gambling*, European Journal of Public Health, for the harm indicators.
- Kohavi, Tang and Xu, 2020, *Trustworthy Online Controlled Experiments*, for the holdout design.

---

## 12. Reproduce

```bash
cd analysis
python 09_cubes.py            # cubes + breadth segment      -> out/cube_*.csv, player_breadth.csv
python 10_pattern_mining.py   # PrefixSpan, Markov, Apriori, intent, chasing, retries
python 11_prefix_ngrams.py    # n-grams on pre-action prefixes -> out/prefix_ngram*.csv
python 12_deferred_fixture.py # cross-session intent by match
```
