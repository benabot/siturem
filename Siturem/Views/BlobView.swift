import SwiftUI

// MARK: - Blob View
// Forme organique animée affichée durant la séance.
// Remplace le compteur numérique. Respire selon la phase en cours.

struct BlobView: View {

    let phase: SessionPhase

    @State private var animationKey = UUID()
    @State private var breathing = false

    // Durée d'un cycle de respiration selon la phase
    private var duration: Double {
        switch phase {
        case .intro:      return 5.0   // lent
        case .meditation: return 7.5   // très lent, quasi-immobile
        case .closing:    return 3.5   // légèrement plus ample
        }
    }

    // Amplitude des déplacements selon la phase
    private var spread: CGFloat {
        switch phase {
        case .intro:      return 12
        case .meditation: return 6
        case .closing:    return 18
        }
    }

    var body: some View {
        ZStack {
            // Couche extérieure — halo diffus
            Ellipse()
                .fill(Theme.accent.opacity(0.10))
                .frame(width: 220, height: 200)
                .scaleEffect(breathing ? 1.07 : 0.94)
                .offset(x: breathing ? spread : -spread * 0.6,
                        y: breathing ? -spread * 0.7 : spread * 0.5)
                .blur(radius: 30)

            // Couche intermédiaire
            Ellipse()
                .fill(Theme.accent.opacity(0.16))
                .frame(width: 170, height: 185)
                .scaleEffect(breathing ? 0.95 : 1.06)
                .offset(x: breathing ? -spread * 0.9 : spread * 0.5,
                        y: breathing ? spread * 0.8 : -spread * 0.4)
                .blur(radius: 20)

            // Noyau central
            Circle()
                .fill(Theme.accent.opacity(0.26))
                .frame(width: 130, height: 130)
                .scaleEffect(breathing ? 1.05 : 0.97)
                .offset(x: breathing ? spread * 0.4 : -spread * 0.3,
                        y: breathing ? -spread * 0.5 : spread * 0.6)
                .blur(radius: 12)
        }
        .id(animationKey) // recrée la vue (et relance onAppear) au changement de phase
        .onAppear {
            withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                breathing = true
            }
        }
        .onChange(of: phase) { _, _ in
            animationKey = UUID()
        }
    }
}
