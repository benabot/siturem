import Foundation

// MARK: - Practice Frame Store
// Persistance locale des cadres V2 via UserDefaults + JSON.

@Observable
final class PracticeFrameStore {

    private enum StorageKey {
        static let frames = "siturem.practiceFrames"
        static let lastUsedFrameID = "siturem.practiceFrames.lastUsedFrameID"
    }

    private let defaults: UserDefaults
    private let isPersistenceEnabled: Bool

    /// L'ordre du tableau persisté fait foi pour le futur affichage côté Home.
    private(set) var frames: [PracticeFrame]

    /// Le dernier cadre utilisé reste une métadonnée du store, pas du modèle métier.
    private(set) var lastUsedFrameID: UUID?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.isPersistenceEnabled = true
        self.frames = []
        self.lastUsedFrameID = nil
        load()
    }

    /// Init léger pour previews et dev local, sans toucher au stockage utilisateur.
    init(
        previewFrames: [PracticeFrame],
        lastUsedFrameID: UUID? = nil
    ) {
        self.defaults = .standard
        self.isPersistenceEnabled = false
        self.frames = previewFrames
        self.lastUsedFrameID = lastUsedFrameID ?? previewFrames.first?.id
    }

    var favoriteFrames: [PracticeFrame] {
        frames.filter(\.isFavorite)
    }

    var frameIDsInDisplayOrder: [UUID] {
        frames.map(\.id)
    }

    var lastUsedFrame: PracticeFrame? {
        guard let lastUsedFrameID else { return nil }
        return frame(id: lastUsedFrameID)
    }

    func frame(id: UUID) -> PracticeFrame? {
        frames.first { $0.id == id }
    }

    func addFrame(_ frame: PracticeFrame) {
        guard self.frame(id: frame.id) == nil else {
            updateFrame(frame)
            return
        }

        frames.append(frame)
        persist()
    }

    func updateFrame(_ frame: PracticeFrame) {
        guard let index = frames.firstIndex(where: { $0.id == frame.id }) else { return }
        frames[index] = frame
        persist()
    }

    func deleteFrame(id: UUID) {
        guard let index = frames.firstIndex(where: { $0.id == id }) else { return }
        frames.remove(at: index)

        if lastUsedFrameID == id {
            lastUsedFrameID = nil
        }

        persist()
    }

    func setFavorite(_ isFavorite: Bool, forFrameID id: UUID) {
        guard var frame = frame(id: id) else { return }
        frame.isFavorite = isFavorite
        updateFrame(frame)
    }

    /// Réordonne les cadres existants de façon déterministe.
    /// Les identifiants inconnus sont ignorés, les doublons sont dédupliqués et les absents sont conservés en fin de liste.
    func updateDisplayOrder(frameIDs: [UUID]) {
        let framesByID = Dictionary(uniqueKeysWithValues: frames.map { ($0.id, $0) })
        var orderedFrames: [PracticeFrame] = []
        var seenIDs = Set<UUID>()

        for id in frameIDs where seenIDs.insert(id).inserted {
            if let frame = framesByID[id] {
                orderedFrames.append(frame)
            }
        }

        for frame in frames where seenIDs.insert(frame.id).inserted {
            orderedFrames.append(frame)
        }

        guard orderedFrames.map(\.id) != frames.map(\.id) else { return }

        frames = orderedFrames
        persist()
    }

    func markLastUsed(frameID: UUID?) {
        guard let frameID else {
            lastUsedFrameID = nil
            persistLastUsedFrameID()
            return
        }

        guard frame(id: frameID) != nil else { return }

        lastUsedFrameID = frameID
        persistLastUsedFrameID()
    }

    private func persist() {
        guard isPersistenceEnabled else { return }

        if let data = try? JSONEncoder().encode(frames) {
            defaults.set(data, forKey: StorageKey.frames)
        }

        persistLastUsedFrameID()
    }

    private func persistLastUsedFrameID() {
        guard isPersistenceEnabled else { return }

        if let lastUsedFrameID {
            defaults.set(lastUsedFrameID.uuidString, forKey: StorageKey.lastUsedFrameID)
        } else {
            defaults.removeObject(forKey: StorageKey.lastUsedFrameID)
        }
    }

    private func load() {
        guard isPersistenceEnabled else { return }
        var requiresPersistenceCleanup = false

        if let data = defaults.data(forKey: StorageKey.frames) {
            if let savedFrames = try? JSONDecoder().decode([PracticeFrame].self, from: data) {
                let normalizedFrames = normalizeFrames(savedFrames)
                frames = normalizedFrames
                requiresPersistenceCleanup = normalizedFrames.count != savedFrames.count
            } else {
                frames = []
                requiresPersistenceCleanup = true
            }
        }

        if let rawLastUsedFrameID = defaults.string(forKey: StorageKey.lastUsedFrameID),
           let lastUsedFrameID = UUID(uuidString: rawLastUsedFrameID),
           frames.contains(where: { $0.id == lastUsedFrameID }) {
            self.lastUsedFrameID = lastUsedFrameID
        } else {
            requiresPersistenceCleanup = requiresPersistenceCleanup || defaults.object(forKey: StorageKey.lastUsedFrameID) != nil
            lastUsedFrameID = nil
        }

        if requiresPersistenceCleanup {
            persist()
        }
    }

    /// En cas de doublons accidentels, on conserve la première occurrence pour rester stable et prévisible.
    private func normalizeFrames(_ candidateFrames: [PracticeFrame]) -> [PracticeFrame] {
        var seenIDs = Set<UUID>()

        return candidateFrames.filter { frame in
            seenIDs.insert(frame.id).inserted
        }
    }
}

extension PracticeFrameStore {
    static var preview: PracticeFrameStore {
        PracticeFrameStore(
            previewFrames: PracticeFrame.previewFrames,
            lastUsedFrameID: PracticeFrame.previewFrames.last?.id
        )
    }
}
