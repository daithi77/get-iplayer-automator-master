# Marking Hand

Dáithí's own handwriting, digitised on 26 September 2026 from one photographed sample sheet (`sample-sheet.jpg`) written in the red marking pen. Used for every mark the app makes in the margin.

`buildfont.py` rebuilds the font from the sheet: isolates the red ink, deskews, cuts each glyph, traces it to curves with potrace, and assembles an OpenType file with fontTools. Glyph set: a to z, A to Z, the ten fada vowels, digits, `/ . , ! ? : ( ) -`, a tick (U+2713 and U+2714) and a cross (U+2717, U+2718 and the multiplication sign). Working name "Marking Hand", to be renamed.

Known limits of this first cut: no kerning, a single form of each letter, no `'` or `"` or `;`, and the cap height was normalised to 700 units so the x-height sits where the sheet put it. `proof.png` shows the result against the words from the sheet.
