import SwiftUI

// MARK: - Siturem Mark
// Signe géométrique de la marque : trois segments horizontaux gauche-alignés
// représentant les trois phases d'une séance (intro · méditation · closing).
// Largeurs proportionnelles aux durées relatives d'une séance de 10 min :
//   intro   → 150 s / 600 s ≈ 55 % (visuel ajusté)
//   méditation → 405 s / 600 s = 100 % (phase principale)
//   closing → 45 s  / 600 s ≈ 30 % (visuel ajusté)

struct SituremMark: View {

    /// Largeur de référence (= largeur du segment méditation, le plus long)
    var size: CGFloat = 32
    var color: Color = Theme.accent

    private var lineHeight: CGFloat { max(1.5, size * 0.065) }
    private var gap: CGFloat { lineHeight * 2.6 }

    var body: some View {
        VStack(alignment: .leading, spacing: gap) {
            // Intro
            Capsule()
                .fill(color.opacity(0.70))
                .frame(width: size * 0.55, height: lineHeight)
            // Méditation (phase principale — pleine largeur)
            Capsule()
                .fill(color)
                .frame(width: size, height: lineHeight)
            // Closing
            Capsule()
                .fill(color.opacity(0.45))
                .frame(width: size * 0.30, height: lineHeight)
        }
        .frame(width: size, alignment: .leading)
    }
}

// MARK: - Siturem Logo
// Composition : mark + wordmark verticaux (splash) ou horizontaux (nav bar).

struct SituremLogo: View {

    enum Layout { case vertical, horizontal }

    var layout: Layout = .vertical
    var markSize: CGFloat = 40
    var color: Color = Theme.accent

    private var wordmarkSize: CGFloat {
        layout == .vertical ? markSize * 0.45 : markSize * 0.38
    }
    private var subtitleSize: CGFloat { wordmarkSize * 0.60 }
    private var spacing: CGFloat { markSize * 0.30 }

    var body: some View {
        switch layout {
        case .vertical:   vertical
        case .horizontal: horizontal
        }
    }

    private var vertical: some View {
        VStack(alignment: .leading, spacing: spacing) {
            SituremMark(size: markSize, color: color)
            VStack(alignment: .leading, spacing: 4) {
                Text("SITUREM")
                    .font(.system(size: wordmarkSize, weight: .ultraLight))
                    .tracking(wordmarkSize * 0.28)
                    .foregroundStyle(Theme.textPrimary)
                Text("Méditation structurée")
                    .font(.system(size: subtitleSize, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(0.8)
            }
        }
    }

    private var horizontal: some View {
        HStack(alignment: .center, spacing: spacing * 0.8) {
            SituremMark(size: markSize, color: color)
            Text("SITUREM")
                .font(.system(size: wordmarkSize, weight: .ultraLight))
                .tracking(wordmarkSize * 0.22)
                .foregroundStyle(Theme.textPrimary)
        }
    }
}

// MARK: - Previews

#Preview("Mark") {
    HStack(spacing: 40) {
        SituremMark(size: 24)
        SituremMark(size: 40)
        SituremMark(size: 72)
    }
    .padding(40)
    .background(Theme.background)
    .preferredColorScheme(.dark)
}

#Preview("Logo vertical") {
    SituremLogo(layout: .vertical, markSize: 56)
        .padding(40)
        .background(Theme.background)
        .preferredColorScheme(.dark)
}

#Preview("Logo horizontal") {
    SituremLogo(layout: .horizontal, markSize: 20)
        .padding(40)
        .background(Theme.background)
        .preferredColorScheme(.dark)
}
