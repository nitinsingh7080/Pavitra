import SwiftUI

// MARK: - OnboardingView
// Shown only on first launch. Now includes a language selection page.

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @State private var currentPage = 0

    // Language picker page is page 0; content pages follow
    private var totalPages: Int { contentPages.count + 1 }  // +1 for language page

    private let contentPages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.viewfinder",
            iconColor: Color(red: 0.9, green: 0.75, blue: 0.45),
            title: "Scan & Discover",
            subtitle:
                "Point your camera at any ritual object — Diya, Shankh, Kalash — and instantly learn its sacred meaning from the Vedas and Puranas.",
            gradientColors: [
                Color(red: 0.10, green: 0.07, blue: 0.04),
                Color(red: 0.22, green: 0.14, blue: 0.08),
            ]
        ),
        OnboardingPage(
            icon: "calendar",
            iconColor: Color(red: 0.55, green: 0.85, blue: 0.65),
            title: "Ritual Calendar",
            subtitle:
                "Explore 20+ sacred Hindu festivals across all 12 Hindu lunar months. Learn their significance and how to celebrate them.",
            gradientColors: [
                Color(red: 0.04, green: 0.10, blue: 0.07),
                Color(red: 0.08, green: 0.20, blue: 0.12),
            ]
        ),
        OnboardingPage(
            icon: "bell.fill",
            iconColor: Color(red: 0.75, green: 0.55, blue: 0.95),
            title: "Perform Aarti",
            subtitle:
                "Select instruments and play them yourself, or let Guided Aarti play a perfectly timed rhythmic ceremony for you.",
            gradientColors: [
                Color(red: 0.07, green: 0.04, blue: 0.12),
                Color(red: 0.14, green: 0.08, blue: 0.22),
            ]
        ),
    ]

    // Background gradient for current page
    private var bgColors: [Color] {
        if currentPage == 0 {
            return [
                Color(red: 0.07, green: 0.04, blue: 0.01),
                Color(red: 0.15, green: 0.08, blue: 0.02),
            ]
        }
        return contentPages[currentPage - 1].gradientColors
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: bgColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: currentPage)

            VStack(spacing: 0) {
                // Skip (hidden on language page and last page)
                HStack {
                    Spacer()
                    if currentPage > 0 && currentPage < totalPages - 1 {
                        Button("Skip") {
                            withAnimation { hasSeenOnboarding = true }
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(.white.opacity(0.6))
                        .padding()
                    }
                }

                TabView(selection: $currentPage) {
                    // Page 0: Language selection
                    LanguageSelectionPage(selectedLanguage: $selectedLanguage)
                        .tag(0)

                    // Pages 1-3: Content
                    ForEach(Array(contentPages.enumerated()), id: \.offset) { idx, page in
                        OnboardingPageView(page: page)
                            .tag(idx + 1)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // Dot indicators
                HStack(spacing: 10) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i == currentPage ? Color.white : Color.white.opacity(0.35))
                            .frame(width: i == currentPage ? 24 : 8, height: 8)
                            .animation(
                                .spring(response: 0.4, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 16)

                // Action button
                Button {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    if currentPage < totalPages - 1 {
                        withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                            currentPage += 1
                        }
                    } else {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            hasSeenOnboarding = true
                        }
                    }
                } label: {
                    let isLast = currentPage == totalPages - 1
                    Text(currentPage == 0 ? "Continue" : (isLast ? "Get Started" : "Next"))
                        .font(.headline)
                        .foregroundColor(
                            currentPage == 0
                                ? Color(red: 0.12, green: 0.07, blue: 0.02)
                                : bgColors[1]
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 32)
                .padding(.top, 28)
                .padding(.bottom, 50)
            }
        }
    }
}

// MARK: - Language Selection Page

private struct LanguageSelectionPage: View {
    @Binding var selectedLanguage: String

    private let gold = Color(red: 0.90, green: 0.72, blue: 0.35)

    private let languages: [(code: String, name: String, nativeName: String, flag: String)] = [
        ("en", "English", "English", "🇬🇧"),
        ("hi", "Hindi", "हिन्दी", "🇮🇳"),
    ]

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Om + flame icon
            ZStack {
                Circle()
                    .fill(gold.opacity(0.12))
                    .frame(width: 130, height: 130)
                Circle()
                    .stroke(gold.opacity(0.35), lineWidth: 1.5)
                    .frame(width: 130, height: 130)
                Text("ॐ")
                    .font(.system(size: 56, weight: .ultraLight, design: .serif))
                    .foregroundColor(gold)
            }

            VStack(spacing: 10) {
                Text("Choose Your Language")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Text("भाषा चुनें")
                    .font(.system(size: 18, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.55))
            }
            .multilineTextAlignment(.center)

            // Language cards
            VStack(spacing: 14) {
                ForEach(languages, id: \.code) { lang in
                    LanguageCard(
                        flag: lang.flag,
                        name: lang.name,
                        nativeName: lang.nativeName,
                        isSelected: selectedLanguage == lang.code,
                        onSelect: { selectedLanguage = lang.code }
                    )
                }
            }
            .padding(.horizontal, 28)

            Spacer()
        }
    }
}

private struct LanguageCard: View {
    let flag: String
    let name: String
    let nativeName: String
    let isSelected: Bool
    let onSelect: () -> Void

    private let gold = Color(red: 0.90, green: 0.72, blue: 0.35)
    private let bg = Color(red: 0.12, green: 0.07, blue: 0.02)

    var body: some View {
        Button(action: {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            onSelect()
        }) {
            HStack(spacing: 16) {
                Text(flag).font(.title)
                VStack(alignment: .leading, spacing: 2) {
                    Text(name)
                        .font(.system(.headline, design: .serif, weight: .semibold))
                        .foregroundColor(.white)
                    Text(nativeName)
                        .font(.system(.subheadline, design: .serif))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(gold)
                        .font(.title3)
                } else {
                    Circle()
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? gold.opacity(0.14) : bg.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                isSelected ? gold.opacity(0.8) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 1.5 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.68), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(name). \(isSelected ? "Selected." : "Double tap to select.")")
    }
}

// MARK: - Supporting Types (unchanged)

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let gradientColors: [Color]
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle()
                    .fill(page.iconColor.opacity(0.15))
                    .frame(width: 140, height: 140)
                Circle()
                    .stroke(page.iconColor.opacity(0.35), lineWidth: 1.5)
                    .frame(width: 140, height: 140)
                Image(systemName: page.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(page.iconColor)
            }
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text(page.subtitle)
                    .font(.system(.body, design: .serif))
                    .foregroundColor(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 28)
            }
            Spacer()
        }
    }
}
