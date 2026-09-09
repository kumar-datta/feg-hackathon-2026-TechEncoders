"""PSK monthly trend sheets (casino PSK, sportsbook hr / HTK-CRO): 3-month moving averages, YoY-free deltas, seasonality."""
import pandas as pd, numpy as np
RAW="C:/FEG/Fegdetails/"; OUT="C:/FEG/psk-session-intel/analysis/out/"
pd.set_option('display.width',250)
c=pd.read_excel(RAW+"hackathon_casino_trends.xlsx",header=None)
hdr=['market','month','stake_per_session','spins_per_session','games_per_session','sessions_per_player','median_len_s']
cas=c.iloc[1:66,:7]; cas.columns=hdr; cas=cas.dropna(subset=['market']); cas=cas[cas.market!='market']
cas['month']=pd.to_datetime(cas.month); num=hdr[2:]; cas[num]=cas[num].astype(float)
psk=cas[cas.market=='PSK'].set_index('month').sort_index()
for k in num: psk[k+'_ma3']=psk[k].rolling(3).mean(); psk[k+'_mom%']=psk[k].pct_change()*100
psk['stake_per_spin']=psk.stake_per_session/psk.spins_per_session
psk['conv_android']=c.iloc[68:80,2].astype(float).values; psk['conv_gm_web']=c.iloc[68:80,3].astype(float).values
psk['ttfg_android_s']=pd.to_numeric(c.iloc[68:80,4],errors='coerce').values; psk['ttfg_gm_web_s']=pd.to_numeric(c.iloc[68:80,5],errors='coerce').values
psk.round(3).to_csv(OUT+"psk_casino_monthly_ma3.csv"); print("=== PSK casino monthly (+MA3, MoM%) ==="); print(psk.round(2).to_string())
print("\nPSK vs other markets Aug-2026:"); print(cas[cas.month=='2026-08-01'].set_index('market')[num].round(2).to_string())
print("\ncorr across PSK months:"); print(psk[num+['stake_per_spin','conv_android']].corr().round(2).to_string())
s=pd.read_excel(RAW+"hackathon_sportsbook_trends.xlsx",header=None)
sb=s.iloc[1:37,:8]; sb.columns=['brand','month','sessions','active_players','stake_per_session_eur','betslips_per_session','sports_per_session','sessions_per_player']
sb=sb.dropna(subset=['brand']); sb['month']=pd.to_datetime(sb.month); n2=sb.columns[2:]; sb[n2]=sb[n2].astype(float)
hr=sb[sb.brand=='hr'].set_index('month').sort_index()
hr['value_per_active_player']=hr.stake_per_session_eur*hr.sessions_per_player
for k in n2: hr[k+'_ma3']=hr[k].rolling(3).mean()
conv=s.iloc[45:81,:4]; conv.columns=['month','market','session_conversion_rate','median_len_s']; conv=conv.dropna(subset=['market']); conv=conv[conv.market!='market']
conv['month']=pd.to_datetime(conv.month)
cro=conv[conv.market=='HTK-CRO'].set_index('month').sort_index().drop(columns='market').astype(float)
ttfb=s.iloc[85:121,:6]; ttfb.columns=['month','market','median_ttfb_s','avg_ttfb_s','median_ttfb_min','avg_ttfb_min']; ttfb=ttfb.dropna(subset=['market']); ttfb=ttfb[ttfb.market!='market']; ttfb['month']=pd.to_datetime(ttfb.month)
cro_t=ttfb[ttfb.market=='HTK-CRO'].set_index('month').sort_index()
hr=hr.join(cro[['session_conversion_rate','median_len_s']]).join(cro_t[['median_ttfb_s','avg_ttfb_s']].astype(float))
hr['session_conversion_rate_ma3']=hr.session_conversion_rate.rolling(3).mean()
hr['sessions_per_conversion']=1/hr.session_conversion_rate
hr.round(3).to_csv(OUT+"psk_sportsbook_monthly_ma3.csv"); print("\n=== PSK/hr sportsbook monthly (+HTK-CRO conv, TTFB) ==="); print(hr.round(3).T.to_string())
print("\nAll markets sportsbook conversion Aug-2026:"); print(conv[conv.month=='2026-08-01'].set_index('market').round(3).to_string())
print("\ncorr hr months:"); print(hr[['sessions','stake_per_session_eur','betslips_per_session','sports_per_session','sessions_per_player','session_conversion_rate','median_len_s','median_ttfb_s']].corr().round(2).to_string())
