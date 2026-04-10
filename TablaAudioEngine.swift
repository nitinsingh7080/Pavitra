import AVFoundation

class TablaAudioEngine {
    static let shared = TablaAudioEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    
    // Bayan (Left, Bass) State
    private var bayanPlaying: Bool = false
    private var bayanTime: Double = 0
    private var bayanEnvelope: Double = 0.0
    private var bayanIntensity: Double = 0.0
    private var bayanPressure: Double = 0.0 // Pitch bend via palm pressure
    
    // Dayan (Right, Treble) State
    private var dayanPlaying: Bool = false
    private var dayanTime: Double = 0
    private var dayanEnvelope: Double = 0.0
    private var dayanIntensity: Double = 0.0
    
    private let sampleRate: Double = 44100.0
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                var finalSample: Double = 0.0
                
                // - BAYAN SYNTHESIS (Left Drum - Bass / Ge) -
                if self.bayanPlaying {
                    let t = self.bayanTime
                    let twoPi = 2.0 * .pi
                    
                    // Bayan has a trademark sweeping bass sound ("Ge" or "Ga")
                    // Frequency shifts up based on pressure
                    let baseFreq = 65.0 + (self.bayanPressure * 45.0) // slightly deeper base, slightly wider bend
                    
                    // Initial slide effect typical of playing the Bayan
                    let initialSlide = 18.0 * exp(-t * 15.0) // slightly sharper slide
                    let f1 = baseFreq + initialSlide
                    
                    let v1 = sin(twoPi * f1 * t)
                    let v2 = sin(twoPi * f1 * 2.1 * t) * 0.15 // Add subtle overtone for clarity
                    
                    let env = self.bayanEnvelope
                    finalSample += (v1 + v2) * env * self.bayanIntensity * 1.5
                    
                    self.bayanTime += 1.0 / self.sampleRate
                    self.bayanEnvelope *= 0.99975 // Slightly faster decay
                    
                    if self.bayanEnvelope < 0.001 {
                        self.bayanPlaying = false
                    }
                }
                
                // - DAYAN SYNTHESIS (Right Drum - Treble / Na / Tin) -
                if self.dayanPlaying {
                    let t = self.dayanTime
                    let twoPi = 2.0 * .pi
                    
                    // Dayan is a highly tuned drum with explicit harmonic partials (due to the black spot 'Syahi')
                    // Exact classical modes for Tabla Dayan: 1.0, 2.0, 2.9, 3.8, 4.8
                    let f1 = 320.0 // Fundamental (typical D# Tuning)
                    let f2 = f1 * 2.0 
                    let f3 = f1 * 2.91 
                    let f4 = f1 * 3.85
                    let f5 = f1 * 4.82
                    
                    let v1 = sin(twoPi * f1 * t) * 0.6
                    let v2 = sin(twoPi * f2 * t) * 0.4
                    let v3 = sin(twoPi * f3 * t) * 0.25
                    let v4 = sin(twoPi * f4 * t) * 0.15
                    let v5 = sin(twoPi * f5 * t) * 0.08
                    
                    // The attack has a distinct sharp "click" or "tap" sound
                    let attackNoise = Double.random(in: -1.0...1.0) * exp(-t * 400.0) // Sharper attack click
                    
                    let dayanPulse = v1 + v2 + v3 + v4 + v5 + attackNoise
                    
                    let env = self.dayanEnvelope
                    finalSample += dayanPulse * env * self.dayanIntensity
                    
                    self.dayanTime += 1.0 / self.sampleRate
                    // Dayan has a ringing, bell-like decay but faster than Bayan
                    self.dayanEnvelope *= 0.9995 
                    
                    if self.dayanEnvelope < 0.001 {
                        self.dayanPlaying = false
                    }
                }
                
                // Soft clipping to prevent distortion when both drums hit hard
                finalSample = tanh(finalSample * 1.2)
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = Float(finalSample)
                }
            }
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("TablaAudioEngine start error: \(error)")
        }
    }
    
    // Play the Bayan (Left Bass Drum)
    // Pressure parameter (0.0 to 1.0) controls the pitch bend
    func playBayan(intensity: Float, pressure: Float = 0.0) {
        self.bayanIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.bayanPressure = Double(max(0.0, min(pressure, 1.0)))
        self.bayanEnvelope = 1.0
        self.bayanTime = 0.0
        self.bayanPlaying = true
    }
    
    // Update the pitch of an already playing Bayan (simulating palming the skin while it rings)
    func modulateBayanPressure(_ pressure: Float) {
        self.bayanPressure = Double(max(0.0, min(pressure, 1.0)))
    }
    
    // Play the Dayan (Right Treble Drum)
    func playDayan(intensity: Float) {
        self.dayanIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.dayanEnvelope = 1.0
        self.dayanTime = 0.0
        self.dayanPlaying = true
    }
}
