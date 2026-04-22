import SwiftUI

// MARK: - Home View
// Écran principal : configuration de séance et lancement.

struct HomeView: View {

    private enum FrameEditFeedback {
        case applied
        case alreadyVisible

        var message: LocalizedStringResource {
            switch self {
            case .applied:
                "Cadre chargé dans les réglages"
            case .alreadyVisible:
                "Cadre déjà chargé dans les réglages"
            }
        }
    }

    @Bindable var prefs: PreferencesStore
    @Bindable var frameStore: PracticeFrameStore
    let onStart: (SessionConfiguration) -> Void
    @Environment(\.locale) private var locale

    @State private var selectedMinutes: Int = 10
    @State private var showDurationError: Bool = false
    @State private var frameEditFeedback: FrameEditFeedback?

    private var selectedDuration: Int { selectedMinutes * 60 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutMetrics.md) {
                    sessionSection
                    signalsSection
                }
                .padding(.horizontal, LayoutMetrics.hPadding)
                .padding(.top, LayoutMetrics.sm)
                .padding(.bottom, LayoutMetrics.md)
            }
            .background(Theme.background)
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
                migrateFramesIfNeeded()
                let minutes = prefs.totalDuration / 60
                selectedMinutes = max(6, min(60, minutes))
            }
            .onChange(of: selectedMinutes) { _, v in
                prefs.totalDuration = v * 60
            }
        }
    }

    private var lastUsedFrame: PracticeFrame? {
        frameStore.lastUsedFrame
    }

    // MARK: - Séance

    private var sessionSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            primarySectionLabel("Séance")

            if let lastUsedFrame {
                lastFrameCard(lastUsedFrame)
            }

            durationCard
        }
    }

    private func lastFrameCard(_ frame: PracticeFrame) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DERNIER CADRE")

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(displayName(for: frame))
                        .font(.system(.title3, design: .rounded, weight: .light))
                        .foregroundStyle(Theme.textPrimary)

                    if frame.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Theme.accent)
                            .accessibilityLabel("Cadre favori")
                    }

                    Spacer()
                }

                HStack(spacing: 8) {
                    durationDetailPill(minutes: frame.duration / 60)
                    detailPill(frame.accompaniment.displayLabel)
                }

                VStack(alignment: .leading, spacing: 6) {
                    detailRow("Gong", value: frame.gong.displayLabel)

                    if frame.ambient != .off {
                        detailRow("Ambiance", value: frame.ambient.displayLabel)
                    }

                    if frame.reminder != .off {
                        detailRow("Rappels", value: frame.reminder.homeLabel)
                    }
                }

                Button("Charger") {
                    apply(frame: frame)
                }
                .buttonStyle(.bordered)
                .tint(Theme.textSecondary)

                if let frameEditFeedback {
                    Text(frameEditFeedback.message)
                        .font(.system(.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .transition(.opacity)
                }
            }
            .padding(LayoutMetrics.md)
            .background(Theme.surfaceHigh)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Signaux

    private var durationCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DURÉE")

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: LayoutMetrics.md) {
                    Text("\(selectedMinutes)")
                        .font(.system(size: 52, weight: .ultraLight, design: .monospaced))
                        .foregroundStyle(Theme.textPrimary)
                        + Text(verbatim: " \(minuteAbbreviation)")
                        .font(.system(size: 20, weight: .light, design: .monospaced))
                        .foregroundStyle(Theme.textSecondary)

                    Spacer()

                    Picker("Durée", selection: $selectedMinutes) {
                        ForEach(6...60, id: \.self) { m in
                            Text(verbatim: durationLabel(minutes: m))
                                .font(.system(.body, design: .monospaced))
                                .tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 110, height: 110)
                    .clipped()
                }

                startButton
            }
            .padding(.horizontal, LayoutMetrics.sm)
            .padding(.vertical, LayoutMetrics.md)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var signalsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionLabel("SIGNAUX")
            VStack(spacing: 1) {
                optionRow("Accompagnement") {
                    Picker("", selection: $prefs.accompaniment) {
                        ForEach(AccompanimentMode.allCases) { m in Text(m.displayLabel).tag(m) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
                optionRow("Gong") {
                    Picker("", selection: $prefs.gong) {
                        ForEach(GongMode.allCases) { g in Text(g.displayLabel).tag(g) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
                optionRow("Ambiance") {
                    Picker("", selection: $prefs.ambient) {
                        ForEach(AmbientSound.allCases) { s in Text(s.displayLabel).tag(s) }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                    .tint(Theme.textSecondary)
                }
            }
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Actions

    @ViewBuilder
    private func optionRow<Content: View>(_ label: LocalizedStringResource, isLast: Bool = false, @ViewBuilder content: () -> Content) -> some View {
        HStack {
            Text(label)
                .font(.system(.subheadline))
                .foregroundStyle(Theme.textPrimary)
            Spacer()
            content()
        }
        .padding(.horizontal, LayoutMetrics.sm)
        .padding(.vertical, LayoutMetrics.sm)
        .overlay(alignment: .bottom) {
            if !isLast {
                Theme.surfaceHigh.frame(height: 0.5)
            }
        }
    }

    private var startButton: some View {
        Button {
            start(config: currentSessionConfiguration)
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

    private func sectionLabel(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .tracking(2)
    }

    private func primarySectionLabel(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.system(.title3, design: .rounded, weight: .light))
            .foregroundStyle(Theme.textPrimary)
    }

    private func detailPill(_ label: LocalizedStringResource) -> some View {
        Text(label)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.surfaceHigh)
            .clipShape(Capsule())
    }

    private func durationDetailPill(minutes: Int) -> some View {
        Text(verbatim: durationLabel(minutes: minutes))
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.surfaceHigh)
            .clipShape(Capsule())
    }

    private func detailRow(_ title: LocalizedStringResource, value: LocalizedStringResource) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)

            Spacer()

            Text(value)
                .font(.system(.caption))
                .foregroundStyle(Theme.textPrimary)
        }
    }

    private var currentSessionConfiguration: SessionConfiguration {
        SessionConfiguration(
            totalDuration: selectedDuration,
            accompaniment: prefs.accompaniment,
            gong: prefs.gong,
            ambient: prefs.ambient,
            reminder: prefs.reminder,
            audioLocale: prefs.audioLocale
        )
    }

    private func migrateFramesIfNeeded() {
        frameStore.migratePreferencesIfNeeded(
            from: prefs,
            frameName: seededFrameName
        )
    }

    private func apply(frame: PracticeFrame) {
        let isAlreadyVisible = selectedDuration == frame.duration
            && prefs.accompaniment == frame.accompaniment
            && prefs.gong == frame.gong
            && prefs.ambient == frame.ambient

        prefs.totalDuration = frame.duration
        prefs.accompaniment = frame.accompaniment
        prefs.gong = frame.gong
        prefs.ambient = frame.ambient
        prefs.reminder = frame.reminder
        selectedMinutes = max(6, min(60, frame.duration / 60))

        showFrameEditFeedback(isAlreadyVisible ? .alreadyVisible : .applied)
    }

    private func start(frame: PracticeFrame) {
        frameStore.markLastUsed(frameID: frame.id)
        start(config: frame.sessionConfiguration(audioLocale: prefs.audioLocale))
    }

    private func start(config: SessionConfiguration) {
        guard config.isValid else {
            showDurationError = true
            return
        }

        onStart(config)
    }

    private var seededFrameName: String {
        switch prefs.uiLanguage {
        case .fr:
            "Cadre habituel"
        case .enUS:
            "Usual frame"
        case .es:
            "Marco habitual"
        case .de:
            "Üblicher Rahmen"
        }
    }

    private func displayName(for frame: PracticeFrame) -> String {
        seededFrameAliases.contains(frame.name) ? seededFrameName : frame.name
    }

    private var seededFrameAliases: Set<String> {
        [
            "Cadre habituel",
            "Usual frame",
            "Marco habitual",
            "Ueblicher Rahmen",
            "Üblicher Rahmen"
        ]
    }

    private func showFrameEditFeedback(_ feedback: FrameEditFeedback) {
        withAnimation(.easeOut(duration: 0.18)) {
            frameEditFeedback = feedback
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            guard frameEditFeedback == feedback else { return }

            withAnimation(.easeOut(duration: 0.18)) {
                frameEditFeedback = nil
            }
        }
    }

    private func durationLabel(minutes: Int) -> String {
        "\(minutes) \(minuteAbbreviation)"
    }

    private var minuteAbbreviation: String {
        locale.identifier.hasPrefix("de") ? "Min." : "min"
    }
}
