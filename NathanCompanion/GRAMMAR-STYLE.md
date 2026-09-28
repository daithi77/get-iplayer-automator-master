# Gan Ainm grammar style: Dáithí's method

Every grammar asset in Gan Ainm (lessons, practice items, overview tables, slide decks, iPhone and web) follows these rules. They are deduced from Dáithí's own *GCSE: Using Verbs* booklet; the evidence is in `data/verb-booklet/REPORT.md`. Where a rule here and an older lesson disagree, this file wins; retrofit the lesson when you next touch it.

## The rules

1. **Box first.** Every verb activity starts by placing the verb in its box, shown in the box colour:
   - 1st conjugation broad: orange `#FDC99A`
   - 1st conjugation slender: yellow `#FFFF99`
   - 2nd conjugation broad: green `#CCFFCC`
   - 2nd conjugation slender: blue `#99CCFF`
   - syncopated: purple `#CC99FF`
   - irregular: pink `#FF99CC`
   (Light-mode tints; use darker equivalents in dark mode, and always label the box in words as well.)
2. **Broad or slender, every time.** The first step of every regular-verb procedure asks it.
3. **Rules as numbered moves.** Write each rule as two to four numbered steps built from the named moves, in order:
   séimhiú (aspirate: h after the first letter) · urú (eclipse: a letter in front) · prefix d' · remove -aigh / -igh · add the ending · add the pronoun · add Ní / An (Níor / Ar in the past) · remove d'.
4. **Positive, negative and question together.** Every lesson, table, worked example and slide shows P, N and Q as a set. The autonomous form sits alongside them, not in a separate place.
5. **One overview across the tenses.** Each verb group has one overview grid (past, present, future, conditional side by side) using the same move language, and lessons link back to it. It fits on one screen or one slide.
6. **Two forms plus we.** Teach the mé form and the form for everyone else. The we-form is analytic by default (cuireann muid, cuirfidh muid) with the synthetic shown beside it and accepted. In the conditional, show both forms for we and they (chuirfimis / chuirfeadh muid; chuirfidís / chuirfeadh siad).
7. **Irregular verbs as cards.** One card per verb, in this order: beir, ith, tar, cluin, tabhair, faigh, abair, déan, téigh, feic, bí. Each card has P, N and Q across the four tenses; show the Ulster form beside the standard where one exists (gheibhim, tchím, bhéarfaidh, níor dhúirt). Use cluin, never clois.
8. **The mnemonics, word for word.**
   - Letters that take séimhiú: "Britney caught dopey friends going mad publicly, silly twits" (b c d f g m p s t).
   - Letters that never do: vowels; "He likes noodles and rice" (h l n r); "Scallions smell spicy in stew" (sc sm sp st).
   - Urú: "Many boys go camping near ditches behind fences, while nice girls buy pens down town" (mb gc nd bhf ng bp dt).
9. **Colour means one thing.** Red with underline for a letter or word added; green with underline for a particle; the box and tense colours above. Never colour alone.
   Tense colours (overviews and cards): past yellow, present blue, future pink, conditional purple.
10. **English explains, Irish names.** Headings pair the Irish term with the English (An Aimsir Chaite · Past tense). Explanations in plain English. Grammatical terms: séimhiú and urú, each glossed with Dáithí's words (aspirate, eclipse) the first time on a screen.
11. **Examples you would say to someone.** Prefer questions to tú, real situations and local places (Bessbrook, Newry, Camlough, Dún Dealgan), with humour where it fits: "An dtiocfaidh tú chuig an dioscó liom?"
12. **The whole pattern on one screen.** If an overview needs scrolling, split it by group, not by tense.

## Ruling, 28 September 2026: the colour-coded boxes are a key asset of the whole app

Dáithí: "The colour coded boxes is a key asset to preserve and develop across the app." So the boxes are not a grammar-section feature; they are part of how Gan Ainm shows every verb.

- **One source.** The boxes, their verbs and their colours live in `builders/verbs.json`. Web and iPhone read the same colours as named tokens (box-c1-broad, box-c1-slender, box-c2-broad, box-c2-slender, box-sync, box-irreg), each with a dark-mode variant of the same hue.
- **Everywhere a verb is taught.** Grammar lessons, the verb cards, the overview grid, sentence builder rows whose chunk is a verb, GCSE and A2 pattern boxes, Comhrá rows and the class slides all show the verb's box colour and its label (for example "2 caol"). Colour is never the only signal.
- **Grow the boxes.** Every new verb that appears in new content is added to its box in `builders/verbs.json`, so the boxes become the app's verb dictionary.
- **Develop them as an activity.** A "Cén bosca?" sorting activity (drag or tap the verb into its box), a verb look-up that opens on the verb's box and card, and a box legend on every grammar screen and deck.
- **Preserve them.** No redesign may drop, merge or recolour the boxes without Dáithí's say.

## Standing language rulings (unchanged)

Ulster Irish. Never "dún" as a verb (druid). Never -amar/-eamar. "cluin", not "clois". "tábla", not "bord". British spelling, "pupil" not "student", no em or en dashes, never name an exam board or specification.
