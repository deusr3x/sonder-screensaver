import Cocoa
#if canImport(SonderSaverCore)
import SonderSaverCore
#endif

let app = NSApplication.shared
app.setActivationPolicy(.regular)

let delegate = AppDelegate()
app.delegate = delegate

app.run()
