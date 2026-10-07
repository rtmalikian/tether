import SwiftUI
import AppKit

/// Settings: break cadence, pomodoro config, privacy toggles, data controls.
struct SettingsView: View {
    @EnvironmentObject var breaks: BreakEngine
    @EnvironmentObject var pomodoro: PomodoroEngine
    @EnvironmentObject var buddies: BuddyManager
    @EnvironmentObject var usage: UsageMonitor

    var body: some View {
        Form {
            Section("Break reminders") {
                Stepper("Eye break (20-20-20) every \(breaks.settings.eyeBreakMinutes) min",
                        value: binding(\.eyeBreakMinutes), in: 5...60, step: 5)
                Stepper("Look-away duration: \(breaks.settings.eyeBreakSeconds) sec",
                        value: binding(\.eyeBreakSeconds), in: 10...60, step: 5)
                Stepper("Movement break every \(breaks.settings.movementBreakMinutes) min",
                        value: binding(\.movementBreakMinutes), in: 20...120, step: 10)
                Stepper("Nudge after \(breaks.settings.continuousNudgeMinutes) min continuous use",
                        value: binding(\.continuousNudgeMinutes), in: 30...180, step: 15)
            }

            Section("Pomodoro") {
                Stepper("Focus: \(pomodoro.config.workMinutes) min",
                        value: configBinding(\.workMinutes), in: 10...60, step: 5)
                Stepper("Short break: \(pomodoro.config.shortBreakMinutes) min",
                        value: configBinding(\.shortBreakMinutes), in: 1...15)
                Stepper("Long break: \(pomodoro.config.longBreakMinutes) min",
                        value: configBinding(\.longBreakMinutes), in: 5...45, step: 5)
                Stepper("Long break every \(pomodoro.config.roundsBeforeLong) sprints",
                        value: configBinding(\.roundsBeforeLong), in: 2...8)
            }

            Section("Buddies") {
                Toggle("Discover buddies on local network", isOn: $buddies.enabled)
                TextField("Display name", text: displayNameBinding)
                    .textFieldStyle(.roundedBorder)
                Text("Buddies connect over your local Wi-Fi. No accounts, no servers.")
                    .font(.caption).foregroundColor(.secondary)
            }

            Section("AI usage awareness (optional)") {
                Toggle("Monitor time in AI apps", isOn: $usage.enabled)
                if usage.enabled && !usage.permissionGranted {
                    Button("Grant Accessibility permission") { usage.requestTrust() }
                    Text("Tether reads the frontmost app's name only — never what you type. Grant access in System Settings → Privacy & Security → Accessibility.")
                        .font(.caption).foregroundColor(.secondary)
                }
            }

            Section("Your data") {
                Button("Reveal data folder in Finder") {
                    NSWorkspace.shared.open(Store.directory)
                }
                Button("Delete all Tether data", role: .destructive) {
                    Store.deleteAll()
                }
                Text("Everything is stored on this Mac. Nothing is uploaded anywhere.")
                    .font(.caption).foregroundColor(.secondary)
            }

            Section("About") {
                Text("Tether helps you take the breaks research says matter: 20-20-20 eye breaks, hourly movement, real focus sprints, and buddies who keep you honest.")
                    .font(.callout).foregroundColor(.secondary)
            }
        }
        .padding(16)
    }

    // MARK: - Bindings

    private func binding(_ keyPath: WritableKeyPath<AppSettings, Int>) -> Binding<Int> {
        Binding(
            get: { breaks.settings[keyPath: keyPath] },
            set: { breaks.settings[keyPath: keyPath] = $0 }
        )
    }

    private func configBinding(_ keyPath: WritableKeyPath<PomodoroConfig, Int>) -> Binding<Int> {
        Binding(
            get: { pomodoro.config[keyPath: keyPath] },
            set: {
                var c = pomodoro.config
                c[keyPath: keyPath] = $0
                pomodoro.config = c
            }
        )
    }

    private var displayNameBinding: Binding<String> {
        Binding(
            get: { breaks.settings.buddyDisplayName },
            set: {
                breaks.settings.buddyDisplayName = $0
                // Takes effect on next launch (peer ID is created at startup).
            }
        )
    }
}
