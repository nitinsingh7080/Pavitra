import AVFoundation
import Combine
import CoreHaptics
import CoreMotion
import SwiftUI

// MARK: - Domain Types

enum AartiMode: String, CaseIterable {
    case practice = "Practice"
    case guided = "Guided Aarti"
}

/// All 6 sacred instruments — same set as the original ImmersiveExperienceView
enum InstrumentType: String, CaseIterable, Identifiable {
    case ghanti = "Ghanti"
    case shankh = "Shankh"
    case manjira = "Manjira"
    case tabla = "Tabla"
    case dholak = "Dholak"
    case damru = "Damru"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .ghanti: return "bell.fill"
        case .shankh: return "wind"
        case .manjira: return "circles.hexagonpath.fill"
        case .tabla: return "t.circle.fill"
        case .dholak: return "cylinder.fill"
        case .damru: return "hourglass"
        }
    }

    var practiceHint: String {
        switch self {
        case .ghanti: return "Shake device or tap to ring."
        case .shankh: return "Blow into mic, or press and hold."
        case .manjira: return "Tap to clash."
        case .tabla: return "Tap Bayan or Dayan to play."
        case .dholak: return "Tap left (bass) or right (treble)."
        case .damru: return "Tap to strike."
        }
    }
}

enum TablaZone { case bayan, dayan }
enum DholakZone { case bass, treble }

// MARK: - AartiViewModel

@MainActor
class AartiViewModel: ObservableObject {

    // MARK: - Mode
    @Published var mode: AartiMode = .practice

    // MARK: - Practice: selected instrument (always one active; Ghanti by default)
    @Published var selectedInstrument: InstrumentType = .ghanti

    // MARK: - Per-instrument speed (0.5 – 3.0×; affects beat firing density in guided)
    /// 1.0 = fires at base rate. 2.0 = fires twice as often. 0.5 = half as often.
    @Published var instrumentSpeeds: [InstrumentType: Double] = {
        var d: [InstrumentType: Double] = [:]
        for inst in InstrumentType.allCases { d[inst] = 1.0 }
        return d
    }()

    // Speed slider expansion
    @Published var expandedInstrument: InstrumentType? = nil

    // MARK: - Guided sequencer
    @Published var isGuidedPlaying: Bool = false
    @Published var currentBeat: Int = 0
    @Published var tempoMultiplier: Double = 1.0  // master tempo 0.5 – 2.0

    // MARK: - Shake / blow detection (Practice mode)
    @Published var isBlowDetected: Bool = false
    @Published var micLevel: Float = -160
    @Published var isRinging: Bool = false  // Ghanti visual flash

    // MARK: - Mic permission
    @Published var micPermissionGranted: Bool = false
    @Published var micPermissionDenied: Bool = false

    // MARK: - Sub-managers
    let motionManager = MotionManager()
    let micManager = MicManager()

    private var sequencerTimer: AnyCancellable?
    private var swingCancellable: AnyCancellable?
    private var blowCancellable: AnyCancellable?

    private var lastRingTime: Date = .distantPast
    private var lastBlowTime: Date = .distantPast
    private let bellCooldown: TimeInterval = 0.35
    private let blowDebounce: TimeInterval = 0.15
    private let blowThreshold: Float = -18.0

    // MARK: - Base tempo: 108 BPM (sacred number)
    private let baseBPM: Double = 108.0

    // 16-step guided pattern — only Ghanti & Manjira (Shankh is continuous drone)
    // Ghanti 9×  Manjira 7×  — bell-dominant as in real Aarti
    private let pattern: [InstrumentType?] = [
        .ghanti, .manjira, .ghanti, .ghanti,  // bar 1: bell opens strong
        .manjira, .ghanti, .manjira, .ghanti,  // bar 2: alternating
        .ghanti, .manjira, .ghanti, .manjira,  // bar 3: even interchange
        .ghanti, .manjira, .ghanti, .ghanti,  // bar 4: bell closes strong
    ]

