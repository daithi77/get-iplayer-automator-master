import SwiftUI

struct SessionView: View {
    @EnvironmentObject private var store: Store
    @ObservedObject var session: Session
    let finish: (SessionResult) -> Void

    enum Field: Hashable { case first, second }

    @State private var first = ""
    @State private var second = ""
    @State private var verdictFirst: Verdict? = nil
    @State private var verdictSecond: Verdict? = nil
    @State private var revealed = false
    @FocusState private var focus: Field?

    private var item: VocabItem? { session.current }
    private var marked: Bool { verdictFirst != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                       unit: "Aonad 1 · Cuimhne",
                       right: "Ceist \(session.questionNumber) de \(session.totalQuestions)",
                       score: scoreText)
                .padding(.horizontal, 20)
                .padding(.top, 12)

            Rubric(ga: item?.isVerb == true
                        ? "Scríobh an briathar agus an t-ainm briathartha."
                        : "Scríobh an focal ceart sa bhosca.",
                   en: item?.isVerb == true
                        ? "Write the verb and its verbal noun."
                        : "Write the correct word in the box.")
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ZStack(alignment: .topLeading) {
                RuledPaper()
                if let item {
                    questionBody(item)
                        .padding(.leading, Theme.marginX + 12)
                        .padding(.trailing, 20)
                    marginMarks
                }
            }
            .padding(.top, 12)
            .onTapGesture { focus = nil }

            HStack {
                if marked {
                    Spacer()
                    PrimaryButton(title: session.index + 1 < session.queue.count ? "Ar aghaidh" : "Críochnaigh", action: next)
                } else {
                    LinkButton(title: revealed ? "Taispeánta" : "Taispeáin dom", action: reveal)
                    Spacer()
                    PrimaryButton(title: "Seiceáil", action: check)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { c in
                    Button(c) { insert(c) }
                        .font(.system(size: 22))
                        .frame(minWidth: 44, minHeight: 44)
                }
                Spacer()
                Button("Seiceáil", action: check).fontWeight(.bold)
            }
        }
        .onAppear { focus = .first }
    }

    // MARK: question

    private func questionBody(_ item: VocabItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(session.questionNumber).").font(.system(size: 20, weight: .bold))
                Text(item.en).font(.system(size: 20))
                if item.type == "noun", item.gender == "m" {
                    Text("(fir.)").font(.footnote).foregroundColor(Theme.grey)
                }
            }
            .foregroundColor(Theme.ink)
            .frame(height: Theme.lineHeight, alignment: .bottomLeading)

            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    AnswerBox(label: item.isVerb ? "Fréamh + réamhfhocal" : "Gaeilge",
                              placeholder: "", text: $first, focused: $focus, field: .first,
                              locked: marked, struck: isWrong(verdictFirst),
                              onSubmit: { if item.isVerb { focus = .second } else { check() } })
                    correction(for: verdictFirst)
                }
                if item.isVerb {
                    ZStack(alignment: .topLeading) {
                        AnswerBox(label: "Ainm briathartha", placeholder: "ag …",
                                  text: $second, focused: $focus, field: .second,
                                  locked: marked, struck: isWrong(verdictSecond),
                                  onSubmit: check)
                        correction(for: verdictSecond)
                    }
                }
            }
            .padding(.top, Theme.lineHeight)

            if revealed && !marked {
                Text(revealText(item))
                    .font(.system(size: 17))
                    .foregroundColor(Theme.grey)
                    .frame(height: Theme.lineHeight, alignment: .bottomLeading)
                    .padding(.top, 8)
            }
        }
    }

    private func revealText(_ item: VocabItem) -> String {
        if let vn = item.vn { return item.expectedFirst + "  ·  " + vn }
        return item.expectedFirst
    }

    /// The right answer written above a struck-out wrong one, in the marking hand.
    @ViewBuilder
    private func correction(for v: Verdict?) -> some View {
        switch v {
        case .wrong(let right):
            PenMark(text: right, size: 24, tilt: -2)
                .padding(.leading, 134)
                .offset(y: -24)
        case .rightButFada(let right):
            PenMark(text: "fada! \(right)", size: 20, tilt: -2)
                .padding(.leading, 134)
                .offset(y: -22)
        default:
            EmptyView()
        }
    }

    private var marginMarks: some View {
        VStack(alignment: .center, spacing: 34) {
            if let v = verdictFirst {
                PenMark(text: isWrong(v) ? "✗" : "✓", size: 28, tilt: 0)
            }
            if let v = verdictSecond {
                PenMark(text: isWrong(v) ? "✗" : "✓", size: 28, tilt: 0)
            }
        }
        .frame(width: Theme.marginX)
        .padding(.top, Theme.lineHeight * 2 - 4)
    }

    private var scoreText: String? {
        let m = session.marksSoFar
        return m.of == 0 ? nil : "\(m.right)/\(m.of)"
    }

    private func isWrong(_ v: Verdict?) -> Bool {
        if case .wrong = v { return true }
        return false
    }

    // MARK: actions

    private func insert(_ c: String) {
        switch focus {
        case .second: second += c
        default: first += c
        }
    }

    private func reveal() {
        revealed = true
    }

    private func check() {
        guard let item, !marked else { return }
        let v1 = Marker.mark(answer: first, accepted: item.acceptedFirst, strictFadas: store.strictFadas)
        var v2: Verdict? = nil
        if item.isVerb {
            v2 = Marker.mark(answer: second, accepted: item.acceptedSecond, strictFadas: store.strictFadas)
        }
        verdictFirst = v1
        verdictSecond = v2
        let allRight = !isWrong(v1) && !isWrong(v2) && !revealed
        session.record(item, correct: allRight)
        focus = nil
    }

    private func next() {
        session.advance()
        first = ""; second = ""
        verdictFirst = nil; verdictSecond = nil
        revealed = false
        if session.isFinished {
            finish(session.result())
        } else {
            focus = .first
        }
    }
}
