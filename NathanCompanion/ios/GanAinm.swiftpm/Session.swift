import Foundation
import Combine

enum ItemKind {
    case hearTiles, meaning, build, type, question
}

struct Item: Identifiable {
    let id = UUID()
    let kind: ItemKind
    let row: Int
    var sentence: Sentence? = nil
    var question: UnitQuestion? = nil
    var model: String? = nil
    var combos: [String] = []
}

struct LogEntry: Identifiable {
    let id = UUID()
    let ok: Bool
    let ga: String
    let en: String
}

struct Outcome {
    let ok: Bool
    var fadaSlip = false
}

/// One six-minute session on one unit: Éist, Aithin, Tóg, Ó chuimhne, then results.
final class Session: ObservableObject, Identifiable {
    let id = UUID()
    let unit: BuilderUnit
    let store: Store

    static let steps: [(ga: String, en: String)] = [
        ("Éist", "Listen"), ("Aithin", "Recognise"), ("Tóg", "Build"), ("Ó chuimhne", "From memory")
    ]

    /// 0 listen, 1 recognise, 2 build, 3 from memory, 4 results.
    @Published private(set) var step = 0
    @Published private(set) var listenRow = 0
    @Published private(set) var index = 0
    @Published private(set) var selected: [String] = []
    @Published var typed = ""
    @Published private(set) var outcome: Outcome?
    @Published private(set) var options: [String] = []
    @Published private(set) var picked: Int?
    @Published private(set) var log: [LogEntry] = []
    /// The sentence the pupil's tiles made, when it differs from the right answer.
    @Published private(set) var ownSentence: Sentence?

    private var plan: [[Item]] = [[], [], [], []]

    init(unit: BuilderUnit, store: Store) {
        self.unit = unit
        self.store = store
        build()
    }

    var items: [Item] { (1...3).contains(step) ? plan[step] : [] }
    var item: Item? { items.indices.contains(index) ? items[index] : nil }
    var isLastItem: Bool { index + 1 >= items.count }

    // MARK: Planning

    private func build() {
        let now = Date()
        let all = unit.allSentences
        // Due sentences first, then the weakest.
        let weak = all.shuffled().sorted { a, b in
            let ca = store.card(a.sentence.audio), cb = store.card(b.sentence.audio)
            let da = ca.due <= now ? 0 : 1, db = cb.due <= now ? 0 : 1
            if da != db { return da < db }
            return ca.box < cb.box
        }
        func at(_ i: Int) -> PlacedSentence? { weak.indices.contains(i) ? weak[i] : nil }
        func make(_ kind: ItemKind, _ i: Int) -> Item? {
            guard let p = at(i) else { return nil }
            return Item(kind: kind, row: p.row, sentence: p.sentence)
        }

        let recognise = [make(.hearTiles, 0), make(.meaning, 1), make(.hearTiles, 2), make(.meaning, 3)].compactMap { $0 }
        let buildItems = [4, 5, 6, 7].compactMap { make(.build, $0) }
        var recall = [0, 2, 5].compactMap { make(.type, $0) }

        let answerable = unit.questions.filter { $0.rows != nil }
        if let q = answerable.randomElement(), let rows = q.rows, let first = rows.first {
            let combos = rows.flatMap { Mark.combos(unit.rows[$0]) }
            let model = unit.rows[first].sentences.randomElement()?.ga
            recall.append(Item(kind: .question, row: first, question: q, model: model, combos: combos))
        }

        plan = [[], recognise, buildItems, recall]
        log = []
        listenRow = 0
        index = 0
        // A returning pupil has heard the models; they start at Aithin.
        step = store.runCount(unit.id) > 0 ? 1 : 0
        prepare()
    }

    func restart() {
        Speaker.shared.stop()
        build()
        autoPlay()
    }

