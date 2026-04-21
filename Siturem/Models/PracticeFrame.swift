import Foundation

/// Cadre de pratique nommé, pensé comme une façade légère au-dessus de `SessionConfiguration`.
/// La locale audio reste résolue côté `PreferencesStore`.
struct PracticeFrame: Identifiable, Hashable, Codable {

    /// Identifiant stable pour le futur stockage du dernier cadre utilisé.
    let id: UUID

    var name: String

    /// Durée totale de la séance en secondes.
    var duration: Int
    var accompaniment: AccompanimentMode
    var gong: GongMode
    var ambient: AmbientSound

    /// Réglage unique de rappel discret dans le V1 actuel.
    var reminder: ReminderInterval
    var isFavorite: Bool

    init(
        id: UUID = UUID(),
        name: String,
        duration: Int,
        accompaniment: AccompanimentMode,
        gong: GongMode,
        ambient: AmbientSound,
        reminder: ReminderInterval,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.name = name
        self.duration = duration
        self.accompaniment = accompaniment
        self.gong = gong
        self.ambient = ambient
        self.reminder = reminder
        self.isFavorite = isFavorite
    }

    init(
        id: UUID = UUID(),
        name: String,
        sessionConfiguration: SessionConfiguration,
        isFavorite: Bool = false
    ) {
        self.init(
            id: id,
            name: name,
            duration: sessionConfiguration.totalDuration,
            accompaniment: sessionConfiguration.accompaniment,
            gong: sessionConfiguration.gong,
            ambient: sessionConfiguration.ambient,
            reminder: sessionConfiguration.reminder,
            isFavorite: isFavorite
        )
    }

    /// Recompose la configuration V1 pour lancer une séance.
    func sessionConfiguration(audioLocale: AudioLocale) -> SessionConfiguration {
        SessionConfiguration(
            totalDuration: duration,
            accompaniment: accompaniment,
            gong: gong,
            ambient: ambient,
            reminder: reminder,
            audioLocale: audioLocale
        )
    }
}

extension PracticeFrame {

    /// Données sobres pour les previews et le développement local des prochains tickets V2.
    static let previewFrames: [PracticeFrame] = [
        PracticeFrame(
            name: "Ancrage 10 min",
            duration: 600,
            accompaniment: .guided,
            gong: .sessionBounds,
            ambient: .off,
            reminder: .off,
            isFavorite: true
        ),
        PracticeFrame(
            name: "Silence 20 min",
            duration: 1_200,
            accompaniment: .silent,
            gong: .sessionBounds,
            ambient: .forest,
            reminder: .off
        ),
        PracticeFrame(
            name: "Souffle 15 min",
            duration: 900,
            accompaniment: .guided,
            gong: .off,
            ambient: .river,
            reminder: .every150sec
        )
    ]
}
