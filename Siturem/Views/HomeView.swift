import SwiftUI

// MARK: - Home View
// Écran principal : configuration de séance et lancement.

struct HomeView: View {

    @Bindable var prefs: PreferencesStore
    let onStart: (SessionConfiguration) -> Void

    @State private var customMinutes: Int = 10
    @State private var useCustom: Bool = false
    @State private var showDurationError: Bool = false

    private var selectedDuration: Int {
        useCustom ? customMinutes * 60 : prefs.totalDuration
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    durationSection
                    optionsSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .background(Theme.background)
            .safeAreaInset(edge: .bottom) {
                startButton
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Theme.background)
            }
            .navigationTitle("Siturem")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .alert("Durée insuffisante", isPresented: $showDurationError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Durée minimale : 6 minutes.")
            }
        }
    }

    // MARK: - Durée

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DURÉE")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(SessionDuration.allCases) { preset in
                        durationChip(preset)
                    }
                    customDurationChip
                }
            }
            if useCustom {
                HStack {
                    Text("\(customMinutes) min")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Stepper("", value: $customMinutes, in: 6...120)
                        .labelsHidden()
                }
                .padding(.top, 4)
            }
        }
    }

    private func durationChip(_ preset: SessionDuration) -> some View {
        let selected = !useCustom && prefs.totalDuration == preset.totalSeconds
        return Button(preset.label) {
            useCustom = false
            prefs.totalDuration = preset.totalSeconds
        }
        .font(.system(.subheadline, design: .monospaced))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(selected ? Theme.accent : Theme.surface)
        .foregroundStyle(selected ? Theme.background : Theme.textPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    private var customDurationChip: some View {
        Button("Perso") { useCustom = true }
            .font(.system(.subheadline, design: .monospaced))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(useCustom ? Theme.accent : Theme.surface)
            .foregroundStyle(useCustom ? Theme.background : Theme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .animation(.easeInOut(duration: 0.15), value: useCustom)
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
                optionRow("Ambiance") {
                    Picker("", selection: $prefs.ambient) {
                        ForEach(AmbientSound.allCases) { s in Text(s.rawValue).tag(s) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
                optionRow("Rappels", isLast: true) {
                    Picker("", selection: $prefs.reminder) {
                        ForEach(ReminderInterval.allCases) { r in Text(r.rawValue).tag(r) }
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
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
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
                reminder: prefs.reminder
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
