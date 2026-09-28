import Foundation
import Combine

// MARK: - Content, decoded from Resources/units.json (built from the approved Year 8 builders)

struct Chunk: Codable, Hashable, Identifiable {
    let ga: String
    let en: String
    let id: String
    let optional: Bool?

    var isOptional: Bool { optional ?? false }
    /// Names and numbers carry the same text in both languages; the English line is then left off.
    var showsEnglish: Bool { en != ga }
}

struct Sentence: Codable, Hashable {
    let ga: String
    let en: String
    let chunks: [String]
    let audio: String
}

struct BuilderRow: Codable, Hashable {
    let label: String
    let columns: [[Chunk]]
    /// The six model sentences used for sessions and progress.
    let sentences: [Sentence]
    /// Every sentence the row can make, each with its own recording.
    let all: [Sentence]?

    /// The sentence a set of picked tiles makes, taking one tile per colour in column order.
    /// Nil when a colour that is needed has no tile picked.
    func sentence(picked: [String]) -> Sentence? {
        let order = columns.compactMap { column in column.first(where: { picked.contains($0.id) })?.id }
        return (all ?? sentences).first(where: { $0.chunks == order })
    }

    /// Picking a tile drops any other tile of the same colour; picking it again drops it.
    func toggle(_ chunkID: String, column: Int, in picked: [String]) -> [String] {
        guard columns.indices.contains(column) else { return picked }
        let ids = columns[column].map { $0.id }
        var out = picked.filter { !ids.contains($0) }
        if !picked.contains(chunkID) { out.append(chunkID) }
        return out
    }
}

struct UnitQuestion: Codable, Hashable {
    let ga: String
    let audio: String
    /// Builder rows that answer this question in one sentence. Nil when it needs more than one row.
    let rows: [Int]?
}

struct Example: Codable, Hashable {
    let ga: String
    let audio: String
}

/// A link from a conversation topic to a grammar section (and the lesson that matters most, if any).
struct GrammarLink: Codable, Hashable {
    let id: String
    let title: String
    let why: String
    let whyEn: String
    let lesson: Int?
    let lessonTitle: String?
    let examples: [String]
}

/// A learning intention (Sprioc foghlama): what the pupil is learning to do in this unit.
struct Sprioc: Codable, Hashable {
    let ga: String
    let en: String
    let audio: String?
}

/// GCSE: a pattern to spot. Each row is a word on its own, then the same word after the change,
/// with the house marks ([x] changed, {x} particle).
struct SpotPattern: Codable, Hashable {
    let title: String
    let question: String
    let questionEn: String
    let rows: [[String]]
    let rule: String?

    /// The rows as pairs. A row with only one entry shows it on both sides.
    var pairs: [PatternPair] {
        rows.map { row in
            let plain = row.first ?? ""
            return PatternPair(plain: plain, marked: row.count > 1 ? row[1] : plain)
        }
    }
}

struct PatternPair: Hashable {
    let plain: String
    let marked: String
}

/// GCSE: one rung of the ladder from a basic answer to the best one. New words are marked [x].
struct LadderRung: Codable, Hashable {
    let ga: String
    let en: String
    let label: String
    let audio: String
}

/// GCSE: one exchange in a role play. The teacher speaks, the pupil does the task in English.
struct RoleTask: Codable, Hashable {
    let teacher: String
    let en: String
    let ga: String
    /// Another good answer, where there is one.
    let alt: String?
    let audio: String
    let teacherAudio: String
    /// The question the pupil has not seen in advance.
    let unexpected: Bool?
}

struct RolePlay: Codable, Hashable {
    let title: String
    let titleEn: String
    let rubric: String
    let rubricEn: String
    let rubricAudio: String?
    let tasks: [RoleTask]
}

/// A2: an essay question with a plan and a model answer. The pupil's draft is kept on the device.
struct WritingTask: Codable, Hashable {
    let title: String?
    let prompt: String?
    let promptEn: String?
    /// About how many words the essay should be (300 when not given).
    let words: Int?
    let plan: [String]?
    let model: String?

    enum CodingKeys: String, CodingKey {
        case title, prompt, promptEn, words, plan, model
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        prompt = try c.decodeIfPresent(String.self, forKey: .prompt)
        promptEn = try c.decodeIfPresent(String.self, forKey: .promptEn)
        // The word count may be written as a number or as text.
        if let n = try? c.decodeIfPresent(Int.self, forKey: .words) {
            words = n
        } else if let text = try? c.decodeIfPresent(String.self, forKey: .words) {
            words = Int(text)
        } else {
            words = nil
        }
        plan = try c.decodeIfPresent([String].self, forKey: .plan)
        model = try c.decodeIfPresent(String.self, forKey: .model)
    }
}

