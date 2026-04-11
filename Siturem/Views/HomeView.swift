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
            .background(Color.black)
            .safeAreaInset(edge: .bottom) {
                startButton
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                    .background(Color.black)
            }
            .navigationTitle("Siturem")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.black, for: .navigationBar)
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
                        .foregroundStyle(.primary)
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
        .background(selected ? Color.primary : Color(white: 0.1))
        .foregroundStyle(selected ? Color.black : Color.primary)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .animation(.easeInOut(duration: 0.15), value: selected)
    }

    private var customDurationChip: some View {
        Button("Perso") { useCustom = true }
            .font(.system(.subheadline, design: .monospaced))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(useCustom ? Color.primary : Color(white: 0.1))
            .foregroundStyle(useCustom ? Color.black : Color.primary)
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
                    .tint(.secondary)
                }
                optionRow("Gong") {
                    Picker("", selection: $prefs.gong) {
                        ForEach(GongMode.allCases) { g in Text(g.rawValue).tag(g) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(.secondary)
                }
                optionRow("Ambiance") {
                    Picker("", selection: $prefs.ambient) {
                        ForEach(AmbientSound.allCases) { s in Text(s.rawValue).tag(s) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(.secondary)
                }
                optionRow("Rappels", isLast: true) {
                    Picker("", selection: $prefs.reminder) {
                        ForEach(ReminderInterval.allCases) { r in Text(r.rawValue).tag(r) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(.secondary)
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
                .foregroundStyle(.primary)
            Spacer()
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(white: 0.08))
        .overlay(alignment: .bottom) {
            if !isLast {
                Color(white: 0.12).frame(height: 0.5)
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
        .tint(.primary)
        .foregroundStyle(Color.black)
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.tertiary)
            .tracking(2)
    }
}
