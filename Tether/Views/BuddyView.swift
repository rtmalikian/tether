import SwiftUI

/// Buddy tab: nearby accountability, nudges, shared IRL activities,
/// and the community pulse (mesh).
struct BuddyView: View {
    @EnvironmentObject var buddies: BuddyManager
    @EnvironmentObject var breaks: BreakEngine
    @State private var newActivity = ""
    @State private var withBuddy = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Community pulse
                GroupBox("Community pulse") {
                    VStack(alignment: .leading, spacing: 8) {
                        if buddies.buddiesOnBreak.isEmpty {
                            Text("No buddies on a break right now. Be the first — they'll see you.")
                                .font(.callout).foregroundColor(.secondary)
                        } else {
                            ForEach(buddies.buddiesOnBreak) { b in
                                Label("\(b.displayName) is on a break — join them?",
                                      systemImage: "leaf.fill")
                                    .foregroundColor(.green)
                            }
                        }
                        Text("Global pulse — how many people worldwide are on a break right now — arrives with the opt-in cloud service (see Roadmap in the README).")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    .padding(4)
                }

                // Connected buddies
                GroupBox("Buddies nearby (\(buddies.buddies.count))") {
                    if buddies.buddies.isEmpty {
                        Text("No buddies connected. Open Tether on a nearby Mac (same Wi-Fi) and you'll find each other automatically.")
                            .font(.callout).foregroundColor(.secondary)
                    } else {
                        ForEach(buddies.buddies) { b in
                            HStack {
                                Image(systemName: b.onBreak ? "leaf.fill" : "person.fill")
                                    .foregroundColor(b.onBreak ? .green : .secondary)
                                Text(b.displayName)
                                Spacer()
                                if b.onBreak {
                                    Text("on a break").font(.caption).foregroundColor(.green)
                                } else {
                                    Button("Nudge") { buddies.nudge(b) }
                                        .buttonStyle(.bordered)
                                        .controlSize(.small)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }

                // Touch grass together
                GroupBox("Touch grass together") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Log a real-world activity — a walk, a park, coffee outside. Shared activities keep you both honest.")
                            .font(.callout).foregroundColor(.secondary)
                        Text("Evidence tip: accountability works best with someone you know. In a year-long RCT, progress updates to a nominated friend or family member added 503 steps/day — grouping with strangers did nothing (Patel et al. 2021, JAMA Network Open).")
                            .font(.caption).foregroundColor(.secondary)
                        HStack {
                            TextField("What did you do? (e.g. 20-min park walk)", text: $newActivity)
                                .textFieldStyle(.roundedBorder)
                            TextField("With (optional)", text: $withBuddy)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 130)
                            Button("Log") {
                                let title = newActivity.trimmingCharacters(in: .whitespaces)
                                guard !title.isEmpty else { return }
                                let who = withBuddy.trimmingCharacters(in: .whitespaces)
                                buddies.logSharedActivity(title: title, with: who.isEmpty ? nil : who)
                                breaks.logOutdoorBreak(minutes: 20,
                                                       with: who.isEmpty ? nil : who)
                                newActivity = ""
                                withBuddy = ""
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newActivity.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                        if !buddies.sharedActivities.isEmpty {
                            Divider()
                            ForEach(buddies.sharedActivities.prefix(8)) { a in
                                HStack {
                                    Image(systemName: "tree.fill").foregroundColor(.green)
                                    Text(a.title)
                                    if let w = a.withBuddy {
                                        Text("with \(w)").foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Text(a.date, style: .date).font(.caption).foregroundColor(.secondary)
                                }
                                .font(.callout)
                            }
                        }
                    }
                    .padding(4)
                }

                // Feed
                if !buddies.feed.isEmpty {
                    GroupBox("Buddy feed") {
                        ForEach(buddies.feed.prefix(10), id: \.self) { line in
                            Text(line).font(.callout).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(16)
        }
    }
}
