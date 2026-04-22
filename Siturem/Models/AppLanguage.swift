import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case fr = "fr"
    case enUS = "en-US"
    case es = "es"
    case de = "de"

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: rawValue)
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .fr:
            "Français"
        case .enUS:
            "en"
        case .es:
            "Español"
        case .de:
            "Deutsch"
        }
    }

    static func resolveSystemLanguage() -> AppLanguage {
        let preferredLanguages = UserDefaults.standard.stringArray(forKey: "AppleLanguages") ?? Locale.preferredLanguages
        return resolveSystemLanguage(preferredLanguages: preferredLanguages)
    }

    static func resolveSystemLanguage(preferredLanguages: [String]) -> AppLanguage {
        for identifier in preferredLanguages {
            if let language = supportedLanguage(matching: identifier) {
                return language
            }
        }

        return .enUS
    }

    private static func supportedLanguage(matching identifier: String) -> AppLanguage? {
        if let language = AppLanguage(rawValue: identifier) {
            return language
        }

        let locale = Locale(identifier: identifier)
        switch locale.language.languageCode?.identifier {
        case "fr":
            return .fr
        case "en":
            return .enUS
        case "es":
            return .es
        case "de":
            return .de
        default:
            return nil
        }
    }
}

enum AppLanguageSelection: String, CaseIterable, Identifiable {
    case system
    case fr
    case enUS
    case es
    case de

    var id: String { rawValue }

    init(languageOverride: AppLanguage?) {
        switch languageOverride {
        case .fr:
            self = .fr
        case .enUS:
            self = .enUS
        case .es:
            self = .es
        case .de:
            self = .de
        case nil:
            self = .system
        }
    }

    var languageOverride: AppLanguage? {
        switch self {
        case .system:
            nil
        case .fr:
            .fr
        case .enUS:
            .enUS
        case .es:
            .es
        case .de:
            .de
        }
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .system:
            "Système"
        case .fr:
            "Français"
        case .enUS:
            "en"
        case .es:
            "Español"
        case .de:
            "Deutsch"
        }
    }
}
