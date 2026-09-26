# A companion to Nathán: what the CCEA corpus supports

Dáithí Murray, with Claude. 26 September 2026. Proposal only; nothing built yet.

## 1. What the corpus actually is

The PDF is Appendices 2 to 5 of the CCEA GCSE Irish specification (September 2017, Version 2, November 2018), 71 pages:

| Appendix | Content | Size |
|---|---|---|
| 2 | Exam rubrics, Irish and English, all four papers, both tiers | 5 pages |
| 3 | Sample speaking questions for Conversation Topics 1 and 2, by Context for Learning | about 300 questions |
| 4 | Grammar and structures checklist, Foundation and Higher | 3 pages |
| 5 | Core minimum vocabulary list, tagged by Context, topic and sub-topic | about 2,250 entries |

A first automated pass over Appendix 5 (see `tools/extract.py` and `data/corpus_raw.json`; the cleaning workbook is `Nathán companion - corpus.xlsx`) gives:

| Measure | Count |
|---|---|
| Entries | 2,247 |
| Marked masculine `[m]` | 811 |
| Verbs with verbal noun `(ag ...)` | 358 |
| Useful constructions (`is maith liom ...`) | 72 |
| Entries broken by the two-column layout | 14 |

The list is Ulster Irish throughout (cad é, cad chuige, cóngarach, tchí), which matches the school.

**Three cautions before anything is built.**

1. **It is a syllabus appendix, not a corpus.** There are no passages, no dialogues, no model answers. Anything that needs continuous prose has to be authored.
2. **The data needs a human cleaning pass.** Feminine gender is marked only by the absence of `[m]`, the tags are inconsistent (`[nm]`, `[fpl]`, `[mpl]`), sub-headings bleed into the next section in the raw parse, and 14 entries lost their English. One evening of work, but it is not optional.
3. **Copyright.** This is CCEA material. Internal use for St Paul's pupils is ordinary practice. Publishing on the App Store with the list inside is a permissions question for CCEA, and should be asked before a store listing is planned.

## 2. Why a scramble was the weakest use of this material

A scramble tests recognition of a spelling. This list carries four things a scramble throws away: the gender mark, the verbal noun, the governing preposition (`buail le`, `braith ar`, `éist le`) and the topic tag. Every direction below uses at least two of those.

## 3. Directions, in the order I would build them

### A. Recall trainer (data-ready, build first)

Spaced repetition over the cleaned list. English shown, Irish typed or spoken back, with lenient matching on fadas at Foundation and strict at Higher. Filter by Context for Learning, topic, or "this week's list". Verb cards demand three things: the root, the verbal noun, and the preposition where there is one. Scheduling on the open FSRS algorithm, stored on device, synced through iCloud so a pupil's iPad and phone agree.

Why first: it needs nothing authored, it is the natural sister to Nathán (recognition there, recall here), and the dataset it produces becomes the shared asset for everything else.

### B. Grammar engine (rule-based, generated from the same data)

Appendix 4 is the checklist of what is examined. Almost all of it can be drilled by rules applied to the nouns and verbs in Appendix 5, with no authoring:

- Article and gender: `an` + `fuinneog` gives `an fhuinneog`; `an` + `am` gives `an t-am`. Generated from the gender mark.
- Preposition plus article, Ulster form: `ar an bhord`, `sa charr`, `leis an mhúinteoir`.
- Possessives: `mo` and `do` lenite, `a` (his, her, their) does three different things, `ár` and `bhur` eclipse.
- Adjective agreement: `fuinneog bhán`, `fuinneoga móra`.
- Regular verb conjugation: present, past, future, imperative for the 358 verbs. First and second conjugation are recognisable from the root shape. The eleven irregular verbs get a hand-written table.
- Counting objects: `dhá mhála`, `seacht bpunt`, personal numbers, ordinals.

Pupil sees `an + fuinneog` and must produce the mutated form. Wrong answers are diagnosed by rule, not marked "incorrect": "you eclipsed after `ar an`; in Ulster Irish it lenites".

Why second: it is the highest marks-per-hour feature for the writing and speaking papers, and it is the one nobody else's app does in the Ulster dialect.

### C. Speaking rehearsal with a personal answer bank (the ambitious one)

Appendix 3 is the actual question bank the teacher-examiner draws from. The speaking paper rewards prepared personal answers, so the app holds, for each pupil, their own answer to each question: family, town, subjects, part-time job. The pupil records the answer, hears it back, and the spaced scheduler brings the weak questions round again. A "cold exam" mode picks questions at random from the chosen topics with a countdown, the way the real conversation runs.

