import SwiftUI

// MARK: - Theme
// Palette centralisée. Remplace Color.black et Color(white:) partout dans l'app.

enum Theme {
    /// Fond principal — anthracite profond, légèrement bleuté
    static let background    = Color(red: 0.094, green: 0.094, blue: 0.118)
    /// Fond secondaire — gris minéral (cartes, rangées)
    static let surface       = Color(red: 0.133, green: 0.133, blue: 0.165)
    /// Fond tertiaire — séparateurs, bords
    static let surfaceHigh   = Color(red: 0.165, green: 0.165, blue: 0.200)
    /// Accent unique — bleu ardoise désaturé (cf. BrandingGuideline §12)
    static let accent        = Color(red: 0.431, green: 0.498, blue: 0.639)
    /// Texte principal — blanc cassé
    static let textPrimary   = Color(red: 0.941, green: 0.929, blue: 0.910)
    /// Texte secondaire — gris clair froid
    static let textSecondary = Color(red: 0.541, green: 0.561, blue: 0.620)
}
