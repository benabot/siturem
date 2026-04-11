import Foundation
import HealthKit

// MARK: - HealthKit Service
// Écriture des séances de méditation dans HealthKit.

final class HealthKitService {

    private let store = HKHealthStore()

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard isAvailable else { return }
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        try await store.requestAuthorization(toShare: [mindfulType], read: [])
    }

    // MARK: - Write session

    func save(startDate: Date, endDate: Date) async throws {
        guard isAvailable else { return }
        let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!
        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )
        try await store.save(sample)
    }
}
