import AVFoundation
import SwiftUI

// MARK: - AartiView — Main Aarti Tab

struct AartiView: View {
    @StateObject private var viewModel = AartiViewModel()
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer(minLength: 32)

                AartiSegmentedControl(selected: viewModel.mode) { newMode in
                    viewModel.switchMode(to: newMode)
                }
                .padding(.horizontal, 32)

                Spacer(minLength: 28)

                if viewModel.mode == .practice {
                    practiceView
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                } else {
                    guidedView
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                }

                Spacer(minLength: 50)
            }
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Aarti")
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .animation(.spring(response: 0.42, dampingFraction: 0.78), value: viewModel.mode)
    }

    // MARK: — Header

    private var headerArea: some View {
        VStack(spacing: 6) {
            Text("ॐ")
                .font(.system(size: 46, weight: .ultraLight, design: .serif))
                .foregroundColor(AppTheme.accent)
                .shadow(color: AppTheme.accent.opacity(0.7), radius: 14)
                .accessibilityLabel("Om")
            Text("Aarti")
                .font(AppTheme.heroFont)
                .foregroundColor(AppTheme.primaryText)
            Text("A guided devotional experience")
                .font(AppTheme.subheadingFont)
                .foregroundColor(AppTheme.secondaryText)
                .tracking(0.4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: — Practice Mode

    private var practiceView: some View {
        VStack(spacing: 20) {
            // Context hints
            VStack(spacing: 5) {
                HStack(spacing: 16) {
                    Label("Shake = Ghanti", systemImage: "iphone.motion")
                    Label("Shake = Manjira", systemImage: "iphone.motion")
                }
                Label("Blow = Shankh", systemImage: "mic.fill")
            }
            .font(AppTheme.caption2Font)
            .foregroundColor(AppTheme.secondaryText)

            // All 6 instruments — 3×2 grid (clean, no speed badge on chips)
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ],
                spacing: 12
            ) {
                ForEach(InstrumentType.allCases) { inst in
                    PracticeInstrumentCard(
                        instrument: inst,
                        viewModel: viewModel,
                        isSelected: viewModel.selectedInstrument == inst
                    )
                }
            }
            .padding(.horizontal, 16)

            // ── Frequency control (above the play pad, non-Shankh only)
            if viewModel.selectedInstrument != .shankh {
                FrequencyControlPanel(
                    instrument: viewModel.selectedInstrument,
                    viewModel: viewModel
                )
                .padding(.horizontal, 24)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // ── Large play pad (always visible)
            Divider().background(AppTheme.primaryText.opacity(0.08)).padding(.horizontal, 32)
            ActivePlayPad(instrument: viewModel.selectedInstrument, viewModel: viewModel)
                .padding(.horizontal, 32)
        }
    }

    // MARK: — Guided Mode

    private var guidedView: some View {
        VStack(spacing: 20) {

            // ── 1. Begin / Stop Aarti button (TOP)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.isGuidedPlaying
                        ? viewModel.stopGuidedPlayback() : viewModel.startGuidedPlayback()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.isGuidedPlaying ? "stop.fill" : "play.fill")
                        .font(.title3.bold())
                    Text(viewModel.isGuidedPlaying ? "Stop Aarti" : "Begin Aarti")
                        .font(.system(.headline, design: .serif, weight: .semibold))
                }
                .foregroundColor(AppTheme.pageBackground)
                .padding(.vertical, 16)
                .padding(.horizontal, 44)
                .background(viewModel.isGuidedPlaying ? Color.red.opacity(0.9) : AppTheme.accent)
                .clipShape(Capsule())
                .shadow(
                    color: (viewModel.isGuidedPlaying ? Color.red : AppTheme.accent).opacity(0.4),
                    radius: 14)
            }
            .scaleEffect(viewModel.isGuidedPlaying ? 1.04 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6), value: viewModel.isGuidedPlaying
            )
            .accessibilityLabel(viewModel.isGuidedPlaying ? "Stop Aarti" : "Begin Aarti")

            // ── 2. Master Tempo slider (TOP)
            VStack(spacing: 6) {
                HStack {
                    Text("Master Tempo")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText.opacity(0.5))
                    Spacer()
                    Text("\(Int(108.0 * viewModel.tempoMultiplier)) BPM")
                        .font(.system(.caption, design: .serif, weight: .bold))
                        .foregroundColor(AppTheme.primaryText)
                }
                Slider(value: $viewModel.tempoMultiplier, in: 0.5...2.0, step: 0.05) { _ in
                    viewModel.updateTempo()
                }
                .tint(AppTheme.accent)
                HStack {
                    Text("Slow").font(.caption2).foregroundColor(AppTheme.primaryText.opacity(0.3))
                    Spacer()
                    Text("Fast").font(.caption2).foregroundColor(AppTheme.primaryText.opacity(0.3))
                }
            }
            .padding(.horizontal, 28)

            // ── 3. Beat visualiser
            BeatVisualiser(currentBeat: viewModel.currentBeat, isPlaying: viewModel.isGuidedPlaying)
                .frame(height: 44)
                .padding(.horizontal, 24)

            // ── 4. Only 3 active instruments: Ghanti, Manjira, Shankh (drone)
            VStack(spacing: 10) {
                ForEach([InstrumentType.ghanti, .manjira, .shankh]) { inst in
                    GuidedInstrumentRow(instrument: inst, viewModel: viewModel)
                }
            }
            .padding(.horizontal, 16)
        }
    }

}

