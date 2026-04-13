import SwiftUI

// MARK: - Home View
// Écran principal : configuration de séance et lancement.

struct HomeView: View {

    @Bindable var prefs: PreferencesStore
    let onStart: (SessionConfiguration) -> Void

    @State private var selectedMinutes: Int = 10
    @State private var showDurationError: Bool = false

    private var selectedDuration: Int { selectedMinutes * 60 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutMetrics.md) {
                    durationSection
                    optionsSection
                }
                .padding(.horizontal, LayoutMetrics.hPadding)
                .padding(.top, LayoutMetrics.sm)
                .padding(.bottom, LayoutMetrics.md)
            }
            .background(Theme.background)
            .safeAreaInset(edge: .bottom) {
                startButton
                    .padding(.horizontal, LayoutMetrics.hPadding)
                    .padding(.top, 12)
                    .padding(.bottom, LayoutMetrics.sm)
                    .background(Theme.background)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    SituremLogo(layout: .horizontal, markSize: 24)
                }
            }
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Durée insuffisante", isPresented: $showDurationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Durée minimale : 6 minutes.")
            }
            .onAppear {
                let minutes = prefs.totalDuration / 60
                selectedMinutes = max(6, min(60, minutes))
            }
            .onChange(of: selectedMinutes) { _, v in
                prefs.totalDuration = v * 60
            }
        }
    }

    // MARK: - Durée

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DURÉE")

            HStack(spacing: LayoutMetrics.md) {
                // Valeur sélectionnée mise en avant
                Text("\(selectedMinutes)")
                    .font(.system(size: 52, weight: .ultraLight, design: .monospaced))
                    .foregroundStyle(Theme.textPrimary)
                    + Text(" min")
                    .font(.system(size: 20, weight: .light, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)

                Spacer()

                // Wheel picker compact
                Picker("Durée", selection: $selectedMinutes) {
                    ForEach(6...60, id: \.self) { m in
                        Text("\(m) min")
                            .font(.system(.body, design: .monospaced))
                            .tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110, height: 110)
                .clipped()
            }
            .padding(.horizontal, LayoutMetrics.sm)
            .padding(.vertical, LayoutMetrics.sm)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Options

    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("OPTIONS")
            VStack(spacing: 1) {
                optionRow("Accompagnement") {
                    Picker("", selection: $prefs.accompaniment) {
                        ForEach(AccompanimentMode.allCases) { m in Text(m.rawValue).tag(m) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
                optionRow("Gong") {
                    Picker("", selection: $prefs.gong) {
                        ForEach(GongMode.allCases) { g in Text(g.rawValue).tag(g) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
                optionRow("Ambiance", isLast: true) {
                    Picker("", selection: $prefs.ambient) {
                        ForEach(AmbientSound.allCases) { s in Text(s.rawValue).tag(s) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func optionRow<Content: View>(_ label: String, isLast: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            content()
        }
        .padding(.horizontal, LayoutMetrics.sm)
        .padding(.vertical, LayoutMetrics.sm)
        .background(Theme.surface)
        .overlay(alignment: .bottom) {
            if !isLast {
                Theme.surfaceHigh.frame(height: 0.5)
            }
        }
    }

    // MARK: - Démarrage

    private var startButton: some View {
        Button {
            let config = SessionConfiguration(
                totalDuration: selectedDuration,
                accompaniment: prefs.accompaniment,
                gong: prefs.gong,
                ambient: prefs.ambient,
                reminder: prefs.reminder,
                audioLocale: prefs.audioLocale
            )
            guard config.isValid else { showDurationError = true; return }
            onStart(config)
        } label: {
            Text("COMMENCER")
                .font(.system(.subheadline, weight: .light))
                .tracking(3)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(.borderedProminent)
        .tint(Theme.accent)
        .foregroundStyle(Theme.background)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .tracking(2)
    }
}
