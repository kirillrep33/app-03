import SwiftUI
import UserNotifications
import UIKit

struct ContentView: View {
    @StateObject private var navigationState = NavigationState()
    @StateObject private var profileManager = ProfileManager()
    
    var body: some View {
        GeometryReader { geometry in
            let baseWidth: CGFloat = 393.0
            let scale = geometry.size.width / baseWidth
            
            ZStack {
                profileManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Group {
                        switch navigationState.selectedTab {
                        case 0:
                            TodayView()
                                .environmentObject(profileManager)
                                .environmentObject(navigationState)
                        case 1:
                            StatisticsView()
                                .environmentObject(profileManager)
                                .environmentObject(navigationState)
                        case 2:
                            DatabaseView()
                                .environmentObject(profileManager)
                                .environmentObject(navigationState)
                        default:
                            ProfileView()
                                .environmentObject(profileManager)
                                .environmentObject(navigationState)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    HStack(spacing: 0) {
                        TabButton(
                            icon: "Icon",
                            label: "Today",
                            isSelected: navigationState.selectedTab == 0,
                            action: { navigationState.selectedTab = 0 },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 53.11
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-1",
                            label: "Statistics",
                            isSelected: navigationState.selectedTab == 1,
                            action: { navigationState.selectedTab = 1 },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 70.16
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-2",
                            label: "Database",
                            isSelected: navigationState.selectedTab == 2,
                            action: { navigationState.selectedTab = 2 },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 70.58
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-3",
                            label: "Profile",
                            isSelected: navigationState.selectedTab == 3,
                            action: { navigationState.selectedTab = 3 },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 53.42
                        )
                    }
                    .environmentObject(profileManager)
                    .environmentObject(navigationState)
                    .padding(.horizontal, 25 * scale)
                    .frame(height: 80 * scale)
                    .frame(maxWidth: .infinity)
                    .background(profileManager.cardBackgroundColor)
                    .overlay(
                        Rectangle()
                            .frame(height: 0.568371 * scale)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    )
                    // Навигационная панель должна быть в самом низу экрана,
                    // поэтому игнорируем нижнюю safe-area.
                    .padding(.bottom, 0)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

struct TabButton: View {
    @EnvironmentObject var profileManager: ProfileManager
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    let screenWidth: CGFloat
    let baseWidth: CGFloat
    let buttonWidth: CGFloat
    
    var body: some View {
        SoundButton(action: action) {
            VStack(spacing: 4 * (screenWidth / baseWidth)) {
                if isSelected {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14 * (screenWidth / baseWidth))
                            .fill(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14 * (screenWidth / baseWidth))
                                    .stroke(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.3), lineWidth: 0.568371 * (screenWidth / baseWidth))
                            )
                            .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.3), radius: 15 * (screenWidth / baseWidth))
                            .frame(width: 37.12 * (screenWidth / baseWidth), height: 37.12 * (screenWidth / baseWidth))
                        
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                            .frame(width: 26 * (screenWidth / baseWidth),
                                   height: 26 * (screenWidth / baseWidth))
                    }
                    .padding(.top, 0.568371 * (screenWidth / baseWidth))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14 * (screenWidth / baseWidth))
                            .fill(Color.clear)
                            .frame(width: 35.98 * (screenWidth / baseWidth), height: 35.98 * (screenWidth / baseWidth))
                        
                        Image(icon)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(profileManager.textPrimaryColor)
                            .frame(width: 26 * (screenWidth / baseWidth),
                                   height: 26 * (screenWidth / baseWidth))
                    }
                }
                
                Text(label)
                    .font(.system(size: 12 * (screenWidth / baseWidth), weight: .medium))
                    .foregroundColor(isSelected ? Color(red: 1.0, green: 0.176, blue: 0.176) : profileManager.textPrimaryColor)
                    .frame(height: 16 * (screenWidth / baseWidth))
            }
            .frame(width: buttonWidth * (screenWidth / baseWidth))
            .frame(height: isSelected ? 73.1 * (screenWidth / baseWidth) : 71.96 * (screenWidth / baseWidth))
        }
    }
}

struct StatisticsView: View {
    @EnvironmentObject private var nutritionStore: NutritionStore
    @EnvironmentObject var profileManager: ProfileManager
    
    @State private var selectedRange: StatsRange = .week
    
    enum StatsRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }
    
 
    
    private var logsInRange: [(date: Date, totals: NutritionStore.Totals)] {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        
        let now = Date()
        let dayCount: Int
        switch selectedRange {
        case .week: dayCount = 7
        case .month: dayCount = 30
        case .year: dayCount = 365
        }
        
        var days: [Date] = []
        for offset in stride(from: dayCount - 1, through: 0, by: -1) {
            if let d = Calendar.current.date(byAdding: .day, value: -offset, to: now) {
                days.append(d)
            }
        }
        
        return days.map { date in
            (date: date, totals: nutritionStore.totals(for: date))
        }
    }
    
    private var summary: (totalCalories: Int, avgCalories: Int, avgProtein: Int, avgFat: Int, avgCarbs: Int, totalGrams: Int, daysWithData: Int) {
        let data = logsInRange
        let nonEmpty = data.filter { $0.totals.grams > 0 }
        guard !nonEmpty.isEmpty else {
            return (0, 0, 0, 0, 0, 0, 0)
        }
        let totalCalories = nonEmpty.reduce(0.0) { $0 + $1.totals.calories }
        let totalProtein  = nonEmpty.reduce(0.0) { $0 + $1.totals.protein }
        let totalFat      = nonEmpty.reduce(0.0) { $0 + $1.totals.fat }
        let totalCarbs    = nonEmpty.reduce(0.0) { $0 + $1.totals.carbs }
        let totalGrams    = nonEmpty.reduce(0.0) { $0 + $1.totals.grams }
        let daysCount = nonEmpty.count
        return (
            totalCalories: Int(totalCalories.rounded()),
            avgCalories: Int((totalCalories / Double(daysCount)).rounded()),
            avgProtein: Int((totalProtein / Double(daysCount)).rounded()),
            avgFat: Int((totalFat / Double(daysCount)).rounded()),
            avgCarbs: Int((totalCarbs / Double(daysCount)).rounded()),
            totalGrams: Int(totalGrams.rounded()),
            daysWithData: daysCount
        )
    }
    
    private var hasData: Bool {
  
        logsInRange.contains { $0.totals.grams > 0 }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let baseWidth: CGFloat = 393.0
            let scale = screenWidth / baseWidth
            
            ZStack {
                profileManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20 * scale) {
                    
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Statistics")
                                .font(.system(size: 28 * scale, weight: .bold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .padding(.horizontal, 24 * scale)
                            
                            HStack(spacing: 0) {
                                ForEach(StatsRange.allCases, id: \.self) { range in
                                    StatisticsSegmentButton(
                                        title: range.rawValue,
                                        isSelected: selectedRange == range,
                                        scale: scale,
                                        action: { selectedRange = range }
                                    )
                                }
                            }
                            .environmentObject(profileManager)
                            .padding(.top, 16 * scale)
                            .padding(.horizontal, 24 * scale)
                            
                            Rectangle()
                                .fill(profileManager.dividerColor)
                                .frame(height: 1 * scale)
                                .padding(.top, 16 * scale)
                        }
                        .padding(.top, 0)
                        

                        StatisticsCard(title: "Daily Calories", scale: scale) {
                            DailyCaloriesChart(
                                data: logsInRange,
                                scale: scale,
                                range: selectedRange
                            )
                        }
                        .padding(.horizontal, 24 * scale)
                        
                        StatisticsCard(title: "Total Food Weight (\(profileManager.formatMassUnit()))", scale: scale) {
                            TotalWeightBarChart(
                                data: logsInRange,
                                scale: scale,
                                range: selectedRange
                            )
                        }
                        .padding(.horizontal, 24 * scale)
                        
                  
                        StatisticsCard(title: "Top 5 Most Eaten Foods", scale: scale) {
                            TopFoodsSection(
                                dates: logsInRange.map { $0.date },
                                scale: scale
                            )
                            .environmentObject(nutritionStore)
                            .id("topFoods-\(nutritionStore.logs.count)")
                        }
                        .padding(.horizontal, 24 * scale)
                        
                  
                        VStack(alignment: .leading, spacing: 20 * scale) {
                            Text(selectedRange == .week ? "Weekly Summary" : selectedRange == .month ? "Monthly Summary" : "Yearly Summary")
                                .font(.system(size: 24 * scale, weight: .bold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .padding(.horizontal, 24 * scale)
                            
                            VStack(spacing: 12 * scale) {
                                HStack(spacing: 12 * scale) {
                                    SummaryCard(
                                        title: "Total Calories",
                                        value: summary.totalCalories > 0 ? formatNumber(summary.totalCalories) : "—",
                                        unit: "kcal",
                                        valueColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        scale: scale
                                    )
                                    
                                    SummaryCard(
                                        title: "Avg Calories",
                                        value: summary.avgCalories > 0 ? formatNumber(summary.avgCalories) : "—",
                                        unit: "kcal/day",
                                        valueColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        scale: scale
                                    )
                                }
                                
                                HStack(spacing: 12 * scale) {
                                    SummaryCard(
                                        title: "Avg Protein",
                                        value: {
                                            if summary.avgProtein > 0 {
                                                let displayed = profileManager.massToDisplayed(Double(summary.avgProtein))
                                                return String(format: "%.1f", displayed)
                                            } else {
                                                return "—"
                                            }
                                        }(),
                                        unit: "\(profileManager.formatMassUnit())/day",
                                        valueColor: Color(red: 0.0, green: 0.898, blue: 1.0),
                                        scale: scale
                                    )
                                    
                                    SummaryCard(
                                        title: "Avg Fat",
                                        value: {
                                            if summary.avgFat > 0 {
                                                let displayed = profileManager.massToDisplayed(Double(summary.avgFat))
                                                return String(format: "%.1f", displayed)
                                            } else {
                                                return "—"
                                            }
                                        }(),
                                        unit: "\(profileManager.formatMassUnit())/day",
                                        valueColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        scale: scale
                                    )
                                }
                                
                                HStack(spacing: 12 * scale) {
                                    SummaryCard(
                                        title: "Avg Carbs",
                                        value: {
                                            if summary.avgCarbs > 0 {
                                                let displayed = profileManager.massToDisplayed(Double(summary.avgCarbs))
                                                return String(format: "%.1f", displayed)
                                            } else {
                                                return "—"
                                            }
                                        }(),
                                        unit: "\(profileManager.formatMassUnit())/day",
                                        valueColor: Color(red: 0.482, green: 0.247, blue: 0.894),
                                        scale: scale
                                    )
                                    
                                    SummaryCard(
                                        title: "Total Weight",
                                        value: {
                                            if summary.totalGrams > 0 {
                                                let displayed = profileManager.massToDisplayed(Double(summary.totalGrams))
                                                return String(format: "%.1f", displayed)
                                            } else {
                                                return "—"
                                            }
                                        }(),
                                        unit: profileManager.formatMassUnit(),
                                        valueColor: Color(red: 0.482, green: 0.247, blue: 0.894),
                                        scale: scale
                                    )
                                }
                            }
                            .padding(.horizontal, 24 * scale)
                        }
                        .id("summary-\(summary.totalCalories)-\(summary.daysWithData)")
                        .padding(.bottom, 40 * scale)
                    }
                    .padding(.top, 16 * scale)
                }
            }
        }
    }
}

