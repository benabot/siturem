import SwiftUI

// MARK: - Stats View
// Suivi discret de la pratique : temps, séances, streak.

struct StatsView: View {

    let stats: StatsStore
    @Environment(\.locale) private var locale

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
                    statRow("Streak actuel", value: "\(stats.currentStreak) \(dayAbbreviation)")
                    statRow("Meilleur streak", value: "\(stats.bestStreak) \(dayAbbreviation)")
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

    private func statRow(_ label: LocalizedStringResource, value: String) -> some View {
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

    private var dayAbbreviation: String {
        switch locale.identifier {
        case let id where id.hasPrefix("fr"):
            "j"
        case let id where id.hasPrefix("de"):
            "Tg"
        default:
            "d"
        }
    }

    private var minuteAbbreviation: String {
        locale.identifier.hasPrefix("de") ? "Min." : "min"
    }

    private var hourAbbreviation: String {
        locale.identifier.hasPrefix("de") ? "Std." : "h"
    }
}
