import SwiftUI
import AVKit

/// Don rang: builder slides for the classroom screen.
/// On an iPad, mirror to an Apple TV (Control Centre, Screen Mirroring) and hold the iPad sideways.
struct TeachHome: View {
    @EnvironmentObject private var store: Store
    @State private var showHelp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Sleamhnáin do mhúinteoirí. Slides for the class screen: one builder row per slide, with Áine's voice.")
                    .foregroundStyle(Theme.muted)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                    ForEach(Array(store.units.enumerated()), id: \.element.id) { i, unit in
                        NavigationLink {
                            TeachDeck(unit: unit)
                        } label: {
                            deckCard("\(i + 1). \(unit.title)", unit)
                        }
                        .buttonStyle(.plain)
                    }
                }
                ForEach([UnitTrack.gcse, UnitTrack.a2], id: \.self) { track in
                    let units = store.trackUnits(track)
                    if !units.isEmpty {
                        Text(track.title)
                            .font(.caption.weight(.bold))
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.muted)
                            .padding(.top, 8)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 12)], spacing: 12) {
                            ForEach(units) { unit in
                                NavigationLink {
                                    TeachDeck(unit: unit)
                                } label: {
                                    deckCard(unit.title, unit)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                if !store.comhra.isEmpty {
                    ComhraDeckList(units: store.comhra)
                }
                if let grammar = store.grammar {
                    GrammarDeckList(grammar: grammar)
                }
            }
            .padding()
        }
        .background(Theme.ground)
        .navigationTitle("Don rang")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHelp = true
                } label: {
                    Label("Ar an teilifís", systemImage: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelp) {
            CastHelp()
        }
    }

    private func deckCard(_ title: String, _ unit: BuilderUnit) -> some View {
        HStack(spacing: 12) {
            Text(unit.emoji).font(.system(size: 36)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline).foregroundStyle(Theme.ink)
                Text("\(unit.en) · \(DeckSlide.make(unit).count) sleamhnán")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
            Spacer()
            Image(systemName: "play.rectangle.fill")
                .font(.title2)
                .foregroundStyle(Theme.columnInk(0))
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.rule))
    }
}

/// How to get the slides onto each kind of classroom screen.
struct CastHelp: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Apple TV") {
                    Text("1. Open Control Centre on the iPad and tap Screen Mirroring.")
                    Text("2. Choose the classroom Apple TV.")
                    Text("3. Hold the iPad sideways. Áine's voice plays through the TV.")
                }
                Section("Interactive panel or projector") {
                    Text("Open the Gan Ainm web link in the panel's browser, or on the laptop connected to it, and choose Don rang. The slides and the audio are the same.")
                    Text("If the panel supports AirPlay or screen sharing from an iPad, mirror the iPad as for Apple TV.")
                }
                Section("While presenting") {
                    Text("Swipe, or use the arrows, to move between slides.")
                    Text("Tap any chunk to hear it. Tap Éist to hear the row's sentences, lit up as Áine says them.")
                    Text("Hide the English to turn a slide into a recall task.")
                    Text("On a pattern, ladder or role-play slide, the first press of the right arrow shows what is held back; the next press moves on.")
                }
            }
            .navigationTitle("Ar an teilifís")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Déanta") { dismiss() }
                }
            }
        }
    }
}

/// One unit's slides, in the house sequence: title, Sprioc, each builder row, pattern, ladder, role play,
/// model answers, Dul siar (the numbered questions), then a closing slide that bookends the title.
enum DeckSlide: Hashable {
    case title
    case sprioc
    case row(Int)
    case pattern(Int)
    case ladder
    case role(Int)
    case models
    case dulsiar
    case end

    static func make(_ unit: BuilderUnit) -> [DeckSlide] {
        var slides: [DeckSlide] = [.title]
        if !(unit.sprioc ?? []).isEmpty { slides.append(.sprioc) }
        slides += unit.rows.indices.map { DeckSlide.row($0) }
        slides += (unit.patterns ?? []).indices.map { DeckSlide.pattern($0) }
        if !(unit.ladder ?? []).isEmpty { slides.append(.ladder) }
        slides += (unit.roleplays ?? []).indices.map { DeckSlide.role($0) }
        slides += [.models, .dulsiar, .end]
        return slides
    }
}

