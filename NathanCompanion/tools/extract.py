import pymupdf, json, re, collections, sys
PDF=sys.argv[1]
d=pymupdf.open(PDF)

def rows_of(page, ymerge=3):
    rows=collections.defaultdict(list)
    for b in page.get_text("dict")["blocks"]:
        for l in b.get("lines",[]):
            for s in l["spans"]:
                t=s["text"]
                if not t.strip() or s["size"]<10: continue
                rows[round(s["bbox"][1]/ymerge)*ymerge].append((s["bbox"][0],t,s["font"],s["size"]))
    return [sorted(rows[y]) for y in sorted(rows)]

# ---------- Appendix 5: vocabulary (pages 18-71) ----------
vocab=[]; ctx=topic=sub=None; last_topic_row=False
for i in range(17,71):
    cur=None
    for sp in rows_of(d[i]):
        left="".join(t for x,t,f,z in sp if x<300).strip(); right="".join(t for x,t,f,z in sp if x>=300).strip()
        font=sp[0][2]; size=sp[0][3]; x0=sp[0][0]
        if "Bold" in font:
            if size>=13.5:
                if left.startswith("Context"): ctx=left
                elif left.startswith("Appendix") or left.startswith("Irish Core"): pass
                else: ctx=(ctx or "")+" "+left
            elif "Arial" in font:
                if last_topic_row: topic=((topic[0]+" "+left).strip(),(topic[1]+" "+right).strip())
                else: topic=(left,right); sub=None
                last_topic_row=True; cur=None; continue
            else: sub=(left,right)
            last_topic_row=False; cur=None; continue
        last_topic_row=False
        if x0>95 and x0<300 and cur is not None:
            cur["ga"]+=" "+left
            if right: cur["en"]+=" "+right
            continue
        if not left and right and cur: cur["en"]+=" "+right; continue
        cur={"ga":left,"en":right,"ctx":ctx,"topic":topic,"sub":sub,"page":i+1}; vocab.append(cur)
for e in vocab:
    e["ga"]=re.sub(r"\s+"," ",e["ga"]).strip(); e["en"]=re.sub(r"\s+"," ",e["en"]).strip()

# ---------- Appendix 3: speaking questions (pages 6-14) ----------
qs=[]; ctx=topic=None
for i in range(5,14):
    cur=None
    for sp in rows_of(d[i]):
        text="".join(t for x,t,f,z in sp).strip(); font=sp[0][2]; size=sp[0][3]
        if "Bold" in font:
            if size>=13.5:
                if text.startswith("Context"): ctx=text
                elif text.startswith("Appendix") or text.startswith("Unit") or text.startswith("1 and 2"): pass
                else: ctx=(ctx or "")+" "+text
            else: topic=text
            cur=None; continue
        if cur and not re.match(r"^(Cad|Cá|Cé|Cén|An|Ar|Inis|Déan|Do |Cuir)\b",text):
            cur["q"]+=" "+text; continue
        cur={"q":text,"ctx":ctx,"topic":topic,"page":i+1}; qs.append(cur)
for q in qs: q["q"]=re.sub(r"\s+"," ",q["q"]).strip()

# ---------- Appendix 4: grammar (pages 15-17) ----------
gr=[]; tier=area=None
for i in range(14,17):
    cur=None
    for sp in rows_of(d[i]):
        left="".join(t for x,t,f,z in sp if x<240).strip(); right="".join(t for x,t,f,z in sp if x>=240).strip()
        font=sp[0][2]; size=sp[0][3]
        if "Arial" in font:
            if "Tier" in left: tier=left.replace(" Tier","").strip()
            cur=None; continue
        if "Bold" in font:
            if left.startswith("Grammar and Structures") or left.startswith("All grammar"): cur=None; continue
            area=left; cur=None; continue
        if size<11: continue
        if left and (left[0].isupper() or not cur):
            cur={"tier":tier,"area":area,"point":left,"ex":right,"page":i+1}; gr.append(cur)
        elif cur:
            if left: cur["point"]+=" "+left
            if right: cur["ex"]+=" "+right
for g in gr:
    g["point"]=re.sub(r"\s+"," ",g["point"]).strip(); g["ex"]=re.sub(r"\s+"," ",g["ex"]).strip()
gr=[g for g in gr if g["tier"] and not g["point"].startswith("GCSE") and not g["point"].startswith("All grammar")]

json.dump({"vocab":vocab,"questions":qs,"grammar":gr},open("corpus.json","w"),ensure_ascii=False,indent=1)
print(len(vocab),"vocab;",len(qs),"questions;",len(gr),"grammar points")
