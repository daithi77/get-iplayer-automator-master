# iPhone Duo: handover for the Mac session

10 October 2026. Written by a cloud session (Linux container, no Xcode, no Swift compiler) that stopped at the pre-checks, as Dáithí asked. No app code was changed. Everything below is for the session that runs on the Mac.

## What the cloud session could and could not do

| Check | Result |
|---|---|
| 1. `xcode-select -p` is Xcode 27.1 RC | Could not run: `xcode-select` not found. Linux, not the Mac. |
| 2. Read developer.apple.com/iphone-duo and the guide | Done. Facts below, verified 10 October 2026. |
| 3. `xcrun simctl list devices` shows iPhone Duo | Could not run: `xcrun` not found. |
| 4. Xcode's resizability scan | Could not run. A grep for the patterns Apple's Prepare page lists found none in the app (no `UIScreen.main`, no orientation, idiom, size-class or device-size checks, no aspect-fill media). Repeat the real scan on the Mac. |

## What Apple's pages say

### Prepare page (developer.apple.com/iphone-duo/prepare)

| SDK the app is built with | Behaviour on iPhone Duo |
|---|---|
| iOS 26 SDK or earlier | Runs but does not adapt. Open, the app is centred with empty space around it. Closed, content sits left of the status bar and camera. |
| iOS 27 SDK | Fills most of the inner display but avoids the status bar on the right edge. |
| iOS 27.1 SDK or later | Edge to edge. Toolbars and tab bars move vertically below the status bar. |

Quoted: "Before shipping an app build with the iOS 27.1 SDK, make sure your app's content adapts to the bars becoming vertical."

Running the scan: in Xcode, ask the coding assistant "get my app ready for iPhone Duo". From another agent: `xcrun agent skills export`. Apple says the skill does not catch everything.

Patterns it looks for: `UIScreen.main`; layout decided by orientation; idiom or size class taken as the device; checks against known iPhone sizes; full-bleed media with aspect fill.

Testing: the iOS resizable simulator in Device Hub; iPhone Mirroring on macOS 27; the iPhone Duo simulator in Xcode 27.1 (Apple: the best way to test the full native experience).

### Guide (Preparing your app for iPhone Duo)

- Prefer system containers: split views, tab bars, arrangement views, navigation stacks.
- Size views to their container, not to fixed iPhone dimensions. Use size classes and scene geometry.
- Bars go vertical on the outer display when closed, and in some leading or trailing positions on the inner display when open. Bars must come from `.toolbar(content:)` on a `NavigationStack` to get this.
- "If your item has a title and doesn't have an icon, the system doesn't present it vertically." Give every toolbar item an icon and a title.
- Put Back or Close at the top of the vertical bar (`cancellationAction`), then prominent actions (`topBarPinnedTrailing`).
- "Avoid placing an arrangement view inside a navigation split view, list, scroll view, or other container that might cause part of your view to become inaccessible."
- The fold and the cameras are reserved regions. A division (the fold) is active when partially open and inactive when fully open.
- No point sizes, size classes per pose, Info.plist keys or state-preservation advice appear on any of the pages. The 5.4 inch and 7.6 inch figures came from Dáithí's briefing, not from Apple.

### Human Interface Guidelines (Designing for iPhone Duo, dated 9 September 2026)

- "A compact width layout for the outer display and a regular width layout for the inner display give you the fundamentals for every pose."
- "Keep functionality and the state of elements the same between displays."
- "Avoid extreme layout changes as people fold the device. Move only what's necessary to keep elements visible and easy to tap."
- "In a grid-style layout, prefer an even number of columns so content divides cleanly."
- "Keep navigation outside of arrangement views."
- "Consider using the full display width for interfaces where bars aren't necessary."
- "In general, don't override the default bar placement."

### APIs, with signatures from the API pages (all iOS 27.1, marked beta)

```swift
// Two views, side by side when wider than tall, stacked when taller than wide.
ArrangementView {
    PrimaryView()
        .splitArrangementLayoutRatio(0.4)   // optional share of the split
} secondary: {
    SecondaryView()
}
.arrangementViewStyle(.split.axes(.horizontal))   // or .split, or .overlay

// Where the fold and cameras are, in the view's own coordinates.
GeometryReader { proxy in
    let folds = proxy.reservedRegions(kind: .division)   // [ReservedRegion]: frame, margins, isActive, id
}

// Opt a non-scrolling screen out of the vertical bar. Apple: treat as a stable choice, do not toggle per view state.
.toolbarVerticalBehavior(.disabled)

// Which edge the vertical bar is on, or nil where there is none.
@Environment(\.toolbarVerticalEdge) var edge   // HorizontalEdge?
```