struct StatisticsSegmentButton: View {
    @EnvironmentObject var profileManager: ProfileManager
    let title: String
    let isSelected: Bool
    let scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        SoundButton(action: action) {
            Text(title)
                .font(.system(size: 16 * scale, weight: .medium))
                .foregroundColor(isSelected ? profileManager.textPrimaryColor : profileManager.textPrimaryColor)
                .frame(maxWidth: .infinity)
                .frame(height: 40 * scale)
                .background(
                    Group {
                        if isSelected {
                            Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.2)
                        } else {
                            Color.clear
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10 * scale)
                        .stroke(
                            isSelected
                            ? Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.4)
                            : Color.clear,
                            lineWidth: 0.568371 * scale
                        )
                )
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .cornerRadius(10 * scale)
    }
}

struct StatisticsCard<Content: View>: View {
    @EnvironmentObject var profileManager: ProfileManager
    let title: String
    let scale: CGFloat
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16 * scale) {
            Text(title)
                .font(.system(size: 16 * scale, weight: .semibold))
                .foregroundColor(profileManager.textPrimaryColor)
            
            content()
        }
        .padding(16 * scale)
        .background(profileManager.cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 14 * scale)
                .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
        )
        .cornerRadius(14 * scale)
    }
}

struct DailyCaloriesChart: View {
    @EnvironmentObject var profileManager: ProfileManager
    let data: [(date: Date, totals: NutritionStore.Totals)]
    let scale: CGFloat
    let range: StatisticsView.StatsRange?
    
    init(data: [(date: Date, totals: NutritionStore.Totals)], scale: CGFloat, range: StatisticsView.StatsRange? = nil) {
        self.data = data
        self.scale = scale
        self.range = range
    }
    
    private var values: [CGFloat] {
        data.map { CGFloat($0.totals.calories) }
    }
    
    private var maxValue: CGFloat {
        let maxVal = values.max() ?? 2400
        return maxVal > 0 ? Swift.max(maxVal.rounded(.up), 2400) : 2400
    }
    
    private var days: [String] {
        guard let range = range else {
          
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return data.map { formatter.string(from: $0.date).prefix(3).capitalized }
        }
        
        switch range {
        case .week:
          
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return data.map { formatter.string(from: $0.date).prefix(3).capitalized }
        case .month:
   
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let calendar = Calendar.current
            var result: [String] = Array(repeating: "", count: data.count)
            
      
            var uniqueMonths: [(month: Int, monthName: String, firstIndex: Int)] = []
            var seenMonths: Set<Int> = []
            
            for (index, item) in data.enumerated() {
                let month = calendar.component(.month, from: item.date)
                if !seenMonths.contains(month) {
                    seenMonths.insert(month)
                    uniqueMonths.append((month: month, monthName: formatter.string(from: item.date).prefix(3).capitalized, firstIndex: index))
                }
            }
            
       
            let monthsToShow = Array(uniqueMonths.prefix(7))
            
            if monthsToShow.count > 0 {
          
                let targetLabels = monthsToShow.count
                let step = data.count > 1 ? max(1, (data.count - 1) / (targetLabels - 1)) : 1
                
                for (i, monthInfo) in monthsToShow.enumerated() {
                    let index = min(i * step, data.count - 1)
                    result[index] = monthInfo.monthName
                }
            }
            
            return result
        case .year:
  
            let calendar = Calendar.current
            var result: [String] = Array(repeating: "", count: data.count)
            
    
            var uniqueYears: [(year: Int, firstIndex: Int)] = []
            var seenYears: Set<Int> = []
            
            for (index, item) in data.enumerated() {
                let year = calendar.component(.year, from: item.date)
                if !seenYears.contains(year) {
                    seenYears.insert(year)
                    uniqueYears.append((year: year, firstIndex: index))
                }
            }
            
      
            let yearsToShow = Array(uniqueYears.prefix(2))
            
            if yearsToShow.count > 0 {
             
                let targetLabels = yearsToShow.count
                let step = data.count > 1 ? max(1, (data.count - 1) / (targetLabels - 1)) : 1
                
                for (i, yearInfo) in yearsToShow.enumerated() {
                    let index = min(i * step, data.count - 1)
                    result[index] = "\(yearInfo.year)"
                }
            }
            
            return result
        }
    }
    
    private var hasData: Bool {
        values.contains { $0 > 0 }
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let insetLeft: CGFloat = 60 * scale
            let insetRight: CGFloat = 8 * scale
            let insetTop: CGFloat = 8 * scale
            let insetBottom: CGFloat = 34 * scale
            
            let chartWidth = width - insetLeft - insetRight
            let chartHeight = height - insetTop - insetBottom
            
            let stepX = values.count > 1 ? chartWidth / CGFloat(values.count - 1) : chartWidth
            let yMax = maxValue > 0 ? maxValue : 2400
            let yStep = yMax / 4
            let yLevels: [CGFloat] = [0, yStep, yStep * 2, yStep * 3, yMax]
            
            let axisX = insetLeft
            let baselineY = height - insetBottom
            
            ZStack {
                if !hasData {
                
                    VStack(spacing: 8 * scale) {
                        Text("No data")
                            .font(.system(size: 14 * scale, weight: .regular))
                            .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
          
                ForEach(yLevels, id: \.self) { level in
                        let ratio = level / yMax
                    let y = baselineY - ratio * chartHeight
                    
                    Path { path in
                      
                        path.move(to: CGPoint(x: axisX - 8 * scale, y: y))
                        path.addLine(to: CGPoint(x: axisX, y: y))
                    }
                        .stroke(profileManager.textSecondaryColor, lineWidth: 1)
                    
                    Text("\(Int(level))")
                        .font(.system(size: 12 * scale, weight: .regular))
                            .foregroundColor(profileManager.textSecondaryColor)
                        .frame(width: 40 * scale, alignment: .trailing)
                        .position(
                            x: axisX - 26 * scale,
                            y: y
                        )
                }
                
            
                Path { path in
               
                    path.move(to: CGPoint(x: axisX, y: insetTop))
                    path.addLine(to: CGPoint(x: axisX, y: baselineY))
                    
                
                    path.move(to: CGPoint(x: axisX, y: baselineY))
                    path.addLine(to: CGPoint(x: width - insetRight, y: baselineY))
                }
                    .stroke(profileManager.textSecondaryColor, lineWidth: 1)
           
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        if !day.isEmpty {
                    let x = axisX + stepX * CGFloat(index)
                    
               
                    Path { path in
                 
                        path.move(to: CGPoint(x: x, y: baselineY))
                        path.addLine(to: CGPoint(x: x, y: baselineY - 8 * scale))
                    }
                            .stroke(profileManager.textSecondaryColor, lineWidth: 1)
               
                    Text(day)
                        .font(.system(size: 12 * scale, weight: .regular))
                                .foregroundColor(profileManager.textSecondaryColor)
                                .multilineTextAlignment(.center)
                                .frame(width: 50 * scale, alignment: .center)
                        .position(x: x, y: baselineY + 18 * scale)
                        }
                }
                
              
                Path { path in
                    for (index, value) in values.enumerated() {
                        let x = axisX + stepX * CGFloat(index)
                            let yRatio = value / yMax
                        let y = baselineY - yRatio * chartHeight
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color(red: 1.0, green: 0.3, blue: 0.3), Color(red: 1.0, green: 0.176, blue: 0.176)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3 * scale, lineCap: .round, lineJoin: .round)
                )
                
         
                ForEach(values.indices, id: \.self) { index in
                    let value = values[index]
                        if value > 0 {
                    let x = axisX + stepX * CGFloat(index)
                            let yRatio = value / yMax
                    let y = baselineY - yRatio * chartHeight
                    
                    Circle()
                        .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                        .frame(width: 10 * scale, height: 10 * scale)
                        .position(x: x, y: y)
                        }
                    }
                }
            }
        }
        .frame(height: 200 * scale)
    }
}

struct TotalWeightBarChart: View {
    @EnvironmentObject var profileManager: ProfileManager
    let data: [(date: Date, totals: NutritionStore.Totals)]
    let scale: CGFloat
    let range: StatisticsView.StatsRange?
    
