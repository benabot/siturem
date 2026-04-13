import Foundation

// MARK: - Preferences Store
// Persistance des préférences utilisateur via UserDefaults.

@Observable
final class PreferencesStore {

    static let defaultAudioLocale: AudioLocale = .fallback

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
    var audioLocale: AudioLocale {
        didSet { defaults.set(audioLocale.rawValue, forKey: "pref.audioLocale") }
    }
    var healthKitEnabled: Bool {
        didSet { defaults.set(healthKitEnabled, forKey: "pref.healthKit") }
    }

    init() {
        let d = UserDefaults.standard
        totalDuration = d.object(forKey: "pref.totalDuration") as? Int ?? 600
        accompaniment = PreferencesStore.resolveAccompanimentMode(from: d.string(forKey: "pref.accompaniment"))
        gong = PreferencesStore.resolveGongMode(from: d.string(forKey: "pref.gong")) ?? .sessionBounds
        ambient = AmbientSound(rawValue: d.string(forKey: "pref.ambient") ?? "") ?? .off
        reminder = ReminderInterval(rawValue: d.string(forKey: "pref.reminder") ?? "") ?? .off
        audioLocale = PreferencesStore.resolveAudioLocale(from: d.string(forKey: "pref.audioLocale"))
        healthKitEnabled = d.bool(forKey: "pref.healthKit")
    }

    var sessionConfiguration: SessionConfiguration {
        SessionConfiguration(
            totalDuration: totalDuration,
            accompaniment: accompaniment,
            gong: gong,
            ambient: ambient,
            reminder: reminder,
            audioLocale: audioLocale
        )
    }

    private static func resolveGongMode(from rawValue: String?) -> GongMode? {
        guard let rawValue else { return nil }

        if let mode = GongMode(rawValue: rawValue) {
            return mode
        }

        switch rawValue {
        case "Début / Transitions / Fin":
            return .sessionBounds
        default:
            return nil
        }
    }

    private static func resolveAccompanimentMode(from rawValue: String?) -> AccompanimentMode {
        guard let rawValue else { return .guided }

        if let mode = AccompanimentMode(rawValue: rawValue) {
            return mode
        }

        switch rawValue {
        case "Structuré", "Guidé léger":
            return .guided
        default:
            return .guided
        }
    }

    private static func resolveAudioLocale(from rawValue: String?) -> AudioLocale {
        guard let rawValue, let locale = AudioLocale(rawValue: rawValue) else {
            return defaultAudioLocale
        }

        return locale
    }
}