**Hard dependency to face early:** Apple ships no Irish voice and no Irish speech recognition, so there is no free text-to-speech or automatic marking. The realistic route is the Abair project at Trinity College Dublin, which offers synthesis in an Ulster voice through a web API, and is the only Irish speech recognition worth trying. Without it, the feature is record-and-listen with teacher feedback, which is still worth having.

Model answers are the other cost. Roughly 300 questions, each needing a Foundation and a Higher model answer in Ulster Irish, checked by an Irish teacher. Claude can draft; a human signs off.

### D. Sentence scaffolds for the writing paper

Not a scramble. The 72 useful constructions are frames with typed slots: `is maith liom` + [activity as verbal noun phrase], `ba mhaith liom` + [verb phrase], `is dóigh liom go` + [clause]. The pupil fills the slot from the topic vocabulary and the grammar engine applies the consequences (`peil a imirt`, `ag imirt peile`). Output is a growing personal phrasebook the pupil can export before the exam.

### E. Teacher view

One screen per class: who has practised, which topic, accuracy by grammar rule. Sync through CloudKit shared records, or a nightly export to a Microsoft List so it sits beside the rest of Cumarsáid. Not a pupil feature; it is what makes the app a department tool rather than a private habit.

### F. Rubric decoder

Appendix 2 in a flashcard set: `Cuir tic le dhá rud a itheann Seosamh` and what it asks for. Trivial to build, an afternoon, but it removes the single most avoidable way to lose marks on the listening and reading papers. Bolt it onto A.

## 4. What I would leave out

- An in-app dictionary or full lexicon. The list is the syllabus; going beyond it dilutes the point.
- Generated reading passages from a language model without a teacher checking them. The dialect and the exam register are too specific to trust unchecked.
- Any leaderboard across pupils. Spaced repetition and public rankings pull in opposite directions.

## 5. Recommended shape

One app, four modules, one dataset, built in this order: A with F, then B, then D, then C, then E. A and F are a fortnight of work on the cleaned data. B is the differentiator and is pure logic over the same data. C is the ambitious one and is gated by Abair access and model-answer authoring, so it goes later, not because it matters less but because its dependencies are outside the codebase.

Platform: Swift and SwiftUI, iOS and iPadOS, offline first, data shipped as JSON inside the bundle. The Swift source can be written here, but building, signing and running on a device happens in Xcode on the Mac; this cloud container cannot compile for iOS.

## 6. Open questions for Dáithí

1. Is Version 2 (2018) still the live specification, or has CCEA revised the list since? If revised, the cleaning pass should be against the current PDF.
2. Who signs off the Ulster forms in the grammar engine and the model answers? A named Irish teacher, or Dáithí himself.
3. Does the school hold, or want to seek, permission from CCEA to distribute the list inside an app beyond the school?
4. Does Nathán have a class or teacher view already? If not, E is new ground; if so, the companion should reuse it.

## 7. For the Work Register (queued; the register is not mounted in this session)

```python
add_work_entry(
    project="Nathán Companion App",
    task="Read the CCEA GCSE Irish specification appendices (71 pages) supplied as a corpus. Parsed Appendix 5 into structured JSON: 2,247 vocabulary entries, 811 masculine, 358 verbs with verbal nouns, tagged by Context, topic and sub-topic. Wrote PROPOSAL.md setting out six directions for a native iOS companion to Nathán, recommended build order A (recall trainer) and F (rubrics), then B (rule-based grammar engine), D (sentence scaffolds), C (speaking rehearsal with personal answer bank), E (teacher view).",
    status="Under Review",
    output_file="NathanCompanion/PROPOSAL.md (branch claude/nathan-companion-app-k1105h in the get-iplayer-automator repository)",
    notes="Raw parse needs a human cleaning pass before use: feminine unmarked, 14 broken entries, sub-heading bleed. Apple has no Irish TTS or ASR; speaking module depends on the Abair API. Copyright question for CCEA before any App Store release. Dáithí asked for both the recall and speaking directions plus other ambitious ones; platform confirmed as native iOS or iPad.",
    device="Home (M5)",
)
```

## 8. Ruling of 26 September 2026

The app never names the examining body, the list, or the appendices. Dáithí will augment the corpus himself. The cleaning workbook `Nathán companion - corpus.xlsx` is the working copy of the data from now on; the JSON in `data/` is the raw extraction and is superseded by the workbook once cleaning begins.

## 9. Visual direction, ruled 26 September 2026

Four screens were mocked in a generic register, rejected by Dáithí as "designed by AI". Three alternatives were then drawn on the same canvas: a dictionary page, an exam script, and a combination. **Dáithí chose the exam script.** Canvas: https://claude.ai/artifact/SerbqvkAAFyZsjQGcdYACG (row C).

