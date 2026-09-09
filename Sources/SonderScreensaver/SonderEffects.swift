import Foundation
import AppKit

public struct RenderGlyph {
    public var character: Character
    public var x: CGFloat
    public var y: CGFloat
    public var color: NSColor
    public var alpha: CGFloat
    public var scale: CGFloat
    public var glowIntensity: CGFloat
    
    public init(
        character: Character,
        x: CGFloat,
        y: CGFloat,
        color: NSColor,
        alpha: CGFloat = 1.0,
        scale: CGFloat = 1.0,
        glowIntensity: CGFloat = 1.0
    ) {
        self.character = character
        self.x = x
        self.y = y
        self.color = color
        self.alpha = alpha
        self.scale = scale
        self.glowIntensity = glowIntensity
    }
}

public final class SonderEffects {
    private static let matrixChars: [Character] = ["0", "1", "X", "+", "░", "▒", "▓", "▄", "█", "▀", "/"]
    
    /// Computes the active render state of all glyphs for a given effect and animation progress
    public static func renderEffect(
        type: SonderEffectType,
        progress: CGFloat,
        elapsedTime: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let actualEffect: SonderEffectType
        if type == .cycleRandom || type == .cycleSequential {
            actualEffect = .synthgrid
        } else {
            actualEffect = type
        }
        
        switch actualEffect {
        case .matrix:
            return renderMatrix(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .synthgrid:
            return renderSynthGrid(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .pour:
            return renderPour(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .waves:
            return renderWaves(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .smoke:
            return renderSmoke(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .slice:
            return renderSlice(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .unstable:
            return renderUnstable(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .scattered:
            return renderScattered(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .sweep:
            return renderSweep(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .rings:
            return renderRings(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        case .middleout:
            return renderMiddleOut(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        default:
            return renderSynthGrid(progress: progress, elapsed: elapsedTime, logoData: logoData, cellWidth: cellWidth, cellHeight: cellHeight, gridOrigin: gridOrigin, canvasSize: canvasSize)
        }
    }
    
    // MARK: - 1. SynthGrid
    private static func renderSynthGrid(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.green, SonderPalette.orange]
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.65 + glyph.normalizedY * 0.35)
            
            let decodeThreshold = 0.20 + 0.60 * (glyph.normalizedX * 0.6 + glyph.normalizedY * 0.4)
            
            if progress < 0.10 {
                let p = progress / 0.10
                let alpha = max(0.0, p * (CGFloat((glyph.id * 31) % 100) / 100.0))
                let ch = matrixChars[(glyph.id + Int(elapsed * 24.0)) % matrixChars.count]
                return RenderGlyph(character: ch, x: homeX, y: homeY, color: SonderPalette.green, alpha: alpha, scale: 0.9, glowIntensity: 1.4)
            } else if progress < decodeThreshold {
                let ch = matrixChars[(glyph.id + Int(elapsed * 20.0)) % matrixChars.count]
                let color = (glyph.id % 2 == 0) ? SonderPalette.blue : SonderPalette.green
                return RenderGlyph(character: ch, x: homeX, y: homeY, color: color, alpha: 0.85, scale: 1.0, glowIntensity: 1.3)
            } else {
                let settleT = min(1.0, (progress - decodeThreshold) / 0.20)
                let flash = (1.0 - settleT) * 1.5
                let color = NSColor.white.blended(withFraction: 1.0 - (1.0 - settleT) * 0.8, of: targetColor) ?? targetColor
                return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: color, alpha: 1.0, scale: 1.0 + flash * 0.25, glowIntensity: 1.0 + flash)
            }
        }
    }
    
    // MARK: - 2. Pour
    private static func renderPour(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.green, SonderPalette.orange]
        let startY = -cellHeight * 6.0
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.6 + glyph.normalizedY * 0.4)
            
            let colProgress = CGFloat(glyph.col) / CGFloat(logoData.colCount)
            let jitter = (CGFloat((glyph.id * 43) % 100) / 100.0) * 0.15
            let delay = colProgress * 0.45 + jitter
            
            let localT = max(0.0, min(1.0, (progress - delay) / max(0.001, (1.0 - delay))))
            
            if localT <= 0.0 {
                return RenderGlyph(character: glyph.character, x: homeX, y: startY, color: SonderPalette.blue, alpha: 0.0)
            }
            
            var curY: CGFloat
            var curScale: CGFloat = 1.0
            if localT < 0.70 {
                let dropT = localT / 0.70
                let eased = dropT * dropT * dropT
                curY = startY + (homeY - startY) * eased
            } else {
                let bounceT = (localT - 0.70) / 0.30
                let damp = exp(-bounceT * 4.0)
                let bounce = sin(bounceT * .pi * 2.5) * damp * cellHeight * 1.6
                curY = homeY - bounce
                curScale = 1.0 + bounce / (cellHeight * 2.0)
            }
            
            let alpha = min(1.0, localT * 2.0)
            let color = SonderPalette.blue.blended(withFraction: localT, of: targetColor) ?? targetColor
            return RenderGlyph(character: glyph.character, x: homeX, y: curY, color: color, alpha: alpha, scale: curScale, glowIntensity: 1.0 + (1.0 - localT) * 0.5)
        }
    }
    
    // MARK: - 3. Waves
    private static func renderWaves(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.sky, SonderPalette.green]
        let wavePhase = CGFloat(elapsed * 4.0)
        let decay = pow(1.0 - progress, 1.8)
        let waveAmpY = cellHeight * 2.4 * decay
        let waveAmpX = cellWidth * 1.2 * decay
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            
            let offsetX = sin(CGFloat(glyph.row) * 0.45 + wavePhase) * waveAmpX
            let offsetY = cos(CGFloat(glyph.col) * 0.32 + wavePhase) * waveAmpY
            
            let colorT = fmod(glyph.normalizedX * 0.8 + CGFloat(elapsed * 0.4), 1.0)
            let dynamicColor = SonderPalette.interpolate(stops: stops, t: colorT)
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX)
            let finalColor = dynamicColor.blended(withFraction: progress, of: targetColor) ?? targetColor
            
            let alpha = min(1.0, progress * 4.0 + 0.2)
            return RenderGlyph(character: glyph.character, x: homeX + offsetX, y: homeY + offsetY, color: finalColor, alpha: alpha, scale: 1.0 + decay * 0.15, glowIntensity: 1.0 + decay * 0.6)
        }
    }
    
    // MARK: - 4. Smoke
    private static func renderSmoke(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.navy]
        let invertProgress = 1.0 - progress
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            
            let seed = Double(glyph.id * 101)
            let angle = seed.truncatingRemainder(dividingBy: 6.28318)
            let radius = invertProgress * (CGFloat(glyph.id % 200) + 120.0)
            let curl = sin(CGFloat(elapsed * 2.0) + CGFloat(glyph.id % 10)) * 25.0 * invertProgress
            
            let curX = homeX + cos(CGFloat(angle)) * radius + curl
            let curY = homeY + sin(CGFloat(angle)) * radius + curl
            
            let alpha = max(0.05, min(1.0, 0.2 + progress * 0.8))
            let color = SonderPalette.interpolate(stops: stops, t: glyph.normalizedY)
            let brightened = color.blended(withFraction: progress, of: SonderPalette.blue) ?? color
            
            return RenderGlyph(character: glyph.character, x: curX, y: curY, color: brightened, alpha: alpha, scale: 1.0 + invertProgress * 0.4, glowIntensity: 1.0 + invertProgress * 0.8)
        }
    }
    
    // MARK: - 5. Slice
    private static func renderSlice(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.green, SonderPalette.orange]
        let sliceIndex = glyphSliceIndex(rowCount: logoData.rowCount)
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.7 + glyph.normalizedY * 0.3)
            
            let sIdx = sliceIndex(glyph.row)
            let isEven = (sIdx % 2 == 0)
            let travelDist = canvasSize.width * 0.85
            let startX = isEven ? (homeX - travelDist) : (homeX + travelDist)
            
            let delay = CGFloat(sIdx) * 0.05
            let localT = max(0.0, min(1.0, (progress - delay) / max(0.001, 1.0 - delay)))
            
            let eased = 1.0 - pow(1.0 - localT, 3.0)
            let curX = startX + (homeX - startX) * eased
            
            let alpha = min(1.0, localT * 2.5)
            let trailGlow = (1.0 - localT) * 1.5
            return RenderGlyph(character: glyph.character, x: curX, y: homeY, color: targetColor, alpha: alpha, scale: 1.0, glowIntensity: 1.0 + trailGlow)
        }
    }
    
    private static func glyphSliceIndex(rowCount: Int) -> (Int) -> Int {
        return { row in row / 2 }
    }
    
    // MARK: - 6. Unstable
    private static func renderUnstable(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.navy, SonderPalette.blue, SonderPalette.green]
        let emblemCenterScreen = CGPoint(
            x: gridOrigin.x + logoData.emblemCenter.x * cellWidth,
            y: gridOrigin.y + logoData.emblemCenter.y * cellHeight
        )
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.5 + glyph.normalizedY * 0.5)
            
            var curX = homeX
            var curY = homeY
            var curColor = targetColor
            var alpha: CGFloat = 1.0
            
            if progress < 0.25 {
                // Phase 1: High frequency jitter & glitch
                let jitterX = (CGFloat((glyph.id * 17) % 25) - 12.0) * (1.0 - progress * 4.0)
                let jitterY = (CGFloat((glyph.id * 23) % 15) - 7.0) * (1.0 - progress * 4.0)
                curX += jitterX
                curY += jitterY
                curColor = (glyph.id % 3 == 0) ? SonderPalette.green : SonderPalette.blue
            } else if progress < 0.55 {
                // Phase 2: Quantum blast outward
                let blastT = (progress - 0.25) / 0.30
                let blastFactor = sin(blastT * .pi)
                let angle = atan2(homeY - emblemCenterScreen.y, homeX - emblemCenterScreen.x)
                let blastDist = blastFactor * (120.0 + CGFloat(glyph.id % 120))
                curX += cos(angle) * blastDist
                curY += sin(angle) * blastDist
                curColor = SonderPalette.interpolate(stops: [SonderPalette.blue, SonderPalette.green], t: blastT)
            } else {
                // Phase 3: Gravitational snap back
                let snapT = (progress - 0.55) / 0.45
                let eased = 1.0 - pow(1.0 - snapT, 4.0)
                let angle = atan2(homeY - emblemCenterScreen.y, homeX - emblemCenterScreen.x)
                let maxDist = 120.0 + CGFloat(glyph.id % 120)
                let remainingDist = maxDist * (1.0 - eased)
                curX += cos(angle) * remainingDist
                curY += sin(angle) * remainingDist
                alpha = 0.5 + snapT * 0.5
            }
            
            return RenderGlyph(character: glyph.character, x: curX, y: curY, color: curColor, alpha: alpha, scale: 1.0, glowIntensity: 1.2)
        }
    }
    
    // MARK: - 7. Scattered
    private static func renderScattered(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.sky, SonderPalette.lime]
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.6 + glyph.normalizedY * 0.4)
            
            let scatterX = CGFloat((glyph.id * 149) % max(1, Int(canvasSize.width)))
            let scatterY = CGFloat((glyph.id * 263) % max(1, Int(canvasSize.height)))
            
            let delay = (1.0 - min(1.0, glyph.distanceFromEmblemCenter / 2.5)) * 0.30
            let localT = max(0.0, min(1.0, (progress - delay) / max(0.001, 1.0 - delay)))
            let eased = 1.0 - pow(1.0 - localT, 3.5)
            
            let curX = scatterX + (homeX - scatterX) * eased
            let curY = scatterY + (homeY - scatterY) * eased
            
            let alpha = max(0.1, localT)
            let color = SonderPalette.interpolate(stops: [SonderPalette.lime, targetColor], t: localT)
            return RenderGlyph(character: glyph.character, x: curX, y: curY, color: color, alpha: alpha, scale: 1.0 + (1.0 - localT) * 0.3, glowIntensity: 1.0 + (1.0 - localT))
        }
    }
    
    // MARK: - 8. Sweep
    private static func renderSweep(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.blue, SonderPalette.green, SonderPalette.orange]
        let beamCol = progress * CGFloat(logoData.colCount + 10) - 5.0
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX * 0.7 + glyph.normalizedY * 0.3)
            
            let dist = CGFloat(glyph.col) - beamCol
            
            if dist > 2.0 {
                // Ahead of beam: dim unrevealed
                return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: SonderPalette.navy, alpha: 0.08, scale: 0.95, glowIntensity: 0.5)
            } else if abs(dist) <= 2.0 {
                // In beam: high energy peak
                let intensity = 1.0 - abs(dist) / 2.0
                let highlightColor = NSColor.white.blended(withFraction: 0.4, of: SonderPalette.sky) ?? SonderPalette.sky
                return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: highlightColor, alpha: 1.0, scale: 1.0 + intensity * 0.3, glowIntensity: 1.0 + intensity * 2.0)
            } else {
                // Behind beam: vibrant revealed
                return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: targetColor, alpha: 1.0, scale: 1.0, glowIntensity: 1.0)
            }
        }
    }
    
    // MARK: - 9. Rings
    private static func renderRings(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let ringColors = [SonderPalette.blue, SonderPalette.green, SonderPalette.orange]
        let waveStarts: [CGFloat] = [0.0, 0.22, 0.44]
        let maxRadius: CGFloat = 3.2
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: ringColors, t: glyph.normalizedX * 0.6 + glyph.normalizedY * 0.4)
            
            var highestPulse: CGFloat = 0.0
            var activeColor = SonderPalette.navy
            var isPassedAny = false
            
            for (idx, start) in waveStarts.enumerated() {
                if progress >= start {
                    let waveT = (progress - start) / (1.0 - start)
                    let currentR = waveT * maxRadius
                    let dist = glyph.distanceFromEmblemCenter
                    
                    if dist <= currentR {
                        isPassedAny = true
                        activeColor = ringColors[idx]
                        let pulse = max(0.0, 1.0 - abs(dist - currentR) * 2.5)
                        highestPulse = max(highestPulse, pulse)
                    }
                }
            }
            
            let alpha: CGFloat = isPassedAny ? 1.0 : 0.05
            let color = highestPulse > 0.3 ? NSColor.white.blended(withFraction: 0.5, of: activeColor)! : (progress > 0.85 ? targetColor : activeColor)
            return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: color, alpha: alpha, scale: 1.0 + highestPulse * 0.35, glowIntensity: 1.0 + highestPulse * 2.0)
        }
    }
    
    // MARK: - 10. MiddleOut
    private static func renderMiddleOut(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        let stops = [SonderPalette.navy, SonderPalette.blue, SonderPalette.green]
        let centerCol = CGFloat(logoData.colCount) / 2.0
        let maxDist = centerCol + 3.0
        let revealDist = progress * maxDist
        
        return logoData.glyphs.map { glyph in
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: stops, t: glyph.normalizedX)
            
            let distFromCenter = abs(CGFloat(glyph.col) - centerCol)
            
            if distFromCenter > revealDist {
                return RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: SonderPalette.navy, alpha: 0.0)
            } else {
                let localT = min(1.0, (revealDist - distFromCenter) / 4.0)
                let offsetX = (1.0 - localT) * (CGFloat(glyph.col) < centerCol ? 35.0 : -35.0)
                let color = SonderPalette.blue.blended(withFraction: localT, of: targetColor) ?? targetColor
                return RenderGlyph(character: glyph.character, x: homeX + offsetX, y: homeY, color: color, alpha: localT, scale: 1.0, glowIntensity: 1.0 + (1.0 - localT) * 0.8)
            }
        }
    }
    
    // MARK: - 11. Matrix
    private static let matrixRainChars: [Character] = [
        // Complete authentic half-width Katakana
        "ｦ", "ｱ", "ｲ", "ｳ", "ｴ", "ｵ", "ｶ", "ｷ", "ｸ", "ｹ", "ｺ",
        "ｻ", "ｼ", "ｽ", "ｾ", "ｿ", "ﾀ", "ﾁ", "ﾂ", "ﾃ", "ﾄ",
        "ﾅ", "ﾆ", "ﾇ", "ﾈ", "ﾉ", "ﾊ", "ﾋ", "ﾌ", "ﾍ", "ﾎ",
        "ﾏ", "ﾐ", "ﾑ", "ﾒ", "ﾓ", "ﾔ", "ﾕ", "ﾖ", "ﾗ", "ﾘ",
        "ﾙ", "ﾚ", "ﾛ", "ﾜ", "ﾝ",
        // Numbers 0 through 9
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        // Cyberspace glyphs
        "X", "Z", "Y", "K", "+", "-", "*", "/", "<", ">", "=", "%", ":", "¦", "░", "▒", "▓"
    ]
    
    private static let matrixHeadColor = NSColor(srgbRed: 0.96, green: 1.0, blue: 0.96, alpha: 1.0)
    private static let matrixDarkGreen = NSColor(srgbRed: 0.05, green: 0.45, blue: 0.14, alpha: 1.0)
    
    private static func renderMatrix(
        progress: CGFloat,
        elapsed: TimeInterval,
        logoData: SonderLogoData,
        cellWidth: CGFloat,
        cellHeight: CGFloat,
        gridOrigin: CGPoint,
        canvasSize: CGSize
    ) -> [RenderGlyph] {
        var glyphs: [RenderGlyph] = []
        glyphs.reserveCapacity(2500)
        
        // 1. Ambient rain streams in margins (left and right of logo)
        let totalGridWidth = CGFloat(logoData.colCount) * cellWidth
        let leftSpace = gridOrigin.x
        let rightStart = gridOrigin.x + totalGridWidth
        let rightSpace = max(0.0, canvasSize.width - rightStart)
        
        let ambientCount = 8
        for i in 0..<ambientCount {
            if leftSpace > cellWidth * 2.0 {
                let ambX = cellWidth * 1.5 + CGFloat(i) * ((leftSpace - cellWidth * 3.0) / CGFloat(max(1, ambientCount - 1)))
                renderAmbientStream(colX: ambX, index: i, elapsed: elapsed, cellHeight: cellHeight, canvasHeight: canvasSize.height, into: &glyphs)
            }
            if rightSpace > cellWidth * 2.0 {
                let ambX = rightStart + cellWidth * 1.5 + CGFloat(i) * ((rightSpace - cellWidth * 3.0) / CGFloat(max(1, ambientCount - 1)))
                renderAmbientStream(colX: ambX, index: i + 10, elapsed: elapsed, cellHeight: cellHeight, canvasHeight: canvasSize.height, into: &glyphs)
            }
        }
        
        // 2. Primary rain streams cascading down logo columns
        let startY = -cellHeight * 6.0
        let endY = canvasSize.height + cellHeight * 14.0
        let streamAlpha = max(0.0, 1.0 - max(0.0, progress - 0.70) / 0.22)
        
        // Find which columns in the logo have glyphs
        var activeCols = Set<Int>()
        for g in logoData.glyphs {
            activeCols.insert(g.col)
        }
        
        if streamAlpha > 0.01 {
            for col in activeCols {
                let colSeed = (col * 7919 + 104729) & 0x7fffffff
                let delay = CGFloat(Double(colSeed % 280) / 1000.0) // 0.0 to 0.28
                let speed = CGFloat(0.95 + Double((colSeed / 280) % 35) / 100.0) // 0.95 to 1.30
                
                guard progress >= delay else { continue }
                let streamT = min(1.0, (progress - delay) / max(0.001, 0.65 - delay))
                let headY = startY + (endY - startY) * pow(streamT, 1.1) * speed
                
                guard headY > startY + cellHeight else { continue }
                let colX = gridOrigin.x + CGFloat(col) * cellWidth
                let tailLen = 10 + (colSeed % 8)
                
                for step in 0...tailLen {
                    let charY = headY - CGFloat(step) * cellHeight
                    guard charY >= -cellHeight && charY <= canvasSize.height + cellHeight else { continue }
                    
                    let charIdx = (colSeed + step * 19 + Int(elapsed * 24.0)) % matrixRainChars.count
                    let ch = matrixRainChars[charIdx]
                    
                    if step == 0 {
                        glyphs.append(RenderGlyph(character: ch, x: colX, y: charY, color: matrixHeadColor, alpha: streamAlpha, scale: 1.15, glowIntensity: 2.2))
                    } else if step <= 2 {
                        glyphs.append(RenderGlyph(character: ch, x: colX, y: charY, color: SonderPalette.lime, alpha: streamAlpha * 0.9, scale: 1.0, glowIntensity: 1.2))
                    } else if step <= 6 {
                        // Disable shadow blur for mid-tail to optimize rendering on Retina displays
                        glyphs.append(RenderGlyph(character: ch, x: colX, y: charY, color: SonderPalette.green, alpha: streamAlpha * 0.75, scale: 0.95, glowIntensity: 0.0))
                    } else {
                        // Disable shadow blur for lower-tail
                        let tailFade = max(0.05, 0.45 - CGFloat(step - 6) * 0.05)
                        glyphs.append(RenderGlyph(character: ch, x: colX, y: charY, color: matrixDarkGreen, alpha: streamAlpha * tailFade, scale: 0.9, glowIntensity: 0.0))
                    }
                }
            }
        }
        
        // 3. Logo Glyphs (ignited, deciphering, locking in to form the logo shape)
        let brandStops = [SonderPalette.green, SonderPalette.lime, SonderPalette.green, SonderPalette.sky]
        
        for glyph in logoData.glyphs {
            let homeX = gridOrigin.x + CGFloat(glyph.col) * cellWidth
            let homeY = gridOrigin.y + CGFloat(glyph.row) * cellHeight
            let targetColor = SonderPalette.interpolate(stops: brandStops, t: glyph.normalizedX * 0.7 + glyph.normalizedY * 0.3)
            
            let colSeed = (glyph.col * 7919 + 104729) & 0x7fffffff
            let delay = CGFloat(Double(colSeed % 280) / 1000.0)
            let speed = CGFloat(0.95 + Double((colSeed / 280) % 35) / 100.0)
            
            // Calculate progress when stream head hits this glyph's homeY
            let neededRatio = max(0.0, min(1.0, (homeY - startY) / max(0.001, (endY - startY) * speed)))
            let neededStreamT = pow(neededRatio, 1.0 / 1.1)
            let arrivalP = delay + neededStreamT * (0.65 - delay)
            
            guard progress >= arrivalP else {
                // Stream has not reached this glyph yet
                continue
            }
            
            let deltaP = progress - arrivalP
            let lockDelay = 0.16 + (CGFloat((glyph.id * 43) % 100) / 100.0) * 0.12
            let lockP = min(0.92, arrivalP + lockDelay)
            
            if deltaP < 0.035 {
                // Phase A: Stream head actively hitting the glyph (supercharged white-hot impact)
                let ch = matrixRainChars[(glyph.id * 7 + Int(elapsed * 30.0)) % matrixRainChars.count]
                glyphs.append(RenderGlyph(character: ch, x: homeX, y: homeY, color: matrixHeadColor, alpha: 1.0, scale: 1.25, glowIntensity: 2.4))
            } else if progress < lockP {
                // Phase B: Matrix Deciphering (scrambling green matrix glyphs outlining the logo)
                let ch = matrixRainChars[(glyph.id * 17 + Int(elapsed * 24.0)) % matrixRainChars.count]
                let color = (glyph.id % 4 == 0) ? SonderPalette.lime : SonderPalette.green
                glyphs.append(RenderGlyph(character: ch, x: homeX, y: homeY, color: color, alpha: 0.95, scale: 1.0, glowIntensity: 1.3))
            } else {
                // Phase C: Crystallization & Lock-in (resolving into true logo ASCII characters)
                let settleT = min(1.0, (progress - lockP) / 0.08)
                if settleT < 1.0 {
                    let flash = (1.0 - settleT) * 1.8
                    let flashColor = NSColor.white.blended(withFraction: 1.0 - (1.0 - settleT) * 0.7, of: targetColor) ?? targetColor
                    glyphs.append(RenderGlyph(character: glyph.character, x: homeX, y: homeY, color: flashColor, alpha: 1.0, scale: 1.0 + flash * 0.22, glowIntensity: 1.0 + flash * 1.6))
                } else {
                    // Fully settled in the shape of the logo
                    var displayChar = glyph.character
                    var displayColor = targetColor
                    var displayGlow: CGFloat = 1.0
                    
                    // Subtle alive matrix glitch during hold
                    if progress >= 0.98 {
                        let glitchSeed = (glyph.id * 131 + Int(elapsed * 5.0)) % 180
                        if glitchSeed == 42 {
                            displayChar = matrixRainChars[(glyph.id + Int(elapsed * 15.0)) % matrixRainChars.count]
                            displayColor = SonderPalette.lime
                            displayGlow = 1.8
                        }
                    }
                    
                    glyphs.append(RenderGlyph(character: displayChar, x: homeX, y: homeY, color: displayColor, alpha: 1.0, scale: 1.0, glowIntensity: displayGlow))
                }
            }
        }
        
        return glyphs
    }
    
    private static func renderAmbientStream(
        colX: CGFloat,
        index: Int,
        elapsed: TimeInterval,
        cellHeight: CGFloat,
        canvasHeight: CGFloat,
        into glyphs: inout [RenderGlyph]
    ) {
        let ambSeed = index * 997 + 101
        let cycle = 2.4 + Double((ambSeed % 18)) / 10.0
        let offset = Double((ambSeed % 100)) / 100.0 * cycle
        let ambT = CGFloat(fmod(elapsed + offset, cycle) / cycle)
        let ambHeadY = -cellHeight * 4.0 + ambT * (canvasHeight + cellHeight * 16.0)
        let ambTail = 8 + (ambSeed % 6)
        let ambBaseAlpha: CGFloat = 0.35
        
        for step in 0...ambTail {
            let y = ambHeadY - CGFloat(step) * cellHeight
            guard y >= -cellHeight && y <= canvasHeight + cellHeight else { continue }
            
            let ch = matrixRainChars[(ambSeed + step * 13 + Int(elapsed * 18.0)) % matrixRainChars.count]
            if step == 0 {
                glyphs.append(RenderGlyph(character: ch, x: colX, y: y, color: matrixHeadColor, alpha: ambBaseAlpha * 0.9, scale: 1.05, glowIntensity: 1.0))
            } else if step <= 2 {
                glyphs.append(RenderGlyph(character: ch, x: colX, y: y, color: SonderPalette.lime, alpha: ambBaseAlpha * 0.75, scale: 1.0, glowIntensity: 0.0))
            } else if step <= 5 {
                glyphs.append(RenderGlyph(character: ch, x: colX, y: y, color: SonderPalette.green, alpha: ambBaseAlpha * 0.5, scale: 0.95, glowIntensity: 0.0))
            } else {
                glyphs.append(RenderGlyph(character: ch, x: colX, y: y, color: matrixDarkGreen, alpha: ambBaseAlpha * 0.25, scale: 0.9, glowIntensity: 0.0))
            }
        }
    }
}
