import AVFoundation

class BellAudioEngine {
    static let shared = BellAudioEngine()

    private let engine = AVAudioEngine()
    private var sourceNode: AVAudioSourceNode!

    // State variables
    private var time: Double = 0
    private let sampleRate: Double = 44100.0
    private var strikeTime: Double = -1.0
    private var strikeIntensity: Double = 0.0

    private init() {
        setupAudio()
    }

    private func setupAudio() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!

        sourceNode = AVAudioSourceNode {
            [weak self] _, _, frameCount, audioBufferList -> OSStatus in
            guard let self = self else { return noErr }

            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)

            for frame in 0..<Int(frameCount) {
                var sample: Float = 0.0

                if self.strikeTime >= 0 {
                    let t = self.time - self.strikeTime

                    // Exponential decay envelopes
                    let decay1 = exp(-5.5 * t)  // fast metallic hit
                    let decay2 = exp(-2.2 * t)  // mid-frequency ring
                    let decay3 = exp(-1.2 * t)  // fundamental — tighter sustain

                    if decay3 > 0.001 {
                        // Frequencies: raised fundamental for a thinner, brighter ring
                        let f1: Double = 1900.0  // raised fundamental
                        let f2: Double = 2700.0
                        let f3: Double = 3500.0
                        let f4: Double = 4600.0
                        let f5: Double = 5800.0

                        let twoPi: Double = 2.0 * .pi

                        // Less fundamental, more overtone — thin bright ting
                        let v1 = sin(twoPi * f1 * t) * decay3 * 0.20
                        let v2 = sin(twoPi * f2 * t) * decay2 * 0.38
                        let v3 = sin(twoPi * f3 * t) * decay2 * 0.28
                        let v4 = sin(twoPi * f4 * t) * decay1 * 0.22
                        let v5 = sin(twoPi * f5 * t) * decay1 * 0.18

                        let rawSample: Double = v1 + v2 + v3 + v4 + v5
                        let scaledSample: Double = rawSample * self.strikeIntensity * 0.62
                        sample = Float(scaledSample)
                    } else {
                        self.strikeTime = -1.0  // Stop sounding when decayed
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

        // Ensure AVAudioSession is set to playback so it works even on silent mode
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioSession set category error: \(error)")
        }

        do {
            try engine.start()
        } catch {
            print("AudioEngine start error: \(error)")
        }
    }

    func ringBell(intensity: Float) {
        // Trigger the procedural sound
        self.strikeIntensity = Double(max(0.1, min(intensity, 1.0)))
        self.strikeTime = self.time
    }
}
