import SwiftUI
import Combine

// MARK: - Dáithí's verb booklet, decoded from Resources/verbs.json: the colour boxes, the master grid,
// the syncopated table and the eleven irregular verb cards. The web version is verbsHTML and its neighbours in index.src.html.

struct VerbMnemonic: Codable, Hashable {
    let id: String
    let title: String
    let what: String
    let letters: String
    let rhyme: String?
    /// Urú only: sentences with the eclipsing letter marked [x].
    let examples: [String]?
}

struct VerbBox: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let ga: String
    let colour: String
    /// Pairs of the verb and its English.
    let verbs: [[String]]
}

struct VerbTense: Codable, Hashable, Identifiable {
    let id: String
    let ga: String
    let en: String
    let colour: String
}

struct VerbGridRow: Codable, Hashable, Identifiable {
    let id: String
    let label: String
    /// Numbered moves by column: "past", "present-1", "present-2", ... or "all" for every tense after the past.
    let cells: [String: [String]]
}

struct VerbGrid: Codable, Hashable {
    let tenses: [VerbTense]
    let rows: [VerbGridRow]
}

struct VerbSyncRow: Codable, Hashable {
    let verb: String
    let past: String
    let present: String
    let future: String
    let conditional: String

    func form(_ tense: String) -> String {
        switch tense {
        case "past": return past
        case "present": return present
        case "future": return future
        default: return conditional
        }
    }
}

struct VerbSyncopated: Codable, Hashable {
    let rule: [String]
    let table: [VerbSyncRow]
}

/// One tense of an irregular verb: positive, negative, question, autonomous, and the Ulster form where there is one.
struct VerbForms: Codable, Hashable {
    let positive: String
    let negative: String
    let question: String
    let saor: String
    let ulster: String?

    enum CodingKeys: String, CodingKey {
        case positive = "P"
        case negative = "N"
        case question = "Q"
        case saor, ulster
    }

    /// The form by its letter on the card: P, N or Q.
    func form(_ key: String) -> String {
        switch key {
        case "P": return positive
        case "N": return negative
        default: return question
        }
    }
}

struct IrregularVerb: Codable, Hashable {
    let n: Int
    let verb: String
    let en: String
    /// The card's own colour, for the bar down its side.
    let colour: String
    let past: VerbForms
    let present: VerbForms
    let future: VerbForms
    let conditional: VerbForms

    func forms(_ tense: String) -> VerbForms {
        switch tense {
        case "past": return past
        case "present": return present
        case "future": return future
        default: return conditional
        }
    }
}

struct VerbData: Codable {
    let note: String?
    let mnemonics: [VerbMnemonic]
    let boxes: [VerbBox]
    let grid: VerbGrid
    let syncopated: VerbSyncopated
    let irregular: [IrregularVerb]
}

/// The booklet, loaded once, with the helpers the web keeps beside it (BOXLBL, VBOX, pv, vfirst, whyBox, rhymeHTML).
enum VerbBook {
    static let data: VerbData? = load()

    /// A verb's box by its root, lower case (the web's VBOX).
    static let boxOf: [String: String] = lookup(data)

    /// The box labels shown on every chip (the web's BOXLBL).
    static let labels: [String: String] = [
        "c1-broad": "1 leathan", "c1-slender": "1 caol", "c2-broad": "2 leathan",
        "c2-slender": "2 caol", "sync": "coimrithe", "irreg": "neamhrialta"
    ]

