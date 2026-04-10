import AVFoundation

class DholakAudioEngine {
    static let shared = DholakAudioEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    
    // Bass (Left) State
    private var bassPlaying: Bool = false
    private var bassTime: Double = 0
    private var bassEnvelope: Double = 0.0
    private var bassIntensity: Double = 0.0
    
    // Treble (Right) State
    private var treblePlaying: Bool = false
    private var trebleTime: Double = 0
    private var trebleEnvelope: Double = 0.0
    private var trebleIntensity: Double = 0.0
    
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
                
                // - BASS SYNTHESIS (Left Head) -
                if self.bassPlaying {
                    let t = self.bassTime
                    let twoPi = 2.0 * .pi
                    
                    // The Dholak bass has a soft, resonant low frequency, often pitch-bending slightly downward
                    let baseFreq = 75.0 // Deeper base bump
                    // Pitch bend simulates changing skin tension upon strike
                    let pitchBend = 30.0 * exp(-t * 20.0) // Quicker snap on the bend
                    
                    let f1 = baseFreq + pitchBend
                    let f2 = f1 * 1.58 // Slightly inharmonic overtone (typical of a generic circular membrane)
                    let f3 = f1 * 2.24
                    
                    let v1 = sin(twoPi * f1 * t) * 1.0
                    let v2 = sin(twoPi * f2 * t) * 0.4
                    let v3 = sin(twoPi * f3 * t) * 0.15
                    
                    let basePulse = v1 + v2 + v3
                    
                    // The bass decays relatively quickly
                    let env = self.bassEnvelope
                    finalSample += basePulse * env * self.bassIntensity
                    
                    self.bassTime += 1.0 / self.sampleRate
                    self.bassEnvelope *= 0.9996 // Quicker decay than a Tabla Bayan
                    
                    if self.bassEnvelope < 0.001 {
                        self.bassPlaying = false
                    }
                }
                
                // - TREBLE SYNTHESIS (Right Head) -
                if self.treblePlaying {
                    let t = self.trebleTime
                    let twoPi = 2.0 * .pi
                    
                    // The Dholak treble is sharp, high pitched (like a high tom/snare)
                    // Ratios for a rigid circular membrane: 1.0, 1.59, 2.13, 2.29, 2.65
                    let f1 = 400.0
                    let f2 = f1 * 1.59
                    let f3 = f1 * 2.13
                    let f4 = f1 * 2.65
                    
                    let v1 = sin(twoPi * f1 * t) * 0.5
                    let v2 = sin(twoPi * f2 * t) * 0.3
                    let v3 = sin(twoPi * f3 * t) * 0.2
                    let v4 = sin(twoPi * f4 * t) * 0.1
                    
                    // Sharp noise burst for the initial skin slap attack (very prominent on Dholak treble)
                    let noise = Double.random(in: -1.0...1.0) * exp(-t * 300.0)
                    
                    let treblePulse = v1 + v2 + v3 + v4 + noise * 1.2
                    
                    // Treble decays very fast
                    let env = self.trebleEnvelope
                    finalSample += treblePulse * env * self.trebleIntensity
                    
                    self.trebleTime += 1.0 / self.sampleRate
                    self.trebleEnvelope *= 0.999 // Very fast decay, ~0.1s
                    
                    if self.trebleEnvelope < 0.001 {
                        self.treblePlaying = false
                    }
                }
                
                // Mix & Compress to avoid clipping if both hit at max intensity
                finalSample = tanh(finalSample * 1.2) // Soft clipping
                
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
            print("DholakAudioEngine start error: \(error)")
        }
    }
    
    // Play the Bass (Left) Side
    func playBass(intensity: Float) {
        self.bassIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.bassEnvelope = 1.0
        self.bassTime = 0.0
        self.bassPlaying = true
    }
    
    // Play the Treble (Right) Side
    func playTreble(intensity: Float) {
        self.trebleIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.trebleEnvelope = 1.0
        self.trebleTime = 0.0
        self.treblePlaying = true
    }
}
