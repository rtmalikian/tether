import Foundation
import Combine

/// Classic Pomodoro technique: focused work sprints separated by real breaks.
/// 25/5 by default, long break after every 4th sprint — all configurable.
final class PomodoroEngine: ObservableObject {
    enum Phase: String {
        case idle, work, shortBreak, longBreak

        var label: String {
            switch self {
            case .idle: return "Ready"
            case .work: return "Focus"
            case .shortBreak: return "Short break"
            case .longBreak: return "Long break"
            }
        }
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var remaining = 0
    @Published private(set) var completedSprints = 0
    @Published var running = false

    var config: PomodoroConfig {
        get { Store.load("settings", default: AppSettings()).pomodoro }
        set {
            var s: AppSettings = Store.load("settings", default: AppSettings())
            s.pomodoro = newValue
            Store.save(s, as: "settings")
        }
    }

    private var timer: Timer?

    var menuLabel: String {
        phase == .idle ? "Pomodoro" : "\(phase.label) \(fmt(remaining))"
    }

    var progress: Double {
        let total = totalForPhase(phase)
        guard total > 0 else { return 0 }
        return 1.0 - Double(remaining) / Double(total)
    }

    func start() {
        guard phase == .idle else { return }
        begin(.work)
    }

    func pause() {
        running = false
        timer?.invalidate()
    }

    func resume() {
        guard phase != .idle, !running else { return }
        running = true
        schedule()
    }

    func reset() {
        timer?.invalidate()
        running = false
        phase = .idle
        remaining = 0
    }

    func skip() {
        advance()
    }

    // MARK: - Private

    private func totalForPhase(_ phase: Phase) -> Int {
        switch phase {
        case .idle: return 0
        case .work: return config.workMinutes * 60
        case .shortBreak: return config.shortBreakMinutes * 60
        case .longBreak: return config.longBreakMinutes * 60
        }
    }

    private func begin(_ phase: Phase) {
        self.phase = phase
        remaining = totalForPhase(phase)
        running = true
        schedule()
    }

    private func schedule() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard remaining > 0 else { advance(); return }
        remaining -= 1
    }

    private func advance() {
        timer?.invalidate()
        running = false
        switch phase {
        case .work:
            completedSprints += 1
            let long = completedSprints % config.roundsBeforeLong == 0
            Notifications.post(title: "Focus sprint done",
                               body: long ? "Time for a long break — you've earned it."
                                          : "Take \(config.shortBreakMinutes) minutes. Look far away, move a little.")
            begin(long ? .longBreak : .shortBreak)
        case .shortBreak, .longBreak:
            Notifications.post(title: "Break over", body: "Ready for the next focus sprint?")
            begin(.work)
        case .idle:
            break
        }
    }
}
