import Foundation

enum AudioLocale: String, CaseIterable, Codable {
    case fr
    case en
    case es

    static let fallback: AudioLocale = .en

    static func resolved(for uiLanguage: AppLanguage) -> AudioLocale {
        switch uiLanguage {
        case .fr:
            .fr
        case .enUS:
            .en
        case .es:
            .es
        case .de:
            .fallback
        }
    }
}

enum SharedAudioAssetGroup: String {
    case gongs = "Shared/Gongs"
    case ambiance = "Shared/Ambiance"

    var resourceSubdirectory: String {
        "Audio/\(rawValue)"
    }
}

enum LocalizedAudioAssetGroup: String {
    case intro = "VoiceGuidance/Intro"
    case reminders = "VoiceGuidance/Reminders"
    case outro = "VoiceGuidance/Outro"

    func resourceSubdirectory(for locale: AudioLocale) -> String {
        "Audio/\(locale.rawValue)/\(rawValue)"
    }
}

enum AudioAssetLocation {
    case shared(SharedAudioAssetGroup)
    case localized(LocalizedAudioAssetGroup)

    var cacheKeyComponent: String {
        switch self {
        case .shared(let group):
            "shared:\(group.rawValue)"
        case .localized(let group):
            "localized:\(group.rawValue)"
        }
    }

    func resourceSubdirectories(for locale: AudioLocale, fallback: AudioLocale) -> [String] {
        switch self {
        case .shared(let group):
            return [group.resourceSubdirectory]
        case .localized(let group):
            let locales: [AudioLocale] = locale == fallback ? [fallback] : [locale, fallback]
            return locales.map { group.resourceSubdirectory(for: $0) }
        }
    }
}

enum AudioAsset {
    case gong
    case ambient(AmbientSound)
    case intro(IntroGuidanceClip)
    case reminder
    case outro(OutroGuidanceClip)

    var location: AudioAssetLocation {
        switch self {
        case .gong:
            .shared(.gongs)
        case .ambient:
            .shared(.ambiance)
        case .intro:
            .localized(.intro)
        case .reminder:
            .localized(.reminders)
        case .outro:
            .localized(.outro)
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

enum GuidanceSequencePlacement {
    case sequential
    case anchoredToPhaseEnd(leadTime: TimeInterval)
}

struct OrderedGuidanceStep {
    let asset: AudioAsset
    let expectedDuration: TimeInterval
    let postDelay: TimeInterval
    let placement: GuidanceSequencePlacement

    var fileName: String { asset.baseName }
    var location: AudioAssetLocation { asset.location }
}

extension OrderedGuidanceStep {
    static func sequential(
        _ asset: AudioAsset,
        expectedDuration: TimeInterval,
        postDelay: TimeInterval
    ) -> OrderedGuidanceStep {
        OrderedGuidanceStep(
            asset: asset,
            expectedDuration: expectedDuration,
            postDelay: postDelay,
            placement: .sequential
        )
    }

    static func anchoredToPhaseEnd(
        _ asset: AudioAsset,
        expectedDuration: TimeInterval,
        leadTime: TimeInterval,
        postDelay: TimeInterval = 0
    ) -> OrderedGuidanceStep {
        OrderedGuidanceStep(
            asset: asset,
            expectedDuration: expectedDuration,
            postDelay: postDelay,
            placement: .anchoredToPhaseEnd(leadTime: leadTime)
        )
    }
}

enum VoiceGuidanceLibrary {
    static let introSteps: [OrderedGuidanceStep] = [
        .sequential(.intro(.bonjour), expectedDuration: 3.552, postDelay: 1.5),
        .sequential(.gong, expectedDuration: 6.072, postDelay: 1.5),
        .sequential(.intro(.posture), expectedDuration: 7.512, postDelay: 3.5),
        .sequential(.intro(.fourBreaths), expectedDuration: 10.104, postDelay: 13.0),
        .sequential(.intro(.closeEyes), expectedDuration: 10.608, postDelay: 4.0),
        .sequential(.intro(.contactPoints), expectedDuration: 9.768, postDelay: 10.0),
        .sequential(.intro(.environment), expectedDuration: 11.712, postDelay: 10.0),
        .sequential(.intro(.bodyScan), expectedDuration: 13.248, postDelay: 0),
        .anchoredToPhaseEnd(.intro(.breathFocus), expectedDuration: 6.96, leadTime: 5)
    ]

    static let outroSteps: [OrderedGuidanceStep] = [
        .sequential(.outro(.releaseBreathFocus), expectedDuration: 6.216, postDelay: 17.0),
        .sequential(.outro(.contactPoints), expectedDuration: 6.648, postDelay: 15.0),
        .sequential(.outro(.environment), expectedDuration: 7.608, postDelay: 19.0),
        .sequential(.outro(.openEyes), expectedDuration: 7.8, postDelay: 3.0),
        .sequential(.gong, expectedDuration: 6.072, postDelay: 0)
    ]
}

struct AudioAssetResolver {
    let bundle: Bundle

    func url(for asset: AudioAsset, locale: AudioLocale) -> URL? {
        guard !asset.baseName.isEmpty else { return nil }

        return url(
            for: asset.baseName,
            locale: locale,
            location: asset.location,
            supportedExtensions: asset.supportedExtensions
        )
    }

    func url(
        for fileName: String,
        locale: AudioLocale,
        location: AudioAssetLocation,
        supportedExtensions: [String]
    ) -> URL? {
        for subdirectory in location.resourceSubdirectories(for: locale, fallback: .fallback) {
            for fileExtension in supportedExtensions {
                if let url = bundle.url(
                    forResource: fileName,
                    withExtension: fileExtension,
                    subdirectory: subdirectory
                ) {
                    return url
                }
            }
        }

        return nil
    }
}
