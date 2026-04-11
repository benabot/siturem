import SwiftUI

// MARK: - Session View
// Écran affiché pendant une séance en cours.

struct SessionView: View {

    @Bindable var engine: SessionEngine
    let stats: StatsStore
    let onEnd: () -> Void

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
            engine.onSessionEnd = handleEnd
            engine.start()
        }
    }

    // MARK: - Running

    private var sessionRunningView: some View {
        VStack(spacing: 0) {
            phaseLabel
                .padding(.top, 56)
                .padding(.bottom, 8)

            Spacer()

            BlobView(phase: engine.currentPhase)

            Spacer()

            progressBar
                .padding(.bottom, 32)

            controls
                .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.background)
        .alert("Arrêter la séance ?", isPresented: $showEndConfirmation) {
            Button("Arrêter", role: .destructive) {
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

    // MARK: - Progression globale (séance entière)

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Theme.surface)
                    .frame(height: 3)
                Capsule()
                    .fill(Theme.accent.opacity(0.75))
                    .frame(width: max(0, geo.size.width * globalProgress), height: 3)
                    .animation(.linear(duration: 1), value: globalProgress)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 40)
    }

    private var globalProgress: Double {
        let total = engine.config.totalDuration
        guard total > 0 else { return 0 }
        return min(1.0, Double(engine.totalElapsed) / Double(total))
    }

    // MARK: - Contrôles

    private var controls: some View {
        HStack(spacing: 56) {
            Button {
                showEndConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary)
            }

            Button {
                if engine.state == .running { engine.pause() }
                else { engine.start() }
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
