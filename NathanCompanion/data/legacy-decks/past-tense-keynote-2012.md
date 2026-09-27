# "An Aimsir Chaite 2012" (Keynote): review against Gan Ainm

## Summary

I read the deck in full. Its 61 slides give the past tense in this order: the root, then which letters take h, then d' and d'fh, then Níor, then Ar, then positive, negative and question side by side, then the 11 irregular verbs, then pronouns, then building sentences. The ten slides with no extracted text are tables in `index.apxl`, and I recovered all of them. The main one is a 30-verb Ulster list sorted by whether each verb takes h, with a tick or cross answer key.

The Irish is mostly sound and mostly Ulster: druid, amharc, múscail, muid, and no -amar. Problems:
- **One ruling breach:** "Clois" (slide 31).
- **Misleading term:** it calls the root the "infinitive" throughout.
- **Small errors:** "Cogar" (should be cogair), "t-úrlár" (should be t-urlár), "We drunk".
- **Teaching weaknesses:** there is almost no pupil practice, no plenary, and pronouns are taught last.

The app's lessons already do the rules better. They use cluin, "root" and séimhiú, they teach how to answer a question, the autonomous form and -aigh/-igh verbs, and they practise in real sentences. The deck's real value is:
1. A ready-made **"An lá inné" Year 8 builder** (rows proposed below).
2. A **verb first, then the person** layout in coloured columns, which the builder format reproduces automatically.
3. **Tighter séimhiú rules** for r1-chaite and r2-chaite: sm is missing from the past-tense rules, and "s + vowel, l, n, r takes h" is never said.
4. A **"does it take h?" sorting activity**.
5. A **one verb of each type** table for rith.

Along the way I found two problems already in the app: "úrlár" is misspelt in the app's own lessons, and `render.py` cannot render b9.

---

## 1. The deck's structure and teaching sequence

The deck was made in Keynote 2009, saved in 2012, and uses the Scrapbook theme. There are no speaker notes. The flower photos are theme backgrounds. Slides 44 to 50 use line drawings from an Italian pronoun set (`pronomeIo.gif` and so on). These are third-party, so do not reuse them.

| Slides | Phase | Content |
|---|---|---|
| 1 | Title | "An Aimsir Chaite / The Past Tense" |
| 2 | **Sprioc** (learning intentions) | Only two: recognise the "infinitive"; know when a verb can be aspirated |
| 3 | Rule and **Key Words** | Two steps: take the "infinitive", then decide whether it can be aspirated. Glossary: "Infinitive: you use it when you're giving an order"; "Aspirate: insert h after the first letter" |
| 4 to 6 | Verb list | Three tables of 10 verbs with English (below) |
| 7 | Rule and **mnemonics** | Takes h: b c d f g m p s\* t, with the mnemonic "*Britney caught dopey friends going mad publicly, silly twits*". Does not: vowels; h, l, n, r ("*he likes noodles and rice*"); sc, sm, sp, st ("*scallions smell spicy in stew*"). The asterisk on s is never explained |
| 8 to 10 | **Practice: sorting activity** | "Can we aspirate the following infinitives?" The same three lists with a tick-or-cross answer column |
| 11 to 13 | Vowel verbs | Rule "prefix d'", with Key Word "Prefix". Table: Amharc, Éist (le), Éirigh, Ith, Ól, Ullmhaigh, with d'… mé forms |
| 14 to 16 | f verbs | "Aspirate, then prefix d'". Table: Fan, Fág, Foghlaim, Folmhaigh |
| 17 to 19 | Negative | "An fhoirm dhiúltach": Níor, and drop the d'. Table: Níor cheannaigh / bhris / ith / fhoghlaim mé |
| 20 to 22 | Question | "An fhoirm cheisteach": Ar, and drop the d'. Table: Ar cheannaigh / bhris / ith / fhoghlaim tú? |
| 23 to 28 | **Three forms side by side** | "Every verb has a positive, a negative and a question form". One verb of each type: Ceannaigh (takes h), Rith (no change), Ól (vowel), Fan (f) |
| 29 to 30 | Irregular verbs | "There are 11 irregular verbs… must be learned individually" |
| 31 to 35 | Irregulars 1 to 5 (Níor/Ar) | Clois, Beir, Tabhair, Tar, Ith, each with question, positive and negative |
| 36 to 41 | Irregulars 6 to 11 (Ní/An) | A **"Notice"** slide marks the change at number 6 (Téigh). Then Feic, Faigh, Déan, Abair, Bí |
| 42 to 50 | Personal pronouns | English puts the pronoun before the verb; Irish puts it after. Seven pronouns, one per slide with a picture: mé, tú, sé, sí, muid, sibh, siad |
| 51 to 60 | Making a sentence | Coloured frame **Verb / Pronoun / Article / Noun**: Thóg mé an peann; Scuab mé an t-úrlár; Cheannaigh mé na milseáin. Then "Verb\*" marks the irregular verbs: Bhí mé ag an leithreas; Chonaic mé an sneachta; Rinne mé an bricfeasta; Chuaigh mé ar Aifreann; Dúirt mé an phaidir; Fuair mé an nóta |
| 61 | (blank) | No plenary |

