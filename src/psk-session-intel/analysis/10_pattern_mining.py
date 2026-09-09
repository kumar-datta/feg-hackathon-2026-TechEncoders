"""Pattern mining on PSK app sessions.
 1. Sequence n-grams (bigram/trigram) with conversion lift
 2. PrefixSpan frequent sequential patterns (own implementation)
 3. Absorbing Markov chain: P(reach action) and P(exit) from every screen; transition entropy
 4. Apriori association rules with outcome consequents (own implementation)
 5. Four-intent taxonomy quantification (no intent / undecided / decided-cant-find / decided-hesitating)
 6. Cross-session deferred intent at fixture level
 7. Chasing proxy (quick re-bet after placement)
 8. Android placement retry anatomy
"""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
from collections import Counter, defaultdict
from itertools import combinations
pd.set_option('display.width', 250); pd.set_option('display.max_columns', 60)
df = load_events(); S = sessionize(df)
SA = pd.read_csv(OUT + "sessions_enriched.csv", index_col=0, dtype={'player': str}); SA.index = SA.index.astype(str)
ap = df[df.is_app].copy()
TOP = ['homepage', 'ticketHistory', 'ticketDetail', 'liveEvents', 'liveDetail', 'prematchSports', 'prematchLeagues', 'prematchMatchesOverview', 'prematchDetail',
       'competition_detail', 'betslip', 'my_account', 'account', 'accounts_web_view', 'webViewunknown', 'menu', 'search', 'searchPrematch', 'searchLive', 'searchHomepage',
       'ticket', 'my_games', 'lobby', 'az_games', 'splash', 'login', 'unnamed_screen']
ev_map = {'betslip_add_bet': 'ADD', 'betslip_placed': 'PLACE', 'casino_game_launch': 'LAUNCH'}


def tok(r):
    if r.event_name in ev_map: return ev_map[r.event_name]
    if r.event_name == 'betslip_placed_bet': return None
    s = r.screen
    if s.startswith('search'): return 'search'
    return s if s in TOP else 'other'


ap['tok'] = [tok(r) for r in ap[['event_name', 'screen']].itertuples(index=False)]
ap = ap[ap.tok.notna()]
seqs = {}
for sid, g in ap.groupby('session', sort=False):
    t = g.tok.tolist(); out = []
    for x in t:
        if not out or out[-1] != x: out.append(x)
    seqs[sid] = out
SA = SA[SA.index.isin(seqs)]
SA['seq'] = SA.index.map(seqs)
SA['outcome'] = np.where(SA.converted, 'converted', np.where(SA.reached_final, 'abandoned_final', 'no_action'))
sb = SA[SA.platform.isin(['SB iOS', 'SB Android'])]
print("sequences:", len(SA), " SB app sequences:", len(sb), " median length:", int(sb.seq.map(len).median()))


# ---------------- 1. n-grams with lift ----------------
def ngrams(seq, n): return set(tuple(seq[i:i + n]) for i in range(len(seq) - n + 1))


def ngram_table(frame, n, min_support=0.02):
    conv = frame.converted.values; N = len(frame); Nc = conv.sum(); Nn = N - Nc
    cnt_all = Counter(); cnt_conv = Counter()
    for s, c in zip(frame.seq, conv):
        for g in ngrams(s, n):
            cnt_all[g] += 1
            if c: cnt_conv[g] += 1
    rows = []
    for g, a in cnt_all.items():
        if a / N < min_support: continue
        c = cnt_conv[g]; nc = a - c
        p_conv_given = c / a; lift_conv = p_conv_given / (Nc / N)
        rows.append({'pattern': ' > '.join(g), 'sessions': a, 'support': a / N, 'conv_rate_with': p_conv_given, 'lift_conv': lift_conv,
                     'share_of_nonconv': nc / Nn, 'share_of_conv': c / Nc})
    return pd.DataFrame(rows).sort_values('sessions', ascending=False)


for plat in ['SB iOS', 'SB Android']:
    fr = sb[sb.platform == plat]
    for n in [2, 3]:
        t = ngram_table(fr, n, 0.02); t.round(3).to_csv(OUT + f"ngram{n}_{plat.replace(' ', '_')}.csv", index=False)
        print(f"\n=== {plat} {n}-grams: most common in NON-converting sessions (lift_conv<0.8) ===")
        print(t[t.lift_conv < 0.8].sort_values('share_of_nonconv', ascending=False).head(10).round(3).to_string(index=False))
        print(f"--- {plat} {n}-grams: strongest conversion signals (support>=3%) ---")
        print(t[(t.support >= .03)].sort_values('lift_conv', ascending=False).head(8).round(3).to_string(index=False))


