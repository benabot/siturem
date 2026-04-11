import Foundation

// MARK: - Golden Ratio Layout Constants
// φ (phi) = 1.618... Utilisé pour tous les espacements et proportions.
// Source de vérité pour la cohérence visuelle.

enum LayoutMetrics {
    static let phi = 1.618

    // MARK: - Espacements principaux (base 40 pt)

    /// Base : 40 pt
    static let base: CGFloat = 40

    /// Small : 40 / φ ≈ 24.7 pt
    static let sm: CGFloat = 24.7

    /// Medium : 40 pt (base)
    static let md: CGFloat = 40

    /// Large : 40 × φ ≈ 64.7 pt
    static let lg: CGFloat = 64.7

    /// X-Large : 40 × φ² ≈ 104.7 pt
    static let xl: CGFloat = 104.7

    // MARK: - SessionView spécifiques

    /// Padding horizontal (générique)
    static let hPadding: CGFloat = 40

    /// Offset label de phase depuis le top
    static let phaseTopOffset: CGFloat = 56

    /// Spacing blob → progression
    static let blobToProgressSpacing: CGFloat = 65

    /// Spacing progression → boutons
    static let progressToControlsSpacing: CGFloat = 24

    /// Padding au-dessus du home indicator (safeAreaInset)
    static let safeAreaBottomPadding: CGFloat = sm   // 24.7 pt
}
