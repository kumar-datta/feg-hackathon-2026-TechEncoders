"""POC evidence models.
 A) Early-session intent: predict the kind of visit from the first 3 events.
 B) Final-step abandonment: predict 'added a pick but never placed' from what is known at the first add.
Both use only sklearn, and report glass-box style explanations (coefficients / permutation importance).
"""
exec(open("C:/FEG/psk-session-intel/analysis/00_common.py").read())
from sklearn.model_selection import GroupKFold, cross_val_predict
from sklearn.ensemble import HistGradientBoostingClassifier
from sklearn.linear_model import LogisticRegression
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.metrics import roc_auc_score, accuracy_score, balanced_accuracy_score, classification_report
from sklearn.inspection import permutation_importance
pd.set_option('display.width', 250)

df = load_events(); S = sessionize(df); S = S[S.is_app].copy()
S = S.sort_values(['player', 'start'])
S['prev_end'] = S.groupby('player').end.shift()
S['mins_since_prev'] = ((S.start - S.prev_end).dt.total_seconds() / 60).fillna(999).clip(0, 1440)
S['abandoned_flag'] = (S.reached_final & (S.n_placed == 0)).astype(int)
S['prev_abandoned'] = S.groupby('player').abandoned_flag.shift().fillna(0).astype(int)
S['sess_idx_day'] = S.groupby(['player', 'day']).cumcount() + 1
S['open_tickets_prev'] = S.groupby('player').n_placed.transform(lambda x: x.rolling(20, min_periods=1).sum().shift().fillna(0))

# ---------- A) intent from first 3 events ----------
clus = pd.read_csv(OUT + "sessions_with_cluster.csv", index_col=0); clus.index = clus.index.astype(str)
names = {0: 'ticket_check', 3: 'glance', 5: 'prematch_browse', 6: 'live_follow', 1: 'marathon', 2: 'account', 4: 'casino'}
S['archetype'] = clus.cluster.reindex(S.index).map(names)
ap = df[df.is_app].copy(); ap['rank'] = ap.groupby('session').cumcount()
f3 = ap[ap['rank'] < 3].groupby('session').agg(s1=('screen', lambda x: x.iloc[0]), s2=('screen', lambda x: x.iloc[1] if len(x) > 1 else 'none'),
                                              s3=('screen', lambda x: x.iloc[2] if len(x) > 2 else 'none'),
                                              t3=('ts', lambda x: (x.iloc[-1] - x.iloc[0]).total_seconds()))
A = S.join(f3).dropna(subset=['archetype'])
XA = A[['s1', 's2', 's3', 't3', 'hour', 'dow', 'platform', 'mins_since_prev', 'sess_idx_day', 'open_tickets_prev']]
yA = A.archetype; gA = A.player
preA = ColumnTransformer([('cat', OneHotEncoder(handle_unknown='ignore', min_frequency=30, sparse_output=False), ['s1', 's2', 's3', 'platform']),
                          ('num', StandardScaler(), ['t3', 'hour', 'dow', 'mins_since_prev', 'sess_idx_day', 'open_tickets_prev'])])
modelA = Pipeline([('pre', preA), ('clf', HistGradientBoostingClassifier(max_depth=4, learning_rate=0.08, max_iter=200, random_state=0))])
predA = cross_val_predict(modelA, XA, yA, groups=gA, cv=GroupKFold(5))
print("=== A) Intent from first 3 events (5-fold, grouped by player so no user leaks across folds) ===")
print("accuracy:", round(accuracy_score(yA, predA), 3), " balanced accuracy:", round(balanced_accuracy_score(yA, predA), 3), " majority-class baseline:", round(yA.value_counts(normalize=True).max(), 3))
print(classification_report(yA, predA, digits=2))
rep = pd.DataFrame(classification_report(yA, predA, output_dict=True)).T.round(2); rep.to_csv(OUT + "poc_intent_report.csv")

