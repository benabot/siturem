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

enum AudioAssetGroup: String {
    case gongs = "Gongs"
    case ambiance = "Ambiance"
    case intro = "VoiceGuidance/Intro"
    case reminders = "VoiceGuidance/Reminders"
    case outro = "VoiceGuidance/Outro"

    func resourceSubdirectory(for locale: AudioLocale) -> String {
        "Audio/\(locale.rawValue)/\(rawValue)"
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
            .intro
        case .reminder:
            .reminders
        case .outro:
            .outro
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
    var group: AudioAssetGroup { asset.group }
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
            group: asset.group,
            supportedExtensions: asset.supportedExtensions
        )
    }

    func url(
        for fileName: String,
        locale: AudioLocale,
        group: AudioAssetGroup,
        supportedExtensions: [String]
    ) -> URL? {
        for candidateLocale in candidateLocales(for: locale) {
            for fileExtension in supportedExtensions {
                if let url = bundle.url(
                    forResource: fileName,
                    withExtension: fileExtension,
                    subdirectory: group.resourceSubdirectory(for: candidateLocale)
                ) {
                    return url
                }
            }
        }

        return nil
    }

    private func candidateLocales(for locale: AudioLocale) -> [AudioLocale] {
        locale == .fallback ? [.fallback] : [locale, .fallback]
    }
}
