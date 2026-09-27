import SwiftUI
import Combine

// MARK: - GCSE · Bliain 11: the examiner's question chain, sentence builders (the Year 8 engine),
// patterns to spot, a basic to best ladder and role plays.

struct GCSEHome: View {
    @EnvironmentObject private var store: Store

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                DraftBanner()
                Text("Achan aonad: ceisteanna an scrúdaitheora, abairtí le tógáil, patrún le haimsiú, freagra níos fearr agus ról-imirt. Each unit: the examiner's questions, sentences to build, a pattern to spot, a better answer and a role play.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(store.gcse.enumerated()), id: \.element.id) { i, unit in
                    NavigationLink {
                        GCSEUnitView(unit: unit)
                    } label: {
                        HStack(spacing: 12) {
                            Text(unit.emoji).font(.system(size: 34)).accessibilityHidden(true)
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    Text("\(i + 1). \(unit.title)").font(.headline).foregroundStyle(Theme.ink)
                                    if unit.isNew ?? false {
                                        Text("nua · new")
                                            .font(.caption.weight(.bold))
                                            .padding(.horizontal, 8).padding(.vertical, 2)
                                            .background(Capsule().fill(Theme.fill(2)))
                                            .foregroundStyle(Theme.columnInk(2))
                                    }
                                }
                                Text("\(unit.en) · \(unit.questions.count) ceist")
                                    .font(.subheadline)
                                    .foregroundStyle(Theme.muted)
                                ProgressView(value: store.progress(unit))
                                    .tint(Theme.good)
                                    .accessibilityLabel("Progress \(Int(store.progress(unit) * 100)) per cent")
                            }
                            Spacer(minLength: 8)
                            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(0)).accessibilityHidden(true)
                        }
                        .padding(14)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("GCSE · Bliain 11")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GCSEUnitView: View {
    @EnvironmentObject private var store: Store
    let unit: BuilderUnit
    @State private var active: Session?
    @State private var role: RolePlayRun?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text(unit.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                DraftBanner()
                if let sprioc = unit.sprioc, !sprioc.isEmpty {
                    SpriocCard(items: sprioc)
                }
                Panel {
                    Text("Ceisteanna an scrúdaitheora · the examiner's questions")
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                    ForEach(Array(unit.questions.enumerated()), id: \.offset) { i, q in
                        HStack(alignment: .firstTextBaseline, spacing: 8) {
                            Text("\(i + 1).").font(.headline)
                            VStack(alignment: .leading, spacing: 2) {
                                Button {
                                    Speaker.shared.play(q.audio)
                                } label: {
                                    Label(q.ga, systemImage: "speaker.wave.2.fill")
                                        .font(.headline)
                                        .foregroundStyle(Theme.ink)
                                        .multilineTextAlignment(.leading)
                                }
                                .buttonStyle(.plain)
                                Text(i == 0 ? "An chéad cheist · the first question" : "Ceist leantach · a follow-up")
                                    .font(.caption).foregroundStyle(Theme.muted)
                            }
                        }
                    }
                }
                Button {
                    active = Session(unit: unit, store: store)
                    active?.autoPlay()
                } label: {
                    GCSEActionLabel(emoji: "🧱", ga: "Cleachtadh na n-abairtí", en: "Listen, recognise, build and answer from memory")
                }
                .buttonStyle(.plain)
                ForEach(Array((unit.roleplays ?? []).enumerated()), id: \.offset) { _, play in
                    Button {
                        role = RolePlayRun(unit: unit, rolePlay: play, store: store)
                    } label: {
                        GCSEActionLabel(emoji: "🎭", ga: "Ról-imirt: \(play.title)", en: "\(play.titleEn) · \(play.tasks.count) tasks")
                    }
                    .buttonStyle(.plain)
                }
                ForEach(Array((unit.patterns ?? []).enumerated()), id: \.offset) { _, pattern in
                    PatternCard(pattern: pattern)
                }
                if let ladder = unit.ladder, !ladder.isEmpty {
                    LadderCard(rungs: ladder)
                }
                NavigationLink {
                    TeachDeck(unit: unit)
                } label: {
                    Label("Don rang · slides for this unit", systemImage: "tv")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
            .fullScreenCover(item: $role) { run in
                RolePlayView(run: run)
            }
        }
        .background(Theme.ground)
        .navigationTitle(unit.title)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $active) { session in
            SessionView(session: session)
        }
    }
}

/// A row that opens something: an emoji, the Irish, and a line of English.
struct GCSEActionLabel: View {
    let emoji: String
    let ga: String
    let en: String

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji).font(.system(size: 30)).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(ga).font(.headline).foregroundStyle(Theme.ink)
                Text(en).font(.subheadline).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right").foregroundStyle(Theme.columnInk(0)).accessibilityHidden(true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
        .contentShape(Rectangle())
    }
}

