import SwiftUI
import Combine

// MARK: - Walk-through lessons: one grammar point each (rule, steps, worked example, hint, practice)

struct GrammarExample: Codable, Hashable {
    let prompt: String
    let answer: String
    /// The other correct form where both exist (conditional).
    let alt: String?
}

/// "Nó · or: …" under an answer that has a second correct form.
struct AltLine: View {
    let alt: String?

    var body: some View {
        if let alt = alt {
            Text("Nó · or: \(alt)").font(.subheadline).foregroundStyle(Theme.muted)
        }
    }
}

struct GrammarLesson: Codable, Hashable {
    let title: String
    let en: String
    let rule: String
    let steps: [String]
    let example: GrammarExample
    let more: [GrammarExample]?
    let hint: String
    let items: [GrammarItem]
}

enum Highlight {
    private static func key(_ word: String) -> String {
        Mark.fold(Mark.norm(word.replacingOccurrences(of: "(", with: " ").replacingOccurrences(of: ")", with: " ")))
    }

    /// The answer with every word that is not in `from` highlighted, so the change the rule makes stands out.
    static func changes(from: String, to answer: String) -> AttributedString {
        let have = Set(from.replacingOccurrences(of: "(", with: " ").replacingOccurrences(of: ")", with: " ")
            .split(whereSeparator: { $0.isWhitespace }).map { key(String($0)) })
        var out = AttributedString()
        let words = answer.split(separator: " ", omittingEmptySubsequences: false)
        for (i, w) in words.enumerated() {
            var part = AttributedString(String(w))
            let k = key(String(w))
            if !k.isEmpty && !have.contains(k) {
                part.backgroundColor = Theme.hi
            }
            out += part
            if i < words.count - 1 { out += AttributedString(" ") }
        }
        return out
    }
}

final class LessonSession: ObservableObject, Identifiable {
    let id = UUID()
    let section: GrammarSection
    let lessonIndex: Int
    let store: Store

    /// 0 how it works, 1 your turn, 2 results.
    @Published private(set) var step = 0
    @Published private(set) var items: [GrammarItem] = []
    @Published private(set) var index = 0
    @Published var typed = ""
    @Published private(set) var outcome: GrammarOutcome?
    @Published private(set) var log: [GrammarLogEntry] = []
    @Published var showHint = false

    var lesson: GrammarLesson { section.lessons![lessonIndex] }
    var item: GrammarItem? { items.indices.contains(index) ? items[index] : nil }
    var isLastItem: Bool { index + 1 >= items.count }
    var isLastLesson: Bool { lessonIndex + 1 >= (section.lessons?.count ?? 0) }

    init(section: GrammarSection, lessonIndex: Int, store: Store) {
        self.section = section
        self.lessonIndex = lessonIndex
        self.store = store
        plan()
    }

    private func plan() {
        let now = Date()
        items = Array(lesson.items.shuffled().sorted { a, b in
            let ca = store.card(a.key), cb = store.card(b.key)
            let da = ca.due <= now ? 0 : 1, db = cb.due <= now ? 0 : 1
            if da != db { return da < db }
            return ca.box < cb.box
        }.prefix(8))
        step = 0
        index = 0
        typed = ""
        outcome = nil
        log = []
        showHint = false
    }

    func restart() { plan() }
    func start() { step = 1; index = 0; typed = ""; outcome = nil; showHint = false }

    func check(skip: Bool = false) {
        guard outcome == nil, let it = item else { return }
        if skip { typed = "" }
        let answer = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        if it.isSelfMarked {
            if answer.isEmpty { outcome = GrammarOutcome(ok: false, selfMarked: true); record(false) }
            else { outcome = GrammarOutcome(ok: false, awaitingSelfMark: true) }
            return
        }
        var verdict = Mark.Verdict(ok: false, fadaSlip: false)
        if !answer.isEmpty {
            verdict = Mark.grammarCompare(answer, it.answer)
            if !verdict.ok, let gap = it.gap {
                let g = Mark.grammarCompare(answer, gap)
                if g.ok { verdict = g }
            }
        }
        outcome = GrammarOutcome(ok: verdict.ok, fadaSlip: verdict.fadaSlip)
        record(verdict.ok)
    }

    func selfMark(_ ok: Bool) {
        guard outcome?.awaitingSelfMark == true else { return }
        outcome = GrammarOutcome(ok: ok, selfMarked: true)
        record(ok)
    }

    func acceptMine() {
        guard let o = outcome, !o.ok, let it = item, !log.isEmpty else { return }
        log[log.count - 1].ok = true
        store.record(it.key, ok: true)
        outcome = GrammarOutcome(ok: true, selfMarked: true)
    }

    private func record(_ ok: Bool) {
        guard let it = item else { return }
        log.append(GrammarLogEntry(ok: ok, answer: it.answer))
        store.record(it.key, ok: ok)
    }

    func next() {
        if !isLastItem { index += 1; typed = ""; outcome = nil; showHint = false } else { step = 2 }
    }

    var score: (right: Int, total: Int) { (log.filter { $0.ok }.count, log.count) }
}

// MARK: - The lessons of one section

