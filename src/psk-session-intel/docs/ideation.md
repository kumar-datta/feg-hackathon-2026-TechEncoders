# Proposed solutions

Ten ideas, ranked by how strong the evidence is against how hard they are to build. The first five are what we recommend building.

Every idea follows the same shape: what the data showed, what we would build, which number it moves, and how we keep it safe.

Terms explained in [glossary.md](glossary.md). Evidence in [findings.md](findings.md).

---

## The shortlist at a glance

| # | Idea | Why we believe it | Number it moves | Difficulty |
|---|---|---|---|---|
| 1 | Measure visits by what the person came to do | Half of "failed" visits were never trying to bet | A new, honest way to measure everything | Medium |
| 2 | Fix the Android bet rejection bug | 17% of Android single bets fail vs under 1% on iPhone | Final-step conversion, roughly +8 points | **Easy** |
| 3 | Keep the betslip alive between visits | 40% of abandoners return within the hour | Final-step conversion, time to action | Medium |
| 4 | Put search in front of people | Used in 1-3% of visits, converts twice as well | Conversion, time to action | Medium |
| 5 | Make ticket-checking visits useful | A quarter of visits, none convert, endless loops | Value per visit, long-term retention | Medium |
| 6 | Home screen that adapts to intent | First visit of the day converts worst | Time to action | Harder |
| 7 | Replace "popular" suggestions with relevant ones | Popularity widgets convert worst at 56% | Final-step conversion | Harder |
| 8 | Show key info in the live list | 42,000 pointless round trips | Actions per visit | Medium |
| 9 | Casino "carry on where you left off" row | 87% of games played are repeats | Time to action | Easy |
| 10 | Harm-aware safety layer | Applies to all of the above | The guardrail | Medium |

---

## 1. Measure visits by what the person came to do

**What the data showed.** We sorted 16,000 visits into natural groups and found seven kinds. Over half are visits where betting was never the goal: checking a ticket, a quick glance, account admin.

**The problem with how it is measured today.** Someone opens the app, checks whether their bet won, sees that it did, and closes the app satisfied in eleven seconds. Today that counts as a failure. It was a perfectly good visit.

This matters more than it sounds. If you measure it as a failure, every improvement you try will be aimed at making that person bet. That is precisely the pressure the challenge forbids. **Measuring it wrong pushes you towards dark patterns without anyone intending it.**

**What we would build.** Work out within the first few taps what kind of visit this is. Report every measurement separately for each kind. And score each visit with the Session Quality Index described in help.md, which asks whether the visit was good *for the user*, with a penalty for harm signals.

**Why it goes first.** Every other idea gets judged against this. Getting it wrong means optimising for the wrong thing, very efficiently.

---

## 2. Fix the Android bet rejection bug

**What the data showed.** When someone places a single bet on Android, it succeeds 83% of the time. On iPhone, 99.5%. Same people, same matches, same month. In August alone, 642 came back "closed" and 451 "rejected".

**What is probably happening.** The odds changed, or the market closed, between the person tapping and the app submitting. The iPhone app appears to handle this gracefully. The Android app does not.

**What we would build.**
- Check the bet is still valid before submitting, not after.
- If the odds moved, show the old and new price side by side with one tap to accept. Not a warning, just the facts.
- If the market closed, keep the slip and offer the same pick in the next available market.
- Let people set once: "accept small odds changes automatically".
- Record why every rejection happened, so nobody has to do detective work again.

**What it is worth.** Android final-step conversion should go from 86% to about 93%, matching iPhone. No machine learning, no design risk, no responsible-gambling concern. **This is the highest return for the least effort in the entire analysis.**

---

## 3. Keep the betslip alive between visits

**What the data showed.** One in five visits that add a pick never place it. On iPhone people close the app 43 seconds after their last pick, a quarter within 5 seconds. That is interruption, not deliberation. And it is confirmed by what happens next: 40% come back within the hour, and 39% place a bet in their next visit.

**They did not change their minds. They lost their slip.**

**What we would build.** The slip survives between visits. Next time they open the app, a calm card says "your slip, 3 picks" and shows what changed, such as one price moving or one match having started. Information, not persuasion.

**What we deliberately would not build.** No countdown. No "hurry". No push notification. No "your bet is waiting for you!". The card sits there, and is easy to dismiss.

