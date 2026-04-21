import SwiftUI

// MARK: - Stats View
// Suivi discret de la pratique : temps, séances, streak.

struct StatsView: View {

    let stats: StatsStore
    @Environment(\.locale) private var locale

    private let heatmapColumns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 15
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutMetrics.md) {
                    sectionLabel("Pratique")
                    essentialsCard
                    heatmapCard
                }
                .padding(.horizontal, LayoutMetrics.hPadding)
                .padding(.top, LayoutMetrics.sm)
                .padding(.bottom, LayoutMetrics.md)
            }
            .background(Theme.background)
            .navigationTitle("Suivi")
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var essentialsCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Temps total")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
                    .tracking(2)

                Text(formatMinutes(stats.totalSeconds))
                    .font(.system(size: 44, weight: .ultraLight, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
            }

            metricRow("Séances", value: "\(stats.totalSessions)")

            cardSeparator

            metricGroup(title: "Période") {
                metricRow("7 derniers jours", value: formatMinutes(stats.seconds7Days))
                metricRow("30 derniers jours", value: formatMinutes(stats.seconds30Days))
            }

            cardSeparator

            metricGroup(title: "Régularité") {
                metricRow("Streak actuel", value: "\(stats.currentStreak) \(dayAbbreviation)")
                metricRow("Meilleur streak", value: "\(stats.bestStreak) \(dayAbbreviation)")
            }
        }
        .padding(LayoutMetrics.sm)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var heatmapCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("90 derniers jours")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            LazyVGrid(columns: heatmapColumns, spacing: 4) {
                ForEach(stats.practiceHeatmap90Days) { day in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(day.didPractice ? Theme.accent.opacity(0.55) : Theme.surfaceHigh)
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                }
            }

            if stats.practiceHeatmap90Days.allSatisfy({ !$0.didPractice }) {
                Text("Aucune séance sur les 90 derniers jours")
                    .font(.system(.caption))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .padding(LayoutMetrics.sm)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func sectionLabel(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .tracking(2)
    }

    @ViewBuilder
    private func metricGroup<Content: View>(
        title: LocalizedStringResource,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            content()
        }
    }

    private func metricRow(_ label: LocalizedStringResource, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            Text(value)
                .foregroundStyle(Theme.textSecondary)
                .font(.system(.body, design: .monospaced))
        }
    }

    private var cardSeparator: some View {
        Theme.surfaceHigh
            .frame(height: 0.5)
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
