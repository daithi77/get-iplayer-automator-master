import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: Store
    @State private var confirmClear = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Dalta") {
                    TextField("Ainm", text: $store.pupilName)
                    TextField("Rang", text: $store.pupilClass)
                }
                Section {
                    Picker("Céim", selection: $store.stage) {
                        ForEach(Stage.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("Céim")
                } footer: {
                    Text("Key Stage 3 uses the frequency list, about 830 words in bands. GCSE uses the topic list, about 2,200 words. Progress is kept separately for each.")
                }
                Section {
                    Picker("Ceisteanna sa bhabhta", selection: $store.sessionSize) {
                        Text("5").tag(5)
                        Text("10").tag(10)
                        Text("15").tag(15)
                    }
                    .pickerStyle(.segmented)
                    Toggle("Fadaí dochta", isOn: $store.strictFadas)
                } header: {
                    Text("Cleachtadh")
                } footer: {
                    Text("Strict fadas off: a missing fada is marked right with a note in the margin. On: it is marked wrong.")
                }
                Section {
                    LabeledContent("Focail feicthe", value: "\(store.seenCount)")
                    LabeledContent("Focail ar eolas", value: "\(store.learnedCount)")
                    LabeledContent("Sraith", value: "\(store.streak) lá")
                } header: {
                    Text("Dul chun cinn")
                }
                Section {
                    Button("Glan an dul chun cinn", role: .destructive) { confirmClear = true }
                } footer: {
                    Text("Clears every word's progress on this device, for both stages. Spoken answers are kept.")
                }
                Section {
                    Text("Cuimhne 0.2, proof of concept. The marking hand is Dáithí Murray's handwriting.")
                        .font(.footnote)
                        .foregroundColor(Theme.grey)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("Socruithe")
            .confirmationDialog("Glan an dul chun cinn?", isPresented: $confirmClear, titleVisibility: .visible) {
                Button("Glan", role: .destructive) { store.clearProgress() }
                Button("Cealaigh", role: .cancel) {}
            }
        }
    }
}