struct TeachDeck: View {
    let unit: BuilderUnit
    private let slides: [DeckSlide]
    @Environment(\.dismiss) private var dismiss
    @State private var page = 0
    @State private var showEnglish = true
    /// How much of each slide is showing: the pattern answers, the ladder rungs, the role-play answers.
    @State private var steps: [Int: Int] = [:]

    init(unit: BuilderUnit) {
        self.unit = unit
        self.slides = DeckSlide.make(unit)
    }

    private var lastPage: Int { max(0, slides.count - 1) }

    var body: some View {
        TabView(selection: $page) {
            ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                slideView(slide, page: i)
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Theme.ground)
        .navigationTitle("\(unit.emoji) \(unit.title)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showEnglish.toggle()
                } label: {
                    Label(showEnglish ? "Folaigh an Béarla" : "Taispeáin an Béarla",
                          systemImage: showEnglish ? "eye.slash" : "eye")
                }
                AirPlayButton()
                    .frame(width: 36, height: 36)
                Button {
                    withAnimation { page = max(0, page - 1) }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(page == 0)
                .keyboardShortcut(.leftArrow, modifiers: [])
                .accessibilityLabel("Siar. Previous slide")
                Button {
                    advance()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(page == lastPage)
                .keyboardShortcut(.rightArrow, modifiers: [])
                .accessibilityLabel("Ar aghaidh. Next slide")
            }
        }
        .onChange(of: page) {
            Speaker.shared.stop()
            steps = [:]
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
        }
    }

    @ViewBuilder
    private func slideView(_ slide: DeckSlide, page i: Int) -> some View {
        switch slide {
        case .title:
            TitleSlide(unit: unit, showEnglish: showEnglish)
        case .sprioc:
            SpriocSlide(unit: unit, showEnglish: showEnglish)
        case .row(let r):
            if unit.rows.indices.contains(r) {
                RowSlide(unit: unit, row: unit.rows[r], index: r, showEnglish: showEnglish)
            }
        case .pattern(let k):
            if let patterns = unit.patterns, patterns.indices.contains(k) {
                PatternSlide(pattern: patterns[k], shown: step(i) > 0, showEnglish: showEnglish) {
                    reveal(i)
                }
            }
        case .ladder:
            LadderSlide(unit: unit, visible: max(1, step(i)), showEnglish: showEnglish) {
                reveal(i)
            }
        case .role(let k):
            if let plays = unit.roleplays, plays.indices.contains(k) {
                RoleSlide(unit: unit, rolePlay: plays[k], revealed: step(i), showEnglish: showEnglish) {
                    reveal(i)
                }
            }
        case .models:
            ExamplesSlide(unit: unit, showEnglish: showEnglish)
        case .dulsiar:
            DulSiarSlide(unit: unit, showEnglish: showEnglish)
        case .end:
            EndSlide(unit: unit, showEnglish: showEnglish) {
                dismiss()
            }
        }
    }

    private func step(_ i: Int) -> Int { steps[i] ?? 0 }

    /// Whether this slide is still holding something back.
    private func canReveal(_ i: Int) -> Bool {
        guard slides.indices.contains(i) else { return false }
        switch slides[i] {
        case .pattern:
            return step(i) == 0
        case .ladder:
            return max(1, step(i)) < (unit.ladder ?? []).count
        case .role(let k):
            guard let plays = unit.roleplays, plays.indices.contains(k) else { return false }
            return step(i) < plays[k].tasks.count
        default:
            return false
        }
    }

    /// Shows the pattern answers, the next ladder rung, or the next role-play answer (and plays it).
    private func reveal(_ i: Int) {
        guard canReveal(i) else { return }
        switch slides[i] {
        case .pattern:
            steps[i] = 1
        case .ladder:
            steps[i] = min((unit.ladder ?? []).count, max(1, step(i)) + 1)
        case .role(let k):
            let n = step(i) + 1
            steps[i] = n
            if let plays = unit.roleplays, plays.indices.contains(k), plays[k].tasks.indices.contains(n - 1) {
                Speaker.shared.play(plays[k].tasks[n - 1].audio)
            }
        default:
            break
        }
    }

    /// A clicker press first reveals what the slide is holding back, then moves on.
    private func advance() {
        if canReveal(page) {
            reveal(page)
        } else {
            withAnimation { page = min(lastPage, page + 1) }
        }
    }
}

