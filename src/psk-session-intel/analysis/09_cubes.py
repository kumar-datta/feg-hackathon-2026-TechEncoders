"""Data cubes: multidimensional aggregates over sessions, funnel, time, casino launches and betting markets.
Each cube is written as a flat CSV (all dimension columns + measures) so it can be sliced in any tool.
Also builds a per-player 'breadth' segment (specialist vs focused) from SB_Player as a tenure proxy.
"""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width', 250); pd.set_option('display.max_columns', 60)
df = load_events(); S = sessionize(df)
ap = df[df.is_app].copy(); SA = S[S.is_app].copy()

# ---------- player breadth segment (tenure/specialist proxy) ----------
sbp = pd.read_csv(RAW + "SB_Player.csv", dtype=str, on_bad_lines='skip')
sbp = sbp[sbp.PlayerID.isin(S.player.unique())].copy()
sbp['stake'] = pd.to_numeric(sbp.stake_distribution_amount_local, errors='coerce'); sbp['bets'] = pd.to_numeric(sbp.no_of_bets, errors='coerce')
pb = sbp.groupby('PlayerID').agg(n_sports=('Sport_name_english', 'nunique'), n_leagues=('event_name_english', 'nunique'),
                                 n_markets=('market_name_english', 'nunique'), n_fixtures=('fixture_name_english', 'nunique'),
                                 bets=('bets', 'sum'), stake=('stake', 'sum'),
                                 live_share=('betslip_product', lambda x: (x == 'LIVE').mean()))
pb['stake_per_bet'] = pb.stake / pb.bets
pb['markets_per_bet'] = pb.n_markets / pb.bets
# breadth = distinct market types; terciles among log players with sportsbook rows
pb['breadth'] = pd.qcut(pb.n_markets.rank(method='first'), 3, labels=['focused', 'mid', 'broad'])
pb.to_csv(OUT + "player_breadth.csv")
print("=== player breadth segments (from SB_Player, 16-31 Aug) ==="); print(pb.groupby('breadth').agg(players=('bets', 'size'), med_markets=('n_markets', 'median'), med_sports=('n_sports', 'median'), med_bets=('bets', 'median'), med_stake_per_bet=('stake_per_bet', 'median'), live_share=('live_share', 'mean')).round(2).to_string())
SA['breadth'] = SA.player.map(pb.breadth).astype(object).fillna('no_sb_rows')

# archetype labels
clus = pd.read_csv(OUT + "sessions_with_cluster.csv", index_col=0); clus.index = clus.index.astype(str)
names = {0: 'ticket_check', 3: 'glance', 5: 'prematch_browse', 6: 'live_follow', 1: 'marathon', 2: 'account', 4: 'casino'}
SA['archetype'] = clus.cluster.reindex(SA.index).map(names).fillna('unknown')
SA['hour_band'] = pd.cut(SA.hour, [-1, 5, 11, 17, 23], labels=['night_00-05', 'morning_06-11', 'afternoon_12-17', 'evening_18-23'])
SA['weekend'] = np.where(SA.dow >= 5, 'weekend', 'weekday')
SA = SA.sort_values(['player', 'start'])
SA['sess_idx_day'] = SA.groupby(['player', 'day']).cumcount() + 1
SA['sess_idx_band'] = pd.cut(SA.sess_idx_day, [0, 1, 3, 6, 100], labels=['1st', '2nd-3rd', '4th-6th', '7th+'])
SA['len_band'] = pd.cut(SA.len_s, [-1, 30, 300, 1800, 1e9], labels=['<30s', '30s-5m', '5-30m', '>30m'])
SA['first_screen_grp'] = SA.first_screen.replace({'unnamed_screen': 'unnamed'}).where(SA.first_screen.isin(['homepage', 'ticketHistory', 'ticketDetail', 'liveEvents', 'liveDetail', 'my_account', 'unnamed_screen', 'my_games', 'search', 'lobby', 'splash']), 'other')


def measures(g):
    return pd.Series({'sessions': len(g), 'players': g.player.nunique(), 'conv_rate': g.converted.mean(), 'reach_final': g.reached_final.mean(),
                      'final_conv': g.final_conv.mean(), 'actions_per_session': g.n_action.mean(), 'adds_per_session': g.n_add.mean(),
                      'med_ttfa_s': g.ttfa.median(), 'med_len_s': g.len_s.median(), 'single_event_share': (g.n == 1).mean()})


def cube(name, dims, min_n=20):
    c = SA.groupby(dims, observed=True).apply(measures, include_groups=False).reset_index()
    c = c[c.sessions >= min_n].round(3); c.to_csv(OUT + f"cube_{name}.csv", index=False); return c


