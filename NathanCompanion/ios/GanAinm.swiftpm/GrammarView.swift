import SwiftUI

private let draftNote = "Dréacht: níor seiceáil múinteoir an Ghaeilge seo go fóill. Draft: a teacher has not yet checked the Irish here."

struct DraftBanner: View {
    var body: some View {
        Text(draftNote)
            .font(.footnote)
            .foregroundStyle(Theme.columnInk(2))
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(2)))
    }
}

/// The list of all 30 grammar sections, grouped by topic.
struct GrammarHome: View {
    @EnvironmentObject private var store: Store
    let grammar: GrammarData
    @State private var active: GrammarSession?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DraftBanner()
                Text("Gach alt: patrún, riail, cleachtadh. Each section: see the pattern, learn the rule, then practise.")
                    .foregroundStyle(Theme.muted)
                ForEach(grammar.groups, id: \.ga) { group in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(group.emoji) \(group.ga) · \(group.en)")
                            .font(.footnote.weight(.bold))
                            .textCase(.uppercase)
                            .foregroundStyle(Theme.muted)
                            .padding(.top, 6)
                        ForEach(group.sections, id: \.self) { sid in
                            if let section = grammar.sections[sid] {
                                Button {
                                    active = GrammarSession(section: section, store: store)
                                } label: {
                                    GrammarSectionRow(section: section, progress: progress(section))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: 760)
            .frame(maxWidth: .infinity)
        }
        .background(Theme.ground)
        .navigationTitle("Gramadach · AS agus A2")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $active) { session in
            GrammarSessionView(session: session)
        }
    }

    private func progress(_ section: GrammarSection) -> Double {
        guard !section.items.isEmpty else { return 0 }
        let known = section.items.filter { store.card($0.key).box >= 2 }.count
        return Double(known) / Double(section.items.count)
    }
}

struct GrammarSectionRow: View {
    let section: GrammarSection
    let progress: Double

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(section.title).font(.headline).foregroundStyle(Theme.ink)
                Text("\(section.en) · \(section.items.count) cleachtadh")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
                ProgressView(value: progress).tint(Theme.good)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.right")
                .foregroundStyle(Theme.columnInk(0))
                .accessibilityHidden(true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
        .contentShape(Rectangle())
    }
}

