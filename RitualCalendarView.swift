import SwiftUI

// MARK: - Colors

extension Color {
    static let appAccentSoftBrown = Color(red: 200/255, green: 155/255, blue: 60/255)
    static let appBorderLight = Color(uiColor: .systemGray5)
}

// MARK: - RitualCalendarView

struct RitualCalendarView: View {
    
    @State private var selectedDate: DateComponents?
    @State private var displayedMonth: DateComponents
    @State private var showSavedRituals = false
    
    @EnvironmentObject var store: UserDataStore
    
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: selectedLanguage)
        return cal
    }
    
    init() {
        let now = Date()
        let cal = Calendar(identifier: .gregorian)
        
        var monthComps = cal.dateComponents([.year, .month], from: now)
        monthComps.day = 1
        
        _displayedMonth = State(initialValue: monthComps)
        
        let todayComps = cal.dateComponents([.year, .month, .day], from: now)
        _selectedDate = State(initialValue: todayComps)
    }
    
    // MARK: - Computed
    
    private var allRitualDates: Set<DateComponents> {
        Set(
            AnnualRitualDatabase.rituals.map {
                DateComponents(month: $0.approximateMonth,
                               day: $0.approximateDay)
            }
        )
    }
    
    /// Rituals for the currently selected calendar date (falls back to real today)
    private var selectedDateRituals: [AnnualRitual] {
        let comps = selectedDate ?? calendar.dateComponents([.month, .day], from: Date())
        guard let month = comps.month, let day = comps.day else { return [] }
        return AnnualRitualDatabase.rituals
            .filter { $0.approximateMonth == month && $0.approximateDay == day }
    }
    
    private var isSelectedDateToday: Bool {
        let todayComps = calendar.dateComponents([.year, .month, .day], from: Date())
        guard let sel = selectedDate,
              sel.year == todayComps.year,
              sel.month == todayComps.month,
              sel.day == todayComps.day else { return false }
        return true
    }
    
    private var selectedDateLabel: String {
        guard let dateComps = selectedDate,
            let date = calendar.date(from: dateComps)
        else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private var displayedRituals: [AnnualRitual] {
        let month = displayedMonth.month ?? calendar.component(.month, from: Date())
        return AnnualRitualDatabase.rituals
            .filter { $0.approximateMonth == month }
            .sorted { $0.approximateDay < $1.approximateDay }
    }
    
    private var displayMonthName: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "MMMM yyyy"
        if let date = calendar.date(from: displayedMonth) {
            return formatter.string(from: date)
        }
        return ""
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    
                    calendarSection
                    todayRitualSection
                    summaryHeaderSection
                    ritualGridSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .background(AppTheme.pageBackground)
            .navigationTitle("Ritual Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showSavedRituals = true
                        } label: {
                            Label("Favourites", systemImage: "star.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 20))
                            .frame(width: 36, height: 36)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
        }
        .sheet(isPresented: $showSavedRituals) {
            NavigationStack {
                SavedRitualsView()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") { showSavedRituals = false }
                                .fontWeight(.semibold)
                        }
                    }
            }
            .environmentObject(store)
        }
    }
}

// MARK: - Calendar Section

private extension RitualCalendarView {
    
    var calendarSection: some View {
        NativeCalendarView(
            selectedDate: $selectedDate,
            displayedMonth: $displayedMonth,
            ritualDates: allRitualDates
        )
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.appAccentSoftBrown.opacity(0.25), lineWidth: 1)
        )
        .shadow(color: Color.appAccentSoftBrown.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Today's Ritual Section

private extension RitualCalendarView {
    
    var todayRitualSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header — "Today's Ritual" or "March 12" etc.
            HStack(spacing: 6) {
                Image(systemName: isSelectedDateToday ? "sun.max.fill" : "calendar")
                    .foregroundColor(AppTheme.accent)
                    .font(.system(size: 14, weight: .semibold))
                Text(isSelectedDateToday ? "Today's Ritual" : LocalizedStringKey(selectedDateLabel))
                    .font(AppTheme.titleFont)
            }
            
            if let ritual = selectedDateRituals.first {
                // Full-width highlighted card
                NavigationLink(destination: AnnualRitualDetailView(ritual: ritual)) {
                    TodayFullWidthCard(ritual: ritual)
                }
                .buttonStyle(.plain)
            } else {
                // Empty state
                HStack(spacing: 14) {
                    Image(systemName: "moon.zzz")
                        .font(.system(size: 28))
                        .foregroundColor(.appAccentSoftBrown.opacity(0.7))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(
                            isSelectedDateToday
                                ? "No Ritual Today"
                                : LocalizedStringKey("No Ritual on \(selectedDateLabel)")
                        )
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                            .foregroundColor(.primary)
                        Text(isSelectedDateToday ? "Enjoy your peaceful day 🙏" : "Pick another date to explore rituals")
                            .font(.system(size: 13, design: .serif))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(16)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                        .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: AppTheme.accent.opacity(0.06), radius: 8, x: 0, y: 3)
            }
        }
    }
}

// MARK: - Summary Header

private extension RitualCalendarView {
    
    var summaryHeaderSection: some View {
        HStack {
            Text(displayMonthName)
                .font(AppTheme.titleFont)
            
            Spacer()
            
            if !displayedRituals.isEmpty {
                Text("\(displayedRituals.count) Rituals")
                    .font(AppTheme.uiPillFont)
                    .foregroundColor(AppTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.fillBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(AppTheme.accent.opacity(0.3), lineWidth: 1))
            }
        }
    }
}

// MARK: - Ritual Grid

private extension RitualCalendarView {
    
    var ritualGridSection: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ],
            spacing: 16
        ) {
            ForEach(displayedRituals) { ritual in
                NavigationLink(destination: AnnualRitualDetailView(ritual: ritual)) {
                    PremiumGridRitualCard(ritual: ritual)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Premium Grid Card

struct PremiumGridRitualCard: View {
    
    let ritual: AnnualRitual
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Image(ritual.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                
                AppTheme.cardScrim()
                    .frame(width: geo.size.width, height: geo.size.height)
                
                Text(LocalizedStringKey(ritual.name))
                    .font(AppTheme.uiPillFont)
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
        .frame(height: 150)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(AppTheme.accent.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Full-Width Today Card

struct TodayFullWidthCard: View {
    
    let ritual: AnnualRitual
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Background image
            GeometryReader { geo in
                Image(ritual.image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
            }
            
            // Deep scrim for legibility
            AppTheme.cardScrim(startAlpha: 0, endAlpha: 0.82)
            
            // Bottom content
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey(ritual.name))
                    .font(AppTheme.titleFont)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(LocalizedStringKey(ritual.month.rawValue.capitalized))
                    .font(AppTheme.uiPillFont)
                    .foregroundColor(.white)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(.thinMaterial.opacity(0.75))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.35), lineWidth: 1))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 210)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cardCornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [Color.appAccentSoftBrown, Color.appAccentSoftBrown.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        )
        .shadow(color: Color.appAccentSoftBrown.opacity(0.35), radius: 12, x: 0, y: 5)
    }
}
