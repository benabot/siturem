import Foundation

// MARK: - Session Duration

enum SessionDuration: Int, CaseIterable, Identifiable {
    case six = 6
    case ten = 10
    case fifteen = 15
    case twenty = 20
    case thirty = 30

    var id: Int { rawValue }

    var label: String {
        "\(rawValue) min"
    }

    var totalSeconds: Int {
        rawValue * 60
    }
}

// MARK: - Accompaniment Mode

enum AccompanimentMode: String, CaseIterable, Identifiable {
    case silent = "Silencieux"
    case structured = "Structuré"
    case lightGuided = "Guidé léger"

    var id: String { rawValue }
}

// MARK: - Gong Mode

enum GongMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case startEnd = "Début / Fin"
    case all = "Début / Transitions / Fin"

    var id: String { rawValue }
}

// MARK: - Ambient Sound

enum AmbientSound: String, CaseIterable, Identifiable {
    case off = "Off"
    case rain = "Pluie"
    case river = "Rivière"
    case forest = "Forêt"
    case whiteNoise = "Bruit blanc"

    var id: String { rawValue }
}

// MARK: - Reminder Interval

enum ReminderInterval: String, CaseIterable, Identifiable {
    case off = "Off"
    case every3min = "Toutes les 3 min"
    case every5min = "Toutes les 5 min"

    var id: String { rawValue }

    var seconds: Int? {
        switch self {
        case .off: nil
        case .every3min: 180
        case .every5min: 300
        }
    }

    /// Label sobre pour SettingsView
    var settingsLabel: String {
        switch self {
        case .off: "Aucune"
        case .every3min: "Occasionnelles"
        case .every5min: "Fréquentes"
        }
    }
}

// MARK: - Session Phase

enum SessionPhase {
    case intro
    case meditation
    case closing

    var label: String {
        switch self {
        case .intro: "Introduction"
        case .meditation: "Méditation"
        case .closing: "Retour au calme"
        }
    }
}

// MARK: - Session State

enum SessionState {
    case ready
    case running
    case paused
    case finished
    case cancelled
}