    init(data: [(date: Date, totals: NutritionStore.Totals)], scale: CGFloat, range: StatisticsView.StatsRange? = nil) {
        self.data = data
        self.scale = scale
        self.range = range
    }
    
    private var values: [CGFloat] {
        data.map { CGFloat($0.totals.grams) }
    }
    
    private var maxValue: CGFloat {
        let maxVal = values.max() ?? 1500
        return maxVal > 0 ? Swift.max(maxVal.rounded(.up), 1500) : 1500
    }
    
    private var days: [String] {
        guard let range = range else {
           
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return data.map { formatter.string(from: $0.date).prefix(3).capitalized }
        }
        
        switch range {
        case .week:
        
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE"
            return data.map { formatter.string(from: $0.date).prefix(3).capitalized }
        case .month:
  
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            let calendar = Calendar.current
            var result: [String] = Array(repeating: "", count: data.count)
          
            var uniqueMonths: [(month: Int, monthName: String, firstIndex: Int)] = []
            var seenMonths: Set<Int> = []
            
            for (index, item) in data.enumerated() {
                let month = calendar.component(.month, from: item.date)
                if !seenMonths.contains(month) {
                    seenMonths.insert(month)
                    uniqueMonths.append((month: month, monthName: formatter.string(from: item.date).prefix(3).capitalized, firstIndex: index))
                }
            }
            
            
            let monthsToShow = Array(uniqueMonths.prefix(7))
            
            if monthsToShow.count > 0 {
              
                let targetLabels = monthsToShow.count
                let step = data.count > 1 ? max(1, (data.count - 1) / (targetLabels - 1)) : 1
                
                for (i, monthInfo) in monthsToShow.enumerated() {
                    let index = min(i * step, data.count - 1)
                    result[index] = monthInfo.monthName
                }
            }
            
            return result
        case .year:

            let calendar = Calendar.current
            var result: [String] = Array(repeating: "", count: data.count)
            
      
            var uniqueYears: [(year: Int, firstIndex: Int)] = []
            var seenYears: Set<Int> = []
            
            for (index, item) in data.enumerated() {
                let year = calendar.component(.year, from: item.date)
                if !seenYears.contains(year) {
                    seenYears.insert(year)
                    uniqueYears.append((year: year, firstIndex: index))
                }
            }
            
         
            let yearsToShow = Array(uniqueYears.prefix(2))
            
            if yearsToShow.count > 0 {
             
                let targetLabels = yearsToShow.count
                let step = data.count > 1 ? max(1, (data.count - 1) / (targetLabels - 1)) : 1
                
                for (i, yearInfo) in yearsToShow.enumerated() {
                    let index = min(i * step, data.count - 1)
                    result[index] = "\(yearInfo.year)"
                }
            }
            
            return result
        }
    }
    
    private var hasData: Bool {
        values.contains { $0 > 0 }
    }
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let insetLeft: CGFloat = 60 * scale
            let insetRight: CGFloat = 8 * scale
            let insetTop: CGFloat = 8 * scale
            let insetBottom: CGFloat = 34 * scale
            
            let chartWidth = width - insetLeft - insetRight
            let chartHeight = height - insetTop - insetBottom
            
            let axisX = insetLeft
            let baselineY = height - insetBottom
            
            let barSpacing: CGFloat = values.count > 0 ? chartWidth / CGFloat(values.count) : chartWidth
            let barWidth = barSpacing * 0.55
            
            let yMax = maxValue > 0 ? maxValue : 1500
            let yStep = yMax / 4
            let yLevels: [CGFloat] = [0, yStep, yStep * 2, yStep * 3, yMax]
            
            ZStack {
                if !hasData {
             
                    VStack(spacing: 8 * scale) {
                        Text("No data")
                            .font(.system(size: 14 * scale, weight: .regular))
                            .foregroundColor(profileManager.textSecondaryColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
              
                ForEach(yLevels, id: \.self) { level in
                        let ratio = level / yMax
                    let y = baselineY - ratio * chartHeight
                    
                    Path { path in
                   
                        path.move(to: CGPoint(x: axisX - 8 * scale, y: y))
                        path.addLine(to: CGPoint(x: axisX, y: y))
                    }
                        .stroke(profileManager.textSecondaryColor, lineWidth: 1)
                    
                    Text("\(Int(level))")
                        .font(.system(size: 12 * scale, weight: .regular))
                            .foregroundColor(profileManager.textSecondaryColor)
                        .frame(width: 40 * scale, alignment: .trailing)
                        .position(
                            x: axisX - 36 * scale,
                            y: y
                        )
                }
                
              
                Path { path in
                 
                    path.move(to: CGPoint(x: axisX, y: insetTop))
                    path.addLine(to: CGPoint(x: axisX, y: baselineY))
             
                    path.move(to: CGPoint(x: axisX, y: baselineY))
                    path.addLine(to: CGPoint(x: width - insetRight, y: baselineY))
                }
                    .stroke(profileManager.textSecondaryColor, lineWidth: 1)
                
             
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    let centerX = axisX + barSpacing * (CGFloat(index) + 0.5)
                        let ratio = value / yMax
                    let barHeight = max(ratio * chartHeight, 4 * scale)
                    
                   
                        if value > 0 {
                    RoundedRectangle(cornerRadius: 6 * scale)
                        .fill(
                            LinearGradient(
                        colors: [Color(red: 1.0, green: 0.176, blue: 0.176), Color(red: 0.835, green: 0.063, blue: 0.063, opacity: 0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: barWidth, height: barHeight)
                        .position(x: centerX, y: baselineY - barHeight / 2)
                        }
                    
                   
                        if !days[index].isEmpty {
                    Path { path in
                        path.move(to: CGPoint(x: centerX, y: baselineY))
                        path.addLine(to: CGPoint(x: centerX, y: baselineY + 6 * scale))
                    }
                            .stroke(profileManager.textSecondaryColor, lineWidth: 1)
                    
                   
                    Text(days[index])
                        .font(.system(size: 12 * scale, weight: .regular))
                                .foregroundColor(profileManager.textSecondaryColor)
                                .multilineTextAlignment(.center)
                                .frame(width: 50 * scale, alignment: .center)
                        .position(x: centerX, y: baselineY + 18 * scale)
                        }
                    }
                }
            }
        }
        .frame(height: 200 * scale)
    }
}

struct TopFood: Identifiable {
    let id: String
    let name: String
    let calories: Int
    let percentage: Int
    let color: Color
}

struct TopFoodsSection: View {
    @EnvironmentObject private var nutritionStore: NutritionStore
    @EnvironmentObject var profileManager: ProfileManager
    let dates: [Date]
    let scale: CGFloat
    
    private let colors: [Color] = [
        Color(red: 1.0, green: 0.176, blue: 0.176),
        Color(red: 0.482, green: 0.247, blue: 0.894),
        Color(red: 0.0, green: 0.898, blue: 1.0),
        Color(red: 1.0, green: 0.6, blue: 0.3),
        Color(red: 0.4, green: 0.8, blue: 0.3)
    ]
    
    private var topProducts: [(name: String, totalCalories: Double, percentage: Double)] {
        var productTotals: [Int: (name: String, calories: Double)] = [:]
        
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for date in dates {
            let key = dateFormatter.string(from: date)
            guard let log = nutritionStore.logs[key] else { continue }
            
            for (_, entries) in log.meals {
                for entry in entries {
                    guard let product = nutritionStore.product(by: entry.productID) else { continue }
                    let factor = entry.grams / 100.0
                    let calories = Double(product.calories) * factor
                    
                    if let existing = productTotals[product.id] {
                        productTotals[product.id] = (existing.name, existing.calories + calories)
                    } else {
                        productTotals[product.id] = (product.name, calories)
                    }
                }
            }
        }
        
        let totalCalories = productTotals.values.reduce(0.0) { $0 + $1.calories }
        guard totalCalories > 0 else { return [] }
        
        return productTotals
            .map { (name: $0.value.name, totalCalories: $0.value.calories, percentage: ($0.value.calories / totalCalories) * 100) }
            .sorted { $0.totalCalories > $1.totalCalories }
            .prefix(5)
            .map { (name: $0.name, totalCalories: $0.totalCalories, percentage: $0.percentage) }
    }
    
    private var foods: [TopFood] {
        topProducts.enumerated().map { index, product in
            TopFood(
                id: product.name,
                name: product.name,
                calories: Int(product.totalCalories.rounded()),
                percentage: Int(product.percentage.rounded()),
                color: colors[min(index, colors.count - 1)]
            )
        }
    }
    
    private var hasData: Bool {
        !topProducts.isEmpty
    }
    
    var body: some View {
        if !hasData {
            VStack(spacing: 8 * scale) {
                Text("No data")
                    .font(.system(size: 14 * scale, weight: .regular))
                    .foregroundColor(profileManager.textSecondaryColor)
            }
            .frame(maxWidth: .infinity, minHeight: 200 * scale)
        } else {
        VStack(spacing: 20 * scale) {
            HStack(alignment: .center, spacing: 24 * scale) {
                PieChartView(foods: foods, scale: scale)
                    .frame(width: 180 * scale, height: 180 * scale)
                
                Spacer()
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .leading, spacing: 10 * scale) {
                ForEach(foods) { food in
                    HStack {
                        Circle()
                            .fill(food.color)
                            .frame(width: 8 * scale, height: 8 * scale)
                        
                        Text(food.name)
                            .font(.system(size: 14 * scale, weight: .regular))
                                .foregroundColor(profileManager.textPrimaryColor)
                        
                        Spacer()
                        
                        Text("\(food.calories) kcal")
                            .font(.system(size: 13 * scale, weight: .regular))
                                .foregroundColor(profileManager.textSecondaryColor)
                        
                        Text("\(food.percentage)%")
                            .font(.system(size: 13 * scale, weight: .semibold))
                                .foregroundColor(profileManager.textPrimaryColor)
                            .padding(.horizontal, 8 * scale)
                            .padding(.vertical, 4 * scale)
                            .background(
                                Capsule()
                                    .fill(food.color.opacity(0.2))
                            )
                        }
                    }
                }
            }
        }
    }
}

struct PieChartView: View {
    @EnvironmentObject var profileManager: ProfileManager
    let foods: [TopFood]
    let scale: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let total = foods.map { Double($0.percentage) }.reduce(0, +)
                        
            ZStack {
                if total > 0 {
                ForEach(Array(foods.enumerated()), id: \.element.id) { index, food in
                    let previousSum = foods.prefix(index).map { Double($0.percentage) }.reduce(0, +)
                    let startAngle = Angle(degrees: -90 + 360 * (previousSum / total))
                    let endAngle = startAngle + Angle(degrees: 360 * (Double(food.percentage) / total))
                    
                    Path { path in
                        path.move(to: CGPoint(x: radius, y: radius))
                        path.addArc(center: CGPoint(x: radius, y: radius),
                                    radius: radius,
                                    startAngle: startAngle,
                                    endAngle: endAngle,
                                    clockwise: false)
                    }
                    .fill(food.color)
                    }
                }
                
                Circle()
                    .fill(profileManager.cardBackgroundColor)
                    .frame(width: size * 0.55, height: size * 0.55)
                
                VStack(spacing: 4 * scale) {
                    Text("Top foods")
                        .font(.system(size: 12 * scale, weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                    
                    Text("Week")
                        .font(.system(size: 16 * scale, weight: .semibold))
                        .foregroundColor(profileManager.textPrimaryColor)
                }
            }
        }
    }
}

struct SummaryCard: View {
    @EnvironmentObject var profileManager: ProfileManager
    let title: String
    let value: String
    let unit: String
    let valueColor: Color
    let scale: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 8 * scale)
            
            Text(value)
                .font(.system(size: 32 * scale, weight: .bold))
                .foregroundColor(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10 * scale)
            
            Text(unit)
                .font(.system(size: 14 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 6 * scale)
                .padding(.bottom, 12 * scale)
        }
        .padding(.horizontal, 20 * scale)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(profileManager.cardBackgroundColor)
        .cornerRadius(26 * scale)
    }
}

