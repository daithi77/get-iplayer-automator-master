"""Turn builders/year8.json into beta/data/units.json: chunks, sampled sentences with English, audio file names."""
import json, hashlib, itertools, random, re
random.seed(8)
d=json.load(open('../builders/year8.json'))
def aid(t): return hashlib.sha1(t.strip().encode()).hexdigest()[:12]
def gl(e): return re.sub(r'\s*\([^)]*\)','',e).strip()
def english(cols):
    if cols[0]['en'].startswith('(copula'):
        x=cols[1]['en']; return (x[0].upper()+x[1:]+' is my favourite subject.').replace('  ',' ')
    s=' '.join(gl(c['en']) for c in cols if gl(c['en']))
    s=s.replace('There is / are','There is'); return s[0].upper()+s[1:]+'.'
def irish(cols):
    s=' '.join(c['ga'] for c in cols); return s[0].upper()+s[1:]+'.'
# Which builder rows can answer each question in one sentence. None = needs more than one row; left out of the typed exam question.
QROWS={'b1-mefein':[[0,1],[3],[4]],'b2-teaghlach':[[0],[1,2],[1,2]],'b3-cursios':[[0,1,2,3],None],
 'b4-ceantar':[[0],[3,4],[2]],'b5-scoil':[None,[4,5],[0,1]],'b6-caitheamh':[[0,1,2],[0],[0,1,2]],
 'b7-la':[[0],[1],[0,1,2,3]],'b8-guthan':[[0],[1]],'b9-laethanta':[[0],[1],[2],[3]]}
units=[]; audio=set()
for b in d['builders']:
    rows=[]
    for ri,r in enumerate(b['rows']):
        cols=[[dict(c,id=aid(c['ga'])) for c in col] for col in r['columns']]
        for col in cols:
            for c in col: audio.add(c['ga'])
        # all combinations (optional chunks may also be skipped)
        opts=[]
        for col in cols:
            o=list(col)
            if all(c.get('optional') for c in col): o=o+[None]
            opts.append(o)
        combos=[ [c for c in combo if c] for combo in itertools.product(*opts)]
        random.shuffle(combos)
        mk=lambda c:{'ga':irish(c),'en':english(c),'chunks':[x['id'] for x in c],'audio':aid(irish(c))}
        # 'sentences' are the six models used for sessions and progress; 'all' is every sentence the row
        # can make, so whatever tiles a pupil picks can be heard as a whole sentence.
        sents=[mk(c) for c in combos[:6]]
        every=[mk(c) for c in combos]
        for s in every: audio.add(s['ga'])
        rows.append({'label':r['label'],'columns':cols,'sentences':sents,'all':every,'total':len(combos)})
    for e in b['examples']: audio.add(e)
    for q in b['questions']: audio.add(q)
    units.append({'id':b['id'],'title':b['title'],'en':b['en'],'questions':[{'ga':q,'audio':aid(q),'rows':QROWS[b['id']][qi]} for qi,q in enumerate(b['questions'])],
                  'examples':[{'ga':e,'audio':aid(e)} for e in b['examples']],'rows':rows})
json.dump(units,open('data/units.json','w'),ensure_ascii=False)
json.dump(sorted(audio),open('data/audio_texts.json','w'),ensure_ascii=False)
print(len(units),'units',sum(len(r['sentences']) for u in units for r in u['rows']),'sentences',len(audio),'audio texts')
for u in units[:8]:
    s=u['rows'][0]['sentences'][0]; print(' ',s['ga'],'|',s['en'])
