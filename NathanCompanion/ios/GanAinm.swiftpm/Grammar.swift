import Foundation
import Combine

// MARK: - Grammar content, decoded from Resources/grammar.json (AS and A2, from the grammar PDF)

struct GrammarData: Codable {
    let groups: [GrammarGroup]
    let sections: [String: GrammarSection]
}

struct GrammarGroup: Codable, Hashable {
    let ga: String
    let en: String
    let emoji: String
    let sections: [String]
}

struct GrammarRule: Codable, Hashable {
    let point: String
    let text: String
}

struct GrammarTable: Codable, Hashable {
    let title: String
    let forms: [String]
}

struct GrammarModel: Codable, Hashable {
    let ga: String
    let cue: String
    let point: String
}

struct GrammarItem: Codable, Hashable {
    let shape: String
    let prompt: String
    let answer: String
    let point: String
    /// For gap items: just the missing word or words.
    let gap: String?
    /// Open questions with many right answers: the pupil compares with the model and marks it.
    let selfMarked: Bool?

    enum CodingKeys: String, CodingKey {
        case shape, prompt, answer, point, gap
        case selfMarked = "self"
    }

    var isSelfMarked: Bool { selfMarked ?? false }

    /// A stable key for spacing, the same on every launch.
    var key: String {
        var h: UInt64 = 5381
        for u in answer.unicodeScalars { h = (h &* 33) &+ UInt64(u.value) }
        return "g:" + String(h, radix: 36)
    }

    var task: (ga: String, en: String) {
        switch shape {
        case "gap": return ("Líon an bhearna.", gap == nil ? "Fill the gap." : "Fill the gap. Type only the missing word or words.")
        case "transform": return ("Athscríobh de réir an phatrúin.", "Rewrite it following the pattern.")
        case "question": return ("Cum ceist a fhreagraíonn é seo.", "Write a question that this answers.")
        case "free": return ("Freagair an cheist.", "Answer the question.")
        default: return ("Scríobh an abairt iomlán i gceart.", "Write out the whole sentence correctly.")
        }
    }
}

struct GrammarSection: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let en: String
    let rules: [GrammarRule]
    let tables: [GrammarTable]
    let models: [GrammarModel]
    let items: [GrammarItem]
}

enum GrammarLoader {
    static func load() -> GrammarData? {
        guard let url = Bundle.main.url(forResource: "grammar", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(GrammarData.self, from: data)
    }
}

// MARK: - Marking for grammar answers

extension Mark {
    /// Present and future first person plural: the synthetic and analytic forms are both right
    /// (cuirimid = cuireann muid, ceannóimid = ceannóidh muid). Both are turned into the analytic form before comparing.
    static let toggle: [(String, String)] = [
        ("aímid", "aíonn"), ("ímid", "íonn"), ("óimid", "óidh"), ("eoimid", "eoidh"),
        ("fimid", "fidh"), ("faimid", "faidh"), ("aimid", "ann"), ("imid", "eann")
    ]

    static func canon(_ s: String) -> String {
        norm(s).split(separator: " ").map { word -> String in
            let w = String(word)
            for (synthetic, analytic) in toggle where w.count > synthetic.count + 1 && w.hasSuffix(synthetic) {
                return String(w.dropLast(synthetic.count)) + analytic + " muid"
            }
            return w
        }.joined(separator: " ")
    }

    static func grammarCompare(_ typed: String, _ target: String) -> Verdict {
        let a = canon(typed), b = canon(target)
        if a == b { return Verdict(ok: true, fadaSlip: false) }
        if fold(a) == fold(b) { return Verdict(ok: true, fadaSlip: true) }
        return Verdict(ok: false, fadaSlip: false)
    }