struct DatabaseView: View {
    @EnvironmentObject private var nutritionStore: NutritionStore
    @EnvironmentObject var profileManager: ProfileManager

    
    enum FoodCategory: String, CaseIterable, Identifiable {
        case all = "All"
        case meat = "Meat"
        case fish = "Fish"
        case seafood = "Seafood"
        case dairy = "Dairy"
        case eggs = "Eggs"
        case vegetables = "Vegetables"
        case fruits = "Fruits"
        case berries = "Berries"
        case grains = "Grains"
        case bread = "Bread"
        case pasta = "Pasta"
        case legumes = "Legumes"
        case nuts = "Nuts"
        case seeds = "Seeds"
        case oilsSauces = "Oils & Sauces"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .all: return "🍽️"
            case .meat: return "🥩"
            case .fish: return "🐟"
            case .seafood: return "🦐"
            case .dairy: return "🥛"
            case .eggs: return "🥚"
            case .vegetables: return "🥗"
            case .fruits: return "🍎"
            case .berries: return "🫐"
            case .grains: return "🌾"
            case .bread: return "🍞"
            case .pasta: return "🍝"
            case .legumes: return "🫘"
            case .nuts: return "🥜"
            case .seeds: return "🌰"
            case .oilsSauces: return "🫗"
            }
        }
    }
    
    enum SortKey {
        case name
        case calories
        case protein
        case fat
        case carbs
    }
    

    
    @State private var searchText: String = ""
    @State private var selectedCategory: FoodCategory = .all
    @State private var sortKey: SortKey = .name
    @State private var sortAscending: Bool = true
    
 
    
    private var filteredFoods: [Product] {
        let allFoods = nutritionStore.products
        
        let categoryFiltered: [Product] = allFoods.filter { product in
            switch selectedCategory {
            case .all:
                return true
            case .meat:
                return product.category == .meat
            case .fish, .seafood:
                return product.category == .fishSeafood
            case .dairy, .eggs:
                return product.category == .eggsDairy
            case .vegetables:
                return product.category == .vegetables
            case .fruits, .berries:
                return product.category == .fruitsBerries
            case .grains:
                return product.category == .grains
            case .bread, .pasta:
                return product.category == .pastaBread
            case .legumes:
                return false
            case .nuts, .seeds:
                return product.category == .nutsSeeds
            case .oilsSauces:
                return product.category == .oilsSauces
            }
        }
        
        let searchFiltered: [Product]
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            searchFiltered = categoryFiltered
        } else {
            let lower = searchText.lowercased()
            searchFiltered = categoryFiltered.filter { $0.name.lowercased().contains(lower) }
        }
        
        let sorted: [Product] = searchFiltered.sorted { lhs, rhs in
            switch sortKey {
            case .name:
                return sortAscending ? lhs.name < rhs.name : lhs.name > rhs.name
            case .calories:
                return sortAscending ? lhs.calories < rhs.calories : lhs.calories > rhs.calories
            case .protein:
                return sortAscending ? lhs.protein < rhs.protein : lhs.protein > rhs.protein
            case .fat:
                return sortAscending ? lhs.fat < rhs.fat : lhs.fat > rhs.fat
            case .carbs:
                return sortAscending ? lhs.carbs < rhs.carbs : lhs.carbs > rhs.carbs
            }
        }
        
        return sorted
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let baseWidth: CGFloat = 393.0
            let scale = screenWidth / baseWidth
            
        ZStack {
            profileManager.backgroundColor
                .ignoresSafeArea()
            
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20 * scale) {
                    
                        VStack(alignment: .leading, spacing: 16 * scale) {
                            Text("Food Database")
                                .font(.system(size: 28 * scale, weight: .bold))
                .foregroundColor(profileManager.textPrimaryColor)
                                .padding(.horizontal, 24 * scale)
                                .padding(.top, 4 * scale)
                            
                       
                            HStack(spacing: 12 * scale) {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                
                                TextField("", text: $searchText)
                                    .font(.system(size: 16 * scale))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                    .placeholder(when: searchText.isEmpty) {
                                        Text("Search food...")
                                            .foregroundColor(profileManager.textSecondaryColor.opacity(0.6))
                                            .font(.system(size: 16 * scale))
                                    }
                            }
                            .padding(.horizontal, 16 * scale)
                            .frame(height: 48 * scale)
                            .background(profileManager.cardBackgroundColor)
                            .cornerRadius(16 * scale)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16 * scale)
                                    .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                            )
                            .padding(.horizontal, 24 * scale)
                        }
                        
                  
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10 * scale) {
                                ForEach(FoodCategory.allCases) { category in
                                    categoryChip(for: category, scale: scale)
                                }
                            }
                            .padding(.horizontal, 24 * scale)
                        }
                        
                   
                        Text("Showing \(filteredFoods.count) of \(nutritionStore.products.count) items")
                            .font(.system(size: 14 * scale))
                            .foregroundColor(Color(red: 0.722, green: 0.722, blue: 0.722))
                            .padding(.horizontal, 24 * scale)

                        HStack {
                            Spacer()

                            let horizontalInset: CGFloat = 24 * scale
                            let panelWidth: CGFloat = screenWidth - horizontalInset * 2
                        
                            let innerInset: CGFloat = 16 * scale
                            let contentWidth: CGFloat = panelWidth - innerInset * 2
                            let productWidth = contentWidth * 0.36
                            let kcalWidth    = contentWidth * 0.16
                            let macroWidth   = contentWidth * 0.10
                            let perWidth     = contentWidth * 0.18
                            
                            VStack(spacing: 0) {
                            
                                HStack(spacing: 0) {
                                    tableHeader(title: "Product", key: .name, columnWidth: productWidth, alignment: .leading, scale: scale)
                                    
                                    tableHeader(title: "Kcal", key: .calories, columnWidth: kcalWidth, alignment: .trailing, scale: scale)
                                    
                                    tableHeader(title: "P", key: .protein, columnWidth: macroWidth, alignment: .trailing, scale: scale)
                                    
                                    tableHeader(title: "F", key: .fat, columnWidth: macroWidth, alignment: .trailing, scale: scale)
                                    
                                    tableHeader(title: "C", key: .carbs, columnWidth: macroWidth, alignment: .trailing, scale: scale)
                                    
                                    Text("Per 100g")
                                        .font(.system(size: 13 * scale, weight: .regular))
                                        .foregroundColor(profileManager.textSecondaryColor)
                                        .frame(width: perWidth, alignment: .trailing)
                                }
                                .padding(.horizontal, innerInset)
                                .frame(height: 44.07 * scale)
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.568371 * scale)
                                        .foregroundColor(profileManager.borderColor),
                                    alignment: .bottom
                                )
                                
                            
                                VStack(spacing: 0) {
                                    ForEach(Array(filteredFoods.enumerated()), id: \.element.id) { index, item in
                                        foodRow(
                                            item: item,
                                            screenWidth: screenWidth,
                                            productWidth: productWidth,
                                            kcalWidth: kcalWidth,
                                            macroWidth: macroWidth,
                                            perWidth: perWidth,
                                            scale: scale,
                                            isStriped: index % 2 == 1
                                        )
                                        .overlay(
                                            Rectangle()
                                                .frame(height: 0.568371 * scale)
                                                .foregroundColor(profileManager.borderColor),
                                            alignment: .bottom
                                        )
                                    }
                                }
                            }
                            .frame(width: panelWidth)
                            .background(profileManager.cardBackgroundColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14 * scale)
                                    .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                            )
                            .cornerRadius(14 * scale)
                            
                            Spacer()
                        }
                        
                   
                        VStack(alignment: .leading, spacing: 8 * scale) {
                            Text("Data Source")
                                .font(.system(size: 15 * scale, weight: .semibold))
                                .foregroundColor(profileManager.textPrimaryColor)
                            
                            Text("Data is based on USDA FoodData Central and GOST. Values are averaged. Actual nutritional values may vary depending on manufacturer and preparation method.")
                                .font(.system(size: 13 * scale))
                                .foregroundColor(profileManager.textSecondaryColor)
                        }
                        .padding(16 * scale)
                        .background(profileManager.cardBackgroundColor)
                        .cornerRadius(18 * scale)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18 * scale)
                                .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                        )
                        .padding(.horizontal, 24 * scale)
                        .padding(.bottom, 32 * scale)
                    }
                    .padding(.top, 16 * scale)
                }
            }
        }
    }
    
   
    
    private func categoryChip(for category: FoodCategory, scale: CGFloat) -> some View {
        let isSelected = category == selectedCategory
        let accent = Color(red: 123/255, green: 63/255, blue: 228/255)
        
        return Button {
            if selectedCategory == category {
                selectedCategory = .all
            } else {
                selectedCategory = category
            }
        } label: {
            HStack(spacing: 8 * scale) {
                Text(category.icon)
                    .font(.system(size: 16 * scale))
                    .foregroundColor(isSelected ? accent : profileManager.textSecondaryColor)
                
                Text(category.rawValue)
                    .font(.system(size: 13 * scale, weight: .medium))
                    .foregroundColor(isSelected ? accent : profileManager.textSecondaryColor)
            }
            .padding(.leading, 12 * scale)
            .padding(.trailing, 12 * scale)
            .frame(height: 36.62 * scale)
            .background(
                RoundedRectangle(cornerRadius: 10 * scale)
                    .fill(
                        isSelected
                        ? accent.opacity(0.15)
                        : profileManager.cardBackgroundColor
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10 * scale)
                    .stroke(
                        isSelected
                        ? accent.opacity(0.4)
                        : profileManager.borderColor,
                        lineWidth: 0.568371 * scale
                    )
            )
        }
        .buttonStyle(.plain)
    }
    
    private func tableHeader(
        title: String,
        key: SortKey,
        columnWidth: CGFloat,
        alignment: Alignment,
        scale: CGFloat
    ) -> some View {
        let isActive = sortKey == key
        let arrowName: String
        if !isActive {
            arrowName = "arrow.up.arrow.down"
        } else {
            arrowName = sortAscending ? "chevron.up" : "chevron.down"
        }
        
        return Button {
            if sortKey == key {
                sortAscending.toggle()
            } else {
                sortKey = key
                sortAscending = key == .name
            }
        } label: {
            HStack(spacing: 4 * scale) {
                Text(title)
                    .font(.system(size: 13 * scale, weight: .medium))
                    .foregroundColor(isActive ? profileManager.textPrimaryColor : profileManager.textSecondaryColor)
                
                Image(systemName: arrowName)
                    .font(.system(size: 10 * scale, weight: .semibold))
                    .foregroundColor(isActive ? Color(red: 1.0, green: 0.176, blue: 0.176) : profileManager.textSecondaryColor)
            }
            .frame(width: columnWidth, alignment: alignment)
        }
        .buttonStyle(.plain)
    }
    
    private func foodRow(
        item: Product,
        screenWidth: CGFloat,
        productWidth: CGFloat,
        kcalWidth: CGFloat,
        macroWidth: CGFloat,
        perWidth: CGFloat,
        scale: CGFloat,
        isStriped: Bool
    ) -> some View {
        return HStack(spacing: 0) {
            Text(item.name)
                .font(.system(size: 14 * scale, weight: .regular))
                .foregroundColor(profileManager.textPrimaryColor)
                .frame(width: productWidth, alignment: .leading)
            
            Text("\(item.calories)")
                .font(.system(size: 14 * scale, weight: .semibold))
                .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                .frame(width: kcalWidth, alignment: .trailing)
            
            Text({
                let displayed = profileManager.massToDisplayed(item.protein)
                return String(format: "%.1f", displayed)
            }())
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(Color(red: 0.0, green: 0.898, blue: 1.0))
                .frame(width: macroWidth, alignment: .trailing)
            
            Text({
                let displayed = profileManager.massToDisplayed(item.fat)
                return String(format: "%.1f", displayed)
            }())
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                .frame(width: macroWidth, alignment: .trailing)
            
            Text({
                let displayed = profileManager.massToDisplayed(item.carbs)
                return String(format: "%.1f", displayed)
            }())
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(Color(red: 0.482, green: 0.247, blue: 0.894))
                .frame(width: macroWidth, alignment: .trailing)
            
            Text("100g")
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
                .frame(width: perWidth, alignment: .trailing)
        }
      
        .padding(.horizontal, 16 * scale)
        .frame(height: 45.56 * scale)
        .background(
            isStriped
            ? Color.white.opacity(0.02)
            : Color.clear
        )
    }
}

