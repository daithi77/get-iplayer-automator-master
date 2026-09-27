import SwiftUI

// MARK: - Comhrá AS: the speaking-test conversation.
// Topics with the examiner's question chain, model answers, sentence practice (the Year 8 engine, silent for now)
// and the pupil's own answers, practised from memory.

struct ComhraHome: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DraftBanner()
                Text("Achan topaic: ceisteanna an scrúdaitheora, freagraí samplacha, abairtí le tógáil agus d'fhreagraí féin. Each topic: the examiner's questions, model answers, sentences to build, and your own answers.")
                    .foregroundStyle(Theme.muted)
                ForEach(store.comhra) { unit in
                    NavigationLink {
                        ComhraTopic(unit: unit)
                    } label: {
                        HStack(spacing: 12) {
                            Text("💬").font(.system(size: 30)).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text(unit.title).font(.headline).foregroundStyle(Theme.ink)
                                    if unit.isNew ?? false {
                                        Text("nua · new")
                                            .font(.caption.weight(.bold))
                                            .padding(.horizontal, 8).padding(.vertical, 2)
                                            .background(Capsule().fill(Theme.fill(2)))
                                            .foregroundStyle(Theme.columnInk(2))
                                    }
                                }
                                let done = unit.questions.filter { !store.ownAnswer($0.ga).isEmpty }.count
                                Text("\(unit.en) · \(unit.questions.count) ceist · \(done)/\(unit.questions.count) freagra féin")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(1)).accessibilityHidden(true)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Comhrá · AS")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One link card: a title, a line of detail, and sentences showing the grammar in use.
struct LinkCard: View {
    let title: String
    let detail: String
    let examples: [String]

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline).foregroundStyle(Theme.ink)
                Text(detail).font(.subheadline).foregroundStyle(Theme.muted)
                ForEach(Array(examples.enumerated()), id: \.offset) { _, e in
                    Text(e).font(.subheadline).italic().foregroundStyle(Theme.ink)
                }
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(0)).accessibilityHidden(true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.ground))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
        .contentShape(Rectangle())
    }
}

struct ComhraTopic: View {
    @EnvironmentObject private var store: Store
    let unit: BuilderUnit
    @State private var active: Session?
    @State private var recall = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                DraftBanner()
                if unit.isNew ?? false {
                    Text("Topaic nua, le ceadú. A new topic, awaiting approval.")
                        .font(.footnote)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.fill(2)))
                        .foregroundStyle(Theme.columnInk(2))
                }
                Panel {
                    Text("Ceisteanna an scrúdaitheora · the examiner's questions")
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                    ForEach(Array(unit.questions.enumerated()), id: \.offset) { i, q in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(i + 1).").font(.headline)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(q.ga).font(.headline)
                                Text(i == 0 ? "An phríomhcheist · the main question" : "Ceist leantach · a follow-up")
                                    .font(.caption).foregroundStyle(Theme.muted)
                            }
                        }
                    }
                }
                if let links = unit.grammar, !links.isEmpty, let grammar = store.grammar {
                    Panel {
                        Text("Gramadach an topaic seo · the grammar this topic uses")
                            .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                        ForEach(Array(links.enumerated()), id: \.offset) { _, link in
                            if let section = grammar.sections[link.id], section.hasLessons {
                                NavigationLink {
                                    LessonList(section: section, recommended: link.lesson)
                                } label: {
                                    LinkCard(title: link.title,
                                             detail: link.lessonTitle.map { "\(link.whyEn) · ceacht: \($0)" } ?? link.whyEn,
                                             examples: link.examples)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                Panel {
                    Text("Freagraí samplacha · model answers")
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                    ForEach(Array(unit.examples.enumerated()), id: \.offset) { i, e in
                        ExampleRow(title: "Freagra samplach \(i + 1)", text: e.ga, startOpen: i == 0)
                    }
                }
                actionRow("🧱", "Cleachtadh na n-abairtí", "Practise the sentences: read, recognise, build, recall") {
                    active = Session(unit: unit, store: store)
                }
                NavigationLink {
                    OwnAnswers(unit: unit)
                } label: {
                    actionLabel("✍️", "M'fhreagra féin", "Write your own answer to each question, then learn it")
                }
                .buttonStyle(.plain)
                NavigationLink {
                    TeachDeck(unit: unit)
                } label: {
                    Label("Don rang · slides for this topic", systemImage: "tv")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $active) { session in
            SessionView(session: session)
        }
    }

    private func actionRow(_ emoji: String, _ ga: String, _ en: String, action: @escaping () -> Void) -> some View {
        Button(action: action) { actionLabel(emoji, ga, en) }
            .buttonStyle(.plain)
    }

    private func actionLabel(_ emoji: String, _ ga: String, _ en: String) -> some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 30)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(ga).font(.headline).foregroundStyle(Theme.ink)
                Text(en).font(.subheadline).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(1)).accessibilityHidden(true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
        .contentShape(Rectangle())
    }
}

struct ExampleRow: View {
    let title: String
    let text: String
    @State private var open: Bool

    init(title: String, text: String, startOpen: Bool) {
        self.title = title
        self.text = text
        _open = State(initialValue: startOpen)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            Text(text).frame(maxWidth: .infinity, alignment: .leading).padding(.bottom, 6)
        } label: {
            Text(title).font(.headline).foregroundStyle(Theme.ink)
        }
        .tint(Theme.columnInk(0))
    }
}

