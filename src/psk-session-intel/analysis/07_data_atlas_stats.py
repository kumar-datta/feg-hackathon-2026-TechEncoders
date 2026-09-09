"""Summary statistics for every provided dataset -> JSON for the data atlas page."""
import pandas as pd, numpy as np, json, os
RAW = "C:/FEG/Fegdetails/"; OUT = "C:/FEG/psk-session-intel/analysis/out/"
J = {}


def sz(f): return round(os.path.getsize(RAW + f) / 1e6, 1)


# --- event logs ---
for key, f in [("sport_log", "top_sport_users_event_logs.csv"), ("casino_log", "top_casino_users_event_logs.csv")]:
    d = pd.read_csv(RAW + f, dtype=str, keep_default_na=False, na_values=['null', ''])
    d['ts'] = pd.to_datetime(d.timestamp.str.replace(' UTC', '').str.replace('Z', ''), format='mixed', utc=True)
    J[key] = {"file": f, "mb": sz(f), "rows": len(d), "cols": list(d.columns), "players": int(d.PlayerID.nunique()), "sessions": int(d.session.nunique()),
              "date_min": str(d.ts.min().date()), "date_max": str(d.ts.max().date()),
              "platform": d.platform.value_counts().to_dict(), "event": d.event_name.value_counts().to_dict(),
              "screens": d.fortuna_screen_name.value_counts().head(12).to_dict(),
              "daily_events": d.ts.dt.date.astype(str).value_counts().sort_index().to_dict(),
              "fill": {c: round(float(d[c].notna().mean()), 3) for c in d.columns},
              "sample": d.drop(columns=['ts']).head(3).fillna("").to_dict(orient='records')}
# --- SB_Player ---
d = pd.read_csv(RAW + "SB_Player.csv", dtype=str, on_bad_lines='skip')
d['stake'] = pd.to_numeric(d.stake_distribution_amount_local, errors='coerce'); d['bets'] = pd.to_numeric(d.no_of_bets, errors='coerce')
J["sb_player"] = {"file": "SB_Player.csv", "mb": sz("SB_Player.csv"), "rows": len(d), "cols": list(d.columns)[:-2], "players": int(d.PlayerID.nunique()),
                  "date_min": str(d.placed_date.min()), "date_max": str(d.placed_date.max()),
                  "sport_stake": d.groupby('Sport_name_english').stake.sum().sort_values(ascending=False).head(10).round(0).to_dict(),
                  "product": d.groupby('betslip_product').stake.sum().round(0).to_dict(),
                  "daily_stake": d.groupby('placed_date').stake.sum().round(0).to_dict(),
                  "total_stake": round(float(d.stake.sum()), 0), "total_bets": int(d.bets.sum()),
                  "sample": d.head(3).drop(columns=['stake', 'bets']).fillna("").to_dict(orient='records')}
# --- CA_Player ---
d = pd.read_csv(RAW + "CA_Player.csv", dtype={'PlayerID': str})
J["ca_player"] = {"file": "CA_Player.csv", "mb": sz("CA_Player.csv"), "rows": len(d), "cols": list(d.columns), "players": int(d.PlayerID.nunique()),
                  "date_min": str(d.local_transaction_date.min()), "date_max": str(d.local_transaction_date.max()),
                  "provider_stake": d.groupby('reporting_provider_info').total_stake_amt.sum().sort_values(ascending=False).head(10).round(0).to_dict(),
                  "game_type": d.groupby('src_game_type').total_stake_amt.sum().sort_values(ascending=False).head(8).round(0).to_dict(),
                  "product_type": d.groupby('reporting_product_type').total_stake_amt.sum().round(0).to_dict(),
                  "daily_stake": d.groupby('local_transaction_date').total_stake_amt.sum().round(0).to_dict(),
                  "total_stake": round(float(d.total_stake_amt.sum()), 0), "sample": d.head(3).fillna("").to_dict(orient='records')}
# --- SB_MOM ---
d = pd.read_csv(RAW + "SB_MOM.csv", dtype=str, on_bad_lines='skip')
for c in ['no_of_tickets', 'stake_distribution_amount_Euro']: d[c] = pd.to_numeric(d[c], errors='coerce')
J["sb_mom"] = {"file": "SB_MOM.csv", "mb": sz("SB_MOM.csv"), "rows": len(d), "cols": list(d.columns), "months": sorted(d.month_start_date.dropna().unique().tolist()),
               "sport_tickets": d.groupby('Sport_name_english').no_of_tickets.sum().sort_values(ascending=False).head(10).to_dict(),
               "month_stake": d.groupby('month_start_date').stake_distribution_amount_Euro.sum().round(0).to_dict(),
               "month_tickets": d.groupby('month_start_date').no_of_tickets.sum().to_dict(),
               "top_events": d.groupby('event_name_english').no_of_tickets.sum().sort_values(ascending=False).head(10).to_dict(),
               "sample": d.head(3).fillna("").to_dict(orient='records')}
