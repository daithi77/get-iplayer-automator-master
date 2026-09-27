# 2026-09-27 - Gan Ainm - session note

Secondary session (Claude Code in the cloud; the Claude-Work folder was not reachable, so nothing was written to the register). Everything below is ready to paste into the script.

## Register entries

```python
add_work_entry(
    project="Gan Ainm",
    task="Uploaded version 0.3 (build 5) to TestFlight: grammar walk-through lessons (30 sections, 195 lessons) and the new Comhrá AS track (16 topics, 66 questions). Answered the export compliance question (None of the algorithms) and confirmed the build Ready to Test; installed on Dáithí's iPhone Air.",
    status="Complete",
    output_file="",
    notes="Apple asks the encryption question for every build. Claude could not set the answer inside the App Playground format; it goes away once the app is converted to a standard Xcode project before pupils test it.",
    device="Home (M5)",
)

add_work_entry(
    project="Gan Ainm",
    task="Added a colleague at St Paul's as an internal TestFlight tester: App Store Connect user with the Marketing role limited to Gan Ainm, invitation accepted, added to the Beta 1 group. Feedback arrives under TestFlight, Feedback, Screenshots.",
    status="Complete",
    output_file="",
    notes="Internal testing only. ABAIR's written consent is still needed before external testers or pupils.",
    device="Home (M5)",
)

add_work_entry(
    project="Gan Ainm",
    task="Dáithí ruled on 23 open points from the Comhrá AS and grammar review lists; Claude applied them. Changes: 'fá dtaobh de' in three questions; 'Sílim an dúrud de' added to the music model answer; vapes offered as 'toitíní leictreonacha', 'ag vapeáil' and 'ag galú'; the r1-chaite road sentence became 'Druideadh an leabharlann go luath inné'; 'Tá cead mo chinn agam' and 'Contae' in the review notes. Kept: £8 to £10 pay, Armagh 2024, drinking removed, 'An dóigh a ndéantar é', 'seasann sí liom', 'ar an talamh', 'ionad fóillíochta', 'leanúint', 'gráid', 'a bheith', lenition after slender plurals, 'an bhliain seo chugainn', brand names, AI as 'sí', 'ag druidim', 'na gardaí', 'Brisim rialacha go minic'. Web beta republished (version 13); iPhone package rebuilt as build 6.",
    status="Complete",
    output_file="",
    notes="Code is on GitHub, branch claude/nathan-companion-app-k1105h, folder NathanCompanion. Rulings recorded in data/comhra-AS-review.md, data/grammar-lessons-review.md and PROPOSAL.md. Browser tests after the change: 16/16 Comhrá topics, 195/195 grammar lessons.",
    device="Home (M5)",
)

add_work_entry(
    project="Gan Ainm",
    task="Build 6 (version 0.3) downloaded and opened in Xcode, ready to archive and upload to TestFlight. Upload not yet done.",
    status="In Progress",
    output_file="",
    notes="Next time: set the team to Dáithí Murray, choose Any iOS Device (arm64), Product then Archive, Distribute App, TestFlight Internal Only; answer the encryption question in App Store Connect.",
    device="Home (M5)",
)
```

## Session note

```python
add_session_note(
    summary="Gan Ainm, the Ulster Irish learning app. Uploaded version 0.3 (build 5) to TestFlight and installed it on Dáithí's iPhone Air; added a colleague at St Paul's as an internal tester in Beta 1; took Dáithí's rulings on 23 open points in the Comhrá AS and grammar review lists and applied them to the web beta and the iPhone package (build 6). Build 6 is open in Xcode but not yet uploaded.",
    decisions="Rulings of 27 September: 'Tá cead mo chinn agam'; 'fá dtaobh de' in writing; 'Contae', 'gráid', 'leanúint', 'a bheith'; lenite after slender plurals; vapes as 'toitíní leictreonacha', 'vapeáil' or 'galú' (Claude read Dáithí's answer 'Use all of the corrected terms' as all three; he should confirm); 'Sílim an dúrud de' added (Claude spelt it 'dúrúd' in the question but 'dúrud' in the app; Dáithí to confirm); 'na gardaí' kept; no drinking in weekend answers. Claude attempted to re-upload a duplicate archive of build 5 before spotting that build 5 was already uploaded; always check the Status column in the Organizer first. Claude promised to stop the encryption question and then found it cannot in the App Playground format; it corrected that the same session. Dáithí gets overwhelmed by multi-step Apple procedures: one step at a time, with links, and screenshots requested after each step.",
    device="Home (M5)",
)
```

## Diary line for HANDOFF.md

27 September: Gan Ainm 0.3 on TestFlight with a colleague testing; review rulings applied; build 6 waits in Xcode to be archived and uploaded.
