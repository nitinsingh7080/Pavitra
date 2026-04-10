import CoreMotion
import SwiftUI
import Combine

class MotionManager: ObservableObject {
    private var motionManager = CMMotionManager()
    
    // For the Swiping/Swinging Bell
    @Published var acceleration: CMAcceleration = CMAcceleration(x: 0, y: 0, z: 0)
    @Published var rotationRate: CMRotationRate = CMRotationRate(x: 0, y: 0, z: 0)
    
    // Calculate an abstract "swing energy" for UI and sound triggers
    @Published var swingEnergy: Double = 0.0
    
    // Threshold to register a bell ring
    let ringingThreshold: Double = 2.5
    
    // For flame reaction
    @Published var tiltAngle: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        startDeviceMotion()
    }
    
    func startDeviceMotion() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 1.0 / 60.0 // 60 FPS update
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                guard let self = self, let motion = motion else { return }
                
                self.acceleration = motion.userAcceleration
                self.rotationRate = motion.rotationRate
                
                // Calculate total energy of the device movement (simplified for ringing a bell)
                let energy = abs(motion.userAcceleration.x) + 
                             abs(motion.userAcceleration.y) + 
                             abs(motion.userAcceleration.z) +
                             abs(motion.rotationRate.x) +
                             abs(motion.rotationRate.y)
                
                // Smooth the energy a bit to prevent erratic spikes
                self.swingEnergy = self.swingEnergy * 0.7 + energy * 0.3
                
                // Calculate tilt for the flame (using roll for tilting left/right)
                self.tiltAngle = motion.attitude.roll
            }
        }
    }
    
    func stop() {
        motionManager.stopDeviceMotionUpdates()
    }
}
