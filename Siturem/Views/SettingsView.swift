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
                principlesSection
                sessionSection
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

    // MARK: - Principes

    private var principlesSection: some View {
        Section {
            principleRow(
                title: "Trois phases fixes",
                detail: "Introduction (2 min 30) — Méditation (durée choisie) — Retour (45 s). La structure ne change pas d'une séance à l'autre."
            )
            principleRow(
                title: "Pour qui",
                detail: "Pratiquants qui savent déjà méditer et veulent un cadre stable, reproductible, sans distraction."
            )
            principleRow(
                title: "Philosophie",
                detail: "Siturem tient le cadre et s'efface. Pas de narration, pas de score, pas de gamification. L'app réduit la friction et disparaît."
            )
            principleRow(
                title: "Durée minimale",
                detail: "6 minutes (intro + méditation courte + retour). Durée par défaut : 10 minutes."
            )
        } header: {
            sectionHeader("PRINCIPES")
        }
        .listRowBackground(Theme.surface)
    }

    private func principleRow(title: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(.subheadline))
                .foregroundStyle(Theme.textPrimary)
            Text(detail)
                .font(.system(.caption))
                .foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 2)
    }

    // MARK: - Séance

    private var sessionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("Rappels pendant la méditation")
                    .font(.system(.subheadline))
                    .foregroundStyle(Theme.textPrimary)
                Picker("", selection: $prefs.reminder) {
                    ForEach(ReminderInterval.allCases) { interval in
                        Text(interval.settingsLabel).tag(interval)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(.vertical, 4)
        } header: {
            sectionHeader("SÉANCE")
        } footer: {
            Text("Définit la fréquence des rappels vocaux pendant la phase de méditation en mode guidé.")
                .foregroundStyle(Theme.textSecondary)
        }
        .listRowBackground(Theme.surface)
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
