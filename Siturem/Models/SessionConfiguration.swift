import Foundation

// MARK: - Session Configuration

struct SessionConfiguration {
    var totalDuration: Int          // secondes
    var accompaniment: AccompanimentMode
    var gong: GongMode
    var ambient: AmbientSound
    var reminder: ReminderInterval

    // Phases fixes (cahier des charges §5)
    static let introDuration: Int = 150    // 2 min 30
    static let closingDuration: Int = 45   // 45 s
    static let minimumDuration: Int = 360  // 6 min

    var meditationDuration: Int {
        totalDuration - SessionConfiguration.introDuration - SessionConfiguration.closingDuration
    }

    var isValid: Bool {
        totalDuration >= SessionConfiguration.minimumDuration
    }

    static var `default`: SessionConfiguration {
        SessionConfiguration(
            totalDuration: 600, // 10 min
            accompaniment: .structured,
            gong: .startEnd,
            ambient: .off,
            reminder: .off
        )
    }
}
