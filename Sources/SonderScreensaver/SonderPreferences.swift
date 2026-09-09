import Foundation
import ScreenSaver

public enum SonderEffectType: String, CaseIterable, Identifiable, Codable {
    case cycleRandom = "cycle_random"
    case cycleSequential = "cycle_sequential"
    case matrix = "matrix"
    case synthgrid = "synthgrid"
    case pour = "pour"
    case waves = "waves"
    case smoke = "smoke"
    case slice = "slice"
    case unstable = "unstable"
    case scattered = "scattered"
    case sweep = "sweep"
    case rings = "rings"
    case middleout = "middleout"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .cycleRandom: return "Rotate (Random)"
        case .cycleSequential: return "Rotate (Sequential)"
        case .matrix: return "Matrix"
        case .synthgrid: return "Synthgrid"
        case .pour: return "Pour"
        case .waves: return "Waves"
        case .smoke: return "Smoke"
        case .slice: return "Slice"
        case .unstable: return "Unstable"
        case .scattered: return "Scattered"
        case .sweep: return "Sweep"
        case .rings: return "Rings"
        case .middleout: return "Middleout"
        }
    }
    
    public static var selectableEffects: [SonderEffectType] {
        return [.matrix, .synthgrid, .pour, .waves, .smoke, .slice, .unstable, .scattered, .sweep, .rings, .middleout]
    }
}

public enum BackgroundChoice: String, CaseIterable, Identifiable, Codable {
    case black = "black"
    case navy = "navy"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .black: return "Pure Black (#000000)"
        case .navy: return "Deep Navy (#000f2e)"
        }
    }
}

public final class SonderPreferences: ObservableObject {
    public static let shared = SonderPreferences()
    public static let moduleName = "com.sonder.screensaver"
    
    private let defaults: UserDefaults
    
    public init() {
        if let screenSaverDefaults = ScreenSaverDefaults(forModuleWithName: SonderPreferences.moduleName) {
            self.defaults = screenSaverDefaults
        } else {
            self.defaults = UserDefaults.standard
        }
    }
    
    // MARK: - Preference Keys
    private enum Keys {
        static let effect = "SonderSelectedEffect"
        static let speedMultiplier = "SonderSpeedMultiplier"
        static let neonGlowEnabled = "SonderNeonGlowEnabled"
        static let holdDuration = "SonderHoldDuration"
        static let backgroundChoice = "SonderBackgroundChoice"
    }
    
    public var effect: SonderEffectType {
        get {
            if let str = defaults.string(forKey: Keys.effect),
               let item = SonderEffectType(rawValue: str) {
                return item
            }
            return .cycleRandom
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.effect)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
    
    public var speedMultiplier: Double {
        get {
            let val = defaults.double(forKey: Keys.speedMultiplier)
            return val > 0 ? val : 1.0
        }
        set {
            defaults.set(newValue, forKey: Keys.speedMultiplier)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
    
    public var neonGlowEnabled: Bool {
        get {
            if defaults.object(forKey: Keys.neonGlowEnabled) != nil {
                return defaults.bool(forKey: Keys.neonGlowEnabled)
            }
            return true
        }
        set {
            defaults.set(newValue, forKey: Keys.neonGlowEnabled)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
    
    public var holdDuration: Double {
        get {
            let val = defaults.double(forKey: Keys.holdDuration)
            return val > 0 ? val : 4.0
        }
        set {
            defaults.set(newValue, forKey: Keys.holdDuration)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
    
    public var backgroundChoice: BackgroundChoice {
        get {
            if let str = defaults.string(forKey: Keys.backgroundChoice),
               let item = BackgroundChoice(rawValue: str) {
                return item
            }
            return .black
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.backgroundChoice)
            defaults.synchronize()
            objectWillChange.send()
        }
    }
}
