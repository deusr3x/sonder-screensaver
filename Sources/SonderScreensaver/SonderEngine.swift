import Foundation
import AppKit

public enum EngineState {
    case animating(progress: CGFloat)
    case holding(elapsed: TimeInterval)
    case outro(progress: CGFloat)
}

public final class SonderEngine {
    public let logoData: SonderLogoData
    public var currentEffect: SonderEffectType
    public var state: EngineState = .animating(progress: 0.0)
    
    public var animationDuration: TimeInterval = 4.0
    public var holdDuration: TimeInterval = 4.0
    public var outroDuration: TimeInterval = 1.0
    
    private var stateElapsed: TimeInterval = 0.0
    private var totalElapsed: TimeInterval = 0.0
    private var sequentialIndex = 0
    
    // Cached typography
    private var cachedFontSize: CGFloat = 0.0
    private var cachedFont: NSFont = NSFont.monospacedSystemFont(ofSize: 16, weight: .bold)
    private var cachedCellWidth: CGFloat = 10.0
    private var cachedCellHeight: CGFloat = 18.0
    
    public init(logoData: SonderLogoData = SonderLogoData.shared) {
        self.logoData = logoData
        self.currentEffect = SonderPreferences.shared.effect
        pickInitialEffect()
    }
    
    public func pickInitialEffect() {
        let prefEffect = SonderPreferences.shared.effect
        if prefEffect == .cycleRandom {
            currentEffect = SonderEffectType.selectableEffects.randomElement() ?? .synthgrid
        } else if prefEffect == .cycleSequential {
            sequentialIndex = 0
            currentEffect = SonderEffectType.selectableEffects[sequentialIndex]
        } else {
            currentEffect = prefEffect
        }
        state = .animating(progress: 0.0)
        stateElapsed = 0.0
    }
    
    public func setSpecificEffect(_ effect: SonderEffectType) {
        currentEffect = effect
        state = .animating(progress: 0.0)
        stateElapsed = 0.0
    }
    
    public func triggerNextEffect() {
        let pref = SonderPreferences.shared.effect
        if pref == .cycleSequential {
            sequentialIndex = (sequentialIndex + 1) % SonderEffectType.selectableEffects.count
            currentEffect = SonderEffectType.selectableEffects[sequentialIndex]
        } else if pref == .cycleRandom {
            let available = SonderEffectType.selectableEffects.filter { $0 != self.currentEffect }
            currentEffect = available.randomElement() ?? .synthgrid
        } else {
            // In single effect mode, reload it
            currentEffect = pref
        }
        state = .animating(progress: 0.0)
        stateElapsed = 0.0
    }
    
    public func advance(deltaTime: TimeInterval) {
        let speed = SonderPreferences.shared.speedMultiplier
        let adjustedDt = deltaTime * speed
        totalElapsed += adjustedDt
        stateElapsed += adjustedDt
        
        switch state {
        case .animating:
            let p = CGFloat(min(1.0, stateElapsed / animationDuration))
            if p >= 1.0 {
                state = .holding(elapsed: 0.0)
                stateElapsed = 0.0
            } else {
                state = .animating(progress: p)
            }
            
        case .holding:
            let holdTime = SonderPreferences.shared.holdDuration
            if stateElapsed >= holdTime {
                state = .outro(progress: 0.0)
                stateElapsed = 0.0
            } else {
                state = .holding(elapsed: stateElapsed)
            }
            
        case .outro:
            let p = CGFloat(min(1.0, stateElapsed / outroDuration))
            if p >= 1.0 {
                triggerNextEffect()
            } else {
                state = .outro(progress: p)
            }
        }
    }
    