Also listed on the API pages, not read in detail: `splitArrangementLayoutSize(minWidth:idealWidth:maxWidth:minHeight:idealHeight:maxHeight:)`, `splitArrangementFixedLayoutSize(horizontal:vertical:)`, `overlayArrangementEdge(_:)`, `toolbarVerticalCompressionBehavior(_:)`, `ToolbarOverflowMenu`, `visibilityPriority(_:)`, `axisBehavior(_:)`, `presentationPlacement(_:)`, `backgroundExtensionEffect()`.

## Where the app stands

- `NathanCompanion/ios/GanAinm.swiftpm`, an App Playground. `swift-tools-version: 6.2`, `platforms: [.iOS("26.0")]`, portrait and both landscapes on iPhone.
- `ArrangementView` and the rest need iOS 27.1. Either guard with `if #available(iOS 27.1, *)` or raise the platform to 27.1. TESTFLIGHT.md records that App Store Connect reads the package's minimum iOS as its SDK version, so building with the 27.1 SDK may raise the minimum to 27.1 regardless. Check what Nathán's phone runs before deciding.
- The word "puzzle" appears nowhere in the code or data. Best match for "the main puzzle screen": `SessionView.swift`, the Éist, Aithin, Tóg, Ó chuimhne run that a unit card on the home screen opens as a `fullScreenCover`, where the pupil picks one tile from each colour. Other candidates: Cén bosca? in `Verbs.swift`, the grammar drill in `GrammarView.swift`. Confirm with Dáithí first.

## Proposed change, not built

1. **Full inner display.** `SessionView.swift` line 22 caps the content at `.frame(maxWidth: 760)` inside a `ScrollView`. Unfolded, that leaves empty margins either side. Replace with a layout that splits when the available width is regular: prompt, instructions and feedback on one side (about 0.4), the `BuilderGrid` tiles on the other; stacked as now on the outer display. Decide the split from the container's width via `GeometryReader` or `onGeometryChange`, never from orientation or idiom.
2. **Which container.** `ArrangementView(.split)` is Apple's intended tool, but the guide warns against putting it inside a scroll view, and this screen scrolls. Try it with the scroll view inside each pane. If it fights, fall back to `AnyLayout` switching between `HStackLayout` and `VStackLayout`, which keeps view identity.
3. **State across fold, unfold and rotation.** `Session` is an `ObservableObject` held in `@State active` on `HomeView` and presented by `fullScreenCover`; a size change does not recreate it, so the run itself survives. The risks are in the views: an `if wide { HStack } else { VStack }` switch changes identity and resets `ListenStep`'s `@State picked` and `shown`, the `@FocusState typing`, and the scroll position. Keep identity stable (point 2). Make sure `session.autoPlay()` and `.onAppear { typing = true }` do not refire on resize. Test by picking two tiles, folding, unfolding and rotating, and checking the ticks are still there.
4. **Vertical bar.** The Druid (close) button is `cancellationAction` with a title only, so the system will not show it in a vertical bar. Give it `Label("Druid", systemImage: "xmark")`. The bottom action bar is a custom `safeAreaInset`, so it stays horizontal; check it clears the vertical bar on the outer display.
5. **The fold.** The tiles sit in four colour groups stacked vertically. In the split layout they are on one side of the fold. If a group lands on the fold when partially open, pad around `reservedRegions(kind: .division)`. Optional.
6. Out of scope unless Dáithí asks: `HomeView` (`maxWidth: 900`), the Teach, Grammar, Verbs and Comhrá screens, which have their own `GeometryReader` layouts.

## Done means

Builds against the iOS 27.1 SDK with no new warnings. Screenshots from the Duo simulator: folded, unfolded portrait, unfolded landscape. A run in progress survives fold, unfold and rotation with the chosen tiles still selected.

## On the Mac

Open a session in `NathanCompanion/ios/GanAinm.swiftpm`. Repeat the four pre-checks there before any code. Then ask Dáithí, one at a time: which screen; split layout or simply widen; guard for 27.1 or raise the deployment target.
