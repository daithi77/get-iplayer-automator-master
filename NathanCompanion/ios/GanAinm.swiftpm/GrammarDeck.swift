import SwiftUI

/// Grammar slides for the class screen: title, Sprioc foghlama, pattern, one slide per rule and table,
/// practice with the answer revealed on a tap, Dul siar, then a closing slide with a seanfhocal.
enum GrammarSlide {
    case title
    case sprioc
    case pattern([GrammarModel])
    case rule(GrammarRule)
    case table(GrammarTable)
    case item(GrammarItem)
    case lessonRule(GrammarLesson, Int)
    case worked(GrammarLesson)
    case contents([GrammarLesson])
    /// Revision: up to four items not already shown, answers revealed together.
    case dulsiar([GrammarItem])
    case end
}

/// Well-known seanfhocail to close a deck, one per section, always the same for that section (as on the web).
enum Seanfhocal {
    static let all: [(ga: String, en: String)] = [
        ("Cleachtadh a dhéanann máistreacht.", "Practice makes perfect."),
        ("Tús maith leath na hoibre.", "A good start is half the work."),
        ("Ní neart go cur le chéile.", "There is strength in working together."),
        ("Mol an óige agus tiocfaidh sí.", "Praise the young and they will flourish."),
        ("Beagán agus a rá go maith.", "Say a little, and say it well."),
        ("Bíonn gach tosach lag.", "Every beginning is weak."),
        ("Is fada an bóthar nach bhfuil casadh ann.", "It is a long road that has no turning."),
        ("Níl aon tinteán mar do thinteán féin.", "There is no place like home.")
    ]

    /// The web's seanFor: h = 7, then h = (h * 31 + c) mod 2^32 for each UTF-16 code unit, index h mod 8.
    static func forID(_ id: String) -> (ga: String, en: String) {
        var h: UInt32 = 7
        for c in id.utf16 { h = h &* 31 &+ UInt32(c) }
        return all[Int(h % UInt32(all.count))]
    }
}

enum GrammarSlides {
    static func make(_ section: GrammarSection) -> [GrammarSlide] {
        if let lessons = section.lessons, !lessons.isEmpty {
            var slides: [GrammarSlide] = [.title, .contents(lessons)]
            var used: [GrammarItem] = []
            for (i, lesson) in lessons.enumerated() {
                slides.append(.lessonRule(lesson, i))
                slides.append(.worked(lesson))
                let shown = Array(lesson.items.shuffled().prefix(3))
                used += shown
                slides += shown.map { GrammarSlide.item($0) }
            }
            let rest = lessons.flatMap { $0.items }.filter { !used.contains($0) && !$0.isSelfMarked }.shuffled()
            if !rest.isEmpty { slides.append(.dulsiar(Array(rest.prefix(4)))) }
            slides.append(.end)
            return slides
        }
        var byPoint: [String: [GrammarModel]] = [:]
        for m in section.models { byPoint[m.point, default: []].append(m) }
        let points = byPoint.keys.filter { (byPoint[$0]?.count ?? 0) >= 3 }
        var models: [GrammarModel] = []
        var lead: [GrammarItem] = []
        if let focus = points.randomElement(), let chosen = byPoint[focus] {
            models = Array(chosen.shuffled().prefix(6))
            lead = Array(section.items.filter { $0.point == focus }.shuffled().prefix(4))
        } else {
            models = Array(section.models.shuffled().prefix(6))
        }
        let items = Array((lead + section.items.filter { !lead.contains($0) }.shuffled()).prefix(8))
        let rest = Array(section.items.filter { !items.contains($0) && !$0.isSelfMarked }.shuffled().prefix(4))
        var slides: [GrammarSlide] = [.title, .sprioc]
        if !models.isEmpty { slides.append(.pattern(models)) }
        slides += section.rules.map { GrammarSlide.rule($0) }
        slides += section.tables.map { GrammarSlide.table($0) }
        slides += items.map { GrammarSlide.item($0) }
        if !rest.isEmpty { slides.append(.dulsiar(rest)) }
        slides.append(.end)
        return slides
    }
}

