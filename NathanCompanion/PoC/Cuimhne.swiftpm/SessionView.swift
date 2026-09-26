import SwiftUI

struct SessionView: View {
    @EnvironmentObject private var store: Store
    @ObservedObject var session: Session
    let finish: (SessionResult) -> Void
    let quit: () -> Void

    @State private var first = ""
    @State private var second = ""
    @State private var verdictFirst: Verdict? = nil
    @State private var verdictSecond: Verdict? = nil
    @State private var revealed = false
    @FocusState private var focus: Int?

    private var item: VocabItem? { session.current }
    private var marked: Bool { verdictFirst != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: quit) {
                    Image(systemName: "xmark").font(.body.weight(.semibold)).frame(width: 44, height: 44)
                }
                .foregroundColor(Theme.ink)
                Spacer()
            }
            .padding(.horizontal, 8)

            ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                       unit: "Cuimhne · \(session.title)",
                       right: "Ceist \(session.questionNumber) de \(session.totalQuestions)",
                       score: scoreText)
                .padding(.horizontal, 20)

            Rubric(ga: item?.hasSecondBox == true
                        ? "Scríobh an briathar agus an t-ainm briathartha."
                        : "Scríobh an focal ceart sa bhosca.",
                   en: item?.hasSecondBox == true
                        ? "Write the verb and its verbal noun."
                        : "Write the correct word in the box.")
                .padding(.horizontal, 20)
                .padding(.top, 14)

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
            .contentShape(Rectangle())
            .onTapGesture { focus = nil }

            HStack {
                if marked {
                    Spacer()
                    PrimaryButton(title: session.isLastQuestion ? "Críochnaigh" : "Ar aghaidh", action: next)
                } else {
                    LinkButton(title: revealed ? "Taispeánta" : "Taispeáin dom", action: { revealed = true })
                    Spacer()
                    PrimaryButton(title: "Seiceáil", action: check)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .toolbar { FadaToolbar(insert: insert, check: check) }
        .onAppear { focus = 0 }
    }

    // MARK: question

    private func questionBody(_ item: VocabItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text("\(session.questionNumber).").font(.system(size: 20, weight: .bold))
                Text(item.en).font(.system(size: 20))
                if let g = item.genderLabel {
                    Text("(\(g))").font(.footnote).foregroundColor(Theme.grey)
                }
            }
            .foregroundColor(Theme.ink)
            .frame(minHeight: Theme.lineHeight, alignment: .bottomLeading)

            VStack(alignment: .leading, spacing: 12) {
                ZStack(alignment: .topLeading) {
                    AnswerBox(label: item.hasSecondBox ? "Fréamh + réamhfhocal" : "Gaeilge",
                              placeholder: "", text: $first, focused: $focus, field: 0,
                              locked: marked, struck: verdictFirst?.isWrong == true,
                              onSubmit: { if item.hasSecondBox { focus = 1 } else { check() } })
                    correction(for: verdictFirst)
                }
                if item.hasSecondBox {
                    ZStack(alignment: .topLeading) {
                        AnswerBox(label: "Ainm briathartha", placeholder: "ag …",
                                  text: $second, focused: $focus, field: 1,
                                  locked: marked, struck: verdictSecond?.isWrong == true,
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
                PenMark(text: v.isWrong ? "✗" : "✓", size: 28, tilt: 0)
            }
            if let v = verdictSecond {
                PenMark(text: v.isWrong ? "✗" : "✓", size: 28, tilt: 0)
            }
        }
        .frame(width: Theme.marginX)
        .padding(.top, Theme.lineHeight * 2 - 4)
    }

    private var scoreText: String? {
        let m = session.marksSoFar
        return m.of == 0 ? nil : "\(m.right)/\(m.of)"
    }

    // MARK: actions

    private func insert(_ c: String) {
        if focus == 1 { second += c } else { first += c }
    }

    private func check() {
        guard let item, !marked else { return }
        let v1 = Marker.mark(answer: first, accepted: item.acceptedFirst, strictFadas: store.strictFadas)
        var v2: Verdict? = nil
        if item.hasSecondBox {
            v2 = Marker.mark(answer: second, accepted: item.acceptedSecond, strictFadas: store.strictFadas)
        }
        verdictFirst = v1
        verdictSecond = v2
        let allRight = !v1.isWrong && !(v2?.isWrong ?? false) && !revealed
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
            focus = 0
        }
    }
}