    static func load() -> VerbData? {
        guard let url = Bundle.main.url(forResource: "verbs", withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(VerbData.self, from: data)
    }

    private static func lookup(_ data: VerbData?) -> [String: String] {
        var out: [String: String] = [:]
        guard let data = data else { return out }
        for box in data.boxes {
            for pair in box.verbs {
                if let verb = pair.first {
                    out[root(verb).lowercased()] = box.id
                }
            }
        }
        return out
    }

    /// The verb without what follows it in brackets: "cuidigh (le)" is "cuidigh".
    static func root(_ verb: String) -> String {
        verb.components(separatedBy: " (").first ?? verb
    }

    static func box(of verb: String) -> String? {
        boxOf[root(verb).lowercased()]
    }

    static func label(_ box: String) -> String {
        labels[box] ?? box
    }

    /// Why a verb is in its box (the web's whyBox).
    static func why(_ box: String) -> String {
        if box == "irreg" { return "One of the eleven irregular verbs: learn its card." }
        if box == "sync" {
            return "Two syllables ending in -il, -ir, -is or -in: it shortens (oscail, osclaím) and takes 2nd conjugation endings."
        }
        let two = box.hasPrefix("c2")
        let broad = box.hasSuffix("broad")
        let size: String = two ? "Two syllables ending in -" + (broad ? "aigh" : "igh") + ": 2nd conjugation. " : "One syllable: 1st conjugation. "
        return size + (broad ? "The last vowel is a, o or u: broad." : "The last vowel is i or e: slender.")
    }

    /// The first form on a card line, without the other forms or the bracketed alternative (the web's vfirst):
    /// "Beirim / Beireann sé / Beireann muid (Beirimid)" is "Beirim".
    static func first(_ form: String) -> String {
        var head = form
        for separator in [" / ", ". Usually", "? Usually"] {
            if let r = head.range(of: separator) {
                head = String(head[..<r.lowerBound])
            }
        }
        head = head.replacingOccurrences(of: #"\s*\(.*\)\s*$"#, with: "", options: .regularExpression)
        return head.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// A hyphen that starts an ending (-aigh, -faidh) is kept on the same line as the ending, as on the web.
    static func keepHyphens(_ s: String) -> String {
        s.replacingOccurrences(of: #"(^|[\s(])-(?=[a-záéíóú])"#, with: "$1\u{2011}", options: .regularExpression)
    }

    /// A card's own colour from its hex string, the same in light and dark mode.
    static func colour(_ hex: String) -> Color {
        let digits = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        let value: UInt32 = UInt32(digits, radix: 16) ?? 0x888888
        return Color(light: value, dark: value)
    }

    /// A verb in its box colour with the box label beside it, inside running text. The label is part of the text,
    /// so colour is never the only signal.
    static func inlineChip(_ word: String, box: String) -> AttributedString {
        let fill: Color = Theme.box(box)
        let ink: Color = Theme.boxInk
        var verb = AttributedString("\u{2009}" + word + "\u{00A0}")
        verb.backgroundColor = fill
        verb.foregroundColor = ink
        verb.inlinePresentationIntent = .stronglyEmphasized
        var tag = AttributedString(label(box).replacingOccurrences(of: " ", with: "\u{00A0}") + "\u{2009}")
        tag.backgroundColor = fill
        tag.foregroundColor = ink
        let small: Font = .caption.weight(.semibold)
        tag.font = small
        return verb + tag
    }

    /// A prompt with each verb named in brackets shown in its box colour (the web's pv):
    /// "(ceannaigh, an aimsir chaite)" shows ceannaigh as a 2 leathan chip. Other text is left as it is.
    static func chipped(_ source: String) -> AttributedString {
        var out = AttributedString()
        var rest = Substring(source)
        while let open = rest.firstIndex(of: "("), let close = rest[open...].firstIndex(of: ")") {
            out += AttributedString(String(rest[..<open]))
            out += AttributedString("(")
            out += chipWords(String(rest[rest.index(after: open)..<close]))
            out += AttributedString(")")
            rest = rest[rest.index(after: close)...]
        }
        out += AttributedString(String(rest))
        return out
    }

    /// The words inside one pair of brackets, split on spaces, commas and slashes, each verb as a chip.
    private static func chipWords(_ inner: String) -> AttributedString {
        var tokens: [String] = []
        var current = ""
        var currentIsGap = false
        for ch in inner {
            let isGap = ch.isWhitespace || ch == "," || ch == "/"
            if !current.isEmpty && isGap != currentIsGap {
                tokens.append(current)
                current = ""
            }
            currentIsGap = isGap
            current.append(ch)
        }
        if !current.isEmpty { tokens.append(current) }
        var out = AttributedString()
        for token in tokens {
            if let b = boxOf[token.lowercased()] {
                out += inlineChip(token, box: b)
            } else {
                out += AttributedString(token)
            }
        }
        return out
    }

    /// The urú rhyme with the eclipsing letter red (two letters for "behind") and the letter it eclipses blue,
    /// both underlined and bold (the web's rhymeHTML).
    static func rhyme() -> AttributedString {
        let pairs: [(String, String)] = [
            ("Many", "boys"), ("go", "camping"), ("near", "ditches"), ("behind", "fences"),
            ("nice", "girls"), ("buy", "pens"), ("down", "town")
        ]
        var out = AttributedString()
        for (i, pair) in pairs.enumerated() {
            if i > 0 { out += AttributedString(" ") }
            if i == 4 {
                var joiner = AttributedString("while ")
                joiner.inlinePresentationIntent = .emphasized
                out += joiner
            }
            out += lettered(pair.0, count: pair.0 == "behind" ? 2 : 1, colour: Theme.pen)
            out += AttributedString(" ")
            out += lettered(pair.1, count: 1, colour: Theme.columnInk(0))
        }
        out += AttributedString(".")
        return out
    }

    private static func lettered(_ word: String, count: Int, colour: Color) -> AttributedString {
        var head = AttributedString(String(word.prefix(count)))
        head.foregroundColor = colour
        head.underlineStyle = Text.LineStyle.single
        head.inlinePresentationIntent = .stronglyEmphasized
        var tail = AttributedString(String(word.dropFirst(count)))
        tail.inlinePresentationIntent = .stronglyEmphasized
        return head + tail
    }

    /// "Title what": the title bold, the explanation muted.
    static func titled(_ title: String, _ detail: String) -> AttributedString {
        var head = AttributedString(title)
        head.inlinePresentationIntent = .stronglyEmphasized
        var tail = AttributedString(" " + detail)
        tail.foregroundColor = Theme.muted
        return head + tail
    }
}

// MARK: - Chips

/// A verb in its box colour with the box label (for example "2 caol"), so colour is never the only signal.
struct BoxChip: View {
    let verb: String
    let box: String
    var size: CGFloat = 17

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text(verb)
                .font(.system(size: size, weight: .bold))
            Text(VerbBook.label(box))
                .font(.system(size: max(11, size * 0.7), weight: .semibold))
                .opacity(0.85)
        }
        .foregroundStyle(Theme.boxInk)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.box(box)))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(Color.black.opacity(0.18)))
        .accessibilityElement(children: .combine)
    }
}

