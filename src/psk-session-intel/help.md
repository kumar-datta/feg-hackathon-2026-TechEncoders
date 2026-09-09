# help.md — how every number was worked out

This file exists so anyone can check our work. For each measurement: what it means, which file it came from, exactly how we calculated it, the judgement calls we made, where we stand today, and what could be wrong with it.

Unfamiliar terms are explained in [docs/glossary.md](docs/glossary.md).

Unless we say "all customers", every number describes our 113 heavy users in August 2026.

---

## Part A — Cleaning the data

Before measuring anything, eight problems had to be fixed. Skipping any of them would have produced wrong answers.

| # | The problem | What we did | Why it mattered |
|---|---|---|---|
| A1 | Two separate files, one for casino users and one for sports users | Joined them, tagged each row with which file it came from. Six people appear in both. | Same structure, and we need one combined picture. |
| A2 | Missing values written two different ways. The casino file writes the word "null". The sports file leaves it empty. | Treated both as missing. | Otherwise the word "null" gets counted as if it were a real screen name. |
| A3 | Two date formats in the same dataset | Converted both to a single standard, then to Croatian local time for anything involving the hour of day. | Without this, hour-of-day analysis is meaningless. |
| A4 | Websites mixed in with apps | Marked the three apps separately. Websites kept only as a comparison column. | The challenge is about the apps. |
| A5 | Screen names stored in three different columns depending on the app | Built one combined column, taking whichever was available. | So the three apps can be compared side by side. |
| A6 | Android records every screen twice, once blank and once named, a fraction of a second apart | Gave the blank record its neighbour's name when they were within 2 seconds. What is left over is labelled "unnamed". | Without this fix, the blank record was the top result in every single analysis and hid the real behaviour. |
| A7 | Two definitions of "a visit" exist | Used the ID already in the data. We checked it: 28% of visits contain a gap over 15 minutes and 3% over 30, so it ends a visit after about 30 minutes of inactivity. The monthly sheets use a different rule, 15 minutes since the last bet. | These give different answers. We always say which one a number uses. |
| A8 | 94 visits show more than one customer ID | Kept them, used the first ID. Probably a shared phone. | It is 0.3% of visits, too small to change anything. |

---

## Part B — The six measurements the challenge asks for

### B1. Session Conversion Rate — what share of visits end in something real

**In plain words:** out of 100 visits, how many ended with the person actually placing a bet or opening a casino game?

**How we calculated it:** we look at every visit and ask whether it contains at least one bet placement or one game launch. Then we count what share of visits pass.

**Judgement calls we made:**
- One bet slip counts as one action, even if it has six picks on it. There is a separate record for each pick, and counting those would inflate the number.
- Opening a free demo game counts, because trying a game before risking money is a sensible, informed thing to do. It is 14% of casino launches and we report it separately so it can be excluded.

**Where we stand:** iPhone 35%, Android 32%, casino 74%, website 28%. **Across all customers, 24%.**

**What could be wrong:** our 113 users are heavy users, so their rate is flattered. Set targets against the 24%.

---

### B2. Final-step Conversion — of the people who nearly bet, how many finished

**In plain words:** someone has put a pick in their slip. They are one tap away. What share go through with it?

**How we calculated it:** among visits containing at least one "pick added", what share also contain a "bet placed".

**Judgement calls we made:**
- We do not require them to have opened the betslip screen, because Android does not reliably record that. Requiring it would make Android look artificially bad.
- We also measure separately whether the bet was *accepted*, because a placed bet that the system rejects is a completely different problem from a customer changing their mind. This distinction is what uncovered the Android bug.

**Where we stand:** iPhone 76%, Android 86%, website 85%. And once placed, acceptance rates are: Android single bets **83%**, Android multiples 95%, iPhone single bets **99.5%**, iPhone multiples 99%.

**What could be wrong:** "pick added" also fires when someone re-bets from their history, and those behave differently, converting at only 68%. So always split by where the pick came from.

---

### B3. Time to First Action — how long before anything happens

**In plain words:** from opening the app, how long until the person does the thing they came for?

**How we calculated it:** seconds from the first recorded event to the first bet or game launch. We use the **median**, the middle value, because a few very long visits would distort an average. We also measure time to first *pick added*, which shows how long finding something takes as opposed to deciding.

**Where we stand:** iPhone 8.6 minutes, Android 5.6 minutes, casino 37 seconds. Time to first pick is only about 100 seconds, meaning **most of the wait is between adding a pick and placing it, not finding something**. Across all customers, 6.3 minutes to a first bet, and 55 seconds to a first casino game against 28 seconds on the website.

**What could be wrong:** visits where someone only wanted to check a ticket have no action at all and no meaningful timing. So we measure this only on visits that converted, and report the share that never acted as its own number.