/// One section: Patrún, Riail, Cleachtadh, then results.
struct GrammarSessionView: View {
    @ObservedObject var session: GrammarSession
    @Environment(\.dismiss) private var dismiss
    @FocusState private var typing: Bool

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Color.clear.frame(height: 0).id("top")
                        DraftBanner()
                        if session.step < 3 { header }
                        switch session.step {
                        case 0: pattern
                        case 1: rules
                        case 2: practice
                        default: results
                        }
                    }
                    .padding()
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: session.step) { _, _ in proxy.scrollTo("top", anchor: .top) }
                .onChange(of: session.index) { _, _ in
                    proxy.scrollTo("top", anchor: .top)
                    typing = true
                }
                .onChange(of: session.outcome != nil) { _, answered in
                    if answered { withAnimation { proxy.scrollTo("feedback", anchor: .center) } }
                }
            }
            .background(Theme.ground)
            .safeAreaInset(edge: .bottom) { actionBar }
            .navigationTitle(session.section.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Dún") { dismiss() }
                        .accessibilityLabel("Dún. Close")
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i < session.step ? Theme.good : (i == session.step ? Theme.columnInk(0) : Theme.rule))
                        .frame(height: 6)
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text(GrammarSession.steps[session.step].ga).font(.title2.weight(.bold))
                Spacer()
                Text("\(GrammarSession.steps[session.step].en) · \(session.step + 1) / 3")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
        }
        .accessibilityElement(children: .combine)
    }

    // MARK: Patrún

    private var pattern: some View {
        Panel {
            Text("Léigh na habairtí seo. Cad é atá cosúil eatarthu?").font(.title2.weight(.bold))
            Text("Read these sentences. What do they have in common?").foregroundStyle(Theme.muted)
            ForEach(Array(session.models.enumerated()), id: \.offset) { _, model in
                VStack(alignment: .leading, spacing: 2) {
                    Text(model.ga).font(.title3.weight(.bold))
                    if !model.cue.isEmpty {
                        Text(model.cue).font(.footnote.italic()).foregroundStyle(Theme.muted)
                    }
                }
                .padding(.vertical, 4)
            }
            if session.models.isEmpty {
                Text("Níl samplaí ann go fóill. No examples yet.").foregroundStyle(Theme.muted)
            }
        }
    }

    // MARK: Riail

    private var rules: some View {
        Panel {
            Text("Brúigh ar riail le hí a oscailt. Tap a rule to open it.").foregroundStyle(Theme.muted)
            ForEach(Array(session.section.rules.enumerated()), id: \.offset) { i, rule in
                RuleRow(rule: rule, startOpen: i == 0)
            }
            if !session.section.tables.isEmpty {
                Text("Táblaí · tables")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 6)
                ForEach(Array(session.section.tables.enumerated()), id: \.offset) { _, table in
                    GrammarTableRow(table: table)
                }
            }
        }
    }

    // MARK: Cleachtadh

    @ViewBuilder private var practice: some View {
        if let it = session.item {
            Panel {
                Text("\(session.index + 1) / \(session.items.count) · \(it.point)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Theme.muted)
                Text(it.task.ga).font(.title2.weight(.bold))
                Text(it.task.en).foregroundStyle(Theme.muted)
                Text(it.prompt)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.columnInk(0))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(0)))
                TextField("Scríobh anseo", text: $session.typed)
                    .font(.title3)
                    .textInputAutocapitalization(.sentences)
                    .autocorrectionDisabled()
                    .focused($typing)
                    .submitLabel(.done)
                    .onSubmit { session.check() }
                    .disabled(session.outcome != nil)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(fieldColour, lineWidth: 2))
                    .onAppear { typing = true }
                if session.outcome == nil {
                    HStack(spacing: 8) {
                        ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { letter in
                            Button(letter) { session.typed += letter }
                                .font(.title3.weight(.semibold))
                                .frame(minWidth: 44, minHeight: 44)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.surface))
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Theme.rule))
                                .buttonStyle(.plain)
                                .accessibilityLabel("\(letter) le fada")
                        }
                    }
                }
                feedback(it)
            }
        }
    }

    private var fieldColour: Color {
        guard let o = session.outcome, !o.awaitingSelfMark else { return Theme.ink }
        return o.ok ? Theme.good : Theme.pen
    }

    @ViewBuilder private func feedback(_ it: GrammarItem) -> some View {
        if let o = session.outcome {
            VStack(alignment: .leading, spacing: 8) {
                if o.awaitingSelfMark {
                    Text("Freagra samplach · a model answer").font(.subheadline).foregroundStyle(Theme.muted)
                    Text(it.answer).font(.title3.weight(.bold))
                    Text("An raibh do fhreagra ceart? Was your answer right?").font(.subheadline).foregroundStyle(Theme.muted)
                    HStack(spacing: 10) {
                        Button("Bhí") { session.selfMark(true) }
                            .buttonStyle(.borderedProminent).tint(Theme.good)
                        Button("Ní raibh") { session.selfMark(false) }
                            .buttonStyle(.bordered)
                    }
                } else if o.ok {
                    Text(o.fadaSlip ? "✓ seiceáil na fadaí" : (o.selfMarked ? "✓" : "✓ ceart!"))
                        .font(Pen.font(30)).foregroundStyle(Theme.pen)
                    Text(it.answer).font(.title3.weight(.bold))
                } else {
                    Text("✗").font(Pen.font(30)).foregroundStyle(Theme.pen)
                    Text("An freagra ceart · the right answer").font(.subheadline).foregroundStyle(Theme.muted)
                    Text(it.answer).font(.title3.weight(.bold))
                    let missing = session.missing
                    if !missing.isEmpty {
                        Text("De dhíth · missing or different: \(missing.joined(separator: ", "))")
                            .font(.subheadline)
                            .foregroundStyle(Theme.muted)
                    }
                    if !o.selfMarked && !session.typed.isEmpty {
                        Button("Tá mo leagan ceart freisin · my version is right too") { session.acceptMine() }
                            .font(.subheadline)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
            .id("feedback")
        }
    }

    // MARK: Results

    private var results: some View {
        let score = session.score
        let share = score.total > 0 ? Double(score.right) / Double(score.total) : 0
        return Panel {
            VStack(spacing: 6) {
                Text(share >= 0.8 ? "🌟" : (share >= 0.5 ? "👍" : "💪")).font(.system(size: 64)).accessibilityHidden(true)
                Text("\(score.right) / \(score.total)").font(.largeTitle.weight(.bold))
            }
            .frame(maxWidth: .infinity)
            ForEach(session.log) { entry in
                HStack(alignment: .top, spacing: 10) {
                    Text(entry.ok ? "✓" : "✗").font(Pen.font(26)).foregroundStyle(Theme.pen).frame(width: 24)
                    Text(entry.answer)
                }
                .accessibilityElement(children: .combine)
                Divider()
            }
        }
    }

    // MARK: Bottom bar

    private var actionBar: some View {
        HStack {
            switch session.step {
            case 0:
                Spacer()
                primary("An riail") { session.nextStep() }
            case 1:
                Button("An patrún") { session.backToPattern() }
                    .buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary(session.items.isEmpty ? "Críochnaigh" : "Cleachtadh") { session.nextStep() }
            case 2:
                if let o = session.outcome {
                    if !o.awaitingSelfMark {
                        Spacer()
                        primary(session.isLastItem ? "Críochnaigh" : "Ar aghaidh") { session.next() }
                    }
                } else {
                    Button("Níl a fhios agam") { session.check(skip: true) }
                        .foregroundStyle(Theme.muted)
                    Spacer()
                    primary("Seiceáil") { session.check() }
                }
            default:
                Button("Gramadach") { dismiss() }
                    .buttonStyle(.bordered).controlSize(.large)
                Spacer()
                primary("Arís") { session.restart() }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func primary(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title).font(.headline).padding(.horizontal, 8)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(Theme.ink)
    }
}

/// A rule the pupil taps to open.
struct RuleRow: View {
    let rule: GrammarRule
    @State private var open: Bool

    init(rule: GrammarRule, startOpen: Bool) {
        self.rule = rule
        _open = State(initialValue: startOpen)
    }

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            Text(rule.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 6)
        } label: {
            Text(rule.point).font(.headline).foregroundStyle(Theme.ink).multilineTextAlignment(.leading)
        }
        .tint(Theme.columnInk(0))
        .padding(.leading, 12)
        .overlay(alignment: .leading) {
            Rectangle().fill(Theme.columnInk(0)).frame(width: 4)
        }
    }
}

/// A table of forms the pupil taps to open.
struct GrammarTableRow: View {
    let table: GrammarTable
    @State private var open = false

    var body: some View {
        DisclosureGroup(isExpanded: $open) {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(table.forms.enumerated()), id: \.offset) { _, form in
                    Text("• \(form)")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, 8)
        } label: {
            Text(table.title).font(.headline).multilineTextAlignment(.leading)
        }
        .foregroundStyle(Theme.columnInk(1))
        .tint(Theme.columnInk(1))
        .padding(.horizontal, 14)
        .padding(.vertical, 4)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(1)))
    }
}
