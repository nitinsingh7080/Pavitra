import SwiftUI

@main
struct IndianRitual2App: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    @StateObject private var userDataStore = UserDataStore.shared

    var body: some Scene {
        WindowGroup {
            MainTabView(selectedLanguage: selectedLanguage)
                .environmentObject(userDataStore)
                .environment(\.locale, Locale(identifier: selectedLanguage))
                .fullScreenCover(isPresented: .constant(!hasSeenOnboarding)) {
                    OnboardingView()
                        .environment(\.locale, Locale(identifier: selectedLanguage))
                }
        }
    }
}

struct MainTabView: View {
    /// Passed from IndianRitual2App so the locale environment and .id() rebuild
    /// happen in the same parent render — no timing race with a second @AppStorage.
    let selectedLanguage: String

    var body: some View {
        TabView {
            Tab("tab_home", systemImage: "house") {
                RitualDiscoveryView()
            }
            Tab("tab_rituals", systemImage: "calendar") {
                RitualCalendarView()
            }
            Tab("Aarti", systemImage: "bell.fill") {
                NavigationStack { AartiView() }
            }
            Tab("Search", systemImage: "magnifyingglass", role: .search) {
                UniversalSearchView()
            }
        }
        .id(selectedLanguage)   // force full rebuild when language changes
        .tint(AppTheme.accent)
    }
}