class ProfileManager: ObservableObject {
    @Published var profileImage: UIImage? = nil
    

    @AppStorage("profile_has_been_edited") var hasProfileBeenEdited: Bool = false
    

    @AppStorage("profile_name") var name: String = ""
    @AppStorage("profile_age") var age: Int = 0
    @AppStorage("profile_height_cm") var heightCm: Int = 0
    @AppStorage("profile_weight_current_kg") var currentWeightKg: Double = 0
    @AppStorage("profile_weight_goal_kg") var goalWeightKg: Double = 0
    
    @AppStorage("profile_calories_target") var dailyCaloriesTarget: Int = 0
    @AppStorage("profile_protein_target") var proteinTarget: Int = 0
    @AppStorage("profile_fat_target") var fatTarget: Int = 0
    @AppStorage("profile_carbs_target") var carbsTarget: Int = 0
    

    @AppStorage("settings_units_metric") var isMetric: Bool = true
    @AppStorage("settings_dark_mode") var isDarkMode: Bool = true
    @AppStorage("settings_notifications_enabled") var notificationsEnabled: Bool = false
    @AppStorage("settings_data_sync_automatic") var isDataSyncAutomatic: Bool = true
    
  
    func formatWeight(_ kg: Double) -> (value: String, unit: String) {
        if isMetric {
            return (String(format: "%.1f", kg), "kg")
        } else {
            let pounds = kg * 2.20462
            return (String(format: "%.1f", pounds), "lb")
        }
    }
    
    func formatHeight(_ cm: Int) -> (value: String, unit: String) {
       
        return ("\(cm)", "cm")
    }
    
    func formatWeightUnit() -> String {
        return isMetric ? "kg" : "lb"
    }
    
    func formatMassUnit() -> String {
        return isMetric ? "g" : "oz"
    }
    
    func formatMass(_ grams: Double) -> (value: String, unit: String) {
        if isMetric {
            return (String(format: "%.0f", grams), "g")
        } else {
            let ounces = grams / 28.3495
            return (String(format: "%.1f", ounces), "oz")
        }
    }

    func weightFromDisplayed(_ value: Double) -> Double {
        if isMetric {
            return value
        } else {
            return value / 2.20462
        }
    }
    
    func weightToDisplayed(_ kg: Double) -> Double {
        if isMetric {
            return kg
        } else {
            return kg * 2.20462
        }
    }
    
    func massFromDisplayed(_ value: Double) -> Double {
        if isMetric {
            return value
        } else {
            return value * 28.3495
        }
    }
    
    func massToDisplayed(_ grams: Double) -> Double {
        if isMetric {
            return grams
        } else {
            return grams / 28.3495
        }
    }
    
   
    var backgroundColor: Color {
        isDarkMode ? Color(red: 0.039, green: 0.039, blue: 0.039) : Color(red: 1.0, green: 1.0, blue: 1.0)
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color(red: 0.11, green: 0.11, blue: 0.11) : Color(red: 0.85, green: 0.85, blue: 0.85)
    }
    
    var textPrimaryColor: Color {
        isDarkMode ? .white : Color(red: 0.0, green: 0.0, blue: 0.0)
    }
    
    var textSecondaryColor: Color {
        isDarkMode ? Color(red: 0.722, green: 0.722, blue: 0.722) : Color(red: 0.3, green: 0.3, blue: 0.3)
    }
    
    var borderColor: Color {
        isDarkMode ? Color(red: 0.165, green: 0.165, blue: 0.165) : Color(red: 0.9, green: 0.9, blue: 0.9)
    }
    
    var dividerColor: Color {
        isDarkMode ? Color(red: 0.165, green: 0.165, blue: 0.165) : Color(red: 0.85, green: 0.85, blue: 0.85)
    }
    
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.notificationsEnabled = true
                } else {
                    self.notificationsEnabled = false
                }
                completion(granted)
            }
        }
    }
    
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
  
                    break
                case .denied:
                   
                    self.notificationsEnabled = false
                case .notDetermined:

                    break
                @unknown default:
                    break
                }
            }
        }
    }

    func handleNotificationToggle() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:

                    self.notificationsEnabled.toggle()
                    
                case .notDetermined:

                    self.requestNotificationPermission { _ in }
                    
                case .denied:

                    if let url = URL(string: UIApplication.openSettingsURLString),
                       UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    
                @unknown default:
                    break
                }
            }
        }
    }
    
    init() {
 
        checkNotificationStatus()
    }
}

struct ProfileView: View {
    @State private var isEditingProfile = false
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject private var nutritionStore: NutritionStore
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let baseWidth: CGFloat = 393.0
            let scale = screenWidth / baseWidth
            
