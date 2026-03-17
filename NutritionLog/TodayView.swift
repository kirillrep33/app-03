import SwiftUI

struct TodayView: View {
    @EnvironmentObject private var nutritionStore: NutritionStore
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var navigationState: NavigationState
    
    @State private var selectedMeal: MealType = .breakfast
    @State private var isPresentingAddFood: Bool = false
    @State private var selectedDate: Date = Date()
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let baseWidth: CGFloat = 393.0
            
            ZStack {
                profileManager.backgroundColor
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Today")
                                .font(.system(size: 28 * (screenWidth / baseWidth), weight: .bold))
                                .foregroundColor(profileManager.textPrimaryColor)
                                .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                            
                            Text(dateString(selectedDate))
                                .font(.system(size: 14 * (screenWidth / baseWidth), weight: .regular))
                                .foregroundColor(profileManager.textSecondaryColor)
                                .padding(.top, 2 * (screenWidth / baseWidth))
                                .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                            
                            Rectangle()
                                .fill(profileManager.dividerColor)
                                .frame(height: 1 * (screenWidth / baseWidth))
                                .padding(.top, 12 * (screenWidth / baseWidth))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 0)
                        
                        GeometryReader { _ in
                            ZStack {
                                Image(profileManager.isDarkMode ? "svg-2" : "svg-3")
                                    .resizable()
                                    .frame(width: 220 * (screenWidth / baseWidth),
                                           height: 220 * (screenWidth / baseWidth))
                                
                                let totals = nutritionStore.totals(for: selectedDate)
                                
                                VStack(spacing: 4 * (screenWidth / baseWidth)) {
                                    Text("Calories Today")
                                        .font(.system(size: 12 * (screenWidth / baseWidth), weight: .regular))
                                        .foregroundColor(profileManager.textSecondaryColor)
                                    
                                    Text("\(Int(totals.calories.rounded()))")
                                        .font(.system(size: 32 * (screenWidth / baseWidth), weight: .bold))
                                        .foregroundColor(profileManager.textPrimaryColor)
                                        .tracking(1.04625 * (screenWidth / baseWidth))
                                    
                                    Text("/ \(profileManager.dailyCaloriesTarget > 0 ? profileManager.dailyCaloriesTarget : 2200) kcal")
                                        .font(.system(size: 14 * (screenWidth / baseWidth), weight: .regular))
                                        .foregroundColor(profileManager.textSecondaryColor)
                                        .tracking(-0.150391 * (screenWidth / baseWidth))
                                }
                            }
                            .frame(width: 220 * (screenWidth / baseWidth),
                                   height: 220 * (screenWidth / baseWidth),
                                   alignment: .center)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                            .padding(.leading, 62.66 * (screenWidth / baseWidth))
                            .padding(.top, 0)
                        }
                        .frame(width: 345.32 * (screenWidth / baseWidth), height: 220 * (screenWidth / baseWidth))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 24 * (screenWidth / baseWidth))
                        .padding(.top, 27.55 * (screenWidth / baseWidth))
                        
                        VStack(spacing: 16 * (screenWidth / baseWidth)) {
                            let totals = nutritionStore.totals(for: selectedDate)
                            let proteinInt = Int(totals.protein.rounded())
                            let fatInt = Int(totals.fat.rounded())
                            let carbsInt = Int(totals.carbs.rounded())
                            MacronutrientBar(
                                label: "Protein",
                                current: proteinInt,
                                goal: profileManager.proteinTarget > 0 ? profileManager.proteinTarget : 165,
                                color: Color(red: 0.0, green: 0.898, blue: 1.0),
                                screenWidth: screenWidth,
                                baseWidth: baseWidth
                            )
                            
                            MacronutrientBar(
                                label: "Fat",
                                current: fatInt,
                                goal: profileManager.fatTarget > 0 ? profileManager.fatTarget : 73,
                                color: Color(red: 1.0, green: 0.176, blue: 0.176),
                                screenWidth: screenWidth,
                                baseWidth: baseWidth
                            )
                            
                            MacronutrientBar(
                                label: "Carbs",
                                current: carbsInt,
                                goal: profileManager.carbsTarget > 0 ? profileManager.carbsTarget : 220,
                                color: Color(red: 0.482, green: 0.247, blue: 0.894),
                                screenWidth: screenWidth,
                                baseWidth: baseWidth
                            )
                        }
                        .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                        .padding(.top, 31.99 * (screenWidth / baseWidth))
                        
                        HStack(spacing: 4 * (screenWidth / baseWidth)) {
                            ForEach(MealType.allCases, id: \.self) { meal in
                                SoundButton(action: {
                                    selectedMeal = meal
                                }) {
                                    Text(meal.title)
                                        .font(.system(size: 16 * (screenWidth / baseWidth), weight: .medium))
                                        .foregroundColor(
                                            selectedMeal == meal
                                                ? Color(red: 1.0, green: 0.176, blue: 0.176)
                                                : Color(red: 0.722, green: 0.722, blue: 0.722)
                                        )
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 49.14 * (screenWidth / baseWidth))
                                        .background(
                                            selectedMeal == meal
                                                ? Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.15)
                                                : Color.clear
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10 * (screenWidth / baseWidth))
                                                .stroke(
                                                    selectedMeal == meal
                                                        ? Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.3)
                                                        : Color.clear,
                                                    lineWidth: 0.568371 * (screenWidth / baseWidth)
                                                )
                                        )
                                        .cornerRadius(10 * (screenWidth / baseWidth))
                                        .shadow(
                                            color: selectedMeal == meal
                                                ? Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.2)
                                                : Color.clear,
                                            radius: 15 * (screenWidth / baseWidth)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 4 * (screenWidth / baseWidth))
                        .padding(.top, 4 * (screenWidth / baseWidth))
                        .background(profileManager.cardBackgroundColor)
                        .cornerRadius(14 * (screenWidth / baseWidth))
                        .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                        .padding(.top, 15.99 * (screenWidth / baseWidth))
                        
                        VStack(spacing: 12 * (screenWidth / baseWidth)) {
                            let entries = nutritionStore.entries(for: selectedDate, meal: selectedMeal)
                            
                            ForEach(entries) { entry in
                                if let product = nutritionStore.product(by: entry.productID) {
                                    FoodItemRow(
                                        entry: entry,
                                        product: product,
                                        profileManager: profileManager,
                                        screenWidth: screenWidth,
                                        baseWidth: baseWidth,
                                        selectedDate: selectedDate,
                                        selectedMeal: selectedMeal,
                                        nutritionStore: nutritionStore
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                        .padding(.top, 15.99 * (screenWidth / baseWidth))
                        
                        Text("\"Your body is your supercar. Fuel it right.\"")
                            .font(.system(size: 14 * (screenWidth / baseWidth), weight: .regular))
                            .italic()
                            .foregroundColor(profileManager.textSecondaryColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 23.9959 * (screenWidth / baseWidth))
                            .padding(.top, 20)
                            .padding(.bottom, 80 * (screenWidth / baseWidth))
                    }
                }
                
                VStack {
                    Spacer()
                        HStack {
                            Spacer()
                            SoundButton(action: {
                            isPresentingAddFood = true
                            }) {
                            Image(systemName: "plus")
                                .font(.system(size: 28 * (screenWidth / baseWidth), weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56 * (screenWidth / baseWidth), height: 56 * (screenWidth / baseWidth))
                                .background(Color(red: 1.0, green: 0.176, blue: 0.176))
                                .clipShape(Circle())
                                .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.6), radius: 25 * (screenWidth / baseWidth))
                        }
                        .padding(.trailing, 23.9959 * (screenWidth / baseWidth))
                        .padding(.bottom, 10 * (screenWidth / baseWidth))
                    }
                }
                .fullScreenCover(isPresented: $isPresentingAddFood) {
                    AddFoodView(meal: selectedMeal, date: selectedDate)
                        .environmentObject(profileManager)
                        .environmentObject(navigationState)
                        .environmentObject(nutritionStore)
                }
            }
        }
    }
}