// MARK: - Practice Instrument Card (clean, equal height)

private struct PracticeInstrumentCard: View {
    let instrument: InstrumentType
    @ObservedObject var viewModel: AartiViewModel
    let isSelected: Bool

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // Per-instrument animation states
    @State private var iconAngle:  Double  = 0   // Ghanti swing, Damru spin
    @State private var iconOffset: CGFloat = 0   // Manjira side-clash
    @State private var iconScale:  CGFloat = 1.0 // Tabla/Dholak thump, Shankh pulse

    private var isFlashing: Bool { instrument == .ghanti && viewModel.isRinging }
    private var isBlowing:  Bool { instrument == .shankh && viewModel.isBlowDetected }
    private var isActive:   Bool { isFlashing || isBlowing }

    var body: some View {
        Button {
            viewModel.selectInstrument(instrument)
            triggerAnimation()
        } label: {
            VStack(spacing: 6) {
                Image(systemName: instrument.icon)
                    .font(.system(size: isSelected ? 26 : 20, weight: .semibold))
                    .foregroundColor(
                        isActive
                            ? AppTheme.primaryText
                            : AppTheme.primaryText.opacity(isSelected ? 0.85 : 0.52)
                    )
                    .shadow(
                        color: isActive
                            ? AppTheme.accent
                            : (isSelected ? AppTheme.accent.opacity(0.6) : .clear),
                        radius: isActive ? 12 : 8
                    )
                    // Instrument-specific animations stacked
                    .rotationEffect(.degrees(iconAngle))
                    .offset(x: iconOffset)
                    .scaleEffect(iconScale)
                    .scaleEffect(isActive && !reduceMotion ? 1.12 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isActive)

                Text(LocalizedStringKey(instrument.rawValue))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText.opacity(isSelected ? 0.85 : 0.45))
                    .tracking(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 70)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isActive
                            ? AppTheme.accent.opacity(0.9)
                            : isSelected
                                ? AppTheme.accent.opacity(0.65)
                                : AppTheme.accent.opacity(0.2),
                        lineWidth: isActive ? 1.5 : 1)
            )
            .shadow(color: isActive ? AppTheme.accent.opacity(0.35) : AppTheme.accent.opacity(0.06), radius: isActive ? 10 : 8, x: 0, y: 3)
            .scaleEffect(isSelected && !reduceMotion ? 1.04 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.65), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(instrument.rawValue)
        .accessibilityHint(instrument.practiceHint)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onChange(of: isActive) { _, active in
            if active { triggerAnimation() }
        }
    }

    /// Fires a realistic micro-animation per instrument type
    private func triggerAnimation() {
        guard !reduceMotion else { return }
        switch instrument {
        case .ghanti:
            // Bell swing — rotate right then spring back with decay
            withAnimation(.spring(response: 0.18, dampingFraction: 0.32)) { iconAngle = 28 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                withAnimation(.spring(response: 0.55, dampingFraction: 0.28)) { iconAngle = 0 }
            }
        case .damru:
            // Rapid spin back-and-forth
            withAnimation(.spring(response: 0.10, dampingFraction: 0.28)) { iconAngle = 34 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.18, dampingFraction: 0.25)) { iconAngle = -22 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.40)) { iconAngle = 0 }
                }
            }
        case .manjira:
            // Two plates clashing — quick left then right bounce
            withAnimation(.spring(response: 0.09, dampingFraction: 0.32)) { iconOffset = -7 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.09) {
                withAnimation(.spring(response: 0.11, dampingFraction: 0.28)) { iconOffset = 7 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                    withAnimation(.spring(response: 0.42, dampingFraction: 0.45)) { iconOffset = 0 }
                }
            }
        case .tabla, .dholak:
            // Drum thump — scale up then spring back
            withAnimation(.spring(response: 0.09, dampingFraction: 0.38)) { iconScale = 1.25 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                withAnimation(.spring(response: 0.40, dampingFraction: 0.50)) { iconScale = 1.0 }
            }
        case .shankh:
            // Conch blow — gentle scale swell
            withAnimation(.easeInOut(duration: 0.22)) { iconScale = 1.20 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.30)) { iconScale = 1.0 }
            }
        }
    }
}

