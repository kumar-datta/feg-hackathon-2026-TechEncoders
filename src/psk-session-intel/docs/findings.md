# Findings — what the PSK app data showed

Data: August 2026 app event logs, 113 heavy users, about 16,000 visits. Plus monthly totals for all customers, used as a reality check.

**Important warning about the numbers.** Our 113 users are heavy users, hand-picked for the exercise. They bet far more than a normal customer. So use these numbers to understand *why* things happen, and use the all-customer monthly figures when setting targets. Where a number covers all customers, we say so.

---

## 1. Where we stand today

| Measure | Sports iPhone | Sports Android | Casino Android | Website | All customers |
|---|---|---|---|---|---|
| Visits ending in a bet or game | 35% | 32% | 74% | 28% | **24%** |
| Visits where a bet got added to the slip | 45% | 37% | — | 22% | — |
| Of those, share that actually placed it | 76% | 86% | — | 85% | — |
| Typical wait before the first action | 8.6 min | 5.6 min | 37 sec | 2.9 min | 6.3 min |
| Actions per visit | 1.7 | 1.3 | 4.4 | 1.1 | 1.7 |
| Visits per person per month | 131 | 132 | 89 | 78 | 24 |
| Typical visit length | 8 min | 5.5 min | 13 min | 3.2 min | 5.3 min |

Read the first row like this: on the sports iPhone app, 35 visits out of every 100 ended with a bet. The other 65 did not.

## 2. The seven kinds of visit

We let the computer sort all 16,000 visits into natural groups, without telling it what to look for. Seven kinds emerged. **This is our most important finding.**

| Kind of visit | Share | Typical length | Ends in action | What it looks like |
|---|---|---|---|---|
| **Checking a ticket** | 24% | 41 sec | 2% | Opens app, looks at an existing bet, leaves |
| **A quick glance** | 19% | 6 sec | 14% | Two taps and gone |
| **Browsing upcoming matches** | 16% | 13 min | 57% | Looking through matches not yet started |
| **Following a live match** | 13% | 18 min | 51% | Watching a game in progress |
| **The marathon** | 12% | 106 min | 100% | 284 taps, 82 picks added, 9 bets placed |
| **Account admin** | 8% | 4 min | 2% | Deposits, withdrawals, settings |
| **Playing casino** | 8% | 35 min | 100% | Opens 7 games, starts within 39 seconds |

**Why this matters so much.** Add up the first two and the admin group and you get **just over half of all visits where betting was never the point**. Someone checking whether their bet won is not a failed customer. Counting them as failures pushes us towards exactly the pressure tactics the challenge forbids. Our first proposal is built on this.

The marathon group is the opposite concern. 12% of visits, every one converting, but 106 minutes and 82 picks. These need watching for harm, not encouragement.

## 3. What makes visits end

**Length predicts everything.** Visits under 30 seconds almost never convert, between 0.5% and 2%. Two to five minutes gets to 34%. Over an hour reaches 75 to 80%. And short visits are common: 27% of Android sports visits and 22% of iPhone ones last under 30 seconds.

**Where visits die.** On iPhone, a quarter end on the bet detail screen and a sixth on the bet history screen. Together that is 41%, all in the ticket-checking area. Another 14% end on the live match list.

**Going round in circles.** The biggest single pattern in the data is people bouncing between a list and a detail page, then back. Live list to live match and back happened 42,000 times. Ticket list to ticket detail and back, 33,000 times. They are doing this because the list does not show what they need, so they have to open each item to find out and then come back.

**The slowest screen.** The account and deposit pages, which open as an embedded web page inside the app, take 22.6 seconds before people move on. That is by far the slowest thing in the app, and 6% of all visits end there.

**Time of day.** Between 3am and 6am only 22 to 30% of visits convert, and they are short. Between 3pm and 8pm it is 43 to 46%.

