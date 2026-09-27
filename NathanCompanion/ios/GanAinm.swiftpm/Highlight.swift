import SwiftUI

/// Marks an answer against its prompt, letter by letter, as the web does (`hl` and `markWord` in index.src.html).
/// Words already in the prompt are left alone. A new particle (an, ní, go, ...) is green. Any other new word is
/// compared with the prompt's words once initial mutations are set aside (d', bhf, mb, gc, n-, t-, h, séimhiú),
/// allowing for syncope in the base, and only the added mutation letters and the changed ending are red.
/// A word that matches nothing is red throughout. Both marks are bold and underlined (see `Marking`).
enum Highlight {
    enum Kind: Equatable {
        case plain, changed, particle
    }

    struct Segment: Equatable {
        var text: String
        let kind: Kind
    }

    /// The answer as runs of plain, changed and particle text.
    static func segments(from prompt: String, to answer: String) -> [Segment] {
        let have = wordsOf(swapping(prompt, [":", ";", "/"], with: " "))
        let known = Set(have)
        var out: [Segment] = []
        func add<C: Collection>(_ scalars: C, _ kind: Kind) where C.Element == Unicode.Scalar {
            guard !scalars.isEmpty else { return }
            let text = string(scalars)
            if let last = out.last, last.kind == kind {
                out[out.count - 1].text += text
            } else {
                out.append(Segment(text: text, kind: kind))
            }
        }
        for token in tokens(answer) {
            let w = token.scalars
            if token.isSpace {
                add(w, .plain)
                continue
            }
            // Leading ( " ' ‘ “ and trailing . , ! ? ; : ) " ' ’ ” stay outside the word.
            var start = 0
            while start < w.count && leading.contains(w[start]) { start += 1 }
            var end = w.count
            while end > start && trailing.contains(w[end - 1]) { end -= 1 }
            let core = Array(w[start..<end])
            let k = fold(norm(string(core)))
            if k.isEmpty || known.contains(k) || !core.contains(where: isLetter) {
                add(w, .plain)
                continue
            }
            add(w[0..<start], .plain)
            if particles.contains(k) {
                add(core, .particle)
            } else if let red = markWord(core, have) {
                for (i, c) in core.enumerated() {
                    add(CollectionOfOne(c), red.contains(i) ? .changed : .plain)
                }
            } else {
                add(core, .changed)
            }
            add(w[end..<w.count], .plain)
        }
        return out
    }

    /// The answer with the changes marked, for a SwiftUI Text.
    static func changes(from prompt: String, to answer: String) -> AttributedString {
        var out = AttributedString()
        for segment in segments(from: prompt, to: answer) {
            switch segment.kind {
            case .plain:
                out += AttributedString(segment.text)
            case .changed:
                out += Marking.marked(segment.text, particle: false)
            case .particle:
                out += Marking.marked(segment.text, particle: true)
            }
        }
        return out
    }

    // MARK: - The web's helpers, scalar for scalar

    private static let particles: Set<String> = Set([
        "an", "is", "ar", "ní", "níor", "nár", "nach", "go", "gur", "cha", "char", "a", "ná", "má", "dá",
        "mura", "muna", "ba", "níorbh", "arbh", "gurbh", "nárbh"
    ].map { Highlight.fold($0) })

    private static let leading: Set<Unicode.Scalar> = ["(", "\"", "'", "\u{2018}", "\u{201C}"]
    private static let trailing: Set<Unicode.Scalar> = [".", ",", "!", "?", ";", ":", ")", "\"", "'", "\u{2019}", "\u{201D}"]
    private static let lenitable: Set<Unicode.Scalar> = ["b", "c", "d", "f", "g", "m", "p", "s", "t"]
    private static let vowels: Set<Unicode.Scalar> = ["a", "e", "i", "o", "u"]
    private static let apostrophe: Unicode.Scalar = "'"

    private struct Token {
        let scalars: [Unicode.Scalar]
        let isSpace: Bool
    }

