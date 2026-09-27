"""Pack each unit's clips into one file, audio/pack-<unit>.mp3, with byte offsets in data/packs.json.
The web page slices the pack back into clips, so the link stays well under its file limit."""
import json, os
Y8 = json.load(open('data/units.json')); GC = json.load(open('data/gcse.json')) if os.path.exists('data/gcse.json') else []
A2 = json.load(open('data/a2.json')) if os.path.exists('data/a2.json') else []
units = Y8 + GC + A2
index = {}
missing = []
for u in units:
    ids = []
    def add(i):
        if i not in ids: ids.append(i)
    for q in u['questions']: add(q['audio'])
    for e in u['examples']: add(e['audio'])
    for r in u['rows']:
        for col in r['columns']:
            for c in col: add(c['id'])
        for s in r.get('all', r['sentences']): add(s['audio'])
    for x in u.get('sprioc', []):
        if x.get('audio'): add(x['audio'])
    for i in u.get('extraAudio', []): add(i)
    blob = bytearray(); idx = {}; gap = 0
    for i in ids:
        f = f'audio/{i}.mp3'
        if not os.path.exists(f): missing.append(i); gap += 1; continue
        b = open(f, 'rb').read(); idx[i] = [len(blob), len(b)]; blob += b
    open(f"audio/pack-{u['id']}.mp3", 'wb').write(blob)
    index[u['id']] = idx
    # A unit whose recordings are not finished runs in read mode (Léigh instead of Éist) until they are.
    if gap: u['noAudio'] = True
    else: u.pop('noAudio', None)
    print(u['id'], len(idx), 'clips', round(len(blob) / 1e6, 2), 'MB')
json.dump(index, open('data/packs.json', 'w'))
json.dump(Y8, open('data/units.json', 'w'), ensure_ascii=False)
if GC: json.dump(GC, open('data/gcse.json', 'w'), ensure_ascii=False)
if A2: json.dump(A2, open('data/a2.json', 'w'), ensure_ascii=False)
print('read mode until audio is finished:', [u['id'] for u in units if u.get('noAudio')])
print('missing', len(missing))
