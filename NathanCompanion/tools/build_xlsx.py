import sys
import json, re
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment, Border, Side
from openpyxl.worksheet.datavalidation import DataValidation
from openpyxl.utils import get_column_letter

c=json.load(open('corpus.json'))
GENERAL={'Adjectives (common)','Comparatives','Conjunctions and connectives','Days, months, seasons','Simile','Greetings','Intensifiers','Negatives','Numbers – ordinal and cardinal','Opinions – positive/negative, justifications','Prepositions','Pronouns','Questions','Time – telling the time, expressions of time','Other common verbs'}
CTX={'1':'1 Identity, Lifestyle and Culture','2':'2 Local, National, International and Global','3':'3 School Life, Studies and the World of Work','G':'General (all contexts)'}
def ctx_label(e):
    t=(e['topic'] or ('',''))[1]
    if t in GENERAL: return CTX['G']
    m=re.search(r'Context for Learning (\d)',e['ctx'] or ''); return CTX[m.group(1)] if m else ''

TAG=re.compile(r'\s*\[(n?)(m|f)?(pl)?\]')
VERB=re.compile(r'^(?P<root>[^()]*?)\s*\((?P<vn>ag [^)]*)\)\s*(?P<rest>.*)$')
def split_entry(ga, sub, topic):
    gender=number=''; 
    for m in TAG.finditer(ga):
        if m.group(2): gender=m.group(2)
        if m.group(3): number='pl'
    head=TAG.sub('',ga).strip()
    root=vn=prep=''; typ=''
    m=VERB.match(head)
    if m and m.group('vn'):
        root=m.group('root').strip(); vn=m.group('vn').strip(); rest=m.group('rest').strip()
        if rest and re.fullmatch(r'(ar|le|as|do|de|ag|faoi|chuig|ó|i|in|roimh|thar|um|go|trí)( .*)?',rest): prep=rest
        elif rest: root=(root+' '+rest).strip()
        typ='verb'
        if root=='' : root=head
    elif sub=='Useful constructions': typ='construction'
    elif topic=='Numbers – ordinal and cardinal': typ='number'
    elif topic=='Questions' or head.endswith('?'): typ='question'
    elif topic=='Prepositions': typ='preposition'
    elif topic=='Pronouns': typ='pronoun'
    elif topic in ('Adjectives (common)','Comparatives'): typ='adjective'
    elif topic in ('Conjunctions and connectives',): typ='connective'
    elif gender: typ='noun'
    return head,gender,number,typ,root,vn,prep

ARIAL=Font(name='Arial',size=11); BOLD=Font(name='Arial',size=11,bold=True); H1=Font(name='Arial',size=14,bold=True)
HFILL=PatternFill('solid',fgColor='1F3864'); HFONT=Font(name='Arial',size=11,bold=True,color='FFFFFF')
EDIT=PatternFill('solid',fgColor='FFF2CC'); thin=Side(style='thin',color='BFBFBF')
def header(ws,cols,widths):
    for i,(h,w) in enumerate(zip(cols,widths),1):
        cl=ws.cell(row=1,column=i,value=h); cl.font=HFONT; cl.fill=HFILL; cl.alignment=Alignment(vertical='center',wrap_text=True)
        ws.column_dimensions[get_column_letter(i)].width=w
    ws.row_dimensions[1].height=32; ws.freeze_panes='B2'
def finish(ws,ncols,nrows):
    ws.auto_filter.ref=f"A1:{get_column_letter(ncols)}{nrows}"
    for row in ws.iter_rows(min_row=2,max_row=nrows,max_col=ncols):
        for cl in row:
            if cl.font!=BOLD: cl.font=ARIAL
            cl.alignment=Alignment(vertical='top',wrap_text=True)

wb=Workbook()
# ---------------- Lists ----------------
ls=wb.active; ls.title='Lists'
lists={'Gender':['m','f'],'Number':['sg','pl'],'Type':['noun','verb','adjective','adverb','phrase','construction','question','number','preposition','pronoun','connective','other'],
       'Tier':['F','H'],'Status':['Raw','Checked','Edited','Added','Remove'],'Origin':['Source list','Added'],
       'Context':[CTX['1'],CTX['2'],CTX['3'],CTX['G']],'GrammarTier':['Foundation','Higher']}
