import SwiftUI

struct AnnualRitualDetailView: View {
    let ritual: AnnualRitual
    @State private var selectedTab = 0
    @EnvironmentObject var store: UserDataStore
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Hero Image
                Image(ritual.image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 350)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 22) {

                    // MARK: - Title
                    VStack(alignment: .leading, spacing: 6) {
                        Text(LocalizedStringKey(ritual.name))
                            .font(AppTheme.heroFont)
                            .foregroundColor(AppTheme.primaryText)

                        Text("\(String(localized: String.LocalizationValue(ritual.month.rawValue))) \(String(localized: "Sacred Observance"))")
                            .font(AppTheme.subheadingFont)
                            .foregroundColor(AppTheme.secondaryText)
                            .italic()
                    }

                    // MARK: - Segmented Control
                    Picker("Information", selection: $selectedTab) {
                        Text(LocalizedStringKey("Significance")).tag(0)
                        Text(LocalizedStringKey("Instructions")).tag(1)
                        Text(LocalizedStringKey("History")).tag(2)
                    }
                    .pickerStyle(.segmented)

                    // MARK: - Content Section
                    VStack(alignment: .leading, spacing: 16) {

                        Text(LocalizedStringKey(tabTitle))
                            .font(AppTheme.headingFont)
                            .foregroundColor(AppTheme.accent)

                        // Use the normalised key so it matches the .strings file
                        Text(LocalizedStringKey(normaliseForKey(tabContent)))
                            .font(AppTheme.bodyFont)
                            .lineSpacing(7)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(selectedTab)   // force re-render when tab changes

                        // MARK: - Ritual Items (Instructions Tab Only)
                        if selectedTab == 1 && !ritual.items.isEmpty {

                            Divider().padding(.vertical, 6)

                            Text(LocalizedStringKey("Essential Ritual Items"))
                                .font(AppTheme.headingFont)

                            ForEach(ritual.items) { item in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppTheme.accent)
                                        .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(LocalizedStringKey(item.name))
                                            .font(AppTheme.bodyFont.weight(.semibold))
                                            .fixedSize(horizontal: false, vertical: true)

                                        Text(LocalizedStringKey(item.reason))
                                            .font(AppTheme.captionFont)
                                            .foregroundColor(AppTheme.secondaryText)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                .padding(.vertical, 3)
                            }
                        }
                    }
                    .padding(.bottom, 30)
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.ultraThinMaterial)
                .cornerRadius(30, corners: [.topLeft, .topRight])
                .offset(y: -30)
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(AppTheme.pageBackground)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                        store.toggleFavorite(ritual)
                    }
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                } label: {
                    Image(systemName: store.isFavorite(ritual) ? "heart.fill" : "heart")
                        .foregroundColor(store.isFavorite(ritual) ? .red : .primary)
                        .symbolEffect(.bounce, value: store.isFavorite(ritual))
                }
            }
        }
    }

    // MARK: - Tab Helpers

    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Deep Spiritual Significance"
        case 1: return "Ritual Instructions & Practice"
        default: return "Vedic & Historical Origins"
        }
    }

    private var tabContent: String {
        switch selectedTab {
        case 0: return ritual.significance
        case 1: return ritual.instructions
        default: return ritual.history
        }
    }

    /// Normalises a multiline Swift string so it matches the keys in Localizable.strings.
    /// The .strings keys use double-space "  " as paragraph separators and have no
    /// leading/trailing whitespace per line — matching this format enables LocalizedStringKey
    /// to look up the Hindi (or other) translation correctly.
    private func normaliseForKey(_ raw: String) -> String {
        let lines = raw.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }

        var paragraphs: [String] = []
        var current = ""

        for line in lines {
            if line.isEmpty {
                if !current.isEmpty {
                    paragraphs.append(current)
                    current = ""
                }
            } else {
                current = current.isEmpty ? line : current + " " + line
            }
        }
        if !current.isEmpty { paragraphs.append(current) }

        return paragraphs.joined(separator: "   ")
    }
}
