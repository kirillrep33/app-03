import Foundation
import SwiftUI


enum MealType: String, Codable, CaseIterable, Identifiable {
    case breakfast
    case lunch
    case dinner
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch:     return "Lunch"
        case .dinner:    return "Dinner"
        }
    }
}

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case meat
    case fishSeafood
    case eggsDairy
    case vegetables
    case fruitsBerries
    case grains
    case pastaBread
    case nutsSeeds
    case oilsSauces
    
    var id: String { rawValue }
}

struct Product: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let category: ProductCategory
}

struct MealEntry: Identifiable, Codable {
    let id: UUID
    let productID: Int
    var grams: Double
}

struct DayLog: Identifiable, Codable {
    let id: String          
    var meals: [MealType: [MealEntry]]
    
    init(dateKey: String) {
        self.id = dateKey
        self.meals = [:]
    }
}


final class NutritionStore: ObservableObject {
    @Published private(set) var products: [Product]
    @Published private(set) var logs: [String: DayLog] = [:]
    
    private let storageKey = "nutrition_logs_v1"
    
    init(products: [Product] = NutritionProducts.allProducts) {
        self.products = products
        load()
    }
    
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([String: DayLog].self, from: data)
            self.logs = decoded
        } catch {
            print("Failed to decode logs from UserDefaults:", error)
        }
    }
    
    private func save() {
        do {
            let data = try JSONEncoder().encode(logs)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Failed to encode logs to UserDefaults:", error)
        }
    }
    
    
    private func key(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func dayLog(for date: Date) -> DayLog {
        let k = key(for: date)
        if let existing = logs[k] {
            return existing
        } else {
            return DayLog(dateKey: k)
        }
    }
    
    func entries(for date: Date, meal: MealType) -> [MealEntry] {
        let k = key(for: date)
        return logs[k]?.meals[meal] ?? []
    }
    
    func addEntries(for date: Date, meal: MealType, newEntries: [MealEntry]) {
        let k = key(for: date)
        var log = logs[k] ?? DayLog(dateKey: k)
        var mealEntries = log.meals[meal] ?? []
        mealEntries.append(contentsOf: newEntries)
        log.meals[meal] = mealEntries
        logs[k] = log
        save()
    }
    
    func removeEntry(for date: Date, meal: MealType, entryID: UUID) {
        let k = key(for: date)
        guard var log = logs[k], var mealEntries = log.meals[meal] else { return }
        mealEntries.removeAll { $0.id == entryID }
        
        if mealEntries.isEmpty {
            log.meals.removeValue(forKey: meal)
        } else {
            log.meals[meal] = mealEntries
        }
        
        if log.meals.isEmpty || log.meals.values.allSatisfy({ $0.isEmpty }) {
            logs.removeValue(forKey: k)
        } else {
            logs[k] = log
        }
        save()
    }
    
    func product(by id: Int) -> Product? {
        products.first { $0.id == id }
    }
    
    
    struct Totals {
        var calories: Double = 0
        var protein: Double = 0
        var fat: Double = 0
        var carbs: Double = 0
        var grams: Double = 0
    }
    
    func totals(for date: Date) -> Totals {
        let k = key(for: date)
        guard let log = logs[k] else { return Totals() }
        var result = Totals()
        for (_, entries) in log.meals {
            for entry in entries {
                guard let product = product(by: entry.productID) else { continue }
                let factor = entry.grams / 100.0
                result.calories += Double(product.calories) * factor
                result.protein  += product.protein * factor
                result.fat      += product.fat * factor
                result.carbs    += product.carbs * factor
                result.grams    += entry.grams
            }
        }
        return result
    }
}


