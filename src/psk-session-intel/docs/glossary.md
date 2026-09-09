# Glossary — every term used in these documents

Read this first if a word in the other files is unclear.

## The basics
**Session** — one visit. The user opens the app, does some things, and stops. If they do nothing for about 30 minutes, that visit is over and the next thing they do counts as a new visit.

**Action** — the user actually did the main thing, instead of just looking. For sports that means placing a bet. For casino that means opening a game. Everything else, scrolling and tapping around, is not an action.

**Conversion** — a visit that ended in an action. "Session conversion rate of 30%" means 3 out of every 10 visits ended in a bet or a game, and 7 did not.

**Final step** — the moment just before betting. The user has picked a selection and put it in their betslip. They are one tap away. If they leave now, we lose someone who had already decided.

**Betslip** — the basket. The user adds picks to it, then confirms the whole thing to place the bet.

**Drop-off / abandon** — the user got to a point and then left without finishing.

## Words that appear in the data
**PSK** — the Croatian brand we are studying. In the raw files it is written as `hr`, and in one sheet as `HTK-CRO`. All three mean the same company.

**Platform** — which app the user was on. We care about three: `SB iOS` (the sports app on iPhone), `SB Android` (the sports app on Android), and `Casino Android` (the casino app). `GM` and `web` are the websites, which we only use for comparison.

**Screen** — one page inside the app, for example the live matches list, or the betslip.

**Event** — one recorded thing the user did, with a timestamp. Opening a screen is an event. Adding a bet is an event. Our files hold about 1.7 million of them.

**PlayerID** — a scrambled code standing in for one customer. We cannot see who they are, but we can tell that the same person came back.

**Prematch** — betting on a match before it starts. **Live** — betting while it is being played.

**Stake** — the money put on a bet.

## Words used in the measurements
**Median** — the middle value. Half are below, half above. We use it instead of the average because a handful of extremely long visits would drag an average upwards and mislead us.

**Average (mean)** — add everything up, divide by the count.

**Moving average** — a smoothed line. Instead of plotting each day, which jumps around, you plot the average of the last 7 days. Real trends show through, daily noise disappears.

**Baseline** — where we are today, before we change anything. You need it to prove an idea worked.

**Cohort** — a group of users grouped by when they started, so you can follow them over time.

**D30 / D90 retention** — the share of users still coming back 30 days and 90 days later. It is the test of whether a change actually helped, or just produced a short-term bump followed by people leaving.

## Words about the guardrail
**Responsible gambling (RG)** — the rules that stop a product from harming people. It outranks every business goal here.

**Dark pattern** — a design that tricks or pressures someone into doing something. Countdown timers, "only 2 left", hard-to-find cancel buttons. The challenge bans these outright, and so do we.

**Harm indicator** — a sign that someone's play is becoming unhealthy. Playing all night, sessions over two hours, reopening the app minutes after closing it, betting bigger and bigger.

**Suppression** — switching our features off for a user showing those signs. They see the plain app and the help tools, nothing that encourages more play.

**Guardrail metric** — a number that must NOT go up. If our changes make more sessions look harmful, the idea has failed no matter how good conversion looks.

## Technical words in the ideas
**Model** — a piece of software that spots a pattern in past behaviour and uses it to make a guess about right now. For example, guessing that this user is about to abandon their betslip.

**Explainable / glass-box model** — a model that can tell you in plain words why it decided something. "Three picks added, forty seconds of no activity, one odds change." We insist on this so nobody has to trust a black box.

**Feature** — one piece of information fed to a model, such as the hour of day, or how many picks are in the slip.

**Clustering** — sorting things into natural groups without being told the groups in advance. We used it to discover the seven kinds of visit.

**Archetype** — one of those discovered groups. A "kind of visit", such as a quick ticket check.

**A/B test** — show the new version to half the users, keep the old version for the other half, then compare. The only honest way to prove a change worked.

**Search index / semantic search** — search that understands meaning, not just exact spelling. Typing "Dinamo game tonight" finds the right match even though those exact words are not the match's title.