The register: ruled copybook lines with a margin rule, the exam papers' own rubric wording in italic with an English gloss, the pupil's typed answers in biro blue, marking in a pen hand in the margin, a candidate box at the top of each task. One print face for everything set (Atkinson Hyperlegible in the mock-up), one hand for the marks.

Three conditions attached to the choice:

1. The marking hand must be a real digitised handwriting, not a stock font.
2. The frame is a practice booklet, not a test. Ticks and corrections, no percentages, no timer unless the pupil switches on the cold exam mode. This matters most for the ADHD fork below.
3. The pen colour should match the colour pupils see on marked work at St Paul's.

## 10. A fork to keep in mind: pupils with ADD and ADHD

Raised by Dáithí mid-session. Pupils who struggle to attend, retain and memorise are a specific audience the companion could serve first. Consequences for design, to be carried into every screen:

- one question per screen, one action, nothing competing;
- immediate marked feedback, visible progress within a session measured in minutes, not days;
- short sessions by default (five items), with the option to continue, never a long queue shown up front;
- predictable structure: every task looks like the last one;
- spacing intervals shorter than the usual defaults, and re-tests of the same item inside one session.

The exam script suits this fork better than the dictionary page, which is dense by nature.

Rulings on the two open conditions, same day: the pen is **red**, matching marking at St Paul's; the marking hand is **Dáithí's own handwriting**, to be digitised from a photographed sample sheet.

## 11. The Key Stage 3 framework (TransformED, Northern Ireland Curriculum 2028, draft for consultation)

Read 26 September 2026: the draft Modern Languages framework, the explanation of its appendices, and Appendix 3, Irish (phonics, vocabulary by frequency, alphabetical and by part of speech, grammar).

**What it changes for the app.** The framework is built on exactly the three things the companion drills: sound-symbol correspondences, high-frequency vocabulary, and grammar for meaning (tense, person, negation, question). It names regular revisiting and recall as the method, wants pupils to write from memory, wants unprepared speech, and wants pupils to keep a small personal vocabulary. The app should therefore span Key Stage 3 to GCSE with two spines in one data model: the KS3 list (about 800 headwords, frequency-ranked, part of speech and gender given) for Years 8 to 10, and the GCSE list for Years 11 and 12. Only about 230 headwords are on both, so the KS3 list is largely new material, not a subset.

**Good news.** The KS3 Irish list leans Ulster: fosta not freisin, madadh not madra, cad é mar, achan, ar na mallaibh. It also carries gender and part of speech cleanly, which the GCSE list does not. It should become the primary vocabulary spine and the GCSE list the second.

**Modules the framework adds.** A phonics module from the appendix's source and cluster words (hear and type; read aloud and record), and a personal vocabulary the pupil adds to (the appendix itself leaves placeholders for a placename and the pupil's surname). Prepositional pronoun paradigms (agam, agat, aige...) and verbs in positive, negative and interrogative forms are explicitly listed, so the grammar engine's scope is now defined by the appendix.

**Dependencies.** Listening input "in a standard variety" collides with an Ulster classroom; the Abair Ulster voice is the practical answer. Audio is needed for phonics, which pushes Abair earlier in the build order than section 5 put it.

**Defects in the draft appendix worth raising in the consultation.**
1. In the Irish grammar sheet, columns A to D carry the Spanish appendix's content (feminine nouns "-o changes to -a", ser and estar, algún). The Irish grammar proper sits in columns E and F and runs to nine rows. The Irish grammar appendix is both contaminated and thin.
2. 29 vocabulary rows have no part of speech; several common words are absent (cailín, buachaill, go raibh maith agat) while madadh sits at rank 3806.
3. "Standard variety" pronunciation is undefined for Irish, which has three.

## 12. Concept ruling, 26 September 2026

A five-angle concept panel (see CONCEPT.md) chose the pupil's own exam script as the idea that runs through the app. Dáithí's rulings on the brief's three open questions:

1. **The whole school, not Years 11 and 12 only.** The thread has to hold for a Year 8 with no exam date. The brief is being adapted.
2. **Wait for Abair.** No teacher recording of the 270 questions; the questions stay in print until the synthetic Ulster voice is wired in.
3. **Dáithí signs off every line of Irish himself**, page titles, glosses, pen phrases included.

## 13. Grammar exemplars, 26 September 2026

Dáithí uploaded a 186-page scan of the school grammar workbook Gramadach Gan Dua (standard Irish, illustrated, exercises for every tense, mood, declension and preposition). Ruling: its sentences are to be extracted, tagged by grammar point, **converted to Ulster forms and used on screen**, with Dáithí signing off every conversion in a sheet before any reaches a pupil. Copyright for on-screen use is to be settled before distribution, as with the exam board's list. The scan is at data/Gramadach Samplaí.pdf; optical character recognition ran with the Irish model.

