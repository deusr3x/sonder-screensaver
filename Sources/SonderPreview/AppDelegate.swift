import Cocoa
import SwiftUI
#if canImport(SonderSaverCore)
import SonderSaverCore
#endif

final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private var window: NSWindow?
    private var screenSaverView: SonderScreenSaverView?
    private var statusLabel: NSTextField?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        setupWindow()
    }
    
    private func setupMenu() {
        let mainMenu = NSMenu()
        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "About Sonder Screensaver", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(NSMenuItem.separator())
        appMenu.addItem(withTitle: "Quit Sonder Preview", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu
        
        NSApp.mainMenu = mainMenu
    }
    
    private func setupWindow() {
        let isFullScreenRequested = CommandLine.arguments.contains("--fullscreen") || CommandLine.arguments.contains("-f")
        
        let initialRect = NSRect(x: 100, y: 100, width: 1000, height: 650)
        let window = NSWindow(
            contentRect: initialRect,
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Sonder Screensaver Preview"
        window.backgroundColor = SonderPalette.black
        window.isOpaque = true
        window.center()
        window.delegate = self
        
        let container = NSView(frame: window.contentView!.bounds)
        container.autoresizingMask = [.width, .height]
        container.wantsLayer = true
        container.layer?.backgroundColor = SonderPalette.black.cgColor
        window.contentView = container
        
        // Initialize screensaver view
        let saverView = SonderScreenSaverView(frame: container.bounds, isPreview: false) ?? SonderScreenSaverView()
        saverView.autoresizingMask = [.width, .height]
        container.addSubview(saverView)
        self.screenSaverView = saverView
        saverView.startAnimation()
        
        // Overlay HUD text field
        let label = NSTextField(labelWithString: "Effect: \(saverView.engine.currentEffect.displayName)  [Space: Next | 1-0: Select | F: Fullscreen | C: Options | Esc: Exit]")
        label.font = NSFont.monospacedSystemFont(ofSize: 11, weight: .medium)
        label.textColor = NSColor.white.withAlphaComponent(0.70)
        label.backgroundColor = NSColor.black.withAlphaComponent(0.65)
        label.isBezeled = false
        label.isEditable = false
        label.sizeToFit()
        
        label.frame.origin = CGPoint(x: 16, y: 12)
        label.autoresizingMask = [.maxXMargin, .maxYMargin]
        container.addSubview(label)
        self.statusLabel = label
        
        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        if isFullScreenRequested {
            window.toggleFullScreen(nil)
        }
        
        // Monitor key events
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if self?.handleKeyDown(event) == true {
                return nil
            }
            return event
        }
    }
    
    private func handleKeyDown(_ event: NSEvent) -> Bool {
        guard let chars = event.charactersIgnoringModifiers, let saver = screenSaverView else { return false }
        
        switch chars {
        case " ":
            saver.engine.triggerNextEffect()
            updateStatus()
            return true
        case "f", "F":
            window?.toggleFullScreen(nil)
            return true
        case "c", "C":
            if let sheet = saver.configureSheet, let win = window {
                win.beginSheet(sheet)
            }
            return true
        case "q", "Q", "\u{1b}": // Esc or Q
            NSApp.terminate(nil)
            return true
        case "1":
            saver.engine.setSpecificEffect(.synthgrid)
            updateStatus()
            return true
        case "2":
            saver.engine.setSpecificEffect(.pour)
            updateStatus()
            return true
        case "3":
            saver.engine.setSpecificEffect(.waves)
            updateStatus()
            return true
        case "4":
            saver.engine.setSpecificEffect(.smoke)
            updateStatus()
            return true
        case "5":
            saver.engine.setSpecificEffect(.slice)
            updateStatus()
            return true
        case "6":
            saver.engine.setSpecificEffect(.unstable)
            updateStatus()
            return true
        case "7":
            saver.engine.setSpecificEffect(.scattered)
            updateStatus()
            return true
        case "8":
            saver.engine.setSpecificEffect(.sweep)
            updateStatus()
            return true
        case "9":
            saver.engine.setSpecificEffect(.rings)
            updateStatus()
            return true
        case "0":
            saver.engine.setSpecificEffect(.middleout)
            updateStatus()
            return true
        default:
            return false
        }
    }
    
    private func updateStatus() {
        guard let saver = screenSaverView, let label = statusLabel else { return }
        label.stringValue = "Effect: \(saver.engine.currentEffect.displayName)  [Space: Next | 1-0: Select | F: Fullscreen | C: Options | Esc: Exit]"
        label.sizeToFit()
    }
    
    func windowWillClose(_ notification: Notification) {
        screenSaverView?.stopAnimation()
        NSApp.terminate(nil)
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}
