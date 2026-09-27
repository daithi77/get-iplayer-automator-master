"""Turn data/grammar_exemplars.json (the PDF grammar, rewritten in Ulster Irish) into beta/data/grammar.json
for the AS and A2 grammar track. Flagged sentences (check: true) are left out until Dáithí reviews them."""
import json, re
SRC = json.load(open('../data/grammar_exemplars.json'))
TITLES = {"copail":"An chopail 'Is'","r1-chaite":"An chéad réimniú: an aimsir chaite","r1-laithreach":"An chéad réimniú: an aimsir láithreach",
 "r1-fhaistineach":"An chéad réimniú: an aimsir fháistineach","r2-chaite":"An dara réimniú: an aimsir chaite","r2-laithreach":"An dara réimniú: an aimsir láithreach",
 "r2-fhaistineach":"An dara réimniú: an aimsir fháistineach","nr-chaite":"Na briathra neamhrialta: an aimsir chaite","nr-laithreach":"Na briathra neamhrialta: an aimsir láithreach",
 "nr-fhaistineach":"Na briathra neamhrialta: an aimsir fháistineach","sealbhach":"An aidiacht shealbhach","uimhreacha":"Na huimhreacha","dobhriathar":"An dobhriathar",
 "r1-coinniollach":"An chéad réimniú: an modh coinníollach","r1-gnathchaite":"An chéad réimniú: an aimsir ghnáthchaite","r2-coinniollach":"An dara réimniú: an modh coinníollach",
 "r2-gnathchaite":"An dara réimniú: an aimsir ghnáthchaite","nr-coinniollach":"Na briathra neamhrialta: an modh coinníollach","nr-gnathchaite":"Na briathra neamhrialta: an aimsir ghnáthchaite",
 "reamhfhocail-simpli":"Na réamhfhocail shimplí","reamhfhocail-briathra":"Réamhfhocail le briathra","aidiachtai":"Aidiachtaí agus céimeanna comparáide",
 "d1":"An chéad díochlaonadh","d2":"An dara díochlaonadh","d3":"An tríú díochlaonadh","d4":"An ceathrú díochlaonadh","d5":"An cúigiú díochlaonadh",
 "reamhfhocail-chomhshuite":"Réamhfhocail chomhshuite","ainm-briathartha":"An t-ainm briathartha","aidiacht-bhriathartha":"An aidiacht bhriathartha"}
EN = {"copail":"The copula","r1-chaite":"First conjugation: past","r1-laithreach":"First conjugation: present","r1-fhaistineach":"First conjugation: future",
 "r2-chaite":"Second conjugation: past","r2-laithreach":"Second conjugation: present","r2-fhaistineach":"Second conjugation: future","nr-chaite":"Irregular verbs: past",
 "nr-laithreach":"Irregular verbs: present","nr-fhaistineach":"Irregular verbs: future","sealbhach":"Possessive adjectives","uimhreacha":"Numbers","dobhriathar":"Adverbs of direction",
 "r1-coinniollach":"First conjugation: conditional","r1-gnathchaite":"First conjugation: past habitual","r2-coinniollach":"Second conjugation: conditional",
 "r2-gnathchaite":"Second conjugation: past habitual","nr-coinniollach":"Irregular verbs: conditional","nr-gnathchaite":"Irregular verbs: past habitual",
 "reamhfhocail-simpli":"Simple prepositions","reamhfhocail-briathra":"Prepositions with verbs","aidiachtai":"Adjectives and comparison","d1":"First declension",
 "d2":"Second declension","d3":"Third declension","d4":"Fourth declension","d5":"Fifth declension","reamhfhocail-chomhshuite":"Compound prepositions",
 "ainm-briathartha":"The verbal noun","aidiacht-bhriathartha":"The verbal adjective"}
GROUPS = [
 ("An chopail","The copula","🟰",["copail"]),
 ("An aimsir chaite","The past","⏪",["r1-chaite","r2-chaite","nr-chaite"]),
 ("An aimsir láithreach","The present","▶️",["r1-laithreach","r2-laithreach","nr-laithreach"]),
 ("An aimsir fháistineach","The future","⏩",["r1-fhaistineach","r2-fhaistineach","nr-fhaistineach"]),
 ("An aimsir ghnáthchaite","The past habitual","🔁",["r1-gnathchaite","r2-gnathchaite","nr-gnathchaite"]),
 ("An modh coinníollach","The conditional","🤔",["r1-coinniollach","r2-coinniollach","nr-coinniollach"]),
 ("An briathar: foirmeacha eile","Other verb forms","🧩",["ainm-briathartha","aidiacht-bhriathartha"]),
 ("An t-ainmfhocal","Nouns","📚",["d1","d2","d3","d4","d5","sealbhach"]),
 ("Na réamhfhocail","Prepositions","📍",["reamhfhocail-simpli","reamhfhocail-briathra","reamhfhocail-chomhshuite"]),
 ("Aidiachtaí, uimhreacha, dobhriathra","Adjectives, numbers, adverbs","🔢",["aidiachtai","uimhreacha","dobhriathar"]),
]
PIC = re.compile(r'\s*\[pictiúr:\s*([^\]]*)\]\s*')
def gap_answer(stem, fresh):
    parts = re.split(r'_{3,}', stem)
    if len(parts) != 2: return None
    a, b = parts[0], parts[1]
    if fresh.startswith(a) and fresh.endswith(b) and len(fresh) >= len(a) + len(b):
        return fresh[len(a):len(fresh) - len(b)].strip() or None
    return None