    /// JavaScript's \s.
    private static func isSpace(_ u: Unicode.Scalar) -> Bool {
        switch u.value {
        case 0x09...0x0D, 0x20, 0xA0, 0x1680, 0x2000...0x200A, 0x2028, 0x2029, 0x202F, 0x205F, 0x3000, 0xFEFF:
            return true
        default:
            return false
        }
    }

    /// JavaScript's \p{L}.
    private static func isLetter(_ u: Unicode.Scalar) -> Bool {
        switch u.properties.generalCategory {
        case .uppercaseLetter, .lowercaseLetter, .titlecaseLetter, .modifierLetter, .otherLetter:
            return true
        default:
            return false
        }
    }

    private static func string<S: Sequence>(_ scalars: S) -> String where S.Element == Unicode.Scalar {
        var s = ""
        s.unicodeScalars.append(contentsOf: scalars)
        return s
    }

    private static func swapping(_ s: String, _ set: Set<Unicode.Scalar>, with replacement: Unicode.Scalar) -> String {
        string(s.unicodeScalars.map { set.contains($0) ? replacement : $0 })
    }

    /// Runs of space and non-space, in order (the web's split(/(\s+)/)).
    private static func tokens(_ s: String) -> [Token] {
        var out: [Token] = []
        var run: [Unicode.Scalar] = []
        var runIsSpace = false
        for u in s.unicodeScalars {
            let space = isSpace(u)
            if !run.isEmpty && space != runIsSpace {
                out.append(Token(scalars: run, isSpace: runIsSpace))
                run = []
            }
            runIsSpace = space
            run.append(u)
        }
        if !run.isEmpty { out.append(Token(scalars: run, isSpace: runIsSpace)) }
        return out
    }

    /// Fadas and other combining marks taken off (the web's fold). Case is kept.
    static func fold(_ s: String) -> String {
        var kept = String.UnicodeScalarView()
        for u in s.decomposedStringWithCanonicalMapping.unicodeScalars where !(0x300...0x36F).contains(u.value) {
            kept.append(u)
        }
        return String(kept).precomposedStringWithCanonicalMapping
    }

    /// Lower case, curly apostrophes straightened, . ! ? and commas dropped, spaces collapsed (the web's norm).
    static func norm(_ s: String) -> String {
        var words: [String] = []
        var current: [Unicode.Scalar] = []
        for var u in s.lowercased().unicodeScalars {
            if u == "\u{2019}" || u == "\u{2018}" { u = apostrophe }
            if u == "." || u == "!" || u == "?" || u == "," || isSpace(u) {
                if !current.isEmpty { words.append(string(current)) }
                current = []
            } else {
                current.append(u)
            }
        }
        if !current.isEmpty { words.append(string(current)) }
        return words.joined(separator: " ")
    }

    /// The prompt's words, in order: brackets and blanks (two or more underscores) taken out, normalised, folded.
    private static func wordsOf(_ text: String) -> [String] {
        var cleaned: [Unicode.Scalar] = []
        var underscores = 0
        func flush() {
            if underscores >= 2 {
                cleaned.append(" ")
            } else if underscores == 1 {
                cleaned.append("_")
            }
            underscores = 0
        }
        for u in text.unicodeScalars {
            if u == "_" {
                underscores += 1
                continue
            }
            flush()
            cleaned.append(u == "(" || u == ")" ? " " : u)
        }
        flush()
        return norm(string(cleaned)).split(separator: " ").map { fold(String($0)) }
    }

    /// One letter folded for comparing: no fada, lower case, straight apostrophe (the web's fc).
    private static func fc(_ c: Unicode.Scalar) -> [Unicode.Scalar] {
        var bare = String.UnicodeScalarView()
        for u in String(Character(c)).decomposedStringWithCanonicalMapping.unicodeScalars where !(0x300...0x36F).contains(u.value) {
            bare.append(u)
        }
        return String(bare).lowercased().unicodeScalars.map { u in
            (u == "\u{2019}" || u == "\u{2018}") ? apostrophe : u
        }
    }

