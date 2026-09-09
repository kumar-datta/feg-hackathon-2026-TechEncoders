"""Shared loader for PSK (brand=hr) app event logs.
Used via exec(open(...).read()) by the numbered scripts. All paths Windows-style.
"""
import pandas as pd, numpy as np
RAW = "C:/FEG/Fegdetails/"
OUT = "C:/FEG/psk-session-intel/analysis/out/"
APPS = ['SB iOS', 'SB Android', 'Casino Android']     # native apps = focus of this project
WEB = ['GM', 'web']                                   # web front-ends, comparison only
ACTION_EVENTS = {'betslip_placed', 'casino_game_launch'}  # "completed action" (help.md)
INTENT_EVENT = 'betslip_add_bet'                      # entry into the final step (help.md)


def load_events():
    ca = pd.read_csv(RAW + "top_casino_users_event_logs.csv", dtype=str, keep_default_na=False, na_values=['null', ''])
    sb = pd.read_csv(RAW + "top_sport_users_event_logs.csv", dtype=str, keep_default_na=False, na_values=['null', ''])
    ca['src'] = 'casino_top'
    sb['src'] = 'sport_top'
    df = pd.concat([ca, sb], ignore_index=True)
    df['ts'] = pd.to_datetime(df.timestamp.str.replace(' UTC', '').str.replace('Z', ''), format='mixed', utc=True)
    df = df.sort_values(['session', 'ts']).reset_index(drop=True)
    # unified screen label: native screen name > casino route > web path > event name
    df['screen'] = (df.fortuna_screen_name.fillna(df.on_route)
                    .fillna(df.page_location.str.replace(r'\?.*', '', regex=True).str.replace('https://', '', regex=False))
                    .fillna(df.event_name))
    # Android quirk: every screen fires a blank `screen_view` plus a named one ~0s apart.
    # Merge: a blank screen_view takes the name of the adjacent named row in the same session within 2s.
    blank = df.event_name.eq('screen_view') & df.screen.eq('screen_view')
    same_next = df.session.eq(df.session.shift(-1)) & ((df.ts.shift(-1) - df.ts).dt.total_seconds().abs() <= 2)
    same_prev = df.session.eq(df.session.shift(1)) & ((df.ts - df.ts.shift(1)).dt.total_seconds().abs() <= 2)
    nxt = df.screen.shift(-1); prv = df.screen.shift(1)
    df.loc[blank & same_next & nxt.ne('screen_view'), 'screen'] = nxt
    still = df.event_name.eq('screen_view') & df.screen.eq('screen_view')
    df.loc[still & same_prev & prv.ne('screen_view'), 'screen'] = prv
    df['screen'] = df.screen.replace({'screen_view': 'unnamed_screen'})
    df['is_action'] = df.event_name.isin(ACTION_EVENTS)
    df['is_intent'] = df.event_name.eq(INTENT_EVENT)
    df['is_app'] = df.platform.isin(APPS)
    return df


def sessionize(df):
    g = df.groupby('session')
    s = g.agg(platform=('platform', 'first'), player=('PlayerID', 'first'), src=('src', 'first'),
              start=('ts', 'min'), end=('ts', 'max'), n=('ts', 'size'),
              n_add=('is_intent', 'sum'), n_action=('is_action', 'sum'),
              n_placed=('event_name', lambda e: (e == 'betslip_placed').sum()),
              n_accepted=('status', lambda x: (x == 'ACCEPTED').sum()),
              n_launch=('event_name', lambda e: (e == 'casino_game_launch').sum()),
              n_screens=('screen', 'nunique'), first_screen=('screen', 'first'), last_screen=('screen', 'last'))
    s['first_action'] = df[df.is_action].groupby('session').ts.min()
    s['first_intent'] = df[df.is_intent].groupby('session').ts.min()
    s['len_s'] = (s.end - s.start).dt.total_seconds()
    s['ttfa'] = (s.first_action - s.start).dt.total_seconds()
    s['ttfi'] = (s.first_intent - s.start).dt.total_seconds()
    s['converted'] = s.n_action > 0
    s['reached_final'] = s.n_add > 0
    s['final_conv'] = np.where(s.reached_final, s.n_placed > 0, np.nan)
    s['is_app'] = s.platform.isin(APPS)
    loc = s.start.dt.tz_convert('Europe/Zagreb')
    s['day'] = loc.dt.date
    s['hour'] = loc.dt.hour
    s['dow'] = loc.dt.dayofweek
    return s