private func dateString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale.current
    formatter.dateStyle = .full
    return formatter.string(from: date)
}

struct MacronutrientBar: View {
    @EnvironmentObject var profileManager: ProfileManager
    let label: String
    let current: Int
    let goal: Int
    let color: Color
    let screenWidth: CGFloat
    let baseWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8 * (screenWidth / baseWidth)) {
            HStack {
                Text(label)
                    .font(.system(size: 14 * (screenWidth / baseWidth), weight: .regular))
                    .foregroundColor(profileManager.textPrimaryColor)
                
                Spacer()
                
                Text({
                    let currentDisplayed = profileManager.massToDisplayed(Double(current))
                    let goalDisplayed = profileManager.massToDisplayed(Double(goal))
                    let unit = profileManager.formatMassUnit()
                    return String(format: "%.1f%@ / %.1f%@", currentDisplayed, unit, goalDisplayed, unit)
                }())
                    .font(.system(size: 14 * (screenWidth / baseWidth), weight: .regular))
                    .foregroundColor(profileManager.textSecondaryColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 1000000)
                        .fill(profileManager.borderColor)
                        .frame(height: 8 * (screenWidth / baseWidth))
                    
                    RoundedRectangle(cornerRadius: 1000000)
                        .fill(color)
                        .frame(width: min(geometry.size.width * CGFloat(current) / CGFloat(max(goal, 1)), geometry.size.width),
                               height: 8 * (screenWidth / baseWidth))
                }
            }
            .frame(height: 8 * (screenWidth / baseWidth))
        }
    }
}

