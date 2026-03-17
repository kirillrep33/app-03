import SwiftUI

struct AddFoodView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var nutritionStore: NutritionStore
    @EnvironmentObject var profileManager: ProfileManager
    @EnvironmentObject var navigationState: NavigationState
    
    let meal: MealType
    let date: Date
    @State private var searchText: String = ""
    @State private var selectedCategory: FoodCategory = .all
    @State private var favoriteIDs: Set<Int> = []
    @State private var selectedFood: Product? = nil
    @State private var selectedAmount: Double = 100
    
    private let baseWidth: CGFloat = 393.0
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let scale = screenWidth / baseWidth
            
            ZStack {
                profileManager.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    header(scale: scale)
                        .padding(.top, 16 * scale)
                        .padding(.horizontal, 24 * scale)
                    
                    searchBar(scale: scale)
                        .padding(.top, 18 * scale)
                        .padding(.horizontal, 24 * scale)
                    
                    categoryScroll(scale: scale)
                        .padding(.top, 18 * scale)
                        .padding(.leading, 16 * scale)
                        .padding(.trailing, 0)
                    
                    titleRow(scale: scale)
                        .padding(.top, 18 * scale)
                        .padding(.horizontal, 24 * scale)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 12 * scale) {
                            ForEach(filteredFoods, id: \.id) { item in
                                AddFoodRow(
                                    item: item,
                                    isFavorite: favoriteIDs.contains(item.id),
                                    toggleFavorite: {
                                        toggleFavorite(item)
                                    },
                                    selectItem: {
                                        selectedFood = item
                                        selectedAmount = profileManager.massToDisplayed(100.0)
                                    },
                                    scale: scale
                                )
                            }
                        }
                        .padding(.horizontal, 24 * scale)
                        .padding(.top, 8 * scale)
                        .padding(.bottom, 24 * scale)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    
                    HStack(spacing: 0) {
                        TabButton(
                            icon: "Icon",
                            label: "Today",
                            isSelected: navigationState.selectedTab == 0,
                            action: {
                                navigationState.selectedTab = 0
                                dismiss()
                            },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 53.11
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-1",
                            label: "Statistics",
                            isSelected: navigationState.selectedTab == 1,
                            action: {
                                navigationState.selectedTab = 1
                                dismiss()
                            },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 70.16
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-2",
                            label: "Database",
                            isSelected: navigationState.selectedTab == 2,
                            action: {
                                navigationState.selectedTab = 2
                                dismiss()
                            },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 70.58
                        )
                        
                        Spacer()
                        
                        TabButton(
                            icon: "Icon-3",
                            label: "Profile",
                            isSelected: navigationState.selectedTab == 3,
                            action: {
                                navigationState.selectedTab = 3
                                dismiss()
                            },
                            screenWidth: geometry.size.width,
                            baseWidth: baseWidth,
                            buttonWidth: 53.42
                        )
                    }
                    .environmentObject(profileManager)
                    .padding(.horizontal, 25 * scale)
                    .frame(height: 80 * scale)
                    .frame(maxWidth: .infinity)
                    .background(profileManager.cardBackgroundColor)
                    .overlay(
                        Rectangle()
                            .frame(height: 0.568371 * scale)
                            .foregroundColor(profileManager.borderColor)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    )

                    .padding(.bottom, 0)
                }

                .ignoresSafeArea(edges: .bottom)
                
                if let food = selectedFood {
                    profileManager.backgroundColor.opacity(0.8)
                        .ignoresSafeArea()
                    
                    FoodAmountPanel(
                        food: food,
                        amount: $selectedAmount,
                        scale: scale,
                        onClose: {
                            selectedFood = nil
                        },
                        onAdd: {
                            let grams = profileManager.massFromDisplayed(selectedAmount)
                            let entry = MealEntry(id: UUID(), productID: food.id, grams: grams)
                            nutritionStore.addEntries(for: date, meal: meal, newEntries: [entry])
                            dismiss()
                            selectedFood = nil
                        }
                    )
                    .environmentObject(profileManager)
                    .frame(width: 393 * scale, height: 580 * scale)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }
    
    private var filteredFoods: [Product] {
        nutritionStore.products.filter { item in
            let matchesCategory: Bool
            switch selectedCategory {
            case .all:
                matchesCategory = true
            case .favorites:
                matchesCategory = favoriteIDs.contains(item.id)
            case .meat:
                matchesCategory = item.category == .meat
            case .fish:
                matchesCategory = item.category == .fishSeafood
            case .seafood:
                matchesCategory = item.category == .fishSeafood
            case .dairy, .eggs:
                matchesCategory = item.category == .eggsDairy
            case .vegetables:
                matchesCategory = item.category == .vegetables
            case .fruits, .berries:
                matchesCategory = item.category == .fruitsBerries
            case .grains:
                matchesCategory = item.category == .grains
            case .bread, .pasta:
                matchesCategory = item.category == .pastaBread
            case .legumes:
                matchesCategory = false
            case .nuts, .seeds:
                matchesCategory = item.category == .nutsSeeds
            case .oilsSauces:
                matchesCategory = item.category == .oilsSauces
            }
            
            let matchesSearch = searchText.isEmpty || item.name.lowercased().contains(searchText.lowercased())
            return matchesCategory && matchesSearch
        }
    }
    
    private func toggleFavorite(_ item: Product) {
        if favoriteIDs.contains(item.id) {
            favoriteIDs.remove(item.id)
        } else {
            favoriteIDs.insert(item.id)
        }
    }
    
    @ViewBuilder
    private func header(scale: CGFloat) -> some View {
        HStack {
            SoundButton(action: { dismiss() }) {
                Image("chevron")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20 * scale, height: 20 * scale)
                    .foregroundColor(profileManager.textPrimaryColor)
                    .padding(8 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 12 * scale)
                            .fill(profileManager.cardBackgroundColor)
                    )
            }
            
            Spacer()
            
            Text("Add Food")
                .font(.system(size: 28 * scale, weight: .bold))
                .foregroundColor(profileManager.textPrimaryColor)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func searchBar(scale: CGFloat) -> some View {
        HStack(spacing: 10 * scale) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(profileManager.textSecondaryColor)
            
            TextField("Search product or category...", text: $searchText)
                .foregroundColor(profileManager.textPrimaryColor)
                .font(.system(size: 15 * scale, weight: .regular))
        }
        .padding(.horizontal, 16 * scale)
        .frame(height: 48 * scale)
        .background(profileManager.cardBackgroundColor)
        .cornerRadius(16 * scale)
        .overlay(
            RoundedRectangle(cornerRadius: 16 * scale)
                .stroke(profileManager.borderColor, lineWidth: 0.6 * scale)
        )
    }
    
    @ViewBuilder
    private func categoryScroll(scale: CGFloat) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8 * scale) {
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    categoryButton(for: category, scale: scale)
                }
            }
            .padding(.trailing, 24 * scale)
        }
    }
    
    @ViewBuilder
    private func categoryButton(for category: FoodCategory, scale: CGFloat) -> some View {
        let isSelected = selectedCategory == category
        
        SoundButton(action: {
            selectedCategory = category
        }) {
            HStack(spacing: 6 * scale) {
                if let icon = category.icon {
                    Text(icon)
                        .font(.system(size: 14 * scale))
                }
                Text(category.title)
                    .font(.system(size: 14 * scale, weight: .medium))
            }
            .foregroundColor(isSelected ? profileManager.textPrimaryColor : profileManager.textSecondaryColor)
            .padding(.horizontal, 14 * scale)
            .frame(height: 36 * scale)
            .background(
                RoundedRectangle(cornerRadius: 18 * scale)
                    .fill(isSelected ? Color(red: 0.278, green: 0.0, blue: 0.639) : profileManager.cardBackgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18 * scale)
                    .stroke(isSelected ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1 * scale)
            )
        }
    }
    
    @ViewBuilder
    private func titleRow(scale: CGFloat) -> some View {
        HStack {
            Text("All Foods")
                .font(.system(size: 18 * scale, weight: .semibold))
                .foregroundColor(profileManager.textPrimaryColor)
            
            Spacer()
            
            Text("\(filteredFoods.count) items")
                .font(.system(size: 13 * scale, weight: .regular))
                .foregroundColor(profileManager.textSecondaryColor)
        }
    }
}