# ---------- B) abandonment at the moment of first add ----------
adds = ap[ap.event_name == 'betslip_add_bet']
first_add = adds.groupby('session').agg(first_add_ts=('ts', 'min'), add_src=('added_from', lambda x: x.dropna().iloc[0] if x.notna().any() else 'unknown'),
                                       sport=('sport_name', lambda x: x.dropna().str.lower().iloc[0] if x.notna().any() else 'unknown'))
screens_before = ap.merge(first_add[['first_add_ts']], left_on='session', right_index=True)
screens_before = screens_before[screens_before.ts < screens_before.first_add_ts].groupby('session').agg(
    n_before=('ts', 'size'), n_screens_before=('screen', 'nunique'),
    live_before=('screen', lambda x: x.isin(['liveDetail', 'liveEvents']).mean()),
    ticket_before=('screen', lambda x: x.isin(['ticketDetail', 'ticketHistory']).mean()),
    search_before=('screen', lambda x: x.str.contains('search', case=False).any()))
B = S[S.reached_final & S.platform.isin(['SB iOS', 'SB Android'])].join(first_add).join(screens_before)
B[['n_before', 'n_screens_before', 'live_before', 'ticket_before']] = B[['n_before', 'n_screens_before', 'live_before', 'ticket_before']].fillna(0)
B['search_before'] = B.search_before.fillna(False).astype(int)
B['ttfi_s'] = B.ttfi.fillna(0)
B['abandon'] = (B.n_placed == 0).astype(int)
feats_cat = ['platform', 'add_src', 'sport']; feats_num = ['hour', 'dow', 'mins_since_prev', 'sess_idx_day', 'prev_abandoned', 'open_tickets_prev', 'n_before', 'n_screens_before', 'live_before', 'ticket_before', 'search_before', 'ttfi_s']
XB = B[feats_cat + feats_num]; yB = B.abandon; gB = B.player
preB = ColumnTransformer([('cat', OneHotEncoder(handle_unknown='ignore', min_frequency=30, sparse_output=False), feats_cat), ('num', StandardScaler(), feats_num)])
gb = Pipeline([('pre', preB), ('clf', HistGradientBoostingClassifier(max_depth=3, learning_rate=0.06, max_iter=250, random_state=0))])
lr = Pipeline([('pre', preB), ('clf', LogisticRegression(max_iter=2000, C=0.5))])
print("\n=== B) Abandonment at first add (SB apps, n=%d, abandon rate=%.3f) ===" % (len(B), yB.mean()))
for nm, m in [('gradient boosting', gb), ('logistic (glass-box)', lr)]:
    p = cross_val_predict(m, XB, yB, groups=gB, cv=GroupKFold(5), method='predict_proba')[:, 1]
    print(f"{nm:22s} AUC = {roc_auc_score(yB, p):.3f}")
    if nm.startswith('logistic'):
        B['p_abandon'] = p
# readable coefficients
lr.fit(XB, yB)
fn = lr.named_steps['pre'].get_feature_names_out()
coef = pd.Series(lr.named_steps['clf'].coef_[0], index=fn).sort_values()
print("\nTop factors that LOWER abandonment (negative) and RAISE it (positive):")
print(pd.concat([coef.head(8), coef.tail(8)]).round(2).to_string())
coef.round(3).to_csv(OUT + "poc_abandon_coefficients.csv")
# decile lift: if we act on the riskiest 20%, what share of abandons do we cover?
B['decile'] = pd.qcut(B.p_abandon, 10, labels=False, duplicates='drop')
lift = B.groupby('decile').abandon.agg(['size', 'mean']).sort_index(ascending=False)
lift['cum_share_of_abandons'] = (lift['size'] * lift['mean']).cumsum() / (B.abandon.sum())
print("\nRisk deciles (10 = riskiest):"); print(lift.round(3).to_string())
lift.round(3).to_csv(OUT + "poc_abandon_lift.csv")
