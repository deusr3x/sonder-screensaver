import Foundation
import AppKit

// MARK: - Sonder Brand Palette
public struct SonderPalette {
    /// Sonder primary brand blue #2f5be9
    public static let blue = NSColor(srgbRed: 0x2f / 255.0, green: 0x5b / 255.0, blue: 0xe9 / 255.0, alpha: 1.0)
    
    /// Sonder navy #000f2e
    public static let navy = NSColor(srgbRed: 0x00 / 255.0, green: 0x0f / 255.0, blue: 0x2e / 255.0, alpha: 1.0)
    
    /// Sonder electric green #b2ff57
    public static let green = NSColor(srgbRed: 0xb2 / 255.0, green: 0xff / 255.0, blue: 0x57 / 255.0, alpha: 1.0)
    
    /// Sonder warm orange #ff9f6b
    public static let orange = NSColor(srgbRed: 0xff / 255.0, green: 0x9f / 255.0, blue: 0x6b / 255.0, alpha: 1.0)
    
    /// Sonder sky blue #bdeaff
    public static let sky = NSColor(srgbRed: 0xbd / 255.0, green: 0xea / 255.0, blue: 0xff / 255.0, alpha: 1.0)
    
    /// Sonder lime #dcfeb4
    public static let lime = NSColor(srgbRed: 0xdc / 255.0, green: 0xfe / 255.0, blue: 0xb4 / 255.0, alpha: 1.0)
    
    /// Pure black background
    public static let black = NSColor(srgbRed: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)

    /// Interpolates across multi-stop color gradients
    public static func interpolate(stops: [NSColor], t: CGFloat) -> NSColor {
        guard !stops.isEmpty else { return .white }
        if stops.count == 1 { return stops[0] }
        
        let clampedT = max(0.0, min(1.0, t))
        let totalSegments = CGFloat(stops.count - 1)
        let scaled = clampedT * totalSegments
        let index = min(Int(scaled), stops.count - 2)
        let fraction = scaled - CGFloat(index)
        
        let c1 = stops[index]
        let c2 = stops[index + 1]
        
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        
        c1.usingColorSpace(.sRGB)?.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        c2.usingColorSpace(.sRGB)?.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let r = r1 + (r2 - r1) * fraction
        let g = g1 + (g2 - g1) * fraction
        let b = b1 + (b2 - b1) * fraction
        let a = a1 + (a2 - a1) * fraction
        
        return NSColor(srgbRed: r, green: g, blue: b, alpha: a)
    }
}

// MARK: - Logo Glyph Model
public struct LogoGlyph: Identifiable, Sendable {
    public let id: Int
    public let character: Character
    public let row: Int
    public let col: Int
    
    /// Normalized coordinates (0.0 to 1.0) relative to the logo bounds
    public let normalizedX: CGFloat
    public let normalizedY: CGFloat
    
    /// Distance from emblem center (normalized)
    public let distanceFromEmblemCenter: CGFloat
    
    /// Distance from wordmark center (normalized)
    public let isWordmark: Bool
}

// MARK: - Logo Grid Layout
public final class SonderLogoData {
    public static let shared = SonderLogoData()
    
    public let lines: [String]
    public let rowCount: Int
    public let colCount: Int
    public let glyphs: [LogoGlyph]
    
    /// Estimated emblem center coordinates in grid units
    public let emblemCenter: CGPoint
    
    /// Embedded ASCII art as fallback guarantee
    public static let rawText: String = """
                        ▄▄█████████▄▄▄
                    ▄▄█████████████████▄▄
                  ▄████████▀▀▀  ▀▀▀███████▄
                ▄███████▀           ▀▀██████▄
               ▄██████▀       ▄        ▀█████▄
              ▀██████       █████▄       ▀█████
                ▀█████▄      ▀█████▄       ▀███▄
                  ▀█████▄      ▀█████▄       ▀██
             ▄      ▀█████▄      ▀█████▄       ▀
             ██▄      ▀█████▄      ▀█████▄
             ▀███▄      ▀█████▄      ▀█████▄
              █████▄      ▀█████▄      ▀█████▄
               ██████▄      ▀▀▀▀       ▄██████
                ███████▄             ▄███████
                 ▀███████▄▄       ▄████████▀
                   ▀█████████████████████▀
                      ▀▀█████████████▀▀
                            ▀▀▀▀▀

  ▄▄▄▄▄▄                                ▄██
▄███▀▀███                               ███
███▄   ▀▀   ▄██████▄  ██▄█████▄   ▄████████  ▄██████▄  ██▄███
 ▀█████▄▄  ███▀  ▀███ ███▀  ▀██  ███▀  ▀███ ███    ███ ███▀
 ▄   ▀▀███ ██     ███ ███    ██ ▀██     ███ ███▀███▀▀▀ ███
███▄▄▄▄███ ███▄▄▄▄██▀ ███    ██  ███▄▄▄▄███ ▀██▄▄▄▄██  ███
 ▀▀████▀▀   ▀▀████▀▀  ███    ██   ▀█████▀██  ▀▀████▀▀  ███
"""

    public init(customText: String? = nil) {
        let content = customText ?? SonderLogoData.loadLogoContent()
        let rawLines = content.components(separatedBy: .newlines)
        
        // Trim trailing empty lines
        var validLines = rawLines
        while let last = validLines.last, last.trimmingCharacters(in: .whitespaces).isEmpty {
            validLines.removeLast()
        }
        
        self.lines = validLines
        self.rowCount = max(1, validLines.count)
        
        var maxCols = 0
        for line in validLines {
            maxCols = max(maxCols, line.count)
        }
        self.colCount = max(1, maxCols)
        
        // Emblem center is roughly row 9, col 32
        let emblemRow: CGFloat = 8.5
        let emblemCol: CGFloat = 32.0
        self.emblemCenter = CGPoint(x: emblemCol, y: emblemRow)
        
        var items: [LogoGlyph] = []
        var nextId = 0
        
        for (r, line) in validLines.enumerated() {
            let chars = Array(line)
            let isWordmark = (r >= 19)
            
            for (c, ch) in chars.enumerated() {
                if ch != " " && ch != "\t" {
                    let normX = CGFloat(c) / CGFloat(max(1, self.colCount - 1))
                    let normY = CGFloat(r) / CGFloat(max(1, self.rowCount - 1))
                    
                    let dx = (CGFloat(c) - emblemCol) / 32.0
                    let dy = (CGFloat(r) - emblemRow) / 10.0
                    let distEmblem = sqrt(dx * dx + dy * dy)
                    
                    let glyph = LogoGlyph(
                        id: nextId,
                        character: ch,
                        row: r,
                        col: c,
                        normalizedX: normX,
                        normalizedY: normY,
                        distanceFromEmblemCenter: distEmblem,
                        isWordmark: isWordmark
                    )
                    items.append(glyph)
                    nextId += 1
                }
            }
        }
        
        self.glyphs = items
    }
    
    private static func loadLogoContent() -> String {
        if let bundle = Bundle(for: SonderLogoData.self).url(forResource: "sonder-logo", withExtension: "txt"),
           let text = try? String(contentsOf: bundle, encoding: .utf8), !text.isEmpty {
            return text
        }
        return rawText
    }
}
