# Cuimhne, proof of concept 0.2

A Swift App Playground: the whole app shape, in the exam-script register, marked in Dáithí's own hand.

## Run it

**iPad with Swift Playgrounds:** copy the `Cuimhne.swiftpm` folder to the iPad, open it in Swift Playgrounds, press Run.

**Mac with Xcode:** File > Open, choose the `Cuimhne.swiftpm` folder. At the top, click "Any iOS Simulator Device" and pick a named iPhone. Press the Run triangle. To run on your own iPhone, plug it in, choose it instead, and pick your personal team in the package's Signing pane.

Written without a compiler to hand. The first run may throw up an error or two; paste the error text back and it gets fixed.

## What is in it

Five tabs.

- **Inniu.** Candidate box, what is due, streak, one Tosaigh button. A session draws on every topic of the current stage.
- **Innéacs.** Every topic (GCSE) or frequency band (Key Stage 3) with a learned count. Tap one to browse its words or practise just that topic.
- **Gramadach.** A live rule engine: article with a noun, or preposition with the article, generated from the word's gender in Ulster forms. A wrong answer is diagnosed by rule (urú instead of séimhiú, séimhiú missing, t- missing) and the rule shown in Irish and English.
- **Labhairt.** The 270 examiner questions by topic. The pupil writes their own answer on the ruled lines, records it, plays it back. Answers are kept on the device.
- **Socruithe.** Name, class, stage (Key Stage 3 or GCSE), questions per round, strict fadas, progress counts, clear progress.

Data on board: the GCSE topic list (2,233 entries, uncleaned), the Key Stage 3 frequency list (826 entries), the question bank (270). Progress is kept per word on the device with Leitner boxes: 0, 1, 3, 7, 14, 30 days. A word wrong first time comes round again inside the same round.

## Known limits

Uncleaned data, so some GCSE entries carry the source's faults. The grammar engine covers the article and nine prepositions only. No audio of the questions. No teacher view. Print face is the system font; the mock-up used Atkinson Hyperlegible.
