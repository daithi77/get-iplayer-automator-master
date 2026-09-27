"""Copy the builders data, the marking-hand font and Áine's audio into GanAinm.swiftpm/Resources,
report any missing clips, and zip the package for AirDrop or download to the Mac."""
import json, os, shutil, zipfile
here = os.path.dirname(os.path.abspath(__file__))
pkg = os.path.join(here, 'GanAinm.swiftpm')
res = os.path.join(pkg, 'Resources')
beta = os.path.join(here, '..', 'beta')
os.makedirs(res, exist_ok=True)
for f in os.listdir(res):
    if f.endswith('.mp3'): os.remove(os.path.join(res, f))
shutil.copy(os.path.join(beta, 'data', 'units.json'), res)
shutil.copy(os.path.join(beta, 'data', 'grammar.json'), res)
shutil.copy(os.path.join(beta, 'data', 'comhra.json'), res)
shutil.copy(os.path.join(beta, 'data', 'gcse.json'), res)
shutil.copy(os.path.join(here, '..', 'font', 'MarkingHand-Regular.otf'), res)
units = json.load(open(os.path.join(beta, 'data', 'units.json'))) + json.load(open(os.path.join(beta, 'data', 'gcse.json')))
needed = set()
for u in units:
    for q in u['questions']: needed.add(q['audio'])
    for e in u['examples']: needed.add(e['audio'])
    for r in u['rows']:
        for col in r['columns']:
            for c in col: needed.add(c['id'])
        for s in r.get('all', r['sentences']): needed.add(s['audio'])
    for x in u.get('sprioc', []):
        if x.get('audio'): needed.add(x['audio'])
    for i in u.get('extraAudio', []): needed.add(i)
have = 0
for n in sorted(needed):
    src = os.path.join(beta, 'audio', n + '.mp3')
    if os.path.exists(src):
        shutil.copy(src, res); have += 1
print(f'audio {have} of {len(needed)} clips bundled')
out = os.path.join(here, 'GanAinm.swiftpm.zip')
with zipfile.ZipFile(out, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(pkg):
        for f in files:
            if f == '.DS_Store': continue
            p = os.path.join(root, f)
            z.write(p, os.path.relpath(p, here))
print('zip', out, round(os.path.getsize(out) / 1e6, 1), 'MB')
