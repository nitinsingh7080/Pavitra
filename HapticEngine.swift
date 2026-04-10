import CoreHaptics
import SwiftUI

class HapticEngine {
    static let shared = HapticEngine()
    private var engine: CHHapticEngine?
    
    private init() {
        prepareHaptics()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            engine = try CHHapticEngine()
            try engine?.start()
            
            // Re-start handler
            engine?.resetHandler = { [weak self] in
                do {
                    try self?.engine?.start()
                } catch {
                    print("Could not restart haptic engine: \(error)")
                }
            }
            
        } catch {
            print("There was an error creating the haptic engine: \(error.localizedDescription)")
        }
    }
    
    func playHeavyBellRing(intensity: Float = 1.0) {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics, let engine = engine else { return }
        
        // Define a sharp initial strike followed by a fading rumble (like a bell)
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: max(0.4, min(intensity, 1.0)))
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
        
        let initialStrike = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParam, sharpnessParam], relativeTime: 0)
        
        // Create a decaying continuous vibration
        let rumbleIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: min(intensity * 0.6, 1.0))
        let rumbleSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let decay = CHHapticEvent(eventType: .hapticContinuous, parameters: [rumbleIntensity, rumbleSharpness], relativeTime: 0.1, duration: 0.6)
        
        // Custom envelope parameters for the continuous event to make it fade precisely
        let curve = CHHapticParameterCurve(parameterID: .hapticIntensityControl, controlPoints: [
            CHHapticParameterCurve.ControlPoint(relativeTime: 0.0, value: 1.0),
            CHHapticParameterCurve.ControlPoint(relativeTime: 0.6, value: 0.0)
        ], relativeTime: 0.1)
        
        do {
            let pattern = try CHHapticPattern(events: [initialStrike, decay], parameterCurves: [curve])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play advanced pattern: \(error.localizedDescription)")
            
            // Fallback to simple UI feedback
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
        }
    }
    
    func playLightSpark() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}