    static func grammarMissing(typed: String, target: String) -> [String] {
        let have = Set(canon(typed).split(separator: " ").map { fold(String($0)) })
        return canon(target).split(separator: " ").map(String.init).filter { !have.contains(fold($0)) }
    }
}

// MARK: - One grammar session: Patrún, Riail, Cleachtadh, then results

struct GrammarOutcome {
    var ok: Bool
    var fadaSlip = false
    /// True while an open question waits for the pupil to mark it against the model.
    var awaitingSelfMark = false
    var selfMarked = false
}

struct GrammarLogEntry: Identifiable {
    let id = UUID()
    var ok: Bool
    let answer: String
}

final class GrammarSession: ObservableObject, Identifiable {
    let id = UUID()
    let section: GrammarSection
    let store: Store

    static let steps: [(ga: String, en: String)] = [("Patrún", "Pattern"), ("Riail", "Rule"), ("Cleachtadh", "Practice")]

    /// 0 pattern, 1 rule, 2 practice, 3 results.
    @Published private(set) var step = 0
    @Published private(set) var models: [GrammarModel] = []
    @Published private(set) var items: [GrammarItem] = []
    @Published private(set) var index = 0
    @Published var typed = ""
    @Published private(set) var outcome: GrammarOutcome?
    @Published private(set) var log: [GrammarLogEntry] = []

    init(section: GrammarSection, store: Store) {
        self.section = section
        self.store = store
        plan()
    }

    var item: GrammarItem? { items.indices.contains(index) ? items[index] : nil }
    var isLastItem: Bool { index + 1 >= items.count }

    /// Patrún shows one grammar point, so there is one pattern to notice; practice leads on that point, then the weakest items.
    private func plan() {
        let now = Date()
        let pool = section.items.shuffled().sorted { a, b in
            let ca = store.card(a.key), cb = store.card(b.key)
            let da = ca.due <= now ? 0 : 1, db = cb.due <= now ? 0 : 1
            if da != db { return da < db }
            return ca.box < cb.box
        }
        var byPoint: [String: [GrammarModel]] = [:]
        for m in section.models { byPoint[m.point, default: []].append(m) }
        let points = byPoint.keys.filter { (byPoint[$0]?.count ?? 0) >= 3 }
        if let focus = points.randomElement(), let chosen = byPoint[focus] {
            models = Array(chosen.shuffled().prefix(6))
            let lead = Array(pool.filter { $0.point == focus }.prefix(4))
            items = Array((lead + pool.filter { !lead.contains($0) }).prefix(8))
        } else {
            models = Array(section.models.shuffled().prefix(6))
            items = Array(pool.prefix(8))
        }
        step = 0
        index = 0
        typed = ""
        outcome = nil
        log = []
    }

    func restart() { plan() }

    func nextStep() {
        if step == 1 && items.isEmpty { step = 3 } else { step += 1 }
        index = 0
        typed = ""
        outcome = nil
    }

    func backToPattern() { step = 0 }

    func check(skip: Bool = false) {
        guard outcome == nil, let it = item else { return }
        if skip { typed = "" }
        let answer = typed.trimmingCharacters(in: .whitespacesAndNewlines)
        if it.isSelfMarked {
            if answer.isEmpty {
                outcome = GrammarOutcome(ok: false, selfMarked: true)
                record(false)
            } else {
                outcome = GrammarOutcome(ok: false, awaitingSelfMark: true)
            }
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

    /// The pupil marks an open question against the model answer.
    func selfMark(_ ok: Bool) {
        guard outcome?.awaitingSelfMark == true else { return }
        outcome = GrammarOutcome(ok: ok, selfMarked: true)
        record(ok)
    }

    /// "My version is right too": the pupil overrides a wrong mark.
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
        if !isLastItem {
            index += 1
            typed = ""
            outcome = nil
        } else {
            step = 3
        }
    }

    var missing: [String] {
        guard let it = item, !it.isSelfMarked, !typed.isEmpty else { return [] }
        return Mark.grammarMissing(typed: typed, target: it.answer)
    }

    var score: (right: Int, total: Int) { (log.filter { $0.ok }.count, log.count) }
}
