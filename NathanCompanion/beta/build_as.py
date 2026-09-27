"""Copy the AS and A2 reading and picture-stimulus material from builders/ into data/, checking it on the way.
These modes are read and written, not heard, so there is no audio to attach."""
import json, os, re
BAD = re.compile(r'[–—]|\bclois|\bbord\b|\bfreisin\b|student', re.I)
for name in ('spreag', 'leamh'):
    src = f'../builders/{name}.json'
    if not os.path.exists(src): continue
    d = json.load(open(src))
    txt = json.dumps(d, ensure_ascii=False)
    hits = BAD.findall(txt)
    assert not hits, (name, hits[:5])
    json.dump(d, open(f'data/{name}.json', 'w'), ensure_ascii=False)
    print(name, len(d), 'items')
