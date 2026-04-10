import SwiftUI

struct DetailView: View {
    let ritual: RitualInfo
    @State private var selectedTab = 0
    @EnvironmentObject var store: UserDataStore
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Image(ritual.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width, height: 350)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizedStringKey(ritual.name))
                        .font(.system(size: 34, weight: .bold, design: .serif))

                    Picker("Information", selection: $selectedTab) {
                        Text(LocalizedStringKey("Significance")).tag(0)
                        Text(LocalizedStringKey("Instructions")).tag(1)
                        Text(LocalizedStringKey("History")).tag(2)
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizedStringKey(tabTitle))
                            .font(.headline)
                            .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.45))

                        let rawContent = selectedTab == 0
                            ? ritual.meaning
                            : (selectedTab == 1 ? ritual.howToUse : ritual.history)
                        Text(LocalizedStringKey(normaliseForKey(rawContent)))
                            .font(.system(.body, design: .serif))
                            .lineSpacing(7)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .id(selectedTab)
                    }
                    .padding(.top, 10)
                }
                .padding(24)
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
        .onAppear {
            store.markViewed(ritual)
        }
    }

    private var tabTitle: String {
        switch selectedTab {
        case 0: return "Deep Spiritual Significance"
        case 1: return "Ritual Instructions & Practice"
        default: return "Vedic & Historical Origins"
        }
    }

    /// Normalises multiline Swift string to match the single-line keys in Localizable.strings.
    /// Paragraphs are separated by "  " (double space) in .strings keys.
    private func normaliseForKey(_ raw: String) -> String {
        let lines = raw.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        var paragraphs: [String] = []
        var current = ""
        for line in lines {
            if line.isEmpty {
                if !current.isEmpty { paragraphs.append(current); current = "" }
            } else {
                current = current.isEmpty ? line : current + " " + line
            }
        }
        if !current.isEmpty { paragraphs.append(current) }
        return paragraphs.joined(separator: "   ")
    }
}

// Fixed corner radius extension
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect, byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