/// Chooses type sizes from the space available, so a slide fills a TV without scrolling where it can.
private func slideScale(_ size: CGSize) -> CGFloat {
    min(max(size.width / 1100, 0.6), 1.6)
}

struct TitleSlide: View {
    let unit: BuilderUnit
    let showEnglish: Bool

    var body: some View {
        GeometryReader { geo in
            let s = slideScale(geo.size)
            ScrollView {
                VStack(alignment: .leading, spacing: 20 * s) {
                    HStack(spacing: 20 * s) {
                        Text(unit.emoji).font(.system(size: 90 * s)).accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(unit.title).font(.system(size: 56 * s, weight: .bold))
                            if showEnglish {
                                Text(unit.subtitle)
                                    .font(.system(size: 28 * s))
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                    }
                    Text("Ceisteanna")
                        .font(Pen.font(44 * s))
                        .foregroundStyle(Theme.pen)
                        .rotationEffect(.degrees(-2))
                    ForEach(unit.questions, id: \.audio) { q in
                        Button {
                            Speaker.shared.play(q.audio)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: unit.isSilent ? "text.bubble" : "speaker.wave.2.fill")
                                    .foregroundStyle(Theme.columnInk(0))
                                Text(q.ga)
                                    .font(.system(size: 36 * s, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.vertical, 6)
                        }
                        .buttonStyle(.plain)
                    }
                    if let links = unit.grammar, !links.isEmpty {
                        Text("Gramadach · grammar: " + links.map(\.title).joined(separator: " · "))
                            .font(.system(size: 24 * s, weight: .semibold))
                            .foregroundStyle(Theme.muted)
                    }
                }
                .padding(40 * s)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct RowSlide: View {
    let unit: BuilderUnit
    let row: BuilderRow
    let index: Int
    let showEnglish: Bool
    @ObservedObject private var speaker = Speaker.shared
    @State private var shown: Sentence?
    @State private var playingAll = false
    @State private var picked: [String] = []

    var body: some View {
        GeometryReader { geo in
            let s = slideScale(geo.size)
            let widest = row.columns.map { $0.count }.max() ?? 1
            // Long columns wrap into sub-columns of four, so tiles stay large.
            let base: CGFloat = widest > 4 ? 28 : 36
            let tileSize = base * s
            ScrollView {
                VStack(alignment: .leading, spacing: 18 * s) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(row.label)
                            .font(.system(size: 30 * s, weight: .bold))
                            .foregroundStyle(Theme.muted)
                        Spacer()
                        Button {
                            if let mine = row.sentence(picked: picked) {
                                playingAll = false
                                shown = mine
                                Speaker.shared.playSentence(mine, in: unit)
                            }
                        } label: {
                            Label("An abairt seo", systemImage: "play.fill")
                                .font(.system(size: 22 * s, weight: .bold))
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Theme.columnInk(0))
                        .disabled(row.sentence(picked: picked) == nil)
                        if !unit.isSilent {
                            Button {
                                if playingAll {
                                    Speaker.shared.stop()
                                    playingAll = false
                                    shown = nil
                                } else {
                                    playingAll = true
                                    play(from: 0)
                                }
                            } label: {
                                Label(playingAll ? "Stad" : "Éist leis na habairtí",
                                      systemImage: playingAll ? "stop.fill" : "play.fill")
                                    .font(.system(size: 22 * s, weight: .bold))
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.ink)
                        }
                    }
                    // The sentence being spoken sits above the builder, so it is always on screen.
                    if let sentence = shown {
                        SpokenLine(sentence: sentence, unit: unit,
                                   lit: speaker.playing == sentence.audio ? speaker.lit : nil,
                                   size: 40 * s, showEnglish: showEnglish)
                            .padding(20 * s)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.surface))
                    }
                    if geo.size.width > geo.size.height {
                        wideColumns(tileSize: tileSize, width: geo.size.width - 64 * s)
                    } else {
                        BuilderGrid(unit: unit, row: row, selected: picked, litChunk: litChunk, gaSize: tileSize, showEnglish: showEnglish) { chunk, column in
                            pick(chunk, column: column)
                        }
                    }
                }
                .padding(32 * s)
                .padding(.bottom, 40)
            }
        }
        .onDisappear {
            picked = []
            playingAll = false
            shown = nil
        }
    }

    /// On a landscape screen the columns sit side by side, as on the printed builder.
    /// A column of more than four chunks wraps into sub-columns, and gets width in proportion.
    private func wideColumns(tileSize: CGFloat, width: CGFloat) -> some View {
        let subColumns = row.columns.map { max(1, ($0.count + 3) / 4) }
        let totalSub = CGFloat(subColumns.reduce(0, +))
        let arrowWidth = tileSize * 0.8 + 28
        let usable = max(100, width - CGFloat(row.columns.count - 1) * arrowWidth)
        return HStack(alignment: .top, spacing: 14) {
            ForEach(Array(row.columns.enumerated()), id: \.offset) { k, column in
                if k > 0 {
                    Image(systemName: "arrow.right")
                        .font(.system(size: tileSize * 0.8, weight: .bold))
                        .foregroundStyle(Theme.muted)
                        .padding(.top, tileSize * 0.6)
                        .accessibilityHidden(true)
                }
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10, alignment: .top), count: subColumns[k]),
                          alignment: .leading, spacing: 10) {
                    ForEach(column) { chunk in
                        Button {
                            pick(chunk, column: k)
                        } label: {
                            TileView(chunk: chunk, column: k, selected: picked.contains(chunk.id), lit: litChunk == chunk.id,
                                     gaSize: tileSize, showEnglish: showEnglish)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: usable * CGFloat(subColumns[k]) / totalSub, alignment: .topLeading)
            }
        }
    }

