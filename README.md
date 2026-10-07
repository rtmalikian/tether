# Tether — macOS Screen Break Reminder, Pomodoro Timer & Buddy Accountability App

[![Build](https://github.com/rtmalikian/tether/actions/workflows/build.yml/badge.svg)](https://github.com/rtmalikian/tether/actions)
[![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)](https://github.com/rtmalikian/tether)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Privacy](https://img.shields.io/badge/privacy-100%25%20on--device-brightgreen)](https://github.com/rtmalikian/tether)

**Tether is a free, open-source macOS menu bar app for healthy screen breaks.** It reminds you to follow the **20-20-20 rule for eye strain relief**, take **30-minute movement breaks** away from your desk, work in focused **Pomodoro sprints**, check your **desk ergonomics**, and stay accountable with **buddies** — friends who take breaks with you and nudge you to go touch grass. Everything runs **on your Mac**: no accounts, no cloud, no tracking.

If you sit at a computer all day and want to reduce **digital eye strain**, **sedentary fatigue**, **neck and back discomfort**, and **burnout** — while actually getting more focused work done — Tether is the gentle tap on the shoulder you've been missing.

## ✨ Features

### 👁️ 20-20-20 eye break reminders
Every 20 minutes, a calm full-screen overlay counts down 20 seconds while you look at something 20 feet away — the standard guidance for **computer vision syndrome / digital eye strain** relief. One click skips it. Based on American Academy of Ophthalmology guidance.

### 🚶 Movement breaks every 30 minutes
Long unbroken sitting is linked to worse blood sugar control, higher blood pressure, and fatigue. Tether nudges you to stand, move, and hydrate every 30 minutes (configurable) — the interval with the strongest trial support: 5-minute light walks every 30 minutes blunted glucose spikes and lowered blood pressure in a randomized crossover trial (Duran et al. 2023). Being away from your keyboard for 5+ minutes counts as a natural break.

### 🍅 Pomodoro focus timer
Classic 25-minute focus sprints with 5-minute breaks and a long break every 4th sprint — all adjustable. Menu-bar countdown keeps you honest without a fullscreen takeover.

### 🤝 Buddy system (no accounts, no servers)
Buddies find each other automatically over your local Wi-Fi. See when a buddy starts a break, send a one-tap **"time to touch grass?"** nudge, and log real-world activities together — park walks, coffee outside, lunch away from the screen. Accountability to a real person beats willpower alone.

### 🌱 Community pulse (the mesh)
See how many of your buddies are on a break **right now** — a gentle social nudge. We're honest about the evidence: a large 2025 meta-analysis found social-norms messaging effects vanish after publication-bias adjustment, so we treat the pulse as motivation design, not medicine. A global opt-in pulse (how many people worldwide are breaking right now) is on the roadmap — labeled "coming soon" until the privacy-preserving backend exists.

### 📊 Feedback loops
A 2-tap daily check-in ("Did breaks help your focus today? How balanced did your day feel?") plus 7-day trends for focus and balance. The app shows you whether it's actually helping — no vanity metrics.

### 🧠 Optional AI-usage awareness
With your explicit Accessibility permission, Tether can note time spent in AI chat apps (frontmost app name only — **never** message contents, never keystrokes) and surface a gentle pattern card. Off by default.

## 🔬 The science behind Tether

Every default in Tether maps to published evidence. We prioritize **randomized controlled trials (RCTs), systematic reviews, and meta-analyses from the last five years (2021–2026)**, plus authoritative guidelines — and we're honest where the evidence is thin.

### 1. Microbreaks during computer work → the break engine
- **Albulescu et al. 2022** (PLOS ONE) — meta-analysis of 22 experimental samples (N=2,335): micro-breaks (≤10 min) significantly boosted vigor (d=0.36) and reduced fatigue (d=0.35). Overall performance effect was non-significant — breaks restore you; they don't magically raise output. https://pubmed.ncbi.nlm.nih.gov/36044424/
- **Radwan et al. 2022** (Cogent Psychology) — review of 6 controlled trials (N=232 office workers): short active microbreaks (2–3 min light exercise every 30 min) reduced musculoskeletal discomfort and fatigue with **no productivity loss**. https://www.tandfonline.com/doi/full/10.1080/23311916.2022.2026206

### 2. The 20-20-20 rule → the eye-break overlay
- **Talens-Estarelles et al. 2023** (Contact Lens & Anterior Eye) — field study (N=29 symptomatic computer users, webcam-verified reminders): 20-20-20 reminders significantly reduced digital eye strain and dry-eye symptoms — but gains faded a week after stopping, so the reminder needs to be a habit, not a one-off. https://pubmed.ncbi.nlm.nih.gov/35963776/
- **Redondo et al. 2025** (Experimental Eye Research) — repeated-measures experiment (N=24): breaks every 10 minutes or self-paced reduced eye irritation better than the rigid 20-20-20 schedule. → *Tether lets you shorten the interval.*
- **Singh et al. 2022** (Ophthalmology) — meta-analysis of 45 RCTs (N=4,497): no high-certainty evidence for any computer-vision-syndrome intervention yet; the break-based RCT base is limited. Honest caveat, included deliberately.
- **Guidelines:** The **American Academy of Ophthalmology** recommends the 20-20-20 rule; the **American Optometric Association** adds a 15-minute break per 2 hours of device use. https://www.aao.org/eye-health/tips-prevention/should-you-be-worried-about-blue-light

### 3. Timed work intervals → the Pomodoro timer
- **Biwer et al. 2023** (British Journal of Educational Psychology) — RCT (N=87): systematic break schedules reduced fatigue/distraction and raised concentration vs self-chosen breaks, with **the same output in less time**. https://pubmed.ncbi.nlm.nih.gov/36859717/
- **Smits, Wenzel & de Bruin 2025** (Behavioral Sciences) — RCT (N=94): strict 25/5 Pomodoro raised fatigue *faster* than self-regulated breaks; no productivity difference. → *Tether makes every interval adjustable — 25/5 is a starting point, not a prescription.*
- **Ogut et al. 2025** (BMC Medical Education) — scoping review of 32 studies: positive associations with focus/fatigue but moderate-to-low certainty overall. No published RCT tests 25/5 in office knowledge work — we say so openly.

### 4. Breaking up sedentary time → the movement break
- **Duran et al. 2023** (Medicine & Science in Sports & Exercise) — randomized crossover (N=11): 5-minute light walks every 30 minutes significantly blunted post-meal glucose spikes and lowered systolic blood pressure (~4–5 mmHg); also the largest fatigue reductions. https://pubmed.ncbi.nlm.nih.gov/36728338/
- **Gale et al. 2026** (Obesity Reviews) — meta-analysis of 53 acute RCTs: activity breaks <10 min lowered postprandial glucose and insulin; breaks every 15–20 min had the largest effects. https://pubmed.ncbi.nlm.nih.gov/42070794/
- **Kowalsky et al. 2021** (Workplace Health & Safety) — randomized crossover: hourly resistance-exercise breaks significantly reduced **mental fatigue** at hour 4 (d=0.37). https://pubmed.ncbi.nlm.nih.gov/33509068/
- **WHO Guidelines on Physical Activity and Sedentary Behaviour (2020, current):** "Adults should limit the amount of time spent being sedentary. Replacing sedentary time with physical activity of any intensity (including light intensity) provides health benefits." https://www.who.int/publications/i/item/9789240015128

### 5. Accountability partners → the buddy system
- **Patel et al. 2021 — iDiabetes** (JAMA Network Open) — 4-arm RCT (N=361, 1 year): participants whose **nominated family member/friend** got weekly progress updates walked **+503 steps/day** vs control, sustained all year. Being grouped with *strangers* did nothing. → *Tether's buddies are people you choose, not randoms.* https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8144928/
- **Takeda & Takatori 2022** (Clinical Rehabilitation) — pilot RCT (N=65): weekly 5–10 min buddy check-ins produced significantly more exercise days; benefits on outdoor walking persisted 12 weeks post-intervention. https://pubmed.ncbi.nlm.nih.gov/34825590/

### 6. Social proof + feedback loops → community pulse & check-ins
- **Krukowski et al. 2024** (Int J Behav Nutr Phys Act) — meta-analysis of 19 RCTs (N=3,261): self-monitoring interventions **with feedback** were significantly more effective than without (d=0.29). → *This is why the daily check-in and trends exist.* https://pmc.ncbi.nlm.nih.gov/articles/PMC10765525/
- **Papakonstantinou et al. 2025** (Nature Human Behaviour) — pre-registered meta-analysis of 89 RCTs (n=85,759): social-norms messaging effects **disappeared after publication-bias adjustment**. → *We treat the community pulse as engagement design, not an efficacy claim — and we say so.*

> **Bottom line:** frequent short breaks, breaking up sitting, feedback on self-monitored behavior, and accountability to chosen partners rest on solid recent RCT evidence. The exact 20-20-20 numbers and the 25/5 Pomodoro are sensible defaults with thinner direct support — which is why Tether makes them adjustable. No app — this one included — has clinical evidence of preventing harm; Tether is a wellness tool, not a medical device.

## 📥 Installation

### Build from source (recommended)
Requires a Mac with **Xcode 15+** (macOS 13+ SDK):

```bash
git clone https://github.com/rtmalikian/tether.git
cd tether
python3 generate_project.py   # generates Tether.xcodeproj
open Tether.xcodeproj         # build & run in Xcode (⌘R)
```

Or from the terminal:

```bash
xcodebuild -project Tether.xcodeproj -scheme Tether -configuration Release build CODE_SIGNING_ALLOWED=NO
# app appears at build/Release/Tether.app — drag it to /Applications
```

On first launch, Tether asks for:
1. **Notification permission** — for break reminders.
2. **Local network permission** — only if you enable buddy discovery.
3. **Accessibility permission** — only if you enable optional AI-usage awareness.

## 🔒 Privacy

- **100% on-device.** Break history, feedback, buddy names — all stored as encrypted JSON in `~/Library/Application Support/com.rtmalikian.tether/`. Nothing is uploaded, ever.
- **No accounts. No analytics. No ads.** The app makes zero network calls in v1 (buddy discovery uses your local network only).
- **Open source (MIT).** Don't trust the badge — read the code, or watch your firewall.
- **Reveal or delete your data** anytime from Settings.

## 🗺️ Roadmap

- **v1.1** — HealthKit sleep correlation, weekly reflection card, commitment mode (24-h delay before disabling), streak-free design review.
- **v2 — global mesh** — opt-in cloud pulse showing how many people worldwide are on a break right now. Needs a backend host decision and privacy review; the `BuddySyncProvider` seam in the code is where it plugs in.
- **Later** — iOS companion (Screen Time API), more languages, opt-in anonymized research data donation (consent-first).

## ❓ FAQ

**What is the 20-20-20 rule?**
Every 20 minutes, look at something at least 20 feet away for at least 20 seconds. It's the American Academy of Ophthalmology's standard guidance for digital eye strain from screens. Tether automates the remembering part.

**What's the best break reminder app for Mac?**
We built Tether because most break apps are dumb timers. Tether combines 20-20-20 eye breaks, movement breaks, a Pomodoro timer, buddy accountability, and feedback trends — all private and open-source.

**Does Tether work with the Pomodoro technique?**
Yes — 25/5 by default with a long break every 4 sprints, all configurable. (Heads-up from the research: rigid 25/5 isn't magic; adjust it to your rhythm.)

**Does Tether help with desk ergonomics?**
Yes — the Ergonomics tab covers screen distance and height, chair and posture, keyboard and wrist position, lighting, and break cadence, with a setup checklist. (Not medical advice — see a clinician for persistent pain.)

**Is my data sent anywhere?**
No. Everything stays on your Mac. Buddy discovery uses your local Wi-Fi only.

**Is Tether a medical device?**
No. It's a wellness tool. It doesn't diagnose, treat, or prevent any condition. If you're in distress, call or text **988** (US).

## 🤝 Contributing

Issues and PRs welcome. The codebase is small and readable — start with `Tether/BreakEngine.swift`. Please keep the tone calm and the privacy guarantees absolute.

## 📄 License

MIT — see [LICENSE](LICENSE).

## 👤 Author

**Raphael Malikian** — healthcare founder/operator (bootstrapped and ran a direct primary care clinic as CEO), now building clinical AI. Open to collaborate with anyone working on humane, evidence-led health tech — and currently seeking a clinical AI architect role. Find me at [github.com/rtmalikian](https://github.com/rtmalikian).
