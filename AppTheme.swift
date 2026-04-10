import SwiftUI

// MARK: - AppTheme
// Centralised design tokens for consistent look across the entire app.
// All colours are adaptive — visible in both Light and Dark mode.

struct AppTheme {

    // MARK: - Accent
    /// Warm amber gold. Reads clearly on white AND dark backgrounds.
    static let accent = Color(red: 0.78, green: 0.58, blue: 0.20)
    static let accentSoft = Color(red: 0.78, green: 0.58, blue: 0.20).opacity(0.15)

    // MARK: - Backgrounds (adaptive: warm cream in light, deep warm charcoal in dark)
    /// Adaptive page background — warm cream in light mode, deep charcoal-brown in dark mode.
    static let pageBackground = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.10, green: 0.08, blue: 0.06, alpha: 1)   // deep warm charcoal
                : UIColor(red: 0.97, green: 0.95, blue: 0.91, alpha: 1)   // warm cream
        }
    )
    static let cardBackground = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.15, green: 0.12, blue: 0.09, alpha: 1)   // slightly lighter charcoal
                : UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1)   // lighter cream
        }
    )
    static let fillBackground = Color(
        UIColor { t in
            t.userInterfaceStyle == .dark
                ? UIColor(red: 0.22, green: 0.17, blue: 0.12, alpha: 1)   // warm dark fill
                : UIColor(red: 0.94, green: 0.91, blue: 0.86, alpha: 1)   // muted warm fill
        }
    )

    // MARK: - Text (semantic)
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)

    // MARK: - Card Scrim Gradient
    /// A consistent bottom gradient used on ALL image cards app-wide.
    static func cardScrim(startAlpha: Double = 0, endAlpha: Double = 0.72) -> LinearGradient {
        LinearGradient(
            colors: [.black.opacity(startAlpha), .black.opacity(endAlpha)],
            startPoint: .center,
            endPoint: .bottom
        )
    }

    // MARK: - Card Dimensions
    static let cardCornerRadius: CGFloat = 18
    static let gridSpacing: CGFloat = 12
    static let sectionPadding: CGFloat = 16

    // MARK: - Typography
    static let heroFont = Font.system(size: 28, weight: .bold, design: .serif)
    static let titleFont = Font.system(.title2, design: .serif, weight: .bold)
    static let headingFont = Font.system(.headline, design: .serif, weight: .semibold)
    static let bodyFont = Font.system(.body, design: .serif)
    static let subheadingFont = Font.system(.subheadline, design: .serif)
    static let captionFont = Font.system(.caption, design: .serif)
    static let caption2Font = Font.system(.caption2, design: .serif)
    
    /// For UI elements like buttons and pills (friendly & crisp)
    static let uiActionFont = Font.system(.subheadline, design: .rounded, weight: .bold)
    static let uiPillFont = Font.system(.caption2, design: .rounded, weight: .bold)
    
    /// For small all-caps labels/overlines
    static func overlineFont(size: CGFloat = 10) -> Font {
        Font.system(size: size, weight: .black).lowercaseSmallCaps()
    }
}

// MARK: - Shared Section Header

struct AppSectionHeader: View {
    let title: LocalizedStringKey
    var subtitle: LocalizedStringKey? = nil
    var count: Int? = nil
    var countLabel: LocalizedStringKey? = nil
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTheme.titleFont)
                    .foregroundStyle(AppTheme.primaryText)
                if let sub = subtitle {
                    Text(sub)
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.secondaryText)
                }
            }
            Spacer()
            if let label = countLabel {
                Text(label)
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.fillBackground)
                    .clipShape(Capsule())
            } else if let n = count {
                Text("\(n)")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.secondaryText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppTheme.fillBackground)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, AppTheme.sectionPadding)
    }
}

// MARK: - Unified App Card
/// One card style used everywhere: image fills, gradient scrim, name at bottom.
/// Works in both Light and Dark mode because the scrim provides contrast.

struct AppRitualCard: View {
    let name: LocalizedStringKey
    let image: String
    var height: CGFloat = 155
    var showFavorite: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                // Image
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // Consistent scrim gradient
                AppTheme.cardScrim()
                    .frame(width: geo.size.width, height: geo.size.height)

                // Bottom label with faded bordered pill
                Text(name)
                    .font(.system(size: 13, weight: .semibold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 12)
                    .background(.thinMaterial.opacity(0.75))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                    .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 12)
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(alignment: .topTrailing) {
            if showFavorite {
                Image(systemName: "heart.fill")
                    .font(.caption2.bold())
                    .foregroundColor(.red)
                    .padding(5)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Fixed-size card for horizontal scrolls (Home, Saved)

struct AppRitualCardFixed: View {
    let name: LocalizedStringKey
    let image: String
    var width: CGFloat = 160
    var height: CGFloat = 150
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()

            AppTheme.cardScrim()
                .frame(width: width, height: height)

            // Name pill with faded border
            Text(name)
                .font(.system(size: 13, weight: .semibold, design: .serif))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding(.vertical, 5)
                .padding(.horizontal, 12)
                .background(.thinMaterial.opacity(0.75))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 4, x: 0, y: 2)
                .padding(.bottom, 12)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}
