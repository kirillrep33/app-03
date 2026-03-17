import SwiftUI

@main
struct NutritionLogApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var nutritionStore = NutritionStore()
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(nutritionStore)
            } else {
                OnboardingView()
                    .environmentObject(nutritionStore)
            }
        }
    }
}
