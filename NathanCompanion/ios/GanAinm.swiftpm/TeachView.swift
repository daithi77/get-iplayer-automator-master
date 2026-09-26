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
                            HStack(spacing: 12) {
                                Text(unit.emoji).font(.system(size: 36)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(i + 1). \(unit.title)").font(.headline).foregroundStyle(Theme.ink)
                                    Text("\(unit.en) · \(unit.rows.count + 2) sleamhnán")
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
                        .buttonStyle(.plain)
                    }
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

struct TeachDeck: View {
    let unit: BuilderUnit
    @State private var page = 0
    @State private var showEnglish = true

    private var lastPage: Int { unit.rows.count + 1 }

    var body: some View {
        TabView(selection: $page) {
            TitleSlide(unit: unit, showEnglish: showEnglish)
                .tag(0)
            ForEach(Array(unit.rows.enumerated()), id: \.offset) { i, row in
                RowSlide(unit: unit, row: row, index: i, showEnglish: showEnglish)
                    .tag(i + 1)
            }
            ExamplesSlide(unit: unit, showEnglish: showEnglish)
                .tag(lastPage)
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
                .accessibilityLabel("Siar. Previous slide")
                Button {
                    withAnimation { page = min(lastPage, page + 1) }
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(page == lastPage)
                .accessibilityLabel("Ar aghaidh. Next slide")
            }
        }
        .onChange(of: page) {
            Speaker.shared.stop()
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            Speaker.shared.stop()
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
                                Text(unit.en).font(.system(size: 28 * s)).foregroundStyle(Theme.muted)
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
                                Image(systemName: "speaker.wave.2.fill")
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
                        Text("Model answers. Tap one to hear it.")
                            .font(.system(size: 24 * s))
                            .foregroundStyle(Theme.muted)
                    }
                    ForEach(unit.examples, id: \.audio) { example in
                        Button {
                            Speaker.shared.play(example.audio)
                        } label: {
                            HStack(alignment: .top, spacing: 14) {
                                Image(systemName: "speaker.wave.2.fill")
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

/// The system AirPlay button, for sending Áine's audio to a TV or speaker.
struct AirPlayButton: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let view = AVRoutePickerView()
        view.prioritizesVideoDevices = false
        return view
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {}
}
