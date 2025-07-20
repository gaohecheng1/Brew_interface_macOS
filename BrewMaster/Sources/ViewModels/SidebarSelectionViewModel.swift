import SwiftUI
import Combine

class SidebarSelectionViewModel: ObservableObject {
    @Published var selection: NavigationItem? = .dashboard
}