/// The pupil writes an answer to each question; saved on the device.
struct OwnAnswers: View {
    @EnvironmentObject private var store: Store
    let unit: BuilderUnit
    @State private var recalling: RecallRun?

    var body: some View {
        let written = unit.questions.filter { !store.ownAnswer($0.ga).isEmpty }
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                DraftBanner()
                Text("Scríobh freagra fút féin ar achan cheist. Úsáid na habairtí ón topaic. Write an answer about yourself to each question, using the sentences from this topic. It is saved on this device.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(unit.questions.enumerated()), id: \.offset) { i, q in
                    Panel {
                        Text("\(i + 1) / \(unit.questions.count)").font(.caption.weight(.bold)).foregroundStyle(Theme.muted)
                        Text(q.ga).font(.headline)
                        TextEditor(text: Binding(
                            get: { store.ownAnswer(q.ga) },
                            set: { store.setOwnAnswer(q.ga, $0) }))
                            .frame(minHeight: 120)
                            .textInputAutocapitalization(.sentences)
                            .autocorrectionDisabled()
                            .padding(6)
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
                    }
                }
                Button {
                    recalling = RecallRun(unit: unit, store: store)
                } label: {
                    Text("Cleachtaigh ó chuimhne · practise from memory").font(.headline).frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
                .controlSize(.large)
                .disabled(written.isEmpty)
                Text("\(written.count) of \(unit.questions.count) answers written.")
                    .font(.footnote).foregroundStyle(Theme.muted)
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("M'fhreagra féin")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $recalling) { run in
            RecallView(run: run)
        }
    }
}

/// One pass of recalling own answers from memory, due and weakest first.
final class RecallRun: ObservableObject, Identifiable {
    let id = UUID()
    let unit: BuilderUnit
    let store: Store
    let questions: [UnitQuestion]
    @Published var index = 0
    @Published var typed = ""
    @Published var revealed = false
    @Published var log: [Bool] = []

    init(unit: BuilderUnit, store: Store) {
        self.unit = unit
        self.store = store
        let now = Date()
        questions = unit.questions.filter { !store.ownAnswer($0.ga).isEmpty }.shuffled().sorted { a, b in
            let ca = store.card(RecallRun.key(a.ga)), cb = store.card(RecallRun.key(b.ga))
            let da = ca.due <= now ? 0 : 1, db = cb.due <= now ? 0 : 1
            if da != db { return da < db }
            return ca.box < cb.box
        }
    }