for j,(k,v) in enumerate(lists.items(),1):
    ls.cell(row=1,column=j,value=k).font=BOLD
    for i,x in enumerate(v,2): ls.cell(row=i,column=j,value=x).font=ARIAL
    ls.column_dimensions[get_column_letter(j)].width=max(14,max(len(x) for x in v)+2)
def dv(ws,col,key,last):
    n=len(lists[key]); L=get_column_letter(list(lists).index(key)+1)
    d=DataValidation(type='list',formula1=f"=Lists!${L}$2:${L}${n+1}",allow_blank=True,showErrorMessage=True,errorTitle='Not on the list',error=f'Choose a value from the {key} list (Lists sheet), or leave blank.')
    ws.add_data_validation(d); d.add(f"{col}2:{col}{last}")

# ---------------- KS3 appendix ----------------
from openpyxl import load_workbook
KS=load_workbook(sys.argv[3],data_only=True)
ksv=[r for r in KS['Irish KS3 Vocab-by frequency'].iter_rows(min_row=2,values_only=True) if r[3]]
def ks_key(h):
    h=re.sub(r'[\*]','',str(h)); h=re.split(r'[|/;]',h)[0]; h=re.sub(r'\([^)]*\)','',h); return h.strip().strip('()').lower()
ks_rank={}
for r in ksv:
    k=ks_key(r[3])
    if k and k not in ks_rank: ks_rank[k]=r[1]
def gcse_key(head):
    h=re.split(r'[,/(]',head)[0]; return h.strip().lower()

# ---------------- Vocabulary ----------------
vs=wb.create_sheet('Vocabulary')
cols=['ID','Irish','Gender','Number','Type','Verb root','Verbal noun','Preposition','English','Context','Topic','Sub-topic','Tier','Status','Origin','Source page','Notes','Irish as printed','KS3 rank']
widths=[8,34,8,8,13,22,24,12,38,30,32,24,6,10,12,8,30,34,9]
header(vs,cols,widths)
r=2
for e in c['vocab']:
    tp=(e['topic'] or ('','')); topic=tp[1] or tp[0]; sub=(e['sub'] or ('',''))[1]
    head,g,n,t,root,vn,prep=split_entry(e['ga'],sub,topic)
    notes=''
    if not e['en']: notes='English missing in the source layout; entry may be split across two rows.'
    rk=ks_rank.get(gcse_key(head)) or ks_rank.get(gcse_key(root)) if (head or root) else None
    vals=[f"V{r-1:04d}",head,g,n,t,root,vn,prep,e['en'],ctx_label(e),topic,sub,'', 'Raw','Source list',e['page'],notes,e['ga'],rk]
    for j,v in enumerate(vals,1): vs.cell(row=r,column=j,value=v)
    r+=1
LASTV=r-1; SPARE=4000
finish(vs,len(cols),SPARE)
for col,key in [('C','Gender'),('D','Number'),('E','Type'),('J','Context'),('M','Tier'),('N','Status'),('O','Origin')]: dv(vs,col,key,SPARE)
for row in vs.iter_rows(min_row=2,max_row=SPARE,min_col=2,max_col=17):
    for cl in row:
        if cl.column!=16: cl.fill=EDIT
vs.column_dimensions['P'].hidden=False

# ---------------- Speaking questions ----------------
qs=wb.create_sheet('Speaking questions')
qcols=['ID','Question (Irish)','Question (English)','Context','Topic','Tier','Model answer (Foundation)','Model answer (Higher)','Status','Origin','Source page','Notes']
qw=[8,52,40,30,36,6,50,50,10,12,8,30]
header(qs,qcols,qw); r=2
for q in c['questions']:
    m=re.search(r'Context for Learning (\d)',q['ctx'] or ''); cl=CTX[m.group(1)] if m else ''
    vals=[f"Q{r-1:03d}",q['q'],'',cl,q['topic'],'','','','Raw','Source list',q['page'],'']
    for j,v in enumerate(vals,1): qs.cell(row=r,column=j,value=v)
    r+=1
LASTQ=r-1; QSPARE=800
finish(qs,len(qcols),QSPARE)
for col,key in [('D','Context'),('F','Tier'),('I','Status'),('J','Origin')]: dv(qs,col,key,QSPARE)
for row in qs.iter_rows(min_row=2,max_row=QSPARE,min_col=2,max_col=12):
    for cl in row:
        if cl.column!=11: cl.fill=EDIT

