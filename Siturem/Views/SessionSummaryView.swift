import SwiftUI

// MARK: - Session Summary View
// Écran affiché à la fin d'une séance terminée normalement.

struct SessionSummaryView: View {

    let duration: Int
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            VStack(spacing: 12) {
                Text("Séance terminée")
                    .font(.system(.title2, weight: .light))
                    .foregroundStyle(.primary)

                Text(formatDuration(duration))
                    .font(.system(size: 56, weight: .thin, design: .monospaced))
                    .foregroundStyle(.primary)
            }

            Spacer()

            Button("Terminer") {
                onDone()
            }
            .buttonStyle(.bordered)
            .tint(.primary)
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