    /// The initial mutations a folded word may carry: the kind, and the positions of the added letters.
    private static func muts(_ w: [Unicode.Scalar]) -> [(kind: String, added: [Int])] {
        func at(_ i: Int) -> Unicode.Scalar? { i < w.count ? w[i] : nil }
        var o: [(kind: String, added: [Int])] = [(kind: "", added: [])]
        if at(0) == "d" && at(1) == apostrophe {
            o.append((kind: "d'", added: [0, 1]))
            if at(3) == "h", let c = at(2), lenitable.contains(c) {
                o.append((kind: "d'h", added: [0, 1, 3]))
            }
        }
        if at(0) == "b" && at(1) == "h" && at(2) == "f" {
            o.append((kind: "u", added: [0, 1]))
        }
        if let c0 = at(0), let c1 = at(1) {
            let pair = string([c0, c1])
            if ["mb", "gc", "nd", "dt", "bp", "ng", "ts"].contains(pair) {
                o.append((kind: "u", added: [0]))
            }
        }
        if let c0 = at(0), c0 == "n" || c0 == "t" || c0 == "h", at(1) == "-" {
            o.append((kind: "p", added: [0, 1]))
        }
        if at(0) == "h", let c1 = at(1), vowels.contains(c1) {
            o.append((kind: "h", added: [0]))
        }
        if at(1) == "h", let c0 = at(0), lenitable.contains(c0) {
            o.append((kind: "s", added: [1]))
        }
        return o
    }

    private struct Match {
        let score: Int
        let red: Set<Int>
        let kept: [Int]
        let p: Int
        let ra: [Unicode.Scalar]
        let rb: [Unicode.Scalar]
    }

    /// The letters of a new word to mark red, from its best match among the prompt's words; nil when none matches.
    private static func markWord(_ cs: [Unicode.Scalar], _ have: [String]) -> Set<Int>? {
        let a: [Unicode.Scalar] = cs.flatMap { fc($0) }
        var best: Match? = nil
        for h in have {
            if h.utf16.count < 2 { continue }
            let hb: [Unicode.Scalar] = h.unicodeScalars.flatMap { fc($0) }
            for (ka, ia) in muts(a) {
                for (kb, ib) in muts(hb) {
                    let kept = cs.indices.filter { !ia.contains($0) }
                    let ra: [Unicode.Scalar] = kept.compactMap { $0 < a.count ? a[$0] : nil }
                    let rb0: [Unicode.Scalar] = hb.indices.filter { !ib.contains($0) }.map { hb[$0] }
                    // Syncope: tabhair, tabharfaidh; imir, imreoidh.
                    var variants = [rb0]
                    for i in stride(from: max(1, rb0.count - 3), to: rb0.count, by: 1) where vowels.contains(rb0[i]) {
                        var v = rb0
                        v.remove(at: i)
                        variants.append(v)
                    }
                    for rb in variants {
                        var p = 0
                        while p < ra.count && p < rb.count && ra[p] == rb[p] { p += 1 }
                        if !(p >= 3 || (p >= 2 && p == rb.count)) || p * 2 < ra.count { continue }
                        let score = p * 10 - (ka.isEmpty ? 0 : 1) - (kb.isEmpty ? 0 : 1) - (ka == kb ? 0 : 1)
                        if best == nil || score > best!.score {
                            best = Match(score: score, red: ka == kb ? [] : Set(ia), kept: kept, p: p, ra: ra, rb: rb)
                        }
                    }
                }
            }
        }
        guard let m = best else { return nil }
        var red = m.red
        let ta = Array(m.ra[m.p...]), tb = Array(m.rb[m.p...])
        let end = !tb.isEmpty && ta.count >= tb.count && Array(ta.suffix(tb.count)) == tb ? m.ra.count - tb.count : m.ra.count
        if end > m.p {
            for j in m.p..<end { red.insert(m.kept[j]) }
        }
        return red
    }
}