struct FoodItemCard: View {
    @EnvironmentObject var profileManager: ProfileManager
    let name: String
    let amount: String
    let protein: Int
    let fat: Int
    let carbs: Int
    let calories: Int
    let screenWidth: CGFloat
    let baseWidth: CGFloat
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4 * (screenWidth / baseWidth)) {
                        Text(name)
                            .font(.system(size: 16 * (screenWidth / baseWidth), weight: .semibold))
                            .foregroundColor(profileManager.textPrimaryColor)
                        
                        Text(amount)
                            .font(.system(size: 13 * (screenWidth / baseWidth), weight: .regular))
                            .foregroundColor(profileManager.textSecondaryColor)
                            .padding(.top, 4 * (screenWidth / baseWidth))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10 * (screenWidth / baseWidth))
                            .fill(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10 * (screenWidth / baseWidth))
                                    .stroke(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.3),
                                            lineWidth: 0.568371 * (screenWidth / baseWidth))
                            )
                        
                        HStack(spacing: 0) {
                            Text("\(calories)")
                                .font(.system(size: 16 * (screenWidth / baseWidth), weight: .semibold))
                                .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                                .tracking(-0.3125 * (screenWidth / baseWidth))
                            
                            Text("kcal")
                                .font(.system(size: 16 * (screenWidth / baseWidth), weight: .semibold))
                                .foregroundColor(profileManager.textSecondaryColor)
                                .tracking(-0.3125 * (screenWidth / baseWidth))
                                .padding(.leading, 2 * (screenWidth / baseWidth))
                        }
                    }
                    .frame(width: 80.95 * (screenWidth / baseWidth),
                           height: 33.13 * (screenWidth / baseWidth),
                           alignment: .center)
                }
                .padding(.top, 16.56 * (screenWidth / baseWidth))
                
                SoundButton(action: onDelete) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10 * (screenWidth / baseWidth))
                            .fill(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.1))
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 10 * (screenWidth / baseWidth), weight: .bold))
                            .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 10 * (screenWidth / baseWidth))
                            .stroke(Color(red: 1.0, green: 0.176, blue: 0.176),
                                    lineWidth: 0.568371 * (screenWidth / baseWidth))
                    )
                    .frame(width: 13.99 * (screenWidth / baseWidth),
                           height: 13.99 * (screenWidth / baseWidth))
                }
                .padding(.top, 12.57 * (screenWidth / baseWidth))
                .offset(x: 6 * (screenWidth / baseWidth))
            }
            .padding(.bottom, 12.07 * (screenWidth / baseWidth))
            
            HStack(spacing: 16 * (screenWidth / baseWidth)) {
                HStack(spacing: 8 * (screenWidth / baseWidth)) {
                    Circle()
                        .fill(Color(red: 0.0, green: 0.898, blue: 1.0))
                        .frame(width: 8 * (screenWidth / baseWidth), height: 8 * (screenWidth / baseWidth))
                    Text({
                        let displayed = profileManager.massToDisplayed(Double(protein))
                        let unit = profileManager.formatMassUnit()
                        return String(format: "P %.1f%@", displayed, unit)
                    }())
                        .font(.system(size: 13 * (screenWidth / baseWidth), weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                }
                
                HStack(spacing: 8 * (screenWidth / baseWidth)) {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.176, blue: 0.176))
                        .frame(width: 8 * (screenWidth / baseWidth), height: 8 * (screenWidth / baseWidth))
                    Text({
                        let displayed = profileManager.massToDisplayed(Double(fat))
                        let unit = profileManager.formatMassUnit()
                        return String(format: "F %.1f%@", displayed, unit)
                    }())
                        .font(.system(size: 13 * (screenWidth / baseWidth), weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                }
                
                HStack(spacing: 8 * (screenWidth / baseWidth)) {
                    Circle()
                        .fill(Color(red: 0.482, green: 0.247, blue: 0.894))
                        .frame(width: 8 * (screenWidth / baseWidth), height: 8 * (screenWidth / baseWidth))
                    Text({
                        let displayed = profileManager.massToDisplayed(Double(carbs))
                        let unit = profileManager.formatMassUnit()
                        return String(format: "C %.1f%@", displayed, unit)
                    }())
                        .font(.system(size: 13 * (screenWidth / baseWidth), weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                }
            }
        }
        .padding(16.56 * (screenWidth / baseWidth))
        .background(profileManager.cardBackgroundColor) 
        .overlay(
            RoundedRectangle(cornerRadius: 14 * (screenWidth / baseWidth))
                .stroke(profileManager.borderColor, lineWidth: 0.568371 * (screenWidth / baseWidth))
        )
        .cornerRadius(14 * (screenWidth / baseWidth))
    }
}

struct FoodItemRow: View {
    let entry: MealEntry
    let product: Product
    let profileManager: ProfileManager
    let screenWidth: CGFloat
    let baseWidth: CGFloat
    let selectedDate: Date
    let selectedMeal: MealType
    let nutritionStore: NutritionStore
    
    var body: some View {
        let factor = entry.grams / 100.0
        let calories = Int((Double(product.calories) * factor).rounded())
        let protein = Int((product.protein * factor).rounded())
        let fat = Int((product.fat * factor).rounded())
        let carbs = Int((product.carbs * factor).rounded())
        let massFormatted = profileManager.formatMass(entry.grams)
        
        return FoodItemCard(
            name: product.name,
            amount: "\(massFormatted.value)\(massFormatted.unit)",
            protein: protein,
            fat: fat,
            carbs: carbs,
            calories: calories,
            screenWidth: screenWidth,
            baseWidth: baseWidth,
            onDelete: {
                nutritionStore.removeEntry(for: selectedDate, meal: selectedMeal, entryID: entry.id)
            }
        )
    }
}

#Preview {
    TodayView()
        .environmentObject(NutritionStore())
        .environmentObject(ProfileManager())
}