enum NutritionProducts {
    static let allProducts: [Product] = [
        Product(id: 1,  name: "Chicken Breast (fillet)", calories: 113, protein: 23.6, fat: 1.9, carbs: 0.4, category: .meat),
        Product(id: 2,  name: "Chicken Thigh (skinless)", calories: 185, protein: 18.6, fat: 11.8, carbs: 0.0, category: .meat),
        Product(id: 3,  name: "Turkey Breast (fillet)", calories: 115, protein: 23.0, fat: 1.2, carbs: 0.0, category: .meat),
        Product(id: 4,  name: "Beef (lean)", calories: 187, protein: 20.0, fat: 11.0, carbs: 0.0, category: .meat),
        Product(id: 5,  name: "Beef (fatty)", calories: 254, protein: 17.0, fat: 20.0, carbs: 0.0, category: .meat),
        Product(id: 6,  name: "Pork (lean)", calories: 259, protein: 19.4, fat: 20.0, carbs: 0.0, category: .meat),
        Product(id: 7,  name: "Pork (fatty)", calories: 375, protein: 14.0, fat: 35.0, carbs: 0.0, category: .meat),
        Product(id: 8,  name: "Lamb", calories: 294, protein: 16.0, fat: 25.0, carbs: 0.0, category: .meat),
        Product(id: 9,  name: "Rabbit", calories: 156, protein: 21.0, fat: 8.0, carbs: 0.0, category: .meat),
        Product(id: 10, name: "Duck (fillet)", calories: 337, protein: 16.5, fat: 28.0, carbs: 0.0, category: .meat),
        Product(id: 11, name: "Goose", calories: 319, protein: 22.0, fat: 24.0, carbs: 0.0, category: .meat),
        Product(id: 12, name: "Veal", calories: 131, protein: 19.7, fat: 5.0, carbs: 0.0, category: .meat),
        Product(id: 13, name: "Chicken Liver", calories: 136, protein: 20.4, fat: 6.6, carbs: 0.7, category: .meat),
        Product(id: 14, name: "Beef Liver", calories: 125, protein: 17.4, fat: 5.1, carbs: 0.0, category: .meat),
        Product(id: 15, name: "Ground Chicken", calories: 143, protein: 17.4, fat: 8.0, carbs: 0.5, category: .meat),
        
        Product(id: 16, name: "Salmon (fresh)", calories: 208, protein: 20.4, fat: 13.4, carbs: 0.0, category: .fishSeafood),
        Product(id: 17, name: "Tuna (in own juice)", calories: 103, protein: 23.0, fat: 1.0, carbs: 0.0, category: .fishSeafood),
        Product(id: 18, name: "Tilapia", calories: 96, protein: 20.1, fat: 1.7, carbs: 0.0, category: .fishSeafood),
        Product(id: 19, name: "Cod", calories: 78, protein: 17.7, fat: 0.7, carbs: 0.0, category: .fishSeafood),
        Product(id: 20, name: "Pollock", calories: 79, protein: 17.6, fat: 1.0, carbs: 0.0, category: .fishSeafood),
        Product(id: 21, name: "Shrimp", calories: 95, protein: 20.0, fat: 1.8, carbs: 0.2, category: .fishSeafood),
        Product(id: 22, name: "Squid", calories: 92, protein: 18.0, fat: 2.2, carbs: 0.0, category: .fishSeafood),
        Product(id: 23, name: "Mussels", calories: 77, protein: 11.5, fat: 2.0, carbs: 3.3, category: .fishSeafood),
        Product(id: 24, name: "Herring (salted)", calories: 217, protein: 16.3, fat: 16.3, carbs: 0.0, category: .fishSeafood),
        Product(id: 25, name: "Trout", calories: 148, protein: 20.5, fat: 6.6, carbs: 0.0, category: .fishSeafood),
        
        Product(id: 26, name: "Chicken Egg (1 pc ~55g)", calories: 155, protein: 12.7, fat: 10.9, carbs: 0.7, category: .eggsDairy),
        Product(id: 27, name: "Milk 2.5%", calories: 52, protein: 2.9, fat: 2.5, carbs: 4.7, category: .eggsDairy),
        Product(id: 28, name: "Milk 3.2%", calories: 59, protein: 2.9, fat: 3.2, carbs: 4.7, category: .eggsDairy),
        Product(id: 29, name: "Cottage Cheese 0%", calories: 71, protein: 16.7, fat: 0.0, carbs: 1.3, category: .eggsDairy),
        Product(id: 30, name: "Cottage Cheese 5%", calories: 121, protein: 17.2, fat: 5.0, carbs: 1.8, category: .eggsDairy),
        Product(id: 31, name: "Cottage Cheese 9%", calories: 159, protein: 16.7, fat: 9.0, carbs: 2.0, category: .eggsDairy),
        Product(id: 32, name: "Cheddar Cheese", calories: 403, protein: 24.9, fat: 33.1, carbs: 1.3, category: .eggsDairy),
        Product(id: 33, name: "Mozzarella", calories: 280, protein: 22.2, fat: 21.6, carbs: 2.2, category: .eggsDairy),
        Product(id: 34, name: "Greek Yogurt 2%", calories: 75, protein: 9.0, fat: 2.0, carbs: 4.0, category: .eggsDairy),
        Product(id: 35, name: "Sour Cream 15%", calories: 158, protein: 2.6, fat: 15.0, carbs: 3.6, category: .eggsDairy),
        
        Product(id: 36, name: "Cucumber (fresh)", calories: 15, protein: 0.8, fat: 0.1, carbs: 3.0, category: .vegetables),
        Product(id: 37, name: "Tomato (fresh)", calories: 18, protein: 1.1, fat: 0.2, carbs: 3.7, category: .vegetables),
        Product(id: 38, name: "Broccoli", calories: 34, protein: 2.8, fat: 0.4, carbs: 6.6, category: .vegetables),
        Product(id: 39, name: "Cauliflower", calories: 25, protein: 1.9, fat: 0.3, carbs: 4.9, category: .vegetables),
        Product(id: 40, name: "Carrot", calories: 35, protein: 1.3, fat: 0.1, carbs: 7.2, category: .vegetables),
        Product(id: 41, name: "Onion", calories: 41, protein: 1.4, fat: 0.2, carbs: 9.1, category: .vegetables),
        Product(id: 42, name: "Bell Pepper", calories: 27, protein: 1.3, fat: 0.3, carbs: 5.3, category: .vegetables),
        Product(id: 43, name: "Zucchini", calories: 24, protein: 1.5, fat: 0.3, carbs: 4.6, category: .vegetables),
        Product(id: 44, name: "Eggplant", calories: 25, protein: 1.2, fat: 0.1, carbs: 4.5, category: .vegetables),
        Product(id: 45, name: "Spinach", calories: 23, protein: 2.9, fat: 0.4, carbs: 3.6, category: .vegetables),
        Product(id: 46, name: "Leaf Lettuce", calories: 15, protein: 1.4, fat: 0.2, carbs: 2.9, category: .vegetables),
        Product(id: 47, name: "Cabbage (white)", calories: 27, protein: 1.8, fat: 0.1, carbs: 4.7, category: .vegetables),
        Product(id: 48, name: "Potato (boiled)", calories: 82, protein: 2.0, fat: 0.4, carbs: 16.7, category: .vegetables),
        Product(id: 49, name: "Beet (boiled)", calories: 44, protein: 1.7, fat: 0.2, carbs: 9.6, category: .vegetables),
        Product(id: 50, name: "Green Peas", calories: 81, protein: 5.4, fat: 0.2, carbs: 14.5, category: .vegetables),
        
        Product(id: 51, name: "Apple", calories: 52, protein: 0.3, fat: 0.2, carbs: 13.8, category: .fruitsBerries),
        Product(id: 52, name: "Banana", calories: 96, protein: 1.5, fat: 0.3, carbs: 21.8, category: .fruitsBerries),
        Product(id: 53, name: "Orange", calories: 43, protein: 0.9, fat: 0.1, carbs: 9.8, category: .fruitsBerries),
        Product(id: 54, name: "Pear", calories: 57, protein: 0.4, fat: 0.3, carbs: 12.1, category: .fruitsBerries),
        Product(id: 55, name: "Grapes", calories: 69, protein: 0.7, fat: 0.2, carbs: 16.8, category: .fruitsBerries),
        Product(id: 56, name: "Strawberry", calories: 32, protein: 0.8, fat: 0.4, carbs: 7.7, category: .fruitsBerries),
        Product(id: 57, name: "Raspberry", calories: 46, protein: 1.2, fat: 0.7, carbs: 9.0, category: .fruitsBerries),
        Product(id: 58, name: "Blueberry", calories: 57, protein: 0.7, fat: 0.3, carbs: 14.5, category: .fruitsBerries),
        Product(id: 59, name: "Kiwi", calories: 61, protein: 1.1, fat: 0.6, carbs: 14.7, category: .fruitsBerries),
        Product(id: 60, name: "Pineapple", calories: 50, protein: 0.4, fat: 0.2, carbs: 11.8, category: .fruitsBerries),
        Product(id: 61, name: "Peach", calories: 46, protein: 0.9, fat: 0.1, carbs: 11.3, category: .fruitsBerries),
        Product(id: 62, name: "Apricot", calories: 48, protein: 0.9, fat: 0.1, carbs: 10.8, category: .fruitsBerries),
        Product(id: 63, name: "Watermelon", calories: 30, protein: 0.6, fat: 0.1, carbs: 7.6, category: .fruitsBerries),
        Product(id: 64, name: "Melon", calories: 35, protein: 0.6, fat: 0.3, carbs: 7.4, category: .fruitsBerries),
        Product(id: 65, name: "Grapefruit", calories: 42, protein: 0.7, fat: 0.2, carbs: 10.7, category: .fruitsBerries),
        
        Product(id: 66, name: "White Rice (boiled)", calories: 116, protein: 2.7, fat: 0.3, carbs: 25.0, category: .grains),
        Product(id: 67, name: "Brown Rice (boiled)", calories: 112, protein: 2.6, fat: 0.9, carbs: 23.5, category: .grains),
        Product(id: 68, name: "Buckwheat (boiled)", calories: 110, protein: 4.2, fat: 1.2, carbs: 21.3, category: .grains),
        Product(id: 69, name: "Oatmeal (on water)", calories: 88, protein: 3.0, fat: 1.7, carbs: 15.0, category: .grains),
        Product(id: 70, name: "Quinoa (boiled)", calories: 120, protein: 4.4, fat: 1.9, carbs: 21.3, category: .grains),
        Product(id: 71, name: "Bulgur (boiled)", calories: 83, protein: 3.1, fat: 0.2, carbs: 18.6, category: .grains),
        Product(id: 72, name: "Pearl Barley (boiled)", calories: 106, protein: 3.1, fat: 0.4, carbs: 22.9, category: .grains),
        Product(id: 73, name: "Millet (boiled)", calories: 90, protein: 3.0, fat: 0.7, carbs: 17.0, category: .grains),
        Product(id: 74, name: "Corn Porridge", calories: 86, protein: 2.1, fat: 0.4, carbs: 19.0, category: .grains),
        Product(id: 75, name: "Semolina (on water)", calories: 80, protein: 2.5, fat: 0.2, carbs: 16.8, category: .grains),
        
        Product(id: 76, name: "Pasta (boiled)", calories: 112, protein: 3.5, fat: 0.4, carbs: 23.2, category: .pastaBread),
        Product(id: 77, name: "Durum Wheat Pasta", calories: 140, protein: 5.0, fat: 0.5, carbs: 28.0, category: .pastaBread),
        Product(id: 78, name: "White Bread", calories: 265, protein: 7.6, fat: 3.2, carbs: 50.9, category: .pastaBread),
        Product(id: 79, name: "Rye Bread", calories: 214, protein: 6.6, fat: 1.2, carbs: 43.9, category: .pastaBread),
        Product(id: 80, name: "Wholegrain Crispbread", calories: 310, protein: 11.0, fat: 2.5, carbs: 60.0, category: .pastaBread),
        Product(id: 81, name: "Thin Lavash", calories: 277, protein: 9.1, fat: 1.1, carbs: 56.3, category: .pastaBread),
        Product(id: 82, name: "Pita Bread", calories: 275, protein: 9.0, fat: 1.2, carbs: 55.7, category: .pastaBread),
        Product(id: 83, name: "Croissant", calories: 406, protein: 8.2, fat: 24.0, carbs: 41.0, category: .pastaBread),
        Product(id: 84, name: "Sliced Loaf", calories: 262, protein: 7.7, fat: 2.4, carbs: 53.4, category: .pastaBread),
        Product(id: 85, name: "Rye Rusks", calories: 335, protein: 11.0, fat: 1.3, carbs: 73.0, category: .pastaBread),
        
        Product(id: 86, name: "Almonds", calories: 576, protein: 21.2, fat: 49.4, carbs: 21.7, category: .nutsSeeds),
        Product(id: 87, name: "Walnuts", calories: 654, protein: 15.2, fat: 65.2, carbs: 13.7, category: .nutsSeeds),
        Product(id: 88, name: "Peanuts", calories: 567, protein: 25.8, fat: 49.2, carbs: 16.1, category: .nutsSeeds),
        Product(id: 89, name: "Hazelnuts", calories: 628, protein: 15.0, fat: 60.8, carbs: 16.7, category: .nutsSeeds),
        Product(id: 90, name: "Cashews", calories: 553, protein: 18.2, fat: 43.9, carbs: 30.2, category: .nutsSeeds),
        Product(id: 91, name: "Sunflower Seeds", calories: 584, protein: 20.7, fat: 52.9, carbs: 20.0, category: .nutsSeeds),
        Product(id: 92, name: "Pumpkin Seeds", calories: 559, protein: 30.2, fat: 49.1, carbs: 10.7, category: .nutsSeeds),
        Product(id: 93, name: "Chia Seeds", calories: 486, protein: 16.5, fat: 30.7, carbs: 42.1, category: .nutsSeeds),
        
        Product(id: 94, name: "Olive Oil", calories: 884, protein: 0.0, fat: 100.0, carbs: 0.0, category: .oilsSauces),
        Product(id: 95, name: "Sunflower Oil", calories: 899, protein: 0.0, fat: 99.9, carbs: 0.0, category: .oilsSauces),
        Product(id: 96, name: "Butter 82%", calories: 748, protein: 0.5, fat: 82.5, carbs: 0.8, category: .oilsSauces),
        Product(id: 97, name: "Mayonnaise (classic)", calories: 627, protein: 0.4, fat: 67.0, carbs: 3.9, category: .oilsSauces),
        Product(id: 98, name: "Soy Sauce", calories: 53, protein: 5.5, fat: 0.1, carbs: 7.0, category: .oilsSauces),
        Product(id: 99, name: "Ketchup", calories: 102, protein: 1.7, fat: 0.2, carbs: 23.8, category: .oilsSauces),
        Product(id: 100, name: "Mustard", calories: 162, protein: 5.7, fat: 6.4, carbs: 22.0, category: .oilsSauces)
    ]
}

