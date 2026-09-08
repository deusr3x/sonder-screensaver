import SwiftUI
import AppKit

public struct ConfigurationView: View {
    @ObservedObject var preferences = SonderPreferences.shared
    public var onClose: (() -> Void)?
    
    public init(onClose: (() -> Void)? = nil) {
        self.onClose = onClose
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 12) {
                // Sonder logo emblem mini icon
                Text("✦")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(Color(nsColor: SonderPalette.green))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sonder Screen Saver")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Native Swift animated ASCII brand screensaver")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // Settings Form
            Form {
                Picker("Effect Animation:", selection: $preferences.effect) {
                    Text("Rotate (Random)").tag(SonderEffectType.cycleRandom)
                    Text("Rotate (Sequential)").tag(SonderEffectType.cycleSequential)
                    Divider()
                    ForEach(SonderEffectType.selectableEffects) { eff in
                        Text(eff.displayName).tag(eff)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("Animation Speed:", selection: Binding(
                    get: { preferences.speedMultiplier },
                    set: { preferences.speedMultiplier = $0 }
                )) {
                    Text("Gentle (0.75x)").tag(0.75)
                    Text("Normal (1.0x)").tag(1.0)
                    Text("Fast (1.35x)").tag(1.35)
                    Text("Rapid (1.75x)").tag(1.75)
                }
                .pickerStyle(.segmented)
                
                Picker("Hold Duration:", selection: Binding(
                    get: { preferences.holdDuration },
                    set: { preferences.holdDuration = $0 }
                )) {
                    Text("2s").tag(2.0)
                    Text("4s (Default)").tag(4.0)
                    Text("6s").tag(6.0)
                    Text("10s").tag(10.0)
                }
                .pickerStyle(.segmented)
                
                Picker("Background:", selection: $preferences.backgroundChoice) {
                    ForEach(BackgroundChoice.allCases) { bg in
                        Text(bg.displayName).tag(bg)
                    }
                }
                
                Toggle("Enable Neon Bloom / Glow Effect", isOn: $preferences.neonGlowEnabled)
                    .help("Adds a soft blurred luminescence to the active Sonder glyphs.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            // Footer
            HStack {
                Text("Sonder Brand: #2f5be9 • #b2ff57 • #ff9f6b")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Done") {
                    onClose?()
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 440)
    }
}

// MARK: - Configuration Sheet Controller for ScreenSaverView
public final class ConfigurationSheetController: NSObject {
    public private(set) var window: NSWindow?
    private var hostingController: NSHostingController<ConfigurationView>?
    
    public override init() {
        super.init()
        setupWindow()
    }
    
    private func setupWindow() {
        let view = ConfigurationView { [weak self] in
            self?.close()
        }
        
        hostingController = NSHostingController(rootView: view)
        window = NSWindow(contentViewController: hostingController!)
        window?.title = "Sonder Screen Saver Preferences"
        window?.styleMask = [.titled, .closable]
        window?.isReleasedWhenClosed = false
        window?.center()
    }
    
    public func close() {
        if let sheetParent = window?.sheetParent {
            sheetParent.endSheet(window!)
        } else {
            window?.close()
        }
    }
}