# ---------------- 2. PrefixSpan ----------------
def prefixspan(sequences, min_count, max_len=4, max_patterns=400):
    results = []

    def project(db, item):
        out = []
        for s in db:
            try:
                i = s.index(item); out.append(s[i + 1:])
            except ValueError:
                pass
        return out

    def grow(prefix, db):
        if len(prefix) >= max_len or len(results) >= max_patterns: return
        cnt = Counter()
        for s in db:
            for it in set(s): cnt[it] += 1
        for it, c in sorted(cnt.items(), key=lambda x: -x[1]):
            if c < min_count: break
            if prefix and it == prefix[-1]: continue
            p = prefix + [it]; results.append((p, c)); grow(p, project(db, it))

    grow([], sequences)
    return results


for plat in ['SB iOS', 'SB Android']:
    fr = sb[sb.platform == plat]
    for label, sub in [('NON-converting', fr[~fr.converted]), ('converting (path before first action)', fr[fr.converted])]:
        seqlist = [s[:s.index('PLACE')] if 'PLACE' in s else s for s in sub.seq] if 'converting' in label and 'NON' not in label else list(sub.seq)
        seqlist = [s[:40] for s in seqlist]
        pats = prefixspan(seqlist, min_count=int(0.05 * len(seqlist)), max_len=4)
        pats = [(p, c) for p, c in pats if len(p) >= 3]
        pats.sort(key=lambda x: (-len(x[0]), -x[1]))
        print(f"\n=== PrefixSpan {plat} {label}: n={len(seqlist)}, gapped patterns len>=3, support>=5% ===")
        for p, c in pats[:12]: print(f"  {c / len(seqlist):5.1%}  {' … '.join(p)}")
        pd.DataFrame([{'pattern': ' … '.join(p), 'sessions': c, 'support': c / len(seqlist)} for p, c in pats]).round(3).to_csv(OUT + f"prefixspan_{plat.replace(' ', '_')}_{label.split()[0]}.csv", index=False)


# ---------------- 3. absorbing Markov chain ----------------
def absorbing(frame, name):
    trans = Counter(); states = set()
    for s in frame.seq:
        path = []
        for x in s:
            if x in ('PLACE', 'LAUNCH'): path.append('ACTION'); break
            path.append(x)
        if path[-1] != 'ACTION': path.append('EXIT')
        for a, b in zip(path[:-1], path[1:]): trans[(a, b)] += 1; states.add(a)
    states = sorted(st for st in states if st not in ('ACTION', 'EXIT'))
    idx = {s: i for i, s in enumerate(states)}
    Q = np.zeros((len(states), len(states))); R = np.zeros((len(states), 2)); rowtot = np.zeros(len(states))
    for (a, b), c in trans.items():
        if a not in idx: continue
        rowtot[idx[a]] += c
        if b == 'ACTION': R[idx[a], 0] += c
        elif b == 'EXIT': R[idx[a], 1] += c
        else: Q[idx[a], idx[b]] += c
    keep = rowtot >= 30
    Q = Q[keep][:, keep] / rowtot[keep][:, None]; R = R[keep] / rowtot[keep][:, None]; st = [s for s, k in zip(states, keep) if k]
    Nmat = np.linalg.inv(np.eye(len(st)) - Q); B = Nmat @ R; steps = Nmat.sum(1)
    P = np.hstack([Q, R]); ent = -(np.where(P > 0, P * np.log2(np.where(P > 0, P, 1)), 0)).sum(1)
    out = pd.DataFrame({'state': st, 'visits': rowtot[keep].astype(int), 'p_reach_action': B[:, 0], 'p_exit': B[:, 1], 'expected_steps_left': steps,
                        'direct_exit_rate': R[:, 1], 'direct_action_rate': R[:, 0], 'next_step_entropy_bits': ent}).sort_values('p_reach_action', ascending=False)
    out.round(3).to_csv(OUT + f"markov_absorbing_{name}.csv", index=False)
    print(f"\n=== Absorbing Markov chain {name}: P(reach action before leaving) from each screen ===")
    print(out.round(3).to_string(index=False))
    return out


for plat in ['SB iOS', 'SB Android', 'Casino Android']:
    absorbing(SA[SA.platform == plat], plat.replace(' ', '_'))


# ---------------- 4. Apriori rules -> outcome ----------------
def items_for(r):
    it = {f'plat={r.platform}', f'arch={r.archetype}', f'breadth={r.breadth}', f'hour={r.hour_band}', f'{r.weekend}', f'idx={r.sess_idx_band}', f'len={r.len_band}', f'first={r.first_screen_grp}'}
    s = set(r.seq)
    if 'search' in s: it.add('used_search')
    if s & {'liveEvents', 'liveDetail'}: it.add('used_live')
    if s & {'ticketHistory', 'ticketDetail'}: it.add('used_ticket')
    if s & {'prematchLeagues', 'prematchMatchesOverview', 'prematchDetail', 'competition_detail', 'prematchSports'}: it.add('used_prematch')
    if s & {'my_account', 'account', 'accounts_web_view', 'webViewunknown'}: it.add('used_account')
    if 'betslip' in s: it.add('opened_betslip')
    if r.n_add > 0: it.add('adds=' + ('1' if r.n_add == 1 else '2-3' if r.n_add <= 3 else '4+'))
    return frozenset(it)


