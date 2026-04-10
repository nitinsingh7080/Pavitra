import AVFoundation
import SwiftUI
import Combine

class ShankhAudioEngine: ObservableObject {
    static let shared = ShankhAudioEngine()
    
    private var audioPlayer: AVAudioPlayer?
    private var displayLink: CADisplayLink?
    
    @Published var playbackProgress: Float = 0.0
    
    // State variables
    private var isPlaying: Bool = false
    var isScrubbing: Bool = false
    
    private init() {
        setupAudio()
    }
    
    private func setupAudio() {
        guard let url = Bundle.main.url(forResource: "shankh", withExtension: "wav") else {
            print("ShankhAudioEngine: Could not find shankh.wav in bundle")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            
            // Setup display link to publish progress
            displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
            displayLink?.add(to: .main, forMode: .common)
            
        } catch {
            print("ShankhAudioEngine setup error: \(error)")
        }
    }
    
    @objc private func updateProgress() {
        guard let player = audioPlayer, player.isPlaying, !isScrubbing else { return }
        playbackProgress = Float(player.currentTime / player.duration)
    }
    
    func play(intensity: Float) {
        if !isPlaying {
            self.isPlaying = true
            audioPlayer?.play()
        }
        
        let targetVolume = max(0.1, min(intensity, 1.0))
        audioPlayer?.setVolume(targetVolume, fadeDuration: 0.1)
    }
    
    func setPosition(percentage: Float) {
        guard let player = audioPlayer else { return }
        player.currentTime = TimeInterval(percentage) * player.duration
        playbackProgress = percentage
        
        if isScrubbing && !player.isPlaying {
            // Unmute/play temporarily so user can hear the scrubbing
            player.volume = 1.0
            player.play()
        }
    }
    
    func stop() {
        self.isPlaying = false
        audioPlayer?.setVolume(0.0, fadeDuration: 0.2)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if !self.isPlaying && !self.isScrubbing {
                self.audioPlayer?.pause()
            }
        }
    }
}