/// The grammar sections in Don rang.
struct GrammarDeckList: View {
    let grammar: GrammarData

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Gramadach · AS agus A2 · grammar slides")
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .foregroundStyle(Theme.muted)
                .padding(.top, 8)
            DraftBanner()
            ForEach(grammar.groups, id: \.ga) { group in
                Text("\(group.emoji) \(group.ga)")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(Theme.muted)
                    .padding(.top, 4)
                ForEach(group.sections, id: \.self) { sid in
                    if let section = grammar.sections[sid] {
                        NavigationLink {
                            GrammarDeck(section: section)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(section.title).font(.headline).foregroundStyle(Theme.ink)
                                    Text(section.en).font(.subheadline).foregroundStyle(Theme.muted)
                                }
                                Spacer()
                                Image(systemName: "play.rectangle.fill")
                                    .font(.title2)
                                    .foregroundStyle(Theme.columnInk(3))
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Theme.surface))
                            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).strokeBorder(Theme.rule))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct GrammarDeck: View {
    let section: GrammarSection
    @Environment(\.dismiss) private var dismiss
    @State private var slides: [GrammarSlide]
    @State private var page = 0
    @State private var showEnglish = true
    @State private var revealed: Set<Int> = []

    init(section: GrammarSection) {
        self.section = section
        _slides = State(initialValue: GrammarSlides.make(section))
    }

    private var lastPage: Int { slides.count - 1 }

    var body: some View {
        TabView(selection: $page) {
            ForEach(Array(slides.enumerated()), id: \.offset) { i, slide in
                GeometryReader { geo in
                    let s = min(max(geo.size.width / 1100, 0.6), 1.6)
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20 * s) {
                            slideBody(slide, index: i, scale: s)
                        }
                        .padding(40 * s)
                        .padding(.bottom, 40)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(Theme.ground)
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showEnglish.toggle()
                } label: {
                    Label(showEnglish ? "Folaigh an Béarla" : "Taispeáin an Béarla",
                          systemImage: showEnglish ? "eye.slash" : "eye")
                }
                Button {
                    withAnimation { page = max(0, page - 1) }
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(page == 0)
                .accessibilityLabel("Siar. Previous slide")
                Button {
                    advance()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(page == lastPage)
                .accessibilityLabel("Ar aghaidh. Next slide")
            }
        }
        .onAppear { UIApplication.shared.isIdleTimerDisabled = true }
        .onDisappear { UIApplication.shared.isIdleTimerDisabled = false }
    }

    /// On a practice or Dul siar slide the first press shows the answer; the next moves on.
    private func advance() {
        if isReveal(slides[page]), !revealed.contains(page) {
            revealed.insert(page)
        } else {
            withAnimation { page = min(lastPage, page + 1) }
        }
    }

    /// From the contents slide, straight to that lesson's rule.
    private func jump(toLesson n: Int) {
        let target = slides.firstIndex { slide in
            if case .lessonRule(_, let i) = slide { return i == n }
            return false
        }
        if let target = target { withAnimation { page = target } }
    }

    private func isReveal(_ slide: GrammarSlide) -> Bool {
        switch slide {
        case .item, .worked, .dulsiar: return true
        default: return false
        }
    }

    private func revealBlock(prompt: String, answer: String, alt: String? = nil, index: Int, scale s: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 20 * s) {
            Text(prompt)
                .font(.system(size: 44 * s, weight: .bold))
                .foregroundStyle(Theme.columnInk(0))
                .padding(20 * s)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.fill(0)))
            if revealed.contains(index) {
                VStack(alignment: .leading, spacing: 8 * s) {
                    Text(Highlight.changes(from: prompt, to: answer))
                        .font(.system(size: 44 * s, weight: .bold))
                    if let alt = alt {
                        Text("nó \(alt)").font(.system(size: 28 * s))
                    }
                }
                    .padding(20 * s)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.penWash))
            } else {
                Button {
                    revealed.insert(index)
                } label: {
                    Label("Taispeáin an freagra · show the answer", systemImage: "eye")
                        .font(.system(size: 24 * s, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
            }
        }
    }

    private func heading(_ text: String, _ s: CGFloat) -> some View {
        Text(text)
            .font(Pen.font(52 * s))
            .foregroundStyle(Theme.pen)
            .rotationEffect(.degrees(-2))
    }

    @ViewBuilder
    private func slideBody(_ slide: GrammarSlide, index: Int, scale s: CGFloat) -> some View {
        switch slide {
        case .title:
            Text(section.title).font(.system(size: 60 * s, weight: .bold))
            if showEnglish {
                Text(section.en).font(.system(size: 30 * s)).foregroundStyle(Theme.muted)
            }
            heading(section.hasLessons ? "Riail · Sampla · Cleachtadh" : "Patrún · Riail · Cleachtadh", s)
            if let links = section.comhra, !links.isEmpty {
                Text("Sa Chomhrá · in the speaking test: " + links.map(\.title).joined(separator: " · "))
                    .font(.system(size: 24 * s, weight: .semibold))
                    .foregroundStyle(Theme.muted)
            }
            DraftBanner()
        case .sprioc:
            heading("Sprioc foghlama", s)
            if showEnglish {
                Text("Learning goals: by the end of this section.")
                    .font(.system(size: 24 * s))
                    .foregroundStyle(Theme.muted)
            }
            ForEach(Array(section.rules.enumerated()), id: \.offset) { _, rule in
                Text("• \(rule.point)")
                    .font(.system(size: 32 * s, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                    .frame(maxWidth: 1100 * s, alignment: .leading)
            }
        case .contents(let lessons):
            heading("Sprioc foghlama · na ceachtanna", s)
            ForEach(Array(lessons.enumerated()), id: \.offset) { i, lesson in
                Button {
                    jump(toLesson: i)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(i + 1). \(lesson.title)")
                            .font(.system(size: 30 * s, weight: .bold))
                            .foregroundStyle(Theme.ink)
                        if showEnglish {
                            Text(lesson.en).font(.system(size: 20 * s)).foregroundStyle(Theme.muted)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
            }
        case .pattern(let models):
            heading("Patrún", s)
            Text(showEnglish ? "Cad é atá cosúil eatarthu? What do they have in common?" : "Cad é atá cosúil eatarthu?")
                .font(.system(size: 26 * s, weight: .semibold))
                .foregroundStyle(Theme.muted)
            ForEach(Array(models.enumerated()), id: \.offset) { _, m in
                VStack(alignment: .leading, spacing: 2) {
                    Text(m.ga).font(.system(size: 40 * s, weight: .bold))
                    if showEnglish && !m.cue.isEmpty {
                        Text(m.cue).font(.system(size: 20 * s).italic()).foregroundStyle(Theme.muted)
                    }
                }
            }
        case .rule(let rule):
            heading("Riail", s)
            Text(rule.point).font(.system(size: 46 * s, weight: .bold))
            Text(rule.text)
                .font(.system(size: 30 * s))
                .frame(maxWidth: 1100 * s, alignment: .leading)
        case .table(let table):
            heading("Tábla", s)
            Text(table.title).font(.system(size: 46 * s, weight: .bold))
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 320 * s), spacing: 24 * s, alignment: .topLeading)],
                      alignment: .leading, spacing: 10 * s) {
                ForEach(Array(table.forms.enumerated()), id: \.offset) { _, form in
                    Text("• \(form)")
                        .font(.system(size: 28 * s))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        case .item(let item):
            heading("Cleachtadh", s)
            Text(showEnglish ? "\(item.task.ga) \(item.task.en)" : item.task.ga)
                .font(.system(size: 26 * s, weight: .semibold))
                .foregroundStyle(Theme.muted)
            revealBlock(prompt: item.prompt, answer: item.answer, alt: item.alt, index: index, scale: s)
        case .lessonRule(let lesson, let i):
            heading("Riail \(i + 1)", s)
            Text(lesson.title).font(.system(size: 46 * s, weight: .bold))
            Text(lesson.rule).font(.system(size: 30 * s)).frame(maxWidth: 1100 * s, alignment: .leading)
            ForEach(Array(lesson.steps.enumerated()), id: \.offset) { n, step in
                Text("\(n + 1). \(step)").font(.system(size: 26 * s))
            }
        case .worked(let lesson):
            heading("Sampla", s)
            Text(lesson.title).font(.system(size: 26 * s, weight: .semibold)).foregroundStyle(Theme.muted)
            revealBlock(prompt: lesson.example.prompt, answer: lesson.example.answer, alt: lesson.example.alt, index: index, scale: s)
        case .dulsiar(let items):
            heading("Dul siar", s)
            if showEnglish {
                Text("Revision: answer each one aloud, then check.")
                    .font(.system(size: 24 * s))
                    .foregroundStyle(Theme.muted)
            }
            ForEach(Array(items.enumerated()), id: \.offset) { n, item in
                VStack(alignment: .leading, spacing: 8 * s) {
                    Text("\(n + 1). \(item.prompt)")
                        .font(.system(size: 30 * s, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    if revealed.contains(index) {
                        Text(Highlight.changes(from: item.prompt, to: item.answer))
                            .font(.system(size: 32 * s, weight: .bold))
                            .accessibilityLabel(item.answer)
                    }
                }
                .padding(.vertical, 4 * s)
            }
            if !revealed.contains(index) {
                Button {
                    revealed.insert(index)
                } label: {
                    Label("Taispeáin na freagraí · show the answers", systemImage: "eye")
                        .font(.system(size: 24 * s, weight: .bold))
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.ink)
            }
        case .end:
            heading("Críoch", s)
            Text(section.title).font(.system(size: 50 * s, weight: .bold))
            let sean = Seanfhocal.forID(section.id)
            heading("Seanfhocal", s)
            VStack(alignment: .leading, spacing: 4 * s) {
                Text(sean.ga)
                    .font(.system(size: 36 * s, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                if showEnglish {
                    Text(sean.en)
                        .font(.system(size: 24 * s))
                        .foregroundStyle(Theme.muted)
                }
            }
            Button {
                dismiss()
            } label: {
                Label("Na sleamhnáin eile · other slides", systemImage: "square.grid.2x2")
                    .font(.system(size: 22 * s, weight: .bold))
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.ink)
        }
    }
}