/// A tense name on its tense colour.
struct TenseTag: View {
    let tense: VerbTense

    var body: some View {
        Text(tense.ga)
            .font(.caption.weight(.bold))
            .foregroundStyle(Theme.boxInk)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 6, style: .continuous).fill(Theme.tense(tense.id)))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(Color.black.opacity(0.18)))
    }
}

/// A rule as numbered moves, with the house marks ([x] red, {x} green).
struct VerbSteps: View {
    let steps: [String]
    var font: Font = .footnote

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(Array(steps.enumerated()), id: \.offset) { i, step in
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(i + 1).").fontWeight(.bold)
                    Text(Marking.text(VerbBook.keepHyphens(step)))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel(Marking.plain(step))
                }
            }
        }
        .font(font)
    }
}

/// One cell of a verb table: a fixed width, bordered, and as tall as its row.
struct VerbCell<Content: View>: View {
    let width: CGFloat
    var fill: Color = Theme.surface
    var ink: Color = Theme.ink
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            content
        }
        .padding(8)
        .frame(width: width, alignment: .topLeading)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(ink)
        .background(fill)
        .overlay(Rectangle().strokeBorder(Theme.rule, lineWidth: 1))
    }
}

// MARK: - Na briathra: the boxes, the five activities, and séimhiú and urú

struct VerbsHub: View {
    let verbs: VerbData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Verbs: boxes, grid and cards")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                DraftBanner()
                Text("Box first. Which box is the verb in? Then the grid tells you what to do in every tense.")
                    .foregroundStyle(Theme.muted)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10, alignment: .top)], alignment: .leading, spacing: 10) {
                    ForEach(verbs.boxes) { box in
                        VerbBoxTile(box: box)
                    }
                }
                VStack(spacing: 10) {
                    NavigationLink {
                        VerbSortView(verbs: verbs)
                    } label: {
                        GCSEActionLabel(emoji: "🗂️", ga: "Cén bosca?", en: "Which box? Sort ten verbs into their boxes")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        VerbGridView(verbs: verbs)
                    } label: {
                        GCSEActionLabel(emoji: "🧮", ga: "An ghreille", en: "The grid: every tense on one page, as numbered moves")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        VerbSyncView(verbs: verbs)
                    } label: {
                        GCSEActionLabel(emoji: "✂️", ga: "Briathra coimrithe", en: "Syncopated verbs: oscail, imir, inis, aithin")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        VerbCardList(verbs: verbs)
                    } label: {
                        GCSEActionLabel(emoji: "🃏", ga: "Na briathra neamhrialta", en: "The 11 irregular verbs: one card each, P, N and Q in four tenses")
                    }
                    .buttonStyle(.plain)
                    NavigationLink {
                        VerbDrillView(verbs: verbs, card: nil)
                    } label: {
                        GCSEActionLabel(emoji: "✍️", ga: "Dearfach, diúltach, ceist", en: "Positive, negative and question, always together")
                    }
                    .buttonStyle(.plain)
                }
                mnemonics
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Na briathra")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var mnemonics: some View {
        Panel {
            Text("Séimhiú agus urú · aspirate and eclipse")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            ForEach(Array(verbs.mnemonics.enumerated()), id: \.offset) { _, m in
                VStack(alignment: .leading, spacing: 4) {
                    Text(VerbBook.titled(m.title, m.what))
                        .foregroundStyle(Theme.ink)
                    Text(m.letters).font(.body.weight(.bold)).foregroundStyle(Theme.ink)
                    if m.id == "uru" {
                        Text(VerbBook.rhyme())
                            .foregroundStyle(Theme.ink)
                        Text("Red: the eclipsing letter. Blue: the letter it eclipses.")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(Array((m.examples ?? []).enumerated()), id: \.offset) { _, example in
                                Text(Marking.text(example))
                                    .foregroundStyle(Theme.ink)
                                    .accessibilityLabel(Marking.plain(example))
                            }
                        }
                        .padding(.top, 2)
                    } else if let rhyme = m.rhyme, !rhyme.isEmpty {
                        Text(rhyme).italic().foregroundStyle(Theme.ink)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
}

/// One box as a tile in its colour; opens to list its verbs.
struct VerbBoxTile: View {
    let box: VerbBox
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(box.ga) · \(box.verbs.count)")
                    .font(.subheadline)
                ForEach(Array(box.verbs.enumerated()), id: \.offset) { _, pair in
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(pair.first ?? "").font(.subheadline.weight(.semibold))
                        Text(pair.count > 1 ? pair[1] : "").font(.subheadline).opacity(0.75)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
        } label: {
            Text(box.title)
                .font(.headline)
                .multilineTextAlignment(.leading)
        }
        .foregroundStyle(Theme.boxInk)
        .tint(Theme.boxInk)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.box(box.id)))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Color.black.opacity(0.18)))
    }
}

