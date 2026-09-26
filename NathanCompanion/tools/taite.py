"""Add the synthetic (tháite) first-person-plural variant for present and future forms.
Deterministic: analytic 'X muid' -> synthetic, only for present and future endings and the
irregular verbs' present and future stems. Everything else is left alone."""
import re
IRREG={ # analytic -> synthetic, present and future of the irregular verbs (Ulster school forms)
 'tá muid':'táimid','níl muid':'nílimid','bhfuil muid':'bhfuilimid','bíonn muid':'bímid','mbíonn muid':'mbímid','beidh muid':'beimid','mbeidh muid':'mbeimid',
 'deir muid':'deirimid','ndeir muid':'ndeirimid','déarfaidh muid':'déarfaimid','ndéarfaidh muid':'ndéarfaimid',
 'tchí muid':'tchímid','feiceann muid':'feicimid','bhfeiceann muid':'bhfeicimid','tchífidh muid':'tchífimid','feicfidh muid':'feicfimid',
 'gheobhaidh muid':'gheobhaimid','bhfaighidh muid':'bhfaighimid','faigheann muid':'faighimid','bhfaigheann muid':'bhfaighimid',
 'rachaidh muid':'rachaimid','téann muid':'téimid','dtéann muid':'dtéimid',
 'déanann muid':'déanaimid','ndéanann muid':'ndéanaimid','déanfaidh muid':'déanfaimid','ndéanfaidh muid':'ndéanfaimid',
 'tagann muid':'tagaimid','dtagann muid':'dtagaimid','tiocfaidh muid':'tiocfaimid','dtiocfaidh muid':'dtiocfaimid',
 'itheann muid':'ithimid','n-itheann muid':'n-ithimid','íosfaidh muid':'íosfaimid','n-íosfaidh muid':'n-íosfaimid',
 'tugann muid':'tugaimid','dtugann muid':'dtugaimid','tabharfaidh muid':'tabharfaimid','dtabharfaidh muid':'dtabharfaimid',
 'cluineann muid':'cluinimid','gcluineann muid':'gcluinimid','cluinfidh muid':'cluinfimid','gcluinfidh muid':'gcluinfimid',
 'beireann muid':'beirimid','mbeireann muid':'mbeirimid','béarfaidh muid':'béarfaimid','mbéarfaidh muid':'mbéarfaimid',
}
RULES=[ # (regex on the analytic verb + muid, replacement)
 (r'\b(\w+?)aíonn muid\b', r'\1aímid'),   # 2nd conj broad present: ceannaíonn muid -> ceannaímid
 (r'\b(\w+?)íonn muid\b',  r'\1ímid'),    # 2nd conj slender present: bailíonn muid -> bailímid
 (r'\b(\w+?)eann muid\b',  r'\1imid'),    # 1st conj slender present: cuireann muid -> cuirimid (before the broad rule)
 (r'\b(\w+?)ann muid\b',   r'\1aimid'),   # 1st conj broad present: dúnann muid -> dúnaimid
 (r'\b(\w+?)óidh muid\b',  r'\1óimid'),   # 2nd conj broad future: ceannóidh muid -> ceannóimid
 (r'\b(\w+?)eoidh muid\b', r'\1eoimid'),  # 2nd conj slender future: baileoidh muid -> baileoimid
 (r'\b(\w+?)faidh muid\b', r'\1faimid'),  # 1st conj broad future: dúnfaidh muid -> dúnfaimid
 (r'\b(\w+?)fidh muid\b',  r'\1fimid'),   # 1st conj slender future: cuirfidh muid -> cuirfimid
]
def taite(text):
    out=text
    for a,s in IRREG.items():
        out=re.sub(r'\b'+re.escape(a)+r'\b', s, out); out=re.sub(r'\b'+re.escape(a[0].upper()+a[1:])+r'\b', s[0].upper()+s[1:], out)
    for pat,rep in RULES:
        out=re.sub(pat, rep, out); out=re.sub(pat.replace(r'\b(\w+?)', r'\b([A-ZÁÉÍÓÚ]\w*?)'), rep, out)
    return out
if __name__=='__main__':
    for t in ['Cuireann muid an pláta ar an bhord.','Ceannaíonn muid milseáin achan Aoine.','Bailíonn muid na cóipleabhair.','Dúnfaidh muid an doras.','Cuirfidh muid ceist air.','Ceannóidh muid é amárach.','Baileoidh muid iad.','Tá muid ag caint.','Ní bhíonn muid ann.','Rachaidh muid go Doire.','An dtéann muid?','Chuir muid an pláta ar an bhord.','Chuirfeadh muid ceist.','D\'ól muid tae.']:
        print(f'{t:45s} -> {taite(t)}')