---

### B4. Actions per Session — how much gets done in a visit

**In plain words:** on average, how many bets or games per visit?

**Where we stand:** iPhone 1.7, Android 1.3, casino 4.4. Counting only visits that converted: 4.9, 4.2 and 5.9.

**What could be wrong:** the marathon group, 12% of visits, averages nine bets each and drags the average up. If this is ever used as a target, use the median or cap the extremes, otherwise the easiest way to hit the target is to encourage marathons. That would be the opposite of what the challenge wants.

---

### B5. Sessions per User — how often people come back

**Where we stand:** 130 visits per person per month on the sports apps, 89 on casino. Five to six visits per person per day. The typical gap between visits is 82 minutes, and 39% of visits start within an hour of the last one. Across all customers it is 24 visits a month.

**What could be wrong, and it is important:** **this number should not be a target.** The challenge says explicitly not to push anyone to do more than they want, and visits showing signs of harm must not increase. Someone opening the app 130 times a month is not obviously a success story. We report this number, we watch it, and we aim at value per visit instead.

---

### B6. Value per Session — what a visit is worth

**In plain words:** how much money does an average visit involve?

**How we calculated it:** we took each person's total stake for a day from the spending files, and divided it by how many app visits they had that day. About 7 in 10 person-days matched a spending record.

**Where we stand:** typical €93.50 per visit. Crucially it stays flat, between €80 and €120, whether someone visits twice a day or nine or more times, even though their daily total rises. Across all customers, €25.30 per sportsbook visit, up 18% since March. PSK casino is €343 per visit, the highest of any FEG market.

**What could be wrong, and it matters:** stake is not the same as value to the user. A visit where someone checked their bet and left satisfied has real value and zero stake. This is why we propose recording non-money actions such as cash-outs, following a match and setting notifications. Also, the spending files include money spent through the website, so our per-visit figure is an overestimate.

---

## Part C — Extra measurements we added

The six above do not explain *why* anything happens. These do.

| Measurement | What it means | What it told us |
|---|---|---|
| **Reach-the-final-step rate** | Share of visits that got as far as adding a pick | Separates two totally different problems: people not finding anything worth betting on, versus people finding something and then not finishing |
| **Length buckets** | Conversion split by how long the visit lasted | Under 30 seconds converts almost never, and those are a quarter of all visits |
| **Exit screens** | The last screen before leaving | Shows exactly where visits die |
| **Time spent per screen** | Typical seconds before moving on | Slow screen plus lots of exits equals a problem screen. The account web page is 22.6 seconds, by far the worst |
| **Loops** | Going A to B and straight back to A | 42,000 times between the live list and a live match. The list is not telling people what they need |
| **Ticket-only visits** | Visits that only touched ticket and account screens | A quarter of iPhone visits, none convert, and betting was never the intention |
| **Deferred intent** | After abandoning, does the person come back and bet? | 40% return within the hour, 39% bet next visit. Intent survives, the slip does not |
| **Kinds of visit** | Sorting all visits into natural groups | The seven archetypes, our central finding |
| **Harm indicators** | Night play, very long visits, rapid reopening, bet size trend | Our simple rule flags 64 of 113 users, which is too many. It proves thresholds alone are too blunt and a properly calibrated approach is needed |
| **Session Quality Index** | A single 0 to 100 score for whether a visit was good *for the user* | Proposed, not built. Described below |
| **Moving averages** | Smoothed trend lines | Removes daily noise. August conversion drifted up from 36% to 40% |

### About the Session Quality Index

The challenge asks for better ways to measure session quality. Here is ours.

A visit scores out of 100, built from four parts: did the person complete something they intended, how quickly did they get there, how much friction did they hit such as loops and rejections, and did they encounter anything relevant they had not seen before. Then a harm penalty is subtracted, and any visit showing harm signals is capped low no matter how much money it involved.

The value of a single score is that every automatic decision in our proposals can be judged against it. And because harm caps the score, **no system optimising for it can ever learn that pressure works.** That property is the point.

---

## Part D — Questions we need FEG to answer

1. Exactly how long is a visit in the event logs? We measured about 30 minutes, but the monthly sheets use 15 minutes since the last bet. Which is official?
2. What do "closed" and "rejected" mean on a placed bet? Market shut, odds moved, limit hit? **This is our most important question**, because 17% of Android single bets fail this way against under 1% on iPhone.
3. Why does the Android app leave about 40% of screens unnamed?
4. Do cash-out, favourite, follow and notification events exist anywhere? We need them to measure value that is not money.
5. Can we see responsible-gambling information, such as who has set limits or self-excluded? Without it our harm detection can only be simple rules.
