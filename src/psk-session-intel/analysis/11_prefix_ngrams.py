"""n-grams on the PRE-action prefix only (screens before the first ADD/PLACE/LAUNCH), so action tokens cannot leak into the lift."""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
from collections import Counter
import re, ast
pd.set_option('display.width', 250)
SA = pd.read_csv(OUT + "sessions_enriched.csv", index_col=0, dtype={'player': str}); SA.index = SA.index.astype(str)
df = load_events(); ap = df[df.is_app]
ev_map = {'betslip_add_bet': 'ADD', 'betslip_placed': 'PLACE', 'casino_game_launch': 'LAUNCH'}
ap = ap[ap.event_name != 'betslip_placed_bet'].copy()
ap['tok'] = np.where(ap.event_name.isin(ev_map), ap.event_name.map(ev_map), ap.screen.where(~ap.screen.str.startswith('search'), 'search'))
pre = {}; reach = {}
for sid, g in ap.groupby('session', sort=False):
    t = g.tok.tolist(); out = []; r = False
    for x in t:
        if x in ('ADD', 'PLACE', 'LAUNCH'): r = True; break
        if not out or out[-1] != x: out.append(x)
    pre[sid] = out; reach[sid] = r
SA = SA[SA.index.isin(pre)]; SA['pre'] = SA.index.map(pre); SA['reach'] = SA.index.map(reach)
for plat in ['SB iOS', 'SB Android']:
    fr = SA[(SA.platform == plat) & (SA.pre.map(len) >= 2)]
    N = len(fr); base = fr.reach.mean()
    for n in (2, 3):
        ca = Counter(); cr = Counter()
        for s, r in zip(fr.pre, fr.reach):
            for g in set(tuple(s[i:i + n]) for i in range(len(s) - n + 1)):
                ca[g] += 1
                if r: cr[g] += 1
        rows = [{'pattern': ' > '.join(g), 'sessions': a, 'support': a / N, 'reach_rate': cr[g] / a, 'lift_reach': (cr[g] / a) / base} for g, a in ca.items() if a / N >= 0.02]
        t = pd.DataFrame(rows).sort_values('lift_reach'); t.round(3).to_csv(OUT + f"prefix_ngram{n}_{plat.replace(' ', '_')}.csv", index=False)
        print(f"\n=== {plat} pre-action {n}-grams (n={N}, base reach rate={base:.3f}) — LOWEST lift (paths that lead nowhere) ===")
        print(t.head(8).round(3).to_string(index=False))
        print(f"--- HIGHEST lift (paths that lead to a pick) ---"); print(t.tail(8).round(3).to_string(index=False))
