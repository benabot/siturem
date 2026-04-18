import UIKit

@MainActor
final class HapticsService {

    private let phaseTransitionGenerator = UIImpactFeedbackGenerator(style: .soft)

    func prepareForSession() {
        phaseTransitionGenerator.prepare()
    }

    func handlePhaseTransition(from oldPhase: SessionPhase, to newPhase: SessionPhase) {
        guard shouldPlayTransitionHaptic(from: oldPhase, to: newPhase) else { return }

        phaseTransitionGenerator.impactOccurred(intensity: 0.72)
        phaseTransitionGenerator.prepare()
    }

    private func shouldPlayTransitionHaptic(from oldPhase: SessionPhase, to newPhase: SessionPhase) -> Bool {
        switch (oldPhase, newPhase) {
        case (.intro, .meditation), (.meditation, .closing):
            true
        default:
            false
        }
    }
}
