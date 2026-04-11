import SwiftUI

// MARK: - Splash View
// Écran de lancement affiché brièvement au démarrage.

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 10) {
                Text("SITUREM")
                    .font(.system(size: 30, weight: .ultraLight))
                    .tracking(8)
                    .foregroundStyle(.primary)
                Text("Méditation structurée")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .tracking(1.5)
            }
        }
    }
}

#Preview {
    SplashView()
        .preferredColorScheme(.dark)
}