// MARK: - Cén bosca? Which box?

struct VerbSortItem: Hashable {
    let verb: String
    let en: String
    let box: String
}

final class VerbSortRun: ObservableObject {
    let verbs: VerbData
    @Published private(set) var items: [VerbSortItem] = []
    @Published private(set) var index = 0
    @Published private(set) var right = 0
    /// The box the pupil chose for the current verb; nil until they choose.
    @Published private(set) var pick: String?

    init(verbs: VerbData) {
        self.verbs = verbs
        plan()
    }

    var item: VerbSortItem? { items.indices.contains(index) ? items[index] : nil }
    var done: Bool { index >= items.count }
    var ok: Bool { pick != nil && pick == item?.box }

    /// Two verbs from each box in the booklet's order, the first ten of those, shuffled (as the web does).
    private func plan() {
        var chosen: [VerbSortItem] = []
        for box in verbs.boxes {
            let all: [VerbSortItem] = box.verbs.compactMap { pair -> VerbSortItem? in
                guard let verb = pair.first else { return nil }
                return VerbSortItem(verb: VerbBook.root(verb), en: pair.count > 1 ? pair[1] : "", box: box.id)
            }
            chosen += Array(all.shuffled().prefix(2))
        }
        items = Array(chosen.shuffled().prefix(10))
        index = 0
        right = 0
        pick = nil
    }

    func restart() { plan() }

    func choose(_ box: String) {
        guard pick == nil, let it = item else { return }
        pick = box
        if box == it.box { right += 1 }
    }

    func next() {
        index += 1
        pick = nil
    }
}

struct VerbSortView: View {
    let verbs: VerbData
    @StateObject private var run: VerbSortRun
    @Environment(\.dismiss) private var dismiss

