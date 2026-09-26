# Cuimhne, proof of concept

A Swift App Playground. One task: recall, five words a session, topic "Caitheamh aimsire" (316 entries, uncleaned), marked in the exam-script register with the marking hand.

## Run it

**On an iPad with Swift Playgrounds (easiest):** AirDrop or copy the whole `Cuimhne.swiftpm` folder to the iPad, open it in Swift Playgrounds, press Run.

**On the Mac in Xcode:** File > Open, choose the `Cuimhne.swiftpm` folder, pick an iPhone simulator at the top, press Run. To run on your own iPhone, plug it in, choose it instead of the simulator, and in the package's Signing pane pick your personal team.

Written without a compiler to hand, so the first run may throw up a small error or two. Paste the error text back and it gets fixed.

## What it does

Home page shows the candidate box, what is due, streak. Tosaigh starts five questions. Nouns take one box, verbs two (root plus preposition, then verbal noun). A fada row sits above the keyboard. Seiceáil marks in the margin in the hand; a wrong answer is struck through with the right one written above. A word wrong first time comes round again before the session ends. Results page lists the five with ticks and crosses and a one-line comment. Progress lives on the device; Socruithe sets name and class, strict fadas, and clears progress.

Spacing: Leitner boxes with intervals of 0, 1, 3, 7, 14 and 30 days. Wrong drops to box 0.
