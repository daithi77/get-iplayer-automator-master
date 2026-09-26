import cv2, numpy as np, potrace, json
from fontTools.fontBuilder import FontBuilder
from fontTools.pens.t2CharStringPen import T2CharStringPen
from PIL import Image, ImageDraw, ImageFont

d=cv2.imread('deskew.png',0)
prof=(d>0).sum(axis=1)
bands=[];inb=False
for y,v in enumerate(prof):
    if v>0 and not inb: inb=True;y0=y
    elif v==0 and inb:
        inb=False
        if y-y0>8: bands.append((y0,y))

LABELS={0:list("abcdefghijklmnopqrstuvwxyz"),1:list("áéíóúÁÉÍÓÚ"),2:list("ABCDEFGHIJKLMNOPQRSTUVW"),3:list("XYZ"),
        4:list("0123456789/.,!?:()-"),5:["tick","tick","tick","cross","cross","cross"]}
DESC=set("gjpqy(),/")
XH=set("acemnorsuvwxz")

def comps_in(band):
    y0,y1=band; sub=d[y0:y1]
    n,lab,st,ce=cv2.connectedComponentsWithStats(sub,8)
    cs=[[x,y+y0,w,h] for i,(x,y,w,h,a) in enumerate(st) if i and a>=12]
    cs.sort(key=lambda c:c[0])
    # merge components that overlap in x (dots, fadas, stacked punctuation)
    merged=[]
    for c in cs:
        if merged:
            p=merged[-1]; px1=p[0]+p[2]; cx0=c[0]; cx1=c[0]+c[2]
            ov=min(px1,cx1)-max(p[0],cx0)
            if ov>0 or (cx0-px1)<=3:
                nx0=min(p[0],c[0]); ny0=min(p[1],c[1]); nx1=max(px1,cx1); ny1=max(p[1]+p[3],c[1]+c[3])
                merged[-1]=[nx0,ny0,nx1-nx0,ny1-ny0]; continue
        merged.append(list(c))
    return merged

glyphs={}  # label -> dict(bbox, baseline_px)
report=[]
for bi,labels in LABELS.items():
    cs=comps_in(bands[bi])
    report.append((bi,len(cs),len(labels)))
    assert len(cs)==len(labels), (bi,len(cs),len(labels))
    # baseline fit through bottoms of non-descenders
    pts=[(c[0]+c[2]/2,c[1]+c[3]) for c,l in zip(cs,labels) if l not in DESC and l not in ('.','-','tick','cross')]
    if len(pts)<3: pts=[(c[0]+c[2]/2,c[1]+c[3]) for c in cs]
    xs,ys=zip(*pts); k=np.polyfit(xs,ys,1) if len(pts)>2 else (0,np.median(ys))
    for c,l in zip(cs,labels):
        base=k[0]*(c[0]+c[2]/2)+k[1]
        key=l if l not in glyphs else l+str(sum(1 for g in glyphs if g.startswith(l)))
        glyphs[key]={"bbox":c,"base":float(base)}
print("band counts (found, expected):",report)

capH=np.median([g["base"]-g["bbox"][1] for k,g in glyphs.items() if k in "ABCDEFGHIJKLMNOPQRSTUVWXYZ"])
xH=np.median([g["base"]-g["bbox"][1] for k,g in glyphs.items() if k in XH])
UPM=1000; f=700.0/capH
print("cap px",capH,"x px",xH,"scale",f, "x-height units",xH*f)

def trace(key,g):
    x,y,w,h=g["bbox"]; pad=3
    crop=d[max(0,y-pad):y+h+pad, max(0,x-pad):x+w+pad]
    bm=potrace.Bitmap((crop==0))
    path=bm.trace(turdsize=3,alphamax=1.0,opticurve=True,opttolerance=0.25)
    pen=T2CharStringPen(0,None)
    ox=max(0,x-pad); oy=max(0,y-pad)
    def P(pt):
        px=(pt.x+ox-x)*f + 40   # left sidebearing 40 units, positioned from glyph left
        py=(g["base"]-(pt.y+oy))*f
        return (px,py)
    for curve in path:
        pen.moveTo(P(curve.start_point))
        for s in curve.segments:
            if s.is_corner:
                pen.lineTo(P(s.c)); pen.lineTo(P(s.end_point))
            else:
                pen.curveTo(P(s.c1),P(s.c2),P(s.end_point))
        pen.closePath()
    adv=int(w*f+80)
    return pen.getCharString(), adv

