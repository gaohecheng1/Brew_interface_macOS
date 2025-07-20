import SwiftUI

struct MainContentView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @EnvironmentObject private var sidebarSelection: SidebarSelectionViewModel
    
    init() {
        print("MainContentView init")
    }
    
    var body: some View {
        Group {
            switch sidebarSelection.selection {
            case .dashboard:
                DashboardView()
                    .environmentObject(brewViewModel)
            case .packages:
                PackageManagementView()
                    .environmentObject(brewViewModel)
            case .services:
                ServiceManagementView()
                    .environmentObject(brewViewModel)
            case .updates:
                UpdatesView()
                    .environmentObject(brewViewModel)
            case .none:
                SimpleDashboardView()
                    .environmentObject(brewViewModel)
            }
        }
        .onAppear {
            print("MainContentView appeared")
            print("Current selection: \(String(describing: sidebarSelection.selection))")
            // 确保在视图出现时有一个选定的选项卡
            if sidebarSelection.selection == nil {
                sidebarSelection.selection = .dashboard
                print("Set default selection to dashboard")
            }
        }
    }
}

struct MainContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainContentView()
            .environmentObject(BrewViewModel())
            .environmentObject(SidebarSelectionViewModel())
    }
}