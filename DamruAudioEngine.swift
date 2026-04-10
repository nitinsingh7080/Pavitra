import AVFoundation

class DamruAudioEngine {
    static let shared = DamruAudioEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    
    // State
    private var time: Double = 0
    private let sampleRate: Double = 44100.0
    private var isPlaying: Bool = false
    private var currentIntensity: Double = 0.0
    
    private var envelope: Double = 0.0
    
    // Damru strikes are rapid, alternating hits.
    // To add realism, we alternate the pitch slightly to simulate the two different heads or beads.
    private var flipFlop = false
    
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
                    let twoPi = 2.0 * .pi
                    
                    // Base frequency flips slightly per strike to emulate bead variances
                    let f1 = self.flipFlop ? 420.0 : 380.0
                    let f2 = f1 * 1.6
                    let f3 = f1 * 2.1
                    
                    let v1 = sin(twoPi * f1 * t) * 0.7
                    let v2 = sin(twoPi * f2 * t) * 0.3
                    let v3 = sin(twoPi * f3 * t) * 0.1
                    
                    // Very sharp slap attack for the leather bead hitting the skin
                    let attackNoise = Double.random(in: -1.0...1.0) * exp(-t * 150.0)
                    
                    let drumPulse = v1 + v2 + v3 + attackNoise * 1.5
                    
                    sample = Float(drumPulse * self.envelope * self.currentIntensity)
                    
                    // Fast decay (damru heads are small and highly tensioned)
                    self.envelope *= 0.9995
                    self.time += 1.0 / self.sampleRate
                    
                    if self.envelope < 0.001 {
                        self.isPlaying = false
                        self.envelope = 0.0
                    }
                }
                
                for buffer in ablPointer {
                    let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                    buf[frame] = sample
                }
            }
            return noErr
        }
        
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("DamruAudioEngine start error: \(error)")
        }
    }
    
    func strike(intensity: Float) {
        self.currentIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.envelope = 1.0 // Reset attack
        self.time = 0.0
        self.flipFlop.toggle()
        self.isPlaying = true
    }
}