NAME={'tick':'checkmark','cross':'ballotx','/':'slash','.':'period',',':'comma','!':'exclam','?':'question',':':'colon','(':'parenleft',')':'parenright','-':'hyphen',
      'á':'aacute','é':'eacute','í':'iacute','ó':'oacute','ú':'uacute','Á':'Aacute','É':'Eacute','Í':'Iacute','Ó':'Oacute','Ú':'Uacute'}
for i in range(10): NAME[str(i)]=['zero','one','two','three','four','five','six','seven','eight','nine'][i]
def gname(k):
    base=k.rstrip('0123456789') if k[0] not in '0123456789' else k[0]
    suffix=k[len(base):] if k[0] not in '0123456789' else ''
    n=NAME.get(base,base)
    return n+('.alt'+suffix if suffix else '')

charstrings={}; advances={}; cmap={}
for k,g in glyphs.items():
    cs,adv=trace(k,g); n=gname(k); charstrings[n]=cs; advances[n]=(adv,0)
    base=k.rstrip('0123456789') if k[0] not in '0123456789' else k[0]
    if n.endswith('.alt1') or n.endswith('.alt2'): continue
    if base=='tick': cmap[0x2713]=n; cmap[0x2714]=n
    elif base=='cross': cmap[0x2717]=n; cmap[0x2718]=n; cmap[0x00D7]=n
    else: cmap[ord(base)]=n
# space and .notdef
pen=T2CharStringPen(0,None); charstrings['.notdef']=pen.getCharString(); advances['.notdef']=(300,0)
pen=T2CharStringPen(0,None); charstrings['space']=pen.getCharString(); advances['space']=(260,0); cmap[0x20]='space'; cmap[0xA0]='space'
order=['.notdef','space']+[n for n in charstrings if n not in ('.notdef','space')]

fb=FontBuilder(UPM,isTTF=False)
fb.setupGlyphOrder(order); fb.setupCharacterMap(cmap)
fb.setupCFF("MarkingHand-Regular",{"FullName":"Marking Hand","FamilyName":"Marking Hand","Weight":"Regular"},charstrings,{})
fb.setupHorizontalMetrics(advances)
fb.setupHorizontalHeader(ascent=int(capH*f*1.25),descent=-int(0.35*UPM))
fb.setupNameTable({"familyName":"Marking Hand","styleName":"Regular","fullName":"Marking Hand","psName":"MarkingHand-Regular","uniqueFontIdentifier":"MarkingHand;2026","version":"Version 0.1"})
fb.setupOS2(sTypoAscender=int(capH*f*1.25),sTypoDescender=-int(0.35*UPM),usWinAscent=int(capH*f*1.25),usWinDescent=int(0.35*UPM),sxHeight=int(xH*f),sCapHeight=700)
fb.setupPost()
fb.save("MarkingHand-Regular.otf")
print("glyphs:",len(order))

# proof sheet
font=ImageFont.truetype("MarkingHand-Regular.otf",64)
lines=["abcdefghijklmnopqrstuvwxyz","áéíóú ÁÉÍÓÚ","ABCDEFGHIJKLMNOPQRSTUVWXYZ","0123456789 /.,!?:()-","✓✓✓ ✗✗✗","séimhiú urú maith","ar aghaidh féach","ceart mícheart","Ard. Bun. 1/1 0/1 3/4","Séimhiú i nGaeilge Uladh, ní urú!"]
im=Image.new("RGB",(1500,1150),"white"); dr=ImageDraw.Draw(im)
for i,t in enumerate(lines): dr.text((60,40+i*105),t,font=font,fill=(200,16,46))
im.save("proof.png")
