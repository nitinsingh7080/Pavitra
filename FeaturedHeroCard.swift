import SwiftUI

struct FeaturedHeroCard: View {

    var action: () -> Void
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"

    var body: some View {
        Button {
            UISelectionFeedbackGenerator().selectionChanged()
            action()
        } label: {

            ZStack {

                // Background gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.10, blue: 0.08),
                                Color(red: 0.25, green: 0.18, blue: 0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 220)

       
            
                // Foreground content
                VStack(spacing: 14) {

                    Image(systemName: "camera.viewfinder")
                        .font(.system(size: 42))
                        .foregroundColor(Color(red: 0.9, green: 0.75, blue: 0.45)) // Gold accent

                    Text(LocalizedStringKey("Scan a Ritual Object"))
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(LocalizedStringKey("Discover sacred meanings instantly"))
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // Add a subtle border for depth
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FeaturedHeroCard(action: {})
        .padding()
}
