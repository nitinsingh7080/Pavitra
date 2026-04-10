import SwiftUI

// MARK: - Instrument Pad View
// One sacred instrument card used in Practice mode

struct InstrumentPadView: View {
    let instrument: InstrumentType
    @ObservedObject var viewModel: AartiViewModel

    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

    @State private var isPressed: Bool = false
    @State private var glowOpacity: Double = 0
    @State private var rippleScale: CGFloat = 0.6
    @State private var rippleOpacity: Double = 0

    // Tabla-specific
    @State private var tablaZone: TablaZone = .dayan

    private var isActive: Bool {
        if instrument == .shankh { return viewModel.isBlowDetected }
        if instrument == .ghanti { return viewModel.isRinging }
        return isPressed
    }

    var body: some View {
        if instrument == .tabla {
            tablaView
        } else {
            singlePadView
        }
    }

    // MARK: - Standard Pad

    private var singlePadView: some View {
        Button {
            triggerInstrument()
        } label: {
            padContent
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if instrument == .shankh && !viewModel.micPermissionGranted {
                        isPressed = true
                        viewModel.playInstrument(.shankh)
                    }
                }
                .onEnded { _ in
                    if instrument == .shankh && !viewModel.micPermissionGranted {
                        isPressed = false
                        viewModel.stopShankh()
                    }
                }
        )
        .accessibilityLabel(instrument.rawValue)
        .accessibilityHint(instrument.practiceHint)
        .onChange(of: isActive) { _, active in
            animateGlow(active: active)
            if active && !reduceMotion { triggerRipple() }
        }
    }

    // MARK: - Tabla (split left/right zones)

    private var tablaView: some View {
        HStack(spacing: 10) {
            // BAYAN (bass drum, left)
            tablaSide(label: "Bayan", zone: .bayan, iconOffset: -4)
            // DAYAN (treble drum, right)
            tablaSide(label: "Dayan", zone: .dayan, iconOffset: 4)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Tabla")
        .accessibilityHint(instrument.practiceHint)
    }

    private func tablaSide(label: String, zone: TablaZone, iconOffset: CGFloat) -> some View {
        Button {
            isPressed = true
            viewModel.playInstrument(.tabla, tablaZone: zone)
            animateGlow(active: true)
            if !reduceMotion { triggerRipple() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                isPressed = false
                animateGlow(active: false)
            }
        } label: {
            ZStack {
                padBackground(wide: true)
                VStack(spacing: 8) {
                    Image(systemName: "t.circle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundColor(
                            isPressed ? AppTheme.accent : AppTheme.accent.opacity(0.65)
                        )
                        .offset(x: iconOffset)
                    Text(label)
                        .font(.system(.caption2, design: .rounded, weight: .semibold))
                        .foregroundColor(AppTheme.primaryText.opacity(0.65))
                        .tracking(1)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    // MARK: - Shared pad content

    private var padContent: some View {
        ZStack {
            padBackground(wide: false)

            // Ripple ring
            if !reduceMotion {
                Circle()
                    .stroke(AppTheme.accent.opacity(rippleOpacity), lineWidth: 2)
                    .scaleEffect(rippleScale)
                    .frame(width: 80, height: 80)
            }

            VStack(spacing: 10) {
                Image(systemName: instrument.icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(isActive ? AppTheme.accent : AppTheme.accent.opacity(0.55))
                    .scaleEffect(isPressed && !reduceMotion ? 1.12 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)

                Text(instrument.rawValue)
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundColor(AppTheme.primaryText.opacity(0.7))
                    .tracking(1.2)

                // Shankh mic-level indicator
                if instrument == .shankh {
                    micLevelBar
                }
            }
        }
    }

    private func padBackground(wide: Bool) -> some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(AppTheme.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isActive ? AppTheme.accent.opacity(0.9) : AppTheme.primaryText.opacity(0.08),
                        lineWidth: isActive ? 1.5 : 1
                    )
            )
            .shadow(
                color: isActive ? AppTheme.accent.opacity(glowOpacity * 0.55) : .clear, radius: 18,
                x: 0, y: 0)
    }

    // MARK: - Mic level visualiser (Shankh)

    private var micLevelBar: some View {
        let normalised = max(0, min(1, Double((viewModel.micLevel + 60) / 60)))
        return ZStack(alignment: .leading) {
            Capsule().fill(AppTheme.primaryText.opacity(0.1)).frame(height: 4)
            Capsule()
                .fill(AppTheme.accent)
                .frame(width: CGFloat(normalised) * 50, height: 4)
        }
        .frame(width: 50)
        .animation(.linear(duration: 0.05), value: viewModel.micLevel)
    }

    // MARK: - Animations

    private func triggerInstrument() {
        guard instrument != .ghanti && instrument != .shankh else { return }
        isPressed = true
        viewModel.playInstrument(instrument)
        animateGlow(active: true)
        if !reduceMotion { triggerRipple() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
            isPressed = false
            animateGlow(active: false)
        }
    }

    private func animateGlow(active: Bool) {
        withAnimation(.easeInOut(duration: active ? 0.2 : 0.5)) {
            glowOpacity = active ? 1.0 : 0.0
        }
    }

    private func triggerRipple() {
        rippleScale = 0.6
        rippleOpacity = 0.7
        withAnimation(.easeOut(duration: 0.55)) {
            rippleScale = 1.6
            rippleOpacity = 0
        }
    }
}