# The rewriting agents wrote notes for Dáithí into the rules ("the book prints", "flagged for the principal").
# Pupils see the rule only: bracketed asides about the book go, then any sentence that is still editorial.
ASIDE = re.compile(r"\s*\((?:[^()]*\b(?:the book|book's|book:|the app|extract)\b[^()]*)\)")
EDITORIAL = re.compile(r"\bthe book\b|\bbook's\b|\bthe app\b|\bapp's\b|principal|\bexercises?\b|\bstems?\b|\bextract\b|misprint|\bslips?\b|\bOCR\b|flagged|house adaptation|supplies it|the list keeps|summary table|\bdrafted\b|corrected|in line with the rest|\bthis section\b", re.I)
BOOKNOTE = re.compile(r"\s*\([^()]*\bbook\b[^()]*\)", re.I)
def nb(t):
    # Labels and table titles: drop bracketed, semicolon or sentence clauses about the book or for the principal.
    t = BOOKNOTE.sub('', t)
    parts = re.split(r'(;\s*|(?<=[.)])\s+)', t)
    keep = ''.join(x for x in parts if not re.search(r"\bbook\b|principal", x, re.I))
    return keep.strip().rstrip(';').strip()
def clean_rule(text):
    text = BOOKNOTE.sub('', ASIDE.sub('', text))
    kept = [x for x in re.split(r'(?<=[.!?])\s+', text.strip()) if x and not EDITORIAL.search(x)]
    return ' '.join(kept)
out = {'groups': [], 'sections': {}}
counts = {'model': 0, 'items': 0, 'dropped': 0}
for s in SRC['sections']:
    sid = s['sectionId']; models = []; items = []
    for x in s['sentences']:
        if x.get('check'): counts['dropped'] += 1; continue
        fresh = x['fresh'].strip(); stem = (x.get('stem') or '').strip(); shape = x['shape']
        if shape in ('model', 'caption'):
            m = PIC.search(fresh); cue = m.group(1) if m else ''
            models.append({'ga': PIC.sub(' ', fresh).strip(), 'cue': cue, 'point': nb(x['point'])}); continue
        if not stem: counts['dropped'] += 1; continue
        it = {'shape': shape, 'prompt': PIC.sub(' ', stem).strip(), 'answer': PIC.sub(' ', fresh).strip(), 'point': nb(x['point'])}
        if shape == 'gap':
            g = gap_answer(stem, fresh)
            if g: it['gap'] = g
        if shape in ('question', 'free'): it['self'] = True   # many right answers: pupil compares with the model
        # Reviewer notes (x['note']) are for Dáithí, not pupils, so they are not copied.
        items.append(it)
    counts['model'] += len(models); counts['items'] += len(items)
    out['sections'][sid] = {'id': sid, 'title': TITLES[sid], 'en': EN[sid],
        'rules': [{'point': nb(r['point']), 'text': t} for r in s.get('rulesUlster', []) for t in [clean_rule(r['statement'])] if t],
        'tables': [{'title': nb(p['title']), 'forms': [BOOKNOTE.sub('', f) for f in p['forms']]} for p in s.get('paradigmsUlster', [])],
        'models': models, 'items': items}
# Walk-through lessons (data/lessons/<id>.json), written per section: rule, steps, worked example, hint, practice.
import os
DASH = re.compile('[\u2013\u2014]')
def tidy(v):
    if isinstance(v, str): return DASH.sub(',', nb(v)) if v else v
    if isinstance(v, list): return [tidy(x) for x in v]
    if isinstance(v, dict): return {k: tidy(x) for k, x in v.items()}
    return v
for sid, sec in out['sections'].items():
    f = f'data/lessons/{sid}.json'
    if os.path.exists(f):
        L = json.load(open(f))
        lessons = tidy(L.get('lessons', []))
        # Every practice item carries shape, prompt, answer and point (the lesson title), so both apps can decode it.
        for l in lessons:
            l['more'] = l.get('more') or []
            clean = []
            for it in l.get('items', []):
                if not it.get('prompt') or not it.get('answer'): continue
                it['shape'] = it.get('shape') or 'stem'
                it['point'] = it.get('point') or l['title']
                if it['shape'] in ('question', 'free'): it['self'] = True
                clean.append({k: it[k] for k in ('shape', 'prompt', 'answer', 'point', 'gap', 'self') if k in it})
            l['items'] = clean
        sec['lessons'] = [l for l in lessons if l['items'] and l.get('example', {}).get('prompt')]
        if L.get('tables'): sec['tables'] = tidy(L['tables'])
for ga, en, em, ids in GROUPS:
    out['groups'].append({'ga': ga, 'en': en, 'emoji': em, 'sections': ids})
assert sorted(i for g in GROUPS for i in g[3]) == sorted(out['sections'])
json.dump(out, open('data/grammar.json', 'w'), ensure_ascii=False)
print(counts, {k: len(v['items']) for k, v in out['sections'].items() if len(v['items']) < 8 or len(v['models']) < 3})
