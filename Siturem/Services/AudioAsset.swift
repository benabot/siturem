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
        .sequential(.intro(.bonjour), expectedDuration: 3, postDelay: 1.5),
        .sequential(.gong, expectedDuration: 6.07, postDelay: 1.5),
        .sequential(.intro(.posture), expectedDuration: 4, postDelay: 3.5),
        .sequential(.intro(.fourBreaths), expectedDuration: 7, postDelay: 10),
        .sequential(.intro(.closeEyes), expectedDuration: 9, postDelay: 10),
        .sequential(.intro(.contactPoints), expectedDuration: 7, postDelay: 20),
        .sequential(.intro(.environment), expectedDuration: 11, postDelay: 25),
        .anchoredToPhaseEnd(.intro(.breathFocus), expectedDuration: 5, leadTime: 5)
    ]

    static let outroSteps: [OrderedGuidanceStep] = [
        .sequential(.outro(.releaseBreathFocus), expectedDuration: 5.73, postDelay: 1.0),
        .sequential(.outro(.contactPoints), expectedDuration: 5.55, postDelay: 1.0),
        .sequential(.outro(.environment), expectedDuration: 6.1, postDelay: 1.0),
        .sequential(.outro(.openEyes), expectedDuration: 5.53, postDelay: 0)
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