/// Sprioc foghlama: what the pupil is learning to do.
struct SpriocCard: View {
    let items: [Sprioc]

    var body: some View {
        Panel {
            Text("Sprioc foghlama · learning intentions")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.ga).font(.headline).foregroundStyle(Theme.ink)
                        Text(item.en).font(.subheadline).foregroundStyle(Theme.muted)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
            .padding(.leading, 12)
            .overlay(alignment: .leading) {
                Rectangle().fill(Theme.columnInk(1)).frame(width: 4)
            }
        }
    }
}

/// Aimsigh an patrún: each word on its own, then after the change, with the change marked.
struct PatternCard: View {
    let pattern: SpotPattern
    @State private var showRule = false

    var body: some View {
        Panel {
            Text("Aimsigh an patrún · spot the pattern")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            Text(pattern.question).font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
            Text(pattern.questionEn).font(.subheadline).foregroundStyle(Theme.muted)
            Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
                ForEach(Array(pattern.pairs.enumerated()), id: \.offset) { _, pair in
                    Divider()
                    GridRow {
                        Text(pair.plain)
                        Text("→")
                            .foregroundStyle(Theme.muted)
                            .accessibilityHidden(true)
                        Text(Marking.text(pair.marked))
                            .accessibilityLabel(Marking.plain(pair.marked))
                    }
                }
            }
            .font(.title3)
            .foregroundStyle(Theme.ink)
            if let rule = pattern.rule {
                DisclosureGroup(isExpanded: $showRule) {
                    Text(rule)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)
                } label: {
                    Text("An riail · the rule").font(.headline).foregroundStyle(Theme.ink)
                }
                .tint(Theme.columnInk(0))
            }
        }
    }
}

/// Freagra níos fearr: the same answer, basic, better and best, with what is new marked.
struct LadderCard: View {
    let rungs: [LadderRung]

    var body: some View {
        Panel {
            Text("Freagra níos fearr · make it better")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            Text("Na focail dhearga: cad é atá nua? The words in red are new. Can you do better still?")
                .font(.subheadline).foregroundStyle(Theme.muted)
            ForEach(Array(rungs.enumerated()), id: \.offset) { _, rung in
                VStack(alignment: .leading, spacing: 6) {
                    Text(rung.label)
                        .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
                    Text(Marking.text(rung.ga))
                        .font(.title3)
                        .foregroundStyle(Theme.ink)
                        .accessibilityLabel(Marking.plain(rung.ga))
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Button {
                            Speaker.shared.play(rung.audio)
                        } label: {
                            Label("Éist", systemImage: "play.fill")
                        }
                        .buttonStyle(.bordered)
                        Text(rung.en).font(.subheadline).foregroundStyle(Theme.muted)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.ground))
            }
        }
    }
}

// MARK: - Role play

/// One run through a role play: the teacher's line, the task in English, the pupil answers aloud
/// or in writing, sees a model answer and marks it. Self-marks feed the same review as the sessions.
final class RolePlayRun: ObservableObject, Identifiable {
    let id = UUID()
    let unit: BuilderUnit
    let rolePlay: RolePlay
    let store: Store

    @Published private(set) var index = 0
    @Published var typed = ""
    @Published private(set) var shown = false
    @Published private(set) var log: [Bool] = []

    init(unit: BuilderUnit, rolePlay: RolePlay, store: Store) {
        self.unit = unit
        self.rolePlay = rolePlay
        self.store = store
    }

    var task: RoleTask? { rolePlay.tasks.indices.contains(index) ? rolePlay.tasks[index] : nil }
    var done: Bool { index >= rolePlay.tasks.count }
    var right: Int { log.filter { $0 }.count }

    /// The teacher's line, after a short pause, unless something else has played meanwhile.
    func playTeacher() {
        guard let t = task else { return }
        let gen = Speaker.shared.generation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard Speaker.shared.generation == gen else { return }
            Speaker.shared.play(t.teacherAudio)
        }
    }

    func show() {
        guard let t = task, !shown else { return }
        shown = true
        Speaker.shared.play(t.audio)
    }

    func mark(_ ok: Bool) {
        guard let t = task else { return }
        store.record(t.audio, ok: ok)
        log.append(ok)
        index += 1
        shown = false
        typed = ""
        Speaker.shared.stop()
        playTeacher()
    }

    func restart() {
        Speaker.shared.stop()
        index = 0
        shown = false
        typed = ""
        log = []
        playTeacher()
    }
}

