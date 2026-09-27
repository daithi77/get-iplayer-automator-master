# Grammar slide decks (group_grammar): patterns, inventory, problems and a 2026 house style

## Summary

This group has 26 files. Only **19 are distinct grammar decks**: two pairs are byte-identical, one is a cut-down PowerPoint export of a Keynote, and four were misfiled because "aimsir" is in their titles (weather, a provinces map, pastimes, directions). The files date from **2002 to 2013**, not 2006 to 2013. Most were written by colleagues (McKeown, Bonner, Rafferty, McNamee, an AS teacher). Dáithí's own work is the three Keynotes (2009 and 2012). So the "canonical" style is really the department's style, with his Keynotes as the cleanest form of it.

The patterns that recur most:
- **The change is shown in red** (12 of 19 decks).
- **Question and negative are always taught with the positive** (12 of 19), often as a fork: question → yes / no.
- **Pictures or a routine carry the meaning** (7 of 19).
- **An irregular-verb reference table** (7 of 19).
- **Broad/slender side by side, or a 2x2 grid** (short/long × broad/slender).
- **Verbs sorted into Groups 1, 2 and 3.**
- **Memory aids**: "Many Boys Go Camping...", "he likes noodles and rice", DAFDA.
- **A "Sprioc" (aim) slide**, and a reveal where the verb goes red.

The decks contain real errors that must not be copied: "Ní + urú", "An n-éirím", "dún" and "clois". I also found problems in the app itself:
- `clasail.json` and `nr-chaite.json` disagree about "abair".
- `r1-chaite.json` spells "úrlár" (should be "urlár").
- `uimhreacha.json` uses "tar éis", while Year 8 uses "i ndiaidh".
- `grammar.json` still holds 119 "dún" forms, 134 "clois" forms and 35 "bord". It is hidden now, and must stay hidden unless cleaned.

Top recommendations, in order:
1. Highlight the change letter by letter (red for letters added to the verb, green for particles).
2. Fix the four app problems above.
3. Build the Year 8 routine as "one day, three tenses".
4. Add six new slide types to the grammar deck: Sprioc, table, 2x2 grid, question fork, memory aid and a quick-fire round.
5. Add Group 3 (syncopated) verbs and a slide showing the two particle families.

---

## 1. Design and pedagogy patterns

### 1a. What the group really is

| | Count | Files |
|---|---|---|
| Files in the group list | 26 | |
| Byte-identical duplicates | 2 | Coibhneasta (84ab87d5 = f7115c7c); Urú (ee45b205 = fde222d0) |
| Cut-down export | 1 | bc5755f8 Dialann an Lae (PPT, 17 slides) is a truncated export of the 77b1b84a Keynote (21 slides) |
| Misfiled topic decks (matched on "aimsir") | 4 | An Aimsir Bliain 8 (weather), Aimsir_A (a one-slide provinces map for weather), Caithimh Aimsire Year 11 (pastimes, oral Q&A), Treoracha (directions) |
| **Distinct grammar decks** | **19** | Listed in section 2 |

**Authorship** (from `file` metadata). Gerard McKeown wrote 7 decks, C. Bonner 3, "Mr McNamee" 3 (one routine series), an AS teacher account (ST2-5260286) 2, E. Rafferty 1, "Teacher" 1, and Noella Murray 1 ("Last saved by Dith Murray", 2008). The **Keynotes have no author field**, but they are the Mac decks and I take them to be Dáithí's own: An Aimsir Chaite 2012 and Dialann an Lae Bliain 8 (2009); the weather deck is also 2009. Creation dates run from 17 September 2002 (the McNamee template) to May 2013.

### 1b. The patterns, and how often they appear (out of 19 grammar decks)

