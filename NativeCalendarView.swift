import SwiftUI

struct NativeCalendarView: View {
    
    @Binding var selectedDate: DateComponents?
    @Binding var displayedMonth: DateComponents
    var ritualDates: Set<DateComponents>
    
    @AppStorage("selectedLanguage") private var selectedLanguage = "en"
    
    private var calendar: Calendar {
        var cal = Calendar(identifier: .gregorian)
        cal.locale = Locale(identifier: selectedLanguage)
        return cal
    }
    
    var body: some View {
        VStack(spacing: 12) {
            
            // MARK: - Month Header
            HStack {
                Text(monthYearString)
                    .font(.title3.weight(.semibold))
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            
            // MARK: - Weekday Labels
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 6) {
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            
            // MARK: - Date Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(daysInMonth(), id: \.self) { date in
                    if let date = date {
                        dayCell(for: date)
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }
        }
    }
}

// MARK: - Day Cell

private extension NativeCalendarView {
    
    func dayCell(for date: Date) -> some View {
        let comps = calendar.dateComponents([.day, .month, .year], from: date)
        let isSelected = selectedDate?.day == comps.day &&
                         selectedDate?.month == comps.month
        
        let hasRitual = ritualDates.contains {
            $0.day == comps.day && $0.month == comps.month
        }
        
        return VStack(spacing: 4) {
            
            ZStack {
                if isSelected {
                    Circle()
                        .fill(Color.appAccentSoftBrown)
                        .frame(width: 28, height: 28)
                }
                
                Text("\(comps.day ?? 0)")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            
            if hasRitual {
                Circle()
                    .fill(Color.appAccentSoftBrown)
                    .frame(width: 4, height: 4)
            } else {
                Color.clear.frame(width: 4, height: 4)
            }
        }
        .frame(height: 38)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedDate = comps
        }
    }
    
    var monthYearString: String {
        guard let date = calendar.date(from: displayedMonth) else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: selectedLanguage)
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func previousMonth() {
        changeMonth(by: -1)
    }
    
    func nextMonth() {
        changeMonth(by: 1)
    }
    
    func changeMonth(by value: Int) {
        guard let current = calendar.date(from: displayedMonth),
              let newDate = calendar.date(byAdding: .month, value: value, to: current)
        else { return }
        
        displayedMonth = calendar.dateComponents([.year, .month], from: newDate)
    }
    
    func daysInMonth() -> [Date?] {
        guard let monthDate = calendar.date(from: displayedMonth),
              let range = calendar.range(of: .day, in: .month, for: monthDate)
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: monthDate)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)
        
        for day in range {
            var comps = displayedMonth
            comps.day = day
            days.append(calendar.date(from: comps))
        }
        
        return days
    }
}