struct RolePlayView: View {
    @ObservedObject var run: RolePlayRun
    @Environment(\.dismiss) private var dismiss
    @FocusState private var typing: Bool

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Color.clear.frame(height: 0).id("top")
                        Text("\(run.rolePlay.titleEn) · \(run.unit.title)")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                        if let task = run.task {
                            taskPanel(task)
                        } else {
                            endPanel
                        }
                    }
                    .padding()
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: run.index) { _, _ in
                    proxy.scrollTo("top", anchor: .top)
                }
                .onChange(of: run.shown) { _, shown in
                    if shown {
                        withAnimation { proxy.scrollTo("feedback", anchor: .center) }
                    }
                }
            }
            .background(Theme.ground)
            .safeAreaInset(edge: .bottom) { actionBar }
            .navigationTitle("Ról-imirt: \(run.rolePlay.title)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Druid") {
                        Speaker.shared.stop()
                        dismiss()
                    }
                    .accessibilityLabel("Druid. Close")
                }
            }
        }
        .onAppear { run.playTeacher() }
        .onDisappear { Speaker.shared.stop() }
    }

    private func taskPanel(_ task: RoleTask) -> some View {
        Panel {
            Text("\(run.index + 1) / \(run.rolePlay.tasks.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
            if run.index == 0 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(run.rolePlay.rubric).font(.subheadline.weight(.bold)).foregroundStyle(Theme.ink)
                    Text(run.rolePlay.rubricEn).font(.subheadline).foregroundStyle(Theme.muted)
                }
            }
            Text(task.teacher)
                .font(.title3.weight(.bold))
                .foregroundStyle(Theme.columnInk(0))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.fill(0)))
            Button {
                Speaker.shared.play(task.teacherAudio)
            } label: {
                Label("Éist", systemImage: "play.fill")
            }
            .buttonStyle(.bordered)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Text("Your task:").bold()) \(task.en)")
                    .font(.body)
                    .foregroundStyle(Theme.ink)
                if task.unexpected ?? false {
                    Text("ceist gan choinne · unexpected")
                        .font(.caption.weight(.bold))
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Capsule().fill(Theme.fill(2)))
                        .foregroundStyle(Theme.columnInk(2))
                }
            }
            answerField
            if run.shown {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Freagra samplach · a model answer").font(.subheadline).foregroundStyle(Theme.muted)
                    Text(task.ga).font(.title3.weight(.bold)).foregroundStyle(Theme.ink)
                    if let alt = task.alt {
                        Text("Nó · or: \(Text(alt).bold())")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    Button {
                        Speaker.shared.play(task.audio)
                    } label: {
                        Label("Éist", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                    Text("An raibh sé agat? Did you have it?").font(.subheadline).foregroundStyle(Theme.muted)
                    HStack(spacing: 10) {
                        Button("Bhí") { run.mark(true) }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.good)
                        Button("Ní raibh go fóill") { run.mark(false) }
                            .buttonStyle(.bordered)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.penWash))
                .id("feedback")
            }
        }
    }

    private var answerField: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Abair os ard é, nó scríobh anseo", text: $run.typed, axis: .vertical)
                .lineLimit(2...5)
                .font(.title3)
                .textInputAutocapitalization(.sentences)
                .autocorrectionDisabled()
                .focused($typing)
                .disabled(run.shown)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(Theme.ink, lineWidth: 2))
            if !run.shown {
                HStack(spacing: 8) {
                    ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { letter in
                        Button(letter) { run.typed += letter }
                            .font(.title3.weight(.semibold))
                            .frame(minWidth: 44, minHeight: 44)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                            .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
                            .buttonStyle(.plain)
                            .accessibilityLabel("\(letter) le fada")
                    }
                }
            }
        }
    }

    private var endPanel: some View {
        let total = run.rolePlay.tasks.count
        return Panel {
            Text("An comhrá iomlán · the whole conversation")
                .font(.caption.weight(.bold)).textCase(.uppercase).foregroundStyle(Theme.muted)
            VStack(spacing: 8) {
                ForEach(Array(run.rolePlay.tasks.enumerated()), id: \.offset) { _, task in
                    Text(task.teacher)
                        .foregroundStyle(Theme.columnInk(0))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.fill(0)))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.trailing, 40)
                    Text(task.ga)
                        .foregroundStyle(Theme.columnInk(1))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.fill(1)))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.leading, 40)
                }
            }
            Text("\(run.right) / \(total)")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity)
        }
    }

    private var actionBar: some View {
        HStack {
            if run.done {
                Button("An t-aonad") {
                    Speaker.shared.stop()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Spacer()
                Button {
                    run.restart()
                } label: {
                    Text("Arís").font(.headline).padding(.horizontal, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Theme.ink)
            } else if !run.shown {
                Spacer()
                Button {
                    typing = false
                    run.show()
                } label: {
                    Text("Taispeáin an freagra").font(.headline).padding(.horizontal, 8)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(Theme.ink)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }
}
