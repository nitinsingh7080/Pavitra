import AVFoundation
import Combine
import CoreMotion
import SwiftUI

enum RitualObject: String, CaseIterable, Identifiable {
    case bell = "Ghanti"
    case shankh = "Shankh"
    case manjira = "Jhal"
    case dholak = "Dholak"
    case tabla = "Tabla"
    case damru = "Damru"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .bell: return "bell.fill"
        case .shankh: return "water.waves"
        case .manjira: return "circles.hexagonpath.fill"
        case .dholak: return "cylinder.fill"
        case .tabla: return "t.circle.fill"
        case .damru: return "hourglass"
        }
    }
}

enum ExperienceMode: String, CaseIterable {
    case tryTime = "Try Time"
    case aartiTime = "Aarti Time"
}

struct ImmersiveExperienceView: View {
    @StateObject private var motionManager = MotionManager()
    @StateObject private var micManager = MicManager()

    @State private var selectedObject: RitualObject = .bell
    @State private var currentMode: ExperienceMode = .tryTime
    @State private var activeAartiInstruments: Set<RitualObject> = []

    // Store individual speeds per instrument
    @State private var aartiSpeeds: [RitualObject: Double] = {
        var speeds = [RitualObject: Double]()
        for obj in RitualObject.allCases { speeds[obj] = 1.0 }
        return speeds
    }()

    // Master timer that ticks extremely fast, and we selectively trigger instruments based on modulo logic simulating parallel timers
    let masterTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State private var timerTicks: Int = 0

    // Bell State
    @State private var bellAngle: Double = 0
    @State private var isRinging = false
    @State private var lastRingTime: Date = Date()
    @State private var bellScale: CGFloat = 1.0

    // Damru State
    @State private var damruAngle: Double = 0
    @State private var lastDamruHitTime: Date = Date()

    // Shankh State
    @ObservedObject private var shankhEngine = ShankhAudioEngine.shared
    @State private var isShankhButtonPressed: Bool = false

    // Manjira State
    @State private var manjiraScale: CGFloat = 1.0
    @State private var manjiraOffset: CGFloat = 0.0

    // Dholak State
    @State private var dholakLeftScale: CGFloat = 1.0
    @State private var dholakRightScale: CGFloat = 1.0

