import SwiftUI

struct IndexView: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.paper.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 0) {
                    ExamHeader(name: store.pupilName, pupilClass: store.pupilClass,
                               unit: "Innéacs", right: store.stage == .ks3 ? "Eochairchéim 3" : "GCSE")
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Rubric(ga: "Roghnaigh topaic.", en: "Choose a topic.")
                        .padding(.horizontal, 20)
                        .padding(.top, 14)

                    List {
                        ForEach(store.contexts) { ctx in
                            Section {
                                ForEach(ctx.groups) { group in
                                    NavigationLink(value: group.id) {
                                        GroupRow(group: group)
                                    }
                                    .listRowBackground(Theme.paper)
                                }
                            } header: {
                                Text(ctx.context)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(Theme.ink)
                                    .textCase(.uppercase)
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top, 6)
                }
            }
            .navigationDestination(for: String.self) { groupID in
                if let group = store.contexts.flatMap({ $0.groups }).first(where: { $0.id == groupID }) {
                    GroupView(group: group)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct GroupRow: View {
    @EnvironmentObject private var store: Store
    let group: VocabGroup

    var body: some View {
        let learned = group.items.filter { store.isLearned($0) }.count
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(group.name).font(.system(size: 17, weight: .semibold)).foregroundColor(Theme.ink)
                if group.nameEn != group.name {
                    Text(group.nameEn).font(.footnote).foregroundColor(Theme.grey)
                }
            }
            Spacer()
            Text("\(learned)/\(group.items.count)")
                .font(MarkingHand.font(20))
                .foregroundColor(learned == group.items.count && learned > 0 ? Theme.pen : Theme.grey)
        }
        .padding(.vertical, 4)
    }
}

struct GroupView: View {
    @EnvironmentObject private var store: Store
    @Environment(\.dismiss) private var dismiss
    let group: VocabGroup
    @State private var flow: SessionFlowRequest? = nil

    var body: some View {
        ZStack {
            Theme.paper.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left").font(.body.weight(.semibold))
                            .frame(width: 44, height: 44)
                    }
                    .foregroundColor(Theme.ink)
                    Text(group.name).font(.system(size: 20, weight: .bold)).foregroundColor(Theme.ink)
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)

                HStack {
                    let learned = group.items.filter { store.isLearned($0) }.count
                    Rubric(ga: "\(group.items.count) focal · \(learned) ar eolas", en: "")
                    Spacer()
                    PrimaryButton(title: "Cleachtadh") {
                        flow = SessionFlowRequest(title: group.name, scope: group.items)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)

                List(group.items) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(item.expectedFirst)
                            .font(.system(size: 17))
                            .foregroundColor(Theme.biro)
                        if let g = item.genderLabel {
                            Text(g).font(.caption).italic().foregroundColor(Theme.grey)
                        }
                        if let vn = item.vn {
                            Text(vn).font(.footnote).italic().foregroundColor(Theme.grey)
                        }
                        Spacer()
                        Text(item.en).font(.footnote).foregroundColor(Theme.grey)
                            .multilineTextAlignment(.trailing)
                        if store.isLearned(item) {
                            Text("✓").font(MarkingHand.font(18)).foregroundColor(Theme.pen)
                        }
                    }
                    .listRowBackground(Theme.paper)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(item: $flow) { req in
            SessionFlow(request: req).environmentObject(store)
        }
    }
}