        ZStack {
                profileManager.backgroundColor
                .ignoresSafeArea()
            
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24 * scale) {
                     
                        VStack(alignment: .leading, spacing: 0) {
            Text("Profile")
                                .font(.system(size: 28 * scale, weight: .bold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .padding(.horizontal, 24 * scale)
                            
                            Rectangle()
                                .fill(profileManager.dividerColor)
                                .frame(height: 1 * scale)
                                .padding(.top, 12 * scale)
                        }
                        .padding(.top, 4 * scale)
                        
                        
                        VStack(alignment: .leading, spacing: 15.99 * scale) {
                            HStack(spacing: 15.99 * scale) {
                                ZStack {
                                    Image("Container-2")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80 * scale, height: 80 * scale)
                                    
                                    if let image = profileManager.profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 72 * scale, height: 72 * scale)
                                            .clipShape(Circle())
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(profileManager.name.isEmpty ? "User" : profileManager.name)
                                        .font(.system(size: 22 * scale, weight: .semibold))
                                        .foregroundColor(profileManager.textPrimaryColor)
                                        .tracking(-0.257812 * scale)
                                    
                                    Text("Premium Member")
                                        .font(.system(size: 14 * scale, weight: .regular))
                                        .foregroundColor(profileManager.textSecondaryColor)
                                        .tracking(-0.150391 * scale)
                                }
                                
                                Spacer()
                            }
                            .frame(height: 80 * scale)
                            
                            SoundButton(action: { isEditingProfile = true }) {
                                HStack(spacing: 15.99 * scale) {
                                    Image("Edit3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17.99 * scale, height: 17.99 * scale)
                                    
                                    Text("Edit Profile")
                                        .font(.system(size: 16 * scale, weight: .semibold))
                                        .foregroundColor(Color(red: 0.482, green: 0.247, blue: 0.894))
                                        .frame(maxWidth: .infinity)
                                }
                                .frame(height: 49.14 * scale)
                                .padding(.horizontal, 24 * scale)
                                .background(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .fill(Color(red: 123/255, green: 63/255, blue: 228/255).opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .stroke(
                                            Color(red: 123/255, green: 63/255, blue: 228/255).opacity(0.4),
                                            lineWidth: 0.568371 * scale
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 24.5643 * scale)
                        .padding(.horizontal, 24.5643 * scale)
                        .padding(.bottom, 18 * scale)
                        .background(profileManager.cardBackgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18 * scale)
                                .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                        )
                        .cornerRadius(18 * scale)
                        .padding(.horizontal, 24 * scale)

                        if profileManager.hasProfileBeenEdited {
                            VStack(alignment: .leading, spacing: 15.99 * scale) {
                                Text("Daily Targets")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                    .tracking(-0.439453 * scale)
                                
                                VStack(spacing: 12 * scale) {
                                    ProfileGoalRow(
                                        icon: "Target",
                                        title: "Calorie Target",
                                        value: "\(profileManager.dailyCaloriesTarget)",
                                        unit: "kcal",
                                        valueColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        targetColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        scale: scale
                                    )
                                    
                                    ProfileGoalRow(
                                        icon: "Target",
                                        title: "Protein Target",
                                        value: {
                                            let displayedMass = profileManager.massToDisplayed(Double(profileManager.proteinTarget))
                                            return String(format: "%.1f", displayedMass)
                                        }(),
                                        unit: profileManager.formatMassUnit(),
                                        valueColor: Color(red: 0.0, green: 0.898, blue: 1.0),
                                        targetColor: Color(red: 0.0, green: 0.898, blue: 1.0),
                                        scale: scale
                                    )
                                    
                                    ProfileGoalRow(
                                        icon: "Target",
                                        title: "Fat Target",
                                        value: {
                                            let displayedMass = profileManager.massToDisplayed(Double(profileManager.fatTarget))
                                            return String(format: "%.1f", displayedMass)
                                        }(),
                                        unit: profileManager.formatMassUnit(),
                                        valueColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        targetColor: Color(red: 1.0, green: 0.176, blue: 0.176),
                                        scale: scale
                                    )
                                    
                                    ProfileGoalRow(
                                        icon: "Target",
                                        title: "Carbs Target",
                                        value: {
                                            let displayedMass = profileManager.massToDisplayed(Double(profileManager.carbsTarget))
                                            return String(format: "%.1f", displayedMass)
                                        }(),
                                        unit: profileManager.formatMassUnit(),
                                        valueColor: Color(red: 0.482, green: 0.247, blue: 0.894),
                                        targetColor: Color(red: 0.482, green: 0.247, blue: 0.894),
                                        scale: scale
                                    )
                                }
                            }
                            .padding(.horizontal, 23.9959 * scale)
                            
                        
                            VStack(alignment: .leading, spacing: 16 * scale) {
                                Text("Body Stats")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12 * scale), count: 2), spacing: 12 * scale) {
                                    let currentWeightFormatted = profileManager.formatWeight(profileManager.currentWeightKg)
                                    ProfileStatCard(
                                        title: "Current Weight",
                                        value: currentWeightFormatted.value,
                                        unit: currentWeightFormatted.unit,
                                    iconName: "Scale",
                                    iconColor: Color(red: 123/255, green: 63/255, blue: 228/255),
                                        scale: scale
                                    )
                                    
                                    let goalWeightFormatted = profileManager.formatWeight(profileManager.goalWeightKg)
                                    ProfileStatCard(
                                        title: "Goal Weight",
                                        value: goalWeightFormatted.value,
                                        unit: goalWeightFormatted.unit,
                                    iconName: "Scale",
                                    iconColor: Color(red: 123/255, green: 63/255, blue: 228/255),
                                        scale: scale
                                    )
                                    
                                    let heightFormatted = profileManager.formatHeight(profileManager.heightCm)
                                    ProfileStatCard(
                                        title: "Height",
                                        value: heightFormatted.value,
                                        unit: heightFormatted.unit,
                                    iconName: "Target",
                                    iconColor: Color(red: 123/255, green: 63/255, blue: 228/255),
                                        scale: scale
                                    )
                                    
                                    ProfileStatCard(
                                        title: "Age",
                                        value: "\(profileManager.age)",
                                        unit: "years",
                                    iconName: "Target",
                                    iconColor: Color(red: 123/255, green: 63/255, blue: 228/255),
                                        scale: scale
                                    )
                                }
                            }
                            .padding(.horizontal, 24 * scale)
                        }
  
                        if !nutritionStore.logs.isEmpty {
                            VStack(alignment: .leading, spacing: 12 * scale) {
                                Text("Progress Summary")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                
                                Text("You have logged \(nutritionStore.logs.count) day(s) of meals.")
                                    .font(.system(size: 14 * scale, weight: .regular))
                                    .foregroundColor(profileManager.textSecondaryColor)
                            }
                            .padding(.horizontal, 24 * scale)
                        }
                        
                   
                        VStack(alignment: .leading, spacing: 15.99 * scale) {
                            Text("Settings")
                                .font(.system(size: 18 * scale, weight: .semibold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .tracking(-0.439453 * scale)
                            
                            VStack(spacing: 0) {
                                ProfileSettingRow(
                                    title: "Units",
                                    value: profileManager.isMetric ? "Metric (kg, g)" : "Imperial (lb, oz)",
                                    scale: scale,
                                    action: {
                                        profileManager.isMetric.toggle()
                                    }
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.568371 * scale, alignment: .bottom)
                                        .foregroundColor(Color(red: 0.165, green: 0.165, blue: 0.165)),
                                    alignment: .bottom
                                )
                                
                                ProfileSettingRow(
                                    title: "Theme",
                                    value: profileManager.isDarkMode ? "Dark Mode" : "Light Mode",
                                    scale: scale,
                                    action: {
                                        profileManager.isDarkMode.toggle()
                                    }
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.568371 * scale, alignment: .bottom)
                                        .foregroundColor(Color(red: 0.165, green: 0.165, blue: 0.165)),
                                    alignment: .bottom
                                )
                                
                                ProfileSettingRow(
                                    title: "Notifications",
                                    value: profileManager.notificationsEnabled ? "Enabled" : "Disabled",
                                    scale: scale,
                                    action: {
                                        profileManager.handleNotificationToggle()
                                    }
                                )
                                .overlay(
                                    Rectangle()
                                        .frame(height: 0.568371 * scale, alignment: .bottom)
                                        .foregroundColor(Color(red: 0.165, green: 0.165, blue: 0.165)),
                                    alignment: .bottom
                                )
                                
                                ProfileSettingRow(
                                    title: "Data Sync",
                                    value: "Automatic",
                                    scale: scale,
                                    action: {

                                    }
                                )
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 14 * scale)
                                    .fill(profileManager.cardBackgroundColor)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14 * scale)
                                    .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                            )
                        }
                        .padding(.horizontal, 23.9959 * scale)
                        
                 
                        ZStack {
                            RoundedRectangle(cornerRadius: 14 * scale)
                                .fill(profileManager.cardBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
                                )
                                .frame(height: 218.59 * scale)
                            
                            VStack(spacing: 0) {
                                ZStack {
                                    Image("Container-4")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 100 * scale, height: 100 * scale)
                                }
                                .padding(.top, 18.56 * scale)
                                
                                
                                
                                Text("N1-Nutrition Log")
                                    .font(.system(size: 22 * scale, weight: .bold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                    .tracking(-0.257812 * scale)
                                    .padding(.top, 6 * scale)
                                
                                Text("\"Your body is your supercar. Fuel it right.\"")
                                    .font(.system(size: 14 * scale, weight: .regular).italic())
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 296 * scale)
                                    .padding(.top, 8 * scale)
                                    .foregroundColor(profileManager.textSecondaryColor)
                                
                                Text("Version 1.0.0")
                                    .font(.system(size: 13 * scale, weight: .regular))
                                    .foregroundColor(profileManager.textSecondaryColor)
                                    .tracking(-0.0761719 * scale)
                                    .padding(.top, 12 * scale)
                                
                                Spacer(minLength: 24 * scale)
                            }
                            .frame(width: 296.19 * scale)
                        }
                        .padding(.horizontal, 24 * scale)
                        .padding(.bottom, 40 * scale)
                    }
                    .padding(.top, 16 * scale)
                    .fullScreenCover(isPresented: $isEditingProfile) {
                        EditProfileView()
                            .environmentObject(profileManager)
                    }
                    .onAppear {

                        profileManager.checkNotificationStatus()
                    }
                }
            }
        }
    }
}

