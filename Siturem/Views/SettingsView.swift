import SwiftUI

// MARK: - Settings View
// Préférences système : HealthKit, interface, accessibilité, informations.
// La configuration de séance (accompagnement, gong, ambiance, rappels) est dans HomeView.

struct SettingsView: View {

    @Bindable var prefs: PreferencesStore
    @State private var healthKit = HealthKitService()
    @State private var hkStatus: String = ""

    var body: some View {
        NavigationStack {
            Form {
                healthSection
                // interfaceSection  // couleur d'accent — à venir
                // voiceSection      // voix et langue — à venir
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Santé

    private var healthSection: some View {
        Section {
            Toggle("Synchroniser avec Santé", isOn: $prefs.healthKitEnabled)
                .tint(Theme.accent)
            if prefs.healthKitEnabled {
                Button("Autoriser l'accès") {
                    Task {
                        try? await healthKit.requestAuthorization()
                        hkStatus = "Autorisation demandée"
                    }
                }
                .foregroundStyle(Theme.textSecondary)
                if !hkStatus.isEmpty {
                    Text(hkStatus)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
        } header: {
            sectionHeader("SANTÉ")
        } footer: {
            Text("Enregistre les minutes de pleine conscience dans l'app Santé d'Apple.")
                .foregroundStyle(Theme.textSecondary)
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - À propos

    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                Text("1.0.0")
                    .foregroundStyle(Theme.textSecondary)
            }
        } header: {
            sectionHeader("À PROPOS")
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .tracking(2)
    }
}
