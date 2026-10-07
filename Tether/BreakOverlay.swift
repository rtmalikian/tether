import SwiftUI
import AppKit

/// Full-screen gentle overlay for eye / movement breaks.
/// Non-activating: it never steals keyboard focus. Click anywhere to skip.
final class BreakOverlayModel: ObservableObject {
    @Published var remaining: Int
    let total: Int
    let title: String
    let message: String
    var onDone: (() -> Void)?

    private var timer: Timer?

    init(seconds: Int, title: String, message: String) {
        self.remaining = seconds
        self.total = seconds
        self.title = title
        self.message = message
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            if self.remaining > 0 {
                self.remaining -= 1
            } else {
                self.dismiss()
            }
        }
    }

    func dismiss() {
        timer?.invalidate()
        timer = nil
        onDone?()
    }
}

struct BreakOverlayView: View {
    @ObservedObject var model: BreakOverlayModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture { model.dismiss() }
            VStack(spacing: 18) {
                Text(model.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text(model.message)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 60)
                Text("\(model.remaining)")
                    .font(.system(size: 72, weight: .thin))
                    .monospacedDigit()
                    .foregroundColor(.white)
                ProgressView(value: Double(model.total - model.remaining),
                             total: Double(max(1, model.total)))
                    .frame(width: 240)
                    .tint(.green)
                Text("Click anywhere to skip")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

enum BreakOverlay {
    private static var window: NSWindow?

    static func show(seconds: Int, title: String, message: String) {
        hide()
        guard let screen = NSScreen.main else { return }
        let model = BreakOverlayModel(seconds: seconds, title: title, message: message)
        let panel = NSPanel(contentRect: screen.frame,
                            styleMask: [.borderless, .nonactivatingPanel],
                            backing: .buffered,
                            defer: false)
        panel.contentView = NSHostingView(rootView: BreakOverlayView(model: model))
        panel.level = .screenSaver
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        model.onDone = { hide() }
        window = panel
        panel.orderFrontRegardless()
    }

    static func hide() {
        window?.orderOut(nil)
        window = nil
    }
}