    // Tabla State
    @State private var bayanScale: CGFloat = 1.0
    @State private var bayanPressure: Float = 0.0
    @State private var dayanScale: CGFloat = 1.0

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                LinearGradient(
                    colors: [Color(.systemGroupedBackground), Color(.systemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 20) {

                    Spacer().frame(height: 10)

                    // MARK: - Mode Switcher
                    Picker("Mode", selection: $currentMode.animation()) {
                        ForEach(ExperienceMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 24)
                    .onChange(of: currentMode) { _, newMode in
                        if newMode == .tryTime {
                            activeAartiInstruments.removeAll()
                            ShankhAudioEngine.shared.stop()
                            // Stop ambient when leaving Aarti Time
                            AmbientAudioEngine.shared.stop()
                        } else if newMode == .aartiTime {
                            // Play low diya crackle ambient as atmosphere during Aarti
                            AmbientAudioEngine.shared.play(type: .diyaCrackle)
                        }
                    }

                    // MARK: - Object Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(RitualObject.allCases) { object in
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        selectedObject = object
                                    }
                                } label: {
                                    VStack(spacing: 8) {
                                        Image(systemName: object.iconName)
                                            .font(.title2)
                                        Text(object.rawValue)
                                            .font(.caption.bold())
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 20)
                                    .background(
                                        selectedObject == object
                                            ? Color.brown.opacity(0.8)
                                            : Color.black.opacity(0.05)
                                    )
                                    .foregroundColor(selectedObject == object ? .white : .primary)
                                    .clipShape(Capsule())
                                    .overlay(
                                        Capsule().stroke(
                                            Color.brown.opacity(0.5),
                                            lineWidth: selectedObject == object ? 2 : 0)
                                    )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 10)
                    .opacity(currentMode == .tryTime ? 1.0 : 0.0)  // Hide selector in Aarti time
                    .frame(height: currentMode == .tryTime ? nil : 0)  // Collapse space

                    Spacer()

                    // MARK: - Active Object View
                    if currentMode == .aartiTime {
                        aartiTimeView
                    } else {
                        TabView(selection: $selectedObject) {
                            bellView.tag(RitualObject.bell)
                            shankhView.tag(RitualObject.shankh)
                            manjiraView.tag(RitualObject.manjira)
                            dholakView.tag(RitualObject.dholak)
                            tablaView.tag(RitualObject.tabla)
                            damruView.tag(RitualObject.damru)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                        .frame(height: 350)
                    }

                    Spacer()
                }
            }
            .navigationTitle("Experience")
        }
        .onAppear {
            motionManager.startDeviceMotion()
            HapticEngine.shared.prepareHaptics()
            micManager.startMonitoring()
        }
        .onDisappear {
            motionManager.stop()
            micManager.stopMonitoring()
            ShankhAudioEngine.shared.stop()
            AmbientAudioEngine.shared.stop()
        }
    }

    // MARK: - Views

    private func toggleAartiInstrument(_ object: RitualObject) {
        if activeAartiInstruments.contains(object) {
            activeAartiInstruments.remove(object)
            if object == .shankh { ShankhAudioEngine.shared.stop() }
        } else {
            activeAartiInstruments.insert(object)
            if object == .shankh {
                ShankhAudioEngine.shared.play(intensity: 1.0)
            } else {
                triggerAartiInstrument(object)
            }
        }
    }

    private func triggerAartiInstrument(_ object: RitualObject) {
        switch object {
        case .bell: triggerBellRing(intensity: 1.0)
        case .manjira:
            ManjiraAudioEngine.shared.clash(intensity: 1.0)
            HapticEngine.shared.playLightSpark()
        case .dholak:
            DholakAudioEngine.shared.playBass(intensity: 1.0)
            HapticEngine.shared.playHeavyBellRing(intensity: 0.8)
        case .tabla:
            TablaAudioEngine.shared.playDayan(intensity: 1.0)
            HapticEngine.shared.playLightSpark()
        case .damru:
            DamruAudioEngine.shared.strike(intensity: 1.0)
            HapticEngine.shared.playHeavyBellRing(intensity: 0.8)
        case .shankh: break
        }
    }

    private var aartiTimeView: some View {
        VStack(spacing: 15) {
            Text("Play multiple instruments simultaneously!")
                .font(.subheadline)
                .foregroundColor(.secondary)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(RitualObject.allCases) { object in
                        AartiRow(
                            object: object,
                            isActive: activeAartiInstruments.contains(object),
                            speed: binding(for: object),
                            toggleAction: { toggleAartiInstrument(object) }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .frame(height: 420)
        .onReceive(masterTimer) { _ in
            timerTicks += 1

            for object in activeAartiInstruments where object != .shankh {
                // Calculate ticks needed for this instrument based on its speed
                // Base interval of 0.8s means 8 ticks at 0.1s.
                // Speed 1.0 => 8 ticks
                // Speed 2.0 => 4 ticks
                // Speed 0.5 => 16 ticks
                let speed = aartiSpeeds[object] ?? 1.0
                let targetTicks = max(Int(8.0 / speed), 1)

                if timerTicks % targetTicks == 0 {
                    triggerAartiInstrument(object)
                }
            }
        }
    }

    // Helper to get binding for dict
    private func binding(for key: RitualObject) -> Binding<Double> {
        return Binding(
            get: { self.aartiSpeeds[key] ?? 1.0 },
            set: { self.aartiSpeeds[key] = $0 }
        )
    }

    // MARK: - Single Instrument Views

    private var bellView: some View {
        VStack(spacing: 30) {
            Text("Swing your phone to ring the Ghanti")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)

            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(isRinging ? 0.3 : 0.0))
                    .frame(width: 150, height: 150)
                    .blur(radius: 20)
                    .animation(.easeOut(duration: 0.5), value: isRinging)

                Image(systemName: "bell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(red: 0.8, green: 0.6, blue: 0.2))  // Gold color
                    .rotationEffect(.degrees(bellAngle))
                    .scaleEffect(bellScale)
                    .animation(
                        .interactiveSpring(response: 0.4, dampingFraction: 0.3), value: bellAngle
                    )
                    .shadow(color: .yellow.opacity(0.4), radius: isRinging ? 15 : 5, x: 0, y: 0)
            }
            .frame(height: 200)
            .onChange(of: motionManager.swingEnergy) { _, newValue in
                if selectedObject == .bell && newValue > motionManager.ringingThreshold
                    && Date().timeIntervalSince(lastRingTime) > 0.3
                {
                    triggerBellRing(intensity: Float(min(newValue / 5.0, 1.0)))
                }
            }
        }
    }

    private var damruView: some View {
        VStack(spacing: 30) {
            Text("Shake your phone to play the Damru")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundColor(.secondary)

            ZStack {
                // Damru icon with shake animation
                Image(systemName: "hourglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color.brown)
                    .rotationEffect(.degrees(damruAngle))
                    .animation(
                        .interactiveSpring(response: 0.2, dampingFraction: 0.5), value: damruAngle
                    )
                    .shadow(color: .orange.opacity(0.3), radius: 10)
            }
            .frame(height: 250)
            .onChange(of: motionManager.swingEnergy) { _, newValue in
                if selectedObject == .damru && newValue > 1.2
                    && Date().timeIntervalSince(lastDamruHitTime) > 0.12
                {
                    lastDamruHitTime = Date()

                    // Simple shake visual flip
                    self.damruAngle = self.damruAngle > 0 ? -45 : 45

                    let intensity = Float(min(newValue / 3.0, 1.0))
                    DamruAudioEngine.shared.strike(intensity: intensity)
                    HapticEngine.shared.playHeavyBellRing(intensity: intensity)  // Reusing sharp snap haptic

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        if Date().timeIntervalSince(lastDamruHitTime) >= 0.1 {
                            self.damruAngle = 0
                        }
                    }
                }
            }
        }
    }

    private var shankhView: some View {
        VStack(spacing: 30) {
            Text(
                micManager.isBlowing ? "Blowing..." : "Blow into the microphone to play the Shankh"
            )
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .font(.subheadline)

            VStack(spacing: 20) {
                // Use state to overlay animations when either blowing or pressing the button
                let isPlayingShankh = micManager.isBlowing || isShankhButtonPressed

                ZStack {
                    // Expanding radiating waves based on mic level or button press
                    ForEach(0..<3) { i in
                        Circle()
                            .stroke(
                                Color(red: 0.9, green: 0.8, blue: 0.6),
                                lineWidth: isPlayingShankh ? 2 : 0
                            )
                            .scaleEffect(isPlayingShankh ? CGFloat(1.5 + Double(i) * 0.5) : 1.0)
                            .opacity(isPlayingShankh ? (1.0 - Double(i) * 0.3) : 0.0)
                            .frame(width: 100, height: 100)
                            .animation(
                                .linear(duration: 1.0).repeatForever(autoreverses: false).delay(
                                    Double(i) * 0.3), value: isPlayingShankh)
                    }

                    Image(systemName: "water.waves")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(isPlayingShankh ? .blue : .blue.opacity(0.4))
                        .shadow(color: .blue, radius: isPlayingShankh ? 10 : 0)
                }
                .frame(height: 150)

                // Press-and-hold play button
                VStack(spacing: 8) {
                    Text("PRESS & HOLD TO PLAY")
                        .font(.caption2.bold())
                        .foregroundColor(.secondary)

                    Circle()
                        .fill(
                            isShankhButtonPressed
                                ? Color(red: 0.8, green: 0.6, blue: 0.3)
                                : Color.secondary.opacity(0.1)
                        )
                        .frame(width: 70, height: 70)
                        .overlay(
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundColor(
                                    isShankhButtonPressed ? .white : .secondary.opacity(0.7)
                                )
                                .font(.title)
                        )
                        .scaleEffect(isShankhButtonPressed ? 0.9 : 1.0)
                        .animation(
                            .spring(response: 0.2, dampingFraction: 0.6),
                            value: isShankhButtonPressed
                        )
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in
                                    if !self.isShankhButtonPressed {
                                        self.isShankhButtonPressed = true
                                        shankhEngine.play(intensity: 1.0)
                                        HapticEngine.shared.playHeavyBellRing(intensity: 0.8)
                                    }
                                }
                                .onEnded { _ in
                                    self.isShankhButtonPressed = false
                                    if !micManager.isBlowing {
                                        shankhEngine.stop()
                                    }
                                }
                        )
                }
            }
            .onChange(of: micManager.isBlowing) { _, isBlowing in
                if selectedObject == .shankh {
                    if isBlowing {
                        // Map -15dB to 0dB to a 0.5 - 1.0 intensity scale
                        let normalizedIntensity = min(
                            max((micManager.micLevel + 25.0) / 25.0, 0.1), 1.0)
                        shankhEngine.play(intensity: Float(normalizedIntensity))
                        HapticEngine.shared.playHeavyBellRing(intensity: 0.8)  // Reusing heavy continuous haptic
                    } else if !isShankhButtonPressed {
                        shankhEngine.stop()
                    }
                }
            }
            // Stop playing if user swipes away from the Shankh tab
            .onChange(of: selectedObject) { _, newValue in
                if newValue != .shankh {
                    shankhEngine.stop()
                }
            }
        }
    }

    private var manjiraView: some View {
        VStack(spacing: 40) {
            Text("Drag apart and release to smash the Manjira\n(or just tap quickly)")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)

            HStack(spacing: 2 + self.manjiraOffset) {
                // Left cymbal
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.yellow, Color(red: 0.8, green: 0.5, blue: 0.1),
                            ]), center: .center, startRadius: 5, endRadius: 40)
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .orange.opacity(0.5), radius: 10)
                    .rotation3DEffect(
                        .degrees(manjiraOffset > 0 ? 15 : 0), axis: (x: 0, y: 1, z: 0))

                // Right cymbal
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.yellow, Color(red: 0.8, green: 0.5, blue: 0.1),
                            ]), center: .center, startRadius: 5, endRadius: 40)
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: .orange.opacity(0.5), radius: 10)
                    .rotation3DEffect(
                        .degrees(manjiraOffset > 0 ? -15 : 0), axis: (x: 0, y: 1, z: 0))
            }
            .scaleEffect(manjiraScale)
            .background(Color.white.opacity(0.001))  // Hit testing area
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                            self.manjiraOffset = 60.0  // Pull apart
                        }
                    }
                    .onEnded { value in
                        // Snap together and clash
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.3)) {
                            self.manjiraOffset = 0.0
                            self.manjiraScale = 1.3
                        }

                        // Play highly realistic synthesized clash
                        let dragIntensity =
                            abs(value.translation.width) + abs(value.translation.height)
                        let audioIntensity = min(Float(dragIntensity) / 100.0 + 0.6, 1.0)

                        ManjiraAudioEngine.shared.clash(intensity: audioIntensity)
                        HapticEngine.shared.playHeavyBellRing(intensity: 0.8)  // Reusing heavy strike

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                                self.manjiraScale = 1.0
                            }
                        }
                    }
            )
        }
        .frame(height: 250)
    }

    private var dholakView: some View {
        VStack(spacing: 30) {
            Text("Tap left side for Bass (Ge)\nTap right side for Treble (Na)")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)

            HStack(spacing: 0) {
                // Left Head (Bass/Ge)
                Rectangle()
                    .fill(Color.white.opacity(0.01))  // Hit area
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .overlay(
                        Circle()
                            .fill(Color(red: 0.6, green: 0.3, blue: 0.1))
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(Color.black.opacity(0.4), lineWidth: 8))
                            .scaleEffect(dholakLeftScale)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                            dholakLeftScale = 1.15
                        }
                        DholakAudioEngine.shared.playBass(intensity: 1.0)
                        HapticEngine.shared.playHeavyBellRing(intensity: 0.9)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring()) {
                                dholakLeftScale = 1.0
                            }
                        }
                    }

                // Rope/Body Separator
                Rectangle()
                    .fill(Color.orange.opacity(0.5))
                    .frame(width: 20, height: 160)
                    .cornerRadius(5)

                // Right Head (Treble/Na)
                Rectangle()
                    .fill(Color.white.opacity(0.01))  // Hit area
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .overlay(
                        Circle()
                            .fill(Color(red: 0.8, green: 0.7, blue: 0.5))
                            .frame(width: 90, height: 90)
                            .overlay(Circle().stroke(Color.black.opacity(0.4), lineWidth: 6))
                            .scaleEffect(dholakRightScale)
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.1, dampingFraction: 0.4)) {
                            dholakRightScale = 1.15
                        }
                        DholakAudioEngine.shared.playTreble(intensity: 1.0)
                        HapticEngine.shared.playLightSpark()

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring()) {
                                dholakRightScale = 1.0
                            }
                        }
                    }
            }
            .padding(.horizontal)
            .frame(height: 250)
        }
    }

    private var tablaView: some View {
        VStack(spacing: 30) {
            Text("Tap Left (Bayan) & drag down to bend pitch\nTap Right (Dayan) for sharp hits")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .font(.subheadline)

            HStack(spacing: 20) {
                // Bayan (Left Bass Drum)
                ZStack {
                    // Drum body (copper/brass sphere-ish)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.9, green: 0.6, blue: 0.3),
                                    Color(red: 0.5, green: 0.3, blue: 0.1),
                                ]), center: .top, startRadius: 10, endRadius: 80)
                        )
                        .frame(width: 140, height: 140)

                    // The skin and black spot (Syahi - off center)
                    Circle()
                        .fill(Color(white: 0.9))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .fill(Color.black.opacity(0.85))
                                .frame(width: 50, height: 50)
                                .offset(x: 20, y: -20)
                        )
                        .scaleEffect(bayanScale)
                }
                .contentShape(Rectangle())  // Capture drags anywhere in zone
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            // If just started tapping
                            if self.bayanScale == 1.0 {
                                withAnimation(.spring(response: 0.15, dampingFraction: 0.5)) {
                                    self.bayanScale = 0.95
                                }
                                // Initial hit, no pressure
                                self.bayanPressure = 0.0
                                TablaAudioEngine.shared.playBayan(intensity: 1.0, pressure: 0.0)
                                HapticEngine.shared.playHeavyBellRing(intensity: 0.9)
                            } else {
                                // Calculate pressure based on downward drag distance
                                let distance = max(0, value.translation.height)
                                let pressure = min(Float(distance) / 100.0, 1.0)
                                self.bayanPressure = pressure

                                // Modulate the playing synthesizer pitch
                                TablaAudioEngine.shared.modulateBayanPressure(pressure)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                self.bayanScale = 1.0
                            }
                            self.bayanPressure = 0.0
                        }
                )

                // Dayan (Right Treble Drum)
                ZStack {
                    // Drum body (wooden cylinder-ish)
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.brown, Color(red: 0.3, green: 0.15, blue: 0.05),
                                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 110, height: 130)

                    // The skin and centered black spot
                    Circle()
                        .fill(Color(white: 0.9))
                        .frame(width: 100, height: 100)
                        .overlay(
                            Circle()
                                .fill(Color.black.opacity(0.9))
                                .frame(width: 45, height: 45)
                        )
                        .offset(y: -15)
                        .scaleEffect(dayanScale)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if self.dayanScale == 1.0 {
                                withAnimation(.spring(response: 0.1, dampingFraction: 0.4)) {
                                    self.dayanScale = 0.9
                                }
                                TablaAudioEngine.shared.playDayan(intensity: 1.0)
                                HapticEngine.shared.playLightSpark()
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring()) {
                                self.dayanScale = 1.0
                            }
                        }
                )
            }
            .frame(height: 250)
        }
    }

    // MARK: - Logic

    private func triggerBellRing(intensity: Float) {
        lastRingTime = Date()
        isRinging = true

        // Output Sound!
        BellAudioEngine.shared.ringBell(intensity: intensity)

        // Haptic feedback
        HapticEngine.shared.playHeavyBellRing(intensity: intensity)

        // Visual swing based on intensity and direction of movement
        // We use the rotation rate X to determine direction of swing
        let direction: Double = motionManager.rotationRate.x > 0 ? 1 : -1
        let targetAngle = 30.0 * direction * Double(intensity)

        withAnimation(.interactiveSpring(response: 0.2, dampingFraction: 0.2)) {
            bellAngle = targetAngle
            bellScale = 1.1  // Slight pop
        }

        // Swiftly return it to rest
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.4)) {
                bellAngle = 0
                bellScale = 1.0
                isRinging = false
            }
        }
    }
}

