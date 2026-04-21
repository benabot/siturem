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
    var uiLanguageOverride: AppLanguage? {
        didSet {
            if let uiLanguageOverride {
                defaults.set(uiLanguageOverride.rawValue, forKey: "pref.uiLanguage")
            } else {
                defaults.removeObject(forKey: "pref.uiLanguage")
            }
        }
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
        reminder = PreferencesStore.resolveReminderInterval(from: d.string(forKey: "pref.reminder")) ?? .off
        uiLanguageOverride = PreferencesStore.resolveUILanguageOverride(from: d.string(forKey: "pref.uiLanguage"))
        healthKitEnabled = d.bool(forKey: "pref.healthKit")

        // Legacy key kept from the earlier UI/audio split. Audio now follows the active UI language.
        d.removeObject(forKey: "pref.audioLocale")
    }

    var uiLanguage: AppLanguage {
        uiLanguageOverride ?? AppLanguage.resolveSystemLanguage()
    }

    var audioLocale: AudioLocale {
        AudioLocale.resolved(for: uiLanguage)
    }

    var uiLanguageSelection: AppLanguageSelection {
        get { AppLanguageSelection(languageOverride: uiLanguageOverride) }
        set { uiLanguageOverride = newValue.languageOverride }
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

    /// Snapshot du V1 courant sous forme de cadre nommé, sans changer la source de vérité.
    func makePracticeFrame(name: String, isFavorite: Bool = false) -> PracticeFrame {
        PracticeFrame(
            name: name,
            sessionConfiguration: sessionConfiguration,
            isFavorite: isFavorite
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

    private static func resolveUILanguageOverride(from rawValue: String?) -> AppLanguage? {
        guard let rawValue else { return nil }
        return AppLanguage(rawValue: rawValue)
    }

    private static func resolveReminderInterval(from rawValue: String?) -> ReminderInterval? {
        guard let rawValue else { return nil }

        if let interval = ReminderInterval(rawValue: rawValue) {
            return interval
        }

        switch rawValue {
        case "Toutes les 3 min":
            return .every90sec
        case "Toutes les 5 min":
            return .every150sec
        default:
            return nil
        }
    }
}
