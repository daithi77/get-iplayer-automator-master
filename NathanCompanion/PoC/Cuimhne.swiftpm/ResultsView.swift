import SwiftUI

struct ResultsView: View {
    @EnvironmentObject private var store: Store
    let result: SessionResult
    let again: () -> Void
    let home: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                       unit: "Cuimhne", right: "Marc",
                       score: "\(result.rightFirstTime)/\(result.total)")
                .padding(.horizontal, 20)
                .padding(.top, 52)

            Rubric(ga: "Ceartaithe.", en: "Marked.")
                .padding(.horizontal, 20)
                .padding(.top, 16)

            ZStack(alignment: .topLeading) {
                RuledPaper()
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(result.answered.enumerated()), id: \.offset) { i, entry in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("\(i + 1).").font(.system(size: 19, weight: .bold))
                            Text(entry.item.expectedFirst).font(.system(size: 19)).foregroundColor(Theme.biro)
                            Text(entry.item.en).font(.footnote).foregroundColor(Theme.grey).lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .foregroundColor(Theme.ink)
                        .frame(height: Theme.lineHeight, alignment: .bottomLeading)
                        .padding(.bottom, 4)
                    }
                }
                .padding(.leading, Theme.marginX + 12)
                .padding(.trailing, 20)

                VStack(alignment: .center, spacing: 0) {
                    ForEach(Array(result.answered.enumerated()), id: \.offset) { _, entry in
                        PenMark(text: entry.firstTry ? "✓" : "✗", size: 26, tilt: 0)
                            .frame(height: Theme.lineHeight + 4, alignment: .bottom)
                    }
                }
                .frame(width: Theme.marginX)

                PenMark(text: comment, size: 28, tilt: -4)
                    .padding(.leading, Theme.marginX + 12)
                    .padding(.top, Theme.lineHeight * CGFloat(result.total + 1) + 10)
            }
            .padding(.top, 12)

            HStack {
                LinkButton(title: "Baile", action: home)
                Spacer()
                PrimaryButton(title: "Babhta eile", action: again)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var comment: String {
        switch result.rightFirstTime {
        case result.total: return "maith thú!"
        case 0: return "arís amárach"
        default: return result.toRevisit.count == 1 ? "ceann amháin le foghlaim" : "\(result.toRevisit.count) le foghlaim"
        }
    }
}
