import SwiftUI

struct SessionView: View {
    @ObservedObject var session: Session
    @ObservedObject private var speaker = Speaker.shared
    @Environment(\.dismiss) private var dismiss
    @FocusState private var typing: Bool

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Color.clear.frame(height: 0).id("top")
                        if session.step < 4 {
                            StepHeader(step: session.step, silent: session.unit.isSilent)
                        }
                        content
                        Color.clear.frame(height: 1).id("bottom")
                    }
                    .padding()
                    .frame(maxWidth: 760)
                    .frame(maxWidth: .infinity)
                }
                .onChange(of: session.outcome != nil) { _, answered in
                    if answered {
                        withAnimation { proxy.scrollTo("feedback", anchor: .center) }
                    }
                }
                .onChange(of: session.index) { _, _ in
                    proxy.scrollTo("top", anchor: .top)
                    // The field keeps its identity from one typed item to the next, so onAppear does not refire.
                    typing = true
                }
                .onChange(of: session.step) { _, _ in
                    proxy.scrollTo("top", anchor: .top)
                }
            }
            .background(Theme.ground)
            .safeAreaInset(edge: .bottom) { actionBar }
            .navigationTitle("\(session.unit.emoji) \(session.unit.title)")
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
    }

    // MARK: Content per step

    @ViewBuilder private var content: some View {
        switch session.step {
        case 0:
            ListenStep(session: session)
        case 1, 2, 3:
            if let item = session.item {
                itemView(item)
            }
        default:
            ResultsView(session: session)
        }
    }

    @ViewBuilder private func itemView(_ item: Item) -> some View {
        let row = session.unit.rows[item.row]
        Panel {
            Text("\(session.index + 1) / \(session.items.count)")
                .font(.caption.weight(.bold))
                .foregroundStyle(Theme.muted)
            switch item.kind {
            case .hearTiles:
                if session.unit.isSilent {
                    Text("Léigh agus roghnaigh na tíleanna.").font(.title2.weight(.bold))
                    Text("Read it, then tap the tiles that make it, one from each colour.").foregroundStyle(Theme.muted)
                    promptBox(item.sentence?.ga ?? "")
                } else {
                    Text("Éist agus roghnaigh na tíleanna.").font(.title2.weight(.bold))
                    Text("Listen, then tap one tile from each colour.").foregroundStyle(Theme.muted)
                    replayButton(item)
                }
                BuilderGrid(unit: session.unit, row: row, selected: session.selected, litChunk: litChunk(item)) { chunk, column in
                    session.tap(chunk, column: column)
                }
                tileFeedback(item)
            case .meaning:
                Text("Cad é an chiall atá leis?").font(.title2.weight(.bold))
                Text("What does it mean?").foregroundStyle(Theme.muted)
                if session.unit.isSilent {
                    promptBox(item.sentence?.ga ?? "")
                } else {
                    replayButton(item)
                }
                meaningChoices(item)
                if session.outcome != nil, let s = item.sentence {
                    Text(s.ga).font(.headline).id("feedback")
                }
            case .build:
                Text(item.sentence?.en ?? "").font(.title2.weight(.bold))
                Text("Tóg an abairt i nGaeilge. Build it in Irish.").foregroundStyle(Theme.muted)
                BuilderGrid(unit: session.unit, row: row, selected: session.selected, litChunk: litChunk(item)) { chunk, column in
                    session.tap(chunk, column: column)
                }
                tileFeedback(item)
            case .type:
                Text(item.sentence?.en ?? "").font(.title2.weight(.bold))
                Text("Scríobh i nGaeilge é, ó chuimhne. Write it in Irish, from memory.").foregroundStyle(Theme.muted)
                answerField
                typedFeedback(item)
            case .question:
                Text("Ceist an scrúdaitheora")
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.muted)
                Text(item.question?.ga ?? "").font(.title2.weight(.bold))
                if let q = item.question {
                    Button {
                        Speaker.shared.play(q.audio)
                    } label: {
                        Label("Éist", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                }
                Text("Freagair fút féin, ó chuimhne. Answer about yourself, from memory.").foregroundStyle(Theme.muted)
                answerField
                questionFeedback(item)
            }
        }
    }

    private func litChunk(_ item: Item) -> String? {
        guard let s = item.sentence, let i = speaker.lit, speaker.playing == s.audio, s.chunks.indices.contains(i) else { return nil }
        return s.chunks[i]
    }

    private func promptBox(_ text: String) -> some View {
        Text(text)
            .font(.title3.weight(.bold))
            .foregroundStyle(Theme.columnInk(0))
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(0)))
    }

    private func replayButton(_ item: Item) -> some View {
        Button {
            if let s = item.sentence { Speaker.shared.play(s.audio) }
        } label: {
            Label("Éist arís", systemImage: "play.fill")
                .font(.headline)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.ink)
    }

    @ViewBuilder private func tileFeedback(_ item: Item) -> some View {
        if let outcome = session.outcome, let s = item.sentence {
            if outcome.ok {
                PenNote(text: "✓ ceart!", detail: s.ga).id("feedback")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    if let own = session.ownSentence {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Do abairt · your sentence")
                                .font(.subheadline)
                                .foregroundStyle(Theme.muted)
                            Text(own.ga)
                                .strikethrough(true, color: Theme.pen)
                            Button {
                                Speaker.shared.playSentence(own, in: session.unit)
                            } label: {
                                Label("Do abairt", systemImage: "play.fill")
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    PenNote(text: s.ga, detail: "An freagra ceart · the right answer")
                    Button {
                        Speaker.shared.playSentence(s, in: session.unit)
                    } label: {
                        Label("An freagra ceart", systemImage: "play.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .id("feedback")
            }
        }
    }

    private func meaningChoices(_ item: Item) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(session.options.enumerated()), id: \.offset) { k, option in
                let isRight = option == item.sentence?.en
                let answered = session.outcome != nil
                Button {
                    session.choose(k)
                } label: {
                    HStack {
                        Text(option)
                            .strikethrough(answered && session.picked == k && !isRight, color: Theme.pen)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        if answered && isRight {
                            Text("✓").font(Pen.font(28)).foregroundStyle(Theme.pen)
                        } else if answered && session.picked == k {
                            Text("✗").font(Pen.font(28)).foregroundStyle(Theme.pen)
                        }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(Theme.ink)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.surface))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(answered && isRight ? Theme.good : (answered && session.picked == k ? Theme.pen : Theme.rule), lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
                .disabled(answered)
            }
        }
    }

    private var answerField: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(fieldColour, lineWidth: 2)
                )
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
        }
    }

    private var fieldColour: Color {
        guard let o = session.outcome else { return Theme.ink }
        return o.ok ? Theme.good : Theme.pen
    }

    @ViewBuilder private func typedFeedback(_ item: Item) -> some View {
        if let outcome = session.outcome, let s = item.sentence {
            if outcome.ok {
                PenNote(text: outcome.fadaSlip ? "✓ fada!" : "✓ an-mhaith!",
                        detail: outcome.fadaSlip ? "Seiceáil na fadaí: \(s.ga)" : s.ga).id("feedback")
            } else {
                let missing = Mark.missing(typed: session.typed, target: s.ga)
                PenNote(text: s.ga,
                        detail: session.typed.isEmpty || missing.isEmpty ? nil : "De dhíth · missing: \(missing.joined(separator: ", "))").id("feedback")
            }
        }
    }

    @ViewBuilder private func questionFeedback(_ item: Item) -> some View {
        if let outcome = session.outcome {
            if outcome.ok {
                PenNote(text: "✓ an-mhaith!").id("feedback")
            } else {
                PenNote(text: "cuimhnigh ar na tíleanna", detail: "Sampla · for example: \(item.model ?? "")").id("feedback")
            }
        }
    }

    // MARK: Bottom bar

    private var actionBar: some View {
        HStack {
            switch session.step {
            case 0:
                Spacer()
                primary(session.listenRow + 1 < session.unit.rows.count ? "An chéad cheann eile" : "Ar aghaidh") {
                    session.nextListenRow()
                }
            case 1, 2, 3:
                if let item = session.item {
                    if session.outcome == nil {
                        if item.kind == .type || item.kind == .question {
                            Button("Níl a fhios agam") { session.check() }
                                .foregroundStyle(Theme.muted)
                        }
                        Spacer()
                        if item.kind != .meaning {
                            primary("Seiceáil") { session.check() }
                                .disabled((item.kind == .hearTiles || item.kind == .build) && session.selected.isEmpty)
                        }
                    } else {
                        Spacer()
                        primary(session.isLastItem ? (session.step < 3 ? "An chéad chéim eile" : "Críochnaigh") : "Ar aghaidh") {
                            session.next()
                        }
                    }
                }
            default:
                Button("Baile") {
                    Speaker.shared.stop()
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
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

struct StepHeader: View {
    let step: Int
    var silent = false

    private var name: (ga: String, en: String) { silent && step == 0 ? ("Léigh", "Read") : Session.steps[step] }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i < step ? Theme.good : (i == step ? Theme.columnInk(0) : Theme.rule))
                        .frame(height: 6)
                }
            }
            HStack(alignment: .firstTextBaseline) {
                Text(name.ga).font(.title2.weight(.bold))
                Spacer()
                Text("\(name.en) · \(step + 1) / 4")
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

struct ListenStep: View {
    @ObservedObject var session: Session
    @ObservedObject private var speaker = Speaker.shared
    @State private var shown: Sentence?
    @State private var picked: [String] = []

    var body: some View {
        let unit = session.unit
        let row = unit.rows[session.listenRow]
        let mine = row.sentence(picked: picked)
        Panel {
            Text("\(row.label) · \(session.listenRow + 1) / \(unit.rows.count)")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(Theme.muted)
            if unit.isSilent {
                Text("Léigh na samplaí, ansin roghnaigh tíl as gach dath le d'abairt féin a dhéanamh. Read the examples, then pick one tile from each colour to make your own sentence.")
                    .foregroundStyle(Theme.muted)
                ForEach(Array(row.sentences.prefix(3).enumerated()), id: \.offset) { _, s in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(s.ga).font(.headline)
                        Text(s.en).font(.subheadline).foregroundStyle(Theme.muted)
                    }
                }
            } else {
                Text("Brúigh ar thíl le héisteacht. Tap a tile to hear it. Pick one from each colour to hear your own sentence.")
                    .foregroundStyle(Theme.muted)
            }
            BuilderGrid(unit: unit, row: row, selected: picked, litChunk: litChunk) { chunk, column in
                picked = row.toggle(chunk.id, column: column, in: picked)
                Speaker.shared.play(chunk.id)
            }
            FlowLayout(spacing: 10) {
                if !unit.isSilent {
                    Button {
                        playRow(row, from: 0)
                    } label: {
                        Label("Éist leis na habairtí", systemImage: "play.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.ink)
                }
                Button {
                    if let mine = mine {
                        shown = mine
                        Speaker.shared.playSentence(mine, in: unit)
                    }
                } label: {
                    Label(unit.isSilent ? "Taispeáin m'abairt" : "Éist le m'abairt", systemImage: unit.isSilent ? "text.bubble" : "play.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.columnInk(0))
                .disabled(mine == nil)
            }
            if let s = shown {
                SpokenLine(sentence: s, unit: unit, lit: speaker.playing == s.audio ? speaker.lit : nil)
            }
        }
        .onChange(of: session.listenRow) { _, _ in
            shown = nil
            picked = []
        }
    }

    private var litChunk: String? {
        guard let s = shown, speaker.playing == s.audio, let i = speaker.lit, s.chunks.indices.contains(i) else { return nil }
        return s.chunks[i]
    }

    /// Plays three model sentences from this row, one after another.
    private func playRow(_ row: BuilderRow, from k: Int) {
        let sentences = Array(row.sentences.prefix(3))
        guard k < sentences.count else { return }
        shown = sentences[k]
        Speaker.shared.playSentence(sentences[k], in: session.unit) {
            let gen = Speaker.shared.generation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                MainActor.assumeIsolated {
                    guard Speaker.shared.generation == gen else { return }
                    playRow(row, from: k + 1)
                }
            }
        }
    }
}

struct ResultsView: View {
    @ObservedObject var session: Session

    var body: some View {
        let score = session.score
        let share = score.total > 0 ? Double(score.right) / Double(score.total) : 0
        Panel {
            VStack(spacing: 6) {
                Text(share >= 0.8 ? "🌟" : (share >= 0.5 ? "👍" : "💪"))
                    .font(.system(size: 64))
                    .accessibilityHidden(true)
                Text("\(score.right) / \(score.total)")
                    .font(.largeTitle.weight(.bold))
                Text(score.right == score.total ? "maith thú!" : (share >= 0.5 ? "ag teacht chun cinn" : "arís amárach"))
                    .font(Pen.font(40))
                    .foregroundStyle(Theme.pen)
                    .rotationEffect(.degrees(-2))
            }
            .frame(maxWidth: .infinity)
            ForEach(session.log) { entry in
                HStack(alignment: .top, spacing: 10) {
                    Text(entry.ok ? "✓" : "✗")
                        .font(Pen.font(26))
                        .foregroundStyle(Theme.pen)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.ga)
                        Text(entry.en).font(.subheadline).foregroundStyle(Theme.muted)
                    }
                }
                .accessibilityElement(children: .combine)
                Divider()
            }
        }
    }
}
