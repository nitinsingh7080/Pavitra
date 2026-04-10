import AVFoundation

class ManjiraAudioEngine {
    static let shared = ManjiraAudioEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    
    // State
    private var time: Double = 0
    private let sampleRate: Double = 44100.0
    private var isPlaying: Bool = false
    private var currentIntensity: Double = 0.0
    
    // Envelope for the splash (fast attack, long slow decay)
    private var envelope: Double = 0.0 
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                var sample: Float = 0.0
                
                if self.isPlaying {
                    let t = self.time
                    
                    // Manjira (Hand Cymbals) are small bronze cup cymbals.
                    // Metallic sounds have highly inharmonic partials.
                    // We use theoretical mode ratios for a small, thick domed plate.
                    let baseFreq = 1850.0 // Very high fundamental
                    
                    // Specific inharmonic ratios that create a "metallic chink"
                    let r1 = 1.0
                    let r2 = 1.414 // sqrt(2)
                    let r3 = 1.95
                    let r4 = 2.58
                    let r5 = 3.26
                    let r6 = 4.07
                    let r7 = 5.0
                    
                    let twoPi = 2.0 * .pi
                    
                    let s1 = sin(twoPi * baseFreq * r1 * t) * 0.4
                    let s2 = sin(twoPi * baseFreq * r2 * t) * 0.3
                    let s3 = sin(twoPi * baseFreq * r3 * t) * 0.25
                    let s4 = sin(twoPi * baseFreq * r4 * t) * 0.2
                    let s5 = sin(twoPi * baseFreq * r5 * t) * 0.15
                    let s6 = sin(twoPi * baseFreq * r6 * t) * 0.1
                    let s7 = sin(twoPi * baseFreq * r7 * t) * 0.05
                    
                    // The "clash" of two metal plates hitting together generates high-frequency broadband noise.
                    // It decays much faster than the resonant ring.
                    let attackNoise = Double.random(in: -1.0...1.0)
                    let noiseEnvelope = exp(-t * 80.0) // Very fast decay (shatter)
                    let clashNoise = attackNoise * noiseEnvelope * 0.6
                    
                    let rawSample = s1 + s2 + s3 + s4 + s5 + s6 + s7 + clashNoise
                    
                    // Natural exponential decay for the ringing metal
                    sample = Float(rawSample * self.envelope * self.currentIntensity)
                    
                    self.envelope *= 0.99993 // ~3-4 second decay
                    
                    if self.envelope < 0.001 {
                        self.isPlaying = false
                        self.envelope = 0.0
                    }
                }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
                }
                
                self.time += 1.0 / self.sampleRate
            }
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("ManjiraAudioEngine start error: \(error)")
        }
    }
    
    // Clash the cymbals
    func clash(intensity: Float) {
        self.currentIntensity = Double(max(0.1, min(intensity, 1.0)))
        
        // Reset the envelope for a fresh fast attack
        self.envelope = 1.0 
        self.time = 0.0
        self.isPlaying = true
    }
}
