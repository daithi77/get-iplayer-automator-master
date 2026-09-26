import SwiftUI

// MARK: - Mutation engine (Ulster forms)

enum Mutate {
    static let vowels: Set<Character> = ["a", "e", "i", "o", "u", "á", "é", "í", "ó", "ú"]

    static func startsWithVowel(_ w: String) -> Bool {
        guard let f = w.first?.lowercased().first else { return false }
        return vowels.contains(f)
    }

    static func first(_ w: String) -> Character? { w.first?.lowercased().first }
    static func second(_ w: String) -> Character? {
        guard w.count > 1 else { return nil }
        return w[w.index(after: w.startIndex)].lowercased().first
    }

    /// Séimhiú: b c d f g m p t take an h. Others are left alone.
    static func lenite(_ w: String) -> String {
        guard let f = w.first, let fl = first(w), "bcdfgmpt".contains(fl) else { return w }
        if second(w) == "h" { return w }
        return String(f) + "h" + w.dropFirst()
    }

    /// Whether a word already carries lenition on its first letter.
    static func isLenited(_ w: String) -> Bool {
        guard let fl = first(w), "bcdfgmpt".contains(fl) else { return false }
        return second(w) == "h" && !(fl == "s" )
    }

    /// Whether a word carries urú (eclipsis) at the front.
    static func hasEclipsis(_ w: String) -> Bool {
        let l = w.lowercased()
        for p in ["mb", "gc", "nd", "bhf", "ng", "bp", "dt", "n-"] where l.hasPrefix(p) {
            // "ng" could be a genuine word start (ngach is not a word; nglas is eclipsed glas)
            return true
        }
        return false
    }

    /// The definite article with a singular noun.
    static func article(_ w: String, gender: String) -> String {
        if gender == "m" {
            return startsWithVowel(w) ? "an t-" + w : "an " + w
        }
        if startsWithVowel(w) { return "an " + w }
        if first(w) == "s", let s = second(w), vowels.contains(s) || "lnr".contains(s) {
            return "an t" + w
        }
        if let fl = first(w), "bcfgmp".contains(fl) { return "an " + lenite(w) }
        return "an " + w
    }

    /// A simple preposition plus the article, Ulster style: séimhiú on b c f g m p,
    /// nothing on d t s or a vowel. "sa" takes "san" before a vowel.
    static func prepArticle(_ prep: String, _ w: String) -> String {
        if prep == "sa" {
            if startsWithVowel(w) { return "san " + w }
            if first(w) == "f" { return "san " + lenite(w) }
        }
        if startsWithVowel(w) { return prep + " " + w }
        if let fl = first(w), "bcfgmp".contains(fl) { return prep + " " + lenite(w) }
        return prep + " " + w
    }
}

// MARK: - Drill questions

struct GrammarQuestion {
    enum Kind { case article, prepArticle(String) }
    let noun: VocabItem
    let kind: Kind

    var pieces: (String, String) {
        switch kind {
        case .article: return ("an", noun.ga)
        case .prepArticle(let p): return (p, noun.ga)
        }
    }

    var expected: String {
        switch kind {
        case .article: return Mutate.article(noun.ga, gender: noun.gender ?? "m")
        case .prepArticle(let p): return Mutate.prepArticle(p, noun.ga)
        }
    }

