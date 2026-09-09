# PSK Session Intelligence — Challenge 1

**Challenge 1 asks:** how do we turn more visits into completed actions, without pushing anyone?

**This folder holds:** understanding the problem, cleaning the data, analysing it, and proposing solutions. We have not started building anything yet. That is deliberate.

**What we studied:** the PSK apps only. PSK is the Croatian brand. In the raw files it is written as `hr`. Three apps: the sports app on iPhone, the sports app on Android, and the casino app on Android. The websites appear in our tables only so you can compare them against the apps.

New to the terms used here? Read [docs/glossary.md](docs/glossary.md) first. Every word is explained in plain English.

---

## 1. The problem in one paragraph

PSK customers open the app very often, four to six times a day. But only about one visit in three ends with them placing a bet or opening a game, and across all customers it is closer to one in four. So the users are already here and already engaged. They are just not finishing. The challenge names two reasons: people cannot find what suits them, and people who are one tap from betting still walk away.

## 2. What we found when we actually looked at the data

The brief describes the problem one way. The data tells a more specific story. This table is the heart of our submission.

| What the brief says | What the PSK app data actually shows |
|---|---|
| "Sessions end in browsing" | Most visits that end without a bet were never trying to bet. **A quarter of visits are people checking an existing bet slip** — they open the app, look at their ticket, and leave. **Another fifth last under ten seconds**, a glance and nothing more. Only about **one visit in six** is genuinely someone who browsed the markets and chose not to bet. |
| "Discovery friction" | Search is barely used, appearing in only **1 to 3 out of every 100** sports app visits. But when people do use it, they finish **more than twice as often**. In the casino app, search is already the single biggest way people find a game. So the problem is not that good content is missing. The tools to reach it are buried. |
| "Drop-off at the final step" | **About 1 in 5 visits that add a bet never place it.** But the reason differs by phone. On **Android, 17% of single-bet attempts come back rejected or closed by the system**, against under 1% on iPhone. That is a bug, not hesitation, though people retry and nearly always get through, so it costs friction rather than lost bets. On iPhone, people genuinely hesitate: they add fewer picks, half never even open the betslip, and they close the app within a minute. |
| "Sessions per user" | Heavy users already visit 130 times a month. More visits do **not** produce more value. The money spent per visit stays flat no matter how many times someone opens the app. So the goal should be making each visit better, not making people visit more. |

## 3. Which data we used, and which we ignored

| File | Do we use it? | Why |
|---|---|---|
| The two event log files (`top_sport_users_event_logs.csv`, `top_casino_users_event_logs.csv`) | **Yes, this is our main source** | The only files that show visits step by step. Every screen, every tap, with a time on it. Covers August 2026, 113 users, about 16,000 app visits. |
| `hackathon_sportsbook_trends.xlsx` and `hackathon_casino_trends.xlsx` | **Yes, for context** | Monthly totals going back a year, covering all customers rather than our 113. We use them so we do not mistake heavy-user behaviour for normal behaviour. |
| `SB_Player.csv`, `CA_Player.csv` | **Yes, for money** | Daily spend per customer. The only way to work out value per visit. About 7 in 10 of our app days match a spending record. |
| `SB_MOM.csv`, `CA_MOM.csv` | Not yet | Market totals with no customer or visit reference, so they cannot be linked to a visit. Useful later for knowing which sports are popular. |
| `EPS_Offers.csv` | Not yet | A 1.6 GB file of odds changing over time. Very useful later: it can tell us whether the odds moved while someone was hesitating, which may be exactly why they walked away. |
| The game files, videos, design samples | No | Building material for a later stage. |
| The WhatsApp images | No | Unrelated screenshots that happened to be in the folder. |

**Cleaning we had to do.** The full detail is in [help.md](help.md), but in short: the two files record missing values differently and write dates in two different formats, so both were made consistent. The Android app records each screen twice, a blank record and a named one, so we merged those pairs. All times were converted to Croatian local time. And there are two different definitions of "a visit" in circulation, so we always say which one a number uses.

## 4. What is in this folder

| File | What it is for |
|---|---|
| `README.md` | This file. The problem and the data. |
| `status.md` | What is done, what is next, what we decided and why. |
| `help.md` | Every measurement explained: what it means, where it comes from, how we calculated it, and what could be wrong with it. |
| `docs/glossary.md` | Plain-English meaning of every term. |
| `docs/data-atlas.html` | **Visual guide to every dataset we were given.** Open in a browser. Rebuilt by `analysis/07` and `08`. |
| `docs/findings.md` | What the data showed, with the numbers. |
| `docs/final-solution.md` | **The final answer. Start here.** What we build, why, what it moves, how we prove it. |
| `docs/poc-plan.md` | The two problems in depth, with the full business case and assumptions. |
| `docs/pattern-mining.md` | Data cubes and pattern mining: sequence mining, Markov chain, association rules, the four intent types quantified, cross-visit intent. |
| `docs/ideation.md` | The full list of proposed solutions, ranked. |
| `docs/ml-explainability.md` | Which algorithms we suggest and why each stays understandable. |
| `analysis/` | The scripts. Results land in `analysis/out/`. |

To rerun the analysis: open a terminal in the `analysis` folder and run the scripts in order. They need Python with pandas, numpy, scikit-learn and openpyxl.

## 5. The rule we will not break

Any improvement must come from being more relevant and removing annoyances. Never from pressure.

That means no countdown timers, no "others are betting on this", no streaks, no making the exit hard to find. And when a visit shows signs of unhealthy play, such as playing through the night, going past two hours, or reopening the app minutes after closing it, we switch **all** our features off for that visit and show the plain app instead. We count those visits separately, and if our changes make that count go up, the idea has failed regardless of how good the conversion numbers look.
