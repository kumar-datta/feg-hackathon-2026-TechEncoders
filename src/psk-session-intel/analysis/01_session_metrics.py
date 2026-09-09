"""Core challenge metrics per platform + daily 7-day moving averages (native apps)."""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width', 250); pd.set_option('display.max_columns', 40)
df = load_events()
s = sessionize(df)
s.to_csv(OUT + "sessions.csv")


def summ(x):
    return pd.Series({
        'sessions': len(x), 'players': x.player.nunique(), 'sessions_per_player': len(x) / x.player.nunique(),
        'session_conversion_rate': x.converted.mean(), 'reach_final_step_rate': x.reached_final.mean(),
        'final_step_conversion': x.final_conv.mean(),
        'actions_per_session': x.n_action.mean(), 'actions_per_converted_session': x[x.converted].n_action.mean(),
        'median_len_s': x.len_s.median(), 'p75_len_s': x.len_s.quantile(.75), 'mean_len_s': x.len_s.mean(),
        'median_ttfa_s': x.ttfa.median(), 'mean_ttfa_s': x.ttfa.mean(), 'median_ttfi_s': x.ttfi.median(),
        'single_event_session_share': (x.n == 1).mean(), 'median_events': x.n.median(), 'median_screens': x.n_screens.median()})


byp = s.groupby('platform').apply(summ).T
byp.round(3).to_csv(OUT + "metrics_by_platform.csv")
print("=== by platform ==="); print(byp.round(3).to_string())
print("\n=== by cohort x platform ==="); print(s.groupby(['src', 'platform']).apply(summ).T.round(3).to_string())

s['len_bin'] = pd.cut(s.len_s, [-1, 0, 30, 120, 300, 900, 1800, 3600, 1e9],
                      labels=['0', '1-30s', '30s-2m', '2-5m', '5-15m', '15-30m', '30-60m', '>60m'])
ct = pd.crosstab(s.len_bin, s.platform, values=s.converted, aggfunc='mean').round(3)
ct.to_csv(OUT + "conversion_by_length_bucket.csv")
print("\n=== conversion by length bucket ==="); print(ct.to_string()); print(pd.crosstab(s.len_bin, s.platform).to_string())

b = s[~s.converted]
print("\n=== browse-only sessions: last screen ===")
for p in APPS + ['GM']:
    print(p); print(b[b.platform == p].last_screen.value_counts(normalize=True).head(8).round(3).to_string())
ab = s[s.reached_final & (s.n_placed == 0)]
print("\n=== final-step abandon (add_bet, no placed) by platform ==="); print(ab.platform.value_counts().to_string())
print(ab.last_screen.value_counts().head(10).to_string())
print("\n=== first screen (apps) ===")
for p in APPS:
    print(p); print(s[s.platform == p].first_screen.value_counts(normalize=True).head(6).round(3).to_string())

ap = s[s.is_app]
h = ap.groupby('hour').agg(sessions=('n', 'size'), conv=('converted', 'mean'), med_len=('len_s', 'median'))
h.round(3).to_csv(OUT + "hourly_apps.csv")
print("\n=== apps by local hour ==="); print(h.round(3).T.to_string())
d = ap.groupby('day').agg(sessions=('n', 'size'), players=('player', 'nunique'), conv=('converted', 'mean'),
                          final=('final_conv', 'mean'), actions=('n_action', 'mean'), med_len=('len_s', 'median'),
                          med_ttfa=('ttfa', 'median'))
d['sess_per_player'] = d.sessions / d.players
for c in ['conv', 'final', 'actions', 'med_len', 'med_ttfa', 'sess_per_player', 'sessions']:
    d[c + '_ma7'] = d[c].rolling(7, min_periods=3).mean()
d.round(3).to_csv(OUT + "daily_app_metrics_ma7.csv")
print("\n=== daily apps + MA7 ==="); print(d.round(3).to_string())
ap = ap.sort_values(['player', 'start'])
ap['gap_min'] = (ap.start - ap.groupby('player').end.shift()).dt.total_seconds() / 60
print("\n=== inter-session gap (min) apps ==="); print(ap.gap_min.describe(percentiles=[.1, .25, .5, .75, .9]).round(1).to_string())
print("share <15min:", (ap.gap_min < 15).mean().round(3), " <30min:", (ap.gap_min < 30).mean().round(3), " <60min:", (ap.gap_min < 60).mean().round(3))
# multi-session same day: does the 2nd+ session of a day convert more (task-driven return)?
ap['sess_idx_day'] = ap.groupby(['player', 'day']).cumcount() + 1
print("\n=== conversion by session index within day (apps) ===")
print(ap.groupby(ap.sess_idx_day.clip(upper=6)).agg(sessions=('n', 'size'), conv=('converted', 'mean'), med_len=('len_s', 'median')).round(3).to_string())
