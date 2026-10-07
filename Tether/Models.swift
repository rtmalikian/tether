import Foundation

// MARK: - Shared helpers

/// Format seconds as m:ss
func fmt(_ totalSeconds: Int) -> String {
    let s = max(0, totalSeconds)
    return String(format: "%d:%02d", s / 60, s % 60)
}

func todayKey(_ date: Date = Date()) -> String {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f.string(from: date)
}

// MARK: - Breaks

enum BreakKind: String, Codable, CaseIterable {
    case eye        // 20-20-20 look-away
    case movement   // get up and move
    case pomodoro   // pomodoro break
    case outdoor    // touch grass with a buddy

    var title: String {
        switch self {
        case .eye: return "Eye break"
        case .movement: return "Movement break"
        case .pomodoro: return "Pomodoro break"
        case .outdoor: return "Outdoor break"
        }
    }
}

struct BreakEvent: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var kind: BreakKind
    var completed: Bool
    var durationSeconds: Int
}

// MARK: - Pomodoro

struct PomodoroConfig: Codable {
    var workMinutes = 25
    var shortBreakMinutes = 5
    var longBreakMinutes = 15
    var roundsBeforeLong = 4
}

// MARK: - Settings

struct AppSettings: Codable {
    var eyeBreakMinutes = 20
    var eyeBreakSeconds = 20
    // Default 30 min: Duran et al. 2023 (MSSE, randomized crossover) found only
    // the every-30-min-for-5-min dose significantly blunted glucose spikes, and
    // Gale et al. 2026 (meta-analysis, 53 RCTs) found 15–20 min intervals had the
    // largest effects. Hourly also has support (Kowalsky 2021) — adjustable.
    var movementBreakMinutes = 30
    var movementBreakSeconds = 300
    var continuousNudgeMinutes = 90
    // Non-stop input streak: typing/clicking with no real pause. Distinct from
    // total active time — this catches the "haven't lifted my hands" pattern.
    var nonstopNudgeMinutes = 45
    var enableUsageMonitor = false
    var enableBuddyDiscovery = true
    var buddyDisplayName = "Tether User"
    var pomodoro = PomodoroConfig()
    var autoStartBreaks = false
}

// MARK: - Feedback

struct FeedbackEntry: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    /// 1...5 — "Did taking breaks help your focus today?"
    var focusScore: Int
    /// 1...5 — "How balanced did your day feel?"
    var balanceScore: Int
    var note = ""
}

// MARK: - Buddies

struct SharedActivity: Codable, Identifiable {
    var id = UUID()
    var date = Date()
    var title: String
    var withBuddy: String?
}

/// Wire format for buddy-to-buddy messages (local network, MultipeerConnectivity).
struct BuddyMessage: Codable {
    /// "break-start" | "break-end" | "nudge" | "activity"
    var type: String
    var sender: String
    var text: String?
    var date = Date()
}
