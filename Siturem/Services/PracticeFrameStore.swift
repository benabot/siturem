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

    private(set) var frames: [PracticeFrame]
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

        if let data = defaults.data(forKey: StorageKey.frames),
           let savedFrames = try? JSONDecoder().decode([PracticeFrame].self, from: data) {
            frames = savedFrames
        }

        if let rawLastUsedFrameID = defaults.string(forKey: StorageKey.lastUsedFrameID),
           let lastUsedFrameID = UUID(uuidString: rawLastUsedFrameID),
           frames.contains(where: { $0.id == lastUsedFrameID }) {
            self.lastUsedFrameID = lastUsedFrameID
        } else {
            lastUsedFrameID = nil
            persistLastUsedFrameID()
        }
    }
}

extension PracticeFrameStore {
    static var preview: PracticeFrameStore {
        PracticeFrameStore(
            previewFrames: PracticeFrame.previewFrames,
            lastUsedFrameID: PracticeFrame.previewFrames.first?.id
        )
    }
}
