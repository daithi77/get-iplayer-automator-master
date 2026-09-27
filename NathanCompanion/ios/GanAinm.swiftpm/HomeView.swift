import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: Store
    @State private var active: Session?
    @State private var showIntro = false
    @AppStorage("abair-leat.seenIntro") private var seenIntro = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Dia duit!")
                        .font(Pen.font(44))
                        .foregroundStyle(Theme.pen)
                        .rotationEffect(.degrees(-2))
                        .accessibilityAddTraits(.isHeader)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Éist, aithin, tóg agus cuimhnigh. Cúpla bomaite san oíche.")
                            .font(.title3)
                        Text("Listen, recognise, build and remember. A few minutes a night.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    if let error = store.loadError {
                        PenNote(text: "Níor lódáladh na sonraí", detail: error)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 12)], spacing: 12) {
                        ForEach(Array(store.units.enumerated()), id: \.element.id) { i, unit in
                            Button {
                                active = Session(unit: unit, store: store)
                                active?.autoPlay()
                            } label: {
                                UnitCard(number: i + 1, unit: unit,
                                         progress: store.progress(unit),
                                         runs: store.runCount(unit.id))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    if !store.gcse.isEmpty {
                        NavigationLink {
                            GCSEHome(track: .gcse)
                        } label: {
                            HStack(spacing: 14) {
                                Text("🎓").font(.system(size: 34)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("GCSE · Bliain 11").font(.headline)
                                    Text("For pupils starting GCSE: \(store.gcse.count) units with the examiner's questions, sentences to build, a better-answer ladder and role plays.")
                                        .font(.subheadline)
                                        .opacity(0.85)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right").accessibilityHidden(true)
                            }
                            .foregroundStyle(Theme.columnInk(0))
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(0)))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    if !store.comhra.isEmpty {
                        NavigationLink {
                            ComhraHome()
                        } label: {
                            HStack(spacing: 14) {
                                Text("💬").font(.system(size: 34)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Comhrá · AS").font(.headline)
                                    Text("The speaking test conversation: \(store.pupilComhra.count) topics, examiner questions, sentence builders and your own answers.")
                                        .font(.subheadline)
                                        .opacity(0.85)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right").accessibilityHidden(true)
                            }
                            .foregroundStyle(Theme.columnInk(1))
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(1)))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    if let grammar = store.grammar {
                        NavigationLink {
                            GrammarHome(grammar: grammar)
                        } label: {
                            HStack(spacing: 14) {
                                Text("📐").font(.system(size: 34)).accessibilityHidden(true)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Gramadach · AS agus A2").font(.headline)
                                    Text("Grammar for Years 13 and 14: rule, worked example, practice. 32 sections.")
                                        .font(.subheadline)
                                        .opacity(0.85)
                                }
                                Spacer(minLength: 8)
                                Image(systemName: "chevron.right").accessibilityHidden(true)
                            }
                            .foregroundStyle(Theme.columnInk(3))
                            .padding(16)
                            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(3)))
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                    // The AS picture stimulus, reading and translation, and the A2 track, in the web's order.
                    Group {
                        if !store.spreag.isEmpty {
                            NavigationLink {
                                SpreagHome()
                            } label: {
                                TrackTile(emoji: "🖼️", title: "An Spreagphictiúr · AS",
                                          detail: "The picture stimulus: \(store.spreag.count) pictures, five questions each, then the examiner moves to your own life.",
                                          colour: 1)
                            }
                            .buttonStyle(.plain)
                        }
                        if !store.leamh.isEmpty {
                            NavigationLink {
                                LeamhHome()
                            } label: {
                                TrackTile(emoji: "📰", title: "Léitheoireacht agus aistriúchán",
                                          detail: "Reading and translation, AS and A2: \(store.leamh.count) passages with a glossary, questions and translation both ways.",
                                          colour: 3)
                            }
                            .buttonStyle(.plain)
                        }
                        if !store.a2.isEmpty {
                            NavigationLink {
                                GCSEHome(track: .a2)
                            } label: {
                                TrackTile(emoji: "🎓", title: UnitTrack.a2.title,
                                          detail: "Discussion and writing: \(store.a2.count) units with opinion frames, a better-answer ladder, a debate with the examiner and an essay.",
                                          colour: 0)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    Text("Dréacht le haghaidh tástála. A draft for testing. Voice: Áine, ABAIR (Trinity College Dublin). Progress stays on this device.")
                        .font(.footnote)
                        .foregroundStyle(Theme.muted)
                }
                .padding()
                .frame(maxWidth: 900)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.ground)
            .navigationTitle("Gan Ainm")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showIntro = true
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .accessibilityLabel("Faoin aip. About the app")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        TeachHome()
                    } label: {
                        Label("Don rang", systemImage: "tv")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }
            .fullScreenCover(item: $active) { session in
                SessionView(session: session)
            }
        }
        .fullScreenCover(isPresented: $showIntro) {
            IntroView {
                seenIntro = true
                showIntro = false
            }
        }
        .onAppear {
            if !seenIntro { showIntro = true }
        }
    }
}

/// A tile on the home screen that opens a track, in one of the column colours.
struct TrackTile: View {
    let emoji: String
    let title: String
    let detail: String
    let colour: Int

    var body: some View {
        HStack(spacing: 14) {
            Text(emoji).font(.system(size: 34)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(detail)
                    .font(.subheadline)
                    .opacity(0.85)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").accessibilityHidden(true)
        }
        .foregroundStyle(Theme.columnInk(colour))
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.fill(colour)))
        .contentShape(Rectangle())
    }
}

struct UnitCard: View {
    let number: Int
    let unit: BuilderUnit
    let progress: Double
    let runs: Int

    var body: some View {
        HStack(spacing: 14) {
            Text(unit.emoji)
                .font(.system(size: 40))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(number). \(unit.title)")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                Text(unit.en)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                ProgressView(value: progress)
                    .tint(Theme.good)
                    .accessibilityLabel("Progress \(Int(progress * 100)) per cent")
            }
            Spacer(minLength: 8)
            Text(runs > 0 ? "Arís" : "Tosaigh")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Theme.columnInk(0))
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.columnInk(0))
                .accessibilityHidden(true)
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Theme.rule))
        .contentShape(Rectangle())
    }
}