// MARK: - Advanced Animated Flame using Canvas and TimelineView
struct FlameView: View {
    var tilt: Double

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Base width and height of the flame
                let width = size.width
                let height = size.height

                // Calculate dynamic flickering variations
                let swayX = sin(time * 5.0) * 4.0 + sin(time * 12.0) * 2.0
                let heightPulse = cos(time * 8.0) * 8.0

                // Create the central intense flame (yellow/white)
                var centralFlame = Path()
                let px = width / 2 + swayX
                // Adjust tilt based on device roll. Roll goes from ~ -1.5 to 1.5. Multiply by a constant to bend flame.
                let tiltBend = tilt * -30.0

                centralFlame.move(to: CGPoint(x: width / 2, y: height))
                // Control points define the teardrop shape bending upward
                centralFlame.addCurve(
                    to: CGPoint(x: px + tiltBend, y: 10 + heightPulse),
                    control1: CGPoint(x: width / 2 + 10, y: height - 20),
                    control2: CGPoint(x: px + tiltBend + 5, y: 30 + heightPulse)
                )
                centralFlame.addCurve(
                    to: CGPoint(x: width / 2, y: height),
                    control1: CGPoint(x: px + tiltBend - 5, y: 30 + heightPulse),
                    control2: CGPoint(x: width / 2 - 10, y: height - 20)
                )