**Later visits work better.** A person's first visit of the day converts 34% of the time. By their fifth it is 44%. People come back with a purpose. The typical gap between visits is 82 minutes, and 39% return within the hour.

## 4. The final step, examined closely

Of 5,568 visits that added a bet to the slip, **1,064 (19%) never placed it**. 667 on iPhone, 397 on Android. Three separate things are going on.

**On Android, there is a rejection loop.** When a single bet is submitted, only 83% of attempts get accepted. The rest come back closed or rejected, 642 and 451 times in August. On iPhone the same thing succeeds 99.5% of the time. Same users, same matches, same month. Something in the Android app is mishandling the moment when odds change or a market closes. **But people retry and almost always get through:** 15% of Android visits with a placement hit a rejection, and only 15 of those 358 visits ended with no accepted ticket. So this costs time, trust and repeated taps at the moment of highest intent, rather than lost bets. It is still the cheapest fix in the analysis, because it needs no clever technology at all.

**On iPhone, it is genuine hesitation.** People who abandon add fewer picks, four against nine. Half never even open the betslip screen. And they close the app 43 seconds after their last pick, a quarter of them within 5 seconds. That is not someone weighing a decision. That is someone interrupted, or someone who hit something confusing.

For comparison, people who do place a bet take about 97 seconds from first pick to placing. That is the natural thinking time.

**Where the pick came from changes everything.** Picks made from a live match page get placed 88% of the time. From the match detail page, 83%. But from the "most bet matches" widget, only 56%. **Popularity-based suggestions convert worst.** That is strong evidence for relevance over popularity.

**The intent does not disappear.** After abandoning, 40% of people come back within the hour, and 39% place a bet in their next visit. They did not change their minds. They lost their slip.

## 5. Finding things

**Search barely gets used, and works brilliantly.** It appears in 3.4% of iPhone visits and 1.1% of Android ones. Those visits convert at 71% and 79%, against 33% and 31% for everyone else. Roughly double.

**In casino, search already wins.** It is the single biggest source of game launches, 3,874, ahead of the main grid at 1,710. The "my games" list drives another 4,221. And 87% of all launches are a game the person already played that month. The typical person plays 17 different games.

**Speed follows.** When a casino visit starts on "my games" or search, the first game opens within 6 seconds. From an unnamed starting screen it takes 45 seconds.

**Across all customers:** the casino Android app takes 55 seconds to reach a first game, while the website takes 28. The app has been stuck around 43% of visits reaching a game for a year, while the website climbed to 50%.

## 6. The money and the direction of travel

For all Croatian sportsbook customers, March to August 2026:

| | March | August | Change |
|---|---|---|---|
| Visits | 555,000 | 447,000 | −19% |
| Spend per visit | €21.50 | €25.30 | +18% |
| Visits per person | 26.6 | 24.3 | −9% |
| Sports per visit | 1.44 | 1.34 | −7% |
| Visits ending in a bet | 27.2% | 24.1% | −3 points |

Fewer visits, each worth more. People are also narrowing, exploring fewer sports per visit, which is a discovery problem showing up in the numbers.

In casino, PSK has the highest spend per visit of any FEG market, €343. But spend per spin has risen 26% since December. That is worth watching as a harm signal, not celebrating.

**Does visiting more often create more value?** No. We joined visits to actual spending for our 113 users. Someone visiting nine or more times a day produces about the same value per visit, roughly €80 to €120, as someone visiting twice. Their total daily spend is higher, but each visit is no better. **So chasing more visits is the wrong goal.**

## 7. Gaps in the recording

Worth raising with FEG, because they limit what anyone can measure.

- The Android app does not name about 40% of its screens, so we cannot always tell where a person was when they left.
- Nothing records cash-outs, following a match, favouriting, or setting a notification. Those are all valuable things a user can do that are not betting, and today they are invisible.
- Nothing records why a bet was rejected, which is why the Android problem took detective work to find.
- Two different definitions of "a visit" are in use across the files.