    private func prepare() {
        outcome = nil
        ownSentence = nil
        selected = []
        typed = ""
        picked = nil
        options = []
        if let it = item, it.kind == .meaning, let s = it.sentence {
            var seen = Set([s.en])
            var others: [String] = []
            for p in unit.allSentences.shuffled() where !seen.contains(p.sentence.en) {
                seen.insert(p.sentence.en)
                others.append(p.sentence.en)
                if others.count == 2 { break }
            }
            options = ([s.en] + others).shuffled()
        }
    }

    func autoPlay() {
        guard let it = item, let s = it.sentence, it.kind == .hearTiles || it.kind == .meaning else { return }
        let gen = Speaker.shared.generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard Speaker.shared.generation == gen else { return }
            Speaker.shared.play(s.audio)
        }
    }

    // MARK: Actions

    func nextListenRow() {
        Speaker.shared.stop()
        if listenRow + 1 < unit.rows.count {
            listenRow += 1
        } else {
            step = 1
            index = 0
            prepare()
            autoPlay()
        }
    }

    /// One tile per colour: tapping a tile picks it and drops any other in its colour; tapping it again drops it.
    func tap(_ chunk: Chunk, column: Int) {
        Speaker.shared.play(chunk.id)
        guard outcome == nil, let it = item else { return }
        selected = unit.rows[it.row].toggle(chunk.id, column: column, in: selected)
    }

    func choose(_ k: Int) {
        guard outcome == nil, let it = item, let s = it.sentence, options.indices.contains(k) else { return }
        picked = k
        let ok = options[k] == s.en
        finish(ok: ok, ga: s.ga, en: s.en, audio: s.audio)
    }

    func check() {
        guard outcome == nil, let it = item else { return }
        switch it.kind {
        case .hearTiles, .build:
            guard let s = it.sentence else { return }
            let columns = unit.rows[it.row].columns
            let order = columns.compactMap { column in column.first(where: { selected.contains($0.id) })?.id }
            let ok = order == s.chunks
            ownSentence = ok ? nil : unit.rows[it.row].sentence(picked: selected)
            finish(ok: ok, ga: s.ga, en: s.en, audio: s.audio)
            // The pupil hears the sentence they built, then the right one.
            if let own = ownSentence {
                let unit = self.unit
                Speaker.shared.playSentence(own, in: unit) {
                    let gen = Speaker.shared.generation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        guard Speaker.shared.generation == gen else { return }
                        Speaker.shared.playSentence(s, in: unit)
                    }
                }
            } else {
                Speaker.shared.playSentence(s, in: unit)
            }
        case .type:
            guard let s = it.sentence else { return }
            let v = Mark.compare(typed, s.ga)
            finish(ok: v.ok, ga: s.ga, en: s.en, audio: s.audio, fadaSlip: v.fadaSlip)
            Speaker.shared.playSentence(s, in: unit)
        case .question:
            guard let q = it.question else { return }
            let answer = Mark.fold(Mark.norm(typed))
            let ok = it.combos.contains { Mark.fold(Mark.norm($0)) == answer }
            finish(ok: ok, ga: q.ga, en: typed.isEmpty ? "…" : typed, audio: nil)
        case .meaning:
            break
        }
    }

    private func finish(ok: Bool, ga: String, en: String, audio: String?, fadaSlip: Bool = false) {
        outcome = Outcome(ok: ok, fadaSlip: fadaSlip)
        log.append(LogEntry(ok: ok, ga: ga, en: en))
        if let audio = audio { store.record(audio, ok: ok) }
    }

    func next() {
        Speaker.shared.stop()
        if !isLastItem {
            index += 1
            prepare()
            autoPlay()
        } else if step < 3 {
            step += 1
            index = 0
            prepare()
            autoPlay()
        } else {
            Speaker.shared.stop()
            store.finishRun(unit.id)
            step = 4
        }
    }

    var score: (right: Int, total: Int) { (log.filter { $0.ok }.count, log.count) }
}
