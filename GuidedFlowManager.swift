import SwiftUI

// MARK: - Guided Flow Data

struct GuidedStep: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let symbolName: String
    let instrument: InstrumentType?
    let narration: String
    let voiceoverAnnouncement: String

    static let allSteps: [GuidedStep] = [
        GuidedStep(
            id: 0,
            title: "Purify the Space",
            subtitle: "Ring the Ghanti to ward off negative energies and invite the divine.",
            symbolName: "bell.fill",
            instrument: .ghanti,
            narration:
                "Ring the Ghanti to begin the Aarti. Let its sacred sound purify this space.",
            voiceoverAnnouncement: "Step one. Ring the Ghanti to begin. Shake your device."
        ),
        GuidedStep(
            id: 1,
            title: "Sound the Shankh",
            subtitle: "The conch announces the presence of the divine. Blow gently.",
            symbolName: "wind",
            instrument: .shankh,
            narration: "Blow into the microphone to sound the sacred Shankh.",
            voiceoverAnnouncement:
                "Step two. Sound the Shankh. Blow into the microphone or double tap and hold."
        ),
        GuidedStep(
            id: 2,
            title: "Light the Diya",
            subtitle: "The flame represents divine light dispelling all darkness.",
            symbolName: "flame.fill",
            instrument: nil,
            narration: "Focus on the diya flame. Let its warmth fill your heart with devotion.",
            voiceoverAnnouncement: "Step three. Contemplate the diya flame. Breathe slowly."
        ),
        GuidedStep(
            id: 3,
            title: "Rhythmic Offering",
            subtitle: "Keep the sacred beat of the Manjira as the chant rises.",
            symbolName: "circles.hexagonpath.fill",
            instrument: .manjira,
            narration: "Tap the Manjira in steady rhythm. Keep the sacred beat alive.",
            voiceoverAnnouncement:
                "Step four. Tap the Manjira to keep the rhythm. Double tap repeatedly."
        ),
        GuidedStep(
            id: 4,
            title: "Complete Aarti",
            subtitle: "Ring the Ghanti three times to conclude. Jai Shree Ram.",
            symbolName: "sparkles",
            instrument: .ghanti,
            narration: "Ring the Ghanti three times to complete the Aarti. Jai Shree Ram.",
            voiceoverAnnouncement:
                "Final step. Ring the Ghanti three times to conclude. Jai Shree Ram."
        ),
    ]
}