| Pattern | Decks | How it looks |
|---|---|---|
| **Accent colour marks the change** | 12 | Red endings, red "h", red "Ar/Níor"; pink "a + séimhiú" (relative); coloured initial letters (urú); yellow slender/broad vowel (Briathra na Gaeilge). In Dáithí's Dialann Keynote each picture appears twice: first with a black caption, then with the verb and pronoun in red. |
| Red used specifically for letters added to the verb (h, ending, particle) | 8 | Modh Coinníollach, Rafferty Láithreach, Tenses, Neamhrialta chaite, both Bonner tables, 2012, Dialann Keynote. The present-tense Ar Maidin (7935e0f2, outside this group) goes further: **green** for particle plus eclipsis, **red** for the ending. |
| Question and negative taught with the positive | 12 | Separate slides, or a **fork diagram** (question → Dúirt / Níor dhúirt; An gcuirfeá? → chuirfinn / ní chuirfinn), or the 2012 **triangle** (Question at the top, Positive and Negative at the base). |
| Question / yes / no triplet on one slide | 6 | "Ar ith tú lón? / D'ith mé lón. / Níor ith mé." (the McNamee routine decks) |
| Verb built on screen by animation | 4 | Root on screen, "Ní" drops in with a **caret (^) and a red h** above it, and the ending flies in (the Bonner decks, Modh Coinníollach, Briathra). Removed letters (igh, aigh, ail) sit in a separate faded column. The animations collapse into unreadable overlaps in export, so the 2026 version needs tap-to-reveal states instead. |
| Broad/slender side by side, or a 2x2 grid | 4 decks + the .doc | "Broad Verbs \| Slender Verbs" columns (Rafferty). The 2x2 of "1 syl / 2 syl × Slender / Broad" with Bris, Tóg, Éirigh, Ceannaigh (Present Tense Endings). The Cleachtaí .doc has a pupil copy task: "Déan amach bosca mar seo" (Caol/Leathan × Siolla amháin / Níos mó ná siolla amháin). |
| Verb grouping | 4 | Rafferty "Group 1 / 2 / 3", where Group 3 is two-syllable verbs in (a)il, (a)in, (a)ir, (a)is: "remove the vowels, add a group 2 ending". Present Tense Endings labels verbs "1s, 1br, 2s, 2br". Briathra na Gaeilge uses "gairid (1 siolla) / fada (2 shiolla)". |
| Irregular-verb reference table | 7 | Black and blue grids with "(ní) t(h)éann" and the h in red. The past-tense irregulars are split **5 with Ar/Níor, then 6 with An/Ní** (2012: "Notice: we now use Ní and An for the remaining six"). |
| Picture carries the meaning | 7 | One action per slide in all the routine decks, flashcards (gach lá), imperative picture commands (Siúil! Rith! Druid!). |
| Memory aids | 4 | "Many Boys Go Camping Near Ditches BeHind Fences Nice Girls Back Pack Down Town" (urú); "Britney caught dopey friends going mad publicly, silly twits", "he likes noodles and rice", "scallions smell spicy in stew" (2012); "Fan: D'fhan Dan; Imigh: D'imigh Jimmy; Pill: Phill Phil" (Briathra); **DAFDA** (Coibhneasta: Dobhriathartha, then Áit, Fáth, Dóigh, Am). |
| **Particle families** | 3 | "Níor, Ar, Gur, Nár + séimhiú" against "An, Go, Nach + urú" (Tenses, Coibhneasta). Present Tense Endings uses symbols: "AN = ?", "NÍ = x". |
| Tense colour-coding | 1 (strong) | Tenses deck: past yellow, present blue, future green, conditional pink. One verb per slide, five lines each: positive, negative, question with short answers, "Dúirt mé gur...", "Dúirt mé nár...". |
| "Future first" bridge | 1 | Modh Coinníollach: "Aimsir fháistineach ar dtús!!". Cuirfidh becomes chuirfeadh, with arrows from muid and siad to the synthetic forms (chuirfimis, chuirfidís). |
| Sprioc (aim) slide | 2 (+1 misfiled) | All in Dáithí's Keynotes. The weather deck also opens with an equipment slide: "hardbacked book... Pencil, **Red pen**". What is red on the slide is what pupils write in red. |
| Practice inside the deck | 6 | ✔/✘ lenition sort (2012); 21 English sentences with answer slides (Réamhfhocal); "Bain triail as" translation (Coibhneasta); flashcard "Dúshlán" (gach lá); match-the-ending (Modh); sort lists (Bonner). |
| Song or poem | 1 | "Ag dul a luí domh" (irregular verbs in the present): "Cluinimse an tús de nuacht a naoi..." |
| Graded model answers a) to d) | 1 (misfiled) | Caithimh Aimsire Year 11: one question per slide, 3 or 4 model answers of rising difficulty. |

### 1c. Typical sequence within a deck

- **Full rule decks** (Rafferty, AN AIMSIR CAITE 2008, 2012): title → (Sprioc) → the verbs to use (roots with English) → the rule in English → endings table (broad against slender) → one worked verb per group → question → negative → irregular verbs, one per slide → a sentence frame or practice. In 2012 each section opens with a **divider slide** titled in Irish, with the English beneath it ("An fhoirm dhiúltach / Dealing with the negative").
- **Visual build decks** (Bonner, Modh): no prose at all. Positive → "Ní" with the h → "An" with eclipsis → a column of verbs taking the same ending → Group 2 the same way → an irregular reference table ("MAR EOLAS DAOIBH").
- **Routine decks** (McNamee, Dialann): an opening question ("Cad é a rinne tú ar maidin?"), then one action per slide in time order, from waking up to falling asleep.

### 1d. Density, and Irish against English

- **Dáithí's Keynotes are the sparsest**: one sentence and one picture per slide, 21 to 60 slides, section dividers, and a small green "Key Words" box that defines terms.
- **The colleagues' rule decks are dense**: Rafferty has 5 to 8 bullet lines, and Coibhneasta has paragraphs in English.
- **Explanation language**: rules are in English with Irish terms in about 9 of the 19 (KS3, GCSE and AS rule decks). Headings are bilingual ("Gutaí Caola / Slender Vowels").
- About 9 decks are **Irish only, with pictures or symbols**: all the routine decks, the build decks and the poem. **Year 8 content is immersive; rules for older pupils are explained in English.**
- The app already fits this split: English rule text, with a toggle to hide the English.

### 1e. What is distinctively Dáithí's (the Keynotes)

- An aim before content.
- One idea per slide.
- Picture, then the sentence, then the **target chunk turned red**.
- A glossary box for key words.
- Irish section titles with English subtitles.
- The question/positive/negative triangle.
- Sorting with a ✔/✘ answer reveal.
- The verb-first coloured frame (already reviewed).

Everything else in the group is department practice that he chose to keep.

---

## 2. Content inventory

Levels: Y8 = Year 8; KS3 = Years 9 and 10; GCSE = Years 11 and 12; AS/A2.

