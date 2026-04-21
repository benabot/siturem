import Foundation

// MARK: - Preferences Store
// Persistance des préférences utilisateur via UserDefaults.

@Observable
final class PreferencesStore {

    private enum StorageKey {
        static let totalDuration = "pref.totalDuration"
        static let accompaniment = "pref.accompaniment"
        static let gong = "pref.gong"
        static let ambient = "pref.ambient"
        static let reminder = "pref.reminder"
        static let uiLanguage = "pref.uiLanguage"
        static let healthKit = "pref.healthKit"
        static let audioLocale = "pref.audioLocale"
    }

    private let defaults = UserDefaults.standard

    var totalDuration: Int {
        didSet { defaults.set(totalDuration, forKey: StorageKey.totalDuration) }
    }
    var accompaniment: AccompanimentMode {
        didSet { defaults.set(accompaniment.rawValue, forKey: StorageKey.accompaniment) }
    }
    var gong: GongMode {
        didSet { defaults.set(gong.rawValue, forKey: StorageKey.gong) }
    }
    var ambient: AmbientSound {
        didSet { defaults.set(ambient.rawValue, forKey: StorageKey.ambient) }
    }
    var reminder: ReminderInterval {
        didSet { defaults.set(reminder.rawValue, forKey: StorageKey.reminder) }
    }
    var uiLanguageOverride: AppLanguage? {
        didSet {
            if let uiLanguageOverride {
                defaults.set(uiLanguageOverride.rawValue, forKey: StorageKey.uiLanguage)
            } else {
                defaults.removeObject(forKey: StorageKey.uiLanguage)
            }
        }
    }
    var healthKitEnabled: Bool {
        didSet { defaults.set(healthKitEnabled, forKey: StorageKey.healthKit) }
    }

    init() {
        let d = UserDefaults.standard
        totalDuration = d.object(forKey: StorageKey.totalDuration) as? Int ?? 600
        accompaniment = PreferencesStore.resolveAccompanimentMode(from: d.string(forKey: StorageKey.accompaniment))
        gong = PreferencesStore.resolveGongMode(from: d.string(forKey: StorageKey.gong)) ?? .sessionBounds
        ambient = AmbientSound(rawValue: d.string(forKey: StorageKey.ambient) ?? "") ?? .off
        reminder = PreferencesStore.resolveReminderInterval(from: d.string(forKey: StorageKey.reminder)) ?? .off
        uiLanguageOverride = PreferencesStore.resolveUILanguageOverride(from: d.string(forKey: StorageKey.uiLanguage))
        healthKitEnabled = d.bool(forKey: StorageKey.healthKit)

        // Legacy key kept from the earlier UI/audio split. Audio now follows the active UI language.
        d.removeObject(forKey: StorageKey.audioLocale)
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

    /// Indique si l'utilisateur a déjà persisté au moins un réglage de séance V1.
    /// Ce signal sert au seed one-shot du premier cadre sans toucher aux préférences durables.
    var hasPersistedSessionPreferences: Bool {
        defaults.object(forKey: StorageKey.totalDuration) != nil
            || defaults.object(forKey: StorageKey.accompaniment) != nil
            || defaults.object(forKey: StorageKey.gong) != nil
            || defaults.object(forKey: StorageKey.ambient) != nil
            || defaults.object(forKey: StorageKey.reminder) != nil
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
