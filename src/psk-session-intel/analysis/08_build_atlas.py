"""Builds docs/data-atlas.html from out/data_atlas_stats.json + the template below."""
import json
OUT = "C:/FEG/psk-session-intel/analysis/out/"; DOCS = "C:/FEG/psk-session-intel/docs/"
J = json.load(open(OUT + "data_atlas_stats.json", encoding="utf8"))

TEMPLATE = r'''<title>PSK Data Atlas</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,500;12..96,700&family=IBM+Plex+Sans:wght@400;500;600&family=IBM+Plex+Mono:wght@400;500&display=swap">
<style>
:root{
  color-scheme:light;
  --bg:#f5f6f8; --surface:#ffffff; --ink:#15181d; --ink-2:#4f5663; --ink-3:#7c8493; --line:#dfe3e9; --line-2:#eef0f3;
  --accent:#2a78d6; --accent-ink:#1c5cab; --accent-soft:#e6f0fb;
  --s1:#2a78d6; --s2:#eb6834; --s3:#1baf7a; --s4:#eda100; --s5:#e87ba4;
  --note:#fff7e6; --note-ink:#7a4d00;
  --sans:"IBM Plex Sans",system-ui,-apple-system,"Segoe UI",sans-serif;
  --disp:"Bricolage Grotesque","IBM Plex Sans",system-ui,sans-serif;
  --mono:"IBM Plex Mono",ui-monospace,"SF Mono",Consolas,monospace;
}
@media (prefers-color-scheme:dark){ :root:not([data-theme="light"]){
  color-scheme:dark;
  --bg:#15171b; --surface:#1d2025; --ink:#f1f2f4; --ink-2:#b9bec8; --ink-3:#858c99; --line:#2e323a; --line-2:#262a31;
  --accent:#3987e5; --accent-ink:#86b6ef; --accent-soft:#1c2a3d;
  --s1:#3987e5; --s2:#d95926; --s3:#199e70; --s4:#c98500; --s5:#d55181;
  --note:#2d2610; --note-ink:#f0c86a;
}}
:root[data-theme="dark"]{
  color-scheme:dark;
  --bg:#15171b; --surface:#1d2025; --ink:#f1f2f4; --ink-2:#b9bec8; --ink-3:#858c99; --line:#2e323a; --line-2:#262a31;
  --accent:#3987e5; --accent-ink:#86b6ef; --accent-soft:#1c2a3d;
  --s1:#3987e5; --s2:#d95926; --s3:#199e70; --s4:#c98500; --s5:#d55181;
  --note:#2d2610; --note-ink:#f0c86a;
}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);font-size:15px;line-height:1.55;-webkit-font-smoothing:antialiased}
a{color:var(--accent-ink)}
.wrap{display:grid;grid-template-columns:230px minmax(0,1fr);gap:40px;max-width:1180px;margin:0 auto;padding:32px 24px 96px}
@media (max-width:860px){.wrap{grid-template-columns:1fr;gap:24px}.index{position:static!important}}
.index{position:sticky;top:20px;align-self:start;font-size:13px}
.index .eyebrow{margin-bottom:10px}
.index ol{list-style:none;margin:0;padding:0;border-left:2px solid var(--line)}
.index li a{display:block;padding:5px 12px;color:var(--ink-2);text-decoration:none;border-left:2px solid transparent;margin-left:-2px}
.index li a:hover,.index li a:focus-visible{color:var(--ink);border-left-color:var(--accent);outline:none}
.index li a small{display:block;color:var(--ink-3);font-family:var(--mono);font-size:11px}
.eyebrow{font-family:var(--mono);font-size:11px;letter-spacing:.08em;text-transform:uppercase;color:var(--ink-3)}
h1{font-family:var(--disp);font-weight:700;font-size:clamp(30px,4vw,44px);line-height:1.05;margin:6px 0 14px;letter-spacing:-.01em;text-wrap:balance}
h2{font-family:var(--disp);font-weight:700;font-size:26px;line-height:1.15;margin:0 0 4px;letter-spacing:-.01em;text-wrap:balance}
h3{font-family:var(--disp);font-weight:600;font-size:16px;margin:26px 0 8px}
p{max-width:68ch;margin:0 0 12px}
.lede{font-size:17px;color:var(--ink-2);max-width:62ch}
.main>header{padding-bottom:28px;border-bottom:1px solid var(--line);margin-bottom:36px}
.file{font-family:var(--mono);font-size:13px;color:var(--accent-ink);background:var(--accent-soft);padding:2px 7px;border-radius:4px;white-space:nowrap}
section.ds{padding:36px 0;border-top:1px solid var(--line)}
section.ds:first-of-type{border-top:0;padding-top:0}
.ds-head{display:flex;flex-wrap:wrap;align-items:baseline;gap:10px 16px;margin-bottom:14px}
.facts{display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:1px;background:var(--line);border:1px solid var(--line);border-radius:6px;overflow:hidden;margin:14px 0 18px}
.facts div{background:var(--surface);padding:10px 12px}
.facts b{display:block;font-family:var(--disp);font-weight:700;font-size:20px;line-height:1.1;font-variant-numeric:tabular-nums}
.facts span{font-size:12px;color:var(--ink-3)}
.use{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px 28px;margin:6px 0 10px}
.use h4{margin:0 0 4px;font-size:12px;font-family:var(--mono);letter-spacing:.06em;text-transform:uppercase;color:var(--ink-3);font-weight:500}
.use p{font-size:14px;margin:0}
.note{background:var(--note);color:var(--note-ink);padding:10px 14px;border-radius:6px;font-size:14px;max-width:72ch;margin:12px 0}
table{border-collapse:collapse;width:100%;font-size:13px}
.tbl{overflow-x:auto;border:1px solid var(--line);border-radius:6px;background:var(--surface)}
th,td{text-align:left;padding:7px 10px;border-bottom:1px solid var(--line-2);vertical-align:top}
th{font-family:var(--mono);font-weight:500;font-size:11.5px;letter-spacing:.04em;color:var(--ink-3);text-transform:uppercase;white-space:nowrap}
tr:last-child td{border-bottom:0}
td.k{font-family:var(--mono);font-size:12.5px;white-space:nowrap;color:var(--accent-ink)}
td.num{text-align:right;font-variant-numeric:tabular-nums;font-family:var(--mono);font-size:12.5px}
.sample td{font-family:var(--mono);font-size:11.5px;white-space:nowrap;max-width:260px;overflow:hidden;text-overflow:ellipsis}
.charts{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:20px;margin:10px 0 18px}
figure{margin:0;background:var(--surface);border:1px solid var(--line);border-radius:6px;padding:14px 14px 10px;min-width:0}
figcaption{font-size:13px;font-weight:600;margin-bottom:2px}
figcaption small{display:block;font-weight:400;color:var(--ink-3);font-size:12px}
svg{width:100%;height:auto;display:block;overflow:visible}
svg text{font-family:var(--sans);font-size:11px;fill:var(--ink-2)}
svg .grid{stroke:var(--line-2);stroke-width:1}
svg .axis{stroke:var(--line);stroke-width:1}
svg .lbl{fill:var(--ink)}
svg .val{fill:var(--ink-2);font-family:var(--mono);font-size:10.5px}
.legend{display:flex;flex-wrap:wrap;gap:6px 14px;font-size:12px;color:var(--ink-2);margin-top:6px}
.legend i{display:inline-block;width:10px;height:10px;border-radius:2px;margin-right:6px;vertical-align:-1px}
#tip{position:fixed;pointer-events:none;background:var(--ink);color:var(--bg);font-size:12px;padding:6px 9px;border-radius:4px;opacity:0;transition:opacity .08s;z-index:9;font-family:var(--mono);white-space:nowrap}
.map{display:grid;grid-template-columns:repeat(auto-fit,minmax(240px,1fr));gap:12px;margin:14px 0 8px}
.map div{background:var(--surface);border:1px solid var(--line);border-radius:6px;padding:12px 14px}
.map b{font-family:var(--disp);font-size:15px;display:block;margin-bottom:4px}
.map p{font-size:13px;margin:0;color:var(--ink-2)}
.map .k{font-family:var(--mono);font-size:11px;color:var(--accent-ink);margin-top:8px;display:block}
.keys{display:flex;gap:6px;flex-wrap:wrap;margin:8px 0 0}
.key{font-family:var(--mono);font-size:11px;padding:2px 8px;border-radius:99px;border:1px solid var(--line);color:var(--ink-2)}
.key.on{background:var(--accent-soft);border-color:transparent;color:var(--accent-ink)}
ul.plain{padding-left:18px;max-width:68ch}
ul.plain li{margin-bottom:6px}
@media (prefers-reduced-motion:reduce){#tip{transition:none}}
</style>

<div id="tip"></div>
<div class="wrap">
<nav class="index" aria-label="Datasets">
  <div class="eyebrow">The nine datasets</div>
  <ol>
    <li><a href="#overview">How they fit together</a></li>
    <li><a href="#sport_log">1 · Sports app activity<small>top_sport_users_event_logs</small></a></li>
    <li><a href="#casino_log">2 · Casino app activity<small>top_casino_users_event_logs</small></a></li>
    <li><a href="#sb_trends">3 · Sportsbook monthly<small>hackathon_sportsbook_trends</small></a></li>
    <li><a href="#casino_trends">4 · Casino monthly<small>hackathon_casino_trends</small></a></li>
    <li><a href="#sb_player">5 · Sports bets per customer<small>SB_Player</small></a></li>
    <li><a href="#ca_player">6 · Casino play per customer<small>CA_Player</small></a></li>
    <li><a href="#sb_mom">7 · Sports market totals<small>SB_MOM</small></a></li>
    <li><a href="#ca_mom">8 · Casino product totals<small>CA_MOM</small></a></li>
    <li><a href="#eps">9 · The odds feed<small>EPS_Offers</small></a></li>
    <li><a href="#other">Everything else in the folder</a></li>
  </ol>
</nav>

<main class="main">
<header>
  <div class="eyebrow">FEG Hackathon 2026 · Challenge 1 · PSK (Croatia, brand code <span class="file">hr</span>)</div>
  <h1>Every dataset we were given, explained for a first look</h1>
  <p class="lede">Nine data files arrived. This page says, for each one, what it is, what a single row means, how big it is, what period it covers, and what we can and cannot learn from it. All numbers are computed from the files themselves.</p>
</header>

<section class="ds" id="overview">
  <h2>How the nine datasets fit together</h2>
  <p>They come in three kinds. Only the first kind shows what a person did inside the app, step by step. The other two are totals.</p>
  <div class="map">
    <div><b>Step-by-step activity</b><p>Every tap, with a time on it. The only files with a <em>visit</em> (session) in them. Cover 31 days and about 180 hand-picked heavy users.</p><span class="k">1 · 2</span></div>
    <div><b>Money per customer per day</b><p>How much each customer bet on each day, on which sport or game. No visits, no screens, but real money and real customer IDs.</p><span class="k">5 · 6</span></div>
    <div><b>Totals with no customer in them</b><p>Monthly or market-level sums. Good for context and trend, useless for understanding one visit.</p><span class="k">3 · 4 · 7 · 8 · 9</span></div>
  </div>
  <h3>What links them</h3>
  <p>Two keys matter. <span class="file">PlayerID</span> is a scrambled customer code, the same code across files, so a customer's app taps (1, 2) can be joined to their spending (5, 6). <span class="file">session</span> identifies one visit and exists only in files 1 and 2. Everything else joins only on the month or the brand.</p>
  <div class="tbl"><table>
    <tr><th>Dataset</th><th>Has PlayerID</th><th>Has a visit ID</th><th>Has money</th><th>Period</th><th>Who is in it</th></tr>
    <tr><td>1 Sports app activity</td><td>yes</td><td>yes</td><td>no</td><td>1–31 Aug 2026</td><td>92 heavy sports users</td></tr>
    <tr><td>2 Casino app activity</td><td>yes</td><td>yes</td><td>no</td><td>1–31 Aug 2026</td><td>89 heavy casino users</td></tr>
    <tr><td>3 Sportsbook monthly</td><td>no</td><td>no</td><td>per visit</td><td>Mar–Aug 2026</td><td>all customers, 6 markets</td></tr>
    <tr><td>4 Casino monthly</td><td>no</td><td>no</td><td>per visit</td><td>Sep 2025–Aug 2026</td><td>all customers, 5 markets</td></tr>
    <tr><td>5 Sports bets per customer</td><td>yes</td><td>no</td><td>yes</td><td>16–31 Aug 2026</td><td>15,738 customers</td></tr>
    <tr><td>6 Casino play per customer</td><td>yes</td><td>no</td><td>yes</td><td>1–31 Aug 2026</td><td>26,904 customers</td></tr>
    <tr><td>7 Sports market totals</td><td>no</td><td>no</td><td>yes</td><td>Jun–Aug 2026</td><td>everyone, summed</td></tr>
    <tr><td>8 Casino product totals</td><td>no</td><td>no</td><td>yes</td><td>Sep 2025–Aug 2026</td><td>everyone, summed</td></tr>
    <tr><td>9 The odds feed</td><td>no</td><td>no</td><td>no</td><td>16 Aug 2026 only</td><td>no people at all</td></tr>
  </table></div>
</section>

<!-- ============ 1 SPORT LOG ============ -->
<section class="ds" id="sport_log">
  <div class="ds-head"><h2>1 · Sports app activity</h2><span class="file">top_sport_users_event_logs.csv</span></div>
  <p class="lede">The most important file. A diary of everything 92 heavy sports bettors did in the PSK apps and website during August 2026, one line per tap.</p>
  <div class="facts" id="f_sport_log"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One thing one person did at one moment: opened a screen, added a pick to their betslip, placed a bet.</p></div>
    <div><h4>What it lets us do</h4><p>Rebuild each visit tap by tap, see where people go, where they leave, and how long they take to act.</p></div>
    <div><h4>What it cannot do</h4><p>No money in it. And these 92 people bet far more than a normal customer, so their rates are not typical.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Rows by platform<small>Which app or site the tap happened on</small></figcaption><div id="c_sport_platform"></div></figure>
    <figure><figcaption>Rows by type of event<small>What kind of thing was recorded</small></figcaption><div id="c_sport_event"></div></figure>
    <figure style="grid-column:1/-1"><figcaption>Rows per day<small>Weekends and big football days stand out</small></figcaption><div id="c_sport_daily"></div></figure>
  </div>
  <h3>The columns, in plain words</h3>
  <div class="tbl"><table id="t_sport_cols"></table></div>
  <div class="note">Two quirks to know. Missing values are written as an empty cell here but as the word <span class="file">null</span> in file 2. And the Android app records every screen twice, once blank and once named, a fraction of a second apart. Both had to be cleaned before counting anything.</div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_sport_log"></table></div>
</section>

<!-- ============ 2 CASINO LOG ============ -->
<section class="ds" id="casino_log">
  <div class="ds-head"><h2>2 · Casino app activity</h2><span class="file">top_casino_users_event_logs.csv</span></div>
  <p class="lede">The same diary format as file 1, for 89 heavy casino players. Because these people also bet on sport, most of the rows are actually sports taps.</p>
  <div class="facts" id="f_casino_log"></div>
  <div class="use">
    <div><h4>One row means</h4><p>Same as file 1. The casino-specific rows are <span class="file">casino_game_launch</span>, which say which game was opened and from where.</p></div>
    <div><h4>What it lets us do</h4><p>See how people find games: search, the "my games" list, the main grid, a promotion.</p></div>
    <div><h4>Watch out</h4><p>Only 41,000 of the 332,000 rows are on the casino app. Two copies of this file were provided; they are identical.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Rows by platform<small>Casino Android is the casino app; the rest is sport</small></figcaption><div id="c_casino_platform"></div></figure>
    <figure><figcaption>Rows by type of event</figcaption><div id="c_casino_event"></div></figure>
  </div>
  <h3>Columns that only matter for casino rows</h3>
  <div class="tbl"><table id="t_casino_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_casino_log"></table></div>
</section>

<!-- ============ 3 SB TRENDS ============ -->
<section class="ds" id="sb_trends">
  <div class="ds-head"><h2>3 · Sportsbook monthly figures</h2><span class="file">hackathon_sportsbook_trends.xlsx</span></div>
  <p class="lede">A small spreadsheet of monthly totals for six FEG markets, March to August 2026. This is where the "all customers" numbers come from.</p>
  <div class="facts" id="f_sb_trends"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One market in one month: how many visits, how many active customers, average stake per visit, how many bet slips per visit.</p></div>
    <div><h4>What it lets us do</h4><p>Set honest targets. Our 92 heavy users convert at 32–35%; all Croatian customers convert at 24%.</p></div>
    <div><h4>Watch out</h4><p>Croatia appears under two names: <span class="file">hr</span> in the first block and <span class="file">HTK-CRO</span> in the conversion block. Same brand.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Croatia: visits per month<small>Falling since March, while stake per visit rose</small></figcaption><div id="c_hr_sessions"></div></figure>
    <figure><figcaption>Croatia: share of visits ending in a bet<small>The all-customer conversion rate</small></figcaption><div id="c_hr_conv"></div></figure>
    <figure style="grid-column:1/-1"><figcaption>August 2026, all six markets<small>Share of visits ending in a bet</small></figcaption><div id="c_conv_markets"></div></figure>
  </div>
  <div class="note">The sheet defines a visit as ending 15 minutes after the last bet slip. The activity files (1, 2) use a different rule, roughly 30 minutes of inactivity. The two do not give identical counts.</div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_sb_trends_cols"></table></div>
</section>

<!-- ============ 4 CASINO TRENDS ============ -->
<section class="ds" id="casino_trends">
  <div class="ds-head"><h2>4 · Casino monthly figures</h2><span class="file">hackathon_casino_trends.xlsx</span></div>
  <p class="lede">Twelve months of casino averages for five markets, September 2025 to August 2026, plus a small block on how fast the Android app reaches a first game.</p>
  <div class="facts" id="f_casino_trends"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One market in one month: average stake per visit, spins per visit, games per visit, visits per customer, typical visit length.</p></div>
    <div><h4>What it lets us do</h4><p>See that PSK has the highest casino stake per visit of any FEG market, and that the Android app is slower to a first game than the website.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>PSK: stake per visit, in euros<small>Twelve months</small></figcaption><div id="c_psk_stake"></div></figure>
    <figure><figcaption>Share of visits reaching a game<small>Android app versus website</small></figcaption><div id="c_psk_conv"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_casino_trends_cols"></table></div>
</section>

<!-- ============ 5 SB PLAYER ============ -->
<section class="ds" id="sb_player">
  <div class="ds-head"><h2>5 · Sports bets per customer per day</h2><span class="file">SB_Player.csv</span></div>
  <p class="lede">What every Croatian sports customer bet on, day by day, for the second half of August 2026. Three million rows, real money, scrambled customer codes.</p>
  <div class="facts" id="f_sb_player"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One customer, one day, one specific selection on one match: how many bets and how much money.</p></div>
    <div><h4>What it lets us do</h4><p>Join to the activity files by customer code and day, to put money next to behaviour. That is how we get value per visit.</p></div>
    <div><h4>Watch out</h4><p>Only 16 days, not the full month. A few hundred rows are broken by stray quote marks and were skipped.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Stake by sport<small>Top ten, in euros, 16–31 August</small></figcaption><div id="c_sbp_sport"></div></figure>
    <figure><figcaption>Live versus before the match<small>Stake by betting product</small></figcaption><div id="c_sbp_product"></div></figure>
    <figure style="grid-column:1/-1"><figcaption>Total stake per day<small>In euros</small></figcaption><div id="c_sbp_daily"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_sb_player_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_sb_player"></table></div>
</section>

<!-- ============ 6 CA PLAYER ============ -->
<section class="ds" id="ca_player">
  <div class="ds-head"><h2>6 · Casino play per customer per day</h2><span class="file">CA_Player.csv</span></div>
  <p class="lede">The casino equivalent of file 5, for the whole of August: which games each customer played each day and how much they staked.</p>
  <div class="facts" id="f_ca_player"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One customer, one day, one game: total money staked on it.</p></div>
    <div><h4>What it lets us do</h4><p>Same join as file 5. Also shows which game studios and game types carry the money.</p></div>
    <div><h4>Watch out</h4><p>Casino stake looks enormous next to sport because each spin is a stake and people spin hundreds of times a visit. Do not compare the totals directly.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Stake by game studio<small>Top ten providers, in euros</small></figcaption><div id="c_cap_provider"></div></figure>
    <figure><figcaption>Stake by game type<small>Slots dominate</small></figcaption><div id="c_cap_type"></div></figure>
    <figure style="grid-column:1/-1"><figcaption>Total stake per day<small>In euros, August 2026</small></figcaption><div id="c_cap_daily"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_ca_player_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_ca_player"></table></div>
</section>

<!-- ============ 7 SB MOM ============ -->
<section class="ds" id="sb_mom">
  <div class="ds-head"><h2>7 · Sports market totals by month</h2><span class="file">SB_MOM.csv</span></div>
  <p class="lede">Every betting market offered in Croatia, summed per month: how many tickets it attracted and how much money. No customers in it. "MOM" means month on month.</p>
  <div class="facts" id="f_sb_mom"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One selection on one market on one match, in one month: number of tickets and total stake.</p></div>
    <div><h4>What it lets us do</h4><p>Know what is popular: which sports, competitions and bet types attract tickets. Useful later for a "what people like you bet on" feature.</p></div>
    <div><h4>What it cannot do</h4><p>Nothing about who, when within the month, or which visit. Not used in our session analysis for that reason.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Tickets by sport<small>Top ten, three months combined</small></figcaption><div id="c_sbm_sport"></div></figure>
    <figure><figcaption>Most-bet competitions<small>By number of tickets</small></figcaption><div id="c_sbm_events"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_sb_mom_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_sb_mom"></table></div>
</section>

<!-- ============ 8 CA MOM ============ -->
<section class="ds" id="ca_mom">
  <div class="ds-head"><h2>8 · Casino product totals by month</h2><span class="file">CA_MOM.csv</span></div>
  <p class="lede">The biggest file by rows: every casino game, per month, for a year. Total staked and total won, split into bonus money and jackpot money. No customers.</p>
  <div class="facts" id="f_ca_mom"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One game from one studio in one month: total stake, total win, and how much of each came from bonuses or jackpots.</p></div>
    <div><h4>What it lets us do</h4><p>See the casino's size and seasonality, and which studios matter. Stake minus win is roughly what the casino keeps.</p></div>
    <div><h4>What it cannot do</h4><p>Nothing per person or per visit. Not used in our session analysis.</p></div>
  </div>
  <div class="charts">
    <figure style="grid-column:1/-1"><figcaption>Total stake and total win per month<small>In millions of euros. The gap between the lines is the house margin</small></figcaption><div id="c_cam_month"></div><div class="legend"><span><i style="background:var(--s1)"></i>Stake</span><span><i style="background:var(--s2)"></i>Win paid out</span></div></figure>
    <figure><figcaption>Stake by game studio<small>Top ten, twelve months</small></figcaption><div id="c_cam_provider"></div></figure>
    <figure><figcaption>Stake by product type</figcaption><div id="c_cam_type"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_ca_mom_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_ca_mom"></table></div>
</section>

<!-- ============ 9 EPS ============ -->
<section class="ds" id="eps">
  <div class="ds-head"><h2>9 · The odds feed</h2><span class="file">EPS_Offers.csv</span></div>
  <p class="lede">The largest file, 1.7 GB, and the strangest: eleven million odds changes, all from a single day, 16 August 2026. Every time a price on any market moved, one row.</p>
  <div class="facts" id="f_eps"></div>
  <div class="use">
    <div><h4>One row means</h4><p>One price on one market of one match was valid from this second to that second. Rows pile up because live odds change constantly.</p></div>
    <div><h4>What it could let us do</h4><p>Tell whether the odds moved while a person was hesitating over their betslip. That may be exactly why some people walk away. Not joined yet.</p></div>
    <div><h4>Watch out</h4><p>One day only. And it has no match ID that matches the activity files, so joining needs match names and times.</p></div>
  </div>
  <div class="charts">
    <figure><figcaption>Odds changes by sport<small>Soccer and tennis produce almost all of them</small></figcaption><div id="c_eps_sport"></div></figure>
    <figure><figcaption>Most frequently repriced bet types<small>Top ten markets by number of rows</small></figcaption><div id="c_eps_markets"></div></figure>
  </div>
  <h3>The columns</h3>
  <div class="tbl"><table id="t_eps_cols"></table></div>
  <h3>Three real rows</h3>
  <div class="tbl"><table class="sample" id="s_eps"></table></div>
</section>

<!-- ============ OTHER ============ -->
<section class="ds" id="other">
  <h2>Everything else in the folder</h2>
  <p>Not data, but provided alongside it. Listed so nothing is a mystery.</p>
  <ul class="plain">
    <li><b>Three videos</b> — walkthroughs of the website, the mobile view and native apps, and the casino. Useful for seeing the screens named in files 1 and 2.</li>
    <li><b>empireofgold.zip</b> — the built files of one casino slot game. A glimpse of how a game is delivered to the browser. Not used.</li>
    <li><b>Two architecture images</b> — FEG's approved technology list: Vue.js, Java, Python, .NET, PostgreSQL, Kafka and so on, with the retired items crossed out. Relevant when we build.</li>
    <li><b>Submission guidelines (.docx), EU regulations guide (.pdf), agenda (.pdf)</b> — rules of the hackathon. The guidelines forbid committing any customer data, which is why our customer-level outputs stay out of the repository.</li>
    <li><b>Sample design and specification documents</b> — examples of the wireframes, Figma screens and UML diagrams a submission might include.</li>
  </ul>
</section>
</main>
</div>

<script id="data" type="application/json">__DATA__</script>
<script>
const D = JSON.parse(document.getElementById('data').textContent);
const $ = id => document.getElementById(id);
const fmt = n => n >= 1e6 ? (n/1e6).toFixed(n>=1e7?0:1)+'M' : n >= 1e3 ? (n/1e3).toFixed(n>=1e5?0:1)+'k' : String(Math.round(n));
const fmtFull = n => Math.round(n).toLocaleString('en-GB');
const tip = $('tip');
function showTip(e, html){ tip.innerHTML = html; tip.style.opacity = 1; tip.style.left = (e.clientX + 14) + 'px'; tip.style.top = (e.clientY - 10) + 'px'; }
function hideTip(){ tip.style.opacity = 0; }
const S = ['var(--s1)','var(--s2)','var(--s3)','var(--s4)','var(--s5)'];

// horizontal bars: obj {label: value}
function hbar(el, obj, opt={}){
  const entries = Object.entries(obj).filter(([k,v])=>v!=null).slice(0, opt.n||10);
  const max = Math.max(...entries.map(e=>e[1]));
  const W=520, rowH=22, L=opt.labelW||150, R=54, H=entries.length*rowH+6;
  let s = `<svg viewBox="0 0 ${W} ${H}" role="img">`;
  entries.forEach(([k,v],i)=>{
    const y=i*rowH+3, w=Math.max(2,(W-L-R)*v/max);
    const lab = k.length>24? k.slice(0,23)+'…':k;
    s += `<text class="lbl" x="${L-8}" y="${y+14}" text-anchor="end">${esc(lab)}</text>`;
    s += `<rect x="${L}" y="${y+3}" width="${w}" height="${rowH-9}" rx="3" fill="${opt.color||S[0]}" data-k="${esc(k)}" data-v="${v}"></rect>`;
    s += `<text class="val" x="${L+w+6}" y="${y+14}">${opt.pct? (v*100).toFixed(1)+'%' : (opt.eur?'€':'')+fmt(v)}</text>`;
  });
  s += '</svg>'; $(el).innerHTML = s;
  $(el).querySelectorAll('rect').forEach(r=>{ r.addEventListener('mousemove', e=>showTip(e, `${r.dataset.k}: ${opt.pct?(r.dataset.v*100).toFixed(1)+'%':(opt.eur?'€':'')+fmtFull(+r.dataset.v)}`)); r.addEventListener('mouseleave', hideTip); });
}
// line chart: series = [{name, pts:[[label,value]...], color}]
function line(el, series, opt={}){
  const W=560, H=opt.h||190, L=52, R=14, T=12, B=30;
  const all = series.flatMap(s=>s.pts.map(p=>p[1])).filter(v=>v!=null);
  let lo = opt.zero ? 0 : Math.min(...all), hi = Math.max(...all);
  if (lo===hi){ lo=lo*0.9; hi=hi*1.1; }
  const pad=(hi-lo)*0.08; hi+=pad; if(!opt.zero) lo-=pad;
  const n = series[0].pts.length;
  const x = i => L + (W-L-R)*(n>1? i/(n-1) : 0.5);
  const y = v => T + (H-T-B)*(1-(v-lo)/(hi-lo));
  let s = `<svg viewBox="0 0 ${W} ${H}" role="img">`;
  const ticks = 4;
  for(let t=0;t<=ticks;t++){ const v=lo+(hi-lo)*t/ticks; s+=`<line class="grid" x1="${L}" x2="${W-R}" y1="${y(v)}" y2="${y(v)}"/><text class="val" x="${L-6}" y="${y(v)+4}" text-anchor="end">${opt.pct?(v*100).toFixed(0)+'%':(opt.eur?'€':'')+fmt(v)}</text>`; }
  const labels = series[0].pts.map(p=>p[0]);
  const step = Math.ceil(n/ (opt.maxLabels||8));
  labels.forEach((lb,i)=>{ if(i%step===0 || i===n-1) s+=`<text x="${x(i)}" y="${H-8}" text-anchor="middle">${esc(opt.short? lb.slice(-5): lb)}</text>`; });
  series.forEach((sr,si)=>{
    const col = sr.color||S[si];
    const pts = sr.pts.map((p,i)=>p[1]==null?null:[x(i),y(p[1])]);
    let d='', pen=false; pts.forEach(p=>{ if(!p){pen=false;return;} d+= (pen?'L':'M')+p[0].toFixed(1)+' '+p[1].toFixed(1); pen=true; });
    if(opt.area && series.length===1){ let a=d+`L${x(n-1)} ${y(lo)}L${x(0)} ${y(lo)}Z`; s+=`<path d="${a}" fill="${col}" opacity=".08"/>`; }
    s+=`<path d="${d}" fill="none" stroke="${col}" stroke-width="2" stroke-linejoin="round"/>`;
    pts.forEach((p,i)=>{ if(!p) return; const last=i===n-1; s+=`<circle cx="${p[0]}" cy="${p[1]}" r="${last?4:3}" fill="${col}" stroke="var(--surface)" stroke-width="2" data-k="${esc(sr.name?sr.name+' · ':'')}${esc(labels[i])}" data-v="${sr.pts[i][1]}"/>`; });
    if(series.length>1) s+=`<text x="${x(n-1)+8}" y="${pts[n-1]?pts[n-1][1]+4:0}" class="lbl" font-size="10">${esc(sr.name)}</text>`;
  });
  s+='</svg>'; $(el).innerHTML=s;
  $(el).querySelectorAll('circle').forEach(c=>{ c.addEventListener('mousemove', e=>showTip(e, `${c.dataset.k}: ${opt.pct?(c.dataset.v*100).toFixed(1)+'%':(opt.eur?'€':'')+fmtFull(+c.dataset.v)}`)); c.addEventListener('mouseleave', hideTip); });
}
function esc(s){ return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/"/g,'&quot;'); }
function facts(el, items){ $(el).innerHTML = items.map(([v,l])=>`<div><b>${v}</b><span>${l}</span></div>`).join(''); }
function colsTable(el, rows){ $(el).innerHTML = '<tr><th>Column</th><th>What it holds</th></tr>' + rows.map(([k,d])=>`<tr><td class="k">${esc(k)}</td><td>${d}</td></tr>`).join(''); }
function sample(el, rows, cols){ cols = cols || Object.keys(rows[0]); $(el).innerHTML = '<tr>'+cols.map(c=>`<th>${esc(c)}</th>`).join('')+'</tr>' + rows.map(r=>'<tr>'+cols.map(c=>`<td title="${esc(r[c])}">${esc(r[c]===''?'·':r[c])}</td>`).join('')+'</tr>').join(''); }
const sortObj = o => Object.fromEntries(Object.entries(o).sort((a,b)=>b[1]-a[1]));

// ---- 1 sport log ----
let d = D.sport_log;
facts('f_sport_log', [[fmt(d.rows),'rows (taps)'],[d.players,'customers'],[fmt(d.sessions),'visits'],[d.mb+' MB','file size'],['1–31 Aug','2026']]);
hbar('c_sport_platform', sortObj(d.platform), {labelW:120});
hbar('c_sport_event', sortObj(d.event), {labelW:150, color:S[2]});
line('c_sport_daily', [{pts:Object.entries(d.daily_events)}], {zero:true, short:true, area:true, maxLabels:10});
const logCols = [
 ['event_name','What happened. <b>screen_view</b> / <b>fortuna_screen_view</b> / <b>page_view</b>: a screen was opened (Android / iPhone / web). <b>betslip_add_bet</b>: a pick was added. <b>betslip_placed</b>: the slip was submitted. <b>betslip_placed_bet</b>: one line of a submitted slip. <b>casino_game_launch</b>: a game was opened.'],
 ['session','The visit this tap belongs to. All taps with the same number are one visit.'],
 ['timestamp','When, to the millisecond, in UTC. Croatia is UTC+2 in August.'],
 ['platform','SB iOS = sports app on iPhone. SB Android = sports app on Android. Casino Android = casino app. GM and web = the websites.'],
 ['fortuna_screen_name','Name of the screen, for app taps. Examples: <b>homepage</b>, <b>liveEvents</b>, <b>ticketDetail</b> (looking at an existing bet), <b>betslip</b>.'],
 ['page_location / page_referrer','The web address, for website taps only. Shows psk.hr and casino.psk.hr.'],
 ['added_from','Where a pick was added from: a match page, the live list, bet history, a home-page widget.'],
 ['status','Whether a submitted slip was ACCEPTED, REJECTED or CLOSED. Only on betslip_placed rows.'],
 ['betslip_number / betslip_type','The ticket reference, and its kind: SOLO (one pick), AKO (several picks), LEG_COMBI.'],
 ['sport_name','The sport, in Croatian. Nogomet = football, Tenis = tennis, Košarka = basketball.'],
 ['fixture_id / selection_id','Internal codes for the match and the exact pick.'],
 ['game_name, provider, on_route, on_origin, demo, jackpot','Casino only. Explained in dataset 2.'],
 ['PlayerID','Scrambled customer code. Same code in datasets 5 and 6.'],
];
colsTable('t_sport_cols', logCols);
sample('s_sport_log', d.sample, ['event_name','session','timestamp','platform','fortuna_screen_name','added_from','sport_name','status','PlayerID']);

// ---- 2 casino log ----
d = D.casino_log;
facts('f_casino_log', [[fmt(d.rows),'rows'],[d.players,'customers'],[fmt(d.sessions),'visits'],[fmt(d.platform['Casino Android']),'rows on the casino app'],[d.mb+' MB','file size']]);
hbar('c_casino_platform', sortObj(d.platform), {labelW:120});
hbar('c_casino_event', sortObj(d.event), {labelW:150, color:S[2]});
colsTable('t_casino_cols', [
 ['game_name / provider','Which game was opened, and which studio made it. Example: Sizzling Hot Deluxe by Greentube.'],
 ['on_route','Which page the person was on when they opened the game: <b>my_games</b>, <b>search</b>, <b>lobby</b>, <b>az_games</b>.'],
 ['on_origin / on_origin_name','Which element they tapped: search results, a category row, the grid, a pop-up, the top-10 list. The name is the row title, often in Croatian, e.g. Najigranije = most played.'],
 ['from_route / from_origin','Where they came from before that, usually the menu or the lobby.'],
 ['demo','y if they opened the free play version, n if real money.'],
 ['jackpot','true if the game is a jackpot game.'],
]);
sample('s_casino_log', d.sample, ['event_name','session','timestamp','platform','fortuna_screen_name','game_name','provider','on_route','on_origin','PlayerID']);

// ---- 3 sb trends ----
d = D.sb_trends;
const hr = d.by_brand.hr, cro = d.conv['HTK-CRO'];
facts('f_sb_trends', [['6','markets'],['6','months'],[fmtFull(hr[hr.length-1].sessions),'Croatia visits, Aug'],['€'+hr[hr.length-1].stake_per_session_eur.toFixed(2),'stake per visit, Aug'],[(cro[cro.length-1].session_conversion_rate*100).toFixed(1)+'%','visits ending in a bet, Aug']]);
line('c_hr_sessions', [{pts:hr.map(r=>[r.month,r.sessions])}], {zero:true, area:true});
line('c_hr_conv', [{pts:cro.map(r=>[r.month,r.session_conversion_rate]), color:S[2]}], {pct:true, area:true});
hbar('c_conv_markets', sortObj(Object.fromEntries(Object.entries(d.conv).map(([m,rows])=>[m==='HTK-CRO'?'HTK-CRO (Croatia)':m, rows[rows.length-1].session_conversion_rate]))), {pct:true, labelW:150, color:S[2]});
colsTable('t_sb_trends_cols', [
 ['brand / market','Which country: hr = Croatia (PSK), cz = Czechia, sk = Slovakia, pl = Poland, ro = Romania, cp = another brand. HTK-CRO and HTK-RO are the same Croatia and Romania under a different label.'],
 ['sessions','Number of visits in the month.'],
 ['active_players','Customers who placed at least one bet.'],
 ['stake_per_session_eur','Average money bet per visit.'],
 ['avg_betslips_per_session / avg_sports_per_session','How many tickets, and how many different sports, in an average visit.'],
 ['avg_sessions_per_player','Visits per active customer in the month.'],
 ['session_conversion_rate','Share of visits that ended with a bet. The key number for this challenge.'],
 ['median_session_length_sec','Typical visit length in seconds.'],
 ['median_ttfb_sec / avg_ttfb_sec','Time to first bet: how long from opening to the first bet, in seconds.'],
]);

// ---- 4 casino trends ----
d = D.casino_trends;
const psk = d.by_market.PSK;
facts('f_casino_trends', [['5','markets'],['12','months'],['€'+psk[psk.length-1].stake_per_session.toFixed(0),'PSK stake per visit, Aug'],[psk[psk.length-1].sessions_per_player.toFixed(1),'visits per customer, Aug'],[Math.round(psk[psk.length-1].median_len_s/60)+' min','typical visit, Aug']]);
line('c_psk_stake', [{pts:psk.map(r=>[r.month,r.stake_per_session])}], {eur:true, area:true, short:true});
const ac = Object.entries(d.android_conv);
line('c_psk_conv', [{name:'Android app', pts:ac.map(([m,v])=>[m,+v[0]])},{name:'Website', pts:ac.map(([m,v])=>[m,+v[1]]), color:S[1]}], {pct:true, short:true});
colsTable('t_casino_trends_cols', [
 ['market','CASA, CZ, PSK, RO, SK. PSK is Croatia.'],
 ['stake_per_session','Average money staked per visit, in euros.'],
 ['avg_spins_per_session','How many times the reels were spun in an average visit. Hundreds.'],
 ['avg_games_per_session','How many different games in an average visit. Usually two or three.'],
 ['avg_sessions_per_player','Visits per customer per month.'],
 ['median_session_length_sec','Typical visit length in seconds.'],
 ['session to game conversion %','Second block: share of visits where a game was actually opened, Android app versus website.'],
 ['time to first game launched (sec)','Second block: seconds from opening to the first game, Android app versus website.'],
]);

// ---- 5 sb player ----
d = D.sb_player;
facts('f_sb_player', [[fmt(d.rows),'rows'],[fmtFull(d.players),'customers'],['€'+fmt(d.total_stake),'total stake'],[fmt(d.total_bets),'bets'],['16–31 Aug','2026, 16 days']]);
hbar('c_sbp_sport', d.sport_stake, {eur:true, labelW:120});
hbar('c_sbp_product', sortObj(d.product), {eur:true, labelW:130, color:S[2]});
line('c_sbp_daily', [{pts:Object.entries(d.daily_stake)}], {eur:true, zero:true, area:true, short:true});
colsTable('t_sb_player_cols', [
 ['placed_date','The day the bet was placed.'],
 ['betslip_product','LIVE (during the match), PREMATCH (before it), or WORLD_LOTTERY.'],
 ['Sport_name_english / event_name_english','The sport and the competition, e.g. Football, 1.Italy (Serie A).'],
 ['fixture_name_english','The match, e.g. Lecce - AS Roma.'],
 ['market_name_english / selection_name_english','The bet type and the exact pick, e.g. Total goals 1.5 / + 1.5.'],
 ['no_of_bets','How many bets this customer placed on that pick that day.'],
 ['payin_distribution_amount_local / stake_distribution_amount_local','Money paid in, and money staked after any fee, in local currency (euros).'],
 ['PlayerID','Scrambled customer code, matching datasets 1 and 2.'],
]);
sample('s_sb_player', d.sample, ['placed_date','betslip_product','Sport_name_english','event_name_english','fixture_name_english','market_name_english','selection_name_english','no_of_bets','stake_distribution_amount_local','PlayerID']);

// ---- 6 ca player ----
d = D.ca_player;
facts('f_ca_player', [[fmt(d.rows),'rows'],[fmtFull(d.players),'customers'],['€'+fmt(d.total_stake),'total stake (all spins)'],[d.mb+' MB','file size'],['1–31 Aug','2026']]);
hbar('c_cap_provider', d.provider_stake, {eur:true, labelW:120});
hbar('c_cap_type', d.game_type, {eur:true, labelW:150, color:S[2]});
line('c_cap_daily', [{pts:Object.entries(d.daily_stake)}], {eur:true, zero:true, area:true, short:true});
colsTable('t_ca_player_cols', [
 ['local_transaction_date','The day.'],
 ['reporting_product_group / reporting_product_type','Broad category: eGaming, and whether it is a table game (roulette, blackjack) or not (slots).'],
 ['reporting_provider_info','The studio that made the game: Amusnet, EGT Digital, Playtech, Greentube and so on.'],
 ['reporting_bet_type','An internal code for the exact game.'],
 ['src_game_type','The kind of game, e.g. POP Slots.'],
 ['is_multiplayer_yn','Whether other players are at the same table.'],
 ['total_stake_amt','Total money staked on that game that day, in euros. Every spin counts.'],
 ['PlayerID','Scrambled customer code.'],
]);
sample('s_ca_player', d.sample, ['local_transaction_date','reporting_product_type','reporting_provider_info','src_game_type','total_stake_amt','PlayerID']);

// ---- 7 sb mom ----
d = D.sb_mom;
facts('f_sb_mom', [[fmt(d.rows),'rows'],[d.months.length,'months'],['€'+fmt(Object.values(d.month_stake).reduce((a,b)=>a+b,0)),'total stake'],[fmt(Object.values(d.month_tickets).reduce((a,b)=>a+b,0)),'tickets'],[d.mb+' MB','file size']]);
hbar('c_sbm_sport', d.sport_tickets, {labelW:120});
hbar('c_sbm_events', d.top_events, {labelW:170, color:S[2]});
colsTable('t_sb_mom_cols', [
 ['month_start_date','The month.'],
 ['Sport_name_english / event_name_english / fixture_name_english','Sport, competition, match.'],
 ['market_name_english / selection_name_english','Bet type and exact pick.'],
 ['no_of_tickets','How many tickets included this pick that month.'],
 ['payin_distribution_amount_Euro / stake_distribution_amount_Euro','Money paid in and money staked, in euros, spread across the picks on each ticket.'],
]);
sample('s_sb_mom', d.sample);

// ---- 8 ca mom ----
d = D.ca_mom;
const ms = Object.entries(d.month_stake), mw = Object.entries(d.month_win);
facts('f_ca_mom', [[fmt(d.rows),'rows'],[d.months.length,'months'],['€'+fmt(ms[ms.length-1][1]),'stake, Aug 2026'],['€'+fmt(ms[ms.length-1][1]-mw[mw.length-1][1]),'kept by the house, Aug'],[d.mb+' MB','file size']]);
line('c_cam_month', [{name:'Stake', pts:ms.map(([m,v])=>[m.slice(0,7),v])},{name:'Win', pts:mw.map(([m,v])=>[m.slice(0,7),v]), color:S[1]}], {eur:true, zero:true, short:true, h:210});
hbar('c_cam_provider', d.provider_stake, {eur:true, labelW:120});
hbar('c_cam_type', sortObj(d.product_type), {eur:true, labelW:130, color:S[2]});
colsTable('t_ca_mom_cols', [
 ['month_start_date','The month.'],
 ['reporting_product_group / type / provider_info / bet_type / src_game_type','Same game description columns as dataset 6.'],
 ['total_stake_amt','All money staked on the game that month.'],
 ['bonus_stake_amt / jackpot_stake_amt','How much of that stake was bonus money, and how much fed a jackpot.'],
 ['total_win_amt','All money paid back to players.'],
 ['bonus_win_amt / jackpot_win_amt / jackpot_bonus_win_amt','How much of the winnings came from bonuses or jackpots.'],
]);
sample('s_ca_mom', d.sample, ['month_start_date','reporting_product_type','reporting_provider_info','src_game_type','total_stake_amt','total_win_amt','jackpot_win_amt']);

// ---- 9 eps ----
d = D.eps;
facts('f_eps', [[fmt(d.rows),'rows'],[d.mb>1000?(d.mb/1000).toFixed(1)+' GB':d.mb+' MB','file size'],['16 Aug','2026, one day'],[Object.keys(d.sport).length,'sports'],['0','customers']]);
hbar('c_eps_sport', d.sport, {labelW:110});
hbar('c_eps_markets', d.markets, {labelW:190, color:S[2]});
colsTable('t_eps_cols', [
 ['sport_name / tournament_name / match_name','Sport, competition, match, in English.'],
 ['market_name','The bet type, e.g. Handicap, Player Shots On Goal.'],
 ['current_odds','The price at that moment, as a decimal. 1.11 means a €1 bet returns €1.11.'],
 ['start_datetime_utc / end_datetime_utc','When this price started and stopped being valid. Often only seconds apart.'],
 ['is_current_flag','Y if this is the live price right now, N if it has since changed.'],
]);
sample('s_eps', d.sample);
</script>
'''
html = TEMPLATE.replace('__DATA__', json.dumps(J, ensure_ascii=False).replace('</', '<\\/'))
open(DOCS + "data-atlas.html", "w", encoding="utf8").write(html)
print("written", len(html) // 1000, "KB")
