import Foundation
import SwiftUI

// MARK: - Vocabulary

enum Stage: String, CaseIterable, Identifiable {
    case ks3, gcse
    var id: String { rawValue }
    var label: String {
        switch self {
        case .ks3: return "Eochairchéim 3 (Bliain 8 go 10)"
        case .gcse: return "GCSE (Bliain 11 agus 12)"
        }
    }
}

struct VocabItem: Codable, Identifiable, Hashable {
    let id: String
    let ga: String            // headword; for a verb, the root plus any preposition
    let en: String
    let type: String          // "verb", "noun", "word"
    var prep: String? = nil   // governing preposition when written separately
    var vn: String? = nil     // verbal noun, "ag bualadh le"
    var gender: String? = nil // "m" or "f"
    let stage: String         // "ks3" or "gcse"
    let group: String         // topic (GCSE) or frequency band (KS3), in Irish
    let groupEn: String
    let context: String       // Context for Learning (GCSE) or "De réir minicíochta"
    var rank: Int? = nil
    var pos: String? = nil

    var isVerb: Bool { type == "verb" }
    var hasSecondBox: Bool { isVerb && vn != nil }

    var expectedFirst: String {
        if isVerb, let p = prep, !p.isEmpty { return "\(ga) \(p)" }
        return ga
    }

    var acceptedFirst: [String] {
        expectedFirst
            .split(whereSeparator: { $0 == "," || $0 == "/" })
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var acceptedSecond: [String] {
        guard let v = vn else { return [] }
        var out = [v]
        if let p = prep, !p.isEmpty { out.append("\(v) \(p)") }
        return out
    }

    var genderLabel: String? {
        switch gender {
        case "m": return "fir."
        case "f": return "bain."
        default: return nil
        }
    }
}

struct Question: Codable, Identifiable, Hashable {
    let id: String
    let ga: String
    let topic: String
    let context: String
}

enum Loader {
    static func load<T: Decodable>(_ name: String) -> [T] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([T].self, from: data) else {
            return []
        }
        return items
    }
}

// MARK: - Marking

enum Verdict: Equatable {
    case right
    case rightButFada(String)
    case wrong(String)

    var isWrong: Bool {
        if case .wrong = self { return true }
        return false
    }
}

enum Marker {
    static func normalise(_ s: String, strict: Bool) -> String {
        var t = s.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        t = t.replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
        t = t.replacingOccurrences(of: "[.!?]+$", with: "", options: .regularExpression)
        if !strict {
            t = t.folding(options: .diacriticInsensitive, locale: Locale(identifier: "ga"))
        }
        return t
    }

    static func mark(answer: String, accepted: [String], strictFadas: Bool) -> Verdict {
        guard let first = accepted.first else { return .right }
        let a = normalise(answer, strict: true)
        if accepted.contains(where: { normalise($0, strict: true) == a }) { return .right }
        let loose = normalise(answer, strict: false)
        if let hit = accepted.first(where: { normalise($0, strict: false) == loose }) {
            return strictFadas ? .wrong(hit) : .rightButFada(hit)
        }
        return .wrong(first)
    }
}

// MARK: - Spacing

struct ItemState: Codable {
    var box: Int = 0
    var due: Date = .distantPast
    var seen: Int = 0
    var right: Int = 0

    static let intervals: [Int] = [0, 1, 3, 7, 14, 30]
}

struct SessionResult: Identifiable {
    let id = UUID()
    let date: Date
    let answered: [(item: VocabItem, firstTry: Bool)]

    var total: Int { answered.count }
    var rightFirstTime: Int { answered.filter { $0.firstTry }.count }
    var toRevisit: [VocabItem] { answered.filter { !$0.firstTry }.map { $0.item } }
}

final class Session: ObservableObject, Identifiable {
    let id = UUID()
    let title: String
    let planned: [VocabItem]
    @Published var queue: [VocabItem]
    @Published var index: Int = 0
    private(set) var firstTry: [String: Bool] = [:]
    private(set) var attempts: [String: Int] = [:]

    init(title: String, items: [VocabItem]) {
        self.title = title
        planned = items
        queue = items
    }

