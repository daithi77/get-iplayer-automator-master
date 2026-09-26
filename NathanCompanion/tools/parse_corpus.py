import pymupdf, json, re, collections, sys
d=pymupdf.open(sys.argv[1])
entries=[]; ctx=topic=sub=None
for i in range(17,71):
    rows=collections.defaultdict(list)
    for b in d[i].get_text("dict")["blocks"]:
        for l in b.get("lines",[]):
            for s in l["spans"]:
                t=s["text"].strip()
                if not t or s["size"]<10: continue
                y=round(s["bbox"][1]/3)*3
                rows[y].append((s["bbox"][0],t,s["font"],s["size"]))
    cur=None
    for y in sorted(rows):
        sp=sorted(rows[y])
        left=" ".join(t for x,t,f,z in sp if x<300); right=" ".join(t for x,t,f,z in sp if x>=300)
        font=sp[0][2]; size=sp[0][3]; x0=sp[0][0]
        if "Bold" in font:
            if size>=13.5: 
                if left.startswith("Context"): ctx=left
                elif left.startswith("Appendix") or left.startswith("Irish Core"): pass
                else: ctx+=" "+left
            elif "Arial" in font: topic=(left,right)
            else: sub=(left,right)
            cur=None; continue
        if x0>95 and cur is not None and x0<300:   # continuation line
            cur["ga"]+=" "+left; 
            if right: cur["en"]+=" "+right
            continue
        if not left and right and cur: cur["en"]+=" "+right; continue
        cur={"ga":left,"en":right,"ctx":ctx,"topic":topic,"sub":sub,"page":i+1}
        entries.append(cur)
for e in entries:
    e["ga"]=re.sub(r"\s+"," ",e["ga"]).strip(); e["en"]=re.sub(r"\s+"," ",e["en"]).strip()
    e["masc"]="[m" in e["ga"]; e["verb"]=bool(re.search(r"\(ag ",e["ga"]))
json.dump(entries,open("vocab.json","w"),ensure_ascii=False,indent=1)
print(len(entries), "entries;", sum(e["masc"] for e in entries),"masc;", sum(e["verb"] for e in entries),"verbs;", sum(1 for e in entries if not e["en"]),"missing English")
c=collections.Counter(e["ctx"] for e in entries); print(c)
t=collections.Counter((e["topic"] or ("",""))[1] for e in entries); print(t)
s=collections.Counter((e["sub"] or ("",""))[1] for e in entries); print(len(s), s.most_common(12))