    var ruleGa: String {
        switch kind {
        case .article:
            if noun.gender == "f" {
                if Mutate.startsWithVowel(noun.ga) { return "Ainmfhocal baininscneach a thosaíonn le guta: ní athraíonn sé i ndiaidh an ailt (an aimsir, an oíche)." }
                if Mutate.first(noun.ga) == "s" { return "Ainmfhocal baininscneach a thosaíonn le s: cuirtear t roimhe (an tseachtain, an tsráid)." }
                if let f = Mutate.first(noun.ga), "bcfgmp".contains(f) { return "Ainmfhocal baininscneach: séimhiú i ndiaidh an ailt (an bhean, an fhuinneog)." }
                return "Ainmfhocal baininscneach a thosaíonn le d, t, l, n nó r: ní athraíonn sé (an deoch, an tír)."
            }
            if Mutate.startsWithVowel(noun.ga) { return "Ainmfhocal firinscneach a thosaíonn le guta: cuirtear t- roimhe (an t-am, an t-ainm)." }
            return "Ainmfhocal firinscneach: ní athraíonn sé i ndiaidh an ailt (an fear, an clár)."
        case .prepArticle:
            if Mutate.startsWithVowel(noun.ga) { return "Guta i ndiaidh réamhfhocail agus an ailt: ní athraíonn sé (ar an uisce)." }
            if let f = Mutate.first(noun.ga), "bcfgmp".contains(f) { return "I nGaeilge Uladh cuirtear séimhiú ar an ainmfhocal i ndiaidh réamhfhocail agus an ailt: ar an bhord, sa charr, leis an mhúinteoir." }
            return "I nGaeilge Uladh ní athraíonn d, t ná s i ndiaidh réamhfhocail agus an ailt: ar an doras, ag an siopa."
        }
    }

    var ruleEn: String {
        switch kind {
        case .article:
            if noun.gender == "f" {
                if Mutate.startsWithVowel(noun.ga) { return "Feminine noun starting with a vowel: no change after the article." }
                if Mutate.first(noun.ga) == "s" { return "Feminine noun starting with s: t goes in front." }
                if let f = Mutate.first(noun.ga), "bcfgmp".contains(f) { return "Feminine noun: lenite after the article." }
                return "Feminine noun starting with d, t, l, n or r: no change." }
            if Mutate.startsWithVowel(noun.ga) { return "Masculine noun starting with a vowel: t- goes in front." }
            return "Masculine noun: no change after the article."
        case .prepArticle:
            if Mutate.startsWithVowel(noun.ga) { return "Vowel after preposition and article: no change." }
            if let f = Mutate.first(noun.ga), "bcfgmp".contains(f) { return "Ulster Irish lenites after a preposition and the article." }
            return "Ulster Irish leaves d, t and s alone after a preposition and the article."
        }
    }

    /// Explains what went wrong, in the marking hand's voice.
    func diagnose(_ answer: String) -> String {
        let a = answer.trimmingCharacters(in: .whitespaces)
        let nounPart = a.split(separator: " ").last.map(String.init) ?? a
        if Mutate.hasEclipsis(nounPart) { return "urú, ní séimhiú!" }
        let exp = expected.split(separator: " ").last.map(String.init) ?? expected
        if Mutate.isLenited(exp) && !Mutate.isLenited(nounPart) { return "séimhiú de dhíth" }
        if !Mutate.isLenited(exp) && Mutate.isLenited(nounPart) { return "gan séimhiú anseo" }
        if exp.lowercased().hasPrefix("t-") && !nounPart.lowercased().hasPrefix("t-") { return "t- de dhíth" }
        if exp.lowercased().hasPrefix("ts") && !nounPart.lowercased().hasPrefix("ts") { return "t roimh s" }
        return "féach an riail"
    }

    static let preps = ["ar an", "leis an", "ag an", "as an", "faoin", "don", "ón", "chuig an", "sa"]

    static func random(from nouns: [VocabItem]) -> GrammarQuestion? {
        guard let n = nouns.randomElement() else { return nil }
        if Bool.random() {
            return GrammarQuestion(noun: n, kind: .article)
        }
        var p = preps.randomElement() ?? "ar an"
        if p == "sa" && (Mutate.startsWithVowel(n.ga) || Mutate.first(n.ga) == "f") { p = "ar an" }
        return GrammarQuestion(noun: n, kind: .prepArticle(p))
    }
}

// MARK: - Drill screen

struct GrammarView: View {
    @EnvironmentObject private var store: Store
    @State private var question: GrammarQuestion? = nil
    @State private var answer = ""
    @State private var verdict: Verdict? = nil
    @State private var diagnosis = ""
    @State private var number = 0
    @State private var right = 0
    @FocusState private var focus: Int?

