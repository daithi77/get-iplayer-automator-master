"""Turn builders/as-comhra.json (the AS conversation Q&A, corrected and modernised) into beta/data/comhra.json,
in the same shape as the Year 8 units so the same session engine runs them. Text only: no audio yet."""
import json, hashlib, itertools, random, re
random.seed(13)
src = json.load(open('../builders/as-comhra.json'))
aid = lambda t: 'c' + hashlib.sha1(t.strip().encode()).hexdigest()[:11]   # own id space: never matches a Year 8 clip
gl = lambda e: re.sub(r'\s*\([^)]*\)', '', e).strip()
def irish(cols):
    s = ' '.join(c['ga'] for c in cols).strip(); s = s[0].upper() + s[1:]
    return s if s[-1] in '.?!' else s + '.'
def english(cols):
    s = ' '.join(gl(c['en']) for c in cols if gl(c['en'])).strip(); s = s[0].upper() + s[1:]
    return s if s[-1] in '.?!' else s + '.'
units = []
for b in src['builders']:
    rows = []
    for r in b['rows']:
        cols = [[dict(c, id=aid(c['ga'])) for c in col] for col in r['columns']]
        opts = [list(col) + ([None] if all(c.get('optional') for c in col) else []) for col in cols]
        combos = [[c for c in combo if c] for combo in itertools.product(*opts)]
        random.shuffle(combos)
        mk = lambda c: {'ga': irish(c), 'en': english(c), 'chunks': [x['id'] for x in c], 'audio': aid(irish(c))}
        rows.append({'label': r['label'], 'columns': cols, 'sentences': [mk(c) for c in combos[:6]], 'all': [mk(c) for c in combos[:400]], 'total': len(combos)})
    units.append({'id': b['id'], 'title': b['title'], 'en': b['en'], 'teaches': b.get('teaches', ''), 'new': bool(b.get('new')), 'noAudio': True,
                  'questions': [{'ga': q, 'audio': aid(q), 'rows': None} for q in b['questions']],
                  'examples': [{'ga': e, 'audio': aid(e)} for e in b['examples']], 'rows': rows})
json.dump(units, open('data/comhra.json', 'w'), ensure_ascii=False)
print(len(units), 'units', sum(len(u['rows']) for u in units), 'rows', sum(len(u['questions']) for u in units), 'questions')