// MARK: - Frequency Control Panel (above the active play pad)

private struct FrequencyControlPanel: View {
    let instrument: InstrumentType
    @ObservedObject var viewModel: AartiViewModel

    // Theme handled by AppTheme

    private var speed: Double {
        viewModel.instrumentSpeeds[instrument] ?? 1.0
    }

    private var speedLabel: String {
        switch speed {
        case ..<0.5: return "Very Slow"
        case ..<1.0: return "Slow"
        case 1.0: return "Normal"
        case ..<2.0: return "Frequent"
        default: return "Rapid"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header row
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Adjust Frequency")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText.opacity(0.75))
                    Text("Controls how often \(String(localized: String.LocalizationValue(instrument.rawValue))) plays when playing")
                        .font(.system(size: 10, design: .serif))
                        .foregroundColor(AppTheme.primaryText.opacity(0.38))
                }
                Spacer()
                // Speed badge
                Text(String(format: "%.2g× · %@", speed, speedLabel))
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(AppTheme.accent.opacity(0.12))
                            .overlay(Capsule().stroke(AppTheme.accent.opacity(0.4), lineWidth: 1)))
            }

            // Slider
            Slider(
                value: Binding(
                    get: { viewModel.instrumentSpeeds[instrument] ?? 1.0 },
                    set: { viewModel.instrumentSpeeds[instrument] = $0 }
                ),
                in: 0.25...3.0, step: 0.25
            )
            .tint(AppTheme.accent)

            HStack {
                Text("¼× (rare)").font(.system(size: 9)).foregroundColor(
                    AppTheme.primaryText.opacity(0.25))
                Spacer()
                Text("3× (rapid)").font(.system(size: 9)).foregroundColor(
                    AppTheme.primaryText.opacity(0.25))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: AppTheme.accent.opacity(0.06), radius: 8, x: 0, y: 3)
        .animation(.spring(response: 0.3, dampingFraction: 0.75), value: instrument)
    }
}

// MARK: - Active Play Pad (practice mode, selected instrument)

private struct ActivePlayPad: View {
    let instrument: InstrumentType
    @ObservedObject var viewModel: AartiViewModel

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var isPressed = false
    @State private var glowScale: CGFloat = 1.0
    @State private var ripple: CGFloat = 0.6
    @State private var rippleOp: Double = 0