**Verb lists recovered from the slide tables:**
- **Slide 4:** Tosaigh, Críochnaigh, Ceannaigh, Glan, Druid, Tóg, Múscail, Cuir, Suigh (síos), Seas (suas). All ten are ticked on slide 8.
- **Slide 5:** Nigh, Scuab, Rith, Las, Scríobh, Éirigh, Éist (le), Ól, Ith, Amharc (ar). All ten are crossed on slide 9.
- **Slide 6:** Oscail, Imir, Fág, Fan, Léigh, Siúil, Labhair, Léim, Cogar, Foghlaim. These are mixed on slide 10; the ticks are Fág, Fan, Siúil, Cogar and Foghlaim.

The answer keys are all correct.

**Overall shape:** it presents a rule, then a model, then more rules. The only pupil tasks are slides 8 to 10 and the sentence frames on 52 to 60. There are no success criteria, no plenary, no time words (inné, aréir) and no plural examples, even though muid appears on slide 48.

## 2. Problems found

| Slide | Issue | Type | Fix |
|---|---|---|---|
| 31 | "Clois" | **Ruling breach** | **Cluin**: Chuala mé / Níor chuala mé / Ar chuala tú? |
| 2 to 22 | "Infinitive" means the root or command form (2nd singular imperative). The nearest Irish equivalent to an infinitive is the verbal noun (a ghlanadh). This will confuse pupils when they later meet "a + verbal noun" | Misleading term | "root (the command form)". The app already says "root" |
| 3, 7, 8 | "Aspirate" | Term | Keep it as an English gloss, but lead with **séimhiú**, as the app does |
| 7 | "s\*" is never explained. The "No" list suggests only sc, sm, sp, st resist h, but never says that s + vowel, l, n or r takes h (Sheas, Shiúil, Shnámh, Shleamhnaigh) | Incomplete | State it and give examples |
| 7 | The mnemonic names a real celebrity and ends "silly twits". The earlier review recorded the same mnemonic as "Barbie…" | Tone, for use in an app | Keep the letters but use neutral words, e.g. "*Brave cats dance for grannies, making pancakes so tasty*" (b c d f g m p s t). The teacher decides |
| 8 to 10 | The lists are grouped so that slide 8 is all ticks and slide 9 is all crosses. Pupils can guess the pattern without applying the rule | Activity design | Shuffle the 30 verbs |
| 6 | "Cogar: to whisper". Cogar is the noun (and the interjection "Cogar!"); the verb is **cogair** (past: chogair) | Error | Cogair |
| 53 | "an t-úrlár" | Spelling | **an t-urlár** (the app has the same slip; see section 5) |
| 42 | "We drunk" | English | We drank |
| 13 | "Éist (le): to listen" is missing "(to)", unlike slide 5 | Slip | to listen (to) |
| 52 to 60 | The "Article" column holds "ag an" and "ar" (prepositions); "ar Aifreann" has no article | Misleading label | Columns: Briathar / Duine / An chuid eile |
| 58 | "Chuaigh mé ar Aifreann" is acceptable Ulster Irish, but builder b9 uses "chuig an Aifreann" | Consistency | Use one form across the app |
| 18, 21 | "Remove the d'" does not say that the h on f stays (Níor fhan). Slide 28 shows it, but no rule states it | Incomplete | r2-chaite already states it |
| 2, 61 | Two learning intentions for a deck of four or more lessons; no plenary | Planning | See 4.4 |
| 4 | Tosaigh: fine. Ulster speech also has toisigh (thoisigh) | Note only | No change |

Everything else is compliant: druid (never dún), muid (never -amar), Ulster amharc and múscail, correct irregular forms, and correct use of Ní versus Níor.

## 3. Comparison

### 3a. What the deck adds beyond Appendix A (sections 4 and 5)