# ---------- CUBE 1: session cube ----------
c1 = cube("session", ['platform', 'archetype', 'breadth', 'hour_band', 'weekend', 'sess_idx_band'], min_n=1)
print("\n=== CUBE 1 session (platform x archetype x breadth x hour x weekend x index): rows", len(c1))
print("\n-- slice: breadth x platform (sportsbook apps) --")
print(SA[SA.platform.isin(['SB iOS', 'SB Android'])].groupby(['breadth', 'platform'], observed=True).apply(measures, include_groups=False).round(3).to_string())
print("\n-- slice: archetype x breadth (share of sessions) --")
print(pd.crosstab(SA.breadth, SA.archetype, normalize='index').round(3).to_string())
print("\n-- slice: hour_band x weekend --")
print(SA.groupby(['hour_band', 'weekend'], observed=True).apply(measures, include_groups=False).round(3).to_string())
print("\n-- slice: first screen x platform --")
print(SA.groupby(['platform', 'first_screen_grp'], observed=True).apply(measures, include_groups=False).query('sessions>=40').round(3).to_string())

# ---------- CUBE 2: funnel cube ----------
adds = ap[ap.event_name == 'betslip_add_bet']
fa = adds.groupby('session').agg(add_src=('added_from', lambda x: x.dropna().mode().iat[0] if x.notna().any() else 'unknown'),
                                 n_add_events=('ts', 'size'), sport=('sport_name', lambda x: x.dropna().str.lower().mode().iat[0] if x.notna().any() else 'unknown'))
pl = ap[ap.event_name == 'betslip_placed'].groupby('session').agg(btype=('betslip_type', lambda x: x.dropna().str.upper().mode().iat[0] if x.notna().any() else 'unknown'),
                                                                   accepted=('status', lambda x: (x == 'ACCEPTED').any()), n_placed_events=('ts', 'size'))
F = SA[SA.reached_final].join(fa).join(pl)
F['btype'] = F.btype.fillna('not_placed'); F['accepted'] = F.accepted.fillna(False)
F['entry'] = F.add_src.map(lambda a: 'live' if a in {'live_page'} else ('history' if a in {'betslip_history', 'betslip-history-overview', 'afterbet', 'after_bet'} else ('widget' if 'widget' in str(a) or 'most_bet' in str(a) or 'precanned' in str(a) or 'premade' in str(a) else 'prematch_page')))
F['adds_band'] = pd.cut(F.n_add, [0, 1, 3, 8, 1e9], labels=['1', '2-3', '4-8', '9+'])
c2 = F.groupby(['platform', 'entry', 'adds_band', 'breadth', 'hour_band'], observed=True).agg(sessions=('n', 'size'), placed_rate=('n_placed', lambda x: (x > 0).mean()), accepted_rate=('accepted', 'mean'), med_ttfi=('ttfi', 'median')).reset_index()
c2 = c2[c2.sessions >= 10].round(3); c2.to_csv(OUT + "cube_funnel.csv", index=False)
print("\n=== CUBE 2 funnel: rows", len(c2))
print("\n-- slice: entry x adds_band (SB apps) --")
print(F.groupby(['entry', 'adds_band'], observed=True).agg(sessions=('n', 'size'), placed_rate=('n_placed', lambda x: (x > 0).mean())).round(3).unstack('adds_band').to_string())
print("\n-- slice: platform x betslip type -> accepted --")
print(F[F.btype != 'not_placed'].groupby(['platform', 'btype']).accepted.agg(['size', 'mean']).round(3).to_string())
print("\n-- slice: breadth x entry -> placed --")
print(F.groupby(['breadth', 'entry'], observed=True).agg(sessions=('n', 'size'), placed_rate=('n_placed', lambda x: (x > 0).mean())).round(3).unstack('entry').to_string())

# ---------- CUBE 3: time cube ----------
SA['night'] = SA.hour.between(0, 5); SA['long2h'] = SA.len_s > 7200
c3 = SA.groupby(['day', 'hour', 'platform'], observed=True).agg(sessions=('n', 'size'), players=('player', 'nunique'), conv=('converted', 'mean'), actions=('n_action', 'sum'), long2h=('long2h', 'sum')).reset_index().round(3)
c3.to_csv(OUT + "cube_time.csv", index=False)
print("\n=== CUBE 3 time: rows", len(c3))
dh = SA.groupby(['weekend', 'hour'], observed=True).agg(sessions=('n', 'size'), conv=('converted', 'mean')).unstack('weekend').round(3)
print(dh.to_string())

