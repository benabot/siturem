import SwiftUI

// MARK: - Session Detail View
// Détail sobre d'une séance enregistrée depuis le registre de pratique.

struct SessionDetailView: View {

    let record: SessionRecord
    @Environment(\.locale) private var locale

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutMetrics.md) {
                summaryCard
                detailsCard
            }
            .padding(.horizontal, LayoutMetrics.hPadding)
            .padding(.top, LayoutMetrics.sm)
            .padding(.bottom, LayoutMetrics.md)
        }
        .background(Theme.background)
        .navigationTitle("Séance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(detailDate)
                .font(.system(.caption))
                .foregroundStyle(Theme.textSecondary)

            Text("Durée réalisée")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            Text(formatMinutes(record.actualDuration))
                .font(.system(size: 44, weight: .ultraLight, design: .monospaced))
                .foregroundStyle(Theme.textPrimary)
        }
        .padding(LayoutMetrics.sm)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Repères")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .tracking(2)

            VStack(spacing: 0) {
                detailRow("Durée prévue", value: formatMinutes(record.plannedDuration))
                cardSeparator
                accompanimentRow
            }
            .background(Theme.surfaceHigh.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(LayoutMetrics.sm)
        .background(Theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func detailRow(_ title: LocalizedStringResource, value: String) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text(value)
                .foregroundStyle(Theme.textSecondary)
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.trailing)
        }
        .padding(LayoutMetrics.sm)
    }

    private func detailRow(_ title: LocalizedStringResource, value: LocalizedStringResource) -> some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundStyle(Theme.textPrimary)

            Spacer()

            Text(value)
                .foregroundStyle(Theme.textSecondary)
                .font(.system(.body, design: .monospaced))
                .multilineTextAlignment(.trailing)
        }
        .padding(LayoutMetrics.sm)
    }

    private var cardSeparator: some View {
        Theme.surfaceHigh
            .frame(height: 0.5)
    }

    @ViewBuilder
    private var accompanimentRow: some View {
        if let mode = record.accompanimentMode {
            detailRow("Accompagnement", value: mode.displayLabel)
        } else {
            detailRow("Accompagnement", value: record.accompaniment)
        }
    }

    private var detailDate: String {
        record.date.formatted(
            .dateTime
            .locale(locale)
            .weekday(.wide)
            .day()
            .month(.wide)
            .year()
            .hour()
            .minute()
        )
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