| # | Deck | Topic and structures | Level | Author, date | Quality | Duplicate / best |
|---|---|---|---|---|---|---|
| 1 | 00263141 Neamhrialta aimsir chaite (2 slides) | 11 past irregulars: question / positive / negative table, Ar group shaded red; question fork | KS3 | McKeown 2004 | Good table; "Clois / Cluin"; Ulster "Ar dhúirt / Níor dhúirt" | Superseded by #2 |
| 2 | 07d51cc0 An Aimsir Chaite 2012 (60) | Regular past, d', Níor/Ar, 11 irregulars (5+6), pronouns, sentence frame | Y8/KS3 | Dáithí (Keynote) 2012 to 2013 | Very good (already reviewed) | Best past-tense deck |
| 3 | 1a5132bb Modh Coinníollach (14) | Conditional built from the future; -finn/-feá/-feadh; synthetic muid/siad; question fork; ending match; irregular table | GCSE/AS | McKeown 2006 | Strong visuals; **irregular table half copied from the present/past table** | Only version |
| 4 | 251c62b2 Aimsir fháistineach (9) | Future: -faidh/-fidh, -óidh/-eoidh; Ní + h; An + urú; sort lists incl. Músclóidh, Osclóidh | KS3 | Bonner 2004 | Clean, no prose | Only version |
| 5 | 2eab7e49 An Aimsir Láithreach (35) | Present: rules in English, broad/slender endings, Groups 1/2/3, questions, negatives, 11 irregulars | KS3/GCSE | Rafferty 2005 to 2006 | Good structure; **"An n-éirím", "An n-imríonn" (wrong)**; "infinitive" | Best explanation of the present |
| 6 | 360c7844 gach lá aimsir chaite (22) | Flashcards: 22 past forms with cartoons ("Dúshlán, Aonad 9") | Y8 | McKeown 2004 | Fun; "D'oibir", "Chocaráil"; 3 slides without pictures; a cigarette image | Only version |
| 7 | 4b1e5807 AN AIMSIR CAITE (13) | Past: verb list, time phrases, rules, 10 irregulars | KS3 | N. Murray, saved by "Dith Murray" 2008 | Fair (reviewed in appendix A) | Superseded by #2 |
| 8 | 50de0527 Briathra na Gaeilge agus an aimsir chaite (26) | Slender/broad vowels; 4 verb sorts (short/long × broad/slender); **picture imperatives**; "Giving orders"; pronouns; past with the caret; D'fhan Dan | Y8 | McKeown 2005 to 2006 | Good ideas; lists **dún**; "scríob"; "mé = me" | Appendix A saw only a shell; the full deck is this one |
| 9 | 75e576a6 aimsir láithreach (18) | Present by animated build; Groups 1 and 2; question; negative; irregular table (MAR EOLAS) | KS3 | Bonner 2004 | Clean; "Clois / Cluin" | Pair with #5 and #17 |
| 10 | 77051d8c Réamhfhocal simplí + an (11) | Preposition + an + séimhiú (Ulster); d, n, t, l, s and vowel exceptions; feminine s → ts; 21 sentences to translate, with answers | KS3/GCSE | "Teacher" 2006 | Good, Ulster; several slips (section 3) | Only version |
| 11 | 77b1b84a Dialann an Lae Bliain 8 (21, Keynote) | Past routine: picture, then red verb and pronoun | Y8 | Dáithí 2009 | Very good design; stops at lunchtime; "cupan" | **Best** (bc5755f8 is its 17-slide export) |
| 12 | 7c1ac06a aimsir chaite Ar Scoil (11) | Past triplets at school: subjects, "Labhair mé / D'éist mé...", lunch, leaving | Y8 | McNamee 2002 to 2004 | Good; "Máta", "Bhí An Ghaeilge" | Same text as 4e25a058, 873b3609, f42b5a1d |
| 13 | 7f3c4732 neamhrialta láithreach (6) | Poem "Ag dul a luí domh" (present irregulars) + a three-tense table (past, present, ní form) | Y8/KS3 | Bonner, saved by godochartaigh 2004 to 2005 | Charming, Ulster ("domh", "Tchím"); "leapaí", "Clois" | Best irregular table (3 tenses) |
| 14 | 7f3f3a5a Dialann an Lae future (40) | Whole day in the future, one sentence per slide with a picture | Y8/KS3 | McNamee template 2002 to 2003 | Good coverage; "Musclóidh", "bus-stad", "ar a teilifís" | Only future version |
| 15 | 84ab87d5 An Coibhneasta (19) | Direct and indirect relative; particle groups; dependent forms; DAFDA; question words; exceptions; "a bheas" | AS/A2 | ST2 2005 | Useful grid; **"Ní + urú" (wrong)**; "Cén chaoi" | = f7115c7c |
| 16 | a6cae279 Tenses / Comhréir na n-aimsirí (13) | One verb × tense, five lines, with gur/nár and go/nach; colour per tense | GCSE/AS | ST2 2005 | Strong concept; many typos ("Cionníollach", "An bhágfaidh") | Only version |
| 17 | ace8550a Present Tense Endings (6) | 2x2 ending grid; verb lists labelled 1s/1br/2s/2br; question words; AN/NÍ/GO/NACH effects | KS3 | McKeown 2006 | Compact summary; "Oscail*" listed twice | Only version |
| 18 | e7198a45 aimsir chaite Sa Tráthnóna (14) | Past triplets for the evening, to bed | Y8 | McNamee 2003 | Good, "cluin" | Same text as 384d98f3, 5907069e, 80ece6cb |
| 19 | ee45b205 Urú Many Boys (11) | Eclipsis memory aid; places and 7 to 10 + noun; vowels | KS3 | McKeown 2005 to 2006 | Fun; "Nice/No Girls", "Gaillímh", "ina chonaí" | = fde222d0 |

**Misfiled (belong in topic groups):**
- 1009ffc7 An Aimsir Bliain 8 (weather, Dáithí 2009): picture then caption, Sprioc and equipment slides.
- f77eb660 Aimsir_A (a blank provinces map, for weather).
- 3e3a30d8 Caithimh Aimsire Year 11 (oral Q&A with graded answers; errors: "sa spóirt", "chlub na n-nóg", "Imríonn spórt").
- cabfa8c8 Treoracha (directions and a Gaeltacht-college role-play).