    // Theme handled by AppTheme

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.accent.opacity(isPressed ? 0.28 : 0.0), .clear],
                        center: .center, startRadius: 10, endRadius: 90
                    )
                )
                .frame(width: 180, height: 180)
                .scaleEffect(glowScale)
                .animation(.easeInOut(duration: 0.25), value: isPressed)

            // Ripple
            if !reduceMotion {
                Circle().stroke(AppTheme.accent.opacity(rippleOp), lineWidth: 2)
                    .frame(width: 140, height: 140).scaleEffect(ripple)
            }

            switch instrument {
            case .tabla: tablaPad
            case .dholak: dholakPad
            default: singlePad
            }
        }
        .frame(height: 200)
    }

    // Generic single-tap pad
    private var singlePad: some View {
        Button {
            triggerPlay(instrument)
        } label: {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Circle().stroke(
                            isPressed ? AppTheme.accent.opacity(0.9) : AppTheme.accent.opacity(0.3),
                            lineWidth: isPressed ? 2 : 1)
                    )
                    .shadow(color: AppTheme.accent.opacity(isPressed ? 0.25 : 0.08), radius: 10, x: 0, y: 3)
                    .frame(width: 140, height: 140)
                VStack(spacing: 10) {
                    Image(systemName: instrument.icon)
                        .font(.system(size: 42, weight: .light))
                        .foregroundColor(isPressed ? AppTheme.accent : AppTheme.accent.opacity(0.6))
                    Text(LocalizedStringKey(instrument.rawValue))
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText.opacity(0.55))
                }
                .scaleEffect(isPressed && !reduceMotion ? 1.1 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPressed)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(instrument.rawValue)
        .simultaneousGesture(
            instrument == .shankh
                ? DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed {
                            isPressed = true
                            viewModel.playInstrument(.shankh)
                            startGlow()
                            fireRipple()
                        }
                    }
                    .onEnded { _ in
                        isPressed = false
                        viewModel.stopShankh()
                    }
                : nil
        )
    }

    // Tabla: Bayan | Dayan
    private var tablaPad: some View {
        HStack(spacing: 16) {
            splitSide("Bayan") {
                viewModel.playInstrument(.tabla, tablaZone: .bayan)
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                fireRipple()
            }
            splitSide("Dayan") {
                viewModel.playInstrument(.tabla, tablaZone: .dayan)
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                fireRipple()
            }
        }
    }

    // Dholak: Bass | Treble
    private var dholakPad: some View {
        HStack(spacing: 16) {
            splitSide("Bass") {
                viewModel.playInstrument(.dholak, dholakZone: .bass)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                fireRipple()
            }
            splitSide("Treble") {
                viewModel.playInstrument(.dholak, dholakZone: .treble)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                fireRipple()
            }
        }
    }

    private func splitSide(_ label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: instrument.icon)
                    .font(.system(size: 26)).foregroundColor(AppTheme.accent.opacity(0.7))
                Text(LocalizedStringKey(label))
                    .font(AppTheme.uiPillFont)
                    .foregroundColor(AppTheme.secondaryText)
            }
            .frame(width: 88, height: 88)
            .background(
                Circle().fill(.ultraThinMaterial)
                    .overlay(Circle().stroke(AppTheme.accent.opacity(0.3), lineWidth: 1))
                    .shadow(color: AppTheme.accent.opacity(0.08), radius: 8, x: 0, y: 3))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func triggerPlay(_ instrument: InstrumentType) {
        guard instrument != .shankh else { return }
        isPressed = true
        viewModel.playInstrument(instrument)
        startGlow()
        fireRipple()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { isPressed = false }
    }

    private func startGlow() {
        withAnimation(.easeInOut(duration: 0.18)) { glowScale = 1.2 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            withAnimation(.easeInOut(duration: 0.4)) { glowScale = 1.0 }
        }
    }

    private func fireRipple() {
        ripple = 0.6
        rippleOp = 0.8
        withAnimation(.easeOut(duration: 0.55)) {
            ripple = 1.8
            rippleOp = 0
        }
    }
}

// MARK: - Guided Instrument Row (guided mode, each with a speed slider)

private struct GuidedInstrumentRow: View {
    let instrument: InstrumentType
    @ObservedObject var viewModel: AartiViewModel

    // Theme handled by AppTheme

    private let pattern: [InstrumentType?] = [
        .tabla, .manjira, .tabla, .dholak,
        .tabla, .manjira, .tabla, .ghanti,
        .tabla, .damru, .tabla, .manjira,
        .dholak, .tabla, .manjira, .ghanti,
    ]

    private var isActive: Bool {
        guard viewModel.isGuidedPlaying else { return false }
        let step = viewModel.currentBeat % pattern.count
        return pattern[step] == instrument
    }

    private var isExpanded: Bool { viewModel.expandedInstrument == instrument }