    static func key(_ question: String) -> String { "o:" + question }

    var done: Bool { index >= questions.count }

    func mark(_ ok: Bool) {
        guard !done else { return }
        store.record(RecallRun.key(questions[index].ga), ok: ok)
        log.append(ok)
        index += 1
        typed = ""
        revealed = false
    }
}

struct RecallView: View {
    @ObservedObject var run: RecallRun
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if run.done {
                        let ok = run.log.filter { $0 }.count
                        let share: Double = run.log.isEmpty ? 1 : Double(ok) / Double(run.log.count)
                        Panel {
                            Text(share >= 0.8 ? "🌟" : (share >= 0.5 ? "👍" : "💪"))
                                .font(.system(size: 64)).frame(maxWidth: .infinity).accessibilityHidden(true)
                            Text("\(ok) / \(run.log.count)").font(.largeTitle.weight(.bold)).frame(maxWidth: .infinity)
                            Text("Answers you found hard come back sooner.").foregroundStyle(Theme.muted).frame(maxWidth: .infinity)
                        }
                    } else {
                        let q = run.questions[run.index]
                        let mine = run.store.ownAnswer(q.ga)
                        Panel {
                            Text("\(run.index + 1) / \(run.questions.count) · ceist an scrúdaitheora")
                                .font(.caption.weight(.bold)).foregroundStyle(Theme.muted)
                            Text(q.ga).font(.title3.weight(.bold))
                            Text("Freagair ó chuimhne, gan amharc ar do fhreagra. Answer from memory, without looking.")
                                .foregroundStyle(Theme.muted)
                            TextEditor(text: $run.typed)
                                .frame(minHeight: 120)
                                .textInputAutocapitalization(.sentences)
                                .autocorrectionDisabled()
                                .padding(6)
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.ink, lineWidth: 2))
                                .disabled(run.revealed)
                            if run.revealed {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(run.typed.isEmpty ? "D'fhreagra féin · your own answer" : "D'fhreagra féin · your own answer (highlighted words were missing or different)")
                                        .font(.subheadline).foregroundStyle(Theme.muted)
                                    Text(run.typed.isEmpty ? AttributedString(mine) : Highlight.changes(from: run.typed, to: mine))
                                        .font(.headline)
                                    Text("An raibh sé agat? Did you have it?").font(.subheadline).foregroundStyle(Theme.muted)
                                    HStack(spacing: 10) {
                                        Button("Bhí") { run.mark(true) }.buttonStyle(.borderedProminent).tint(Theme.good)
                                        Button("Ní raibh go fóill") { run.mark(false) }.buttonStyle(.bordered)
                                    }
                                }
                                .padding(14)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.penWash))
                            }
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
            .background(Theme.ground)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    if run.done {
                        Spacer()
                        Button("Críochnaigh") { dismiss() }.buttonStyle(.borderedProminent).tint(Theme.ink).controlSize(.large)
                    } else if !run.revealed {
                        Button("Níl a fhios agam") { run.revealed = true }.foregroundStyle(Theme.muted)
                        Spacer()
                        Button("Seiceáil") { run.revealed = true }.buttonStyle(.borderedProminent).tint(Theme.ink).controlSize(.large)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(.bar)
            }
            .navigationTitle("Ó chuimhne")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Druid") { dismiss() }.accessibilityLabel("Druid. Close")
                }
            }
        }
    }
}

/// The conversation topics in Don rang.
struct ComhraDeckList: View {
    let units: [BuilderUnit]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Comhrá · AS · conversation slides")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted).padding(.top, 8)
            ForEach(units) { unit in
                NavigationLink {
                    TeachDeck(unit: unit)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(unit.title).font(.headline).foregroundStyle(Theme.ink)
                            Text(unit.en).font(.subheadline).foregroundStyle(Theme.muted)
                        }
                        Spacer()
                        Image(systemName: "play.rectangle.fill").font(.title2).foregroundStyle(Theme.columnInk(1))
                    }
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
