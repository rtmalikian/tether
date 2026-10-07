import Foundation
import CoreGraphics
import Combine

/// How long since the user last touched mouse or keyboard.
enum SystemIdle {
    static func seconds() -> Double {
        let mouse = CGEventSource.secondsSinceLastEventType(.combinedSessionState, .mouseMoved)
        let keys = CGEventSource.secondsSinceLastEventType(.combinedSessionState, .keyDown)
        return min(mouse, keys)
    }
}

/// The heart of Tether: watches active computer use and fires break reminders.
///
/// - 20-20-20 eye breaks (default every 20 min, 20-second look-away)
/// - Movement breaks (default every 60 min)
/// - A gentle nudge after long continuous use (default 90 min)
///
/// Time only accumulates while the user is actually active (idle < 90s).
/// Being away for 5+ minutes counts as a natural break and resets the timers.
final class BreakEngine: ObservableObject {
    @Published var settings: AppSettings {
        didSet { Store.save(settings, as: "settings") }
    }
    @Published private(set) var activeSecondsToday = 0
    @Published private(set) var eyeBreakIn = 20 * 60
    @Published private(set) var movementBreakIn = 60 * 60
    @Published private(set) var events: [BreakEvent] = []

    private var timer: Timer?
    private var day = todayKey()
    private var eyeAccum = 0
    private var moveAccum = 0
    private var continuousNudged = false

    init() {
        settings = Store.load("settings", default: AppSettings())
        events = Store.load("events", default: [BreakEvent]()).filter {
            Calendar.current.isDateInToday($0.date)
        }
        activeSecondsToday = Store.load("active-\(todayKey())", default: 0)
        eyeBreakIn = settings.eyeBreakMinutes * 60
        movementBreakIn = settings.movementBreakMinutes * 60
        start()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    // MARK: - Public actions

    func startEyeBreakNow() { fireEyeBreak() }

    func startMovementBreakNow() { fireMovementBreak() }

    func logOutdoorBreak(minutes: Int, with buddy: String? = nil) {
        log(kind: .outdoor, seconds: minutes * 60, completed: true)
        Notifications.post(title: "Nice — you touched grass",
                           body: buddy == nil
                            ? "Outdoor break logged. Your eyes and legs thank you."
                            : "Outdoor break with \(buddy!) logged. Accountability works.")
    }

    var breaksTakenToday: Int { events.count }
    var eyeBreaksToday: Int { events.filter { $0.kind == .eye }.count }
    var movementBreaksToday: Int { events.filter { $0.kind == .movement }.count }

    // MARK: - Tick

    private func tick() {
        rollDayIfNeeded()
        let idle = SystemIdle.seconds()

        if idle > 300 {
            // Away for 5+ minutes: counts as a natural break.
            eyeAccum = 0
            moveAccum = 0
            refreshCountdowns()
            return
        }
        guard idle < 90 else { return } // idle but present: don't accumulate

        activeSecondsToday += 1
        eyeAccum += 1
        moveAccum += 1
        refreshCountdowns()

        if eyeAccum >= settings.eyeBreakMinutes * 60 {
            fireEyeBreak()
        } else if moveAccum >= settings.movementBreakMinutes * 60 {
            fireMovementBreak()
        } else if !continuousNudged,
                  activeSecondsToday >= settings.continuousNudgeMinutes * 60 {
            continuousNudged = true
            Notifications.post(
                title: "You've been at it for \(settings.continuousNudgeMinutes) minutes",
                body: "Research links long uninterrupted screen sessions with fatigue and eye strain. Take 5?")
        }
        Store.save(activeSecondsToday, as: "active-\(day)")
    }

    private func refreshCountdowns() {
        eyeBreakIn = max(0, settings.eyeBreakMinutes * 60 - eyeAccum)
        movementBreakIn = max(0, settings.movementBreakMinutes * 60 - moveAccum)
    }

    private func fireEyeBreak() {
        eyeAccum = 0
        refreshCountdowns()
        log(kind: .eye, seconds: settings.eyeBreakSeconds, completed: true)
        BreakOverlay.show(seconds: settings.eyeBreakSeconds,
                          title: "20-20-20",
                          message: "Look at something 20 feet away for 20 seconds.")
        Notifications.post(title: "Eye break",
                           body: "20 seconds looking into the distance. Your eyes will thank you.")
    }

    private func fireMovementBreak() {
        moveAccum = 0
        eyeAccum = 0
        refreshCountdowns()
        log(kind: .movement, seconds: settings.movementBreakSeconds, completed: true)
        BreakOverlay.show(seconds: min(60, settings.movementBreakSeconds),
                          title: "Move break",
                          message: "Stand up. Roll your shoulders. Walk to some water.")
        Notifications.post(title: "Movement break",
                           body: "You've been sitting a while — 5 minutes of movement resets a lot.")
    }

    private func log(kind: BreakKind, seconds: Int, completed: Bool) {
        events.append(BreakEvent(date: Date(), kind: kind,
                                 completed: completed, durationSeconds: seconds))
        Store.save(events, as: "events")
    }

    private func rollDayIfNeeded() {
        let k = todayKey()
        guard k != day else { return }
        day = k
        activeSecondsToday = 0
        eyeAccum = 0
        moveAccum = 0
        continuousNudged = false
        events = []
        refreshCountdowns()
    }
}
