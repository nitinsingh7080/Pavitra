import SwiftUI

// MARK: - Header Section (Home tab subtitle)

struct HeaderSection: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    var body: some View {
        Text(LocalizedStringKey("Discover the meaning behind the objects used in Hindu rituals and pooja."))
            .font(.system(.subheadline, design: .serif))
            .foregroundStyle(AppTheme.secondaryText)
            .padding(.horizontal, AppTheme.sectionPadding)
            .padding(.top, 10)
    }
}

// MARK: - RitualGridCard (legacy alias → uses AppRitualCardFixed internally)
// Kept for backward-compat. New code should prefer AppRitualCard / AppRitualCardFixed.

struct RitualGridCard: View {
    let name: LocalizedStringKey
    let image: String

    var body: some View {
        AppRitualCardFixed(name: name, image: image, width: 170, height: 150)
    }
}

// MARK: - ScanActionButton

struct ScanActionButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "camera.viewfinder")
                    .font(.title3)
                Text("Scan a Ritual Object")
                    .fontWeight(.bold)
            }
            .foregroundColor(.white)
            .padding(.vertical, 18)
            .padding(.horizontal, 35)
            .background(AppTheme.accent)
            .clipShape(Capsule())
            .shadow(color: AppTheme.accent.opacity(0.35), radius: 10, x: 0, y: 5)
        }
    }
}
