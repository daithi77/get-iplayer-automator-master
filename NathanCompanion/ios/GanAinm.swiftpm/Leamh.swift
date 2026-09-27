import SwiftUI

// MARK: - Léitheoireacht agus aistriúchán: reading and translation, AS and A2, in the worksheet layout.
// The passage, a glossary, questions, translation into English, and translation into Irish a chunk at a time.

struct LeamhHome: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DraftBanner()
                Text("Read the passage, check the glossary, answer the questions, then translate: into English, and into Irish a chunk at a time.")
                    .foregroundStyle(Theme.muted)
                ForEach(["AS", "A2"], id: \.self) { level in
                    let passages = store.leamh.filter { $0.level == level && !$0.isTeacherLed }
                    if !passages.isEmpty {
                        Text(level)
                            .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                            .padding(.top, 8)
                        ForEach(passages) { passage in
                            NavigationLink {
                                LeamhView(passage: passage)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(passage.icon).font(.system(size: 34)).accessibilityHidden(true)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(passage.title).font(.headline).foregroundStyle(Theme.ink)
                                        Text("\(passage.titleEn ?? "") · \(passage.allQuestions.count) ceist")
                                            .font(.subheadline)
                                            .foregroundStyle(Theme.muted)
                                    }
                                    Spacer(minLength: 8)
                                    Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(3)).accessibilityHidden(true)
                                }
                                .padding(14)
                                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Léitheoireacht agus aistriúchán")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// The result of checking one translation into Irish, with what was typed at the time.
struct LeamhCheck {
    let ok: Bool
    let fadaSlip: Bool
    let typed: String
}

struct LeamhView: View {
    @EnvironmentObject private var store: Store
    let passage: LeamhPassage
    /// Checked translations into Irish, by sentence. Cleared each time the passage is opened.
    @State private var checks: [Int: LeamhCheck] = [:]
    @State private var showGlossary = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("\(passage.titleEn ?? "") · \(passage.level ?? "")")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                DraftBanner()
                passagePanel
                questionsPanel
                if let lines = passage.toEnglish, !lines.isEmpty {
                    toEnglishPanel(lines)
                }
                if let lines = passage.toIrish, !lines.isEmpty {
                    toIrishPanel(lines)
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle(passage.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var passagePanel: some View {
        let glossary = passage.glossary ?? []
        return Panel {
            Text("An sliocht · the passage")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array((passage.passage ?? []).enumerated()), id: \.offset) { _, paragraph in
                    Text(paragraph)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            DisclosureGroup(isExpanded: $showGlossary) {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                    ForEach(Array(glossary.enumerated()), id: \.offset) { _, entry in
                        Divider()
                        GridRow {
                            Text(entry.ga).bold().foregroundStyle(Theme.ink)
                            Text(entry.en ?? "").foregroundStyle(Theme.ink)
                        }
                    }
                }
                .padding(.top, 4)
            } label: {
                Text("Gluais · glossary (\(glossary.count))").font(.headline).foregroundStyle(Theme.ink)
            }
            .tint(Theme.columnInk(0))
        }
    }

    private var questionsPanel: some View {
        Panel {
            Text("Ceisteanna · questions")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            ForEach(Array(passage.allQuestions.enumerated()), id: \.offset) { k, question in
                VStack(alignment: .leading, spacing: 6) {
                    Text(LeamhView.questionLine(k, question))
                        .foregroundStyle(Theme.ink)
                    OwnBox(key: "leq:\(passage.id):\(k)", minHeight: 70, irish: question.inIrish)
                    AnswerBox(label: "Freagra samplach · model answer", text: question.answer ?? "")
                }
                .padding(.vertical, 6)
            }
        }
    }

    /// "1. The question (2 marks, answer in English)", the number and question bold.
    private static func questionLine(_ k: Int, _ question: LeamhQuestion) -> AttributedString {
        let given = question.marks ?? 0
        let marks = given > 0 ? given : 1
        var line = AttributedString("\(k + 1). \(question.q ?? "") ")
        line.inlinePresentationIntent = .stronglyEmphasized
        var detail = AttributedString("(\(marks) \(marks > 1 ? "marks" : "mark"), answer in \(question.inIrish ? "Irish" : "English"))")
        detail.foregroundColor = Theme.muted
        return line + detail
    }

    private func toEnglishPanel(_ lines: [GaEn]) -> some View {
        Panel {
            Text("Aistrigh go Béarla · translate into English")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            ForEach(Array(lines.enumerated()), id: \.offset) { k, line in
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(k + 1). \(line.ga)").font(.headline).foregroundStyle(Theme.ink)
                    OwnBox(key: "lee:\(passage.id):\(k)", placeholder: "Write your English here", minHeight: 70, irish: false)
                    AnswerBox(label: "Aistriúchán samplach · model translation", text: line.en ?? "")
                }
                .padding(.vertical, 6)
            }
        }
    }

    private func toIrishPanel(_ lines: [LeamhToIrish]) -> some View {
        Panel {
            Text("Aistrigh go Gaeilge · translate into Irish")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            Text("Work a chunk at a time. Tap Leid for the chunks, then write the whole sentence and check it.")
                .font(.subheadline).foregroundStyle(Theme.muted)
            ForEach(Array(lines.enumerated()), id: \.offset) { k, line in
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(k + 1). \(line.en ?? "")").font(.headline).foregroundStyle(Theme.ink)
                    if let chunks = line.chunks, !chunks.isEmpty {
                        ChunkHints(chunks: chunks)
                    }
                    TextField("Scríobh as Gaeilge", text: Binding(
                        get: { store.ownAnswer(LeamhView.irishKey(passage.id, k)) },
                        set: { store.setOwnAnswer(LeamhView.irishKey(passage.id, k), $0) }), axis: .vertical)
                        .lineLimit(2...5)
                        .textInputAutocapitalization(.sentences)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.rule))
                    Button {
                        check(k, line)
                    } label: {
                        Text("Seiceáil · check").font(.subheadline.weight(.semibold))
                    }
                    .buttonStyle(.bordered)
                    if let result = checks[k] {
                        feedback(result, line)
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    @ViewBuilder private func feedback(_ result: LeamhCheck, _ line: LeamhToIrish) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if result.ok {
                Text(result.fadaSlip ? "✓ seiceáil na fadaí" : "✓ ceart!")
                    .font(Pen.font(26)).foregroundStyle(Theme.pen)
                Text(line.ga ?? "").foregroundStyle(Theme.ink)
            } else {
                Text("An freagra ceart · the model answer").font(.subheadline).foregroundStyle(Theme.muted)
                Text(Highlight.changes(from: result.typed, to: line.ga ?? ""))
                    .font(.body.weight(.bold))
                    .foregroundStyle(Theme.ink)
                    .accessibilityLabel(line.ga ?? "")
                if let alt = line.alt, !alt.isEmpty {
                    Text("nó · or: \(alt)").font(.subheadline).foregroundStyle(Theme.muted)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
    }

    private static func irishKey(_ id: String, _ k: Int) -> String { "lei:\(id):\(k)" }

    /// Marks the pupil's Irish as the grammar lessons do (both verb forms allowed, a missing fada spotted),
    /// against the answer and then against the other good answer.
    private func check(_ k: Int, _ line: LeamhToIrish) {
        let typed = store.ownAnswer(LeamhView.irishKey(passage.id, k))
        guard !typed.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        var verdict = Mark.grammarCompare(typed, line.ga ?? "")
        if !verdict.ok, let alt = line.alt, !alt.isEmpty {
            let other = Mark.grammarCompare(typed, alt)
            if other.ok { verdict = other }
        }
        checks[k] = LeamhCheck(ok: verdict.ok, fadaSlip: verdict.fadaSlip, typed: typed)
    }
}

/// A model answer or translation, held back until opened.
struct AnswerBox: View {
    let label: String
    let text: String
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 4)
        } label: {
            Text(label).font(.headline).foregroundStyle(Theme.ink)
        }
        .tint(Theme.columnInk(0))
    }
}

/// Leid: the sentence's chunks, English then Irish, held back until opened.
struct ChunkHints: View {
    let chunks: [[String]]
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                ForEach(Array(chunks.enumerated()), id: \.offset) { _, pair in
                    Divider()
                    GridRow {
                        Text(pair.first ?? "")
                        Text("→")
                            .foregroundStyle(Theme.muted)
                            .accessibilityHidden(true)
                        Text(pair.count > 1 ? pair[1] : "").bold()
                    }
                }
            }
            .foregroundStyle(Theme.ink)
            .padding(.top, 4)
        } label: {
            Text("Leid · the chunks").font(.headline).foregroundStyle(Theme.ink)
        }
        .tint(Theme.columnInk(0))
    }
}
