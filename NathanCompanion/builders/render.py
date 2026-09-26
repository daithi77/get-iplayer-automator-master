import json, html
d=json.load(open('year8.json')); E=html.escape
BE={'b1-mefein':'🙋','b2-teaghlach':'👨‍👩‍👧‍👦','b3-cursios':'🪞','b4-ceantar':'🏡','b5-scoil':'🏫','b6-caitheamh':'⚽','b7-la':'⏰','b8-guthan':'📱'}
KE={'peil Ghaelach':'🏐','sacar':'⚽','iomáint':'🏑','camógaíocht':'🏑','rugbaí':'🏉','cispheil':'🏀','leadóg':'🎾','haca':'🏑','eitpheil':'🏐','an pianó':'🎹','an giotár':'🎸','an fheadóg stáin':'🎶','an fhidil':'🎻','ar an bhus':'🚌','sa charr':'🚗','ar mo rothar':'🚲','de shiúl na gcos':'🚶',
 'Tá madadh':'🐶','Tá cat':'🐱','Tá coinín':'🐰','Tá iasc órga':'🐠','Tá hamstar':'🐹','Tá muc ghuine':'🐹','Tá capall':'🐴','Tá éan':'🐦',
 'guthán cliste':'📱','táibléad':'📲','ríomhaire glúine':'💻','le teachtaireachtaí a sheoladh':'💬','le cluichí a imirt':'🎮','le grianghraif a thógáil':'📷','le héisteacht le ceol':'🎧','le hamharc ar fhíseáin':'🎬',
 'Amharcaim ar an teilifís':'📺','Téim ag snámh':'🏊','Téim chuig an phictiúrlann':'🍿','Léim leabhair':'📚','Imrím cluichí ríomhaire':'🎮','Téim ag rothaíocht':'🚴','Téim ag marcaíocht':'🏇','Téim chuig an spórtlann':'🏋️','Bím ag damhsa':'💃','Canaim i gcór':'🎤','Bím ag rith':'🏃',
 'Éirím':'🛏️','Ithim mo bhricfeasta':'🥣','Téim a luí':'😴',"Déanaim m'obair bhaile":'✏️',
 'an ceol':'🎵','an ealaín':'🎨','an corpoideachas':'🏃','an mhatamaitic':'➗','an eolaíocht':'🔬','an stair':'🏰','an tíreolaíocht':'🌍','an Ghaeilge':'☘️','an Béarla':'📖',
 'siopa':'🛒','páirc':'🌳','club CLG':'🏐','linn snámha':'🏊','i dteach':'🏠','in árasán':'🏢','i mbungaló':'🏡','faoin tuath':'🐄'}
def chunk(c,k):
    em=KE.get(c['ga'],'')
    return f'<div class="c k{k}{" opt" if c.get("optional") else ""}">{f"<span class=em aria-hidden=true>{em}</span>" if em else ""}<span class="ga" lang="ga">{E(c["ga"])}</span><span class="en">{E(c["en"])}</span></div>'
def row(r):
    cols=''
    for k,col in enumerate(r['columns']):
        if k: cols+='<div class="arrow" aria-hidden="true">→</div>'
        cols+='<div class="col">'+''.join(chunk(c,k%4) for c in col)+'</div>'
    return f'<div class="row"><p class="lab">{E(r["label"])}</p><div class="grid">{cols}</div></div>'
secs=[]
for n,b in enumerate(d['builders'],1):
    qs=''.join(f'<p class="bubble q" lang="ga">{E(x)}</p>' for x in b['questions'])
    ex=''.join(f'<p class="bubble a" lang="ga">{E(x)}</p>' for x in b['examples'])
    secs.append(f'<section class="b" id="{b["id"]}"><header><span class="big" aria-hidden="true">{BE[b["id"]]}</span><div><h2 lang="ga">{n}. {E(b["title"])}</h2><p class="sub">{E(b["en"])}</p></div></header><div class="chat"><span class="who">An cheist</span>{qs}</div>{"".join(row(r) for r in b["rows"])}<div class="chat right"><span class="who">Do fhreagra</span>{ex}</div></section>')
toc=''.join(f'<a href="#{b["id"]}"><span aria-hidden="true">{BE[b["id"]]}</span> {E(b["title"])}</a>' for b in d['builders'])
css=open('style.css').read()
open('year8.html','w').write(f'<title>Year 8 Sentence Builders</title>\n<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Atkinson+Hyperlegible:ital,wght@0,400;0,700;1,400&display=swap">\n<style>{css}</style>\n<div class="wrap"><div><h1>☘️ Year 8 sentence builders</h1><p class="lede">Pick one tile from each colour, left to right, and you have a sentence. Every combination is correct. Dashed tiles are optional.</p></div><nav aria-label="Builders">{toc}</nav>{"".join(secs)}</div>')
print('rendered')
