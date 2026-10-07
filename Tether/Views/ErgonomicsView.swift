import SwiftUI

/// Ergonomics tab: evidence-informed desk setup guidance + a setup checklist.
/// Sources: American Optometric Association (screen breaks, viewing distance),
/// WHO Guidelines on Physical Activity and Sedentary Behaviour (2020).
struct ErgonomicsView: View {
    @State private var checks: [String: Bool] = Store.load("ergo-checks", default: [:])

    private let checklist = [
        ("screen-distance", "Screen about an arm's length away (50–70 cm)"),
        ("screen-height", "Top of the screen at or slightly below eye level"),
        ("glare", "No glare on the screen; screen brightness matches the room"),
        ("feet", "Feet flat on the floor (or a footrest), knees at ~90°"),
        ("back", "Lower back supported; shoulders relaxed, not hunched"),
        ("wrists", "Wrists straight and neutral; mouse close to the keyboard"),
        ("breaks", "20-20-20 eye breaks on, movement break every ≤30 min"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Ergonomics").font(.largeTitle).fontWeight(.bold)
                Text("Your best posture is your next posture — no position is good held for hours. Set up well, then let Tether's breaks do the rest.")
                    .font(.callout).foregroundColor(.secondary)

                GroupBox("Screen") {
                    ErgoTips(tips: [
                        "About an arm's length away (50–70 cm), top of the screen at or slightly below eye level.",
                        "Kill glare: no window or bright light reflecting off the screen; match screen brightness to the room.",
                        "Bump up text size instead of leaning in — leaning in is how necks get wrecked.",
                        "Every 20 minutes, look 20 feet away for 20 seconds (the 20-20-20 rule, per the American Academy of Ophthalmology).",
                    ])
                }

                GroupBox("Chair & posture") {
                    ErgoTips(tips: [
                        "Feet flat, knees at roughly 90°, lower back supported by the chair.",
                        "Shoulders relaxed and elbows near 90° — if your shoulders live by your ears, raise the chair or lower the desk.",
                        "Change position often. Stand, stretch, walk — Tether's movement break is the reminder.",
                    ])
                }

                GroupBox("Keyboard & mouse") {
                    ErgoTips(tips: [
                        "Wrists straight and neutral — not bent up or cocked sideways.",
                        "Keep the mouse close to the keyboard so you're not reaching all day.",
                        "Light touch: death-gripping the mouse is a fast track to forearm pain.",
                    ])
                }

                GroupBox("Breaks (the highest-leverage ergonomic)") {
                    ErgoTips(tips: [
                        "The American Optometric Association recommends a 15-minute break for every 2 hours of continuous device use.",
                        "WHO guidance: replace sedentary time with light-intensity activity through the day — it all counts.",
                        "5-minute light walks every 30 minutes blunted blood-sugar spikes and lowered blood pressure in a randomized crossover trial (Duran et al. 2023) — that's Tether's default movement-break cadence.",
                    ])
                }

                GroupBox("Desk setup checklist") {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(checklist, id: \.0) { id, label in
                            Toggle(isOn: Binding(
                                get: { checks[id] ?? false },
                                set: {
                                    checks[id] = $0
                                    Store.save(checks, as: "ergo-checks")
                                }
                            )) {
                                Text(label).font(.callout)
                            }
                            .toggleStyle(.checkbox)
                        }
                        if checklist.allSatisfy({ checks[$0.0] ?? false }) {
                            Label("Desk certified. Now go touch grass.", systemImage: "checkmark.seal.fill")
                                .foregroundColor(.green)
                                .font(.callout)
                                .padding(.top, 4)
                        }
                    }
                    .padding(4)
                }

                Text("Not medical advice. If you have persistent pain, numbness, or vision changes, see a clinician — ideally one who'll ask about your setup.")
                    .font(.caption).foregroundColor(.secondary)
            }
            .padding(16)
        }
    }
}

private struct ErgoTips: View {
    let tips: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(tips, id: \.self) { tip in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "checkmark.circle").foregroundColor(.green)
                    Text(tip).font(.callout)
                }
            }
        }
        .padding(4)
    }
}
