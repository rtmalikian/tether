import SwiftUI

@main
struct TetherApp: App {
    @StateObject private var breaks = BreakEngine()
    @StateObject private var pomodoro = PomodoroEngine()
    @StateObject private var buddies = BuddyManager()
    @StateObject private var feedback = FeedbackStore()
    @StateObject private var usage = UsageMonitor()

    init() {
        Notifications.requestAuthorization()
    }

    var body: some Scene {
        MenuBarExtra("Tether", systemImage: "leaf.fill") {
            MenuBarView()
                .environmentObject(breaks)
                .environmentObject(pomodoro)
                .environmentObject(buddies)
                .environmentObject(feedback)
                .environmentObject(usage)
        }
        .menuBarExtraStyle(.window)

        Window("Tether Dashboard", id: "dashboard") {
            DashboardView()
                .environmentObject(breaks)
                .environmentObject(pomodoro)
                .environmentObject(buddies)
                .environmentObject(feedback)
                .environmentObject(usage)
        }
        .defaultSize(width: 760, height: 560)

        Settings {
            SettingsView()
                .environmentObject(breaks)
                .environmentObject(pomodoro)
                .environmentObject(buddies)
                .environmentObject(usage)
        }
    }
}
