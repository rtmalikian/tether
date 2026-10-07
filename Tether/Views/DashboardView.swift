import SwiftUI

/// Main dashboard window: Today / Pomodoro / Buddies / Ergonomics / Insights / Settings.
struct DashboardView: View {
    @EnvironmentObject var breaks: BreakEngine
    @EnvironmentObject var pomodoro: PomodoroEngine
    @EnvironmentObject var buddies: BuddyManager
    @EnvironmentObject var feedback: FeedbackStore
    @EnvironmentObject var usage: UsageMonitor

    var body: some View {
        TabView {
            TodayView()
                .tabItem { Label("Today", systemImage: "sun.max") }
            PomodoroView()
                .tabItem { Label("Pomodoro", systemImage: "timer") }
            BuddyView()
                .tabItem { Label("Buddies", systemImage: "person.2") }
            ErgonomicsView()
                .tabItem { Label("Ergonomics", systemImage: "chair") }
            InsightsView()
                .tabItem { Label("Insights", systemImage: "chart.bar") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gear") }
        }
        .padding(8)
        .frame(minWidth: 700, minHeight: 520)
    }
}

// MARK: - Today

private struct TodayView: View {
    @EnvironmentObject var breaks: BreakEngine
    @EnvironmentObject var pomodoro: PomodoroEngine
    @EnvironmentObject var buddies: BuddyManager
    @EnvironmentObject var usage: UsageMonitor

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Today").font(.largeTitle).fontWeight(.bold)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()),
                                    GridItem(.flexible()), GridItem(.flexible())],
                          spacing: 12) {
                    StatCard(title: "Active screen time", value: fmt(breaks.activeSecondsToday),
                             icon: "display", tint: .blue)
                    StatCard(title: "Breaks taken", value: "\(breaks.breaksTakenToday)",
                             icon: "leaf", tint: .green)
                    StatCard(title: "Eye breaks", value: "\(breaks.eyeBreaksToday)",
                             icon: "eye", tint: .teal)
                    StatCard(title: "Pomodoros", value: "\(pomodoro.completedSprints)",
                             icon: "timer", tint: .purple)
                }

                GroupBox("Up next") {
                    VStack(alignment: .leading, spacing: 8) {
                        BreakProgressRow(icon: "eye", label: "Eye break",
                                         remaining: breaks.eyeBreakIn,
                                         total: breaks.settings.eyeBreakMinutes * 60,
                                         tint: .blue)
                        BreakProgressRow(icon: "figure.walk", label: "Movement break",
                                         remaining: breaks.movementBreakIn,
                                         total: breaks.settings.movementBreakMinutes * 60,
                                         tint: .orange)
                    }
                    .padding(4)
                }

                HStack {
                    Button("Eye break now") { breaks.startEyeBreakNow() }
                        .buttonStyle(.borderedProminent)
                    Button("Move break now") { breaks.startMovementBreakNow() }
                        .buttonStyle(.bordered)
                    Button(buddies.buddies.isEmpty ? "Find buddies" : "Announce break to buddies") {
                        buddies.announceBreakStart()
                    }
                    .buttonStyle(.bordered)
                }

                if usage.enabled {
                    GroupBox("AI time today") {
                        Text("\(usage.aiMinutesToday) min in AI apps today. Long, late sessions are the pattern to watch — not the minutes themselves.")
                            .font(.callout).foregroundColor(.secondary)
                            .padding(4)
                    }
                }
            }
            .padding(16)
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon).foregroundColor(tint).font(.title2)
            Text(value).font(.title2).fontWeight(.semibold).monospacedDigit()
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(10)
    }
}

private struct BreakProgressRow: View {
    let icon: String
    let label: String
    let remaining: Int
    let total: Int
    let tint: Color

    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(tint).frame(width: 24)
            Text(label).frame(width: 130, alignment: .leading)
            ProgressView(value: Double(total - remaining), total: Double(max(1, total)))
                .tint(tint)
            Text(fmt(remaining)).font(.callout).monospacedDigit().frame(width: 52, alignment: .trailing)
        }
    }
}

// MARK: - Insights

private struct InsightsView: View {
    @EnvironmentObject var feedback: FeedbackStore
    @State private var focus = 3
    @State private var balance = 3
    @State private var note = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Insights").font(.largeTitle).fontWeight(.bold)

                // Daily check-in
                GroupBox("Daily check-in") {
                    if feedback.todayEntry == nil {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Did taking breaks help your focus today?")
                                .font(.callout)
                            Picker("", selection: $focus) {
                                ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                            }.pickerStyle(.segmented)
                            Text("How balanced did your day feel?")
                                .font(.callout)
                            Picker("", selection: $balance) {
                                ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                            }.pickerStyle(.segmented)
                            TextField("Note (optional)", text: $note)
                                .textFieldStyle(.roundedBorder)
                            Button("Save check-in") {
                                feedback.save(focus: focus, balance: balance, note: note)
                                note = ""
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        .padding(4)
                    } else {
                        Text("Check-in saved. Come back tomorrow — trends build over weeks, not days.")
                            .font(.callout).foregroundColor(.secondary).padding(4)
                    }
                }

                // 7-day trends
                GroupBox("Last 7 days") {
                    VStack(spacing: 10) {
                        TrendRow(label: "Focus", color: .purple,
                                 values: feedback.last7Days().map(\.focus))
                        TrendRow(label: "Balance", color: .green,
                                 values: feedback.last7Days().map(\.balance))
                    }
                    .padding(4)
                }

                // Why this works
                GroupBox("Why breaks work") {
                    VStack(alignment: .leading, spacing: 6) {
                        ScienceBullet("Brief breaks from continuous computer work cut fatigue and musculoskeletal discomfort — and don't cost productivity.")
                        ScienceBullet("The 20-20-20 rule (every 20 min, look 20 ft away, 20 sec) is the standard guidance for digital eye strain.")
                        ScienceBullet("Breaking up long sitting with short movement snacks improves blood sugar and blood pressure control.")
                        ScienceBullet("Accountability partners measurably improve follow-through on health habits.")
                        Text("Full citations: see the README's research section.")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(4)
                }
            }
            .padding(16)
        }
    }
}

private struct TrendRow: View {
    let label: String
    let color: Color
    let values: [Double]

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            Text(label).frame(width: 60, alignment: .leading).font(.callout)
            ForEach(values.indices, id: \.self) { i in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(values[i] > 0 ? color : Color.gray.opacity(0.15))
                        .frame(width: 22, height: max(4, values[i] / 5.0 * 60))
                }
                .frame(height: 64)
            }
            Spacer()
        }
    }
}

private struct ScienceBullet: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
            Text(text).font(.callout)
        }
    }
}