struct BuilderUnit: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let en: String
    let questions: [UnitQuestion]
    let examples: [Example]
    let rows: [BuilderRow]
    /// Conversation topics: what the topic practises, whether it is new (awaiting approval), and whether it has audio yet.
    let teaches: String?
    let isNew: Bool?
    let noAudio: Bool?
    /// Conversation topics: the grammar sections the topic relies on, with the topic's own sentences as evidence.
    let grammar: [GrammarLink]?
    /// GCSE units: the year group label, e.g. "GCSE · Bliain 11".
    let level: String?
    /// Learning intentions (Year 8 and GCSE units).
    let sprioc: [Sprioc]?
    /// GCSE units: patterns to spot, a basic to best ladder, role plays, and clips used only by these.
    let patterns: [SpotPattern]?
    let ladder: [LadderRung]?
    let roleplays: [RolePlay]?
    let extraAudio: [String]?
    /// A2 units: essay questions, each with a plan and a model answer.
    let writing: [WritingTask]?
    /// Conversation topics for the class screen only: left out of the pupil's list, kept in Don rang.
    let teacherLed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, title, en, questions, examples, rows, teaches, noAudio, grammar
        case level, sprioc, patterns, ladder, roleplays, extraAudio, writing, teacherLed
        case isNew = "new"
    }

    var isTeacherLed: Bool { teacherLed ?? false }

    var isSilent: Bool { noAudio ?? false }

    /// The English title, with the year group where there is one: "Holidays · GCSE · Bliain 11".
    var subtitle: String {
        guard let level = level, !level.isEmpty else { return en }
        return en + " · " + level
    }

    func chunk(_ chunkID: String) -> Chunk? {
        for row in rows {
            for column in row.columns {
                if let c = column.first(where: { $0.id == chunkID }) { return c }
            }
        }
        return nil
    }

    var allSentences: [PlacedSentence] {
        var out: [PlacedSentence] = []
        for (i, row) in rows.enumerated() {
            for s in row.sentences { out.append(PlacedSentence(sentence: s, row: i)) }
        }
        return out
    }

    var emoji: String {
        switch id {
        case "b1-mefein": return "🙋"
        case "b2-teaghlach": return "👨‍👩‍👧‍👦"
        case "b3-cursios": return "🪞"
        case "b4-ceantar": return "🏡"
        case "b5-scoil": return "🏫"
        case "b6-caitheamh": return "⚽"
        case "b7-la": return "⏰"
        case "b8-guthan": return "📱"
        case "b9-laethanta": return "📅"
        case "b0-failte": return "👋"
        case "b10-uimhreacha": return "🔢"
        case "g1-mefein": return "🙋"
        case "g2-saoire": return "🏖️"
        case "b11-seomra": return "✏️"
        case "b12-dathanna": return "🎨"
        case "b13-corp": return "👀"
        case "b14-teach": return "🛋️"
        case "g3-ceantar": return "🏘️"
        case "g4-caitheamh": return "🎮"
        case "g5-siopadoireacht": return "🛍️"
        case "g6-slainte": return "🩺"
        case "a2-ghaeilge": return "🗣️"
        case "a2-mean": return "🤖"
        case "a2-timpeallacht": return "🌍"
        case "a2-todhchai": return "🧭"
        default: return "💬"
        }
    }
}

struct PlacedSentence: Hashable {
    let sentence: Sentence
    let row: Int
}

/// The two unit tracks in the Year 8 unit shape: GCSE (Bliain 11, gcse.json) and A2 (Bliain 14, a2.json).
enum UnitTrack: Hashable {
    case gcse
    case a2

    var title: String {
        switch self {
        case .gcse: return "GCSE · Bliain 11"
        case .a2: return "A2 · Bliain 14"
        }
    }
}

// MARK: - AS picture stimulus (spreag.json) and reading and translation (leamh.json)

/// A line of Irish with its English. Also read from a plain string, which is taken as the Irish.
struct GaEn: Codable, Hashable {
    let ga: String
    let en: String?

    enum CodingKeys: String, CodingKey {
        case ga, en
    }

    init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), let text = try? single.decode(String.self) {
            ga = text
            en = nil
            return
        }
        let c = try decoder.container(keyedBy: CodingKeys.self)
        ga = try c.decodeIfPresent(String.self, forKey: .ga) ?? ""
        en = try c.decodeIfPresent(String.self, forKey: .en)
    }
}

/// One finger of the five-finger method: a question, chunks to use, and a model answer.
struct SpreagFinger: Codable, Hashable {
    let finger: String?
    let q: String?
    let qEn: String?
    let frames: [GaEn]?
    let model: GaEn?
}

