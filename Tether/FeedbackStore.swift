import Foundation
import Combine

/// Feedback loops: a tiny daily check-in ("did breaks help your focus? how
/// balanced did the day feel?") plus weekly trends. All local. This is how the
/// app learns whether it's actually helping — and shows you the answer.
final class FeedbackStore: ObservableObject {
    @Published private(set) var entries: [FeedbackEntry] = Store.load("feedback", default: [])

    var todayEntry: FeedbackEntry? {
        entries.first { Calendar.current.isDateInToday($0.date) }
    }

    var needsCheckIn: Bool { todayEntry == nil }

    func save(focus: Int, balance: Int, note: String) {
        entries.removeAll { Calendar.current.isDateInToday($0.date) }
        entries.insert(FeedbackEntry(date: Date(), focusScore: focus,
                                     balanceScore: balance, note: note), at: 0)
        Store.save(entries, as: "feedback")
    }

    /// Average scores over the last 7 days, oldest → newest, for trend display.
    func last7Days() -> [(label: String, focus: Double, balance: Double)] {
        let cal = Calendar.current
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: Date())!
            let dayEntries = entries.filter { cal.isDate($0.date, inSameDayAs: date) }
            let f = dayEntries.map(\.focusScore)
            let b = dayEntries.map(\.balanceScore)
            let label: String = {
                let df = DateFormatter()
                df.dateFormat = "E"
                return df.string(from: date)
            }()
            return (label,
                    f.isEmpty ? 0 : Double(f.reduce(0, +)) / Double(f.count),
                    b.isEmpty ? 0 : Double(b.reduce(0, +)) / Double(b.count))
        }
    }

    var weekFocusAverage: Double {
        let vals = entries.prefix(7).map(\.focusScore)
        guard !vals.isEmpty else { return 0 }
        return Double(vals.reduce(0, +)) / Double(vals.count)
    }

    var weekBalanceAverage: Double {
        let vals = entries.prefix(7).map(\.balanceScore)
        guard !vals.isEmpty else { return 0 }
        return Double(vals.reduce(0, +)) / Double(vals.count)
    }
}