struct LessonList: View {
    @EnvironmentObject private var store: Store
    let section: GrammarSection
    @State private var active: LessonSession?
    /// The lesson to open once the current one has finished closing.
    @State private var pendingNext: Int?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DraftBanner()
                let lessons = section.lessons ?? []
                Text("\(lessons.count) ceacht. \(lessons.count) lessons: work through them in order.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(lessons.enumerated()), id: \.offset) { i, lesson in
                    Button {
                        active = LessonSession(section: section, lessonIndex: i, store: store)
                    } label: {
                        HStack(spacing: 12) {
                            Text("\(i + 1)")
                                .font(.headline)
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(Theme.fill(0)))
                                .foregroundStyle(Theme.columnInk(0))
                            VStack(alignment: .leading, spacing: 3) {
                                Text(lesson.title).font(.headline).foregroundStyle(Theme.ink)
                                Text(lesson.en).font(.subheadline).foregroundStyle(Theme.muted)
                                ProgressView(value: progress(lesson)).tint(Theme.good)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(0)).accessibilityHidden(true)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                if !section.tables.isEmpty {
                    Text("Táblaí · tables for reference")
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted).padding(.top, 8)
                    ForEach(Array(section.tables.enumerated()), id: \.offset) { _, table in
                        GrammarTableRow(table: table)
                    }
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $active, onDismiss: openPending) { session in
            LessonSessionView(session: session) { next in
                pendingNext = next
                active = nil
            }
        }
    }

    /// Runs once the closing cover has fully gone, so the next lesson is not presented mid-dismissal.
    private func openPending() {
        guard let next = pendingNext else { return }
        pendingNext = nil
        guard next < (section.lessons?.count ?? 0) else { return }
        active = LessonSession(section: section, lessonIndex: next, store: store)
    }

    private func progress(_ lesson: GrammarLesson) -> Double {
        guard !lesson.items.isEmpty else { return 0 }
        return Double(lesson.items.filter { store.card($0.key).box >= 2 }.count) / Double(lesson.items.count)
    }
}

// MARK: - One lesson: how it works, your turn, results