/// One rung of the picture's ladder, from a basic answer to the best one. New words are marked [x].
struct SpreagRung: Codable, Hashable {
    let label: String?
    let ga: String?
    let en: String?
}

/// One of the examiner's follow-up questions, moving from the picture to the pupil's own life.
struct SpreagFollowUp: Codable, Hashable {
    let ga: String?
    let en: String?
    let model: GaEn?
}

struct SpreagPicture: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let titleEn: String?
    let emoji: String?
    let topic: String?
    /// For the class screen only: left out of the pupil's list.
    let teacherLed: Bool?
    let scene: GaEn?
    /// What the photograph will show, until it is taken.
    let photo: String?
    let fingers: [SpreagFinger]?
    let ladder: [SpreagRung]?
    let followups: [SpreagFollowUp]?

    var isTeacherLed: Bool { teacherLed ?? false }
    var icon: String { (emoji ?? "").isEmpty ? "🖼️" : (emoji ?? "") }
    var allFingers: [SpreagFinger] { fingers ?? [] }
    var allFollowUps: [SpreagFollowUp] { followups ?? [] }
}

/// A reading question: in English or Irish, with its marks and a model answer.
struct LeamhQuestion: Codable, Hashable {
    let q: String?
    /// "ga" when the question is asked and answered in Irish.
    let lang: String?
    let answer: String?
    let marks: Int?

    var inIrish: Bool { lang == "ga" }
}

/// A sentence to put into Irish, with another good answer where there is one and the chunks as a hint.
struct LeamhToIrish: Codable, Hashable {
    let en: String?
    let ga: String?
    let alt: String?
    /// Pairs of English and Irish.
    let chunks: [[String]]?
}

struct LeamhPassage: Codable, Hashable, Identifiable {
    let id: String
    /// "AS" or "A2".
    let level: String?
    let title: String
    let titleEn: String?
    let emoji: String?
    let topic: String?
    /// For the class screen only: left out of the pupil's list.
    let teacherLed: Bool?
    let passage: [String]?
    let glossary: [GaEn]?
    let questions: [LeamhQuestion]?
    let toEnglish: [GaEn]?
    let toIrish: [LeamhToIrish]?

    var isTeacherLed: Bool { teacherLed ?? false }
    var icon: String { (emoji ?? "").isEmpty ? "📰" : (emoji ?? "") }
    var allQuestions: [LeamhQuestion] { questions ?? [] }
}

// MARK: - Progress, kept on the device only

struct Card: Codable {
    var box: Int
    var due: Date
}

final class Store: ObservableObject {
    @Published private(set) var units: [BuilderUnit] = []
    @Published private(set) var cards: [String: Card] = [:]
    @Published private(set) var runs: [String: Int] = [:]
    @Published private(set) var loadError: String?
    /// The AS and A2 grammar track. Nil if grammar.json is missing; the home screen then hides the track.
    let grammar: GrammarData? = GrammarLoader.load()
    /// The AS conversation topics (Comhrá AS). Empty if comhra.json is missing.
    let comhra: [BuilderUnit] = {
        guard let url = Bundle.main.url(forResource: "comhra", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([BuilderUnit].self, from: data)) ?? []
    }()
    /// The GCSE track (Bliain 11), in the Year 8 unit shape. Empty if gcse.json is missing.
    let gcse: [BuilderUnit] = {
        guard let url = Bundle.main.url(forResource: "gcse", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([BuilderUnit].self, from: data)) ?? []
    }()
    /// The A2 track (Bliain 14), in the Year 8 unit shape with essays. Empty if a2.json is missing.
    let a2: [BuilderUnit] = {
        guard let url = Bundle.main.url(forResource: "a2", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([BuilderUnit].self, from: data)) ?? []
    }()
    /// The AS picture stimulus (An Spreagphictiúr). Empty if spreag.json is missing.
    let spreag: [SpreagPicture] = {
        guard let url = Bundle.main.url(forResource: "spreag", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([SpreagPicture].self, from: data)) ?? []
    }()
    /// Reading and translation passages, AS and A2. Empty if leamh.json is missing.
    let leamh: [LeamhPassage] = {
        guard let url = Bundle.main.url(forResource: "leamh", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([LeamhPassage].self, from: data)) ?? []
    }()
    /// Dáithí's verb booklet: the colour boxes, the grid, the syncopated verbs and the irregular verb cards.
    /// Nil if verbs.json is missing; the grammar screen then hides the verbs.
    let verbs: VerbData? = VerbBook.data