**Supporting document:** b0c95f73 Cleachtaithe ar an aimsir Láithreach (.doc). Four sheets of the 2x2 sorting box, a person-cue cloze ("(Rith mé) ___ ar nós na gaoithe") and a past-to-present rewrite. The title should read "Cleachtaí". It contains "Dún", "Féach", "Fill", "Tarla" and a stray "Éistfimid".

### 2b. The daily-routine family compared (in this group and outside it)

| Series | Files | Tense | Differences |
|---|---|---|---|
| Ar Maidin (McNamee) | 3a6f5c54, 4f2e7cf4, 97906fee | Past | Identical text: triplets from waking to the bus stop |
| Ar Maidin (McKeown's edit, 2005) | **7935e0f2** | **Present** | Same pictures, rebuilt as "Cad é a dhéanann tú gach maidin?" with a green particle and red ending ("An **gc**uir**eann** tú...? Cuir**im**. Ní c**h**uir**im**."). **The only present-tense routine, and the best colour model in the family.** |
| Ar Scoil | 7c1ac06a (in group), 4e25a058, 873b3609, f42b5a1d | Past | Identical text |
| Sa Tráthnóna | e7198a45 (in group), 384d98f3, 5907069e, 80ece6cb | Past | Identical text |
| Dialann an Lae future | 7f3f3a5a | Future | The whole day in 40 slides; same template and clip art |
| Dialann an Lae Bliain 8 | **77b1b84a** (Keynote), bc5755f8 (export) | Past | Dáithí's redesign: white slides, photos, a Sprioc, red chunks. Stops at lunch. |

**Best combined version:**
- **Design**: the Keynote's picture → red-chunk reveal.
- **Past**: Ar Maidin, Ar Scoil and Sa Tráthnóna together, which cover the whole day with questions.
- **Present**: 7935e0f2.
- **Future**: 7f3f3a5a.

The same pictures run through all three tenses. The department was already doing "one day, three tenses" by copying the file, and the app can do it on purpose (section 4d).

---

## 3. Problems

### 3a. Breaches of the rulings

| Ruling | Where |
|---|---|
| Never "dún" | Briathra na Gaeilge (broad short list: "dún" next to "Druid !"); Cleachtaí .doc item 9 |
| "cluin", not "clois" | "Clois / Cluin" in Neamhrialta chaite, the Bonner present table, neamhrialta láithreach, and Modh ("Chluinfinn / chloisfinn"); **2012 deck slide 31 "Clois - v. to hear"** (not flagged in the earlier summary) |
| Present/future 1st plural analytic | No breaches; the decks use muid throughout. The Cleachtaí .doc has one stray "Éistfimid". |
| Conditional: both forms in muid/siad | Modh shows both (good) |
| "tábla", not "bord" | No breaches ("ar an tábla" everywhere) |
| -amar/-eamar | None |

### 3b. Errors worth knowing (so nothing is carried across)

- **Coibhneasta**: "Ní + urú" is wrong (Ní lenites; only An, Go and Nach eclipse). "one is direct an one"; "saorbhriathair"; "Cá fhad" glossed only as "How far?" (also "how long"). The consonant list repeats "D".
- **Rafferty Láithreach**: "An n-éirím gach maidin?" and "An n-imríonn sé peil?" are wrong. An never changes a vowel; the right forms are An éiríonn tú? and An imríonn sé? McKeown's own summary says "AN ... doesn't affect vowels". Also "Séan"; the negative note lists only h, l, n, r and vowels (sc, sm, sp, st missing).
- **Modh Coinníollach** slide 14: the Gabh, Ith, Tabhair and Tar rows show present or past forms ("Téim / Ní théim", "D'ith mé"). They should be rachainn, d'íosfainn, thabharfainn (Ulster bhéarfainn) and thiocfainn.
- **Tenses**: "Modh Cionníollach" (×3); "An bhágfaidh" and "An bhágfadh" (should be bhfágfaidh, bhfágfadh); "Ní Fhágfadh / Ní fhágfadh" (should be D'fhágfadh); missing fadas in "Thog", "Togfaidh", "Thogfadh".
- **Réamhfhocal**: "séimhiú i gcónaí" is contradicted by the next slide; "Má tá an ainmfhocal firinscineach" (should be an t-ainmfhocal, firinscneach); "na bhaile roimh an naoi" (abhaile roimh a naoi); "roimh an deich" (roimh a deich); "D'fhág muid ón choirnéal"; "Tá.an".
- **Urú**: "Nice Girls" on one slide, "No Girls" on another; "Gaillímh"; "ina chonaí"; "Speres".
- **Routine decks**: "cupan"; "Musclóidh"; "bus-stad" (stad an bhus); "ar a teilifís"; "Máta"; "Bhí An Ghaeilge"; "éadaí" and "éadaigh" mixed; "ar a leath" and "ar leath" mixed.
- **Briathra na Gaeilge**: "scríob"; éirigh listed as both short and long; "mé = me" (should be I); "Rith chun an tsiopa" (Ulster: chuig an siopa).
- **gach lá**: "D'oibir" (D'oibrigh), "Chocaráil" (Chócaráil).
- **neamhrialta láithreach**: "ag bun mo leapaí" (leapa); "ins an".
- **2012**: "We drunk"; "User-Defined Placeholder Text" left on the title slide.

### 3c. Non-Ulster forms

"Cén chaoi" (Coibhneasta; Ulster: Cén dóigh), "Féach" and "Fill" (Cleachtaí; Ulster: amharc, pill), "chun an tsiopa". Otherwise the group is solidly Ulster: tchím, domh, béarfaidh mé ar an bhus, gheobhaidh, ag cur fearthainne, achan, foscailte, and the "a bheas" relative.

### 3d. Misleading terms

- **"Infinitive" for the root** (Rafferty, 2008, and 2012 throughout). It is the imperative / order form, used as the root. Pupils who later meet "verbal noun" (the real equivalent of the English infinitive) are confused. Use **fréamh (root) = the command form**.
- **"Aspirate / aspiration"** is dated. The app already says séimhiú / lenition, which is right.
- **"Group 1 / Group 2"** means verb classes in Rafferty but **particle families** in Tenses and Coibhneasta. Keep "Grúpa 1, 2, 3" for verbs only, and name the particles by family (section 4a).
- "We can't use 'mé' in the Present Tense" is overstated. Say: "mé is built into the ending: -aim / -im".

### 3e. Problems found in the app while cross-checking

1. **Inconsistency**:
   - `nr-chaite.json` ("Ní: déan, feic, abair...", "Ceist le An...") teaches **Ní dúirt / An ndúirt**.
   - `clasail.json` ("Na briathra neamhrialta san aimsir chaite") puts abair with tar, tabhair etc. and teaches **gur dhúirt**.
   - The 2012 deck agrees with nr-chaite; the 2004 deck has the Ulster Ar/Níor dhúirt.
2. `r1-chaite.json` spells **"úrlár"** twice (should be "urlár"). Every other file has it right.
3. `r1-chaite.json`, "Briathra nach nglacann séimhiú": the rule lists l, n, r, sc, sp, st and **omits sm** (the decks' "scallions smell..." includes it).
4. `uimhreacha.json` ("An t-am") uses **"tar éis a"** 14 times, while `units.json` (Year 8) and every deck use **"i ndiaidh a"**.
5. **Legacy data in `grammar.json`**: the old `rules`, `tables` and `models` hold **119 dún forms, 134 clois forms, 35 bord/bhord**, and "dhúnamar, chuireamar". None of it is shown today, because every section now has lessons and `gSlides` then ignores it. **Do not surface these tables in the new table slides; write new ones.**
6. The current deck (`gSlides` / `gdeckHTML`) is title → contents → (rule text + steps → Sampla → 3 random items) per lesson → end.
   - `hl()` marks **whole changed words**, never the letters that changed.
   - There is no table, grid, question fork, aim, memory aid or tense identity.
   - The rule slide is the densest slide in the deck, where Dáithí's decks keep slides sparse.

---

## 4. For the app in 2026

### 4a. House style for grammar slides and lessons

**Principles, as kept from the decks and updated:**

1. **One idea per slide.** Rule at most 30 words; at most 3 steps; tables at most 7 rows; at most 6 model sentences.
2. **The change is the hero.**
   - **Red** (token `--chg`, lighter in dark mode, always also **underlined**, never colour alone): letters added to the verb, i.e. h, eclipsis letters, d', endings.
   - **Green/teal** (`--part`): the particle (An, Ní, Níor, Ar, go, nach, gur, nár, a).
   - **Grey strikethrough**: letters removed (igh, aigh, the syncopated vowel).
   - The slide should say: "What is red here is what you write in red in your book."
3. **Question, yes and no always travel together** (the fork).
4. **Broad beside slender; one syllable beside two.** Always the same axes.
5. **Tense has a colour** (from the Tenses deck), shown as a header band and on the particle slides: past amber, present blue, future green, conditional pink, past habitual violet.
6. **Irish headings, English help**: Sprioc, Patrún, Riail, Tábla, Cuimhnigh, Cleachtadh, Dúshlán, Críoch. Rules stay in English, hidden by the existing toggle. Year 8 routine decks default to English off.
7. **Replace fly-in animation with tap states**, which export and project cleanly.
8. **Terms**: fréamh (the command form), séimhiú (add h), urú, leathan/caol, Grúpa 1/2/3. Never "infinitive" or "aspirate".
9. Ulster rulings apply to all examples: druid, cluin, tábla, "muid" analytic; the conditional shows both forms for muid and siad.

**Slide types** (new ones marked with ★). Mark changes inside strings with simple markers, e.g. `C[h]uir`, `{An} [g]cuir[eann]`, `~aigh~`, so the renderer can colour them.

| Type | Content (lesson field) | Rendering |
|---|---|---|
| title | section | Title, with a tense colour band |
| ★ sprioc | `sprioc` (1 to 3 "Beidh mé in ann..." lines), optional `keywords` [{ga, en}] | "Sprioc" plus a Focail thábhachtacha box (like the 2012 Key Words box) |
| contents | existing | existing |
| pattern | `models` (3 to 6) | "Cad é atá cosúil eatarthu?"; changed letters coloured; the rule appears on tap |
| lrule | existing `rule`, `steps` | Keep, but show the steps one tap at a time |
| ★ build | `build`: {root, particle?, add?, ending?, pron} | Tap 1: root. Tap 2: particle (green). Tap 3: h or eclipsis with a caret (red). Tap 4: ending (red), with removed letters struck. Tap 5: pronoun. |
| ★ table | `table`: {cols:["Leathan","Caol"], rows:[["mé","Glan[aim]","Cuir[im]"],...]} | Up to 7 rows; conditional rows for muid/siad show "c[h]uir[feadh] muid · c[h]uir[fimis]" |
| ★ grid | `grid`: 2x2, rows Leathan/Caol, columns Grúpa 1 / Grúpa 2 (or 1 siolla / 2 shiolla) | Ending plus a model verb per cell |
| ★ fork | `fork`: {q, yes, no} | Question on top, arrows to the positive and negative answers |
| ★ family | shared data | "Níor · Ar · Gur · Nár + h (the regular past)" against "Ní + h · An · Go · Nach + urú (everything else)" |
| ★ cuimhnigh | `mnemonic`: {text, keys} | The phrase with key letters coloured, plus two examples |
| item | existing | Worked example (Sampla) or practice (Cleachtadh), with **letter-level highlighting** |
| ★ sort | `sort`: {bins, tiles} | Tap a tile, then a bin; reveal shows ✔/✘. Bins such as séimhiú / no séimhiú, Leathan / Caol, Níor group / Ní group |
| ★ dushlan | 10 mixed items drawn from all lessons | Quick-fire: prompt such as "(ól) inné", tap to reveal, optional timer |
| ★ picture (Year 8) | image or emoji, sentence, chunk | Picture → sentence → target chunk in red (the Dialann Keynote pattern) |
| end | `sprioc` again | "Anois is féidir liom...": the aim turned into a checklist |

**Deck order for one section:**
1. title → sprioc → contents
2. For each lesson: (pattern) → lrule → build → table or grid → (fork) → (cuimhnigh) → Sampla → 3 Cleachtadh → (sort)
3. At the end of the section: dúshlán → end

**Lesson sequence inside a tense section** (e.g. `r1-chaite`):
1. Positive form
2. Exceptions: no séimhiú, d', f (memory aid and sort)
3. Question and negative (fork)
4. Answering (tú → mé, sibh → muid)
5. In context (the routine)
6. In clauses (link to `clasail`)
7. Autonomous form (AS)

**Item difficulty ladder** within a lesson: recognise → form (stem) → transform (question / positive / negative) → gap in a routine passage → English to Irish (the Réamhfhocal and Coibhneasta pattern) → free.

**Engineering:**
- **(a)** Replace `hl()` with a character-level comparison between prompt and answer. The simplest version finds the verb token and marks letters not in the root. Also accept the explicit `[ ]`/`{ }`/`~ ~` markers.
- **(b)** Extend `gSlides` to emit the new types only when a lesson has the optional field, so no existing lesson breaks.
- **(c)** Add colour tokens for the tenses and for `--chg` / `--part` in both themes.

### 4b. Specific changes to existing lessons

| File, lesson | Change |
|---|---|
| `clasail.json`, "Na briathra neamhrialta san aimsir chaite" | Move abair into the go/nach list: "Deir sé go ndúirt sé an fhírinne", with `alt` "gur dhúirt". Rule text: "Tar, tabhair, beir, cluin and ith take gur/nár." Add a note that "Níor dhúirt / gur dhúirt" is also heard in Ulster. |
| `nr-chaite.json`, "Ní: déan, feic, abair, téigh, faigh, bí" | Add `alt` "Níor dhúirt" to the abair items; hint memory aid (4c) |
| `nr-chaite.json`, "Níor: beir, cluin, tar, ith, tabhair" | Hint: "I Tried To Be Clever: ith, tar, tabhair, beir, cluin take Níor and Ar." Add a sort slide: Níor group against Ní group. |
| `r1-chaite.json`, "Séimhiú san aimsir chaite" | Hint: the b c d f g m p s t memory aid (4c); add a `table` and a `build` (glan → ghlan). Fix "úrlár" → "urlár" (2 places in this file). |
| `r1-chaite.json`, "Briathra nach nglacann séimhiú" | Add **sm** (e.g. "Smaoinigh mé ar an cheist"). Hint: "he likes noodles and rice; scallions smell spicy in stew". Add a ✔/✘ `sort` using druid, glan, tóg, cuir, las, rith, nigh, scuab, scríobh, ól, fág. |
| `r1-chaite.json`, "D' roimh ghuta agus roimh f" | Add the name rhymes as a `cuimhnigh`: "D'fhan Dan. D'imigh Jimmy. Phill Phil." (pill is the Ulster "return") |
| `r1-chaite.json` / `r2-chaite.json`, "Ceist le Ar, diúltach le Níor" / "Ar agus Níor in abairt" | Add `fork`: "Ar ól tú an bainne? / D'ól mé. / Níor ól mé." Add the `family` slide. |
| `r1-laithreach.json`, "-ann agus -eann" | Add a `table` (Leathan: glan / Caol: cuir; glanann muid and cuireann muid, analytic) and a `grid` (glan, cuir, ceannaigh, bailigh) |
| `r1-laithreach.json`, "Ceist le An, diúltach le Ní"; `nr-laithreach.json`, "An fhoirm cheisteach: An + urú"; `r2-laithreach.json`, "Ceist le An..." | Hint: "Many Boys Go Camping Near Ditches BeHind Fences, Nice Girls Back Pack Down Town." Keep the vowel rule clearly visible: **An + vowel: no change** (the Rafferty deck got this wrong). |
| `r1-coinniollach.json`, "Séimhiú agus -fadh / -feadh"; `r2-coinniollach.json`, "Briathra in -aigh: -ódh" | New first step: "Start from the future: cuirfidh → c[h]uir[feadh]; ceannóidh → c[h]eann[ódh]." Table rows for muid/siad: "chuirfeadh muid · chuirfimis", "chuirfeadh siad · chuirfidís". |
| `reamhfhocail-simpli.json`, "Réamhfhocal + an: séimhiú in Ulaidh" | Add translation items adapted and corrected from the deck: "Tá an madadh faoin chrann." "Tá mo dheirfiúr leis an fhoireann eile." "Léim an fear roimh an charr." "Chuaigh muid abhaile roimh a naoi." |
| `uimhreacha.json`, "An t-am" | Make **"i ndiaidh a"** the primary form (to match Year 8 and the decks), with "tar éis a" as `alt` |
| `ceisteanna.json` | New lesson "Cá huair, Cá fhad, Cá mhinice": "Cá huair a thosaíonn an rang?" "Cá fhad a bhí tú sa Ghaeltacht?" "Cá mhinice a imríonn tú peil?" (direct relative, a + h) |
| `grammar.json` | Keep the legacy tables and rules hidden, or clean them (dún → druid, clois → cluin, bord → tábla, remove the -amar models) before any table slide reads them |

**New lessons and sections:**

1. **Grúpa 3 lessons** in `r2-laithreach`, `r2-fhaistineach` and `r2-coinniollach`. Appendix A asked for these; this adds Rafferty's framing. Rule: two-syllable verbs ending (a)il, (a)in, (a)ir, (a)is drop the last vowel, then take the Grúpa 2 ending.
   - Present: imrím, imríonn muid, osclaíonn sí, labhraím, codlaíonn sé, insím, músclaím.
   - Future: imreoidh, osclóidh, labhróidh, inseoidh.
   - Conditional: d'imreodh muid / d'imreoimis.
2. **"Comhréir na n-aimsirí"** (cross-tense revision, AS; from the Tenses deck). One verb per slide, one tense-coloured card per tense, five lines each. For example, tóg:
   - Past: Thóg mé é. Níor thóg mé é. Ar thóg tú é? Deir sé gur thóg sé é. Deir sé nár thóg sé é.
   - Present: Tógaim é. Ní thógaim é. An dtógann tú é? ...go dtógann... / ...nach dtógann...
   - Future: Tógfaidh mé é. Ní thógfaidh... An dtógfaidh tú é? ...go dtógfaidh...
   - Conditional: Thógfainn é. Ní thógfainn é. An dtógfá é? Dúirt sé go dtógfadh sé é.
   - Past habitual: Thóginn é. Ní thóginn é. An dtógtá é? Dúirt sé go dtógadh sé é.
   - Repeat for ól (vowel: d'ól, d'ólfadh) and fág (d'fhág, An bhfágfaidh, go bhfágfadh).
3. **Imperative section** (appendix A item 2). Add the picture command slides from Briathra na Gaeilge: "Siúil! Rith! Druid an doras. Cuir an peann ar an tábla. Caith an liathróid chugam."
   - Present it as "the root is the command", replacing "infinitive".
4. **Relative clause section** (appendix B item 2). Add the corrected summary grid (Direct: a + h in both families; Indirect: ar + h in the regular past, a + urú elsewhere), a DAFDA `cuimhnigh` ("an áit a bhfuil mé i mo chónaí", "an fáth ar fhág sé") and an Ulster note on "a bheas".
   - Relabel "Group 1/2" as the Níor family and the Ní family.

### 4c. Memory aids to adopt (neutral wording)

| Point | Wording | Source |
|---|---|---|
| Letters that take séimhiú: b c d f g m p s t | "Busy Cooks Don't Fry Green Mushrooms, Peppers, Sausages, Tomatoes" (replaces the celebrity version; keeps the food theme of the next two) | Adapted from the 2012 deck |
| No séimhiú: h l n r | "he likes noodles and rice" | 2012 |
| No séimhiú: sc sm sp st | "scallions smell spicy in stew" | 2012 |
| Eclipsis | "Many Boys Go Camping Near Ditches BeHind Fences, Nice Girls Back Pack Down Town" (mb, gc, nd, bhf, ng, bp, dt) | Urú deck ("Nice", not "No") |
| d' and f | "D'fhan Dan. D'imigh Jimmy. Phill Phil." | Briathra na Gaeilge |
| Past irregulars with Níor/Ar | "I Tried To Be Clever": ith, tar, tabhair, beir, cluin | New (follows the 2012 split of 5 and 6) |
| Past irregulars with Ní/An | "Big Dogs Always Take Fresh Food": bí, déan, abair, téigh, feic, faigh | New |
| Particle families | "The past ends in r": níoR, aR, guR, náR (+ h) for the regular past; Ní, An, Go, Nach for everything else | Tenses and Coibhneasta, reworded |
| Conditional | "Future first, then h" | Modh Coinníollach |
| Indirect relative after nouns used as adverbs | DAFDA: áit, fáth, dóigh, am | Coibhneasta |
| Grúpa 3 | "-il, -in, -ir, -is: lose the vowel, then act like Grúpa 2" | Rafferty, reworded |
| Symbols | An = ? · Ní = ✘ · go = "that" · nach = "that... not" | Present Tense Endings |

### 4d. Year 8 routine builders: "one day, three tenses"

The present builder `b7-la` ("Mo lá") has only 4 rows. The decks give the full day in three tenses with the same actions and pictures.

- **Phase 1** (works with the current unit format: rows, columns of tiles, sentences, audio): expand `b7-la` and add two sibling units.
- **Phase 2**: one builder with a tense switch ("Inné · Gach lá · Amárach") that changes each verb tile in place, with the changed letters in red. This is the decks' own device, done properly.

| Row | Gach lá (b7-la, expand) | Inné (new unit, e.g. b10-inne) | Amárach (new unit, e.g. b11-amarach) |
|---|---|---|---|
| Ar maidin | Músclaím / Éirím / Ním m'aghaidh / Scuabaim m'fhiacla / Cuirim orm mo chuid éadaigh / Ithim mo bhricfeasta / Ólaim cupán tae | Mhúscail mé / D'éirigh mé / Nigh mé m'aghaidh / Scuab mé m'fhiacla / Chuir mé orm mo chuid éadaigh / D'ith mé mo bhricfeasta / D'ól mé cupán tae | Músclóidh mé / Éireoidh mé / Nífidh mé m'aghaidh / Scuabfaidh mé m'fhiacla / Cuirfidh mé orm mo chuid éadaigh / Íosfaidh mé mo bhricfeasta / Ólfaidh mé cupán tae |
| + time column | ar a seacht a chlog / ar cúig i ndiaidh a seacht / ar leath i ndiaidh a seacht | same | same |
| Ar scoil | Téim ar scoil / Bainim an scoil amach ar a naoi a chlog | Chuaigh mé ar scoil / Bhain mé an scoil amach... | Rachaidh mé ar scoil / Bainfidh mé an scoil amach... |
| + mode column | ar an bhus / sa charr / de shiúl na gcos / ar mo rothar | same | same |
| Am lóin | Ithim mo lón sa cheaintín / Imrím peil le mo chairde | D'ith mé mo lón... / D'imir mé peil... | Íosfaidh mé mo lón... / Imreoidh mé peil... |
| Tráthnóna | Fágaim an scoil / Tagaim abhaile / Déanaim m'obair bhaile / Amharcaim ar an teilifís | D'fhág mé an scoil / Tháinig mé abhaile / Rinne mé m'obair bhaile / D'amharc mé ar an teilifís | Fágfaidh mé an scoil / Tiocfaidh mé abhaile / Déanfaidh mé m'obair bhaile / Amharcfaidh mé ar an teilifís |
| Istoíche | Téim a luí ar a deich a chlog / Titim i mo chodladh | Chuaigh mé a luí... / Thit mé i mo chodladh | Rachaidh mé a luí... / Titfidh mé i mo chodladh |
| Connectives | Ar dtús, Ansin, Ina dhiaidh sin, Ar deireadh | same | same |

**Unit questions** (the triplets, as in the McNamee decks):
- Present: "Cad é a dhéanann tú gach maidin?" "An dtéann tú ar scoil ar an bhus? Téim. / Ní théim."
- Past: "Cad é a rinne tú inné?" "Ar ith tú do bhricfeasta? D'ith mé. / Níor ith mé." "An ndearna tú d'obair bhaile? Rinne mé. / Ní dhearna mé."
- Future: "Cad é a dhéanfaidh tú amárach?" "An rachaidh tú ar scoil ar an bhus? Rachaidh. / Ní rachaidh."
- Group stretch: "D'imir muid peil", "Imríonn muid peil", "Imreoidh muid peil" (analytic).

**Class slides for these units:** the `picture` type (picture → sentence → red chunk), then a "Dialann" writing frame: "Dé Luain: Ar dtús mhúscail mé ar a seacht a chlog. Ansin..." Use emoji or clean line icons, not 2002 clip art (the smoking picture in "gach lá" must go).

### 4e. Ranked recommendations (value against effort)

| Rank | Action | Value | Effort |
|---|---|---|---|
| 1 | Fix the app problems: clasail/nr-chaite abair; "urlár"; add sm; "i ndiaidh" in `uimhreacha` | High (correctness) | Very low |
| 2 | Letter-level highlighting in `hl()` plus the red/green/strike colour tokens | High (the core of his style) | Low |
| 3 | Memory aids as `hint`s plus `cuimhnigh` slides (4c) | Medium to high | Very low |
| 4 | `fork`, `sprioc` and `end` slide types in `gSlides` | High | Low |
| 5 | Year 8 "one day, three tenses": expand `b7-la`, add Inné and Amárach units | High | Medium (audio) |
| 6 | `table` and `grid` slide types with **new** clean data (not the legacy `grammar.json`) | High | Medium |
| 7 | Grúpa 3 lessons in the r2 present, future and conditional sections | High | Medium |
| 8 | `family` slide plus a "Comhréir na n-aimsirí" revision section | High (AS) | Medium |
| 9 | Tense colour bands | Medium | Low |
| 10 | `dushlan` quick-fire round at the end of each section | Medium | Low |
| 11 | `sort` item shape (✔/✘ séimhiú; broad/slender; Níor/Ní group) | Medium | Medium (new interaction) |
| 12 | `build` tap-state slide replacing the animations | Medium | Medium |
| 13 | Imperative section with picture commands; relative-clause section with DAFDA | High | Medium (partly in appendices A and B already) |
| 14 | Year 8 `picture` slide type; Phase 2 tense switch on the routine builder | Medium to high | Medium to high |

**Keep out of the app:** the Rafferty question examples ("An n-..."), the Coibhneasta "Ní + urú" row, the Modh irregular table, every "Clois", the "dún" in Briathra and the .doc, and any legacy `grammar.json` table until it is cleaned. Reuse colleagues' decks as ideas with fresh, corrected Ulster examples; authorship and credit are the teacher's call.

**Files referenced:**
- Decks and sheets: `/tmp/claude-0/-home-user-get-iplayer-automator-master/ccdd5904-a3e0-5217-a79e-cb30cb56d957/scratchpad/sheets/*.png|txt` and `.../ppt/`
- App lessons: `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/lessons/` (clasail.json, nr-chaite.json, r1-chaite.json, uimhreacha.json, and the others)
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/grammar.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/units.json` (b7-la)
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/index.src.html` (`hl()` at line 510; `gSlides` and `gdeckHTML` at lines 580 to 610)