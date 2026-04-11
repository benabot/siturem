import Foundation

// MARK: - Completed Session Record

struct SessionRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let plannedDuration: Int    // secondes
    let actualDuration: Int     // secondes
    let accompaniment: String
    let isComplete: Bool

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        plannedDuration: Int,
        actualDuration: Int,
        accompaniment: AccompanimentMode,
        isComplete: Bool
    ) {
        self.id = id
        self.date = date
        self.plannedDuration = plannedDuration
        self.actualDuration = actualDuration
        self.accompaniment = accompaniment.rawValue
        self.isComplete = isComplete
    }
}
