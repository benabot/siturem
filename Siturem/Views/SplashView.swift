import SwiftUI

// MARK: - Splash View
// Écran de lancement. Sobre, stable, ancré dans le territoire de marque.

struct SplashView: View {

    @State private var logoOpacity = 0.0
    @State private var baselineOpacity = 0.0

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                SituremLogo(layout: .vertical, markSize: 80)
                    .opacity(logoOpacity)

                Spacer().frame(height: 32)

                Text("Le cadre discret de votre pratique.")
                    .font(.system(.caption2))
                    .foregroundStyle(Theme.accent.opacity(0.65))
                    .tracking(0.5)
                    .opacity(baselineOpacity)
            }
            .padding(.horizontal, LayoutMetrics.hPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                logoOpacity = 1.0
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
