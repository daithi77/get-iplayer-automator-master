import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: Store
    @State private var flow: SessionFlowRequest? = nil

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                           unit: "Aonad 1 · Cuimhne", right: "Inniu",
                           score: store.lastScore.isEmpty ? nil : store.lastScore)
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Rubric(ga: "\(store.sessionSize) cheist. Scríobh an focal ceart sa bhosca.",
                       en: "\(store.sessionSize) questions. Write the correct word in the box.")
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                ZStack(alignment: .topLeading) {
                    RuledPaper()
                    VStack(alignment: .leading, spacing: 0) {
                        PaperLine(text: store.stage == .ks3 ? "Eochairchéim 3" : "GCSE", bold: true)
                        PaperLine(text: "\(store.dueCount) focal le déanamh inniu")
                        PaperLine(text: "\(store.learnedCount) focal ar eolas, as \(store.items.count)")
                        PaperLine(text: store.streak > 0 ? "\(store.streak) lá as a chéile" : "Céad lá")
                        if store.sessionsToday > 0 {
                            PaperLine(text: "\(store.sessionsToday) babhta déanta inniu")
                        }
                    }
                    .padding(.leading, Theme.marginX + 12)
                    .padding(.trailing, 20)

                    if !store.lastScore.isEmpty {
                        PenMark(text: "maith ✓", size: 24)
                            .padding(.leading, 6)
                            .padding(.top, Theme.lineHeight + 2)
                    }
                }
                .padding(.top, 16)

                HStack {
                    Text("Gach topaic · \(store.sessionSize) fhocal")
                        .font(.footnote)
                        .foregroundColor(Theme.grey)
                    Spacer()
                    PrimaryButton(title: "Tosaigh") {
                        flow = SessionFlowRequest(title: "Cuimhne", scope: store.items)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
        }
        .fullScreenCover(item: $flow) { req in
            SessionFlow(request: req)
                .environmentObject(store)
        }
    }
}

/// What a session is about: a title for the header and the words it may draw on.
struct SessionFlowRequest: Identifiable {
    let id = UUID()
    let title: String
    let scope: [VocabItem]
}

/// Runs one session, shows its results, and offers another round on the same scope.
struct SessionFlow: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let request: SessionFlowRequest
    @State private var session: Session? = nil
    @State private var result: SessionResult? = nil

    var body: some View {
        NavigationStack {
          ZStack {
            Theme.paper.ignoresSafeArea()
            if let result {
                ResultsView(result: result, again: {
                    self.result = nil
                    session = store.makeSession(title: request.title, scope: request.scope)
                }, home: { dismiss() })
            } else if let session {
                SessionView(session: session, finish: { r in
                    store.record(r)
                    result = r
                }, quit: { dismiss() })
            }
          }
          .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            if session == nil {
                session = store.makeSession(title: request.title, scope: request.scope)
            }
        }
    }
}