    /// Tapping a tile plays it and picks it; one tile per colour makes a sentence to play.
    private func pick(_ chunk: Chunk, column: Int) {
        playingAll = false
        picked = row.toggle(chunk.id, column: column, in: picked)
        Speaker.shared.play(chunk.id)
    }

    private var litChunk: String? {
        guard let s = shown, speaker.playing == s.audio, let i = speaker.lit, s.chunks.indices.contains(i) else { return nil }
        return s.chunks[i]
    }

    /// Plays every model sentence in the row, one after another, until stopped.
    private func play(from k: Int) {
        guard playingAll, k < row.sentences.count else {
            playingAll = false
            return
        }
        shown = row.sentences[k]
        Speaker.shared.playSentence(row.sentences[k], in: unit) {
            let gen = Speaker.shared.generation
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                MainActor.assumeIsolated {
                    guard Speaker.shared.generation == gen else {
                        playingAll = false
                        return
                    }
                    play(from: k + 1)
                }
            }
        }
    }
}

struct ExamplesSlide: View {
    let unit: BuilderUnit
    let showEnglish: Bool

    var body: some View {
        GeometryReader { geo in
            let s = slideScale(geo.size)
            ScrollView {
                VStack(alignment: .leading, spacing: 18 * s) {
                    Text("Freagraí samplacha")
                        .font(Pen.font(48 * s))
                        .foregroundStyle(Theme.pen)
                        .rotationEffect(.degrees(-2))
                    if showEnglish {
                        Text(unit.isSilent ? "Model answers." : "Model answers. Tap one to hear it.")
                            .font(.system(size: 24 * s))
                            .foregroundStyle(Theme.muted)
                    }
                    ForEach(unit.examples, id: \.audio) { example in
                        Button {
                            Speaker.shared.play(example.audio)
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: unit.isSilent ? "text.bubble" : "speaker.wave.2.fill")
                                    .foregroundStyle(Theme.columnInk(1))
                                Text(example.ga)
                                    .font(.system(size: 34 * s, weight: .semibold))
                                    .foregroundStyle(Theme.ink)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(40 * s)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

/// A slide's frame: type scaled to the screen, scrolling only where the content will not fit.
struct SlidePage<Content: View>: View {
    private let content: (CGFloat) -> Content

    init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }

    var body: some View {
        GeometryReader { geo in
            let s = slideScale(geo.size)
            ScrollView {
                VStack(alignment: .leading, spacing: 20 * s) {
                    content(s)
                }
                .padding(40 * s)
                .padding(.bottom, 40)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

/// A slide heading in the marking hand.
struct SlideHeading: View {
    let text: String
    let scale: CGFloat

    var body: some View {
        Text(text)
            .font(Pen.font(48 * scale))
            .foregroundStyle(Theme.pen)
            .rotationEffect(.degrees(-2))
            .accessibilityAddTraits(.isHeader)
    }
}

/// Sprioc foghlama: the learning intentions, each with Áine's voice.
struct SpriocSlide: View {
    let unit: BuilderUnit
    let showEnglish: Bool

    var body: some View {
        SlidePage { s in
            SlideHeading(text: "Sprioc foghlama", scale: s)
            ForEach(Array((unit.sprioc ?? []).enumerated()), id: \.offset) { _, item in
                Button {
                    if !unit.isSilent, let audio = item.audio {
                        Speaker.shared.play(audio)
                    }
                } label: {
                    HStack(alignment: .top, spacing: 14) {
                        if !unit.isSilent && item.audio != nil {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(Theme.columnInk(1))
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.ga)
                                .font(.system(size: 36 * s, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            if showEnglish {
                                Text(item.en)
                                    .font(.system(size: 24 * s))
                                    .foregroundStyle(Theme.muted)
                            }
                        }
                        .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// Aimsigh an patrún: the words on their own, with the changed forms held back until shown.
struct PatternSlide: View {
    let pattern: SpotPattern
    let shown: Bool
    let showEnglish: Bool
    let onShow: () -> Void

    var body: some View {
        SlidePage { s in
            SlideHeading(text: "Aimsigh an patrún", scale: s)
            Text(pattern.question)
                .font(.system(size: 30 * s, weight: .semibold))
                .foregroundStyle(Theme.ink)
            if showEnglish {
                Text(pattern.questionEn)
                    .font(.system(size: 24 * s))
                    .foregroundStyle(Theme.muted)
            }
            Grid(alignment: .leading, horizontalSpacing: 28 * s, verticalSpacing: 10 * s) {
                ForEach(Array(pattern.pairs.enumerated()), id: \.offset) { _, pair in
                    Divider()
                    GridRow {
                        Text(pair.plain)
                        Text("→")
                            .foregroundStyle(Theme.muted)
                            .accessibilityHidden(true)
                        if shown {
                            Text(Marking.text(pair.marked))
                                .accessibilityLabel(Marking.plain(pair.marked))
                        } else {
                            Text("?")
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }
            }
            .font(.system(size: 38 * s, weight: .semibold))
            .foregroundStyle(Theme.ink)
            if shown {
                if showEnglish, let rule = pattern.rule {
                    Text(rule)
                        .font(.system(size: 26 * s))
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: 1100 * s, alignment: .leading)
                }
            } else {
                Button {
                    onShow()
                } label: {
                    Label("Taispeáin · show", systemImage: "eye")
                        .font(.system(size: 24 * s, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
            }
        }
    }
}

/// Freagra níos fearr: the ladder, one rung at a time, with the new words marked.
struct LadderSlide: View {
    let unit: BuilderUnit
    let visible: Int
    let showEnglish: Bool
    let onMore: () -> Void

    var body: some View {
        let rungs = unit.ladder ?? []
        SlidePage { s in
            SlideHeading(text: "Freagra níos fearr", scale: s)
            if showEnglish {
                Text("The words in red are new. Can you do better still?")
                    .font(.system(size: 24 * s))
                    .foregroundStyle(Theme.muted)
            }
            ForEach(Array(rungs.prefix(visible).enumerated()), id: \.offset) { _, rung in
                VStack(alignment: .leading, spacing: 8 * s) {
                    Text(rung.label)
                        .font(.system(size: 18 * s, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundStyle(Theme.muted)
                    Text(Marking.text(rung.ga))
                        .font(.system(size: 32 * s, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .accessibilityLabel(Marking.plain(rung.ga))
                    if !unit.isSilent {
                        Button {
                            Speaker.shared.play(rung.audio)
                        } label: {
                            Label("Éist", systemImage: "play.fill")
                                .font(.system(size: 20 * s, weight: .bold))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(18 * s)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface))
            }
            if visible < rungs.count {
                Button {
                    onMore()
                } label: {
                    Label("Níos fearr", systemImage: "chevron.right")
                        .font(.system(size: 24 * s, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
            }
        }
    }
}

/// Ról-imirt: the whole exchange, with the pupil's side as English tasks until each answer is shown.
struct RoleSlide: View {
    let unit: BuilderUnit
    let rolePlay: RolePlay
    let revealed: Int
    let showEnglish: Bool
    let onNext: () -> Void

    var body: some View {
        SlidePage { s in
            SlideHeading(text: "Ról-imirt: \(rolePlay.title)", scale: s)
            Text(rolePlay.rubric)
                .font(.system(size: 26 * s, weight: .semibold))
                .foregroundStyle(Theme.ink)
            if showEnglish {
                Text(rolePlay.rubricEn)
                    .font(.system(size: 22 * s))
                    .foregroundStyle(Theme.muted)
            }
            VStack(alignment: .leading, spacing: 10 * s) {
                ForEach(Array(rolePlay.tasks.enumerated()), id: \.offset) { i, task in
                    Button {
                        if !unit.isSilent {
                            Speaker.shared.play(task.teacherAudio)
                        }
                    } label: {
                        Text(task.teacher)
                            .font(.system(size: 28 * s, weight: .semibold))
                            .foregroundStyle(Theme.columnInk(0))
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 16 * s)
                            .padding(.vertical, 10 * s)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(0)))
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 80 * s)
                    Group {
                        if i < revealed {
                            Text(task.ga)
                        } else {
                            Text(showEnglish ? task.en : "?").italic()
                        }
                    }
                    .font(.system(size: 28 * s, weight: .semibold))
                    .foregroundStyle(Theme.columnInk(1))
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16 * s)
                    .padding(.vertical, 10 * s)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(1)))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.leading, 80 * s)
                }
            }
            if revealed < rolePlay.tasks.count {
                Button {
                    onNext()
                } label: {
                    Label("Taispeáin an chéad fhreagra eile · show the next answer", systemImage: "eye")
                        .font(.system(size: 22 * s, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
            }
        }
    }
}

/// Dul siar: the unit's questions, numbered, to answer aloud.
struct DulSiarSlide: View {
    let unit: BuilderUnit
    let showEnglish: Bool

    var body: some View {
        SlidePage { s in
            SlideHeading(text: "Dul siar", scale: s)
            if showEnglish {
                Text("Revision: answer each question aloud.")
                    .font(.system(size: 24 * s))
                    .foregroundStyle(Theme.muted)
            }
            ForEach(Array(unit.questions.enumerated()), id: \.offset) { i, q in
                Button {
                    Speaker.shared.play(q.audio)
                } label: {
                    Text("\(i + 1). \(q.ga)")
                        .font(.system(size: 36 * s, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                        .multilineTextAlignment(.leading)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// The closing slide: bookends the title, with the learning intentions as things the class can now do.
struct EndSlide: View {
    let unit: BuilderUnit
    let showEnglish: Bool
    let onClose: () -> Void

    var body: some View {
        SlidePage { s in
            HStack(spacing: 20 * s) {
                Text(unit.emoji).font(.system(size: 90 * s)).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 4) {
                    Text(unit.title).font(.system(size: 56 * s, weight: .bold))
                    if showEnglish {
                        Text(unit.en).font(.system(size: 28 * s)).foregroundStyle(Theme.muted)
                    }
                }
            }
            if let sprioc = unit.sprioc, !sprioc.isEmpty {
                SlideHeading(text: "Anois is féidir liom ...", scale: s)
                ForEach(Array(sprioc.enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("✓ " + EndSlide.trimmed(item.ga, "Tá mé ag foghlaim "))
                            .font(.system(size: 30 * s, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        if showEnglish {
                            Text(EndSlide.trimmed(item.en, "I am learning "))
                                .font(.system(size: 22 * s))
                                .foregroundStyle(Theme.muted)
                        }
                    }
                }
            }
            SlideHeading(text: "Seanfhocal", scale: s)
            VStack(alignment: .leading, spacing: 2) {
                Text(Seanfhocal.forID(unit.id).ga)
                    .font(.system(size: 26 * s, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                if showEnglish {
                    Text(Seanfhocal.forID(unit.id).en)
                        .font(.system(size: 22 * s))
                        .foregroundStyle(Theme.muted)
                }
            }
            Button {
                onClose()
            } label: {
                Label("Na sleamhnáin eile · other slides", systemImage: "square.grid.2x2")
                    .font(.system(size: 22 * s, weight: .bold))
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.ink)
        }
    }

    private static func trimmed(_ text: String, _ prefix: String) -> String {
        text.hasPrefix(prefix) ? String(text.dropFirst(prefix.count)) : text
    }
}

/// The system AirPlay button, for sending Áine's audio to a TV or speaker.
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = false
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