    // MARK: - Layout Calculation
    public func layoutMetrics(for size: CGSize) -> (cellWidth: CGFloat, cellHeight: CGFloat, origin: CGPoint, font: NSFont) {
        // Target: fit logo comfortably in ~65-75% of screen
        let cols = CGFloat(logoData.colCount)
        let rows = CGFloat(logoData.rowCount)
        
        let targetWidth = size.width * 0.72
        let targetHeight = size.height * 0.72
        
        // Monospace font character width is ~0.6 of font size; line height ~1.2
        let sizeByW = (targetWidth / cols) / 0.60
        let sizeByH = (targetHeight / rows) / 1.20
        let optimalSize = max(7.0, min(sizeByW, sizeByH))
        
        if abs(optimalSize - cachedFontSize) > 0.5 {
            cachedFontSize = optimalSize
            if let sfMono = NSFont(name: "SF Mono", size: optimalSize) {
                cachedFont = sfMono
            } else if let menlo = NSFont(name: "Menlo-Bold", size: optimalSize) {
                cachedFont = menlo
            } else {
                cachedFont = NSFont.monospacedSystemFont(ofSize: optimalSize, weight: .bold)
            }
            
            // Measure a test character
            let sample = NSAttributedString(string: "█", attributes: [.font: cachedFont])
            let charSize = sample.size()
            cachedCellWidth = ceil(charSize.width)
            cachedCellHeight = ceil(charSize.height * 0.92)
        }
        
        let totalGridWidth = cols * cachedCellWidth
        let totalGridHeight = rows * cachedCellHeight
        
        let originX = floor((size.width - totalGridWidth) / 2.0)
        let originY = floor((size.height - totalGridHeight) / 2.0)
        
        return (cachedCellWidth, cachedCellHeight, CGPoint(x: originX, y: originY), cachedFont)
    }
    
    // MARK: - Render Frame
    public func draw(in context: CGContext, size: CGSize) {
        // 1. Fill background
        let bgChoice = SonderPreferences.shared.backgroundChoice
        let bgColor = (bgChoice == .navy) ? SonderPalette.navy : SonderPalette.black
        context.setFillColor(bgColor.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let (cellWidth, cellHeight, origin, font) = layoutMetrics(for: size)
        let enableGlow = SonderPreferences.shared.neonGlowEnabled
        
        // 2. Compute glyph states
        var progress: CGFloat = 1.0
        var globalAlpha: CGFloat = 1.0
        var pulseScale: CGFloat = 1.0
        
        switch state {
        case .animating(let p):
            progress = p
        case .holding(let elapsed):
            progress = 1.0
            // Subtle breathing pulse in hold state
            pulseScale = 1.0 + 0.03 * CGFloat(sin(elapsed * 2.2))
        case .outro(let p):
            progress = 1.0
            globalAlpha = 1.0 - p
        }
        
        let glyphs = SonderEffects.renderEffect(
            type: currentEffect,
            progress: progress,
            elapsedTime: totalElapsed,
            logoData: logoData,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            gridOrigin: origin,
            canvasSize: size
        )
        
        // 3. Render each glyph
        context.saveGState()
        
        for g in glyphs {
            let effectiveAlpha = g.alpha * globalAlpha
            guard effectiveAlpha > 0.005 else { continue }
            
            let drawColor = g.color.withAlphaComponent(effectiveAlpha)
            let drawScale = g.scale * pulseScale
            
            // Invert Y coordinate for standard AppKit view coordinate space
            // (or draw directly using NSAttributedString in flipped context)
            let str = String(g.character)
            var attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: drawColor
            ]
            
            if enableGlow && g.glowIntensity > 0.1 {
                let shadow = NSShadow()
                shadow.shadowColor = g.color.withAlphaComponent(effectiveAlpha * 0.7)
                shadow.shadowBlurRadius = min(10.0, cellWidth * 0.75 * g.glowIntensity)
                shadow.shadowOffset = .zero
                attributes[.shadow] = shadow
            }
            
            let attrStr = NSAttributedString(string: str, attributes: attributes)
            let pt = NSPoint(x: g.x, y: g.y)
            
            if drawScale != 1.0 {
                NSGraphicsContext.saveGraphicsState()
                let transform = NSAffineTransform()
                transform.translateX(by: pt.x + cellWidth / 2.0, yBy: pt.y + cellHeight / 2.0)
                transform.scale(by: drawScale)
                transform.translateX(by: -(pt.x + cellWidth / 2.0), yBy: -(pt.y + cellHeight / 2.0))
                transform.concat()
                attrStr.draw(at: pt)
                NSGraphicsContext.restoreGraphicsState()
            } else {
                attrStr.draw(at: pt)
            }
        }
        
        context.restoreGState()
    }
}
