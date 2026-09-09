# Status — where this project stands

Last updated: 8 September 2026

**Where we are:** the analysis is finished and written up. The ideas are ranked. We have deliberately not started building anything yet.

**Why nothing is built yet:** understanding the problem properly changed what we would build. If we had started coding on day one, we would have built something to make people bet more, and missed that half the "failed" visits were never trying to bet in the first place.

---

## What is done

| # | Task | Status | Where the result is |
|---|---|---|---|
| 1 | Look at all the data provided, decide what is relevant | Done | README, section 3 |
| 2 | Clean the data and write down every cleaning decision | Done | help.md part A |
| 3 | Calculate the six measurements the challenge asks for | Done | help.md part B |
| 4 | Work out why visits end: length, screens, loops, time of day | Done | findings.md sections 3 and 4 |
| 5 | Examine the final step in detail | Done | findings.md section 4 |
| 6 | Examine how people find games in the casino app | Done | findings.md section 5 |
| 7 | Link visits to actual spending, and check for harm signals | Done | findings.md section 6 |
| 8 | Trends over time with smoothed lines | Done | findings.md section 6 |
| 9 | Find the natural kinds of visit | Done | findings.md section 2 |
| 10 | Write up the findings | Done | docs/findings.md |
| 11 | Propose and rank solutions | Done | docs/ideation.md |
| 12 | Choose the algorithms, keeping them explainable | Done | docs/ml-explainability.md |
| 13 | Design the Session Quality Index | Drafted | help.md part C |
| 14 | Plain-English glossary | Done | docs/glossary.md |
| 15 | Train and test the intent detector on real data | Done, 60% correct across 7 kinds vs 24% by guessing | analysis/06_poc_models.py, out/poc_intent_report.csv |
| 16 | Train and test the abandonment risk score | Done, AUC 0.66, riskiest 30% hold 52% of abandons | out/poc_abandon_coefficients.csv, out/poc_abandon_lift.csv |
| 17 | Two-problem POC plan with business case for evaluators | Done | docs/poc-plan.md |
| 18 | Data atlas: one visual page explaining all nine datasets | Done | docs/data-atlas.html, published at https://claude.ai/code/artifact/a2ad704a-a6c2-4e1f-b4f8-f302e4066b8f |
| 19 | Six data cubes + customer breadth segment (tenure proxy) | Done | analysis/09_cubes.py, out/cube_*.csv |
| 20 | Pattern mining: n-grams, PrefixSpan, absorbing Markov chain, Apriori, intent taxonomy, chasing proxy, Android retries | Done | analysis/10, 11, 12; docs/pattern-mining.md |
| 21 | Fixture-level cross-visit intent: 35% of abandoned matches are bet on later, median 3.3 h | Done | out/deferred_intent_fixture.csv |
| 23 | Final solution document for the hackathon | Done | docs/final-solution.md |
| 22 | Corrected the Android finding: rejections are retried, cost is friction not lost bets | Done | poc-plan.md, findings.md, README.md |

## What is next

| # | Task | Status |
|---|---|---|
| 23 | Get FEG to answer our five questions | **Waiting on them.** Questions in help.md part D |
| 24 | Work out which screens most cause people to leave | Next |
| 25 | Add live in-visit signals (seconds since last pick, price moved) to the risk score | Next |
| 26 | Use the odds file to see if prices moved while people hesitated | Next |
| 27 | Build the two POCs | **Not started on purpose.** This phase is understanding only |

---

## Decisions we made, and why

Recorded so anyone can challenge them.

- **We studied the PSK apps only.** Websites are kept as a comparison column, not as a target. PSK is written as `hr` in the raw files.
- **"A completed action" means placing a bet or opening a casino game.** We also report the stricter version, where the bet had to be accepted. Keeping these separate is what revealed the Android bug.
- **We do not require someone to have opened the betslip screen** to count as having reached the final step, because Android does not reliably record it. Requiring it would make Android look unfairly bad.
- **We merged the Android duplicate screen records.** The app writes each screen twice, once blank and once named. Before fixing this, the blank record was the top answer in every analysis and hid the real behaviour.
- **The Android rejection problem was first written up as lost bets. It is not.** Users retry and nearly always succeed (15 of 358 failing visits ended without an accepted ticket). We moved it from the money column to the friction column and corrected every document that mentioned it.
- **Value per visit is based on money staked, and that is only a rough measure.** It is the only money data available. It misses the value in a visit where someone checked their bet and left happy.

## Risks worth stating openly

- **Our 113 users are heavy users, not typical ones.** Their numbers are flattering. We correct for this by comparing against the all-customer monthly figures throughout.
- **About 40% of Android screens have no name recorded.** This limits how precisely we can say where people left. It needs raising with FEG.
- **We have no responsible-gambling data**, so harm detection can only be simple rules for now. Our simple rule flags 64 of our 113 users, which is clearly too many to act on. It shows the approach needs proper calibration, and we would rather say so than present a number we do not trust.

## Handling the data safely

Some of our output files contain the scrambled customer IDs. They are excluded from version control and must not go into the submission repository, in line with section 5 of the hackathon guidelines. The files in question are the visit-level and customer-level results in the output folder.
