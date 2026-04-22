import Foundation

// MARK: - Stats Store
// Persistance locale des séances et calcul des statistiques.

@Observable
final class StatsStore {

    struct PracticeDay: Identifiable, Hashable {
        let date: Date
        let didPractice: Bool

        var id: Date { date }
    }

    struct MonthlyPracticeTotal: Identifiable, Hashable {
        let monthStart: Date
        let totalSeconds: Int

        var id: Date { monthStart }
    }

    private let key = "siturem.sessions"
    private(set) var records: [SessionRecord] = []

    init() {
        #if DEBUG
        if let seededRecords = Self.debugRecordsFromEnvironment() {
            records = seededRecords
            return
        }
        #endif

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

    var practiceHeatmap90Days: [PracticeDay] {
        practiceDays(last: 90)
    }

    var recentMonthlyTotals: [MonthlyPracticeTotal] {
        monthlyTotals(last: 2)
    }

    var averageWeeklySeconds: Int {
        recentAverageWeeklySeconds(windowDays: 28)
    }

    var recentRecords: [SessionRecord] {
        records.sorted { $0.date > $1.date }
    }

    // MARK: - Private

    private func practiceDays(last days: Int, endingOn endDate: Date = Date()) -> [PracticeDay] {
        guard days > 0 else { return [] }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: endDate)
        let practicedDays = Set(records.map { calendar.startOfDay(for: $0.date) })

        return (0..<days).compactMap { offset in
            let remainingDays = days - offset - 1
            guard let date = calendar.date(byAdding: .day, value: -remainingDays, to: lastDay) else {
                return nil
            }

            return PracticeDay(
                date: date,
                didPractice: practicedDays.contains(date)
            )
        }
    }

    private func monthlyTotals(last months: Int, endingOn endDate: Date = Date()) -> [MonthlyPracticeTotal] {
        guard months > 0 else { return [] }

        let calendar = Calendar.current
        let currentMonthStart = monthStart(for: endDate, calendar: calendar)
        let totalsByMonth = Dictionary(grouping: records) { record in
            monthStart(for: record.date, calendar: calendar)
        }

        return (0..<months).compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: -offset, to: currentMonthStart) else {
                return nil
            }

            let totalSeconds = totalsByMonth[monthStart]?.reduce(0) { partialResult, record in
                partialResult + record.actualDuration
            } ?? 0

            return MonthlyPracticeTotal(
                monthStart: monthStart,
                totalSeconds: totalSeconds
            )
        }
    }

    private func recentAverageWeeklySeconds(windowDays: Int, endingOn endDate: Date = Date()) -> Int {
        guard !records.isEmpty, windowDays > 0 else { return 0 }

        let calendar = Calendar.current
        let lastDay = calendar.startOfDay(for: endDate)
        let requestedWindowStart = calendar.date(byAdding: .day, value: -(windowDays - 1), to: lastDay) ?? lastDay
        let firstRecordedDay = records
            .map { calendar.startOfDay(for: $0.date) }
            .min() ?? lastDay
        let windowStart = max(requestedWindowStart, firstRecordedDay)

        let totalSecondsInWindow = records.reduce(0) { partialResult, record in
            let recordDay = calendar.startOfDay(for: record.date)
            guard recordDay >= windowStart, recordDay <= lastDay else {
                return partialResult
            }
            return partialResult + record.actualDuration
        }

        let observedDays = (calendar.dateComponents([.day], from: windowStart, to: lastDay).day ?? 0) + 1
        guard observedDays > 0 else { return 0 }

        return Int((Double(totalSecondsInWindow) / Double(observedDays) * 7).rounded())
    }

    private func monthStart(for date: Date, calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year, .month], from: date))
            ?? calendar.startOfDay(for: date)
    }

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

    #if DEBUG
    private static func debugRecordsFromEnvironment() -> [SessionRecord]? {
        if let scenario = ProcessInfo.processInfo.environment["SITUREM_STATS_SCENARIO"] {
            return debugRecords(for: scenario)
        }

        let arguments = ProcessInfo.processInfo.arguments
        guard let scenarioIndex = arguments.firstIndex(of: "-stats-scenario"),
              arguments.indices.contains(scenarioIndex + 1) else {
            return nil
        }

        return debugRecords(for: arguments[scenarioIndex + 1])
    }

    private static func debugRecords(for scenario: String) -> [SessionRecord]? {
        let calendar = Calendar.current

        func record(daysAgo: Int, minutes: Int) -> SessionRecord {
            SessionRecord(
                date: calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date(),
                plannedDuration: minutes * 60,
                actualDuration: minutes * 60,
                accompaniment: .guided,
                isComplete: true
            )
        }

        switch scenario {
        case "empty":
            return []
        case "light":
            return [
                record(daysAgo: 0, minutes: 12),
                record(daysAgo: 3, minutes: 10),
                record(daysAgo: 11, minutes: 18),
                record(daysAgo: 27, minutes: 25)
            ]
        case "filled":
            let evenDays = stride(from: 0, through: 88, by: 2).map {
                record(daysAgo: $0, minutes: 10 + ($0 % 3) * 4)
            }
            let recentCluster = [1, 4, 5, 6, 9, 13].map {
                record(daysAgo: $0, minutes: 14)
            }
            return evenDays + recentCluster
        default:
            return nil
        }
    }
    #endif
}
