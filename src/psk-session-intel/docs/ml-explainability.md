# The analysis methods, and the algorithms we propose

Terms explained in [glossary.md](glossary.md).

**The rule that governs this whole file:** anything that changes what a user sees must be able to say why, in one plain sentence. And the safety layer can always overrule it.

Why we insist on this. In a gambling product, a system nobody can explain is a system nobody can defend. If a regulator, a colleague or a customer asks why someone was shown something, "the model decided" is not an acceptable answer. Everything below is chosen so there is always a real answer.

---

## Part 1 — What we have already done to the data

| Method | In plain words | What it told us |
|---|---|---|
| Rebuilding visits from raw events | Group 1.7 million taps into visits, then measure each one | All six challenge measurements |
| Transition counting | For each screen, count where people go next | Where visits die, and the 42,000 pointless loops |
| Time per screen | How long before people move on | The account page is the slowest thing in the app at 22.6 seconds |
| Splitting by visit length | Conversion for each length band | Visits under 30 seconds almost never convert, and are a quarter of all visits |
| Moving averages | Smoothed trend lines, daily and monthly | August conversion drifted from 36% to 40% |
| Correlations | Which monthly numbers move together | More visits goes with **less** spend per visit, strongly. They pull against each other |
| Clustering | Sorting visits into natural groups without being told the groups | The seven kinds of visit, our central finding |
| Joining visits to spending | Link app behaviour to actual money | Value per visit stays flat regardless of how often someone visits |

---

## Part 2 — What we propose building, and why each choice

| What we need | Suggested method | Why this one | How it explains itself |
|---|---|---|---|
| Tell what kind of visit this is, live | Start with simple rules based on which screens were touched, then the clustering we already built | We have already proved it works on real data. It is cheap and stable | The group's description is the explanation: "mostly ticket screens, very short" |
| Guess the intent from the first few taps | Start with counting which screens follow which, then a standard prediction model | Small amount of information, needs to be instant | Show which factors drove it. Constrain the model so its logic cannot go backwards, for example more picks can never mean less intent |
| Spot someone about to abandon their slip | A **glass-box** model: one that is a readable sum of simple parts, rather than a black box | The output triggers something the user sees, so it must be defensible | Reads out directly: "three picks, forty seconds idle, one price moved" |
| Find which screens make people leave | Survival analysis, the same maths hospitals use for "what raises the risk of an event happening now" | Correctly handles that some visits are still going. It answers "which screen raises the chance of leaving right now" | Produces a plain ranking of screens by how much they push people out |
| Search | Keyword matching plus meaning-based matching, combined | Handles both exact team names and everyday phrasing, in two languages | Highlight the matching words and state the reason: "you often bet Serie A" |
| Relevant suggestions | Match people to leagues and bet types they have used before, and games to similar games | Works with the kind of data we have, which is what people did rather than what they rated | The reason is built in: "because you bet on X" |
| Choosing which layout to show | A system that tries options and learns which works, scored on the Session Quality Index, with harm as a hard limit | Learns per kind of visit, and explores safely rather than guessing once | Every choice and its outcome is logged and publishable |
| Spotting harm | Written rules first. Later, an anomaly detector. Eventually a proper model, once FEG shares responsible-gambling data | We have no harm labels today, so rules are honest about that | Rules can be read by anyone. That is the point |
| Catching problems early | Trend and change-point detection on key numbers | The Android rejection problem sat there unnoticed. Automatic monitoring catches the next one in days | Reports the date the change started and how big it was |
| Proving an idea worked | A/B test, plus methods that show *which* users benefited rather than just the average | Judges want improvement that survives, not a one-week bump | A table of who benefited, by kind of visit |

---

## Part 3 — What the models can actually see today

From the existing data, at the moment a decision is needed: which screen they started on, the hour and day, how long since their last visit, which visit of the day this is, how many picks are in the slip, how long since the last pick, where the pick came from, single or multiple bet, which sport, live or upcoming, how many loops so far, whether they used search, and how many open tickets they looked at.

Three things would make a real difference if added: whether the odds moved while they hesitated, which is sitting unused in the 1.6 GB odds file; their stake history; and responsible-gambling flags.

---

## Part 4 — The four rules we hold ourselves to

1. **Every suggestion shown to a user carries a plain reason**, taken from what actually drove the decision. Not a generic label.
2. **Every model gets a written record**: what it uses, when it was trained, and how it performed on the safety tests.
3. **The safety layer is written rules, not a model, and it always wins.** Anyone can read it and check it. No learned system can override it.
4. **No model may use someone's losing history to decide when to prompt them.** This is the line that separates a helpful product from an exploitative one, and it is worth writing down explicitly.
