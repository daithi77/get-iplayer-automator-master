import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: Store
    let start: () -> Void
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                       unit: "Aonad 1 · Cuimhne", right: "Inniu",
                       score: store.lastScore.isEmpty ? nil : store.lastScore)
                .padding(.horizontal, 20)
                .padding(.top, 12)

            Rubric(ga: "Cúig cheist. Scríobh an focal ceart sa bhosca.",
                   en: "Five questions. Write the correct word in the box.")
                .padding(.horizontal, 20)
                .padding(.top, 18)

            ZStack(alignment: .topLeading) {
                RuledPaper()
                VStack(alignment: .leading, spacing: 0) {
                    line("Caitheamh aimsire", bold: true)
                    line("\(store.dueCount) focal le déanamh inniu")
                    line("\(store.learnedCount) focal ar eolas")
                    line(store.streak > 0 ? "\(store.streak) lá as a chéile" : "Céad lá")
                    if store.sessionsToday > 0 {
                        line("\(store.sessionsToday) babhta déanta inniu")
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
                LinkButton(title: "Socruithe") { showSettings = true }
                Spacer()
                PrimaryButton(title: "Tosaigh", action: start)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .sheet(isPresented: $showSettings) { SettingsView() }
    }

    private func line(_ text: String, bold: Bool = false) -> some View {
        Text(text)
            .font(.system(size: 19, weight: bold ? .bold : .regular))
            .foregroundColor(Theme.ink)
            .frame(height: Theme.lineHeight, alignment: .bottomLeading)
            .padding(.bottom, 4)
    }
}

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Dalta") {
                    TextField("Ainm", text: $store.pupilName)
                    TextField("Rang", text: $store.pupilClass)
                }
                Section {
                    Toggle("Fadaí dochta", isOn: $store.strictFadas)
                } footer: {
                    Text("Off: a missing fada is marked right with a note in the margin. On: it is marked wrong.")
                }
                Section {
                    Button("Glan an dul chun cinn", role: .destructive) {
                        store.states = [:]
                        store.streak = 0
                        store.lastScore = ""
                        store.sessionsToday = 0
                    }
                } footer: {
                    Text("Clears every word's progress on this device.")
                }
            }
            .navigationTitle("Socruithe")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Déanta") { dismiss() }
                }
            }
        }
    }
}
