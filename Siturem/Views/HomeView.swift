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

    @State private var selectedMinutes: Int = 10
    @State private var showDurationError: Bool = false
    @State private var frameEditFeedback: FrameEditFeedback?

    private var selectedDuration: Int { selectedMinutes * 60 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: LayoutMetrics.md) {
                    if let lastUsedFrame {
                        lastFrameSection(lastUsedFrame)
                    }
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

    // MARK: - Dernier cadre

    private func lastFrameSection(_ frame: PracticeFrame) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("DERNIER CADRE")

            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    Text(frame.name)
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
                    detailPill("\(frame.duration / 60) min")
                    detailPill(frame.accompaniment.displayLabel)
                }

                VStack(alignment: .leading, spacing: 6) {
                    detailRow("Gong", value: frame.gong.displayLabel)

                    if frame.ambient != .off {
                        detailRow("Ambiance", value: frame.ambient.displayLabel)
                    }

                    if frame.reminder != .off {
                        detailRow("Rappels", value: frame.reminder.settingsLabel)
                    }
                }

                HStack(spacing: 10) {
                    Button("Charger") {
                        apply(frame: frame)
                    }
                    .buttonStyle(.bordered)
                    .tint(Theme.textSecondary)

                    Button("Commencer") {
                        start(frame: frame)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Theme.accent)
                    .foregroundStyle(Theme.background)
                }

                if let frameEditFeedback {
                    Text(frameEditFeedback.message)
                        .font(.system(.caption))
                        .foregroundStyle(Theme.textSecondary)
                        .transition(.opacity)
                }
            }
            .padding(LayoutMetrics.md)
            .background(Theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
                optionRow("Ambiance", isLast: true) {
                    Picker("", selection: $prefs.ambient) {
                        ForEach(AmbientSound.allCases) { s in Text(s.displayLabel).tag(s) }
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
            start(config: SessionConfiguration(
                totalDuration: selectedDuration,
                accompaniment: prefs.accompaniment,
                gong: prefs.gong,
                ambient: prefs.ambient,
                reminder: prefs.reminder,
                audioLocale: prefs.audioLocale
            ))
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

    private func detailPill(_ label: LocalizedStringResource) -> some View {
        Text(label)
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
            "Ueblicher Rahmen"
        }
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
}