    /// The box a verb is in, by its root (lower case, the text before " ("). Nil when it is in no box.
    func verbBox(_ verb: String) -> String? { VerbBook.box(of: verb) }

    /// The pupil's own answers to the conversation questions, by question.
    @Published private(set) var own: [String: String] = [:]

    /// Days until a sentence comes round again, by box.
    static let intervals = [0, 1, 2, 4, 8, 16, 32]
    private let key = "abair-leat.v1"

    private struct Saved: Codable {
        var cards: [String: Card]
        var runs: [String: Int]
        var own: [String: String]?
    }

    init() {
        loadContent()
        restore()
    }

    private func loadContent() {
        guard let url = Bundle.main.url(forResource: "units", withExtension: "json") else {
            loadError = "units.json is missing from the app."
            return
        }
        do {
            let data = try Data(contentsOf: url)
            units = try JSONDecoder().decode([BuilderUnit].self, from: data)
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func restore() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode(Saved.self, from: data) else { return }
        cards = saved.cards
        runs = saved.runs
        own = saved.own ?? [:]
    }

    private func save() {
        if let data = try? JSONEncoder().encode(Saved(cards: cards, runs: runs, own: own)) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func card(_ audio: String) -> Card {
        cards[audio] ?? Card(box: 0, due: .distantPast)
    }

    func record(_ audio: String, ok: Bool) {
        var c = card(audio)
        c.box = ok ? min(c.box + 1, Store.intervals.count - 1) : 0
        c.due = Date().addingTimeInterval(Double(Store.intervals[c.box]) * 86_400)
        cards[audio] = c
        save()
    }

    func ownAnswer(_ question: String) -> String { own[question] ?? "" }

    func setOwnAnswer(_ question: String, _ text: String) {
        own[question] = text
        save()
    }

    /// The conversation topics a pupil sees: those for the class screen only are left out.
    var pupilComhra: [BuilderUnit] { comhra.filter { !$0.isTeacherLed } }

    /// The units of a track.
    func trackUnits(_ track: UnitTrack) -> [BuilderUnit] {
        switch track {
        case .gcse: return gcse
        case .a2: return a2
        }
    }

    func finishRun(_ unitID: String) {
        runs[unitID, default: 0] += 1
        save()
    }

    func runCount(_ unitID: String) -> Int { runs[unitID] ?? 0 }

    /// Share of a unit's sentences that have been right at least twice in a row.
    func progress(_ unit: BuilderUnit) -> Double {
        let all = unit.allSentences
        guard !all.isEmpty else { return 0 }
        let known = all.filter { card($0.sentence.audio).box >= 2 }.count
        return Double(known) / Double(all.count)
    }

    func resetProgress() {
        cards = [:]
        runs = [:]
        save()
    }
}

// MARK: - Marking

enum Mark {
    /// Lower case, curly apostrophes straightened, full stops and commas dropped, spaces collapsed.
    static func norm(_ s: String) -> String {
        var t = s.lowercased()
            .replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{2018}", with: "'")
        for p in [".", "!", "?", ","] {
            t = t.replacingOccurrences(of: p, with: " ")
        }
        return t.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ")
    }

    /// The same text with fadas removed, so a missing fada is spotted rather than marked wrong.
    static func fold(_ s: String) -> String {
        s.folding(options: .diacriticInsensitive, locale: nil)
    }

    struct Verdict {
        let ok: Bool
        let fadaSlip: Bool
    }

    static func compare(_ typed: String, _ target: String) -> Verdict {
        let a = norm(typed), b = norm(target)
        if a == b { return Verdict(ok: true, fadaSlip: false) }
        if fold(a) == fold(b) { return Verdict(ok: true, fadaSlip: true) }
        return Verdict(ok: false, fadaSlip: false)
    }

    /// Words of the target the pupil did not write, ignoring fadas.
    static func missing(typed: String, target: String) -> [String] {
        let have = Set(norm(typed).split(separator: " ").map { fold(String($0)) })
        return norm(target).split(separator: " ").map(String.init).filter { !have.contains(fold($0)) }
    }

    /// Every sentence a builder row can make. A column made only of optional chunks may be skipped.
    static func combos(_ row: BuilderRow) -> [String] {
        var out: [[String]] = [[]]
        for column in row.columns {
            var options: [String?] = column.map { $0.ga }
            if column.allSatisfy({ $0.isOptional }) { options.append(nil) }
            var next: [[String]] = []
            for partial in out {
                for option in options {
                    if let option = option {
                        next.append(partial + [option])
                    } else {
                        next.append(partial)
                    }
                }
            }
            out = next
        }
        return out.map { $0.joined(separator: " ") }
    }
}