# ---------------- Grammar ----------------
gs=wb.create_sheet('Grammar')
gcols=['ID','Tier','Area','Point','Examples','Receptive only','Status','Origin','Source page','Notes']
gw=[8,12,28,40,52,10,10,12,8,36]
header(gs,gcols,gw); r=2
for g in c['grammar']:
    rec='Y' if '(R)' in g['point'] else ''
    vals=[f"G{r-1:02d}",g['tier'],g['area'],g['point'].replace(' (R)',''),g['ex'],rec,'Raw','Source list',g['page'],'']
    for j,v in enumerate(vals,1): gs.cell(row=r,column=j,value=v)
    r+=1
LASTG=r-1; GSPARE=300
finish(gs,len(gcols),GSPARE)
for col,key in [('B','GrammarTier'),('G','Status'),('H','Origin')]: dv(gs,col,key,GSPARE)
for row in gs.iter_rows(min_row=2,max_row=GSPARE,min_col=2,max_col=10):
    for cl in row:
        if cl.column!=9: cl.fill=EDIT

# ---------------- Rubrics (exam instructions) ----------------
rs=wb.create_sheet('Rubrics')
rcols=['ID','Irish','English','Paper','Tier','Status','Notes']; rw=[8,50,50,12,10,10,30]
header(rs,rcols,rw)
rub=[('Scríobh an freagra ceart sa bhosca.','Write the correct answer in the box.','Listening','F'),
('Críochnaigh an abairt i nGaeilge.','Complete the sentence in Irish.','Listening','F'),
('Scríobh an uimhir cheart sa bhosca.','Write the correct number in the box.','Listening','H'),
('Scríobh an abairt cheart sa bhosca.','Write the correct sentence in the box.','Listening','H'),
('Léigh an sliocht agus freagair na ceisteanna.','Read the passage and answer the questions.','Reading','F'),
('Cuir tic le dhá rud a itheann Seosamh.','Tick two things that Seosamh eats.','Reading','F'),
('Cuir tic sna boscaí cearta.','Tick the correct boxes.','Reading','F'),
('Cuir tic le ceithre ráitis atá fíor.','Tick four statements that are true.','Reading','F'),
('Léigh an blag seo.','Read this blog.','Reading','F'),
('Léigh an fógra seo.','Read this notice.','Reading','F'),
('Léigh an fógra thíos.','Read the notice below.','Reading','F'),
('Cuir an duine ceart le gach pictiúr.','Match the correct person with every picture.','Reading','F'),
('Cuir an litir cheart i ngach bosca.','Put the correct letter in every box.','Reading','F'),
('Críochnaigh na habairtí. Úsáid na focail/frásaí sa bhosca thíos.','Finish the sentences. Use the words/phrases in the box below.','Reading','F')]
rub+=[('Léigh an ríomhphost thíos.','Read the email below.','Reading','H'),
('Cuir an duine ceart leis an phictiúr chuí.','Match the correct person with the appropriate picture.','Reading','H'),
('Cuir an litir cheart sa bhosca cuí.','Put the correct letter in the appropriate box.','Reading','H'),
('Scríobh i nGaeilge.','Write in Irish.','Writing','F'),
('Roghnaigh ceist AMHÁIN as na trí rogha agus scríobh do fhreagra i nGaeilge.','Choose ONE question from the three options provided and write your answer in Irish.','Writing','F')]
import sys
r=2
for ga,en,paper,tier in rub:
    for j,v in enumerate([f"R{r-1:02d}",ga,en,paper,tier,'Raw',''],1): rs.cell(row=r,column=j,value=v)
    r+=1
LASTR=r-1; RSPARE=200
finish(rs,len(rcols),RSPARE)
for col,key in [('E','Tier'),('F','Status')]: dv(rs,col,key,RSPARE)
for row in rs.iter_rows(min_row=2,max_row=RSPARE,min_col=2,max_col=7):
    for cl in row: cl.fill=EDIT

# ---------------- KS3 vocabulary ----------------
kv=wb.create_sheet('KS3 vocabulary')
kvcols=['ID','List order','Frequency rank','Part of speech','Headword','English','Category','Status','Notes']; kvw=[8,10,12,16,34,40,14,10,30]
header(kv,kvcols,kvw); r=2
for row in ksv:
    for j,v in enumerate([f"K{r-1:03d}",row[0],row[1],row[2],row[3],row[4],row[5],'Raw',''],1): kv.cell(row=r,column=j,value=v)
    r+=1
