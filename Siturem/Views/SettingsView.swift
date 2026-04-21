import SwiftUI

// MARK: - Settings View
// Préférences système : HealthKit, interface, accessibilité, informations.
// La configuration de séance (accompagnement, gong, ambiance, rappels) est dans HomeView.

struct SettingsView: View {

    @Bindable var prefs: PreferencesStore
    @Environment(\.scenePhase) private var scenePhase

    private let healthKit = HealthKitService()

    @State private var healthAuthorizationStatus: HealthKitAuthorizationState = .unavailable

    var body: some View {
        NavigationStack {
            Form {
                principlesSection
                languageSection
                sessionSection
                healthSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .navigationTitle("Réglages")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear {
                refreshHealthAuthorizationStatus()
            }
            .onChange(of: scenePhase) { _, newValue in
                guard newValue == .active else { return }
                refreshHealthAuthorizationStatus()
            }
        }
    }

    // MARK: - Principes

    private var principlesSection: some View {
        Section {
            principleRow(
                title: "Trois phases fixes",
                detail: "Introduction (2 min 30) — Méditation (durée choisie) — Retour (1 min 32). La structure ne change pas d'une séance à l'autre."
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

    private var languageSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                Text("Langue de l'interface")
                    .font(.system(.subheadline))
                    .foregroundStyle(Theme.textPrimary)

                Picker("", selection: uiLanguageSelection) {
                    ForEach(AppLanguageSelection.allCases) { selection in
                        Text(selection.displayName).tag(selection)
                    }
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .tint(Theme.textSecondary)
            }
            .padding(.vertical, 4)
        } header: {
            sectionHeader("LANGUE")
        } footer: {
            Text("Par défaut, l'interface suit la langue du système si elle est prise en charge, sinon l'anglais. La langue de l'interface reste distincte de la langue audio.")
                .foregroundStyle(Theme.textSecondary)
        }
        .listRowBackground(Theme.surface)
    }

    private func principleRow(title: LocalizedStringResource, detail: LocalizedStringResource) -> some View {
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

            LabeledContent("État d'accès") {
                Text(healthAuthorizationStatusLabel)
                    .foregroundStyle(Theme.textSecondary)
            }

            if !healthKit.isAvailable {
                Text("HealthKit n'est pas disponible sur cet appareil.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            } else if prefs.healthKitEnabled {
                if healthAuthorizationStatus == .notDetermined {
                    Button("Autoriser l'accès à Santé") {
                        Task {
                            healthAuthorizationStatus = await healthKit.requestAuthorizationIfNeeded()
                        }
                    }
                    .foregroundStyle(Theme.textSecondary)
                }

                Text(healthAuthorizationStatusDetail)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                Text("Activez la synchronisation pour autoriser l'écriture des séances terminées dans Santé.")
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } header: {
            sectionHeader("SANTÉ")
        } footer: {
            Text("Seules les séances terminées normalement sont candidates à la synchronisation.")
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
                Text(appVersionDisplay)
                    .foregroundStyle(Theme.textSecondary)
            }
        } header: {
            sectionHeader("À PROPOS")
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .tracking(2)
    }

    private var uiLanguageSelection: Binding<AppLanguageSelection> {
        Binding(
            get: { prefs.uiLanguageSelection },
            set: { prefs.uiLanguageSelection = $0 }
        )
    }

    private var appVersionDisplay: String {
        let marketingVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        if let marketingVersion, let buildVersion, !buildVersion.isEmpty {
            return "\(marketingVersion) (\(buildVersion))"
        }

        return marketingVersion ?? "-"
    }

    private var healthAuthorizationStatusLabel: LocalizedStringResource {
        switch healthAuthorizationStatus {
        case .unavailable:
            "Indisponible"
        case .notDetermined:
            "Non demandé"
        case .authorized:
            "Autorisé"
        case .denied:
            "Refusé"
        }
    }

    private var healthAuthorizationStatusDetail: LocalizedStringResource {
        switch healthAuthorizationStatus {
        case .unavailable:
            "HealthKit n'est pas disponible sur cet appareil."
        case .notDetermined:
            "L'autorisation est requise pour écrire les séances terminées normalement dans Santé."
        case .authorized:
            "Les séances terminées normalement peuvent être enregistrées dans l'app Santé."
        case .denied:
            "L'accès à Santé a été refusé. Vous pouvez le modifier depuis l'app Santé."
        }
    }

    private func refreshHealthAuthorizationStatus() {
        healthAuthorizationStatus = healthKit.authorizationStatus
    }
}
