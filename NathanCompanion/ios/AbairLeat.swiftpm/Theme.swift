import SwiftUI
import UIKit
import CoreText

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    /// A colour that follows light and dark mode.
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }
}

enum Theme {
    static let ground = Color(light: 0xF3F5F9, dark: 0x0F141C)
    static let surface = Color(light: 0xFFFFFF, dark: 0x171E2A)
    static let ink = Color(light: 0x172031, dark: 0xE7EBF1)
    static let muted = Color(light: 0x5B6576, dark: 0xA1AABA)
    static let rule = Color(light: 0xDDE2E9, dark: 0x283245)
    static let pen = Color(light: 0xC8102E, dark: 0xFF6F6F)
    static let penWash = Color(light: 0xFCEEF0, dark: 0x3A1D24)
    static let good = Color(light: 0x16704F, dark: 0x5CCB9E)
    static let hi = Color(light: 0xFFD84D, dark: 0x8A6A00)

    /// Each column of a builder keeps its own colour, as on the printed sheets.
    private static let fills: [Color] = [
        Color(light: 0xE3EEFF, dark: 0x1B2A48),
        Color(light: 0xDDF5E7, dark: 0x15352A),
        Color(light: 0xFFF0C7, dark: 0x3A2E10),
        Color(light: 0xF1E6FF, dark: 0x2C2045)
    ]
    private static let inks: [Color] = [
        Color(light: 0x1D45B0, dark: 0xA9C3FF),
        Color(light: 0x16704F, dark: 0x8FE0B8),
        Color(light: 0x8A5800, dark: 0xF5CF73),
        Color(light: 0x6B3FB5, dark: 0xCDB2FF)
    ]
    static func fill(_ column: Int) -> Color { fills[column % 4] }
    static func columnInk(_ column: Int) -> Color { inks[column % 4] }
}

/// Dáithí's marking hand, bundled as a font and registered at launch.
enum Pen {
    static let postScriptName = "MarkingHand-Regular"

    static func register() {
        guard let url = Bundle.main.url(forResource: "MarkingHand-Regular", withExtension: "otf") else { return }
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
    }

    static func font(_ size: CGFloat) -> Font {
        .custom(postScriptName, size: size)
    }
}

/// Lays children out left to right, wrapping onto new lines.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, lineHeight: CGFloat = 0, widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
            if x > 0 && x + size.width > maxWidth {
                y += lineHeight + spacing
                x = 0
                lineHeight = 0
            }
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(ProposedViewSize(width: bounds.width, height: nil))
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += lineHeight + spacing
                x = bounds.minX
                lineHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: size.width, height: size.height))
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

/// One chunk of a builder, in its column's colour.
struct TileView: View {
    let chunk: Chunk
    let column: Int
    var selected = false
    var lit = false
    var gaSize: CGFloat = 18
    var showEnglish = true

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(chunk.ga)
                .font(.system(size: gaSize, weight: .bold))
            if showEnglish && chunk.showsEnglish {
                Text(chunk.en)
                    .font(.system(size: max(12, gaSize * 0.62)))
                    .opacity(0.85)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.horizontal, gaSize * 0.7)
        .padding(.vertical, gaSize * 0.5)
        .foregroundStyle(Theme.columnInk(column))
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.fill(column)))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(lit ? Theme.hi : (selected ? Theme.columnInk(column) : Color.clear), lineWidth: lit ? 4 : 3)
        )
        .overlay(alignment: .topTrailing) {
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Theme.columnInk(column))
                    .background(Circle().fill(Theme.fill(column)))
                    .offset(x: 6, y: -6)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(selected ? [.isButton, .isSelected] : .isButton)
    }
}

/// A builder row as colour-coded columns, each column a wrapping group of tiles, with arrows between.
struct BuilderGrid: View {
    let unit: BuilderUnit
    let row: BuilderRow
    var selected: [String] = []
    var litChunk: String? = nil
    var gaSize: CGFloat = 18
    var showEnglish = true
    let onTap: (Chunk, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(row.columns.enumerated()), id: \.offset) { k, column in
                if k > 0 {
                    Image(systemName: "arrow.down")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Theme.muted)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }
                FlowLayout(spacing: 8) {
                    ForEach(column) { chunk in
                        Button {
                            onTap(chunk, k)
                        } label: {
                            TileView(chunk: chunk, column: k,
                                     selected: selected.contains(chunk.id),
                                     lit: litChunk == chunk.id,
                                     gaSize: gaSize,
                                     showEnglish: showEnglish)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

/// A white panel for the main content of a screen.
struct Panel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Theme.rule))
    }
}

/// The red-pen feedback box.
struct PenNote: View {
    let text: String
    var detail: String? = nil
    var size: CGFloat = 30

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(Pen.font(size))
                .foregroundStyle(Theme.pen)
                .rotationEffect(.degrees(-1))
            if let detail = detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(Theme.muted)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Theme.penWash))
        .accessibilityElement(children: .combine)
    }
}

/// A sentence spoken aloud, with the chunk being said lit up.
struct SpokenLine: View {
    let sentence: Sentence
    let unit: BuilderUnit
    let lit: Int?
    var size: CGFloat = 22
    var showEnglish = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            FlowLayout(spacing: 4) {
                ForEach(Array(sentence.chunks.enumerated()), id: \.offset) { i, chunkID in
                    Text(unit.chunk(chunkID)?.ga ?? "")
                        .font(.system(size: size, weight: .bold))
                        .padding(.horizontal, 4)
                        .background(RoundedRectangle(cornerRadius: 6).fill(lit == i ? Theme.hi : Color.clear))
                }
            }
            if showEnglish {
                Text(sentence.en)
                    .font(.system(size: max(14, size * 0.65)))
                    .foregroundStyle(Theme.muted)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(sentence.ga + ". " + sentence.en)
    }
}
