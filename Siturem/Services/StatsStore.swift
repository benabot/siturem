import Foundation

// MARK: - Stats Store
// Persistance locale des séances et calcul des statistiques.

@Observable
final class StatsStore {

    private let key = "siturem.sessions"
    private(set) var records: [SessionRecord] = []

    init() {
        load()
    }

    // MARK: - Public API

    func save(_ record: SessionRecord) {
        records.append(record)
        persist()
    }

    // MARK: - Computed Stats

    var totalSessions: Int { records.count }

    var totalSeconds: Int {
        records.reduce(0) { $0 + $1.actualDuration }
    }

    var secondsToday: Int {
        records
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.actualDuration }
    }

    var seconds7Days: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return records.filter { $0.date >= cutoff }.reduce(0) { $0 + $1.actualDuration }
    }

    var seconds30Days: Int {
        let cutoff = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return records.filter { $0.date >= cutoff }.reduce(0) { $0 + $1.actualDuration }
    }

    var currentStreak: Int {
        streak(from: Date())
    }

    var bestStreak: Int {
        computeBestStreak()
    }

    // MARK: - Private

    private func streak(from date: Date) -> Int {
        var count = 0
        var day = Calendar.current.startOfDay(for: date)
        while true {
            let hasSession = records.contains { Calendar.current.isDate($0.date, inSameDayAs: day) }
            if hasSession {
                count += 1
                day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
            } else {
                break
            }
        }
        return count
    }

    private func computeBestStreak() -> Int {
        guard !records.isEmpty else { return 0 }
        let sortedDates = records.map { Calendar.current.startOfDay(for: $0.date) }
            .sorted()
        var best = 1
        var current = 1
        for i in 1..<sortedDates.count {
            let diff = Calendar.current.dateComponents([.day], from: sortedDates[i-1], to: sortedDates[i]).day ?? 0
            if diff == 1 { current += 1; best = max(best, current) }
            else if diff > 1 { current = 1 }
        }
        return best
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let saved = try? JSONDecoder().decode([SessionRecord].self, from: data) else { return }
        records = saved
    }
}
