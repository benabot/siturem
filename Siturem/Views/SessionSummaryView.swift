import SwiftUI

// MARK: - Session Summary View
// Écran affiché à la fin d'une séance terminée normalement.

struct SessionSummaryView: View {

    let duration: Int
    let todayTotal: Int
    let onRestart: () -> Void
    let onDone: () -> Void
    @Environment(\.locale) private var locale

    var body: some View {
        VStack(spacing: LayoutMetrics.md) {
            Spacer()

            VStack(spacing: 14) {
                Text("Séance terminée")
                    .font(.system(.title2, weight: .light))
                    .foregroundStyle(Theme.textPrimary)

                Text("Durée réalisée")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(2)

                Text(formatDuration(duration))
                    .font(.system(size: 56, weight: .thin, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
            }

            todayRow

            Spacer()

            VStack(spacing: 12) {
                Button("Relancer") {
                    onRestart()
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
                .foregroundStyle(Theme.background)

                Button("Terminer") {
                    onDone()
                }
                .buttonStyle(.bordered)
                .tint(Theme.textSecondary)
            }
            .frame(maxWidth: 280)
            .padding(.bottom, 32)
        }
        .padding(.horizontal, LayoutMetrics.hPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
    }

    private var todayRow: some View {
        HStack(spacing: 16) {
            Text("Aujourd'hui")
                .font(.system(.subheadline))
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text(formatMinutes(todayTotal))
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
        }
        .padding(.horizontal, LayoutMetrics.sm)
        .padding(.vertical, LayoutMetrics.sm)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatDuration(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func formatMinutes(_ seconds: Int) -> String {
        let totalMinutes = max(0, seconds / 60)

        if totalMinutes < 60 {
            return "\(totalMinutes) \(minuteAbbreviation)"
        }

        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if minutes == 0 {
            return "\(hours) \(hourAbbreviation)"
        }

        return "\(hours) \(hourAbbreviation) \(minutes) \(minuteAbbreviation)"
    }

    private var minuteAbbreviation: String {
        locale.identifier.hasPrefix("de") ? "Min." : "min"
    }

    private var hourAbbreviation: String {
        locale.identifier.hasPrefix("de") ? "Std." : "h"
    }
}