    init(verbs: VerbData) {
        self.verbs = verbs
        _run = StateObject(wrappedValue: VerbSortRun(verbs: verbs))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Color.clear.frame(height: 0).id("top")
                    Text(run.done ? "Which box?" : "Which box? \(run.index + 1) / \(run.items.count)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    if let it = run.item {
                        question(it)
                    } else {
                        Panel {
                            Text("\(run.right) / \(run.items.count)")
                                .font(.largeTitle.weight(.bold))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: run.index) { _, _ in proxy.scrollTo("top", anchor: .top) }
            .onChange(of: run.pick != nil) { _, answered in
                if answered { withAnimation { proxy.scrollTo("feedback", anchor: .center) } }
            }
        }
        .background(Theme.ground)
        .safeAreaInset(edge: .bottom) { actionBar }
        .navigationTitle("Cén bosca?")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func question(_ it: VerbSortItem) -> some View {
        Panel {
            VStack(spacing: 4) {
                Text(it.verb).font(.system(size: 34, weight: .bold)).foregroundStyle(Theme.ink)
                Text(it.en).foregroundStyle(Theme.muted)
            }
            .frame(maxWidth: .infinity)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                ForEach(verbs.boxes) { box in
                    Button {
                        run.choose(box.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(box.title).font(.headline)
                            Text(box.ga).font(.subheadline)
                        }
                        .foregroundStyle(Theme.boxInk)
                        .multilineTextAlignment(.leading)
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 72, alignment: .topLeading)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.box(box.id)))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(outline(box.id, it), lineWidth: outlined(box.id, it) ? 3 : 1))
                        .overlay(alignment: .topTrailing) { tick(box.id, it) }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .disabled(run.pick != nil)
                    .accessibilityLabel("\(box.title). \(box.ga)")
                }
            }
            if run.pick != nil {
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.ok ? "✓ ceart!" : "✗ " + VerbBook.label(it.box))
                        .font(Pen.font(26))
                        .foregroundStyle(Theme.pen)
                    Text(VerbBook.why(it.box)).foregroundStyle(Theme.ink)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
                .id("feedback")
                .accessibilityElement(children: .combine)
            }
        }
    }

    /// Green round the right box once answered, red round a wrong choice.
    private func outline(_ box: String, _ it: VerbSortItem) -> Color {
        guard let pick = run.pick else { return Color.black.opacity(0.18) }
        if box == it.box { return Theme.good }
        if box == pick { return Theme.pen }
        return Color.black.opacity(0.18)
    }

    /// Whether a box gets the thick outline: the right box, and a wrong choice, once answered.
    private func outlined(_ box: String, _ it: VerbSortItem) -> Bool {
        guard let pick = run.pick else { return false }
        return box == it.box || box == pick
    }

    /// A tick on the right box and a cross on a wrong choice, so colour is not the only signal.
    @ViewBuilder private func tick(_ box: String, _ it: VerbSortItem) -> some View {
        if let pick = run.pick {
            if box == it.box {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.good)
                    .background(Circle().fill(Theme.surface))
                    .offset(x: 6, y: -6)
            } else if box == pick {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Theme.pen)
                    .background(Circle().fill(Theme.surface))
                    .offset(x: 6, y: -6)
            }
        }
    }

    private var actionBar: some View {
        HStack {
            if run.done {
                Button("Na briathra") { dismiss() }
                    .buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary("Arís") { run.restart() }
            } else if run.pick != nil {
                Spacer()
                primary("Ar aghaidh") { run.next() }
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

// MARK: - An ghreille: every tense on one page

private struct VerbGridHead: Hashable {
    let ga: String
    let en: String
    let tense: String
    let span: Int
}

private struct VerbGridCell: Hashable {
    let steps: [String]
    let span: Int
}

struct VerbGridView: View {
    let verbs: VerbData
    let labelWidth: CGFloat = 150
    let cellWidth: CGFloat = 140

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("The grid: every tense, one page")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Text("Find the verb's box, then read down its column.")
                    .foregroundStyle(Theme.muted)
                Text("Red: the letter you add. Green: the particle.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                ScrollView(.horizontal) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                        GridRow {
                            VerbCell(width: labelWidth) { Text("") }
                            ForEach(Array(tenseHeads.enumerated()), id: \.offset) { _, head in
                                headCell(head)
                                    .gridCellColumns(head.span)
                            }
                        }
                        GridRow {
                            VerbCell(width: labelWidth) { Text("") }
                            ForEach(Array(conjugationHeads.enumerated()), id: \.offset) { _, head in
                                headCell(head)
                            }
                        }
                        ForEach(verbs.grid.rows) { row in
                            GridRow {
                                VerbCell(width: labelWidth) {
                                    Text(row.label).font(.footnote.weight(.bold))
                                }
                                ForEach(Array(cells(row).enumerated()), id: \.offset) { _, cell in
                                    VerbCell(width: cellWidth * CGFloat(cell.span)) {
                                        VerbSteps(steps: cell.steps)
                                    }
                                    .gridCellColumns(cell.span)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding()
        }
        .background(Theme.ground)
        .navigationTitle("An ghreille")
        .navigationBarTitleDisplayMode(.inline)
    }

    /// The tense headings: the past takes one column, every other tense two (1st and 2nd conjugation).
    private var tenseHeads: [VerbGridHead] {
        verbs.grid.tenses.map { t in
            VerbGridHead(ga: t.ga, en: t.en, tense: t.id, span: t.id == "past" ? 1 : 2)
        }
    }

    private var conjugationHeads: [VerbGridHead] {
        var out: [VerbGridHead] = []
        for t in verbs.grid.tenses {
            if t.id == "past" {
                out.append(VerbGridHead(ga: "", en: "", tense: t.id, span: 1))
            } else {
                out.append(VerbGridHead(ga: "1ú réimniú", en: "", tense: t.id, span: 1))
                out.append(VerbGridHead(ga: "2ú réimniú", en: "", tense: t.id, span: 1))
            }
        }
        return out
    }

    private func headCell(_ head: VerbGridHead) -> some View {
        VerbCell(width: cellWidth * CGFloat(head.span), fill: Theme.tense(head.tense), ink: Theme.boxInk) {
            Text(head.ga).font(.footnote.weight(.bold))
            if !head.en.isEmpty {
                Text(head.en).font(.footnote)
            }
        }
    }

    /// A row's cells: the past, then each tense as two columns, or one wide one where the row has a move for every tense.
    private func cells(_ row: VerbGridRow) -> [VerbGridCell] {
        var out: [VerbGridCell] = []
        for t in verbs.grid.tenses {
            if t.id == "past" {
                out.append(VerbGridCell(steps: row.cells["past"] ?? [], span: 1))
            } else if let first = row.cells[t.id + "-1"] {
                out.append(VerbGridCell(steps: first, span: 1))
                out.append(VerbGridCell(steps: row.cells[t.id + "-2"] ?? [], span: 1))
            } else {
                out.append(VerbGridCell(steps: row.cells["all"] ?? row.cells[t.id] ?? [], span: 2))
            }
        }
        return out
    }
}

// MARK: - Briathra coimrithe: syncopated verbs

struct VerbSyncView: View {
    let verbs: VerbData
    let cellWidth: CGFloat = 130

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Syncopated verbs")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Panel {
                    VerbSteps(steps: verbs.syncopated.rule, font: .body)
                }
                ScrollView(.horizontal) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                        GridRow {
                            VerbCell(width: cellWidth, fill: Theme.boxSync, ink: Theme.boxInk) {
                                Text("Briathar").font(.subheadline.weight(.bold))
                            }
                            ForEach(verbs.grid.tenses) { t in
                                VerbCell(width: cellWidth, fill: Theme.tense(t.id), ink: Theme.boxInk) {
                                    Text(t.en).font(.subheadline.weight(.bold))
                                }
                            }
                        }
                        ForEach(Array(verbs.syncopated.table.enumerated()), id: \.offset) { _, row in
                            GridRow {
                                VerbCell(width: cellWidth) {
                                    Text(row.verb).font(.subheadline.weight(.bold))
                                }
                                ForEach(verbs.grid.tenses) { t in
                                    VerbCell(width: cellWidth) {
                                        Text(row.form(t.id)).font(.subheadline)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Briathra coimrithe")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Na briathra neamhrialta: the eleven cards

struct VerbCardList: View {
    let verbs: VerbData

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text("The 11 irregular verbs")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                Text("One card per verb: positive, negative and question in all four tenses.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(verbs.irregular.enumerated()), id: \.offset) { i, card in
                    NavigationLink {
                        VerbCardView(verbs: verbs, start: i)
                    } label: {
                        HStack(spacing: 14) {
                            Text("\(card.n)")
                                .font(.system(size: 30, weight: .bold))
                                .frame(width: 48)
                                .foregroundStyle(Theme.ink)
                                .accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(card.verb).font(.headline).foregroundStyle(Theme.ink)
                                Text("to \(card.en)").font(.subheadline).foregroundStyle(Theme.muted)
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(0)).accessibilityHidden(true)
                        }
                        .padding(14)
                        .padding(.leading, 8)
                        .background(Theme.surface)
                        .overlay(alignment: .leading) {
                            Rectangle().fill(VerbBook.colour(card.colour)).frame(width: 8)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(card.n). \(card.verb), to \(card.en)")
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Na briathra neamhrialta")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// One irregular verb: P, N, Q and the autonomous form across the four tenses, with the Ulster forms.
struct VerbCardView: View {
    let verbs: VerbData
    @State private var index: Int
    private let keyWidth: CGFloat = 40
    private let cellWidth: CGFloat = 170

    init(verbs: VerbData, start: Int) {
        self.verbs = verbs
        _index = State(initialValue: start)
    }

    var body: some View {
        ScrollView {
            if verbs.irregular.indices.contains(index) {
                content(verbs.irregular[index])
                    .padding()
                    .frame(maxWidth: 900)
                    .frame(maxWidth: .infinity)
            }
        }
        .background(Theme.ground)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// "1. beir", as the web heads the card.
    private var title: String {
        guard verbs.irregular.indices.contains(index) else { return "" }
        let card = verbs.irregular[index]
        return "\(card.n). \(card.verb)"
    }

    private func content(_ card: IrregularVerb) -> some View {
        let tenses = verbs.grid.tenses
        let ulster = tenses.filter { !(card.forms($0.id).ulster ?? "").isEmpty }
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("to \(card.en) ·").font(.subheadline).foregroundStyle(Theme.muted)
                BoxChip(verb: card.verb, box: "irreg", size: 15)
            }
            VStack(alignment: .leading, spacing: 12) {
                ScrollView(.horizontal) {
                    Grid(alignment: .topLeading, horizontalSpacing: 0, verticalSpacing: 0) {
                        GridRow {
                            VerbCell(width: keyWidth) { Text("") }
                            ForEach(tenses) { t in
                                VerbCell(width: cellWidth, fill: Theme.tense(t.id), ink: Theme.boxInk) {
                                    Text(t.ga).font(.subheadline.weight(.bold))
                                    Text(t.en).font(.subheadline)
                                }
                            }
                        }
                        ForEach(["P", "N", "Q"], id: \.self) { key in
                            GridRow {
                                VerbCell(width: keyWidth) {
                                    Text(key).font(.subheadline.weight(.bold)).frame(maxWidth: .infinity)
                                }
                                ForEach(tenses) { t in
                                    VerbCell(width: cellWidth) {
                                        Text(card.forms(t.id).form(key)).font(.subheadline)
                                    }
                                }
                            }
                        }
                        GridRow {
                            VerbCell(width: keyWidth) {
                                Text("S").font(.subheadline.weight(.bold)).frame(maxWidth: .infinity)
                                    .accessibilityLabel("saorbhriathar")
                            }
                            ForEach(tenses) { t in
                                VerbCell(width: cellWidth) {
                                    Text(card.forms(t.id).saor).font(.subheadline).italic()
                                }
                            }
                        }
                    }
                    .padding(.bottom, 4)
                }
                Text("P positive · N negative · Q question · S autonomous (nobody named). The form in brackets is the other way to say we; both are right.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                if !ulster.isEmpty {
                    Text(VerbCardView.ulsterLine(card, ulster))
                        .foregroundStyle(Theme.ink)
                }
            }
            .padding(18)
            .padding(.leading, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface)
            .overlay(alignment: .leading) {
                Rectangle().fill(VerbBook.colour(card.colour)).frame(width: 8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Theme.rule))
            NavigationLink {
                VerbDrillView(verbs: verbs, card: index)
            } label: {
                Text("Cleachtadh · drill \(card.verb)").font(.headline).padding(.horizontal, 8)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(Theme.ink)
            HStack {
                if index > 0 {
                    Button("◀ \(verbs.irregular[index - 1].verb)") { index -= 1 }
                        .buttonStyle(.bordered).controlSize(.large)
                }
                Spacer()
                if index + 1 < verbs.irregular.count {
                    Button("\(verbs.irregular[index + 1].verb) ▶") { index += 1 }
                        .buttonStyle(.bordered).controlSize(.large)
                }
            }
        }
    }

    /// "Uladh · Ulster: Present: Tigim / Tig sé · Future: ...", the heading bold.
    private static func ulsterLine(_ card: IrregularVerb, _ tenses: [VerbTense]) -> AttributedString {
        var head = AttributedString("Uladh · Ulster: ")
        head.inlinePresentationIntent = .stronglyEmphasized
        let forms = tenses.map { t in "\(t.en): \(card.forms(t.id).ulster ?? "")" }.joined(separator: " · ")
        return head + AttributedString(forms)
    }
}

// MARK: - Dearfach, diúltach, ceist: positive, negative and question together

struct VerbDrillItem: Hashable {
    /// The card's index in the booklet.
    let card: Int
    let tense: String
}

struct VerbDrillResult {
    let ok: Bool
    let fadaSlip: Bool
    let typed: String
    let want: String
}

struct VerbDrillField: Hashable {
    let key: String
    let ga: String
    let who: String
}

final class VerbDrillRun: ObservableObject {
    let verbs: VerbData
    /// The card being drilled, or nil for a mix from all eleven.
    let card: Int?

    static let tenses = ["past", "present", "future", "conditional"]
    static let fields: [VerbDrillField] = [
        VerbDrillField(key: "P", ga: "Dearfach · positive", who: "mé"),
        VerbDrillField(key: "N", ga: "Diúltach · negative", who: "mé"),
        VerbDrillField(key: "Q", ga: "Ceist · question", who: "tú")
    ]

    @Published private(set) var items: [VerbDrillItem] = []
    @Published private(set) var index = 0
    @Published private(set) var right = 0
    @Published private(set) var total = 0
    @Published var positive = ""
    @Published var negative = ""
    @Published var question = ""
    /// The marks for the current item by field (P, N, Q); nil until checked.
    @Published private(set) var results: [String: VerbDrillResult]?

    init(verbs: VerbData, card: Int?) {
        self.verbs = verbs
        self.card = card
        plan()
    }

    var item: VerbDrillItem? { items.indices.contains(index) ? items[index] : nil }
    var done: Bool { index >= items.count }

    /// One card: its four tenses, shuffled. Otherwise eight at random from every card and tense.
    private func plan() {
        if let c = card, verbs.irregular.indices.contains(c) {
            items = VerbDrillRun.tenses.map { VerbDrillItem(card: c, tense: $0) }.shuffled()
        } else {
            var all: [VerbDrillItem] = []
            for i in verbs.irregular.indices {
                for t in VerbDrillRun.tenses { all.append(VerbDrillItem(card: i, tense: t)) }
            }
            items = Array(all.shuffled().prefix(8))
        }
        index = 0
        right = 0
        total = 0
        clear()
    }

    private func clear() {
        positive = ""
        negative = ""
        question = ""
        results = nil
    }

    func restart() { plan() }

    func typed(_ key: String) -> String {
        switch key {
        case "P": return positive
        case "N": return negative
        default: return question
        }
    }

    /// Each answer against the first form on the card, then against any Ulster form, as the grammar lessons mark
    /// (both verb forms allowed, a missing fada spotted).
    func check() {
        guard results == nil, let it = item, verbs.irregular.indices.contains(it.card) else { return }
        let forms = verbs.irregular[it.card].forms(it.tense)
        let ulster = (forms.ulster ?? "").components(separatedBy: " / ").map { VerbBook.first($0) }.filter { !$0.isEmpty }
        var out: [String: VerbDrillResult] = [:]
        for field in VerbDrillRun.fields {
            let answer = typed(field.key)
            let want = VerbBook.first(forms.form(field.key))
            var verdict = Mark.grammarCompare(answer, want)
            if !verdict.ok {
                for u in ulster {
                    let other = Mark.grammarCompare(answer, u)
                    if other.ok {
                        verdict = other
                        break
                    }
                }
            }
            out[field.key] = VerbDrillResult(ok: verdict.ok, fadaSlip: verdict.fadaSlip, typed: answer, want: want)
            total += 1
            if verdict.ok { right += 1 }
        }
        results = out
    }

    func next() {
        index += 1
        clear()
    }
}

struct VerbDrillView: View {
    let verbs: VerbData
    @StateObject private var run: VerbDrillRun
    @FocusState private var focus: String?
    /// The field the fada buttons type into.
    @State private var lastField = "P"

    init(verbs: VerbData, card: Int?) {
        self.verbs = verbs
        _run = StateObject(wrappedValue: VerbDrillRun(verbs: verbs, card: card))
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Color.clear.frame(height: 0).id("top")
                    Text(run.done ? "Positive, negative, question" : "\(run.index + 1) / \(run.items.count)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.muted)
                    if let it = run.item, verbs.irregular.indices.contains(it.card) {
                        itemPanel(it, verbs.irregular[it.card])
                    } else {
                        Panel {
                            Text("\(run.right) / \(run.total)")
                                .font(.largeTitle.weight(.bold))
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: 760)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: run.index) { _, _ in
                proxy.scrollTo("top", anchor: .top)
                lastField = "P"
                if !run.done { focus = "P" }
            }
        }
        .background(Theme.ground)
        .safeAreaInset(edge: .bottom) { actionBar }
        .navigationTitle("Dearfach, diúltach, ceist")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focus) { _, field in
            if let field = field { lastField = field }
        }
    }

    private func itemPanel(_ it: VerbDrillItem, _ card: IrregularVerb) -> some View {
        Panel {
            if let tense = verbs.grid.tenses.first(where: { $0.id == it.tense }) {
                HStack(spacing: 8) {
                    TenseTag(tense: tense)
                    Text(tense.en)
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                }
            }
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                BoxChip(verb: card.verb, box: "irreg", size: 28)
                Text("to \(card.en)").foregroundStyle(Theme.muted)
            }
            ForEach(VerbDrillRun.fields, id: \.key) { field in
                fieldBox(field)
            }
            if run.results == nil {
                HStack(spacing: 8) {
                    ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { letter in
                        Button(letter) {
                            let b = binding(lastField)
                            b.wrappedValue = b.wrappedValue + letter
                        }
                        .font(.title3.weight(.semibold))
                        .frame(minWidth: 44, minHeight: 44)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(letter) le fada")
                    }
                }
            }
        }
    }

    private func fieldBox(_ field: VerbDrillField) -> some View {
        let result = run.results?[field.key]
        return VStack(alignment: .leading, spacing: 6) {
            Text("\(Text(field.ga).bold()) (\(field.who))")
                .foregroundStyle(Theme.ink)
            TextField("Scríobh anseo", text: binding(field.key))
                .font(.title3)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .focused($focus, equals: field.key)
                .submitLabel(field.key == "Q" ? .done : .next)
                .onSubmit { submitted(field.key) }
                .disabled(run.results != nil)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(border(result), lineWidth: 2))
                .onAppear { if field.key == "P" && run.results == nil { focus = "P" } }
            if let r = result {
                VStack(alignment: .leading, spacing: 4) {
                    if r.ok {
                        Text(r.fadaSlip ? "✓ seiceáil na fadaí" : "✓ ceart!")
                            .font(Pen.font(26)).foregroundStyle(Theme.pen)
                        Text(r.want).foregroundStyle(Theme.ink)
                    } else {
                        Text("An freagra ceart · the answer").font(.subheadline).foregroundStyle(Theme.muted)
                        Text(Highlight.changes(from: r.typed, to: r.want))
                            .font(.body.weight(.bold))
                            .foregroundStyle(Theme.ink)
                            .accessibilityLabel(r.want)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
            }
        }
    }

    private func border(_ result: VerbDrillResult?) -> Color {
        guard let r = result else { return Theme.ink }
        return r.ok ? Theme.good : Theme.pen
    }

    private func binding(_ key: String) -> Binding<String> {
        switch key {
        case "P": return $run.positive
        case "N": return $run.negative
        default: return $run.question
        }
    }

    /// Return moves to the next box; on the last one it checks.
    private func submitted(_ key: String) {
        switch key {
        case "P": focus = "N"
        case "N": focus = "Q"
        default:
            focus = nil
            run.check()
        }
    }

    private var actionBar: some View {
        HStack {
            if run.done {
                NavigationLink {
                    VerbCardList(verbs: verbs)
                } label: {
                    Text("Na cártaí")
                }
                .buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary("Arís") { run.restart() }
            } else if let it = run.item, run.results != nil {
                NavigationLink {
                    VerbCardView(verbs: verbs, start: it.card)
                } label: {
                    Text("An cárta · the card")
                }
                .buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary("Ar aghaidh") { run.next() }
            } else {
                Spacer()
                primary("Seiceáil · check") {
                    focus = nil
                    run.check()
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