    private var beatInterval: Double {
        60.0 / (baseBPM * tempoMultiplier)
    }

    init() {
        checkMicPermission()
        wireMotion()
        wireMic()
    }

    // MARK: - Lifecycle

    func onAppear() {
        motionManager.startDeviceMotion()
        if micPermissionGranted { micManager.startMonitoring() }
    }

    func onDisappear() {
        motionManager.stop()
        micManager.stopMonitoring()
        stopGuidedPlayback()
        ShankhAudioEngine.shared.stop()
        AmbientAudioEngine.shared.stop()
    }

    // MARK: - Mode switch

    func switchMode(to newMode: AartiMode) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if newMode == .practice {
            stopGuidedPlayback()
        }
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            mode = newMode
            if newMode == .practice { selectedInstrument = .ghanti }  // always land on Ghanti
            expandedInstrument = nil
        }
    }

    // MARK: - Practice: selection + tapping

    func selectInstrument(_ instrument: InstrumentType) {
        guard selectedInstrument != instrument else { return }  // already selected — no-op
        // If leaving Shankh, stop the audio engine immediately
        if selectedInstrument == .shankh {
            ShankhAudioEngine.shared.stop()
            isBlowDetected = false
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedInstrument = instrument
            expandedInstrument = nil
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func toggleSpeedSlider(for instrument: InstrumentType) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.72)) {
            expandedInstrument = expandedInstrument == instrument ? nil : instrument
        }
    }

    // MARK: - Instrument playback

    func playInstrument(
        _ instrument: InstrumentType,
        tablaZone: TablaZone = .dayan,
        dholakZone: DholakZone = .treble
    ) {
        switch instrument {
        case .ghanti:
            BellAudioEngine.shared.ringBell(intensity: 0.9)
            HapticEngine.shared.playHeavyBellRing(intensity: 0.9)
            triggerRingFlash()
            UIAccessibility.post(notification: .announcement, argument: "Bell ringing.")
        case .shankh:
            ShankhAudioEngine.shared.play(intensity: 1.0)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        case .manjira:
            ManjiraAudioEngine.shared.clash(intensity: 0.85)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .tabla:
            if tablaZone == .bayan {
                TablaAudioEngine.shared.playBayan(intensity: 0.85)
            } else {
                TablaAudioEngine.shared.playDayan(intensity: 0.85)
            }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        case .dholak:
            if dholakZone == .bass {
                DholakAudioEngine.shared.playBass(intensity: 0.85)
            } else {
                DholakAudioEngine.shared.playTreble(intensity: 0.85)
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        case .damru:
            DamruAudioEngine.shared.strike(intensity: 0.9)
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }

    func stopShankh() { ShankhAudioEngine.shared.stop() }

    private func triggerRingFlash() {
        isRinging = true
        Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            isRinging = false
        }
    }

    // MARK: - Motion — shake to ring Ghanti (Practice mode)

    private func wireMotion() {
        swingCancellable = motionManager.$swingEnergy
            .receive(on: RunLoop.main)
            .sink { [weak self] energy in
                guard let self else { return }
                let now = Date()
                let shakeInstrument = self.selectedInstrument
                // Sensors are ONLY active in practice mode
                guard self.mode == .practice,
                shakeInstrument == .ghanti || shakeInstrument == .damru || shakeInstrument == .manjira,
                energy > self.motionManager.ringingThreshold,
                now.timeIntervalSince(self.lastRingTime) > self.bellCooldown
                        / (self.instrumentSpeeds[shakeInstrument] ?? 1.0)
            else { return }
            self.lastRingTime = now
            let intensity = Float(min(energy / 5.0, 1.0))
            if shakeInstrument == .ghanti {
                BellAudioEngine.shared.ringBell(intensity: intensity)
                HapticEngine.shared.playHeavyBellRing(intensity: intensity)
                self.triggerRingFlash()
                UIAccessibility.post(notification: .announcement, argument: "Bell ringing.")
            } else if shakeInstrument == .damru {
                DamruAudioEngine.shared.strike(intensity: intensity)
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                UIAccessibility.post(notification: .announcement, argument: "Damru struck.")
            } else {
                // Manjira — clash on shake
                ManjiraAudioEngine.shared.clash(intensity: intensity)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                UIAccessibility.post(notification: .announcement, argument: "Manjira clashed.")
            }
        }
    }

    // MARK: - Mic — blow to sound Shankh (Practice mode)

    private func wireMic() {
        blowCancellable = micManager.$micLevel
            .receive(on: RunLoop.main)
            .sink { [weak self] level in
                guard let self else { return }
                self.micLevel = level
                let blowing = level > self.blowThreshold
                // Only active in practice mode
                guard self.mode == .practice else {
                    if self.isBlowDetected { self.isBlowDetected = false }
                    return
                }
                // Only act when Shankh is the active instrument
                guard self.selectedInstrument == .shankh else {
                    if self.isBlowDetected { self.isBlowDetected = false }
                    return
                }
                let now = Date()
                if blowing && !self.isBlowDetected
                    && now.timeIntervalSince(self.lastBlowTime) > self.blowDebounce
                {
                    self.lastBlowTime = now
                    self.isBlowDetected = true
                    ShankhAudioEngine.shared.play(intensity: 1.0)
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                } else if !blowing && self.isBlowDetected {
                    self.isBlowDetected = false
                    ShankhAudioEngine.shared.stop()
                }
            }
    }

    // MARK: - Mic permission

    func checkMicPermission() {
        switch AVAudioApplication.shared.recordPermission {
        case .granted:
            micPermissionGranted = true
            micManager.startMonitoring()
        case .denied:
            micPermissionDenied = true
        case .undetermined:
            AVAudioApplication.requestRecordPermission { [weak self] granted in
                Task { @MainActor [weak self] in
                    self?.micPermissionGranted = granted
                    self?.micPermissionDenied = !granted
                    if granted { self?.micManager.startMonitoring() }
                }
            }
        @unknown default: break
        }
    }

    // MARK: - Guided Aarti: auto sequencer

    func startGuidedPlayback() {
        isGuidedPlaying = true
        currentBeat = 0
        AmbientAudioEngine.shared.play(type: .diyaCrackle)
        // Shankh plays as a continuous sacred drone throughout Aarti
        ShankhAudioEngine.shared.play(intensity: 0.45)
        UIAccessibility.post(notification: .announcement, argument: "Guided Aarti started.")
        scheduleNextBeat()
    }

    func stopGuidedPlayback() {
        sequencerTimer?.cancel()
        isGuidedPlaying = false
        ShankhAudioEngine.shared.stop()
        AmbientAudioEngine.shared.stop()
        UIAccessibility.post(notification: .announcement, argument: "Aarti stopped.")
    }

    func updateTempo() {
        guard isGuidedPlaying else { return }
        sequencerTimer?.cancel()
        scheduleNextBeat()
    }

    private func scheduleNextBeat() {
        sequencerTimer = Timer.publish(every: beatInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                let step = self.currentBeat % self.pattern.count
                // Per-instrument speed: higher speed = instrument fires more often
                if let instrument = self.pattern[step] {
                    let speed = self.instrumentSpeeds[instrument] ?? 1.0
                    // If speed >= 1: fire every time (or sub-divide)
                    // If speed < 1: probabilistic skip (fires less often)
                    let shouldFire = speed >= 1.0 || Double.random(in: 0...1) < speed
                    if shouldFire {
                        self.playInstrument(instrument)
                    }
                    // Extra fires for speed > 1
                    if speed >= 2.0 {
                        DispatchQueue.main.asyncAfter(deadline: .now() + self.beatInterval / 2) {
                            if self.isGuidedPlaying { self.playInstrument(instrument) }
                        }
                    }
                }
                withAnimation(.easeOut(duration: 0.08)) { self.currentBeat += 1 }
            }
    }
}
