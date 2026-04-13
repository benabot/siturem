import SwiftUI

// MARK: - Session View
// Écran affiché pendant une séance en cours.
// Mise en page basée sur le nombre d'or (φ ≈ 1.618).
// Barre + contrôles ancrés via safeAreaInset — blob centre l'espace restant.

struct SessionView: View {

    @Bindable var engine: SessionEngine
    let stats: StatsStore
    let onEnd: () -> Void

    @State private var audioService: AudioService?
    @State private var showEndConfirmation = false
    @State private var showSummary = false

    var body: some View {
        Group {
            if showSummary {
                SessionSummaryView(
                    duration: engine.totalElapsed,
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
        }
        .onDisappear {
            audioService?.stopAll()
            audioService = nil
            engine.onSessionEnd = nil
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
                progressBar
                controls
            }
            .padding(.horizontal, LayoutMetrics.hPadding)
            .padding(.top, LayoutMetrics.sessionBottomStackTopPadding)
            .padding(.bottom, LayoutMetrics.sessionBottomStackBottomPadding)
            .background(Theme.background)
        }
        .alert("Arrêter la séance ?", isPresented: $showEndConfirmation) {
            Button("Arrêter", role: .destructive) {
                audioService?.stopAll()
                engine.stop()
                onEnd()
            }
            Button("Continuer", role: .cancel) {}
        }
    }

    // MARK: - Phase label

    private var phaseLabel: some View {
        Text(engine.currentPhase.label.uppercased())
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(Theme.textSecondary)
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
        .offset(y: LayoutMetrics.progressBarYOffset)
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
                showEndConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary)
            }

            Button {
                if engine.state == .running {
                    engine.pause()
                    audioService?.pauseAll()
                } else if engine.state == .paused {
                    audioService?.resumeAll()
                    engine.start()
                }
            } label: {
                Image(systemName: engine.state == .running ? "pause" : "play.fill")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundStyle(Theme.textPrimary)
            }

            Color.clear.frame(width: 28)
        }
    }

    // MARK: - Fin de séance

    private func handleEnd() {
        let record = SessionRecord(
            plannedDuration: engine.config.totalDuration,
            actualDuration: engine.totalElapsed,
            accompaniment: engine.config.accompaniment,
            isComplete: true
        )
        stats.save(record)
        withAnimation { showSummary = true }
    }
}
