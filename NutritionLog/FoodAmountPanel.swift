import SwiftUI

struct FoodAmountPanel: View {
    @EnvironmentObject var profileManager: ProfileManager
    let food: Product
    @Binding var amount: Double
    let scale: CGFloat
    let onClose: () -> Void
    let onAdd: () -> Void
    
    private var amountInGrams: Double {
        profileManager.massFromDisplayed(amount)
    }
    
    private var factor: Double {
        amountInGrams / 100.0
    }
    
    private var calories: Int {
        Int(round(Double(food.calories) * factor))
    }
    
    private var protein: Int {
        Int(round(food.protein * factor))
    }
    
    private var fat: Int {
        Int(round(food.fat * factor))
    }
    
    private var carbs: Int {
        Int(round(food.carbs * factor))
    }
    
   
    private var panelBackgroundColor: Color {
        profileManager.isDarkMode
        ? Color(red: 0.11, green: 0.11, blue: 0.11)
        : profileManager.cardBackgroundColor
    }
    
    private var innerBlockBackgroundColor: Color {
        profileManager.isDarkMode
        ? Color(red: 0.082, green: 0.082, blue: 0.082)
        : Color(red: 0.75, green: 0.75, blue: 0.75)
    }
    
    private var innerBorderColor: Color {
        profileManager.isDarkMode
        ? Color(red: 0.165, green: 0.165, blue: 0.165)
        : profileManager.borderColor
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(food.name)
                    .font(.system(size: 22 * scale, weight: .bold))
                    .foregroundColor(profileManager.textPrimaryColor)
                
                Spacer()
                
                SoundButton(action: onClose) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10 * scale)
                            .fill(innerBlockBackgroundColor)
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 16 * scale, weight: .bold))
                            .foregroundColor(profileManager.textSecondaryColor)
                    }
                    .frame(width: 36 * scale, height: 36 * scale)
                }
            }
            .padding(.horizontal, 24 * scale)
            .frame(height: 69 * scale)
            .overlay(
                Rectangle()
                    .frame(height: 0.57 * scale)
                    .foregroundColor(innerBorderColor),
                alignment: .bottom
            )
            
            ZStack(alignment: .top) {
                Color.clear
                
                VStack(spacing: 32 * scale) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16 * scale)
                            .fill(Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16 * scale)
                                    .stroke(
                                        Color(red: 1.0, green: 0.176, blue: 0.176)
                                            .opacity(0.3),
                                        lineWidth: 0.568371 * scale
                                    )
                            )
                        
                        VStack(spacing: 4 * scale) {
                            Text("\(calories)")
                                .font(.system(size: 36 * scale, weight: .bold))
                                .foregroundColor(Color(red: 1.0, green: 0.176, blue: 0.176))
                            
                            Text("kcal")
                                .font(.system(size: 14 * scale, weight: .regular))
                                .foregroundColor(profileManager.textSecondaryColor)
                        }
                    }
                    .frame(width: 114 * scale, height: 90 * scale)
                    .padding(.top, 24 * scale)
                    
                    HStack(spacing: 12 * scale) {
                        macroCard(value: {
                            let displayed = profileManager.massToDisplayed(Double(protein))
                            return String(format: "%.1f%@", displayed, profileManager.formatMassUnit())
                        }(), label: "Protein", color: Color(red: 0.0, green: 0.898, blue: 1.0))
                        macroCard(value: {
                            let displayed = profileManager.massToDisplayed(Double(fat))
                            return String(format: "%.1f%@", displayed, profileManager.formatMassUnit())
                        }(), label: "Fat", color: Color(red: 1.0, green: 0.176, blue: 0.176))
                        macroCard(value: {
                            let displayed = profileManager.massToDisplayed(Double(carbs))
                            return String(format: "%.1f%@", displayed, profileManager.formatMassUnit())
                        }(), label: "Carbs", color: Color(red: 0.482, green: 0.247, blue: 0.894))
                    }
                    .padding(.horizontal, 24 * scale)
                    
                    VStack(alignment: .leading, spacing: 12 * scale) {
                        Text("Amount")
                            .font(.system(size: 16 * scale, weight: .medium))
                            .foregroundColor(profileManager.textPrimaryColor)
                        
                        HStack(spacing: 16 * scale) {
                            amountSquareButton(symbol: "minus") {
                                let grams = profileManager.massFromDisplayed(amount)
                                let newGrams = max(0, grams - 10.0)
                                amount = profileManager.massToDisplayed(newGrams)
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 14 * scale)
                                    .fill(innerBlockBackgroundColor)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14 * scale)
                                            .stroke(innerBorderColor,
                                                    lineWidth: 0.57 * scale)
                                    )
                                
                                Text(String(format: "%.1f", amount))
                                    .font(.system(size: 20 * scale, weight: .semibold))
                                    .foregroundColor(profileManager.textPrimaryColor)
                            }
                            .frame(height: 55 * scale)
                            
                            amountSquareButton(symbol: "plus") {
                                let grams = profileManager.massFromDisplayed(amount)
                                let newGrams = grams + 10.0
                                amount = profileManager.massToDisplayed(newGrams)
                            }
                        }
                        
                        Text(profileManager.formatMassUnit())
                            .font(.system(size: 14 * scale, weight: .regular))
                            .foregroundColor(profileManager.textSecondaryColor)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 24 * scale)
                    
                    Spacer()
                }
            }
            
            SoundButton(action: onAdd) {
                Text("Add to Meal")
                    .font(.system(size: 16 * scale, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56 * scale)
                    .background(Color(red: 1.0, green: 0.176, blue: 0.176))
                    .cornerRadius(14 * scale)
                    .shadow(color: Color(red: 1.0, green: 0.176, blue: 0.176).opacity(0.5),
                            radius: 20 * scale)
                    .padding(.horizontal, 24 * scale)
                    .padding(.bottom, 16 * scale)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24 * scale)
                .fill(panelBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24 * scale)
                        .stroke(innerBorderColor,
                                lineWidth: 0.57 * scale)
                )
        )
    }
    
    @ViewBuilder
    private func macroCard(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4 * scale) {
            Text(value)
                .font(.system(size: 24 * scale, weight: .semibold))
                .foregroundColor(color)
            
            Text(label)
                .font(.system(size: 16 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 92 * scale)
        .background(
            RoundedRectangle(cornerRadius: 24 * scale)
                .fill(innerBlockBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 24 * scale)
                        .stroke(innerBorderColor,
                                lineWidth: 0.57 * scale)
                )
        )
    }
    
    @ViewBuilder
    private func amountSquareButton(symbol: String, action: @escaping () -> Void) -> some View {
        SoundButton(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 14 * scale)
                    .fill(innerBlockBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14 * scale)
                            .stroke(innerBorderColor,
                                    lineWidth: 0.57 * scale)
                    )
                
                Image(systemName: symbol)
                    .font(.system(size: 20 * scale, weight: .bold))
                    .foregroundColor(profileManager.textPrimaryColor)
            }
            .frame(width: 48 * scale, height: 48 * scale)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func amountButton(symbol: String, action: @escaping () -> Void) -> some View {
        SoundButton(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 22 * scale)
                    .fill(innerBlockBackgroundColor)
                Image(systemName: symbol)
                    .font(.system(size: 22 * scale, weight: .bold))
                    .foregroundColor(profileManager.textPrimaryColor)
            }
            .frame(width: 70 * scale, height: 70 * scale)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    FoodAmountPanel(
        food: Product(id: 17, name: "Tuna (in own juice)", calories: 103, protein: 23, fat: 1, carbs: 0, category: .fishSeafood),
        amount: .constant(100),
        scale: 1.0,
        onClose: {},
        onAdd: {}
    )
    .environmentObject(ProfileManager())
}

