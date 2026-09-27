"""Pack each unit's clips into one file, audio/pack-<unit>.mp3, with byte offsets in data/packs.json.
The web page slices the pack back into clips, so the link stays well under its file limit."""
import json, os
units = json.load(open('data/units.json')) + (json.load(open('data/gcse.json')) if os.path.exists('data/gcse.json') else [])
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
    blob = bytearray(); idx = {}
    for i in ids:
        f = f'audio/{i}.mp3'
        if not os.path.exists(f): missing.append(i); continue
        b = open(f, 'rb').read(); idx[i] = [len(blob), len(b)]; blob += b
    open(f"audio/pack-{u['id']}.mp3", 'wb').write(blob)
    index[u['id']] = idx
    print(u['id'], len(idx), 'clips', round(len(blob) / 1e6, 2), 'MB')
json.dump(index, open('data/packs.json', 'w'))
print('missing', len(missing))