                context.fill(centralFlame, with: .color(Color.white.opacity(0.8)))

                // Create the outer blurred aura (orange/red)
                let outerFlame = centralFlame
                let scaleTransform = CGAffineTransform(scaleX: 1.4, y: 1.2)
                    .concatenating(CGAffineTransform(translationX: -width * 0.2, y: -height * 0.1))
                let transformedOuter = outerFlame.applying(scaleTransform)

                // Draw the orange core glow
                context.fill(transformedOuter, with: .color(Color.orange.opacity(0.6)))

                // Add a red outer glow behind everything (blur must be applied outside the canvas usually, but we can fake it with opacity layers)
                let scaleTransform2 = CGAffineTransform(scaleX: 1.8, y: 1.4)
                    .concatenating(CGAffineTransform(translationX: -width * 0.4, y: -height * 0.2))
                let transformedRed = outerFlame.applying(scaleTransform2)
                context.fill(transformedRed, with: .color(Color.red.opacity(0.3)))
            }
            // Add native SwiftUI blur and blend modes for incredible glowing effects!
            .blur(radius: 2.0)
            .blendMode(.screen)
        }
    }
}

// MARK: - Advanced Animated Agarbatti Smoke Simulator
struct SmokeParticleView: View {
    var dragOffset: CGSize
    var isWaving: Bool