The appendix already covers the mnemonics (its item 6), the Group A/B split of the irregulars (item 8), the "An lá inné" idea (item 4 and 4d), the Clois breach and the "Infinitives" misnomer. It also already noted that r1-chaite lacks sm. The deck's new contributions are:

1. **A sorting activity** ("does it take h?"), with a 30-verb Ulster answer key. Classifying comes before producing forms. None of the exercise types in the appendix's section 4c is a sort.
2. **The verb-first frame in coloured columns** (Verb / Pronoun / …), plus the explicit contrast "English: pronoun before; Irish: pronoun after". The builder already colours each column in turn (`k%4` in `render.py`), so separate verb and person columns reproduce the frame without new code.
3. **One verb of each type** shown in all three forms: Ceannaigh, Rith, Ól, Fan. The app's r1-chaite tables have no table for a verb that does not change.
4. **The s + vowel/l/n/r point** (the unexplained "s\*"), and that **sm is also missing from r2-chaite**, which matters because smaoinigh is a common 2nd-conjugation verb.
5. **The numbered 1 to 11 irregular sequence with a "Notice" slide at number 6.** This makes the Group A/B split visible. It is a small addition to the appendix's item 8.
6. **A per-rule Key Words glossary format** (Sprioc, Key Words), which is useful as a teacher slide template.

### 3b. Where the deck is new or better than the app

- **Rule order:** séimhiú, then the letters that resist it, then d' and d'fh, then Níor, then Ar, then answering. In r1-chaite, "Ceist a fhreagairt" comes 2nd, before Ar is taught in lesson 5. "Briathra nach nglacann séimhiú" comes 3rd, not straight after the séimhiú lesson.
- **The first rule is more precise:** the deck lists b c d f g m p s t. The first r1-chaite lesson says "a verb that begins with a consonant takes séimhiú", which is too broad (it would include l, n, r).
- **Letters that resist h:** the deck includes sm and h. r1-chaite and r2-chaite list "l, n, r, sc, sp or st"; r1-laithreach already includes sm.
- **Pronouns and word order** are taught explicitly. The Year 8 builders are all first person and never teach the verb-first order.
- The **Ulster verb list** (Druid, Amharc (ar), Múscail, Éist (le), Suigh (síos)) shows the preposition beside the verb.

### 3c. What the app already does better

- Cluin; "root"; séimhiú; rules named in Irish.
- Rules the deck lacks: Níor keeps the h on f (r2-chaite); answering questions (tú to mé, do to mo, ort to orm); the sibh/muid switch; the autonomous form in every group; -aigh/-igh verbs.
- Practice sentences set in pupils' lives (GAA, school, phones), in several item formats. The deck has bare "mé" forms.
- nr-chaite already splits the irregulars into Níor/Ar and Ní/An, with hint lists.

## 4. Recommendations, ranked by value against effort

| Rank | What | Where | Value | Effort |
|---|---|---|---|---|
| 1 | Tighten the séimhiú rules: list b c d f g m p s t; add sm; add "s + vowel, l, n, r takes h"; add two trap items | r1-chaite lessons 1 and 3; r2-chaite lesson 1 | High | Very low (text) |
| 2 | Fix "úrlár" to "urlár" | r1-chaite "Briathra nach nglacann séimhiú" `more[0]`; `beta/data/grammar.json` (4 occurrences) | Medium | Very low |
| 3 | Year 8 builder **b10 "An lá inné"** (4.2) | `builders/year8.json`, `beta/data/units.json` (with audio and question-to-row mapping), `ios/.../units.json`, `render.py` `BE` | High | Low to medium (mostly audio) |
| 4 | Add a table "F. Ceist: Ar rith tú? (rith, gan séimhiú)" | r1-chaite `tables` | Medium | Very low |
| 5 | Add a first step "the root is the command form" | r1-chaite "Séimhiú san aimsir chaite" | Medium: links to the missing imperative section (appendix rank 2) | Very low |
| 6 | Reorder r1-chaite to: Séimhiú, Briathra nach nglacann séimhiú, D' roimh ghuta…, Ceist le Ar…, Ceist a fhreagairt, then the autonomous lessons | r1-chaite | Medium | Low. `links.json` points only to r1-chaite lesson 1, which does not move |
| 7 | Add a step to the first Ní lesson: "Notice: from verb 6 onward it is Ní and An, not Níor and Ar" | nr-chaite "Ní: déan, feic, abair, téigh, faigh, bí" | Low to medium | Very low |
| 8 | A "sort" item type ("An féidir séimhiú a chur air?"), seeded with the 30 verbs shuffled | New item type | Medium to high for weaker pupils | Medium (app code) |
| 9 | Corrected teacher slide sequence (4.4) | Classroom | High for the teacher | Medium |