enum FoodCategory: CaseIterable {
    case all
    case favorites
    case meat
    case fish
    case seafood
    case dairy
    case eggs
    case vegetables
    case fruits
    case berries
    case grains
    case bread
    case pasta
    case legumes
    case nuts
    case seeds
    case oilsSauces
    
    var title: String {
        switch self {
        case .all: return "All"
        case .favorites: return "Favorites"
        case .meat: return "Meat"
        case .fish: return "Fish"
        case .seafood: return "Seafood"
        case .dairy: return "Dairy"
        case .eggs: return "Eggs"
        case .vegetables: return "Vegetables"
        case .fruits: return "Fruits"
        case .berries: return "Berries"
        case .grains: return "Grains"
        case .bread: return "Bread"
        case .pasta: return "Pasta"
        case .legumes: return "Legumes"
        case .nuts: return "Nuts"
        case .seeds: return "Seeds"
        case .oilsSauces: return "Oils & Sauces"
        }
    }
    
    var icon: String? {
        switch self {
        case .all: return "🍽"
        case .favorites: return "⭐️"
        case .meat: return "🥩"
        case .fish: return "🐟"
        case .seafood: return "🦐"
        case .dairy: return "🥛"
        case .eggs: return "🥚"
        case .vegetables: return "🥦"
        case .fruits: return "🍎"
        case .berries: return "🫐"
        case .grains: return "🌾"
        case .bread: return "🍞"
        case .pasta: return "🍝"
        case .legumes: return "🫘"
        case .nuts: return "🥜"
        case .seeds: return "🌰"
        case .oilsSauces: return "🥫"
        }
    }
}