struct ProfileGoalRow: View {
    @EnvironmentObject var profileManager: ProfileManager
    let icon: String
    let title: String
    let value: String
    let unit: String
    let valueColor: Color
    let targetColor: Color
    let scale: CGFloat
    
    var body: some View {
        HStack(spacing: 15.9943 * scale) {
            HStack(spacing: 12 * scale) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10 * scale)
                        .fill(Color.clear)
                        .frame(width: 35.98 * scale, height: 35.98 * scale)
                    
                    Image(icon)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(targetColor)
                        .frame(width: 20 * scale, height: 20 * scale)
                }
                
                Text(title)
                    .font(.system(size: 16 * scale, weight: .regular))
                    .foregroundColor(profileManager.textPrimaryColor)
                    .tracking(-0.3125 * scale)
            }
            
            Spacer()
            
            HStack(spacing: 4 * scale) {
                Text(value)
                    .font(.system(size: 20 * scale, weight: .semibold))
                    .foregroundColor(valueColor)
                    .tracking(-0.449219 * scale)
                
                Text(unit)
                    .font(.system(size: 14 * scale, weight: .regular))
                    .foregroundColor(profileManager.textSecondaryColor)
                    .tracking(-0.150391 * scale)
            }
        }
        .padding(.horizontal, 15.9943 * scale)
        .frame(height: 69.11 * scale)
        .background(
            RoundedRectangle(cornerRadius: 14 * scale)
                .fill(profileManager.cardBackgroundColor)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14 * scale)
                .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
        )
    }
}

struct ProfileStatCard: View {
    @EnvironmentObject var profileManager: ProfileManager
    let title: String
    let value: String
    let unit: String
    let iconName: String
    let iconColor: Color
    let scale: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(iconColor)
                .scaledToFit()
                .frame(width: 20 * scale, height: 20 * scale)
                .padding(.top, 16.56 * scale)
            
            Text(title)
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
                .tracking(-0.0761719 * scale)
                .padding(.top, 16 * scale)
            
            HStack(alignment: .firstTextBaseline, spacing: 4 * scale) {
                Text(value)
                    .font(.system(size: 24 * scale, weight: .bold))
                    .foregroundColor(profileManager.textPrimaryColor)
                    .tracking(0.0703125 * scale)
                
                Text(unit)
                    .font(.system(size: 14 * scale, weight: .regular))
                    .foregroundColor(profileManager.textSecondaryColor)
                    .tracking(-0.150391 * scale)
            }
            .padding(.top, 7.5 * scale)
            
            Spacer()
        }
        .padding(.horizontal, 16.56 * scale)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .frame(height: 124.62 * scale)
        .background(profileManager.cardBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 14 * scale)
                .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
        )
        .cornerRadius(14 * scale)
    }
}

struct ProfileSettingRow: View {
    @EnvironmentObject var profileManager: ProfileManager
    let title: String
    let value: String
    let scale: CGFloat
    let action: () -> Void
    
    var body: some View {
        SoundButton(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16 * scale, weight: .regular))
                    .foregroundColor(profileManager.textPrimaryColor)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 14 * scale, weight: .regular))
                    .foregroundColor(profileManager.textSecondaryColor)
            }
            .padding(.horizontal, 15.9943 * scale)
            .frame(height: 56.56 * scale, alignment: .center)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(
                colors: colors,
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .mask(self)
    }
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}


import PhotosUI

