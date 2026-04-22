import SwiftUI

// MARK: - Session View
// Écran affiché pendant une séance en cours.
// Mise en page basée sur le nombre d'or (φ ≈ 1.618).
// Barre + contrôles ancrés via safeAreaInset — blob centre l'espace restant.

struct SessionView: View {

    @Bindable var engine: SessionEngine
    let stats: StatsStore
    @Bindable var prefs: PreferencesStore
    let onRestart: (SessionConfiguration) -> Void
    let onEnd: () -> Void

    private let healthKit = HealthKitService()
    private let haptics = HapticsService()

    @State private var audioService: AudioService?
    @State private var showEndConfirmation = false
    @State private var showSummary = false
    @State private var sessionStartDate: Date?
    @State private var shouldResumeAfterStopConfirmation = false

    var body: some View {
        Group {
            if showSummary {
                SessionSummaryView(
                    duration: engine.totalElapsed,
                    todayTotal: stats.secondsToday,
                    onRestart: { onRestart(engine.config) },
                    onDone: onEnd
                )
            } else {
                sessionRunningView
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            let audio = AudioService(config: engine.config)
            audioService = audio
            haptics.prepareForSession()
            if sessionStartDate == nil {
                sessionStartDate = Date()
            }
            engine.onSessionEnd = {
                audio.handleSessionEnd(configuration: engine.config)
                handleEnd()
            }

            audio.startSessionAudio(configuration: engine.config)
            engine.start()
        }
        .onChange(of: engine.elapsed) { oldValue, newValue in
            audioService?.handleTick(
                phase: engine.currentPhase,
                previousElapsedInPhase: TimeInterval(oldValue),
                currentElapsedInPhase: TimeInterval(newValue),
                configuration: engine.config
            )
        }
        .onChange(of: engine.currentPhase) { oldValue, newValue in
            audioService?.handlePhaseChange(
                from: oldValue,
                to: newValue,
                configuration: engine.config
            )
            playPhaseTransitionHaptic(from: oldValue, to: newValue)
        }
        .onDisappear {
            audioService?.stopAll()
            audioService = nil
            engine.onSessionEnd = nil
            shouldResumeAfterStopConfirmation = false
        }
    }

    // MARK: - Running

    private var sessionRunningView: some View {
        VStack(spacing: 0) {
            // Label de phase — ancré en haut
            phaseLabel
                .padding(.top, LayoutMetrics.phaseTopOffset)
                .frame(maxWidth: .infinity)

            // Blob — centre l'espace restant au-dessus du safeAreaInset
            BlobView(phase: engine.currentPhase)
                .padding(.top, LayoutMetrics.blobVerticalOffset)
                .padding(.horizontal, LayoutMetrics.blobPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        // Barre + contrôles ancrés au bas de l'écran, juste au-dessus du home indicator
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: LayoutMetrics.progressToControlsSpacing) {
                if prefs.showsSessionProgress {
                    progressBar
                }
                controls
            }
            .padding(.horizontal, LayoutMetrics.hPadding)
            .padding(.top, LayoutMetrics.sessionBottomStackTopPadding)
            .padding(.bottom, LayoutMetrics.sessionBottomStackBottomPadding)
            .background(Theme.background)
        }
        .alert("Arrêter la séance ?", isPresented: $showEndConfirmation) {
            Button("Arrêter", role: .destructive) {
                stopSession()
            }
            Button("Continuer", role: .cancel) {
                cancelStopConfirmation()
            }
        }
    }

    // MARK: - Phase label

    private var phaseLabel: some View {
        Text(engine.currentPhase.displayLabel)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
            .textCase(.uppercase)
            .tracking(2)
    }

    // MARK: - Progression globale

    private var progressBar: some View {
        GeometryReader { geo in
            let barWidth = min(geo.size.width * LayoutMetrics.progressBarWidthFactor, LayoutMetrics.progressBarMaxWidth)

            HStack {
                Spacer(minLength: 0)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Theme.surface)
                        .frame(width: barWidth, height: 6)
                    Capsule()
                        .fill(Theme.accent.opacity(0.80))
                        .frame(width: max(0, barWidth * globalProgress), height: 6)
                        .animation(.linear(duration: 1), value: globalProgress)
                }
                .frame(width: barWidth, height: 6)

                Spacer(minLength: 0)
            }
        }
        .frame(height: 6)
        .offset(y: LayoutMetrics.lg * 0.34)
    }

    private var globalProgress: Double {
        let total = engine.config.totalDuration
        guard total > 0 else { return 0 }
        return min(1.0, Double(engine.totalElapsed) / Double(total))
    }

    // MARK: - Contrôles

    private var controls: some View {
        HStack(spacing: LayoutMetrics.lg * 0.88) {
            Button {
                requestStopConfirmation()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary)
            }

            Button {
                togglePauseResume()
            } label: {
                Image(systemName: engine.state == .running ? "pause" : "play.fill")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundStyle(Theme.textPrimary)
            }

            Color.clear.frame(width: 28)
        }
    }

    // MARK: - Fin de séance

    private func playPhaseTransitionHaptic(from oldPhase: SessionPhase, to newPhase: SessionPhase) {
        guard prefs.enableTransitionHaptics else { return }
        haptics.handlePhaseTransition(from: oldPhase, to: newPhase)
    }

    private func requestStopConfirmation() {
        guard !showSummary else { return }
        guard !showEndConfirmation else { return }

        if engine.state == .running {
            engine.pause()
            audioService?.pauseAll()
            shouldResumeAfterStopConfirmation = true
        } else {
            shouldResumeAfterStopConfirmation = false
        }

        showEndConfirmation = true
    }

    private func cancelStopConfirmation() {
        guard shouldResumeAfterStopConfirmation else { return }
        shouldResumeAfterStopConfirmation = false
        audioService?.resumeAll()
        engine.start()
    }

    private func stopSession() {
        shouldResumeAfterStopConfirmation = false
        audioService?.stopAll()
        engine.stop()
        onEnd()
    }

    private func togglePauseResume() {
        guard !showEndConfirmation else { return }
        guard !showSummary else { return }

        switch engine.state {
        case .running:
            engine.pause()
            audioService?.pauseAll()
        case .paused:
            audioService?.resumeAll()
            engine.start()
        default:
            break
        }
    }

    private func handleEnd() {
        showEndConfirmation = false
        shouldResumeAfterStopConfirmation = false

        let endDate = Date()
        let startDate = sessionStartDate ?? endDate.addingTimeInterval(-TimeInterval(engine.totalElapsed))
        let record = SessionRecord(
            date: endDate,
            plannedDuration: engine.config.totalDuration,
            actualDuration: engine.totalElapsed,
            accompaniment: engine.config.accompaniment,
            isComplete: true
        )
        stats.save(record)
        withAnimation { showSummary = true }

        let isSyncEnabled = prefs.healthKitEnabled
        Task {
            _ = await healthKit.saveCompletedSession(
                startDate: startDate,
                endDate: endDate,
                isSyncEnabled: isSyncEnabled
            )
        }
    }
}