    var current: VocabItem? { index < queue.count ? queue[index] : nil }
    var questionNumber: Int { min(index + 1, planned.count) }
    var totalQuestions: Int { planned.count }
    var isFinished: Bool { index >= queue.count }
    var isLastQuestion: Bool { index + 1 >= queue.count }

    func record(_ item: VocabItem, correct: Bool) {
        attempts[item.id, default: 0] += 1
        if firstTry[item.id] == nil { firstTry[item.id] = correct }
        if !correct, attempts[item.id] == 1 {
            queue.append(item)
        }
    }

    func advance() { index += 1 }

    func result() -> SessionResult {
        SessionResult(date: Date(), answered: planned.map { (item: $0, firstTry: firstTry[$0.id] ?? false) })
    }

    var marksSoFar: (right: Int, of: Int) {
        let done = planned.filter { firstTry[$0.id] != nil }
        return (done.filter { firstTry[$0.id] == true }.count, done.count)
    }
}

// MARK: - Store

struct ContextSection: Identifiable {
    let context: String
    let groups: [VocabGroup]
    var id: String { context }
}

struct VocabGroup: Identifiable {
    let name: String
    let nameEn: String
    let context: String
    let items: [VocabItem]
    var id: String { context + "|" + name }
}

final class Store: ObservableObject {
    let allItems: [VocabItem]
    let questions: [Question]

    @Published var states: [String: ItemState] { didSet { save() } }
    @Published var spokenAnswers: [String: String] { didSet { saveAnswers() } }

    @Published var stage: Stage { didSet { defaults.set(stage.rawValue, forKey: "stage") } }
    @Published var pupilName: String { didSet { defaults.set(pupilName, forKey: "pupilName") } }
    @Published var pupilClass: String { didSet { defaults.set(pupilClass, forKey: "pupilClass") } }
    @Published var strictFadas: Bool { didSet { defaults.set(strictFadas, forKey: "strictFadas") } }
    @Published var sessionSize: Int { didSet { defaults.set(sessionSize, forKey: "sessionSize") } }
    @Published var sessionsToday: Int { didSet { defaults.set(sessionsToday, forKey: "sessionsToday") } }
    @Published var lastSessionDay: String { didSet { defaults.set(lastSessionDay, forKey: "lastSessionDay") } }
    @Published var streak: Int { didSet { defaults.set(streak, forKey: "streak") } }
    @Published var lastScore: String { didSet { defaults.set(lastScore, forKey: "lastScore") } }

    private let defaults = UserDefaults.standard