**The clever part.** A model watches the visit and works out when someone is drifting away, using things like how many picks they have added, how long since the last one, and whether the odds moved. But **the score is only ever used to be more helpful**, by surfacing the slip and pre-filling the person's usual stake. It is never used to interrupt or pressure. And it must be a model that explains itself: "three picks added, forty seconds idle, one price moved".

---

## 4. Put search in front of people

**What the data showed.** Search appears in 3.4% of iPhone visits and 1.1% of Android ones. Those visits convert at 71% and 79%, against 33% and 31%. Roughly double. In the casino app, search is already the single biggest way people find a game, ahead of the main grid.

**The conclusion.** People who find search do far better. Almost nobody finds it. The content is fine, the way in is buried.

**What we would build.** A visible search bar on the home screen of both apps. It suggests as you type, across matches, teams, players, bet types and casino games. It handles Croatian and English, and everyday phrasing rather than official names. Every result says why it matched, for example "Serie A, which you bet on often".

**How it works underneath.** Two search methods combined: traditional keyword matching, which is exact and fast, and meaning-based matching, which handles "Dinamo game tonight". Results are then ordered using what this person has bet on before. All of it can be shown to the user as a plain reason.

---

## 5. Make ticket-checking visits useful

**What the data showed.** A quarter of iPhone visits are pure ticket checking. They convert at 2%. And they loop: 33,000 round trips between the ticket list and ticket detail, because the list does not show what people need so they have to open each one.

**What we would build.** Put the live state directly in the list. Score, minute, which of your picks have already come in, and the cash-out value if there is one. The loop disappears because the answer is already on screen.

Then offer things to do that are not betting: follow this match, tell me when it finishes, see the stats. These are real value, and today we cannot even measure them because nothing records them.

**Success here looks unusual.** These visits should get **shorter**, not longer. Someone getting their answer in eight seconds instead of forty is a better experience. This is why idea 1 has to come first, otherwise this looks like a failure on every standard measure.

**The line we will not cross.** No suggestion to bet again after a loss. No "win it back". Nothing that turns checking a losing ticket into a prompt to place another one.

---

## 6. A home screen that adapts to intent

**What the data showed.** On iPhone, the most common thing after opening is going straight to ticket history, 47% of the time. And a person's first visit of the day converts worst, 34%, rising to 44% by their fifth.

**What we would build.** After a couple of taps, or based on the last visit and the time of day, reorder the home screen. People who came to check get their tickets at the top. People who follow live games get the live list. Always with a line saying why it is ordered that way, and always with a way back to the standard layout.

---

## 7. Replace "popular" with "relevant"

**What the data showed.** Picks made from a live match page get placed 88% of the time. From match detail, 83%. But from the "most bet matches" widget, only 56%. **The popularity-based suggestions are the worst performers in the app.**

**What we would build.** Suggestions based on what this person actually follows, not what is generally popular. Each card states its reason: "Serie A, you bet on it most weeks".

---

## 8 and 9. Live list and casino continue row

**Live list.** The 42,000 round trips happen because the list omits what people need. Put the one or two bet types this person usually takes directly in the list row.

**Casino.** 87% of games launched are repeats, and the typical person plays 17 different games. So the first thing on screen should be the last five games they played, then a small row of genuinely similar ones. When a visit starts on "my games" or search, the first game opens in 6 seconds instead of 45.

---

## 10. The safety layer, which sits over everything above

**Not a feature. A condition on all of them.**

Every visit gets a harm score, from signals we can already see: playing through the night, going past two hours, reopening the app minutes after closing, bets getting bigger, and betting again within a minute of losing.

When a visit is flagged, **everything above switches off.** No personalisation, no slip resume, no suggestions. The plain app, plus the responsible-gambling tools.

We start with simple written rules rather than a model, because rules can be read and audited by anyone. Note our honest finding: a naive rule flags 64 of our 113 heavy users, far too many to act on. That tells us thresholds alone are too blunt and this needs proper calibration with FEG's own responsible-gambling data.

**How we prove we did no harm.** Every test reports the share of flagged visits in both groups. If our version has more, the idea has failed. That is not negotiable and it does not get traded off against conversion.

---

## How we would prove any of this works

Show the new version to half the users, keep the current version for the other half, and compare.

- **Main measures:** Session Quality Index, and final-step conversion.
- **Supporting:** value per visit, time to first action.
- **Guardrails that must not worsen:** flagged-visit rate, visits per person not climbing, and people still active 30 and 90 days later.

That last one is the real test. Anyone can lift conversion for a week with pressure. The challenge asks for improvement that is still there three months later, and that only happens when the product genuinely got more useful.