## 14. Whole-school rulings, 26 September 2026

On CONCEPT.md second version: the default calendar of pages per year is **accepted** as the starting point. The department **cannot reliably** hold one real conversation per class each half term with partner-ticked cards, so the cover's date for Years 8 to 10 cannot be a staged conversation. That point goes back to the panel; the rest of the brief stands.

## 15. Synthetic and analytic verb forms, 26 September 2026

Ruling: the app carries both an fhoirm tháite and an fhoirm scartha, with a setting to choose which is shown, because teachers use either or both. The pen accepts either form whatever the setting. The past tense first person plural is never the -amar or -eamar form: always chuir muid, d'ól muid. Scope settled the same day: the toggle applies to the **present and future tenses, first person plural only** (cuirimid or cuireann muid; cuirfimid or cuirfidh muid), and to nothing else. The first person singular stays synthetic in every tense (cuirim, cuirfidh mé is not used: cuirfidh mé is the future first singular in both settings; chuirfinn, chuirinn); the conditional and past habitual plurals stay analytic (chuirfeadh muid, chuirfeadh siad, chuireadh muid); the past first plural is always chuir muid. Default setting: scartha, until Dáithí says otherwise. The grammar exemplars carry both present and future first-plural variants.

## 16. Direction ruling, 26 September 2026, evening

Dáithí did not recognise the panel's brief (the candidate box with a date, the conversation calendar, the boxes and gates) and had not agreed to it. Claude had developed it past what was signed off, in language never explained. Ruling, after a plain explanation: **yes to the core idea, kept simple.** One notebook of the pupil's own answers to the examiner's questions, one new answer a night and one old one rewritten from memory, marked in Dáithí's hand for fadas and mutations; no dates or candidate-box devices for the younger years; word practice and grammar drills sit beside it as plain tools. The long brief is kept for the record at data/CONCEPT-long-2026-09-26.md and is superseded by the short CONCEPT.md.

## 17. Rejection, 26 September 2026, late evening

After seeing eight screens of it (canvas row E), Dáithí rejected the notebook: **the look and the idea both.** The exam-script look, chosen for one screen, became a homework jotter across a whole app. The "pupil writes their own answers, one a night" idea came from Claude's concept panels, not from Dáithí, and was never his. What stands from the day: the corpus and its cleaning workbook; the Key Stage 3 analysis; the whole-school scope; the ADHD fork; the red pen in Dáithí's own hand; the 270 questions authored for sign-off; the grammar exemplars being rewritten in Ulster Irish; the verb-form toggle ruling. What the app should do for a pupil is to be restated by Dáithí in his own words before anything else is drawn.

## 18. Restart, 26 September 2026, night

Dáithí found the working web app (artifact MjhJntQp8bnP5b7hKzzteC) functional but disjointed and not enjoyable, declined Nathán as a model ("a different category of app"), and declined the proposed single-round redesign. Ruling: **scrap the product design and start again.** The data work carries over untouched: the cleaned word lists, the 270 authored questions, the grammar exemplars in Ulster Irish, the verb-form rulings, the marking hand. The restart begins from the problem the app exists to solve, in Dáithí's words, before any screen.

## 19. Pedagogy ruling, 26 September 2026, night

Dáithí: the app's design is to incorporate the philosophy of Dr Gianfranco Conti (Extensive Processing Instruction). Settled so far: memory is the spine, speaking the goal. Conti's model answers the open question of the unit of memory: **chunks and sentence builders**, not single words. Two tensions to resolve before design: (1) EPI starts with modelling and receptive processing through listening, which collides with the ruling of no audio until the Abair voice is wired in; (2) the NI Key Stage 3 framework is written in the phonics, frequency-vocabulary and grammar tradition that Conti has publicly criticised, so the app must satisfy the framework's content while following Conti's method. The gianfrancoconti.com site could not be reached from this session (network block); the summary of EPI used here is from Claude's general knowledge and should be checked against his own writing.

Audio ruling, same night: **bring audio forward now**, the Abair Ulster voice for every chunk and sentence from the start. The Abair hosts (abair.ie, api.abair.ie, synthesis.abair.ie) are blocked by this cloud session's network policy; access to be opened before Abair's service terms and interface can be checked.

Framework ruling, same night: **Conti's method, the framework's content.** Sentence builders are built from the Key Stage 3 high-frequency words and grammar; phonics is taught through listening to those same chunks.
