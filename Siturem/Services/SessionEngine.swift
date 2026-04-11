import Foundation
import Combine

// MARK: - Session Engine
// Gère le déroulé d'une séance : phases, timer, état.

@Observable
final class SessionEngine: Identifiable {

    let id = UUID()

    // MARK: - Published state
    var state: SessionState = .ready
    var currentPhase: SessionPhase = .intro
    var elapsed: Int = 0          // secondes écoulées dans la phase courante
    var totalElapsed: Int = 0     // secondes écoulées au total

    // MARK: - Config
    private(set) var config: SessionConfiguration

    // MARK: - Private
    private var timer: Timer?
    private var phaseStartTime: Int = 0

    // MARK: - Callbacks (pour déclencher gong, audio, etc.)
    var onPhaseChange: ((SessionPhase) -> Void)?
    var onSessionEnd: (() -> Void)?

    // MARK: - Init

    init(config: SessionConfiguration) {
        self.config = config
    }

    // MARK: - Computed

    var currentPhaseDuration: Int {
        switch currentPhase {
        case .intro:       SessionConfiguration.introDuration
        case .meditation:  config.meditationDuration
        case .closing:     SessionConfiguration.closingDuration
        }
    }

    var phaseElapsed: Int { elapsed }

    var phaseRemaining: Int {
        max(0, currentPhaseDuration - elapsed)
    }

    var totalRemaining: Int {
        max(0, config.totalDuration - totalElapsed)
    }

    // MARK: - Controls

    func start() {
        guard state == .ready || state == .paused else { return }
        state = .running
        startTimer()
    }

    func pause() {
        guard state == .running else { return }
        state = .paused
        stopTimer()
    }

    func stop() {
        stopTimer()
        state = .cancelled
    }

    func finish() {
        stopTimer()
        state = .finished
        onSessionEnd?()
    }

    // MARK: - Timer

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard state == .running else { return }
        elapsed += 1
        totalElapsed += 1

        if elapsed >= currentPhaseDuration {
            advancePhase()
        }
    }

    private func advancePhase() {
        switch currentPhase {
        case .intro:
            currentPhase = .meditation
            elapsed = 0
            onPhaseChange?(.meditation)
        case .meditation:
            currentPhase = .closing
            elapsed = 0
            onPhaseChange?(.closing)
        case .closing:
            finish()
        }
    }
}