    var body: some View {
        VStack(spacing: 0) {
            // Main row
            Button {
                viewModel.toggleSpeedSlider(for: instrument)
            } label: {
                HStack(spacing: 14) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle().stroke(
                                    isActive ? AppTheme.accent.opacity(0.7) : AppTheme.accent.opacity(0.2),
                                    lineWidth: 1)
                            )
                            .frame(width: 44, height: 44)
                            .animation(
                                .spring(response: 0.12, dampingFraction: 0.5), value: isActive)
                        Image(systemName: instrument.icon)
                            .font(.system(size: isActive ? 20 : 17, weight: .semibold))
                            .foregroundColor(
                                isActive ? AppTheme.accent : AppTheme.accent.opacity(0.4)
                            )
                            .shadow(
                                color: isActive ? AppTheme.accent.opacity(0.8) : .clear, radius: 8
                            )
                            .scaleEffect(isActive ? 1.1 : 1.0)
                            .animation(
                                .spring(response: 0.12, dampingFraction: 0.5), value: isActive)
                    }

                    // Name
                    Text(LocalizedStringKey(instrument.rawValue))
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundColor(
                            isActive ? AppTheme.primaryText : AppTheme.primaryText.opacity(0.55))

                    Spacer()

                    // Speed badge
                    Text(String(format: "%.2g×", viewModel.instrumentSpeeds[instrument] ?? 1.0))
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundColor(
                            isExpanded ? AppTheme.primaryText : AppTheme.primaryText.opacity(0.35)
                        )
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(
                                    isExpanded
                                        ? AppTheme.accent.opacity(0.12)
                                        : AppTheme.primaryText.opacity(0.05)
                                )
                                .overlay(
                                    Capsule().stroke(
                                        isExpanded ? AppTheme.accent.opacity(0.5) : Color.clear,
                                        lineWidth: 1))
                        )

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.bold())
                        .foregroundColor(AppTheme.primaryText.opacity(0.25))
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            isActive
                                ? AppTheme.accent.opacity(0.45)
                                : AppTheme.accent.opacity(0.2),
                            lineWidth: 1)
                )
                .shadow(color: AppTheme.accent.opacity(isActive ? 0.12 : 0.06), radius: 8, x: 0, y: 3)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(
                "\(instrument.rawValue). Speed: \(String(format: "%.2g", viewModel.instrumentSpeeds[instrument] ?? 1.0))×. Double tap to adjust speed."
            )

            // Expanded speed slider
            if isExpanded {
                VStack(spacing: 6) {
                    HStack {
                        Text("Beat Rate")
                            .font(.system(.caption2, design: .serif))
                            .foregroundColor(AppTheme.primaryText.opacity(0.4))
                        Spacer()
                        Text(speedLabel(for: instrument))
                            .font(.system(.caption2, design: .serif, weight: .bold))
                            .foregroundColor(AppTheme.primaryText)
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.instrumentSpeeds[instrument] ?? 1.0 },
                            set: { viewModel.instrumentSpeeds[instrument] = $0 }
                        ),
                        in: 0.25...3.0,
                        step: 0.25
                    )
                    .tint(AppTheme.accent)
                    HStack {
                        Text("¼× (rare)").font(.system(size: 8)).foregroundColor(
                            AppTheme.primaryText.opacity(0.25))
                        Spacer()
                        Text("3× (rapid)").font(.system(size: 8)).foregroundColor(
                            AppTheme.primaryText.opacity(0.25))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.accent.opacity(0.15), lineWidth: 1))
                .padding(.top, 2)
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
    }

    private func speedLabel(for inst: InstrumentType) -> String {
        let s = viewModel.instrumentSpeeds[inst] ?? 1.0
        if s < 0.5 { return "Rare" }
        if s < 1.0 { return "Occasional" }
        if s == 1.0 { return "Normal" }
        if s <= 2.0 { return "Frequent" }
        return "Rapid"
    }
}

// MARK: - Beat Visualiser

private struct BeatVisualiser: View {
    let currentBeat: Int
    let isPlaying: Bool
    // Theme handled by AppTheme
    private let total = 16

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { i in
                let active = isPlaying && (currentBeat % total == i)
                Capsule()
                    .fill(active ? AppTheme.accent : AppTheme.primaryText.opacity(0.1))
                    .frame(height: active ? 36 : 18)
                    .shadow(color: active ? AppTheme.accent.opacity(0.7) : .clear, radius: 6)
                    .animation(.spring(response: 0.15, dampingFraction: 0.6), value: currentBeat)
            }
        }
    }
}

// MARK: - Custom Segmented Control

struct AartiSegmentedControl: View {
    let selected: AartiMode
    let onSelect: (AartiMode) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Namespace private var segNS
    // Theme handled by AppTheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AartiMode.allCases, id: \.self) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    Text(LocalizedStringKey(mode.rawValue))
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundColor(
                            selected == mode ? .white : AppTheme.primaryText.opacity(0.55)
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background {
                            if selected == mode {
                                Capsule().fill(AppTheme.accent)
                                    .matchedGeometryEffect(id: "seg", in: segNS)
                                    .shadow(color: AppTheme.accent.opacity(0.5), radius: 8)
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.rawValue)
                .accessibilityValue(selected == mode ? "Selected" : "")
                .accessibilityAddTraits(selected == mode ? .isSelected : [])
            }
        }
        .padding(4)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppTheme.primaryText.opacity(0.08), lineWidth: 1))
        .animation(
            reduceMotion ? .none : .spring(response: 0.38, dampingFraction: 0.72), value: selected)
    }
}