T = [(items_for(r), r.outcome) for r in sb.itertuples()]
N = len(T); outc = Counter(o for _, o in T)
min_sup = 0.01
c1 = Counter(); [c1.update(it) for it, _ in T]
L1 = {i for i, c in c1.items() if c / N >= min_sup}
cnt = Counter()
for it, o in T:
    its = sorted(i for i in it if i in L1)
    for k in (1, 2, 3):
        for comb in combinations(its, k): cnt[(comb, o)] += 1
supp = Counter()
for (comb, o), c in cnt.items(): supp[comb] += c
rules = []
for (comb, o), c in cnt.items():
    s_ante = supp[comb]
    if s_ante / N < min_sup or c < 30: continue
    conf = c / s_ante; lift = conf / (outc[o] / N)
    rules.append({'antecedent': ' & '.join(comb), 'outcome': o, 'sessions': s_ante, 'support': s_ante / N, 'confidence': conf, 'lift': lift})
R = pd.DataFrame(rules); R.round(3).to_csv(OUT + "apriori_rules.csv", index=False)
print("\n=== Apriori rules (SB apps): outcome base rates", {k: round(v / N, 3) for k, v in outc.items()})
for o in ['abandoned_final', 'no_action', 'converted']:
    sub = R[(R.outcome == o) & (R.support >= .02)].sort_values('lift', ascending=False)
    print(f"\n--- strongest rules -> {o} (support>=2%) ---"); print(sub.head(12).round(3).to_string(index=False))


# ---------------- 5. four-intent taxonomy ----------------
MARKET = {'prematchSports', 'prematchLeagues', 'prematchMatchesOverview', 'prematchDetail', 'competition_detail', 'liveEvents', 'liveDetail'}


def classify(r):
    s = r.seq; ms = set(s) & MARKET
    if r.n_action > 0:
        pre = s[:s.index('ADD')] if 'ADD' in s else s
        return 'converted_after_hunt' if (len(set(pre) & MARKET) >= 4 or (r.ttfi or 0) > 180) else 'converted_quick'
    if r.reached_final: return 'decided_hesitating'
    if len(ms) >= 3 and r.len_s >= 60: return 'undecided_research'
    if 'search' in s: return 'decided_cant_find'
    return 'no_intent_today'


sb = sb.copy(); sb['intent'] = [classify(r) for r in sb.itertuples()]
print("\n=== Four-intent taxonomy (SB apps) ===")
tab = sb.groupby(['platform', 'intent']).agg(sessions=('n', 'size'), med_len=('len_s', 'median'), med_events=('n', 'median')).reset_index()
tab['share'] = tab.sessions / tab.groupby('platform').sessions.transform('sum')
print(tab.round(3).to_string(index=False))
print("\n-- intent mix by breadth --"); print(pd.crosstab(sb.breadth, sb.intent, normalize='index').round(3).to_string())
print("\n-- intent mix by hour band --"); print(pd.crosstab(sb.hour_band, sb.intent, normalize='index').round(3).to_string())
sb[['platform', 'player', 'breadth', 'archetype', 'intent', 'outcome']].to_csv(OUT + "sessions_intent.csv")
# path length to first add: quick vs hunt
pre_len = sb[sb.reached_final].apply(lambda r: len(r.seq[:r.seq.index('ADD')]) if 'ADD' in r.seq else np.nan, axis=1)
print("\nscreens seen before first add (SB apps): p25/50/75/90 =", pre_len.quantile([.25, .5, .75, .9]).tolist())
print("share of first adds within 3 screens:", round((pre_len <= 3).mean(), 3), " share after 8+ screens:", round((pre_len >= 8).mean(), 3))

# ---------------- 6. cross-session deferred intent at fixture level ----------------
adds = ap[(ap.event_name == 'betslip_add_bet') & ap.fixture_id.notna()][['session', 'PlayerID', 'ts', 'fixture_id']]
placed = ap[(ap.event_name == 'betslip_placed_bet') & ap.fixture_id.notna()][['session', 'PlayerID', 'ts', 'fixture_id']]
placed_first = placed.groupby(['PlayerID', 'fixture_id']).ts.min()
aband = SA[(SA.reached_final) & (SA.n_placed == 0) & SA.platform.isin(['SB iOS', 'SB Android'])]
rows = []
for sid, r in aband.iterrows():
    fx = adds[adds.session == sid].fixture_id.unique()
    if len(fx) == 0: continue
    later = [placed_first.get((r.player, f)) for f in fx]
    later = [t for t in later if t is not None and t > r.end]
    rows.append({'session': sid, 'n_fixtures': len(fx), 'later_placed': len(later) > 0, 'hours_to_place': (min(later) - r.end).total_seconds() / 3600 if later else np.nan})