struct AddFoodRow: View {
    @EnvironmentObject var profileManager: ProfileManager
    let item: Product
    let isFavorite: Bool
    let toggleFavorite: () -> Void
    let selectItem: () -> Void
    let scale: CGFloat
    
    var body: some View {
        SoundButton(action: selectItem) {
            HStack(alignment: .center, spacing: 16 * scale) {
                SoundButton(action: {
                    toggleFavorite()
                }) {
                    Image(isFavorite ? "h-2" : "h-1")
                        .resizable()
                        .renderingMode(.original)
                        .scaledToFit()
                        .frame(width: 36 * scale, height: 36 * scale)
                }
                
                VStack(alignment: .leading, spacing: 4 * scale) {
                    Text(item.name)
                        .font(.system(size: 17 * scale, weight: .semibold))
                        .foregroundColor(profileManager.textPrimaryColor)
                    
                    Text({
                        let pDisplayed = profileManager.massToDisplayed(item.protein)
                        let fDisplayed = profileManager.massToDisplayed(item.fat)
                        let cDisplayed = profileManager.massToDisplayed(item.carbs)
                        let unit = profileManager.formatMassUnit()
                        return String(format: "P:%.1f%@ F:%.1f%@ C:%.1f%@", pDisplayed, unit, fDisplayed, unit, cDisplayed, unit)
                    }())
                        .font(.system(size: 13 * scale, weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2 * scale) {
                    Text("\(item.calories)")
                        .font(.system(size: 20 * scale, weight: .semibold))
                        .foregroundColor(Color(red: 0.0, green: 0.898, blue: 1.0))
                    
                    Text("kcal/100g")
                        .font(.system(size: 12 * scale, weight: .regular))
                        .foregroundColor(profileManager.textSecondaryColor)
                }
            }
            .padding(.horizontal, 16 * scale)
            .frame(height: 78 * scale)
            .background(profileManager.cardBackgroundColor)
            .cornerRadius(18 * scale)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AddFoodView(meal: .breakfast, date: Date())
        .environmentObject(NutritionStore())
        .environmentObject(ProfileManager())
}