### 4.1 Proposed wording for the lessons

**r1-chaite, "Séimhiú san aimsir chaite"**
- Rule: "In the past tense, a verb that begins with b, c, d, f, g, m, p, s or t takes séimhiú: add h after the first letter (glan becomes ghlan). With muid, just put muid after the lenited verb: bhuail muid."
- New first step: "The root is the command form, the word you use to give an order: Glan an tábla!"
- Hint: "b c d f g m p s t take h (Brave cats dance for grannies, making pancakes so tasty)."

**r1-chaite, "Briathra nach nglacann séimhiú"**
- Rule: "A verb beginning with l, n, r, sc, sm, sp or st cannot take séimhiú… But s followed by a vowel, l, n or r does: sheas, shiúil, shnámh."
- Hint: "l, n, r (likes noodles and rice); sc, sm, sp, st (scallions smell spicy in stew): no h."
- New trap items:
  - `(Snámh) muid sa linn snámha inné.` → `Shnámh muid sa linn snámha inné.`
  - `(Seas) an rang nuair a tháinig an príomhoide isteach.` → `Sheas an rang nuair a tháinig an príomhoide isteach.`

**r2-chaite, "Séimhiú: -aigh agus -igh"**
- Rule ending: "…l, n, r, sc, sm, sp or st does not change: réitigh sí, smaoinigh sí."
- New item: `(Smaoinigh) sí ar an cheist ar feadh tamaill.` → `Smaoinigh sí ar an cheist ar feadh tamaill.`

**r1-chaite, new table F:** Ar rith tú? Rith mé / Níor rith mé; the same for sé, sí, sibh (answer muid), siad; Ar ritheadh? Ritheadh / Níor ritheadh.

### 4.2 Year 8 builder b10 "An lá inné" (Yesterday)

- **Teaches:** past tense with mé and muid; séimhiú (mhúscail, chuaigh); d' before a vowel or f (d'éirigh, d'fhág); verbs that do not change (léigh, scríobh, labhair); Níor and Ní; the verb first, then the person. It reuses the times from b7, so it follows "Mo lá" directly.
- **Questions:**
  - Cad é an t-am ar éirigh tú inné? (row 1)
  - Cad é mar a chuaigh tú ar scoil inné? (row 2)
  - Cad é a rinne tú ar scoil inné? (row 3)
  - Cad é a rinne tú aréir? (rows 4 to 6)
  - Cad é a rinne tú ag an deireadh seachtaine seo caite? (row 7)