D = pd.DataFrame(rows)
print("\n=== Deferred intent at fixture level (abandoned SB app sessions with a known fixture) ===")
print("sessions:", len(D), " share where an abandoned fixture was later placed by the same player:", round(D.later_placed.mean(), 3))
print("hours until placed, p25/50/75:", D.hours_to_place.quantile([.25, .5, .75]).round(1).tolist(), " within 24h:", round((D.hours_to_place <= 24).mean(), 3))
# research across sessions: for placed fixtures, was the fixture added in an EARLIER session without placing?
adds_first = adds.groupby(['PlayerID', 'fixture_id']).agg(first_add=('ts', 'min'), first_add_session=('session', 'first'))
pf = placed.groupby(['PlayerID', 'fixture_id']).agg(first_place=('ts', 'min'), place_session=('session', 'first')).join(adds_first)
pf = pf.dropna(subset=['first_add'])
pf['researched_earlier'] = pf.first_add_session != pf.place_session
print("placed fixtures that were first added in an EARLIER session (multi-session research):", round(pf.researched_earlier.mean(), 3), "of", len(pf))
D.to_csv(OUT + "deferred_intent_fixture.csv", index=False)

# ---------------- 7. chasing proxy ----------------
ev = ap[ap.event_name.isin(['betslip_placed', 'betslip_add_bet'])].sort_values(['session', 'ts'])
ev['prev_ev'] = ev.groupby('session').event_name.shift(); ev['dt'] = (ev.ts - ev.groupby('session').ts.shift()).dt.total_seconds()
quick = ev[(ev.event_name == 'betslip_add_bet') & (ev.prev_ev == 'betslip_placed') & (ev.dt <= 60)]
qs = quick.groupby('session').size()
SA['quick_rebet'] = SA.index.map(qs).fillna(0)
withp = SA[SA.n_placed > 0]
print("\n=== Chasing proxy: new pick added within 60 s of placing (SB apps, sessions with a placement) ===")
print("share of placing sessions with >=1 quick re-bet:", round((withp.quick_rebet > 0).mean(), 3), " mean per session:", round(withp.quick_rebet.mean(), 2))
print(withp.groupby('archetype').agg(sessions=('n', 'size'), share_quick=('quick_rebet', lambda x: (x > 0).mean()), mean_quick=('quick_rebet', 'mean')).round(3).to_string())
print("by hour band:"); print(withp.groupby('hour_band').agg(sessions=('n', 'size'), share_quick=('quick_rebet', lambda x: (x > 0).mean())).round(3).to_string())
pq = withp.groupby('player').agg(sessions=('n', 'size'), quick_share=('quick_rebet', lambda x: (x > 0).mean())).query('sessions>=20')
print("players (>=20 placing sessions) with quick re-bet in >30% of sessions:", int((pq.quick_share > .3).sum()), "of", len(pq))

# ---------------- 8. Android retry anatomy ----------------
pl = ap[(ap.event_name == 'betslip_placed') & (ap.platform == 'SB Android')].sort_values(['session', 'ts'])
g = pl.groupby('session').agg(n=('ts', 'size'), n_fail=('status', lambda x: (x != 'ACCEPTED').sum()), n_ok=('status', lambda x: (x == 'ACCEPTED').sum()),
                              first_fail=('ts', lambda x: x[pl.loc[x.index, 'status'] != 'ACCEPTED'].min() if (pl.loc[x.index, 'status'] != 'ACCEPTED').any() else pd.NaT),
                              first_ok_after=('ts', lambda x: x[(pl.loc[x.index, 'status'] == 'ACCEPTED')].min()))
gf = g[g.n_fail > 0]
print("\n=== Android placement retries ===")
print("sessions with a placement:", len(g), " with >=1 failure:", len(gf), f"({len(gf) / len(g):.1%})", " failures never followed by an accepted ticket:", int((gf.n_ok == 0).sum()))
print("failed placements per failing session p50/p90:", gf.n_fail.quantile([.5, .9]).tolist(), " total failed events:", int(g.n_fail.sum()), " total accepted:", int(g.n_ok.sum()))
st = pl.groupby('session').status.apply(list)
seqs_fail = st[st.apply(lambda l: any(s != 'ACCEPTED' for s in l))]
print("typical status sequences in failing sessions:"); print(seqs_fail.apply(lambda l: '>'.join(str(x)[:3] for x in l[:8])).value_counts().head(8).to_string())
print("\ndone")
