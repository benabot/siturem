import SwiftUI

// MARK: - Splash View
// Écran de lancement. Sobre, stable, ancré dans le territoire de marque.

struct SplashView: View {

    @State private var contentOpacity = 0.0
    @State private var baselineOpacity = 0.0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Text("SITUREM")
                        .font(.system(size: 32, weight: .ultraLight))
                        .tracking(10)
                        .foregroundStyle(Theme.textPrimary)

                    Text("Méditation structurée")
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)
                        .tracking(2)
                }
                .opacity(contentOpacity)

                Spacer().frame(height: 36)

                Text("Le cadre discret de votre pratique.")
                    .font(.system(.caption2))
                    .foregroundStyle(Theme.accent.opacity(0.7))
                    .tracking(0.5)
                    .opacity(baselineOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                contentOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.9)) {
                baselineOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