struct LessonSessionView: View {
    @ObservedObject var session: LessonSession
    /// Called on close; carries the next lesson's index when the pupil chooses to go on.
    let onClose: (Int?) -> Void
    @FocusState private var typing: Bool

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Color.clear.frame(height: 0).id("top")
                        DraftBanner()
                        if session.step < 2 { header }
                        switch session.step {
                        case 0: howItWorks
                        case 1: practice
                        default: results
                        }
                    }
                    .padding()
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: session.step) { _, _ in proxy.scrollTo("top", anchor: .top) }
                .onChange(of: session.index) { _, _ in
                    proxy.scrollTo("top", anchor: .top)
                    typing = true
                }
                .onChange(of: session.outcome != nil) { _, answered in
                    if answered { withAnimation { proxy.scrollTo("feedback", anchor: .center) } }
                }
            }
            .background(Theme.ground)
            .safeAreaInset(edge: .bottom) { actionBar }
            .navigationTitle(session.lesson.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Druid") { onClose(nil) }
                        .accessibilityLabel("Druid. Close")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<2, id: \.self) { i in
                    Capsule()
                        .fill(i < session.step ? Theme.good : (i == session.step ? Theme.columnInk(0) : Theme.rule))
                        .frame(height: 6)
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text(session.step == 0 ? "An dóigh a n-oibríonn sé" : "Anois tusa").font(.title2.weight(.bold))
                Spacer()
                Text("\(session.step == 0 ? "How it works" : "Your turn") · \(session.step + 1) / 2")
                    .font(.subheadline).foregroundStyle(Theme.muted)
            }
        }
        .accessibilityElement(children: .combine)
    }

    private func worked(_ ex: GrammarExample) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ex.prompt).font(.body)
            Image(systemName: "arrow.down").font(.footnote).accessibilityHidden(true)
            Text(Highlight.changes(from: ex.prompt, to: ex.answer))
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.ink)
            AltLine(alt: ex.alt)
        }
        .foregroundStyle(Theme.columnInk(1))
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(1)))
    }

    private var howItWorks: some View {
        let l = session.lesson
        return Panel {
            Text("Ceacht \(session.lessonIndex + 1) · \(l.title)")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            Text(l.rule).font(.title3.weight(.bold))
            Text("An dóigh a ndéantar é · step by step")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(l.steps.enumerated()), id: \.offset) { i, s in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("\(i + 1).").font(.body.weight(.bold))
                        Text(s)
                    }
                }
            }
            worked(l.example)
            if let more = l.more, !more.isEmpty {
                Text("Tuilleadh samplaí · more examples")
                    .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                ForEach(Array(more.enumerated()), id: \.offset) { _, ex in worked(ex) }
            }
        }
    }

    @ViewBuilder private var practice: some View {
        if let it = session.item {
            Panel {
                Text("\(session.index + 1) / \(session.items.count) · \(session.lesson.title)")
                    .font(.caption.weight(.bold)).foregroundStyle(Theme.muted)
                Text(it.task.ga).font(.title2.weight(.bold))
                Text(it.task.en).foregroundStyle(Theme.muted)
                Text(it.prompt)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.columnInk(0))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(0)))
                TextField("Scríobh anseo", text: $session.typed)
                    .font(.title3)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .focused($typing)
                    .submitLabel(.done)
                    .onSubmit { session.check() }
                    .disabled(session.outcome != nil)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(fieldColour, lineWidth: 2))
                    .onAppear { typing = true }
                if session.outcome == nil {
                    if session.showHint {
                        Text("Leid · hint: \(session.lesson.hint)")
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle(Theme.columnInk(2))
                            .background(RoundedRectangle(cornerRadius: 12).fill(Theme.fill(2)))
                    } else {
                        Button("Leid · show a hint") { session.showHint = true }
                            .font(.subheadline)
                    }
                    HStack(spacing: 8) {
                        ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { letter in
                            Button(letter) { session.typed += letter }
                                .font(.title3.weight(.semibold))
                                .frame(minWidth: 44, minHeight: 44)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(letter) le fada")
                        }
                    }
                }
                feedback(it)
            }
        }
    }

    private var fieldColour: Color {
        guard let o = session.outcome, !o.awaitingSelfMark else { return Theme.ink }
        return o.ok ? Theme.good : Theme.pen
    }

    @ViewBuilder private func feedback(_ it: GrammarItem) -> some View {
        if let o = session.outcome {
            VStack(alignment: .leading, spacing: 8) {
                if o.awaitingSelfMark {
                    Text("Freagra samplach · a model answer").font(.subheadline).foregroundStyle(Theme.muted)
                    Text(it.answer).font(.title3.weight(.bold))
                    Text("An raibh do fhreagra ceart? Was your answer right?").font(.subheadline).foregroundStyle(Theme.muted)
                    HStack(spacing: 10) {
                        Button("Bhí") { session.selfMark(true) }.buttonStyle(.borderedProminent).tint(Theme.good)
                        Button("Ní raibh") { session.selfMark(false) }.buttonStyle(.bordered)
                    }
                } else if o.ok {
                    Text(o.fadaSlip ? "✓ seiceáil na fadaí" : (o.selfMarked ? "✓" : "✓ ceart!"))
                        .font(Pen.font(30)).foregroundStyle(Theme.pen)
                    Text(Highlight.changes(from: it.prompt, to: it.answer)).font(.title3.weight(.bold))
                    AltLine(alt: it.alt)
                } else {
                    Text("✗").font(Pen.font(30)).foregroundStyle(Theme.pen)
                    let typedSomething = !session.typed.isEmpty && !it.isSelfMarked
                    Text(typedSomething ? "An freagra ceart · the right answer (the highlighted words differ from yours)" : "An freagra ceart · the right answer")
                        .font(.subheadline).foregroundStyle(Theme.muted)
                    Text(Highlight.changes(from: typedSomething ? session.typed : it.prompt, to: it.answer))
                        .font(.title3.weight(.bold))
                    AltLine(alt: it.alt)
                    Text("Riail · rule: \(session.lesson.rule)").font(.subheadline).foregroundStyle(Theme.muted)
                    if !o.selfMarked && !session.typed.isEmpty {
                        Button("Tá mo leagan ceart freisin · my version is right too") { session.acceptMine() }
                            .font(.subheadline)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
            .id("feedback")
        }
    }

    private var results: some View {
        let score = session.score
        let share = score.total > 0 ? Double(score.right) / Double(score.total) : 0
        return Panel {
            VStack(spacing: 6) {
                Text(share >= 0.8 ? "🌟" : (share >= 0.5 ? "👍" : "💪")).font(.system(size: 64)).accessibilityHidden(true)
                Text("\(score.right) / \(score.total)").font(.largeTitle.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            ForEach(session.log) { entry in
                HStack(alignment: .top, spacing: 10) {
                    Text(entry.ok ? "✓" : "✗").font(Pen.font(26)).foregroundStyle(Theme.pen).frame(width: 24)
                    Text(entry.answer)
                }
                .accessibilityElement(children: .combine)
                Divider()
            }
        }
    }

    private var actionBar: some View {
        HStack {
            switch session.step {
            case 0:
                Button("Na ceachtanna") { onClose(nil) }.buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary("Anois tusa") { session.start() }
            case 1:
                if let o = session.outcome {
                    if !o.awaitingSelfMark {
                        Spacer()
                        primary(session.isLastItem ? "Críochnaigh" : "Ar aghaidh") { session.next() }
                    }
                } else {
                    Button("Níl a fhios agam") { session.check(skip: true) }.foregroundStyle(Theme.muted)
                    Spacer()
                    primary("Seiceáil") { session.check() }
                }
            default:
                Button("Arís") { session.restart() }.buttonStyle(.bordered).controlSize(.large)
                Spacer()
                if session.isLastLesson {
                    primary("Na ceachtanna") { onClose(nil) }
                } else {
                    primary("An chéad cheacht eile") { onClose(session.lessonIndex + 1) }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func primary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).padding(.horizontal, 8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Theme.ink)
    }
}
