import SwiftUI

final class NavigationState: ObservableObject {
    @Published var selectedTab: Int = 0
}

