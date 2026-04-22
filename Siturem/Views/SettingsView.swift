import SwiftUI

// MARK: - Settings View
// Préférences durables : interface, rendu de séance, santé, informations.
// Les réglages de lancement rapide restent dans HomeView.

struct SettingsView: View {

    @Bindable var prefs: PreferencesStore
    @Environment(\.scenePhase) private var scenePhase

    private let healthKit = HealthKitService()
    private let privacyPolicyURL = URL(string: "https://beabot.fr/apps/siturem/#privacy")!

    @State private var healthAuthorizationStatus: HealthKitAuthorizationState = .unavailable

    var body: some View {
        NavigationStack {
            Form {
                interfaceSection
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

    private var interfaceSection: some View {
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
            sectionHeader("INTERFACE")
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - Séance

    private var sessionSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                Text("Rappels pendant la méditation")
                    .font(.system(.subheadline))
                    .foregroundStyle(Theme.textPrimary)
                Picker("", selection: $prefs.reminder) {
                    ForEach(ReminderInterval.allCases) { interval in
                        Text(interval.settingsLabel).tag(interval)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Afficher la progression", isOn: $prefs.showsSessionProgress)
                    .tint(Theme.accent)

                Toggle("Retours haptiques", isOn: $prefs.enableTransitionHaptics)
                    .tint(Theme.accent)
            }
            .padding(.vertical, 4)
        } header: {
            sectionHeader("SÉANCE")
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
                Text("Santé indisponible sur cet appareil.")
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

                if let healthAuthorizationStatusDetail {
                    Text(healthAuthorizationStatusDetail)
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        } header: {
            sectionHeader("SANTÉ")
        } footer: {
            Text("Séances terminées uniquement.")
                .foregroundStyle(Theme.textSecondary)
        }
        .listRowBackground(Theme.surface)
    }

    // MARK: - À propos

    private var aboutSection: some View {
        Section {
            Link(destination: privacyPolicyURL) {
                HStack {
                    Text("Politique de confidentialité")
                        .foregroundStyle(Theme.textPrimary)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.system(.footnote, weight: .medium))
                        .foregroundStyle(Theme.textSecondary)
                }
            }

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

    private var healthAuthorizationStatusDetail: LocalizedStringResource? {
        switch healthAuthorizationStatus {
        case .unavailable:
            "Santé indisponible sur cet appareil."
        case .notDetermined:
            "Autorisation requise."
        case .authorized:
            nil
        case .denied:
            "Accès refusé dans Santé."
        }
    }

    private func refreshHealthAuthorizationStatus() {
        healthAuthorizationStatus = healthKit.authorizationStatus
    }
}
