import SwiftUI

// MARK: - Universal Search View (standalone tab)

struct UniversalSearchView: View {
    @State private var query = ""
    @EnvironmentObject var store: UserDataStore

    private var objectResults: [RitualInfo] {
        guard !query.isEmpty else { return [] }
        return RitualDatabase.allRituals.values
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                    || $0.meaning.localizedCaseInsensitiveContains(query)
            }
            .sorted { $0.name < $1.name }
    }

    private var festivalResults: [AnnualRitual] {
        guard !query.isEmpty else { return [] }
        return AnnualRitualDatabase.rituals
            .filter {
                $0.name.localizedCaseInsensitiveContains(query)
                    || $0.month.rawValue.localizedCaseInsensitiveContains(query)
                    || $0.significance.localizedCaseInsensitiveContains(query)
            }
    }

    private var hasResults: Bool { !objectResults.isEmpty || !festivalResults.isEmpty }
    private var showEmpty: Bool { !query.isEmpty && !hasResults }

    var body: some View {
        NavigationStack {
            List {
                if query.isEmpty {
                    // Suggestions / recent
                    Section("Search Across Everything") {
                        SuggestionRow(
                            icon: "camera.viewfinder",
                            text: LocalizedStringKey("Ritual objects by name or meaning"))
                        SuggestionRow(
                            icon: "calendar",
                            text: LocalizedStringKey("Search festivals by name or month"))
                        SuggestionRow(
                            icon: "text.book.closed",
                            text: LocalizedStringKey("Content from Vedic & Puranic texts"))
                    }
                    .listRowBackground(AppTheme.cardBackground)

                    if !store.favoriteRituals.isEmpty || !store.favoriteAnnualRituals.isEmpty {
                        Section("Saved") {
                            ForEach(store.favoriteRituals.prefix(3)) { ritual in
                                NavigationLink(destination: DetailView(ritual: ritual)) {
                                    QuickRow(
                                        name: LocalizedStringKey(ritual.name),
                                        image: ritual.image,
                                        subtitle: LocalizedStringKey("Ritual Object"))
                                }
                            }
                            ForEach(store.favoriteAnnualRituals.prefix(3)) { ritual in
                                NavigationLink(destination: AnnualRitualDetailView(ritual: ritual))
                                {
                                    QuickRow(
                                        name: LocalizedStringKey(ritual.name),
                                        image: ritual.image,
                                        subtitle: LocalizedStringKey(ritual.month.rawValue))
                                }
                            }
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }

                } else if showEmpty {
                    Section {
                        VStack(spacing: 14) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 38))
                                .foregroundStyle(AppTheme.secondaryText)
                            Text("No results for \"\(query)\"")
                                .font(AppTheme.headingFont)
                                .foregroundStyle(AppTheme.primaryText)
                            Text("Try a ritual name, festival, or month.")
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                    .listRowBackground(Color.clear)

                } else {
                    if !objectResults.isEmpty {
                        Section("Ritual Objects  ·  \(objectResults.count) found") {
                            ForEach(objectResults) { ritual in
                                NavigationLink(destination: DetailView(ritual: ritual)) {
                                    SearchResultRow(
                                        image: ritual.image,
                                        title: LocalizedStringKey(ritual.name),
                                        subtitle: LocalizedStringKey(ritual.meaning)
                                    )
                                }
                            }
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }

                    if !festivalResults.isEmpty {
                        Section("Sacred Festivals  ·  \(festivalResults.count) found") {
                            ForEach(festivalResults) { ritual in
                                NavigationLink(destination: AnnualRitualDetailView(ritual: ritual))
                                {
                                    SearchResultRow(
                                        image: ritual.image,
                                        title: LocalizedStringKey(ritual.name),
                                        subtitle: LocalizedStringKey("\(LocalizedStringKey(ritual.month.rawValue))  ·  \(ritual.month.englishRange)")
                                    )
                                }
                            }
                        }
                        .listRowBackground(AppTheme.cardBackground)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(AppTheme.pageBackground)
            .scrollContentBackground(.hidden)
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $query,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Rituals, festivals, meanings…"
            )
            .autocorrectionDisabled()
        }
    }
}

// MARK: - Supporting rows

private struct SuggestionRow: View {
    let icon: String
    let text: LocalizedStringKey
    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .foregroundStyle(AppTheme.secondaryText)
    }
}

private struct QuickRow: View {
    let name: LocalizedStringKey
    let image: String
    let subtitle: LocalizedStringKey
    var body: some View {
        HStack(spacing: 12) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .padding(.vertical, 2)
    }
}

private struct SearchResultRow: View {
    let image: String
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    var body: some View {
        HStack(spacing: 12) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                    .foregroundStyle(AppTheme.primaryText)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.secondaryText)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
