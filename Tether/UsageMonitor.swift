import Foundation
import AppKit
import ApplicationServices
import Combine

/// Optional awareness module: notices long stretches in AI assistants and AI
/// coding tools (ChatGPT, Claude, Codex, Cursor, Windsurf, OpenCode, …) and
/// surfaces a gentle pattern card.
///
/// Privacy contract: it reads the *frontmost app's name only* — never window
/// contents, never keystrokes. Off by default; requires Accessibility permission.
final class UsageMonitor: ObservableObject {
    @Published var enabled: Bool = false {
        didSet {
            var s: AppSettings = Store.load("settings", default: AppSettings())
            s.enableUsageMonitor = enabled
            Store.save(s, as: "settings")
            enabled ? start() : stop()
        }
    }
    @Published private(set) var aiMinutesToday = 0
    @Published private(set) var trusted = false

    /// Matched against the frontmost app's name (lowercased substring).
    /// AI chat assistants, AI coding tools, and the IDEs they're embedded in.
    private let keywords = [
        // AI chat assistants
        "chatgpt", "claude", "gemini", "copilot", "poe", "perplexity",
        "grok", "character.ai", "phind", "you.com", "hermes",
        // AI coding assistants (Codex, OpenCode, Claude Code, Cursor, …)
        "codex", "opencode", "cursor", "windsurf", "aider", "cody",
        "codeium", "tabnine", "v0", "replit", "bolt", "lovable",
        // IDEs (often AI-augmented)
        "visual studio code", "xcode",
    ]
    private var timer: Timer?
    private var day = todayKey()
    /// 5-second ticks spent in an AI app; minutes = ticks / 12.
    private var aiTicksToday = 0

    init() {
        let s: AppSettings = Store.load("settings", default: AppSettings())
        enabled = s.enableUsageMonitor
        aiTicksToday = Store.load("ai-\(todayKey())", default: 0)
        aiMinutesToday = aiTicksToday / 12
        if enabled { start() }
    }

    func requestTrust() {
        let opts = [kAXTrustedCheckOptionPrompt as String: true] as CFDictionary
        trusted = AXIsProcessTrustedWithOptions(opts)
    }

    var permissionGranted: Bool { AXIsProcessTrusted() }

    private func start() {
        requestTrust()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    private func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        if todayKey() != day {
            day = todayKey()
            aiTicksToday = 0
            aiMinutesToday = 0
        }
        guard AXIsProcessTrusted() else { return }
        let name = (NSWorkspace.shared.frontmostApplication?.localizedName ?? "").lowercased()
        if keywords.contains(where: { name.contains($0) }) {
            aiTicksToday += 1
            aiMinutesToday = aiTicksToday / 12
            Store.save(aiTicksToday, as: "ai-\(day)")
        }
    }
}
