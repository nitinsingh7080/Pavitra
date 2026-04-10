import AVFoundation
import Combine

class MicManager: ObservableObject {
    static let shared = MicManager()
    
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    
    @Published var isBlowing: Bool = false
    @Published var micLevel: Float = -160.0 // dB
    
    // Threshold in dB to consider "blowing" into the mic
    private let blowingThreshold: Float = -15.0 
    
    init() {
        setupMicrophone()
    }
    
    private func setupMicrophone() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // Request record permission
            try audioSession.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try audioSession.setActive(true)
            
            let documents = URL(fileURLWithPath: NSTemporaryDirectory())
            let url = documents.appendingPathComponent("temp_mic_monitor.caf")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatAppleIMA4),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
        } catch {
            print("Mic setup error: \(error)")
        }
    }
    
    func startMonitoring() {
        guard let recorder = audioRecorder else { return }
        recorder.record()
        
        // Check levels rapidly (e.g., 20 times a second)
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            recorder.updateMeters()
            
            // averagePower is usually between -160 (quiet) and 0 (loud)
            let level = recorder.averagePower(forChannel: 0)
            self.micLevel = level
            
            if level > self.blowingThreshold {
                self.isBlowing = true
            } else {
                self.isBlowing = false
            }
        }
    }
    
    func stopMonitoring() {
        audioRecorder?.stop()
        timer?.invalidate()
        timer = nil
        isBlowing = false
    }
}
