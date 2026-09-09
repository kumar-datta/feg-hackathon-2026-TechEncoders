"""Cross-session intent at fixture level (standalone, uses raw events so placement rows are present).
 a) After a session where picks were added but nothing placed: did the same player later place a bet on one of those fixtures?
 b) Of fixtures that were placed: what share had been added in an EARLIER session first (multi-session research)?
 c) Repeat behaviour: share of placed fixtures the player had already bet on before in the month.
"""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width', 250)
df = load_events(); S = sessionize(df)
ap = df[df.is_app & df.platform.isin(['SB iOS', 'SB Android'])]
adds = ap[(ap.event_name == 'betslip_add_bet') & ap.fixture_id.notna()][['session', 'PlayerID', 'ts', 'fixture_id']]
placed = ap[(ap.event_name == 'betslip_placed_bet') & ap.fixture_id.notna()][['session', 'PlayerID', 'ts', 'fixture_id']]
print("add rows with fixture:", len(adds), " placed rows with fixture:", len(placed))
placed_first = placed.groupby(['PlayerID', 'fixture_id']).ts.min().to_dict()
SS = S[S.platform.isin(['SB iOS', 'SB Android'])]
aband = SS[SS.reached_final & (SS.n_placed == 0)]
adds_by_sess = adds.groupby('session').fixture_id.agg(lambda x: list(set(x)))
rows = []
for sid, r in aband.iterrows():
    fx = adds_by_sess.get(sid, [])
    if not fx: continue
    later = [placed_first.get((r.player, f)) for f in fx]
    later = [t for t in later if t is not None and t > r.end]
    rows.append({'session': sid, 'platform': r.platform, 'n_fixtures': len(fx), 'later_placed': len(later) > 0,
                 'hours_to_place': (min(later) - r.end).total_seconds() / 3600 if later else np.nan})
D = pd.DataFrame(rows); D.to_csv(OUT + "deferred_intent_fixture.csv", index=False)
print("\n=== (a) abandoned SB app sessions with a known fixture:", len(D))
print("share where an abandoned fixture was later placed by the same player:", round(D.later_placed.mean(), 3))
print("by platform:"); print(D.groupby('platform').later_placed.agg(['size', 'mean']).round(3).to_string())
h = D.hours_to_place.dropna()
print("hours until placed p25/50/75:", h.quantile([.25, .5, .75]).round(1).tolist(), " within 1h:", round((h <= 1).mean(), 3), " within 24h:", round((h <= 24).mean(), 3))
# (b) multi-session research
first_add = adds.sort_values('ts').groupby(['PlayerID', 'fixture_id']).agg(first_add_ts=('ts', 'first'), first_add_session=('session', 'first'))
first_pl = placed.sort_values('ts').groupby(['PlayerID', 'fixture_id']).agg(first_place_ts=('ts', 'first'), place_session=('session', 'first'))
pf = first_pl.join(first_add, how='inner')
pf['researched_earlier'] = (pf.first_add_session != pf.place_session) & (pf.first_add_ts < pf.first_place_ts)
pf['hours_research'] = (pf.first_place_ts - pf.first_add_ts).dt.total_seconds() / 3600
print("\n=== (b) placed fixtures (player x fixture):", len(pf))
print("share first added in an EARLIER session (multi-session research):", round(pf.researched_earlier.mean(), 3))
print("research span hours p25/50/75 (those cases):", pf[pf.researched_earlier].hours_research.quantile([.25, .5, .75]).round(1).tolist())
# (c) repeat betting on same fixture across sessions
pc = placed.groupby(['PlayerID', 'fixture_id']).session.nunique()
print("\n=== (c) share of player-fixture pairs bet on in more than one session:", round((pc > 1).mean(), 3), " mean sessions per fixture:", round(pc.mean(), 2))
