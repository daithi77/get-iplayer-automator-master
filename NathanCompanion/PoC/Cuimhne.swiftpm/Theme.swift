import SwiftUI

enum Theme {
    static let paper = Color(red: 0.992, green: 0.988, blue: 0.969)   // #FDFCF7
    static let ink = Color(red: 0.078, green: 0.129, blue: 0.239)     // #14213D
    static let rule = Color(red: 0.749, green: 0.816, blue: 0.902)    // #BFD0E6
    static let margin = Color(red: 0.910, green: 0.627, blue: 0.659)  // #E8A0A8
    static let biro = Color(red: 0.102, green: 0.247, blue: 0.651)    // #1A3FA6
    static let pen = Color(red: 0.784, green: 0.063, blue: 0.180)     // #C8102E
    static let grey = Color(red: 0.420, green: 0.447, blue: 0.502)    // #6B7280

    static let lineHeight: CGFloat = 32
    static let marginX: CGFloat = 44
}

/// Ruled copybook paper with a red margin, drawn behind whatever sits on it.
struct RuledPaper: View {
    var body: some View {
        Canvas { ctx, size in
            var y = Theme.lineHeight
            while y < size.height {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: .color(Theme.rule), lineWidth: 1)
                y += Theme.lineHeight
            }
            var m = Path()
            m.move(to: CGPoint(x: Theme.marginX, y: 0))
            m.addLine(to: CGPoint(x: Theme.marginX, y: size.height))
            ctx.stroke(m, with: .color(Theme.margin), lineWidth: 2)
        }
        .allowsHitTesting(false)
    }
}

/// The candidate box at the top of every page.
struct ExamHeader: View {
    let name: String
    let pupilClass: String
    let unit: String
    let right: String
    var score: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                cell { labelled("Ainm:", value: name) }
                divider
                cell { labelled("Rang:", value: pupilClass) }
            }
            Rectangle().fill(Theme.ink).frame(height: 1.5)
            HStack(spacing: 0) {
                cell { Text(unit).tracking(0.5).font(.caption).textCase(.uppercase) }
                divider
                cell {
                    HStack {
                        Text(right).tracking(0.5).font(.caption).textCase(.uppercase)
                        Spacer(minLength: 4)
                        if let score {
                            Text(score).font(MarkingHand.font(20)).foregroundColor(Theme.pen)
                        }
                    }
                }
            }
        }
        .foregroundColor(Theme.ink)
        .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1.5))
        .background(Theme.paper)
    }

    private var divider: some View { Rectangle().fill(Theme.ink).frame(width: 1.5) }

    private func cell<V: View>(@ViewBuilder _ content: () -> V) -> some View {
        content()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .frame(height: 36)
    }

    private func labelled(_ label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text(label).tracking(0.5).font(.caption).textCase(.uppercase)
            Text(value).font(MarkingHand.font(20)).foregroundColor(Theme.biro)
        }
    }
}

/// A rubric line in the papers' own register: Irish in italic, English in grey.
struct Rubric: View {
    let ga: String
    let en: String
    var body: some View {
        (Text(ga).italic() + Text(" ") + Text(en).foregroundColor(Theme.grey))
            .font(.subheadline)
            .foregroundColor(Theme.ink)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// A mark in the margin, in the marking hand.
struct PenMark: View {
    let text: String
    var size: CGFloat = 26
    var tilt: Double = -3
    var body: some View {
        Text(text)
            .font(MarkingHand.font(size))
            .foregroundColor(Theme.pen)
            .rotationEffect(.degrees(tilt))
    }
}

/// One ruled line of text, sitting on the paper's rule.
struct PaperLine: View {
    let text: String
    var bold: Bool = false
    var color: Color = Theme.ink
    var body: some View {
        Text(text)
            .font(.system(size: 19, weight: bold ? .bold : .regular))
            .foregroundColor(color)
            .frame(height: Theme.lineHeight, alignment: .bottomLeading)
            .padding(.bottom, 4)
    }
}

/// The answer box the pupil types into.
struct AnswerBox: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let focused: FocusState<Int?>.Binding
    let field: Int
    let locked: Bool
    let struck: Bool
    let onSubmit: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            if !label.isEmpty {
                Text(label)
                    .font(.footnote)
                    .foregroundColor(Theme.ink)
                    .frame(width: 120, alignment: .leading)
            }
            TextField(placeholder, text: $text)
                .font(.system(size: 20))
                .foregroundColor(Theme.biro)
                .strikethrough(struck, color: Theme.pen)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .submitLabel(.next)
                .focused(focused, equals: field)
                .disabled(locked)
                .onSubmit(onSubmit)
                .padding(.horizontal, 10)
                .frame(height: 44)
                .background(Color.white)
                .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1.5))
        }
    }
}

struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.body.weight(.bold))
                .foregroundColor(.white)
                .padding(.horizontal, 22)
                .frame(height: 44)
                .background(Theme.ink)
                .overlay(Rectangle().stroke(Theme.ink, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
    }
}

struct LinkButton: View {
    let title: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .underline()
                .foregroundColor(Theme.grey)
                .frame(height: 44)
        }
        .buttonStyle(.plain)
    }
}

/// The fada row shown above the keyboard on every typing screen.
struct FadaToolbar: ToolbarContent {
    let insert: (String) -> Void
    let check: () -> Void
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            ForEach(["á", "é", "í", "ó", "ú"], id: \.self) { c in
                Button(c) { insert(c) }
                    .font(.system(size: 22))
                    .frame(minWidth: 44, minHeight: 44)
            }
            Spacer()
            Button("Seiceáil", action: check).fontWeight(.bold)
        }
    }
}