| Row (label) | Column 1 | Column 2 | Column 3 | Column 4 |
|---|---|---|---|---|
| 1. Ar maidin | Mhúscail mé (I woke up) / D'éirigh mé (I got up) / D'ith mé mo bhricfeasta (I ate my breakfast) / D'fhág mé an teach (I left the house) | ar a seacht a chlog (at seven o'clock) / ar leath i ndiaidh a seacht (at half past seven) / ar a hocht a chlog (at eight o'clock) | | |
| 2. Ar scoil | Chuaigh mé ar scoil (I went to school) / Tháinig mé abhaile (I came home) | ar an bhus (on the bus) / sa charr (in the car) / de shiúl na gcos (on foot) / ar mo rothar (on my bike) | | |
| 3. Sa rang | Léigh mé scéal (I read a story) / Scríobh mé dán (I wrote a poem) / Labhair mé Gaeilge (I spoke Irish) / D'éist mé le ceol (I listened to music) / Chan mé amhrán (I sang a song) / D'imir mé peil (I played football) | sa rang (in class) / le mo chara (with my friend) / ag am lóin (at lunchtime) | | |
| 4. Tráthnóna | Rinne mé m'obair bhaile (I did my homework) / D'amharc mé ar an teilifís (I watched TV) / Chuidigh mé le mo mhamaí (I helped my mum) / D'imir mé cluichí ríomhaire (I played computer games) | ar a cúig a chlog (at five o'clock) / ar a sé a chlog (at six o'clock) / ar a seacht a chlog (at seven o'clock) | | |
| 5. Istoíche | Chuaigh mé a luí (I went to bed) | ar a naoi a chlog (at nine o'clock) / ar leath i ndiaidh a naoi (at half past nine) / ar a deich a chlog (at ten o'clock) | | |
| 6. Níor agus Ní | Níor ith mé mo bhricfeasta (I didn't eat my breakfast) / Níor imir mé peil (I didn't play football) / Ní dhearna mé m'obair bhaile (I didn't do my homework) / Ní dheachaigh mé amach (I didn't go out) / Ní fhaca mé mo chairde (I didn't see my friends) | mar bhí mé tuirseach (because I was tired) / mar bhí mé tinn (because I was sick) / mar ní raibh am agam (because I didn't have time) | | |
| 7. An deireadh seachtaine seo caite (the deck's verb-first frame: each column is coloured differently) | **Briathar:** Chuaigh (went) | **Duine:** mé (I) / muid (we) / mo dheartháir (my brother) / mo dheirfiúr (my sister) / mo chairde (my friends) | **Áit:** chuig an phictiúrlann (to the cinema) / chuig an trá (to the beach) / chuig an Aifreann (to Mass) / chuig cluiche peile (to a football match) | **Lá:** Dé Sathairn (on Saturday) / Dé Domhnaigh (on Sunday) |

Examples:
- D'éirigh mé ar a seacht a chlog.
- Chuaigh mé ar scoil ar an bhus.
- Labhair mé Gaeilge le mo chara ag am lóin.
- Ní dhearna mé m'obair bhaile mar bhí mé tuirseach.
- Chuaigh muid chuig an trá Dé Sathairn.

Row 3 mixes verb types on purpose: Léigh, Scríobh and Labhair do not change, D'éist and D'imir take d', and Chan takes h. It works as a spoken version of the sorting activity.

### 4.3 Carry-over for the app from the deck

- Offer the 30-verb list (with Cogar corrected to Cogair) as the seed list for the sort item type.
- Use Ceannaigh, Rith, Ól and Fan as the one-of-each-type set in any future summary card.

### 4.4 Corrected teacher slide sequence (Year 8, four lessons)

1. **Lesson 1: the root and séimhiú.**
   - Sprioc and success criteria.
   - Pronouns and word order: the verb first, then the person (move slides 42 to 50 here).
   - "The root is the command form": Glan an tábla! Druid an doras!
   - The letters that take h, with a neutral mnemonic, and the letters that do not.
   - The **shuffled** 30-verb sort, done on mini whiteboards.
   - Exit ticket: five verbs.
2. **Lesson 2: d', Níor, Ar.**
   - d' before a vowel, d'fh before f.
   - The one-of-each-type slides (Ceannaigh, Rith, Ól, Fan).
   - Níor (the h on f stays), then Ar.
   - Answering: "Ar ól tú?" "D'ól mé." Time words: inné, aréir.
   - Plenary: pairs ask each other "Ar … tú inné?"
3. **Lesson 3: the irregular verbs.**
   - Numbers 1 to 5, with **cluin**.
   - The "Notice" slide.
   - Numbers 6 to 11.
   - The irregular-verb poem (appendix item 4d) as a gap-fill.
   - Quiz plenary.
4. **Lesson 4: An lá inné.**
   - Sentence frames labelled Briathar / Duine / An chuid eile, with urlár corrected.
   - Builder b10: write five sentences about yesterday, including one with Níor or Ní and one with muid.
   - Plenary: say three sentences aloud.

## 5. Problems found in the app along the way

- **"úrlár" is misspelt in the app** (it should be urlár):
  - `beta/data/lessons/r1-chaite.json`, lines 123 to 124 ("Scuab Gráinne úrlár an halla spóirt")
  - `beta/data/grammar.json`, including "Scuab sé an t-úrlár"
  - `r1-laithreach.json` already spells it correctly (t-urlár).
- **`builders/render.py` has no entry for b9:** its `BE` dictionary stops at `b8-guthan`, so rerunning it would fail on `b9-laethanta`. The current `year8.html` has no b9. A b10 would also need an entry.

Source files, all read-only (nothing was edited):
- `/tmp/claude-0/-home-user-get-iplayer-automator-master/ccdd5904-a3e0-5217-a79e-cb30cb56d957/scratchpad/key/An-Aimsir-Chaite-2012/index.apxl` (the tables were parsed from here)
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/lessons/r1-chaite.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/lessons/r2-chaite.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/lessons/nr-chaite.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/builders/year8.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/builders/render.py`
- `/home/user/get-iplayer-automator-master/NathanCompanion/beta/data/units.json`
- `/home/user/get-iplayer-automator-master/NathanCompanion/data/old-grammar-notes/appendix-A-verbs.md`