# ---------- CUBE 4: casino launch cube ----------
L = ap[(ap.event_name == 'casino_game_launch') & (ap.platform == 'Casino Android')].copy().sort_values('ts')
L['repeat'] = L.groupby(['PlayerID', 'game_name']).cumcount() > 0
L['origin'] = L.on_origin.fillna('unlogged'); L['route'] = L.on_route.fillna('unlogged'); L['demo'] = L.demo.fillna('n').replace({'true': 'y'})
c4 = L.groupby(['route', 'origin', 'demo', 'provider'], observed=True).agg(launches=('ts', 'size'), players=('PlayerID', 'nunique'), repeat_share=('repeat', 'mean'), games=('game_name', 'nunique')).reset_index()
c4 = c4[c4.launches >= 5].round(3); c4.to_csv(OUT + "cube_casino.csv", index=False)
print("\n=== CUBE 4 casino launches: rows", len(c4))
print(L.groupby(['route', 'origin']).agg(launches=('ts', 'size'), repeat_share=('repeat', 'mean'), games=('game_name', 'nunique')).query('launches>=20').round(3).to_string())
print("\n-- demo vs real: repeat share --"); print(L.groupby('demo').agg(launches=('ts', 'size'), repeat_share=('repeat', 'mean'), games=('game_name', 'nunique')).round(3).to_string())

# ---------- CUBE 5: market cube (SB_Player, all 15.7k customers) ----------
sb_all = pd.read_csv(RAW + "SB_Player.csv", dtype=str, on_bad_lines='skip')
sb_all['stake'] = pd.to_numeric(sb_all.stake_distribution_amount_local, errors='coerce'); sb_all['bets'] = pd.to_numeric(sb_all.no_of_bets, errors='coerce')
c5 = sb_all.groupby(['Sport_name_english', 'betslip_product', 'market_name_english']).agg(bets=('bets', 'sum'), stake=('stake', 'sum'), players=('PlayerID', 'nunique')).reset_index()
c5 = c5[c5.bets >= 20].round(1).sort_values('bets', ascending=False); c5.to_csv(OUT + "cube_market.csv", index=False)
print("\n=== CUBE 5 market (sport x product x market): rows", len(c5))
print(c5.head(15).to_string())


def pareto(series, label):
    s = series.sort_values(ascending=False).values; cum = np.cumsum(s) / s.sum(); n = len(s)
    return {f'{label}_n': n, 'top1%_share': round(float(cum[max(0, int(n * .01) - 1)]), 3), 'top10%_share': round(float(cum[max(0, int(n * .10) - 1)]), 3), 'items_for_80%': int(np.searchsorted(cum, 0.8) + 1)}


print("\n-- concentration of bets (all customers, 16-31 Aug) --")
for col in ['fixture_name_english', 'market_name_english', 'event_name_english']:
    print(pareto(sb_all.groupby(col).bets.sum(), col))
# per-player market repertoire across ALL customers (novice vs specialist at population level)
pp = sb_all.groupby('PlayerID').agg(n_markets=('market_name_english', 'nunique'), n_sports=('Sport_name_english', 'nunique'), bets=('bets', 'sum'), stake=('stake', 'sum'), live_share=('betslip_product', lambda x: (x == 'LIVE').mean()))
pp['band'] = pd.cut(pp.n_markets, [0, 1, 3, 10, 30, 1e9], labels=['1 market', '2-3', '4-10', '11-30', '31+'])
print("\n-- population: customers by number of distinct market types used (16 days) --")
print(pp.groupby('band', observed=True).agg(customers=('bets', 'size'), share=('bets', lambda x: len(x) / len(pp)), med_bets=('bets', 'median'), med_stake=('stake', 'median'), live_share=('live_share', 'mean'), stake_share=('stake', lambda x: x.sum() / pp.stake.sum())).round(3).to_string())
pp.to_csv(OUT + "population_player_breadth.csv")

# ---------- CUBE 6: SB_MOM month x sport x market ----------
mom = pd.read_csv(RAW + "SB_MOM.csv", dtype=str, on_bad_lines='skip')
for c in ['no_of_tickets', 'stake_distribution_amount_Euro']: mom[c] = pd.to_numeric(mom[c], errors='coerce')
c6 = mom.groupby(['month_start_date', 'Sport_name_english', 'market_name_english']).agg(tickets=('no_of_tickets', 'sum'), stake=('stake_distribution_amount_Euro', 'sum'), fixtures=('fixture_name_english', 'nunique')).reset_index()
c6 = c6[c6.tickets >= 50].round(0).sort_values(['month_start_date', 'tickets'], ascending=[True, False]); c6.to_csv(OUT + "cube_mom.csv", index=False)
print("\n=== CUBE 6 SB_MOM month x sport x market: rows", len(c6))
print("-- market long tail per month: markets needed for 80% of tickets --")
for m, g in c6.groupby('month_start_date'):
    print(m, pareto(g.set_index(['Sport_name_english', 'market_name_english']).tickets, 'markets'))
SA.to_csv(OUT + "sessions_enriched.csv")
print("\ncubes written:", [f for f in ['cube_session', 'cube_funnel', 'cube_time', 'cube_casino', 'cube_market', 'cube_mom']])
