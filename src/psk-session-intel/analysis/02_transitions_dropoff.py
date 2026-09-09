"""Screen transition matrix, loops, drop-off screens and search behaviour on native apps."""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
pd.set_option('display.width',250); pd.set_option('display.max_columns',40)
df=load_events()
ap=df[df.is_app].copy()
ap['next']=ap.groupby('session').screen.shift(-1)
ap['dt_next']=(ap.groupby('session').ts.shift(-1)-ap.ts).dt.total_seconds()
# collapse repeated same-screen events (screen refreshes) into one step
step=ap[(ap.screen!=ap.next)|(ap.next.isna())]
step['next']=step['next'].fillna('EXIT')
for p in APPS:
    x=step[step.platform==p]
    T=pd.crosstab(x.screen,x['next'],normalize='index').round(3)
    keep=x.screen.value_counts().head(14).index
    T=T.loc[keep, [c for c in T.columns if c in list(keep)+['EXIT']]]
    T.to_csv(OUT+f"transition_{p.replace(' ','_')}.csv")
    print(f"\n=== transition matrix {p} (row-normalised, top screens) ==="); print(T.to_string())
    ex=x[x['next']=='EXIT'].screen.value_counts(normalize=True).head(10).round(3)
    print(f"\n--- exit screen share {p} ---"); print(ex.to_string())
# dwell per screen (median seconds before moving on)
dw=ap[ap.screen!=ap.next].groupby(['platform','screen']).dt_next.agg(['median','count']).reset_index()
dw=dw[dw['count']>200].sort_values(['platform','median'],ascending=[True,False])
print("\n=== median dwell seconds per screen (apps, n>200) ==="); print(dw.round(1).to_string())
dw.round(1).to_csv(OUT+"dwell_by_screen.csv")
# ping-pong loops: A->B->A within 60s
ap['prev']=ap.groupby('session').screen.shift(1)
loop=ap[(ap.screen==ap.groupby('session').screen.shift(2))&(ap.screen!=ap.prev)]
print("\n=== A-B-A loops (top pairs, apps) ==="); print(loop.groupby(['platform',loop.screen+' <-> '+loop.prev]).size().sort_values(ascending=False).head(15).to_string())
# search: how often does search lead to an action within the session?
sess_search=ap[ap.screen.str.contains('search',case=False,na=False)].session.unique()
s=ap.groupby('session').agg(platform=('platform','first'),conv=('is_action','any'),n=('ts','size'))
s['used_search']=s.index.isin(sess_search)
print("\n=== search usage vs conversion (apps) ==="); print(s.groupby(['platform','used_search']).agg(sessions=('n','size'),conv=('conv','mean')).round(3).to_string())
# ticket-checking sessions: sessions whose screens are only ticketDetail/ticketHistory/homepage
tick={'ticketDetail','ticketHistory','homepage','splash','my_account','account','menu'}
scr=ap.groupby('session').screen.agg(lambda x:set(x))
s['ticket_only']=scr.reindex(s.index).apply(lambda st: st<=tick)
print("\n=== ticket/account-only sessions (no market browsing) ==="); print(s.groupby('platform').agg(share_ticket_only=('ticket_only','mean'),conv_ticket_only=('conv',lambda c: c[s.loc[c.index,'ticket_only']].mean())).round(3).to_string())
# added_from → placed: which entry point converts intent to placement
ab=df[df.event_name.isin(['betslip_add_bet','betslip_placed'])&df.is_app]
sa=ab.groupby('session').agg(placed=('event_name',lambda e:(e=='betslip_placed').any()))
af=ab[ab.event_name=='betslip_add_bet'].groupby('session').added_from.agg(lambda x:x.mode().iat[0] if len(x.mode()) else None)
sa['added_from']=af
r=sa.groupby('added_from').agg(sessions=('placed','size'),placed_rate=('placed','mean')).sort_values('sessions',ascending=False)
print("\n=== final-step conversion by dominant add-source (apps) ==="); print(r[r.sessions>=30].round(3).to_string())
r.round(3).to_csv(OUT+"final_conv_by_added_from.csv")
# rejected / failed placements
st=df[df.event_name=='betslip_placed'].groupby(['platform','status']).size().unstack(fill_value=0)
print("\n=== placement status by platform ==="); print(st.to_string())