# --- CA_MOM ---
d = pd.read_csv(RAW + "CA_MOM.csv")
J["ca_mom"] = {"file": "CA_MOM.csv", "mb": sz("CA_MOM.csv"), "rows": len(d), "cols": list(d.columns), "months": sorted(d.month_start_date.unique().tolist()),
               "month_stake": d.groupby('month_start_date').total_stake_amt.sum().round(0).to_dict(),
               "month_win": d.groupby('month_start_date').total_win_amt.sum().round(0).to_dict(),
               "provider_stake": d.groupby('reporting_provider_info').total_stake_amt.sum().sort_values(ascending=False).head(10).round(0).to_dict(),
               "product_type": d.groupby('reporting_product_type').total_stake_amt.sum().round(0).to_dict(),
               "sample": d.head(3).fillna("").to_dict(orient='records')}
# --- EPS_Offers (chunked) ---
sport = {}; n = 0; tmin = None; tmax = None; sample = None; markets = {}
for ch in pd.read_csv(RAW + "EPS_Offers.csv", dtype=str, chunksize=1_000_000, on_bad_lines='skip'):
    n += len(ch)
    if sample is None: sample = ch.head(3).fillna("").to_dict(orient='records')
    for k, v in ch.sport_name.value_counts().items(): sport[k] = sport.get(k, 0) + int(v)
    for k, v in ch.market_name.value_counts().head(50).items(): markets[k] = markets.get(k, 0) + int(v)
    a = ch.start_datetime_utc.min(); b = ch.start_datetime_utc.max()
    tmin = a if tmin is None or a < tmin else tmin; tmax = b if tmax is None or b > tmax else tmax
J["eps"] = {"file": "EPS_Offers.csv", "mb": sz("EPS_Offers.csv"), "rows": n, "cols": list(ch.columns), "date_min": str(tmin)[:10], "date_max": str(tmax)[:10],
            "sport": dict(sorted(sport.items(), key=lambda x: -x[1])[:10]), "markets": dict(sorted(markets.items(), key=lambda x: -x[1])[:10]), "sample": sample}
# --- trend sheets ---
c = pd.read_excel(RAW + "hackathon_casino_trends.xlsx", header=None)
cas = c.iloc[1:66, :7].copy(); cas.columns = ['market', 'month', 'stake_per_session', 'spins_per_session', 'games_per_session', 'sessions_per_player', 'median_len_s']
cas = cas.dropna(subset=['market']); cas = cas[cas.market != 'market']; cas['month'] = pd.to_datetime(cas.month).dt.strftime('%Y-%m')
J["casino_trends"] = {"file": "hackathon_casino_trends.xlsx", "rows": len(cas), "cols": list(cas.columns),
                      "by_market": {m: g.drop(columns='market').to_dict(orient='records') for m, g in cas.groupby('market')},
                      "android_conv": {pd.to_datetime(c.iloc[i, 1]).strftime('%Y-%m'): [c.iloc[i, 2], c.iloc[i, 3], c.iloc[i, 4], c.iloc[i, 5]] for i in range(68, 80)}}
s = pd.read_excel(RAW + "hackathon_sportsbook_trends.xlsx", header=None)
sb = s.iloc[1:37, :8].copy(); sb.columns = ['brand', 'month', 'sessions', 'active_players', 'stake_per_session_eur', 'betslips_per_session', 'sports_per_session', 'sessions_per_player']
sb = sb.dropna(subset=['brand']); sb['month'] = pd.to_datetime(sb.month).dt.strftime('%Y-%m')
conv = s.iloc[45:81, :4].copy(); conv.columns = ['month', 'market', 'session_conversion_rate', 'median_len_s']; conv = conv.dropna(subset=['market']); conv = conv[conv.market != 'market']; conv['month'] = pd.to_datetime(conv.month).dt.strftime('%Y-%m')
ttfb = s.iloc[85:121, :4].copy(); ttfb.columns = ['month', 'market', 'median_ttfb_s', 'avg_ttfb_s']; ttfb = ttfb.dropna(subset=['market']); ttfb = ttfb[ttfb.market != 'market']; ttfb['month'] = pd.to_datetime(ttfb.month).dt.strftime('%Y-%m')
J["sb_trends"] = {"file": "hackathon_sportsbook_trends.xlsx", "cols": list(sb.columns),
                  "by_brand": {b: g.drop(columns='brand').to_dict(orient='records') for b, g in sb.groupby('brand')},
                  "conv": {m: g.drop(columns='market').to_dict(orient='records') for m, g in conv.groupby('market')},
                  "ttfb": {m: g.drop(columns='market').to_dict(orient='records') for m, g in ttfb.groupby('market')}}


def conv_np(o):
    if isinstance(o, (np.integer,)): return int(o)
    if isinstance(o, (np.floating,)): return None if np.isnan(o) else float(o)
    if isinstance(o, pd.Timestamp): return str(o)
    return str(o)


json.dump(J, open(OUT + "data_atlas_stats.json", "w", encoding="utf8"), default=conv_np, ensure_ascii=False)
print("ok", {k: (v.get('rows'), v.get('mb')) for k, v in J.items()})
