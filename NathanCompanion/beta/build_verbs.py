"""Copy Dáithí's verb booklet data (builders/verbs.json) into data/verbs.json, checking it on the way:
every verb in exactly one box, eleven irregular cards with P, N and Q in four tenses, no banned forms."""
import json, re
d = json.load(open('../builders/verbs.json'))
seen = {}
for b in d['boxes']:
    for v, en in b['verbs']:
        k = v.split(' (')[0]
        assert k not in seen, f'{k} is in {seen[k]} and {b["id"]}'
        seen[k] = b['id']
assert len(d['irregular']) == 11
for c in d['irregular']:
    for t in ('past', 'present', 'future', 'conditional'):
        assert all(c[t].get(x) for x in ('P', 'N', 'Q', 'saor')), (c['verb'], t)
txt = json.dumps({k: v for k, v in d.items() if k != 'note'}, ensure_ascii=False)
bad = re.findall(r'[–—]|\bclois|\bdún\b|amar\b|\bbord\b', txt)
assert not bad, bad
json.dump(d, open('data/verbs.json', 'w'), ensure_ascii=False)
print(len(seen), 'verbs in', len(d['boxes']), 'boxes;', len(d['irregular']), 'irregular cards')
