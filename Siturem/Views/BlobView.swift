import SwiftUI

// MARK: - Blob View
// Forme organique animée affichée durant la séance.
// Chaque couche a une durée d'animation propre (valeurs incommensurables)
// pour créer un mouvement irrégulier et organique.

struct BlobView: View {

    let phase: SessionPhase

    // 5 états indépendants — chacun animé à sa propre vitesse
    @State private var s1 = false // scale couche extérieure
    @State private var s2 = false // scale couche intermédiaire
    @State private var s3 = false // scale noyau
    @State private var o1 = false // offset axe 1
    @State private var o2 = false // offset axe 2

    private var base: Double {
        switch phase {
        case .intro:      return 4.5
        case .meditation: return 6.8
        case .closing:    return 3.2
        }
    }

    /// Agrandit légèrement le blob pour éviter l'effet de bloc trop contenu.
    private var visualScale: CGFloat {
        switch phase {
        case .intro: return 1.18
        case .meditation: return 1.26
        case .closing: return 1.12
        }
    }

    var body: some View {
        ZStack {
            // Halo externe — lent, large
            Ellipse()
                .fill(Theme.accent.opacity(0.09))
                .frame(width: 280, height: 255)
                .scaleEffect(s1 ? 1.14 : 0.87)
                .offset(x: o1 ? 16 : -10, y: o1 ? -13 : 9)
                .blur(radius: 38)

            // Couche intermédiaire — rythme différent
            Ellipse()
                .fill(Theme.accent.opacity(0.16))
                .frame(width: 210, height: 225)
                .scaleEffect(s2 ? 0.89 : 1.11)
                .offset(x: o2 ? -18 : 11, y: o2 ? 15 : -10)
                .blur(radius: 24)

            // Noyau — plus visible, rythme propre
            Circle()
                .fill(Theme.accent.opacity(0.28))
                .frame(width: 160, height: 160)
                .scaleEffect(s3 ? 1.09 : 0.93)
                .offset(x: s1 ? 7 : -5, y: o2 ? -9 : 10)
                .blur(radius: 15)
        }
        .frame(width: LayoutMetrics.blobCanvasSize, height: LayoutMetrics.blobCanvasSize)
        .scaleEffect(visualScale)
        .compositingGroup()
        .padding(LayoutMetrics.blobPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: startAnimations)
        .onChange(of: phase) { _, _ in restartAnimations() }
    }

    private func startAnimations() {
        // Durées incommensurables = mouvement jamais périodique = irrégularité organique
        withAnimation(.easeInOut(duration: base * 1.00).repeatForever(autoreverses: true)) { s1 = true }
        withAnimation(.easeInOut(duration: base * 1.37).repeatForever(autoreverses: true)) { s2 = true }
        withAnimation(.easeInOut(duration: base * 0.79).repeatForever(autoreverses: true)) { s3 = true }
        withAnimation(.easeInOut(duration: base * 1.19).repeatForever(autoreverses: true)) { o1 = true }
        withAnimation(.easeInOut(duration: base * 0.91).repeatForever(autoreverses: true)) { o2 = true }
    }

    private func restartAnimations() {
        s1 = false; s2 = false; s3 = false; o1 = false; o2 = false
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(50))
            startAnimations()
        }
    }
}
