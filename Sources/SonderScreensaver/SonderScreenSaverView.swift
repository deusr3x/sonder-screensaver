import Foundation
import AppKit
import ScreenSaver

@objc(SonderScreenSaverView)
public class SonderScreenSaverView: ScreenSaverView {
    public static let newInstanceNotification = Notification.Name("com.sonder.screensaver.NewInstance")
    
    public let engine = SonderEngine()
    private var lastFrameTime: CFTimeInterval = 0.0
    private var isLameDuck = false
    private var willStopObserver: NSObjectProtocol?
    private var configureSheetController: ConfigurationSheetController?
    private var fallbackTimer: Timer?
    
    // MARK: - Initializers
    public override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    public override var isFlipped: Bool {
        return true
    }
    
    // MARK: - Setup & Lifecycle
    private func setup() {
        self.animationTimeInterval = 1.0 / 60.0
        self.wantsLayer = true
        self.layer?.backgroundColor = SonderPalette.black.cgColor
        
        // Notify any older instances in the same process to become passive (lame-duck fix)
        NotificationCenter.default.post(name: SonderScreenSaverView.newInstanceNotification, object: self)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewInstance(_:)),
            name: SonderScreenSaverView.newInstanceNotification,
            object: nil
        )
        
        // Register for willStop distributed notification (macOS Sonoma / Tahoe fix)
        willStopObserver = DistributedNotificationCenter.default().addObserver(
            forName: Notification.Name("com.apple.screensaver.willstop"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleWillStop()
        }
    }
    
    @objc private func handleNewInstance(_ notification: Notification) {
        guard let sender = notification.object as? SonderScreenSaverView, sender !== self else { return }
        isLameDuck = true
        stopAnimation()
        removeFromSuperview()
        cleanup()
    }
    
    private func handleWillStop() {
        stopAnimation()
        let bundleId = Bundle.main.bundleIdentifier ?? ""
        // Only exit if running as the actual system screensaver inside ScreenSaverEngine / legacyScreenSaver
        if (bundleId.contains("ScreenSaver") || bundleId.contains("legacyScreenSaver")) && !bundleId.contains("preview") && !isPreview {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                exit(0)
            }
        }
    }
    
    // MARK: - Animation
    public override func startAnimation() {
        guard !isLameDuck else { return }
        super.startAnimation()
        lastFrameTime = CACurrentMediaTime()
        
        // In case macOS fails to call animateOneFrame, maintain a fallback timer
        if fallbackTimer == nil {
            fallbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
                self?.stepFrame()
            }
            if let timer = fallbackTimer {
                RunLoop.main.add(timer, forMode: .common)
            }
        }
    }
    
    public override func stopAnimation() {
        super.stopAnimation()
        fallbackTimer?.invalidate()
        fallbackTimer = nil
    }
    
    public override func animateOneFrame() {
        stepFrame()
    }
    
    private func stepFrame() {
        guard !isLameDuck else { return }
        let now = CACurrentMediaTime()
        let dt = (lastFrameTime > 0) ? min(0.1, max(0.001, now - lastFrameTime)) : (1.0 / 60.0)
        lastFrameTime = now
        
        engine.advance(deltaTime: dt)
        needsDisplay = true
    }
    
    // MARK: - Drawing
    public override func draw(_ rect: NSRect) {
        guard !isLameDuck, let context = NSGraphicsContext.current?.cgContext else { return }
        engine.draw(in: context, size: bounds.size)
    }
    
    // MARK: - Preferences Sheet
    public override var hasConfigureSheet: Bool {
        return true
    }
    
    public override var configureSheet: NSWindow? {
        configureSheetController = ConfigurationSheetController()
        return configureSheetController?.window
    }
    
    private func cleanup() {
        fallbackTimer?.invalidate()
        fallbackTimer = nil
        if let obs = willStopObserver {
            DistributedNotificationCenter.default().removeObserver(obs)
            willStopObserver = nil
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        cleanup()
    }
}
