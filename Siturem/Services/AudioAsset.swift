import Foundation

enum AudioAssetGroup {
    case gongs
    case ambiance
    case voiceIntro
    case voiceReminders
    case voiceOutro

    var subdirectory: String {
        switch self {
        case .gongs:
            "Audio/Gongs"
        case .ambiance:
            "Audio/Ambiance"
        case .voiceIntro:
            "Audio/VoiceGuidance/Intro"
        case .voiceReminders:
            "Audio/VoiceGuidance/Reminders"
        case .voiceOutro:
            "Audio/VoiceGuidance/Outro"
        }
    }
}

enum AudioAsset {
    case gong
    case ambient(AmbientSound)
    case intro(IntroGuidanceClip)
    case reminder
    case outro(OutroGuidanceClip)

    var group: AudioAssetGroup {
        switch self {
        case .gong:
            .gongs
        case .ambient:
            .ambiance
        case .intro:
            .voiceIntro
        case .reminder:
            .voiceReminders
        case .outro:
            .voiceOutro
        }
    }

    var baseName: String {
        switch self {
        case .gong:
            "gong"
        case .ambient(let sound):
            switch sound {
            case .off:
                ""
            case .rain:
                "rain-loop"
            case .river:
                "river-loop"
            case .forest:
                "forest-loop"
            case .whiteNoise:
                "white-noise-loop"
            }
        case .intro(let clip):
            clip.rawValue
        case .reminder:
            "reminder_soft_01"
        case .outro(let clip):
            clip.rawValue
        }
    }

    var supportedExtensions: [String] {
        switch self {
        case .gong, .intro, .reminder, .outro:
            ["caf", "m4a"]
        case .ambient:
            ["m4a", "caf"]
        }
    }
}

enum IntroGuidanceClip: String {
    case bonjour = "intro_01_bonjour"
    case posture = "intro_02_posture"
    case fourBreaths = "intro_03_4_grandes_respirations"
    case closeEyes = "intro_04_fermer_les_yeux"
    case contactPoints = "intro_05_points_de_contact"
    case environment = "intro_06_conscience_environnement"
    case bodyScan = "intro_07_scan_corporel"
    case breathFocus = "intro_08_concentration_souffle"
}

enum OutroGuidanceClip: String {
    case releaseBreathFocus = "outro_01_liberer-concentration_souffle"
    case contactPoints = "outro_02_points-de-contact"
    case environment = "outro_03_conscience_environnement"
    case openEyes = "outro_05_ouverture_yeux"
}

struct GuidanceCue {
    let second: TimeInterval
    let asset: AudioAsset
}

enum VoiceGuidanceLibrary {
    static let introCues: [GuidanceCue] = [
        GuidanceCue(second: 0, asset: .intro(.bonjour)),
        GuidanceCue(second: 3, asset: .intro(.posture)),
        GuidanceCue(second: 5, asset: .intro(.fourBreaths)),
        GuidanceCue(second: 11, asset: .intro(.closeEyes)),
        GuidanceCue(second: 13, asset: .intro(.contactPoints)),
        GuidanceCue(second: 40, asset: .intro(.environment)),
        GuidanceCue(second: 90, asset: .intro(.bodyScan)),
        GuidanceCue(second: 145, asset: .intro(.breathFocus))
    ]

    static let outroCues: [GuidanceCue] = [
        GuidanceCue(second: 0, asset: .outro(.releaseBreathFocus)),
        GuidanceCue(second: 15, asset: .outro(.contactPoints)),
        GuidanceCue(second: 27, asset: .outro(.environment)),
        GuidanceCue(second: 38, asset: .outro(.openEyes))
    ]
}

struct AudioAssetResolver {
    let bundle: Bundle

    func url(for asset: AudioAsset) -> URL? {
        guard !asset.baseName.isEmpty else { return nil }

        for fileExtension in asset.supportedExtensions {
            if let url = bundle.url(
                forResource: asset.baseName,
                withExtension: fileExtension,
                subdirectory: asset.group.subdirectory
            ) {
                return url
            }

            if let url = bundle.url(forResource: asset.baseName, withExtension: fileExtension) {
                return url
            }
        }

        return nil
    }
}
