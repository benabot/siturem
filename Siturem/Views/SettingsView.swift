import SwiftUI

// MARK: - Settings View
// Préférences par défaut et options secondaires.

struct SettingsView: View {

    @Bindable var prefs: PreferencesStore
    @State private var healthKit = HealthKitService()
    @State private var hkStatus: String = ""

    var body: some View {
        NavigationStack {
            Form {
                defaultsSection
                healthSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Sections

    private var defaultsSection: some View {
        Section {
            Picker("Accompagnement", selection: $prefs.accompaniment) {
                ForEach(AccompanimentMode.allCases) { m in Text(m.rawValue).tag(m) }
            }
            Picker("Gong", selection: $prefs.gong) {
                ForEach(GongMode.allCases) { g in Text(g.rawValue).tag(g) }
            }
            Picker("Ambiance", selection: $prefs.ambient) {
                ForEach(AmbientSound.allCases) { s in Text(s.rawValue).tag(s) }
            }
            Picker("Rappels", selection: $prefs.reminder) {
                ForEach(ReminderInterval.allCases) { r in Text(r.rawValue).tag(r) }
            }
        } header: {
            sectionHeader("SÉANCE PAR DÉFAUT")
        }
        .listRowBackground(Color(white: 0.08))
    }

    private var healthSection: some View {
        Section {
            Toggle("Synchroniser avec Santé", isOn: $prefs.healthKitEnabled)
            if prefs.healthKitEnabled {
                Button("Autoriser l'accès") {
                    Task {
                        try? await healthKit.requestAuthorization()
                        hkStatus = "Autorisation demandée"
                    }
                }
                .foregroundStyle(.secondary)
                if !hkStatus.isEmpty {
                    Text(hkStatus)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            sectionHeader("SANTÉ")
        } footer: {
            Text("Enregistre les minutes de pleine conscience dans l'app Santé d'Apple.")
                .foregroundStyle(.tertiary)
        }
        .listRowBackground(Color(white: 0.08))
    }

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text("1.0.0").foregroundStyle(.secondary)
            }
        } header: {
            sectionHeader("À PROPOS")
        }
        .listRowBackground(Color(white: 0.08))
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.tertiary)
            .tracking(2)
    }
}
