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
    case guided = "Guidé"

    var id: String { rawValue }

    var displayLabel: LocalizedStringResource {
        switch self {
        case .silent:
            "Silencieux"
        case .guided:
            "Guidé"
        }
    }
}

// MARK: - Gong Mode

enum GongMode: String, CaseIterable, Identifiable {
    case off = "Off"
    case sessionBounds = "Début / Fin"

    var id: String { rawValue }

    var playsSessionBoundaryGongs: Bool {
        self == .sessionBounds
    }

    var displayLabel: LocalizedStringResource {
        switch self {
        case .off:
            "Off"
        case .sessionBounds:
            "Début / Fin"
        }
    }
}

// MARK: - Ambient Sound

enum AmbientSound: String, CaseIterable, Identifiable {
    case off = "Off"
    case rain = "Pluie"
    case river = "Rivière"
    case forest = "Forêt"
    case whiteNoise = "Bruit blanc"

    var id: String { rawValue }

    var displayLabel: LocalizedStringResource {
        switch self {
        case .off:
            "Off"
        case .rain:
            "Pluie"
        case .river:
            "Rivière"
        case .forest:
            "Forêt"
        case .whiteNoise:
            "Bruit blanc"
        }
    }
}

// MARK: - Reminder Interval

enum ReminderInterval: String, CaseIterable, Identifiable {
    case off = "Off"
    case every90sec = "Toutes les 1m30"
    case every150sec = "Toutes les 2m30"

    var id: String { rawValue }

    var seconds: Int? {
        switch self {
        case .off: nil
        case .every90sec: 90
        case .every150sec: 150
        }
    }

    /// Label sobre pour SettingsView
    var settingsLabel: LocalizedStringResource {
        switch self {
        case .off: "Aucune"
        case .every90sec: "Fréquentes"
        case .every150sec: "Occasionnelles"
        }
    }
}

// MARK: - Session Phase

enum SessionPhase {
    case intro
    case meditation
    case closing

    var displayLabel: LocalizedStringResource {
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
