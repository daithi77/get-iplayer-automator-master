"""Turn the grammar workflow's journal into app/data/grammar.json.
Prefers a section's repaired (checked) version over its first rewrite."""
import json, re, sys, collections
J='/root/.claude/projects/-home-user-get-iplayer-automator-master/ccdd5904-a3e0-5217-a79e-cb30cb56d957/subagents/workflows/wf_3e5b1dca-621/journal.jsonl'
SECS=json.load(open('gram/sections.json'))
label={}; res={}
for l in open(J):
    try: j=json.loads(l)
    except: continue
    if j.get('type')=='started': label[j['agentId']]=j.get('label','')
    if j.get('type')=='result': res[label.get(j.get('agentId'),'?')]=j
def get(k):
    j=res.get(k)
    if not j: return None
    r=j.get('result'); return json.loads(r) if isinstance(r,str) else r
# year a section opens (Key Stage 3 sections from Year 8; conditional, habitual, verbal adjective from 10; declensions and compound prepositions from 11)
YEAR={'copail':8,'r1-chaite':8,'r1-laithreach':8,'r1-fhaistineach':9,'r2-chaite':8,'r2-laithreach':8,'r2-fhaistineach':9,
 'nr-chaite':8,'nr-laithreach':8,'nr-fhaistineach':9,'sealbhach':8,'uimhreacha':8,'dobhriathar':9,
 'r1-coinniollach':10,'r1-gnathchaite':10,'r2-coinniollach':10,'r2-gnathchaite':10,'nr-coinniollach':10,'nr-gnathchaite':10,
 'reamhfhocail-simpli':8,'reamhfhocail-briathra':9,'aidiachtai':9,'d1':11,'d2':11,'d3':11,'d4':11,'d5':11,
 'reamhfhocail-chomhshuite':10,'ainm-briathartha':9,'aidiacht-bhriathartha':10}
PH=re.compile(r'(_{3,}\s*\([^)]*\)|\([^)]*\)\s*_{3,}|_{3,}|\([^)]*\))')
def tidy(s): return re.sub(r'\s+',' ',s or '').strip()
def endpunct(s): return re.sub(r'[\s.?!]+$','',s)
def split_item(stem, fresh):
    """Return (before, hint, after, answer) when the stem has exactly one placeholder that aligns with fresh."""
    stem=tidy(stem); fresh=tidy(fresh)
    ms=list(PH.finditer(stem))
    if len(ms)!=1: return None
    m=ms[0]; before=stem[:m.start()].rstrip(); after=stem[m.end():].lstrip()
    hint=re.sub(r'[_()]','',m.group(0)).strip()
    f=endpunct(fresh); a=endpunct(after)
    if before and not f.lower().startswith(before.lower()): return None
    if a and not f.lower().endswith(a.lower()): return None
    ans=f[len(before):len(f)-len(a)].strip() if a else f[len(before):].strip()
    if not ans or len(ans.split())>6: return None
    return (before, hint, after, ans)
out=[]; counts=collections.Counter()
for s in SECS:
    r=get('repair:'+s['id']) or get('rewrite:'+s['id'])
    if not r: continue
    checked='repair:'+s['id'] in res
    items=[]; models=[]
    for x in r['sentences']:
        shape=x['shape']; fresh=tidy(x['fresh']); stem=tidy(x['stem']); point=tidy(x['point'])
        if not fresh: continue
        base={'point':point,'note':tidy(x.get('note','')),'flag':bool(x.get('check')),'book':tidy(x['original']),'page':x.get('page')}
        if shape in ('model','caption'):
            models.append({**base,'ga':re.sub(r'\[pictiúr:[^\]]*\]\s*','',fresh)}); counts['model']+=1; continue
        if shape in ('stem','gap'):
            sp=split_item(stem, fresh)
            if sp:
                b,h,a,ans=sp
                items.append({**base,'kind':'fill','before':b,'hint':h,'after':a,'answer':ans,'full':fresh}); counts['fill']+=1; continue
            if stem:
                items.append({**base,'kind':'whole','prompt':stem,'answer':fresh}); counts['whole']+=1; continue
        if shape in ('transform','question','free') and stem:
            items.append({**base,'kind':'self','prompt':stem,'answer':fresh,'shape':shape}); counts['self_'+shape]+=1; continue
        models.append({**base,'ga':fresh}); counts['model_fallback']+=1
    out.append({'id':s['id'],'title':s['title'],'year':YEAR.get(s['id'],9),'checked':checked,
        'rules':[{'point':tidy(x['point']),'text':tidy(x['statement'])} for x in r['rulesUlster']],
        'tables':[{'title':tidy(p['title']),'rows':[tidy(f) for f in p['forms']]} for p in r['paradigmsUlster']],
        'items':items,'models':models})
json.dump(out,open('app/data/grammar.json','w'),ensure_ascii=False)
print(len(out),'sections', counts, 'checked:',sum(o['checked'] for o in out))
