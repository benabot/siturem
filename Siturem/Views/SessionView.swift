import SwiftUI

// MARK: - Session View
// Écran affiché pendant une séance en cours.

struct SessionView: View {

    @Bindable var engine: SessionEngine
    let stats: StatsStore
    let onEnd: () -> Void

    @State private var sessionStartDate = Date()
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
            sessionStartDate = Date()
            engine.onSessionEnd = handleEnd
            engine.start()
        }
    }

    // MARK: - Running

    private var sessionRunningView: some View {
        VStack(spacing: 48) {
            Spacer()
            phaseLabel
            timerDisplay
            Spacer()
            controls
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .alert("Arrêter la séance ?", isPresented: $showEndConfirmation) {
            Button("Arrêter", role: .destructive) {
                engine.stop()
                onEnd()
            }
            Button("Continuer", role: .cancel) {}
        }
    }

    private var phaseLabel: some View {
        Text(engine.currentPhase.label.uppercased())
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
            .tracking(2)
    }

    private var timerDisplay: some View {
        VStack(spacing: 8) {
            Text(formatTime(engine.phaseRemaining))
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundStyle(.primary)
            Text(formatTime(engine.totalRemaining) + " total")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.tertiary)
        }
    }

    private var controls: some View {
        HStack(spacing: 40) {
            Button {
                showEndConfirmation = true
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }

            Button {
                if engine.state == .running { engine.pause() }
                else { engine.start() }
            } label: {
                Image(systemName: engine.state == .running ? "pause" : "play.fill")
                    .font(.system(size: 44, weight: .thin))
                    .foregroundStyle(.primary)
            }

            Color.clear.frame(width: 28)
        }
    }

    // MARK: - End

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

    private func formatTime(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}
