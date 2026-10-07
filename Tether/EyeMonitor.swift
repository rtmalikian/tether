import AVFoundation
import Vision
import Combine

/// Webcam blink-rate monitor — the honest, feasible slice of "eye tracking"
/// on a stock Mac. True gaze tracking needs dedicated hardware; what a webcam
/// *can* measure on-device is blink rate, and the evidence is strong: relaxed
/// blinking (~15–20/min) collapses to ~4–7/min during screen use, driving dry
/// eye (see README "The science").
///
/// How it works: AVFoundation grabs low-res frames, Vision finds face
/// landmarks on-device, and the eye-opening ratio (bounding-box height/width
/// of each eye's landmarks — no assumption about point ordering) detects
/// blinks. No video is ever stored or transmitted; the camera indicator light
/// stays on while tracking. Off by default and never auto-starts.
final class EyeMonitor: NSObject, ObservableObject {
    @Published var enabled = false {
        didSet {
            guard enabled != oldValue else { return }
            enabled ? start() : stop()
        }
    }
    @Published private(set) var status = "Off"
    @Published private(set) var blinksPerMinute: Double = 0

    private var session: AVCaptureSession?
    private let queue = DispatchQueue(label: "tether.eye")
    private var blinkTimes: [Date] = []
    private var baselineRatio: Double?
    private var closedFrames = 0
    private var lastBlink = Date.distantPast
    private var lastProcessed = Date.distantPast
    private var lowSince: Date?

    // MARK: - Lifecycle

    private func start() {
        status = "Requesting camera…"
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            guard let self else { return }
            DispatchQueue.main.async {
                if granted {
                    self.buildSession()
                } else {
                    self.status = "Camera access denied — enable it in System Settings → Privacy & Security → Camera."
                    self.enabled = false
                }
            }
        }
    }

    private func buildSession() {
        let session = AVCaptureSession()
        session.sessionPreset = .vga640x480 // landmarks don't need HD
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input)
        else {
            status = "No camera found."
            enabled = false
            return
        }
        session.addInput(input)
        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: queue)
        guard session.canAddOutput(output) else {
            status = "Couldn't start camera."
            enabled = false
            return
        }
        session.addOutput(output)
        self.session = session
        status = "Warming up…"
        queue.async { session.startRunning() }
    }

    private func stop() {
        queue.async { [weak self] in self?.session?.stopRunning() }
        session = nil
        status = "Off"
        lowSince = nil
    }

    // MARK: - Frame processing (background queue)

    private func handle(pixelBuffer: CVPixelBuffer) {
        let now = Date()
        guard now.timeIntervalSince(lastProcessed) > 0.12 else { return } // ~8 fps
        lastProcessed = now
        let request = VNDetectFaceLandmarksRequest { [weak self] req, _ in
            self?.handleLandmarks(request: req, at: now)
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .up,
                                            options: [:])
        try? handler.perform([request])
    }

    /// Eye openness as bounding-box height/width of the eye landmarks.
    /// Collapses toward 0 on a blink; no assumption about point ordering.
    private func openness(_ eye: VNFaceLandmarkRegion2D?) -> Double? {
        guard let pts = eye?.normalizedPoints, pts.count >= 4 else { return nil }
        let xs = pts.map(\.x), ys = pts.map(\.y)
        let w = (xs.max() ?? 0) - (xs.min() ?? 0)
        guard w > 0 else { return nil }
        return ((ys.max() ?? 0) - (ys.min() ?? 0)) / w
    }

    private func handleLandmarks(request: VNRequest, at now: Date) {
        guard let face = (request.results as? [VNFaceObservation])?.first,
              let lm = face.landmarks,
              let l = openness(lm.leftEye),
              let r = openness(lm.rightEye)
        else {
            DispatchQueue.main.async { [weak self] in
                if self?.enabled == true { self?.status = "No face detected" }
            }
            return
        }
        let ratio = (l + r) / 2
        // Slowly track the open-eye baseline; ignore closed-eye samples.
        if let base = baselineRatio {
            if ratio > base * 0.75 { baselineRatio = base * 0.98 + ratio * 0.02 }
        } else {
            baselineRatio = ratio
        }
        let base = baselineRatio ?? ratio

        if ratio < base * 0.55 {
            closedFrames += 1
        } else {
            // 1–6 closed frames at ~8fps ≈ a blink; debounce 350ms.
            if closedFrames >= 1, closedFrames <= 6,
               now.timeIntervalSince(lastBlink) > 0.35 {
                lastBlink = now
                blinkTimes.append(now)
            }
            closedFrames = 0
        }
        blinkTimes = blinkTimes.filter { now.timeIntervalSince($0) < 300 }
        let rate = Double(blinkTimes.count) / 5.0
        let lowRate = rate < 7 && blinkTimes.count >= 3

        DispatchQueue.main.async { [weak self] in
            guard let self, self.enabled else { return }
            self.blinksPerMinute = rate
            if lowRate {
                if self.lowSince == nil { self.lowSince = now }
                self.status = "Low blink rate — eye break suggested"
                // Nudge at most every 10 minutes of sustained low blinking.
                if now.timeIntervalSince(self.lowSince ?? now) > 600 {
                    self.lowSince = now
                    Notifications.post(
                        title: "Your blink rate is low",
                        body: "Blinking less dries your eyes out. Take a 20-second look-away break?")
                }
            } else {
                self.lowSince = nil
                self.status = String(format: "%.0f blinks/min — healthy", rate)
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension EyeMonitor: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let pb = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        handle(pixelBuffer: pb)
    }
}