    init() {
        allItems = Loader.load("vocab")
        questions = Loader.load("questions")
        let d = UserDefaults.standard
        if let data = d.data(forKey: "states"),
           let decoded = try? JSONDecoder().decode([String: ItemState].self, from: data) {
            states = decoded
        } else {
            states = [:]
        }
        if let data = d.data(forKey: "spokenAnswers"),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            spokenAnswers = decoded
        } else {
            spokenAnswers = [:]
        }
        stage = Stage(rawValue: d.string(forKey: "stage") ?? "") ?? .gcse
        pupilName = d.string(forKey: "pupilName") ?? "Dalta"
        pupilClass = d.string(forKey: "pupilClass") ?? "11"
        strictFadas = d.bool(forKey: "strictFadas")
        let size = d.integer(forKey: "sessionSize")
        sessionSize = size == 0 ? 5 : size
        sessionsToday = d.integer(forKey: "sessionsToday")
        lastSessionDay = d.string(forKey: "lastSessionDay") ?? ""
        streak = d.integer(forKey: "streak")
        lastScore = d.string(forKey: "lastScore") ?? ""
        rollDay()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(states) { defaults.set(data, forKey: "states") }
    }

    private func saveAnswers() {
        if let data = try? JSONEncoder().encode(spokenAnswers) { defaults.set(data, forKey: "spokenAnswers") }
    }

    private static func dayKey(_ d: Date = Date()) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }

    private func rollDay() {
        if lastSessionDay != Self.dayKey() { sessionsToday = 0 }
    }

    // MARK: stage-scoped views of the data

    var items: [VocabItem] { allItems.filter { $0.stage == stage.rawValue } }

    static let ks3Order = ["Na 100 focal is coitianta", "Focail 101 go 250", "Focail 251 go 500",
                           "Focail 501 go 1000", "Focail 1001 go 2000", "Thar 2000", "Nathanna coitianta"]
    static let gcseOrder = ["Mé féin, mo shaol agus mo chultúr", "Mo cheantar, an tír agus an domhan",
                            "Saol na scoile agus saol na hoibre", "Focail ghinearálta"]

    /// Groups in display order, keyed by context.
    var contexts: [ContextSection] {
        var byContext: [String: [String: [VocabItem]]] = [:]
        var enName: [String: String] = [:]
        var order: [String: [String]] = [:]
        for it in items {
            if byContext[it.context]?[it.group] == nil {
                order[it.context, default: []].append(it.group)
            }
            byContext[it.context, default: [:]][it.group, default: []].append(it)
            enName[it.group] = it.groupEn
        }
        let contextOrder = stage == .ks3 ? Array(byContext.keys) : Self.gcseOrder
        return contextOrder.compactMap { ctx in
            guard let groups = byContext[ctx] else { return nil }
            var names = order[ctx] ?? []
            if stage == .ks3 { names = Self.ks3Order.filter { groups[$0] != nil } }
            return ContextSection(context: ctx, groups: names.map { VocabGroup(name: $0, nameEn: enName[$0] ?? "", context: ctx, items: groups[$0] ?? []) })
        }
    }

    func isLearned(_ item: VocabItem) -> Bool { (states[item.id]?.box ?? 0) >= 2 }
    func isDue(_ item: VocabItem, now: Date = Date()) -> Bool { (states[item.id]?.due ?? .distantPast) <= now }
    func isSeen(_ item: VocabItem) -> Bool { states[item.id] != nil }

    var dueCount: Int { items.filter { isSeen($0) && isDue($0) }.count }
    var learnedCount: Int { items.filter { isLearned($0) }.count }
    var seenCount: Int { items.filter { isSeen($0) }.count }

    func makeSession(title: String, scope: [VocabItem]) -> Session {
        let now = Date()
        var due = scope.filter { isSeen($0) && isDue($0, now: now) }
            .sorted { (states[$0.id]!.box, states[$0.id]!.due) < (states[$1.id]!.box, states[$1.id]!.due) }
        let fresh = scope.filter { !isSeen($0) }.shuffled()
        due.append(contentsOf: fresh)
        if due.count < sessionSize {
            // nothing left that is due or new: revise the weakest instead
            let rest = scope.filter { isSeen($0) && !isDue($0, now: now) }
                .sorted { (states[$0.id]!.box) < (states[$1.id]!.box) }
            due.append(contentsOf: rest)
        }
        return Session(title: title, items: Array(due.prefix(sessionSize)).shuffled())
    }

    func record(_ result: SessionResult) {
        let cal = Calendar.current
        for (item, firstTry) in result.answered {
            var s = states[item.id] ?? ItemState()
            s.seen += 1
            if firstTry {
                s.right += 1
                s.box = min(s.box + 1, ItemState.intervals.count - 1)
            } else {
                s.box = 0
            }
            let days = ItemState.intervals[s.box]
            s.due = days == 0 ? Date() : cal.startOfDay(for: cal.date(byAdding: .day, value: days, to: Date()) ?? Date())
            states[item.id] = s
        }
        let today = Self.dayKey()
        if lastSessionDay != today {
            if let last = cal.date(byAdding: .day, value: -1, to: Date()), lastSessionDay == Self.dayKey(last) {
                streak += 1
            } else {
                streak = 1
            }
            sessionsToday = 0
            lastSessionDay = today
        }
        sessionsToday += 1
        lastScore = "\(result.rightFirstTime)/\(result.total)"
    }

    func clearProgress() {
        states = [:]
        streak = 0
        lastScore = ""
        sessionsToday = 0
        lastSessionDay = ""
    }
}
