import SwiftUI

// MARK: - SavedRitualsView — fully adaptive (light + dark)

struct SavedRitualsView: View {
    @EnvironmentObject var store: UserDataStore

    var body: some View {
        ZStack {
            AppTheme.pageBackground.ignoresSafeArea()

            if store.favoriteRituals.isEmpty && store.favoriteAnnualRituals.isEmpty {
                // MARK: - Empty State
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accentSoft)
                            .frame(width: 110, height: 110)
                        Image(systemName: "heart.slash")
                            .font(.system(size: 46))
                            .foregroundStyle(AppTheme.accent)
                    }
                    Text(LocalizedStringKey("Nothing Saved Yet"))
                        .font(AppTheme.titleFont)
                        .foregroundStyle(AppTheme.primaryText)
                    Text(LocalizedStringKey("Tap the ♡ button on any ritual or\nfestival page to save it here."))
                        .font(AppTheme.bodyFont)
                        .foregroundStyle(AppTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 44)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {

                        // MARK: - Ritual Objects
                        if !store.favoriteRituals.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                SavedSectionHeader(
                                    title: "Ritual Objects",
                                    icon: "camera.viewfinder",
                                    count: store.favoriteRituals.count
                                )

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: AppTheme.gridSpacing) {
                                        ForEach(store.favoriteRituals) { ritual in
                                            NavigationLink(destination: DetailView(ritual: ritual))
                                            {
                                                SavedObjectCard(ritual: ritual)
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, AppTheme.sectionPadding)
                                }
                            }
                        }

                        // MARK: - Sacred Festivals
                        if !store.favoriteAnnualRituals.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                SavedSectionHeader(
                                    title: "Sacred Festivals",
                                    icon: "calendar",
                                    count: store.favoriteAnnualRituals.count
                                )

                                VStack(spacing: 10) {
                                    ForEach(store.favoriteAnnualRituals) { ritual in
                                        NavigationLink(
                                            destination: AnnualRitualDetailView(ritual: ritual)
                                        ) {
                                            SavedFestivalRow(ritual: ritual)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, AppTheme.sectionPadding)
                            }
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                }
            }
        }
        .navigationTitle("Saved")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Section Header

private struct SavedSectionHeader: View {
    let title: LocalizedStringKey
    let icon: String
    let count: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.subheadline.bold())
                .foregroundStyle(AppTheme.accent)
            Text(title)
                .font(.system(.subheadline, weight: .bold))
                .tracking(0.8)
                .foregroundStyle(AppTheme.accent)
            Spacer()
            Text("\(count)")
                .font(.caption.bold())
                .foregroundStyle(AppTheme.secondaryText)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(AppTheme.fillBackground)
                .clipShape(Capsule())
        }
        .padding(.horizontal, AppTheme.sectionPadding)
    }
}

// MARK: - Saved Object Card

private struct SavedObjectCard: View {
    let ritual: RitualInfo
    @EnvironmentObject var store: UserDataStore

    var body: some View {
        ZStack(alignment: .bottom) {
            Image(ritual.image)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 196)
                .clipped()

            AppTheme.cardScrim(startAlpha: 0, endAlpha: 0.82)
                .frame(width: 150, height: 196)

            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(ritual.name))
                    .font(.system(.subheadline, design: .serif, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(2)

                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        store.toggleFavorite(ritual)
                    }
                } label: {
                    Label(LocalizedStringKey("Remove"), systemImage: "heart.slash.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(.red.opacity(0.9))
                }
            }
            .frame(width: 130, alignment: .leading)
            .padding(.bottom, 14)
        }
        .frame(width: 150, height: 196)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(Color(.separator).opacity(0.4), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Saved Festival Row

private struct SavedFestivalRow: View {
    let ritual: AnnualRitual
    @EnvironmentObject var store: UserDataStore

    var body: some View {
        HStack(spacing: 14) {
            Image(ritual.image)
                .resizable()
                .scaledToFill()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(.separator).opacity(0.4), lineWidth: 1))

            VStack(alignment: .leading, spacing: 5) {
                Text(LocalizedStringKey(ritual.name))
                    .font(AppTheme.headingFont)
                    .foregroundStyle(AppTheme.primaryText)
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text(LocalizedStringKey(ritual.month.rawValue))
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.accent)
                    Text("·  \(ritual.month.englishRange)")
                        .font(.caption)
                        .foregroundStyle(AppTheme.secondaryText)
                }
                Text(LocalizedStringKey(ritual.significance))
                    .font(.caption)
                    .foregroundStyle(AppTheme.tertiaryText)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppTheme.tertiaryText)
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        store.toggleFavorite(ritual)
                    }
                } label: {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1))
    }
}
