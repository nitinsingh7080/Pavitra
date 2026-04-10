import AVFoundation

class AmbientAudioEngine {
    static let shared = AmbientAudioEngine()
    
    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!
    
    // Low pass filter to dull the white noise into a "crackle"
    private var filterNode = AVAudioUnitEQ(numberOfBands: 1)
    
    private var isPlaying: Bool = false
    private var time: Double = 0
    private let sampleRate: Double = 44100.0
    private var targetVolume: Float = 0.0
    private var currentVolume: Float = 0.0
    
    enum AmbientType {
        case diyaCrackle
        case agarbattiSizzle
    }
    private var currentType: AmbientType = .diyaCrackle
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        
        // Setup filter
        let band = filterNode.bands[0]
        band.filterType = .lowPass
        band.frequency = 800.0
        band.bandwidth = 1.0
        band.gain = 0.0
        band.bypass = false
        
        sourceNode = AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            
            for frame in 0..<Int(frameCount) {
                var sample: Float = 0.0
                
                // Smoothly interpolate volume to prevent pops
                let diff = self.targetVolume - self.currentVolume
                if abs(diff) > 0.0001 {
                    self.currentVolume += diff * 0.005 // Smoothing factor
                } else {
                    self.currentVolume = self.targetVolume
                }
                
                if self.currentVolume > 0.01 {
                    let t = self.time
                    
                    if self.currentType == .diyaCrackle {
                        // Diya: Low rumble + occasional loud crackle (popping bubbles in oil)
                        // Base rumble
                        let noise = Float.random(in: -0.3...0.3)
                        
                        // Sparse crackles
                        var crackle: Float = 0.0
                        // Generate a pseudo-random pulse that fires rarely
                        let pulse = sin(t * 15.0) * sin(t * 7.1) * cos(t * 23.4)
                        if pulse > 0.98 {
                            crackle = Float.random(in: 0.5...1.0)
                        } else if pulse < -0.98 {
                            crackle = Float.random(in: -1.0...(-0.5))
                        }
                        
                        sample = (noise + crackle) * self.currentVolume * 0.5
                    } else {
                        // Agarbatti: High frequency, dense sizzle (burning powder)
                        // We use a different noise profile and the filter will be bypassed or higher frequency
                        let highNoise = Float.random(in: -0.8...0.8)
                        
                        // Amplitude modulation to make it sound like it's burning unevenly
                        let modulation = Float(sin(t * 3.0) * 0.5 + 0.5) * 0.3 + 0.7
                        
                        sample = highNoise * modulation * self.currentVolume * 0.2
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
        engine.attach(filterNode)
        
        engine.connect(sourceNode, to: filterNode, format: format)
        engine.connect(filterNode, to: engine.mainMixerNode, format: format)
        
        do {
            try engine.start()
        } catch {
            print("AmbientAudioEngine start error: \(error)")
        }
    }
    
    func play(type: AmbientType) {
        self.currentType = type
        
        // Adjust filter based on type
        if type == .diyaCrackle {
            filterNode.bands[0].frequency = 1200.0 // Muffled
        } else {
            filterNode.bands[0].frequency = 6000.0 // Bright sizzle
        }
        
        self.targetVolume = 1.0
    }
    
    func stop() {
        self.targetVolume = 0.0
    }
}
