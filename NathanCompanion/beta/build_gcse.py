"""Turn builders/gcse.json (the GCSE track) into data/gcse.json, in the Year 8 unit shape so the same
session engine, audio and slides run it, plus the question chain, pattern boxes, ladder and role plays.
Also writes data/audio_texts_gcse.json: every line Áine records for the track."""
import json, hashlib, itertools, random, re
random.seed(11)
d = json.load(open('../builders/gcse.json'))
def aid(t): return hashlib.sha1(t.strip().encode()).hexdigest()[:12]
def gl(e): return re.sub(r'\s*\([^)]*\)', '', e).strip()
plain = lambda t: t.replace('[', '').replace(']', '')     # [ ] marks what changes; Áine reads the plain text
def finish(s):
    s = s.replace(' ,', ','); s = s[0].upper() + s[1:]
    return s if s[-1] in '.?!' else s + '.'
irish = lambda cols: finish(' '.join(c['ga'] for c in cols))
english = lambda cols: finish(' '.join(gl(c['en']) for c in cols if gl(c['en'])))
units = []; audio = set()
def say(t):
    audio.add(plain(t)); return aid(plain(t))
for b in d['builders']:
    rows = []
    for r in b['rows']:
        cols = [[dict(c, id=aid(c['ga'])) for c in col] for col in r['columns']]
        for col in cols:
            for c in col: audio.add(c['ga'])
        opts = [list(col) + ([None] if all(c.get('optional') for c in col) else []) for col in cols]
        combos = [[c for c in combo if c] for combo in itertools.product(*opts)]
        random.shuffle(combos)
        mk = lambda c: {'ga': irish(c), 'en': english(c), 'chunks': [x['id'] for x in c], 'audio': say(irish(c))}
        rows.append({'label': r['label'], 'columns': cols, 'sentences': [mk(c) for c in combos[:6]], 'all': [mk(c) for c in combos], 'total': len(combos)})
    extra = []
    sprioc = [dict(x, audio=say(x['ga'])) for x in b.get('sprioc', [])]
    ladder = [dict(x, audio=say(x['ga'])) for x in b.get('ladder', [])]
    plays = []
    for p in b.get('roleplays', []):
        tasks = [dict(t, audio=say(t['ga']), teacherAudio=say(t['teacher'])) for t in p['tasks']]
        plays.append(dict(p, tasks=tasks, rubricAudio=say(p['rubric'])))
    for x in sprioc + ladder: extra.append(x['audio'])
    for p in plays:
        extra.append(p['rubricAudio'])
        for t in p['tasks']: extra += [t['audio'], t['teacherAudio']]
    units.append({'id': b['id'], 'title': b['title'], 'en': b['en'], 'level': b.get('level', ''), 'teaches': b.get('teaches', ''), 'new': bool(b.get('new')),
                  'questions': [{'ga': q, 'audio': say(q), 'rows': b['qrows'][i]} for i, q in enumerate(b['questions'])],
                  'examples': [{'ga': e, 'audio': say(e)} for e in b['examples']], 'rows': rows,
                  'sprioc': sprioc, 'patterns': b.get('patterns', []), 'ladder': ladder, 'roleplays': plays, 'extraAudio': extra})
json.dump(units, open('data/gcse.json', 'w'), ensure_ascii=False)
json.dump(sorted(audio), open('data/audio_texts_gcse.json', 'w'), ensure_ascii=False)
print(len(units), 'units', sum(len(r['all']) for u in units for r in u['rows']), 'sentences', len(audio), 'audio texts')
