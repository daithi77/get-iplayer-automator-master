"""Link Comhrá AS topics and the grammar track both ways, from builders/links.json.
Run after build_comhra.py and build_grammar.py: adds 'grammar' to each topic in data/comhra.json
and 'comhra' to each linked section in data/grammar.json."""
import json
L = json.load(open('../builders/links.json'))
C = json.load(open('data/comhra.json'))
G = json.load(open('data/grammar.json'))
topics = {u['id']: u for u in C}
assert set(L['links']) == set(topics), set(L['links']) ^ set(topics)
for sec in G['sections'].values(): sec['comhra'] = []
def evidence(u, ref):
    if ref.startswith('Q') and ref[1:].isdigit(): return u['questions'][int(ref[1:]) - 1]['ga']
    row = next((r for r in u['rows'] if r['label'] == ref), None)
    assert row, (u['id'], ref)
    return row['sentences'][0]['ga']
for tid, links in L['links'].items():
    u = topics[tid]
    # Every topic starts with the question words the examiner uses.
    out = [{'id': 'ceisteanna', 'lesson': None, 'examples': [q['ga'] for q in u['questions'][:2]]}]
    for sid, lesson, refs in links:
        assert sid in G['sections'], sid
        out.append({'id': sid, 'lesson': lesson, 'examples': [evidence(u, r) for r in refs][:2]})
    for x in out:
        sec = G['sections'][x['id']]
        ls = sec.get('lessons') or []
        if x['lesson'] is not None:
            assert 1 <= x['lesson'] <= len(ls), (tid, x)
            x['lessonTitle'] = ls[x['lesson'] - 1]['title']; x['lesson'] -= 1   # 0-based in the data
        x['title'] = sec['title']; x['why'], x['whyEn'] = L['why'][x['id']]
        sec['comhra'].append({'id': tid, 'title': u['title'], 'en': u['en'], 'example': x['examples'][0] if x['examples'] else ''})
    u['grammar'] = out
json.dump(C, open('data/comhra.json', 'w'), ensure_ascii=False)
json.dump(G, open('data/grammar.json', 'w'), ensure_ascii=False)
print(sum(len(u['grammar']) for u in C), 'links;', sum(1 for s in G['sections'].values() if s['comhra']), 'sections used by Comhrá')