LASTK=r-1; KSPARE=1500
finish(kv,len(kvcols),KSPARE)
dv(kv,'H','Status',KSPARE)
for row in kv.iter_rows(min_row=2,max_row=KSPARE,min_col=4,max_col=9):
    for cl in row: cl.fill=EDIT

# ---------------- KS3 phonics ----------------
kp=wb.create_sheet('KS3 phonics')
kpcols=['Sound-symbol correspondence','Source word','English','Frequency','Cluster word 1','English','Frequency','Cluster word 2','English','Frequency','Status','Notes']; kpw=[30,16,22,10,16,22,10,16,22,10,10,30]
header(kp,kpcols,kpw); r=2
prow=[x for x in KS.worksheets[0].iter_rows(min_row=1,values_only=True) if any(x)]
started=False
for row in prow:
    a=str(row[0] or '')
    if a.startswith('Irish sound-symbol'): started=True; continue
    if not started: continue
    vals=[row[0],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[9],row[10],'Raw' if row[2] else '','']
    for j,v in enumerate(vals,1):
        cl=kp.cell(row=r,column=j,value=v)
        if not row[2]: cl.font=BOLD
    r+=1
LASTP=r-1; PSPARE=300
finish(kp,len(kpcols),PSPARE)
for row in kp.iter_rows(min_row=2,max_row=PSPARE,min_col=1,max_col=12):
    for cl in row:
        if cl.font!=BOLD: cl.fill=EDIT
dv(kp,'K','Status',PSPARE)

# ---------------- KS3 grammar ----------------
kg=wb.create_sheet('KS3 grammar')
kgcols=['ID','Term','Irish grammar features','Status','Notes']; kgw=[8,30,90,10,30]
header(kg,kgcols,kgw); r=2
for row in KS['Irish KS3 Grammar'].iter_rows(min_row=2,values_only=True):
    if row[4] or row[5]:
        for j,v in enumerate([f"KG{r-1:02d}",row[4],row[5],'Raw',''],1): kg.cell(row=r,column=j,value=v)
        r+=1
LASTKG=r-1; KGSPARE=200
finish(kg,len(kgcols),KGSPARE)
dv(kg,'D','Status',KGSPARE)
for row in kg.iter_rows(min_row=2,max_row=KGSPARE,min_col=2,max_col=5):
    for cl in row: cl.fill=EDIT
for rr in range(2,LASTKG+1): kg.row_dimensions[rr].height=110

