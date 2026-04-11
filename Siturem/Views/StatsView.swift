import SwiftUI

// MARK: - Stats View
// Suivi discret de la pratique : temps, séances, streak.

struct StatsView: View {

    let stats: StatsStore

    var body: some View {
        NavigationStack {
            List {
                Section("Pratique") {
                    statRow("Temps total", value: formatMinutes(stats.totalSeconds))
                    statRow("Séances", value: "\(stats.totalSessions)")
                }

                Section("Période") {
                    statRow("7 derniers jours", value: formatMinutes(stats.seconds7Days))
                    statRow("30 derniers jours", value: formatMinutes(stats.seconds30Days))
                }

                Section("Régularité") {
                    statRow("Streak actuel", value: "\(stats.currentStreak) j")
                    statRow("Meilleur streak", value: "\(stats.bestStreak) j")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .listRowBackground(Theme.surface)
            .navigationTitle("Suivi")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private func statRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.textSecondary)
                .font(.system(.body, design: .monospaced))
        }
    }

    private func formatMinutes(_ seconds: Int) -> String {
        let total = seconds / 60
        if total < 60 { return "\(total) min" }
        let h = total / 60
        let m = total % 60
        return m > 0 ? "\(h) h \(m) min" : "\(h) h"
    }
}
