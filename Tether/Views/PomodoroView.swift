import SwiftUI

/// Pomodoro tab: big timer, controls, configurable intervals.
struct PomodoroView: View {
    @EnvironmentObject var pomodoro: PomodoroEngine
    @EnvironmentObject var breaks: BreakEngine

    var body: some View {
        VStack(spacing: 20) {
            Text(pomodoro.phase.label)
                .font(.title2)
                .foregroundColor(.secondary)

            Text(pomodoro.phase == .idle ? fmt(configWorkDefault()) : fmt(pomodoro.remaining))
                .font(.system(size: 72, weight: .thin))
                .monospacedDigit()

            ProgressView(value: pomodoro.progress)
                .frame(width: 280)
                .tint(phaseColor)

            HStack(spacing: 24) {
                ForEach(0..<configRounds(), id: \.self) { i in
                    Circle()
                        .fill(i < pomodoro.completedSprints % max(1, configRounds())
                              ? Color.green : Color.gray.opacity(0.25))
                        .frame(width: 12, height: 12)
                }
            }

            HStack(spacing: 12) {
                if pomodoro.phase == .idle {
                    Button("Start") { pomodoro.start() }.buttonStyle(.borderedProminent)
                } else if pomodoro.running {
                    Button("Pause") { pomodoro.pause() }.buttonStyle(.bordered)
                } else {
                    Button("Resume") { pomodoro.resume() }.buttonStyle(.borderedProminent)
                }
                Button("Skip") { pomodoro.skip() }.buttonStyle(.bordered)
                Button("Reset") { pomodoro.reset() }.buttonStyle(.bordered)
            }

            Text("Completed sprints today: \(pomodoro.completedSprints)")
                .font(.footnote)
                .foregroundColor(.secondary)

            // Smits, Wenzel & de Bruin 2025 (RCT, N=94): strict 25/5 raised
            // fatigue faster than self-chosen breaks. Starting point, not dogma.
            Text("Research note: rigid 25/5 isn't magic — one RCT found it raised fatigue faster than self-chosen breaks. Adjust the intervals in Settings to your rhythm.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var phaseColor: Color {
        switch pomodoro.phase {
        case .work: return .purple
        case .shortBreak, .longBreak: return .green
        case .idle: return .gray
        }
    }

    private func configWorkDefault() -> Int { pomodoro.config.workMinutes * 60 }
    private func configRounds() -> Int { pomodoro.config.roundsBeforeLong }
}
