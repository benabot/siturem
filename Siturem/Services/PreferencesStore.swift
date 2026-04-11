import Foundation

// MARK: - Preferences Store
// Persistance des préférences utilisateur via UserDefaults.

@Observable
final class PreferencesStore {

    private let defaults = UserDefaults.standard

    var totalDuration: Int {
        didSet { defaults.set(totalDuration, forKey: "pref.totalDuration") }
    }
    var accompaniment: AccompanimentMode {
        didSet { defaults.set(accompaniment.rawValue, forKey: "pref.accompaniment") }
    }
    var gong: GongMode {
        didSet { defaults.set(gong.rawValue, forKey: "pref.gong") }
    }
    var ambient: AmbientSound {
        didSet { defaults.set(ambient.rawValue, forKey: "pref.ambient") }
    }
    var reminder: ReminderInterval {
        didSet { defaults.set(reminder.rawValue, forKey: "pref.reminder") }
    }
    var healthKitEnabled: Bool {
        didSet { defaults.set(healthKitEnabled, forKey: "pref.healthKit") }
    }

    init() {
        let d = UserDefaults.standard
        totalDuration = d.object(forKey: "pref.totalDuration") as? Int ?? 600
        accompaniment = AccompanimentMode(rawValue: d.string(forKey: "pref.accompaniment") ?? "") ?? .structured
        gong = GongMode(rawValue: d.string(forKey: "pref.gong") ?? "") ?? .startEnd
        ambient = AmbientSound(rawValue: d.string(forKey: "pref.ambient") ?? "") ?? .off
        reminder = ReminderInterval(rawValue: d.string(forKey: "pref.reminder") ?? "") ?? .off
        healthKitEnabled = d.bool(forKey: "pref.healthKit")
    }

    var sessionConfiguration: SessionConfiguration {
        SessionConfiguration(
            totalDuration: totalDuration,
            accompaniment: accompaniment,
            gong: gong,
            ambient: ambient,
            reminder: reminder
        )
    }
}