# ---------------- READ ME ----------------
rm=wb.create_sheet('READ ME',0)
rm.column_dimensions['A'].width=30; rm.column_dimensions['B'].width=95
lines=[('Nathán companion: corpus workbook',H1),('',ARIAL),
('Purpose','One place to clean, correct and extend the language data the companion app will ship. Every sheet exports to the app as it stands, so what is here is what pupils will see.'),
('Yellow cells','Editable. Change anything in a yellow cell. White cells (ID, Source page) are for reference and should be left alone.'),
('Status','Every row starts as Raw. Set it to Checked when you have confirmed the row, Edited if you changed it, Added for a row you created, Remove for a row the app should drop. Only Checked, Edited and Added rows are exported.'),
('Adding rows','Type into the next empty row. Give it the next ID in sequence, set Status to Added and Origin to Added. The dropdowns already cover the spare rows.'),
('Gender','The source marked masculine nouns only. A blank Gender on a noun almost always means feminine, but confirm each one rather than assuming.'),
('Verbs','Root, verbal noun and governing preposition were split automatically from entries written as "buail (ag bualadh) le". Check the split; compound verbs like "cuir iarratas isteach ar" will need a hand.'),
('Type','Inferred where the source made it obvious (verbs, nouns with a gender mark, numbers, questions). Blank Type means undecided: fill it in.'),
('Context and Topic','The three Contexts for Learning, plus General for vocabulary that belongs to no single topic (days, numbers, prepositions, connectives). Rename topics freely; the app uses whatever is here.'),
('Speaking questions','The conversation question bank by topic. The English and the two model-answer columns are empty and are for authoring.'),
('Grammar','The checklist of structures examined, with examples. Receptive only means the pupil need only recognise it.'),
('Rubrics','Exam instruction wording, Irish and English, for the decoder cards.'),
('Irish as printed','The original string before any splitting, kept so a bad automatic split can be recovered. Never exported.'),
('KS3 rank','The word\'s frequency rank in the Key Stage 3 Irish appendix, where the headword matches. Blank means the word is not on the KS3 list, or is written differently there.'),
('KS3 vocabulary','The Key Stage 3 appendix list as issued for consultation, in its frequency order: about 800 headwords with part of speech, gender and frequency rank. The primary spine for Years 8 to 10.'),
('KS3 phonics','The sound-symbol correspondences from the same appendix, each with a source word and cluster words.'),
('KS3 grammar','The Irish grammar features from the appendix. Only the two Irish columns were taken; the draft sheet\'s first four columns carry Spanish content by mistake and were left out.'),
('',ARIAL),('Example of an added row (Vocabulary)',BOLD),
('','ID V2248 | Irish: scáthán | Gender: m | Number: sg | Type: noun | English: mirror | Context: 2 Local, National, International and Global | Topic: My local environment | Sub-topic: In my house | Status: Added | Origin: Added'),
('',ARIAL),('Counts',BOLD)]
r=1
for a,b in lines:
    if isinstance(b,Font): rm.cell(row=r,column=1,value=a).font=b
    else:
        rm.cell(row=r,column=1,value=a).font=BOLD; cl=rm.cell(row=r,column=2,value=b); cl.font=ARIAL; cl.alignment=Alignment(wrap_text=True,vertical='top')
    r+=1
counts=[('Vocabulary rows',f"=COUNTA(Vocabulary!A2:A{SPARE})"),('  Raw',f'=COUNTIF(Vocabulary!N2:N{SPARE},"Raw")'),('  Checked',f'=COUNTIF(Vocabulary!N2:N{SPARE},"Checked")'),('  Edited',f'=COUNTIF(Vocabulary!N2:N{SPARE},"Edited")'),('  Added',f'=COUNTIF(Vocabulary!N2:N{SPARE},"Added")'),('  Remove',f'=COUNTIF(Vocabulary!N2:N{SPARE},"Remove")'),
('  Verbs',f'=COUNTIF(Vocabulary!E2:E{SPARE},"verb")'),('  Nouns marked masculine',f'=COUNTIF(Vocabulary!C2:C{SPARE},"m")'),('  Nouns marked feminine',f'=COUNTIF(Vocabulary!C2:C{SPARE},"f")'),('  English missing',f'=COUNTIFS(Vocabulary!A2:A{SPARE},"<>",Vocabulary!I2:I{SPARE},"")'),
('Speaking questions',f"=COUNTA('Speaking questions'!A2:A{QSPARE})"),('  with a Foundation model answer',f"=COUNTIFS('Speaking questions'!A2:A{QSPARE},\"<>\",'Speaking questions'!G2:G{QSPARE},\"<>\")"),
('Grammar points',f"=COUNTA(Grammar!A2:A{GSPARE})"),('Rubrics',f"=COUNTA(Rubrics!A2:A{RSPARE})"),('KS3 headwords',f"=COUNTA('KS3 vocabulary'!A2:A{KSPARE})"),('  GCSE words with a KS3 rank',f"=COUNT(Vocabulary!S2:S{SPARE})"),('KS3 sound-symbol correspondences',f"=COUNTIF('KS3 phonics'!K2:K{PSPARE},\"Raw\")"),('KS3 grammar terms',f"=COUNTA('KS3 grammar'!A2:A{KGSPARE})")]
for a,f in counts:
    rm.cell(row=r,column=1,value=a).font=ARIAL; cl=rm.cell(row=r,column=2,value=f); cl.font=ARIAL; cl.alignment=Alignment(horizontal='left'); r+=1
rm.cell(row=r+1,column=1,value='Sources: the specification appendices supplied as a PDF (71 pages; Source page numbers refer to it), and the Key Stage 3 Irish appendix spreadsheet issued for consultation. Both extracted automatically on 26 September 2026.').font=Font(name='Arial',size=9,italic=True)
wb.save(sys.argv[2]); print('saved',LASTV,LASTQ,LASTG,LASTR)