    // We use a Canvas and TimelineView to simulate curling smoke trails mathematically
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                let cx = size.width / 2
                let cy = size.height - 20  // Start smoke from bottom

                // When we drag the incense stick, the smoke source moves
                let sourceX = cx + dragOffset.width / 4
                let sourceY = cy + dragOffset.height / 4

                // Waving intensifies the curling and spread of smoke
                let waveIntensity = isWaving ? 3.0 : 1.0

                for i in 0..<15 {
                    // Spread phases out for infinite looping
                    let tOffset = Double(i) * 0.4
                    // Math modulo to loop time from 0 to 1
                    let localTime = fmod(time * 0.2 + tOffset, 1.0)

                    guard localTime > 0.05 else { continue }  // Delay spawn slightly

                    var path = Path()
                    path.move(to: CGPoint(x: sourceX, y: sourceY))

                    // Parametric curve for drifting smoke upwards
                    // y-axis goes up, losing y over time
                    let heightReached = cy - (CGFloat(localTime) * size.height * 0.8)

                    // Sinewaves to create curl
                    let swaySpeed = time * 0.8
                    let indexNoise = Double(i) * 31.4  // Psuedo-random variance

                    let driftX = sin(swaySpeed + indexNoise) * 30.0 * localTime * waveIntensity
                    // Additional drag offset inherited by older particles
                    let momentumX = (dragOffset.width * 0.3) * (1.0 - localTime)

                    let endPoint = CGPoint(x: sourceX + driftX + momentumX, y: heightReached)

                    // Control points bend in opposite directions to create 'S' curve
                    let cp1 = CGPoint(
                        x: sourceX - driftX * 1.5, y: sourceY - (sourceY - heightReached) * 0.3)
                    let cp2 = CGPoint(
                        x: sourceX + driftX * 1.5, y: sourceY - (sourceY - heightReached) * 0.7)

                    path.addCurve(to: endPoint, control1: cp1, control2: cp2)

                    // Smoke fades out as it rises (localTime approaches 1.0)
                    let opacity = (1.0 - localTime) * 0.3

                    // Thicker at the bottom, wider spread at top
                    let lineWidth = 2.0 + (localTime * 10.0)

                    context.stroke(
                        path,
                        with: .color(Color(white: 0.9, opacity: opacity)),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                }
            }
            .blur(radius: 4.0)  // Soften the math lines into actual "smoke"
            .blendMode(.screen)
        }
    }
}