    private var nouns: [VocabItem] {
        store.items.filter { $0.type == "noun" && $0.gender != nil && !$0.ga.contains(" ") && !$0.ga.contains(",") }
    }

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                           unit: "Aonad 3 · Gramadach",
                           right: number == 0 ? "An t-alt" : "Ceist \(number)",
                           score: number > 1 || verdict != nil ? "\(right)/\(verdict == nil ? number - 1 : number)" : nil)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Rubric(ga: "Cuir le chéile. Scríobh an fhoirm cheart.",
                       en: "Put together. Write the correct form.")
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                ZStack(alignment: .topLeading) {
                    RuledPaper()
                    if let q = question {
                        questionBody(for: q)
                            .padding(.leading, Theme.marginX + 12)
                            .padding(.trailing, 20)
                        if let v = verdict {
                            PenMark(text: v.isWrong ? "✗" : "✓", size: 28, tilt: 0)
                                .frame(width: Theme.marginX)
                                .padding(.top, Theme.lineHeight * 2 - 4)
                        }
                    } else {
                        Text("Níl ainmfhocail le hinscne sa liosta seo.")
                            .foregroundColor(Theme.grey)
                            .padding(.leading, Theme.marginX + 12)
                            .padding(.top, 8)
                    }
                }
                .padding(.top, 12)
                .contentShape(Rectangle())
                .onTapGesture { focus = nil }

                HStack {
                    if verdict != nil {
                        Spacer()
                        PrimaryButton(title: "Ceist eile", action: next)
                    } else {
                        LinkButton(title: "An riail", action: { diagnosis = question?.ruleGa ?? "" })
                        Spacer()
                        PrimaryButton(title: "Seiceáil", action: check)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .toolbar { FadaToolbar(insert: { answer += $0 }, check: check) }
        .onAppear { if question == nil { next() } }
    }

    private func questionBody(for q: GrammarQuestion) -> some View {
        let (a, b) = q.pieces
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(number).").font(.system(size: 20, weight: .bold))
                Text(a).font(.system(size: 22, weight: .semibold))
                Text("+").foregroundColor(Theme.grey)
                Text(b).font(.system(size: 22, weight: .semibold))
                if let g = q.noun.genderLabel { Text("(\(g))").font(.footnote).foregroundColor(Theme.grey) }
            }
            .foregroundColor(Theme.ink)
            .frame(minHeight: Theme.lineHeight, alignment: .bottomLeading)

            Text(q.noun.en).font(.footnote).foregroundColor(Theme.grey)
                .frame(height: Theme.lineHeight, alignment: .bottomLeading)

            ZStack(alignment: .topLeading) {
                AnswerBox(label: "", placeholder: "", text: $answer, focused: $focus, field: 0,
                          locked: verdict != nil, struck: verdict?.isWrong == true, onSubmit: check)
                if case .wrong(let rightForm) = verdict {
                    PenMark(text: rightForm, size: 24, tilt: -2).padding(.leading, 12).offset(y: -24)
                }
                if case .rightButFada(let rightForm) = verdict {
                    PenMark(text: "fada! \(rightForm)", size: 20, tilt: -2).padding(.leading, 12).offset(y: -22)
                }
            }
            .padding(.top, Theme.lineHeight)

            if !diagnosis.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    if verdict?.isWrong == true {
                        PenMark(text: q.diagnose(answer), size: 24, tilt: -1)
                    }
                    Text(q.ruleGa).font(.system(size: 15)).foregroundColor(Theme.ink)
                    Text(q.ruleEn).font(.footnote).foregroundColor(Theme.grey)
                }
                .padding(12)
                .background(Color.white.opacity(0.85))
                .overlay(Rectangle().stroke(Theme.pen, lineWidth: 1.5))
                .padding(.top, 20)
            }
        }
    }

    private func check() {
        guard let q = question, verdict == nil else { return }
        let v = Marker.mark(answer: answer, accepted: [q.expected], strictFadas: store.strictFadas)
        verdict = v
        if !v.isWrong { right += 1 }
        diagnosis = q.ruleGa
        focus = nil
    }

    private func next() {
        question = GrammarQuestion.random(from: nouns)
        answer = ""; verdict = nil; diagnosis = ""
        number += 1
        focus = 0
    }
}
