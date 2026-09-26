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

# ---------------- Vocabulary ----------------
vs=wb.create_sheet('Vocabulary')
cols=['ID','Irish','Gender','Number','Type','Verb root','Verbal noun','Preposition','English','Context','Topic','Sub-topic','Tier','Status','Origin','Source page','Notes','Irish as printed']
widths=[8,34,8,8,13,22,24,12,38,30,32,24,6,10,12,8,30,34]
header(vs,cols,widths)
r=2
for e in c['vocab']:
    tp=(e['topic'] or ('','')); topic=tp[1] or tp[0]; sub=(e['sub'] or ('',''))[1]
    head,g,n,t,root,vn,prep=split_entry(e['ga'],sub,topic)
    notes=''
    if not e['en']: notes='English missing in the source layout; entry may be split across two rows.'
    vals=[f"V{r-1:04d}",head,g,n,t,root,vn,prep,e['en'],ctx_label(e),topic,sub,'', 'Raw','Source list',e['page'],notes,e['ga']]
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
('Grammar points',f"=COUNTA(Grammar!A2:A{GSPARE})"),('Rubrics',f"=COUNTA(Rubrics!A2:A{RSPARE})")]
for a,f in counts:
    rm.cell(row=r,column=1,value=a).font=ARIAL; cl=rm.cell(row=r,column=2,value=f); cl.font=ARIAL; cl.alignment=Alignment(horizontal='left'); r+=1
rm.cell(row=r+1,column=1,value='Source: the specification appendices supplied as a PDF (71 pages), extracted automatically on 26 September 2026. Source page numbers refer to that PDF.').font=Font(name='Arial',size=9,italic=True)
wb.save(sys.argv[2]); print('saved',LASTV,LASTQ,LASTG,LASTR)