// MARK: - Aarti Row
struct AartiRow: View {
    let object: RitualObject
    let isActive: Bool
    @Binding var speed: Double
    let toggleAction: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Main Button
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    toggleAction()
                }
            }) {
                Group {
                    if isActive {
                        VStack(spacing: 6) {
                            Image(systemName: object.iconName)
                                .font(.system(size: 24))
                            Text(object.rawValue)
                                .font(.caption.bold())
                        }
                        .foregroundColor(.white)
                        .frame(width: 80)
                        .padding(.vertical, 12)
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: object.iconName)
                                .font(.system(size: 20))
                                .foregroundColor(.brown)
                                .frame(width: 30)

                            Text(object.rawValue)
                                .font(.subheadline.bold())
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                .background(isActive ? Color.brown : Color.white.opacity(0.8))
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)

            // Right Side
            if isActive {
                if object != .shankh {
                    HStack(spacing: 8) {
                        Text(String(format: "%.1fx", speed))
                            .font(.caption2.bold())
                            .foregroundColor(.brown)
                            .frame(width: 30)

                        Slider(value: $speed, in: 0.5...2.5, step: 0.1)
                            .tint(.brown)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxHeight: .infinity)
                    .background(Color.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.leading, 8)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                } else {
                    Spacer()
                }
            }
        }
        .padding(.horizontal, 4)
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 3)
    }
}
