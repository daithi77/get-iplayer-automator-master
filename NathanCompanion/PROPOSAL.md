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
