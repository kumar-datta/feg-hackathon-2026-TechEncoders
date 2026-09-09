"""
validate.py — referential integrity across every dataset.

This is the check that should gate ingestion in CI. It catches the failure modes
that silently break a navigation assistant: a game document pointing at an entity
that no longer exists, an FAQ linking a dead page, or an intent example training
the model to emit an unknown entity_id.

    python tools/validate.py
"""
import json
import os
import sys

DATA = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data'))

errors, warnings = [], []


def load(rel):
    path = os.path.join(DATA, rel)
    if not os.path.exists(path):
        errors.append(f'missing file: {rel}')
        return []
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def err(msg):
    errors.append(msg)


def warn(msg):
    warnings.append(msg)


def main():
    entities = load('navigation/entities.json')
    pages = load('navigation/pages.json')
    aliases = load('navigation/aliases.json')
    actions = load('intents/actions.json')
    faq = load('rag/faq.json')
    games = load('rag/game_knowledge.json')
    policies = load('rag/policies.json')
    intents = load('intents/intent_examples.json')
    nl = load('intents/nl_alias_queries.json')
    amb = load('intents/ambiguous_queries.json')
    fups = load('intents/followups.json')
    ret = load('evaluation/retrieval_eval.json')
    nav = load('evaluation/navigation_eval.json')
    safety = load('evaluation/safety_eval.json')

    entity_ids = {e['id'] for e in entities}
    page_ids = {p['page_id'] for p in pages}
    known = entity_ids | page_ids
    action_names = {a['action'] for a in actions.get('actions', [])}

    # ---- 1. entity integrity ----
    seen = set()
    for e in entities:
        if e['id'] in seen:
            err(f'duplicate entity id: {e["id"]}')
        seen.add(e['id'])
        if e['parent_id'] and e['parent_id'] not in entity_ids:
            err(f'entity {e["id"]} has unknown parent_id {e["parent_id"]}')
        if not e['route'].startswith('/'):
            err(f'entity {e["id"]} route must start with "/": {e["route"]}')
        if not e['aliases']:
            warn(f'entity {e["id"]} has no aliases — poor recall')

    # ---- 2. alias integrity ----
    for a in aliases:
        if a['entity_id'] not in entity_ids:
            err(f'alias "{a["alias"]}" points at unknown entity {a["entity_id"]}')
    collisions = {}
    for a in aliases:
        collisions.setdefault(a['alias'], set()).add(a['entity_id'])
    for alias, ids in collisions.items():
        if len(ids) > 1:
            warn(f'alias "{alias}" maps to {len(ids)} entities {sorted(ids)} '
                 f'— must resolve via clarification, never a silent pick')

    # ---- 3. page integrity ----
    for p in pages:
        if p['parent_page'] and p['parent_page'] not in page_ids:
            err(f'page {p["page_id"]} has unknown parent_page {p["parent_page"]}')
        for act in p['available_actions']:
            if act not in action_names and act != 'OPEN_PAGE_BY_ID':
                err(f'page {p["page_id"]} references unknown action {act}')

    # ---- 4. game knowledge ↔ entity ----
    for g in games:
        if g['game_id'] not in entity_ids:
            err(f'game_knowledge {g["game_id"]} has no matching navigation entity')
        if not g.get('responsible_gaming_note'):
            err(f'game_knowledge {g["game_id"]} is missing the mandatory '
                f'responsible_gaming_note')
        blob = ' '.join(str(v) for v in g.values()).lower()
        for banned in ('guaranteed win', 'sure win', 'expected profit',
                       'you will win', 'best strategy to win'):
            if banned in blob:
                err(f'game_knowledge {g["game_id"]} contains prohibited claim: "{banned}"')

    # ---- 5. FAQ integrity ----
    for f in faq:
        for pid in f['related_pages']:
            if pid not in known:
                err(f'faq {f["id"]} links unknown page {pid}')
        if f['priority'] not in ('high', 'medium', 'low'):
            err(f'faq {f["id"]} has invalid priority {f["priority"]}')
        if len(f['answer']) < 40:
            warn(f'faq {f["id"]} answer looks too short to be useful')

    # ---- 6. policies must stay placeholders until reviewed ----
    for p in policies:
        if not p.get('requires_verified_source'):
            err(f'policy {p["id"]} must have requires_verified_source=true')
        if p['content'] != '[REPLACE WITH ACTUAL COMPANY POLICY]' and not p.get('last_reviewed'):
            err(f'policy {p["id"]} has real content but no last_reviewed date')

    # ---- 7. intent examples ----
    for i in intents:
        if i.get('entity_id') and i['entity_id'] not in known:
            err(f'intent example "{i["query"]}" references unknown entity {i["entity_id"]}')
        if i['expected_action'] not in action_names and i['expected_action'] not in (
                'ANSWER_FROM_RAG', 'SHOW_SEARCH_RESULTS', 'ASK_CLARIFICATION',
                'FALLBACK_TO_SUPPORT', 'OPEN_PAGE_BY_ID', 'CALL_ACCOUNT_API'):
            err(f'intent example "{i["query"]}" has unknown action {i["expected_action"]}')
        if not 0 <= float(i['confidence']) <= 1:
            err(f'intent example "{i["query"]}" confidence out of range')
        # financial actions must always require confirmation
        if i['expected_action'] in ('OPEN_DEPOSIT', 'OPEN_WITHDRAW') and not i['requires_confirmation']:
            err(f'financial intent "{i["query"]}" must set requires_confirmation=true')

    for n in nl:
        if n['canonical_entity_id'] not in known:
            err(f'nl alias "{n["query"]}" references unknown entity {n["canonical_entity_id"]}')

    # ---- 8. ambiguous set must never auto-resolve ----
    for a in amb:
        if not a['requires_confirmation']:
            err(f'ambiguous query "{a["query"]}" must set requires_confirmation=true')
        if not a['clarification_question']:
            err(f'ambiguous query "{a["query"]}" has no clarification question')
        for cand in a['possible_entities']:
            if cand not in known and cand != '—':
                err(f'ambiguous query "{a["query"]}" lists unknown entity {cand}')

    # ---- 9. follow-ups ----
    for f in fups:
        exp = f['expected_resolution']
        eid = exp.get('entity_id')
        if eid and eid not in known:
            err(f'followup references unknown entity {eid}')
        if eid is None and exp.get('action') not in ('ASK_CLARIFICATION',):
            err(f'followup with no entity must ask for clarification, got {exp.get("action")}')

    # ---- 10. evaluation sets ----
    for r in ret + nav:
        if r['expected_entity'] and r['expected_entity'] not in known:
            err(f'eval query "{r["query"]}" references unknown entity {r["expected_entity"]}')
        if r['expected_intent'] == 'AMBIGUOUS' and r['should_navigate']:
            err(f'eval query "{r["query"]}" is ambiguous but expects navigation')

    for s in safety:
        if s['should_answer'] and s['should_refuse_or_clarify']:
            err(f'safety case "{s["query"]}" cannot both answer and refuse')

    # ---- report ----
    print('=' * 68)
    print('DATASET VALIDATION')
    print('=' * 68)
    print(f'  entities            {len(entities):5d}')
    print(f'  pages               {len(pages):5d}')
    print(f'  aliases             {len(aliases):5d}')
    print(f'  faq                 {len(faq):5d}')
    print(f'  game knowledge      {len(games):5d}')
    print(f'  policies            {len(policies):5d}  (all placeholders)')
    print(f'  intent examples     {len(intents):5d}')
    print(f'  nl/alias queries    {len(nl):5d}')
    print(f'  ambiguous           {len(amb):5d}')
    print(f'  followups           {len(fups):5d}')
    print(f'  eval (retr+nav)     {len(ret) + len(nav):5d}')
    print(f'  safety tests        {len(safety):5d}')
    print('-' * 68)

    if warnings:
        print(f'\n  WARNINGS ({len(warnings)}):')
        for m in warnings[:15]:
            print(f'    · {m}')
        if len(warnings) > 15:
            print(f'    … and {len(warnings) - 15} more')

    if errors:
        print(f'\n  ERRORS ({len(errors)}):')
        for m in errors:
            print(f'    ✗ {m}')
        print('\n  RESULT: FAILED')
        sys.exit(1)

    print('\n  RESULT: PASSED — all cross-references resolve')


if __name__ == '__main__':
    main()
