"""Final-step abandonment anatomy, live vs prematch, deferred intent, session archetypes (KMeans)."""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width',250); pd.set_option('display.max_columns',40)
df=load_events(); S=sessionize(df)
ap=df[df.is_app]; SA=S[S.is_app].copy()
# --- final step anatomy on SB apps ---
sb=ap[ap.platform.isin(['SB iOS','SB Android'])]
adds=sb[sb.event_name=='betslip_add_bet']; placed=sb[sb.event_name=='betslip_placed']
sess=SA[SA.platform.isin(['SB iOS','SB Android'])&SA.reached_final].copy()
last_add=adds.groupby('session').ts.max(); first_place=placed.groupby('session').ts.min()
sess['last_add']=last_add; sess['first_place']=first_place
sess['tail_after_last_add_s']=(sess.end-sess.last_add).dt.total_seconds()
sess['intent_to_place_s']=(sess.first_place-sess.first_intent).dt.total_seconds()
ab=sess[sess.n_placed==0]; ok=sess[sess.n_placed>0]
print("=== SB apps: sessions reaching final step:",len(sess)," abandoned:",len(ab),f"({len(ab)/len(sess):.1%})")
print("adds per session  abandoned vs placed:",ab.n_add.median(),ok.n_add.median()," mean:",round(ab.n_add.mean(),1),round(ok.n_add.mean(),1))
print("seconds from last add to session end (abandoned) p25/50/75:",ab.tail_after_last_add_s.quantile([.25,.5,.75]).round(0).tolist())
print("seconds first add -> first placement (placed) p25/50/75:",ok.intent_to_place_s.quantile([.25,.5,.75]).round(0).tolist())
print("abandoned sessions: share reaching betslip screen:",ab.index.isin(sb[sb.screen=='betslip'].session).mean().round(3))
print("abandoned by platform:"); print(ab.platform.value_counts().to_string())
print("abandoned by hour (share of final-step sessions abandoned):")
print(sess.groupby('hour').apply(lambda x:(x.n_placed==0).mean()).round(3).to_string())
# live vs prematch entry
af=adds.dropna(subset=['added_from']).groupby('session').added_from.agg(lambda x:x.mode().iat[0])
live_src={'live_page','liveDetail'}
sess['entry']=af.reindex(sess.index).map(lambda a:'live' if a in live_src else ('history' if a in {'betslip_history','betslip-history-overview','afterbet','after_bet'} else 'prematch/other'))
print("\n=== final-step conversion by entry type ==="); print(sess.groupby(['platform','entry']).agg(n=('n','size'),placed=('n_placed',lambda x:(x>0).mean())).round(3).to_string())
# deferred intent: abandoned session -> does the same player place within next session(s) same day?
SA=SA.sort_values(['player','start']); SA['next_placed']=SA.groupby('player').n_placed.shift(-1); SA['next_gap_min']=(SA.groupby('player').start.shift(-1)-SA.end).dt.total_seconds()/60
d=SA.loc[ab.index]
print("\n=== deferred intent: after an abandoned final step ===")
print("next session within 60min:",(d.next_gap_min<60).mean().round(3)," next session places a bet:",(d.next_placed>0).mean().round(3)," both:",((d.next_gap_min<60)&(d.next_placed>0)).mean().round(3))
# rejections: by betslip type & platform
pl=placed.copy(); pl['ok']=pl.status.eq('ACCEPTED')
print("\n=== placement acceptance by platform x betslip_type ==="); print(pl.groupby(['platform',pl.betslip_type.str.upper()]).ok.agg(['size','mean']).round(3).to_string())
# --- session archetypes (apps) ---
feat=SA[['len_s','n','n_screens','n_add','n_placed','n_launch']].copy()
feat['log_len']=np.log1p(feat.len_s); feat['log_n']=np.log1p(feat.n)
scr=ap.groupby('session').screen.agg(lambda x:x.value_counts(normalize=True).to_dict())
def share(keys): return scr.apply(lambda d:sum(d.get(k,0) for k in keys)).reindex(feat.index).fillna(0)
feat['share_ticket']=share(['ticketDetail','ticketHistory','ticket'])
feat['share_live']=share(['liveDetail','liveEvents'])
feat['share_prematch']=share(['prematchDetail','prematchLeagues','prematchMatchesOverview','prematchSports','competition_detail'])
feat['share_account']=share(['my_account','account','accounts_web_view','webViewunknown','menu'])
feat['share_search']=share(['search','searchPrematch','searchLive','searchHomepage'])
feat['share_casino']=share(['my_games','lobby','search','az_games','user-my-games'])
X=feat[['log_len','log_n','share_ticket','share_live','share_prematch','share_account','share_search','n_add','n_placed','n_launch']].copy()
X['n_add']=np.log1p(X.n_add); X['n_placed']=np.log1p(X.n_placed); X['n_launch']=np.log1p(X.n_launch)
from sklearn.preprocessing import StandardScaler; from sklearn.cluster import KMeans
Z=StandardScaler().fit_transform(X)
km=KMeans(n_clusters=7,n_init=10,random_state=0).fit(Z); SA['cluster']=km.labels_
prof=SA.groupby('cluster').agg(sessions=('n','size'),share=('n',lambda x:len(x)/len(SA)),conv=('converted','mean'),med_len_s=('len_s','median'),med_events=('n','median'),
    adds=('n_add','mean'),placed=('n_placed','mean'),launch=('n_launch','mean'),final_conv=('final_conv','mean'),med_ttfa=('ttfa','median'),
    ios=('platform',lambda p:(p=='SB iOS').mean()),android=('platform',lambda p:(p=='SB Android').mean()),casino=('platform',lambda p:(p=='Casino Android').mean()))
prof=prof.join(feat.groupby(SA.cluster)[['share_ticket','share_live','share_prematch','share_account','share_search']].mean())
print("\n=== session archetypes (KMeans k=7, apps) ==="); print(prof.round(2).sort_values('share',ascending=False).to_string())
prof.round(3).to_csv(OUT+"session_archetypes.csv"); SA[['platform','player','cluster','converted','len_s','n']].to_csv(OUT+"sessions_with_cluster.csv")
