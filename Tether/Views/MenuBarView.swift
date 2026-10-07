import SwiftUI
import AppKit

/// The menu-bar popover: glanceable status + quick actions.
struct MenuBarView: View {
    @EnvironmentObject var breaks: BreakEngine
    @EnvironmentObject var pomodoro: PomodoroEngine
    @EnvironmentObject var buddies: BuddyManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "leaf.fill").foregroundColor(.green)
                Text("Tether").font(.headline)
                Spacer()
                if !buddies.buddiesOnBreak.isEmpty {
                    Label("\(buddies.buddiesOnBreak.count)", systemImage: "person.2.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                        .help("Buddies on a break right now")
                }
            }

            Divider()

            StatusRow(icon: "eye", tint: .blue,
                      text: "Eye break in \(fmt(breaks.eyeBreakIn))")
            StatusRow(icon: "figure.walk", tint: .orange,
                      text: "Move break in \(fmt(breaks.movementBreakIn))")
            StatusRow(icon: "timer", tint: .purple, text: pomodoro.menuLabel)

            Divider()

            Button("Eye break now") { breaks.startEyeBreakNow() }
            Button("Movement break now") { breaks.startMovementBreakNow() }
            if pomodoro.phase == .idle {
                Button("Start pomodoro") { pomodoro.start() }
            } else if pomodoro.running {
                Button("Pause pomodoro") { pomodoro.pause() }
            } else {
                Button("Resume pomodoro") { pomodoro.resume() }
            }

            Divider()

            Button("Open dashboard") { openWindow(id: "dashboard") }
            Button("Quit Tether") { NSApplication.shared.terminate(nil) }
        }
        .padding(12)
        .frame(width: 280)
    }
}

private struct StatusRow: View {
    let icon: String
    let tint: Color
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(tint).frame(width: 20)
            Text(text).font(.callout)
        }
    }
}