struct ProfileImagePicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var profileManager: ProfileManager
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        private let parent: ProfileImagePicker
        
        init(_ parent: ProfileImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else {
                parent.dismiss()
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        self?.parent.profileManager.profileImage = uiImage
                    }
                    self?.parent.dismiss()
                }
            }
        }
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var profileManager: ProfileManager
    
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var height: String = ""
    @State private var currentWeight: String = ""
    @State private var goalWeight: String = ""
    
    @State private var dailyCalories: String = ""
    @State private var proteinTarget: String = ""
    @State private var fatTarget: String = ""
    @State private var carbsTarget: String = ""
    
    @State private var showingImagePicker = false
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let baseWidth: CGFloat = 393.0
            let scale = screenWidth / baseWidth
            
            ZStack {
                profileManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24 * scale) {
                     
                        VStack(spacing: 0) {
                HStack(spacing: 15.99 * scale) {
                                SoundButton(action: { dismiss() }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10 * scale)
                                            .fill(profileManager.cardBackgroundColor)
                                        
                                        Image("chevron")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20 * scale, height: 20 * scale)
                                            .foregroundColor(profileManager.textPrimaryColor)
                                    }
                                    .frame(width: 35.98 * scale, height: 35.98 * scale)
                                }
                                
                                Text("Edit Profile")
                                    .font(.system(size: 28 * scale, weight: .bold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                    .tracking(0.382812 * scale)
                                
                                Spacer()
                            }
                            .padding(.leading, 23.9959 * scale)
                            .padding(.trailing, 24 * scale)
                            .padding(.top, 4 * scale)
                            
                            Rectangle()
                                .fill(profileManager.dividerColor)
                                .frame(height: 0.568371 * scale)
                        }
                        
                        VStack(spacing: 15.99 * scale) {
                            HStack {
                                Spacer()
                                
                                ZStack {
                                    Image("Container-5")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 125 * scale, height: 125 * scale)
                                    
                                    if let image = profileManager.profileImage {
                                        Image(uiImage: image)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 125 * scale, height: 125 * scale)
                                            .clipShape(Circle())
                                    }
                                }
                                
                                Spacer()
                            }
                            .frame(width: 296.19 * scale, height: 111 * scale)
                            
                            SoundButton(action: { showingImagePicker = true }) {
                                HStack(spacing: 1.99 * scale) {
                                    Image("Edit3")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17.99 * scale, height: 17.99 * scale)
                                    
                                    Text("Change photo")
                                        .font(.system(size: 16 * scale, weight: .semibold))
                                        .foregroundColor(Color(red: 123/255, green: 63/255, blue: 228/255))
                                        .frame(maxWidth: .infinity)
                                }
                                .padding(.horizontal, 75 * scale)
                                .frame(width: 296.19 * scale, height: 30 * scale)
                                .background(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .fill(Color(red: 123/255, green: 63/255, blue: 228/255).opacity(0.15))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .stroke(Color(red: 123/255, green: 63/255, blue: 228/255).opacity(0.4),
                                                lineWidth: 0.568371 * scale)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 24.5643 * scale)
                        .padding(.horizontal, 34.5643 * scale)
                        .padding(.bottom, 16.568371 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 14 * scale)
                                .fill(profileManager.cardBackgroundColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14 * scale)
                                        .stroke(profileManager.borderColor,
                                                lineWidth: 0.568371 * scale)
                                )
                        )
                        .cornerRadius(14 * scale)
                        .padding(.horizontal, 24 * scale)
                        .sheet(isPresented: $showingImagePicker) {
                            ProfileImagePicker(profileManager: profileManager)
                        }
                        
                        VStack(alignment: .leading, spacing: 15.99 * scale) {
                            Text("Personal Information")
                                .font(.system(size: 18 * scale, weight: .semibold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .tracking(-0.439453 * scale)
                            
                            EditProfileField(label: "Name", text: $name, unit: nil, scale: scale, keyboardType: .default)
                            EditProfileField(label: "Age", text: $age, unit: "years", scale: scale, keyboardType: .numberPad)
                            EditProfileField(label: "Height", text: $height, unit: "cm", scale: scale, keyboardType: .numberPad)
                            EditProfileField(label: "Current Weight", text: $currentWeight, unit: profileManager.formatWeightUnit(), scale: scale, keyboardType: .decimalPad)
                            EditProfileField(label: "Goal Weight", text: $goalWeight, unit: profileManager.formatWeightUnit(), scale: scale, keyboardType: .decimalPad)
                        }
                        .padding(.horizontal, 24 * scale)
                        
                        VStack(alignment: .leading, spacing: 15.99 * scale) {
                            HStack {
                                Text("Nutrition Goals")
                                    .font(.system(size: 18 * scale, weight: .semibold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                                    .tracking(-0.439453 * scale)
                                
                                Spacer()
                                
                                SoundButton(action: calculateNutritionGoals) {
                                    Text("Auto calculate")
                                        .font(.system(size: 14 * scale, weight: .medium))
                                        .foregroundColor(profileManager.textSecondaryColor)
                                        .tracking(-0.150391 * scale)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            EditProfileField(label: "Daily Calories", text: $dailyCalories, unit: "kcal", scale: scale, keyboardType: .numberPad)
                            EditProfileField(label: "Protein Target", text: $proteinTarget, unit: profileManager.formatMassUnit(), scale: scale, keyboardType: .numberPad)
                            EditProfileField(label: "Fat Target", text: $fatTarget, unit: profileManager.formatMassUnit(), scale: scale, keyboardType: .numberPad)
                            EditProfileField(label: "Carbs Target", text: $carbsTarget, unit: profileManager.formatMassUnit(), scale: scale, keyboardType: .numberPad)
                        }
                        .padding(.horizontal, 24 * scale)
                        
                        Spacer(minLength: 40 * scale)
                        
                        SoundButton(action: saveProfile) {
                            HStack(spacing: 8 * scale) {
                                Image("Save")
                                    .resizable()
                                    .renderingMode(.original)
                                    .scaledToFit()
                                    .frame(width: 20 * scale, height: 20 * scale)
                                
                                Text("Save Changes")
                                    .font(.system(size: 16 * scale, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56 * scale)
                            .background(
                                RoundedRectangle(cornerRadius: 18 * scale)
                                    .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                            )
                            .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5),
                                    radius: 25 * scale)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24 * scale)
                        .padding(.bottom, 32 * scale)
                    }
                }
            }
        }
        .onAppear(perform: loadFromProfileManager)
        .onChange(of: profileManager.isMetric) { oldValue in
            if profileManager.hasProfileBeenEdited {
                loadFromProfileManager()
            } else {
                convertCurrentValues(fromOldMetric: oldValue)
            }
        }
    }
    
    private func convertCurrentValues(fromOldMetric: Bool) {
        
        if let cw = Double(currentWeight), cw > 0 {
            let kg = fromOldMetric ? cw : cw / 2.20462
            let newValue = profileManager.isMetric ? kg : kg * 2.20462
            currentWeight = String(format: "%.1f", newValue)
        }
        
        if let gw = Double(goalWeight), gw > 0 {
            let kg = fromOldMetric ? gw : gw / 2.20462
            let newValue = profileManager.isMetric ? kg : kg * 2.20462
            goalWeight = String(format: "%.1f", newValue)
        }
        
        if let p = Double(proteinTarget), p > 0 {
            let grams = fromOldMetric ? p : p * 28.3495
            let newValue = profileManager.isMetric ? grams : grams / 28.3495
            proteinTarget = String(format: "%.1f", newValue)
        }
        
        if let f = Double(fatTarget), f > 0 {
            let grams = fromOldMetric ? f : f * 28.3495
            let newValue = profileManager.isMetric ? grams : grams / 28.3495
            fatTarget = String(format: "%.1f", newValue)
        }
        
        if let c = Double(carbsTarget), c > 0 {
            let grams = fromOldMetric ? c : c * 28.3495
            let newValue = profileManager.isMetric ? grams : grams / 28.3495
            carbsTarget = String(format: "%.1f", newValue)
        }
    }
    
    private func loadFromProfileManager() {
        if profileManager.hasProfileBeenEdited {
            name = profileManager.name
            age = profileManager.age > 0 ? "\(profileManager.age)" : ""
            
            height = profileManager.heightCm > 0 ? "\(profileManager.heightCm)" : ""
            
            if profileManager.currentWeightKg > 0 {
                let displayedWeight = profileManager.weightToDisplayed(profileManager.currentWeightKg)
                currentWeight = String(format: "%.1f", displayedWeight)
            } else {
                currentWeight = ""
            }
            
            if profileManager.goalWeightKg > 0 {
                let displayedWeight = profileManager.weightToDisplayed(profileManager.goalWeightKg)
                goalWeight = String(format: "%.1f", displayedWeight)
            } else {
                goalWeight = ""
            }
            
            dailyCalories = profileManager.dailyCaloriesTarget > 0 ? "\(profileManager.dailyCaloriesTarget)" : ""
            
            if profileManager.proteinTarget > 0 {
                let displayedMass = profileManager.massToDisplayed(Double(profileManager.proteinTarget))
                proteinTarget = String(format: "%.1f", displayedMass)
            } else {
                proteinTarget = ""
            }
            
            if profileManager.fatTarget > 0 {
                let displayedMass = profileManager.massToDisplayed(Double(profileManager.fatTarget))
                fatTarget = String(format: "%.1f", displayedMass)
            } else {
                fatTarget = ""
            }
            
            if profileManager.carbsTarget > 0 {
                let displayedMass = profileManager.massToDisplayed(Double(profileManager.carbsTarget))
                carbsTarget = String(format: "%.1f", displayedMass)
            } else {
                carbsTarget = ""
            }
        } else {
            name = ""
            age = ""
            height = ""
            currentWeight = ""
            goalWeight = ""
            dailyCalories = ""
            proteinTarget = ""
            fatTarget = ""
            carbsTarget = ""
        }
    }
    
    private func calculateNutritionGoals() {
        guard let ageValue = Int(age), ageValue > 0,
              let heightCm = Int(height), heightCm > 0,
              let currentWeightInput = Double(currentWeight), currentWeightInput > 0 else {
            return
        }
        
        let currentWeightKg = profileManager.weightFromDisplayed(currentWeightInput)
        
        let bmr = 10 * currentWeightKg + 6.25 * Double(heightCm) - 5 * Double(ageValue) + 5
        
        let activityMultiplier = 1.55 
        var tdee = bmr * activityMultiplier
        
        if let goalWeightInput = Double(goalWeight), goalWeightInput > 0 {
            let goalWeightKg = profileManager.weightFromDisplayed(goalWeightInput)
            let weightDifference = currentWeightKg - goalWeightKg
            
            if weightDifference > 2 {
                tdee -= 500
            } else if weightDifference < -2 {
                tdee += 400
            }
        }
        
        let dailyCaloriesValue = Int(round(tdee / 50) * 50)
        dailyCalories = "\(dailyCaloriesValue)"
        
        let proteinGrams = currentWeightKg * 2.0
        
        let fatGrams = currentWeightKg * 0.9
        
        let proteinCalories = proteinGrams * 4
        let fatCalories = fatGrams * 9
        let remainingCalories = Double(dailyCaloriesValue) - proteinCalories - fatCalories
        let carbsGrams = max(0, remainingCalories / 4)
        
        let displayedProtein = profileManager.massToDisplayed(proteinGrams)
        let displayedFat = profileManager.massToDisplayed(fatGrams)
        let displayedCarbs = profileManager.massToDisplayed(carbsGrams)
        
        proteinTarget = String(format: "%.1f", displayedProtein)
        fatTarget = String(format: "%.1f", displayedFat)
        carbsTarget = String(format: "%.1f", displayedCarbs)
    }
    
    private func saveProfile() {
        if !name.isEmpty {
            profileManager.name = name
        }
        if let ageValue = Int(age), ageValue > 0 {
            profileManager.age = ageValue
        }
        
        if let heightValue = Int(height), heightValue > 0 {
            profileManager.heightCm = heightValue
        }
        
        if let cw = Double(currentWeight), cw > 0 {
            profileManager.currentWeightKg = profileManager.weightFromDisplayed(cw)
        }
        if let gw = Double(goalWeight), gw > 0 {
            profileManager.goalWeightKg = profileManager.weightFromDisplayed(gw)
        }
        
        if let cal = Int(dailyCalories), cal > 0 {
            profileManager.dailyCaloriesTarget = cal
        }
        
        if let p = Double(proteinTarget), p > 0 {
            profileManager.proteinTarget = Int(profileManager.massFromDisplayed(p))
        }
        if let f = Double(fatTarget), f > 0 {
            profileManager.fatTarget = Int(profileManager.massFromDisplayed(f))
        }
        if let c = Double(carbsTarget), c > 0 {
            profileManager.carbsTarget = Int(profileManager.massFromDisplayed(c))
        }
        
        profileManager.hasProfileBeenEdited = true
        
        dismiss()
    }
}


struct NumericTextField: UIViewRepresentable {
    @Binding var text: String
    var keyboardType: UIKeyboardType = .numberPad
    var placeholder: String = ""
    var isDarkMode: Bool
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.keyboardType = keyboardType
        textField.delegate = context.coordinator
        textField.textColor = isDarkMode ? .white : .black
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        if !placeholder.isEmpty {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .foregroundColor: UIColor.systemGray3,
                    .font: UIFont.systemFont(ofSize: 16, weight: .regular)
                ]
            )
        }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let flexible = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: context.coordinator,
            action: #selector(Coordinator.doneTapped)
        )
        done.tintColor = isDarkMode ? .white : .black
        toolbar.items = [flexible, done]
        toolbar.isTranslucent = true
        textField.inputAccessoryView = toolbar
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.keyboardType = keyboardType
        uiView.textColor = isDarkMode ? .white : .black
        
        if let toolbar = uiView.inputAccessoryView as? UIToolbar,
           let done = toolbar.items?.last {
            done.tintColor = isDarkMode ? .white : .black
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
        
        @objc func doneTapped() {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

struct EditProfileField: View {
    @EnvironmentObject var profileManager: ProfileManager
    let label: String
    @Binding var text: String
    let unit: String?
    let scale: CGFloat
    let keyboardType: UIKeyboardType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 7.99 * scale) {
            Text(label)
                .font(.system(size: 14 * scale, weight: .medium))
                .foregroundColor(profileManager.textSecondaryColor)
                .tracking(-0.150391 * scale)
            
            HStack {
                if keyboardType == .numberPad || keyboardType == .decimalPad {
                    NumericTextField(
                        text: $text,
                        keyboardType: keyboardType,
                        placeholder: "Enter \(label.lowercased())",
                        isDarkMode: profileManager.isDarkMode
                    )
                } else {
                    TextField("", text: $text)
                        .keyboardType(keyboardType)
                        .font(.system(size: 16 * scale, weight: .regular))
                        .foregroundColor(profileManager.textPrimaryColor)
                        .placeholder(when: text.isEmpty) {
                            Text("Enter \(label.lowercased())")
                                .foregroundColor(profileManager.textSecondaryColor.opacity(0.6))
                                .font(.system(size: 16 * scale, weight: .regular))
                        }
                }
                
                Spacer()
                
                if let unit {
                    Text(unit)
                        .font(.system(size: 14 * scale, weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                        .tracking(-0.150391 * scale)
                }
            }
            .padding(.horizontal, 16 * scale)
            .frame(height: 49.12 * scale)
            .background(profileManager.cardBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 14 * scale)
                    .stroke(profileManager.borderColor, lineWidth: 0.568371 * scale)
            )
            .cornerRadius(14 * scale)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NutritionStore())
}
