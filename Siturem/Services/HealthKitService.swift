import Foundation
import HealthKit

// MARK: - HealthKit Authorization State

enum HealthKitAuthorizationState: Equatable {
    case unavailable
    case notDetermined
    case authorized
    case denied

    var isAuthorized: Bool {
        self == .authorized
    }
}

// MARK: - HealthKit Write Result

enum HealthKitWriteResult: Equatable {
    case saved
    case skippedSyncDisabled
    case skippedUnavailable
    case skippedUnauthorized
    case skippedInvalidDates
    case failed
}

// MARK: - HealthKit Service
// Intégration V1 : autorisation explicite et écriture silencieuse
// des séances terminées normalement dans HealthKit.

final class HealthKitService {

    private let store = HKHealthStore()
    private let mindfulSessionType = HKObjectType.categoryType(forIdentifier: .mindfulSession)!

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    var authorizationStatus: HealthKitAuthorizationState {
        guard isAvailable else { return .unavailable }

        switch store.authorizationStatus(for: mindfulSessionType) {
        case .notDetermined:
            return .notDetermined
        case .sharingAuthorized:
            return .authorized
        case .sharingDenied:
            return .denied
        @unknown default:
            return .denied
        }
    }

    // MARK: - Authorization

    @discardableResult
    func requestAuthorizationIfNeeded() async -> HealthKitAuthorizationState {
        guard isAvailable else { return .unavailable }

        let currentStatus = authorizationStatus
        guard currentStatus == .notDetermined else { return currentStatus }

        do {
            try await store.requestAuthorization(toShare: [mindfulSessionType], read: [])
        } catch {
            return authorizationStatus
        }

        return authorizationStatus
    }

    // MARK: - Write completed session

    func saveCompletedSession(
        startDate: Date,
        endDate: Date,
        isSyncEnabled: Bool
    ) async -> HealthKitWriteResult {
        guard isSyncEnabled else { return .skippedSyncDisabled }
        guard isAvailable else { return .skippedUnavailable }
        guard authorizationStatus.isAuthorized else { return .skippedUnauthorized }
        guard endDate > startDate else { return .skippedInvalidDates }

        let sample = HKCategorySample(
            type: mindfulSessionType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: startDate,
            end: endDate
        )

        do {
            try await store.save(sample)
            return .saved
        } catch {
            return .failed
        }
    }
}
