import Foundation
import SwiftUI

// MARK: - Vocabulary

struct VocabItem: Codable, Identifiable, Hashable {
    let id: String
    let en: String
    let sub: String
    let type: String          // "verb", "noun", "word"
    let ga: String            // headword; for a verb, the root plus any preposition
    var prep: String? = nil   // governing preposition when written separately
    var vn: String? = nil     // verbal noun, "ag bualadh le"
    var gender: String? = nil // "m" when marked masculine in the source

    var isVerb: Bool { type == "verb" }

    /// What the pupil must write in the first box.
    var expectedFirst: String {
        if isVerb, let p = prep, !p.isEmpty { return "\(ga) \(p)" }
        return ga
    }

    /// Alternatives the source lists with commas or slashes ("clann, teaghlach").
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
}

enum VocabLoader {
    static func load() -> [VocabItem] {
        guard let url = Bundle.main.url(forResource: "vocab", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([VocabItem].self, from: data) else {
            return []
        }
        return items
    }
}

// MARK: - Marking

enum Verdict: Equatable {
    case right
    case rightButFada(String)  // right apart from fadas; the correct spelling
    case wrong(String)         // the correct answer to write in the margin
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

/// Leitner-style boxes. Wrong drops to box 0 and comes back inside the same
/// session; right moves up one box. Intervals in days per box.
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
    let planned: [VocabItem]
    @Published var queue: [VocabItem]
    @Published var index: Int = 0
    private(set) var firstTry: [String: Bool] = [:]
    private(set) var attempts: [String: Int] = [:]

    init(items: [VocabItem]) {
        planned = items
        queue = items
    }

    var current: VocabItem? { index < queue.count ? queue[index] : nil }
    var questionNumber: Int { min(index + 1, planned.count) }
    var totalQuestions: Int { planned.count }
    var isFinished: Bool { index >= queue.count }

    func record(_ item: VocabItem, correct: Bool) {
        attempts[item.id, default: 0] += 1
        if firstTry[item.id] == nil { firstTry[item.id] = correct }
        if !correct, attempts[item.id] == 1 {
            queue.append(item)     // comes round once more before the session ends
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

final class Store: ObservableObject {
    let items: [VocabItem]
    @Published var states: [String: ItemState] {
        didSet { save() }
    }
    // Settings and tallies. Kept as @Published so the screen refreshes when they
    // change; each one writes itself through to UserDefaults.
    @Published var pupilName: String { didSet { defaults.set(pupilName, forKey: "pupilName") } }
    @Published var pupilClass: String { didSet { defaults.set(pupilClass, forKey: "pupilClass") } }
    @Published var strictFadas: Bool { didSet { defaults.set(strictFadas, forKey: "strictFadas") } }
    @Published var sessionsToday: Int { didSet { defaults.set(sessionsToday, forKey: "sessionsToday") } }
    @Published var lastSessionDay: String { didSet { defaults.set(lastSessionDay, forKey: "lastSessionDay") } }
    @Published var streak: Int { didSet { defaults.set(streak, forKey: "streak") } }
    @Published var lastScore: String { didSet { defaults.set(lastScore, forKey: "lastScore") } }

    private let defaults = UserDefaults.standard
    static let sessionSize = 5

    init() {
        items = VocabLoader.load()
        let d = UserDefaults.standard
        if let data = d.data(forKey: "states"),
           let decoded = try? JSONDecoder().decode([String: ItemState].self, from: data) {
            states = decoded
        } else {
            states = [:]
        }
        pupilName = d.string(forKey: "pupilName") ?? "Dalta"
        pupilClass = d.string(forKey: "pupilClass") ?? "11"
        strictFadas = d.bool(forKey: "strictFadas")
        sessionsToday = d.integer(forKey: "sessionsToday")
        lastSessionDay = d.string(forKey: "lastSessionDay") ?? ""
        streak = d.integer(forKey: "streak")
        lastScore = d.string(forKey: "lastScore") ?? ""
        rollDay()
    }

    private func save() {
        if let data = try? JSONEncoder().encode(states) {
            UserDefaults.standard.set(data, forKey: "states")
        }
    }

    private static func dayKey(_ d: Date = Date()) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: d)
    }

    private func rollDay() {
        let today = Self.dayKey()
        if lastSessionDay != today { sessionsToday = 0 }
    }

    var dueCount: Int {
        let now = Date()
        return items.filter { (states[$0.id]?.due ?? .distantPast) <= now }.count
    }

    var learnedCount: Int { states.values.filter { $0.box >= 2 }.count }

    func makeSession() -> Session {
        let now = Date()
        var due = items.filter { states[$0.id] != nil && (states[$0.id]!.due <= now) }
            .sorted { (states[$0.id]!.box, states[$0.id]!.due) < (states[$1.id]!.box, states[$1.id]!.due) }
        let fresh = items.filter { states[$0.id] == nil }.shuffled()
        due.append(contentsOf: fresh)
        let chosen = Array(due.prefix(Self.sessionSize)).shuffled()
        return Session(items: chosen)
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
            s.due = days == 0 ? Date() : cal.startOfDay(for: cal.date(byAdding: .day, value: days, to: Date())!)
            states[item.id] = s
        }
        let today = Self.dayKey()
        if lastSessionDay != today {
            if let last = Calendar.current.date(byAdding: .day, value: -1, to: Date()),
               lastSessionDay == Self.dayKey(last) {
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
}
