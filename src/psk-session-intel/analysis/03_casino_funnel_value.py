"""Casino Android funnel (discovery origin -> launch), value per session via CA_Player/SB_Player join, harmful-play indicators."""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width',250); pd.set_option('display.max_columns',40)
df=load_events()
ca=df[df.platform=='Casino Android']
L=ca[ca.event_name=='casino_game_launch']
print("=== Casino Android launches by discovery origin ==="); print(L.on_origin.value_counts(dropna=False).to_string())
print("\n=== launches by on_route (page where launched) ==="); print(L.on_route.value_counts(dropna=False).head(12).to_string())
print("\n=== demo share ==="); print(L.demo.value_counts(normalize=True).round(3).to_string())
print("\n=== on_origin_name (row/category names) top ==="); print(L.on_origin_name.value_counts().head(15).to_string())
# repeat vs new game per player
L=L.sort_values('ts'); L['seen']=L.groupby(['PlayerID','game_name']).cumcount()>0
print("\nshare launches that are repeat of a game already played this month:",L.seen.mean().round(3))
print("distinct games per player (Casino Android):"); print(L.groupby('PlayerID').game_name.nunique().describe().round(1).to_string())
# search_results vs category rows: launch within session after search screen
s=sessionize(ca)
srch=ca[ca.screen.eq('search')].session.unique(); s['used_search']=s.index.isin(srch)
print("\n=== Casino Android sessions: search vs not ==="); print(s.groupby('used_search').agg(sessions=('n','size'),conv=('converted','mean'),med_ttfa=('ttfa','median'),med_len=('len_s','median')).round(2).to_string())
# time from session start to first launch, by first screen
print("\n=== TTFA by first screen (Casino Android) ==="); print(s.groupby('first_screen').agg(n=('n','size'),conv=('converted','mean'),med_ttfa=('ttfa','median')).query('n>=30').round(2).to_string())
# ---- Value per session: join daily stakes ----
S=sessionize(df); S=S[S.is_app]
cap=pd.read_csv(RAW+"CA_Player.csv",dtype={'PlayerID':str})
cap=cap[cap.PlayerID.isin(S.player.unique())]; cap['day']=pd.to_datetime(cap.local_transaction_date).dt.date
cad=cap.groupby(['PlayerID','day']).total_stake_amt.sum().rename('casino_stake')
sbp=pd.read_csv(RAW+"SB_Player.csv",dtype=str,on_bad_lines='skip')
sbp=sbp[sbp.PlayerID.isin(S.player.unique())].copy()
sbp['stake']=pd.to_numeric(sbp.stake_distribution_amount_local,errors='coerce'); sbp['bets']=pd.to_numeric(sbp.no_of_bets,errors='coerce')
sbp['day']=pd.to_datetime(sbp.placed_date,errors='coerce').dt.date
sbd=sbp.groupby(['PlayerID','day']).agg(sb_stake=('stake','sum'),sb_bets=('bets','sum'))
pd_=S.groupby(['player','day']).agg(sessions=('n','size'),conv_sessions=('converted','sum'),actions=('n_action','sum'),placed=('n_placed','sum'),launches=('n_launch','sum'),total_len_min=('len_s',lambda x:x.sum()/60))
pd_.index.names=['PlayerID','day']
j=pd_.join(cad,how='left').join(sbd,how='left').fillna(0)
j['value_per_session_eur']=(j.casino_stake+j.sb_stake)/j.sessions
j.to_csv(OUT+"player_day_value.csv")
print("\n=== player-day join coverage: rows",len(j)," with any stake:",((j.casino_stake+j.sb_stake)>0).mean().round(3))
print("value per session (EUR stake) describe:"); print(j.value_per_session_eur.describe(percentiles=[.25,.5,.75,.9]).round(1).to_string())
print("\n=== value per session by sessions/day bucket (does more sessions = more value?) ===")
j['sess_bin']=pd.cut(j.sessions,[0,1,2,4,8,100],labels=['1','2','3-4','5-8','9+'])
print(j.groupby('sess_bin').agg(player_days=('sessions','size'),stake_per_day=('casino_stake',lambda x:(x+j.loc[x.index,'sb_stake']).mean()),vps=('value_per_session_eur','median'),conv_share=('conv_sessions',lambda c:(c/j.loc[c.index,'sessions']).mean())).round(1).to_string())
# correlation between session log placements and SB_Player bets (sanity)
print("\ncorr(log placed betslips, SB_Player no_of_bets) per player-day:",j[['placed','sb_bets']].corr().iloc[0,1].round(3))
# ---- Harmful-play indicators (top users, apps) ----
S=S.sort_values(['player','start'])
S['gap_min']=(S.start-S.groupby('player').end.shift()).dt.total_seconds()/60
night=S.hour.between(0,5)
ind=pd.DataFrame({
 'sessions_per_day_p90':S.groupby(['player','day']).size().groupby('player').quantile(.9),
 'share_night_sessions':night.groupby(S.player).mean(),
 'share_sessions_gt60min':(S.len_s>3600).groupby(S.player).mean(),
 'share_sessions_gt120min':(S.len_s>7200).groupby(S.player).mean(),
 'share_reopen_lt15min':(S.gap_min<15).groupby(S.player).mean(),
 'active_days':S.groupby('player').day.nunique(),
 'max_placed_in_session':S.groupby('player').n_placed.max(),
 'sessions':S.groupby('player').size()})
ind.to_csv(OUT+"player_harm_indicators.csv")
print("\n=== harmful-play indicator distribution across top app users ==="); print(ind.describe(percentiles=[.5,.75,.9]).round(2).T.to_string())
flag=(ind.active_days>=25)&((ind.share_night_sessions>.2)|(ind.share_sessions_gt120min>.15)|(ind.sessions_per_day_p90>=8))
print("players flagged by simple rule:",flag.sum(),"of",len(ind))
