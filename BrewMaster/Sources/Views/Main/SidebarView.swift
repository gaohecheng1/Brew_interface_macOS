import SwiftUI

struct SidebarView: View {
    private func destinationView(for item: NavigationItem) -> some View {
        // 这个方法只是为了兼容旧版 NavigationLink API
        // 实际的视图切换由 MainContentView 中的 TabView 处理
        // 返回一个空视图，因为我们使用 HSplitView 来显示 MainContentView
        EmptyView()
    }
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @EnvironmentObject private var sidebarSelection: SidebarSelectionViewModel
    @State private var showSettings = false
    
    init() {
        print("SidebarView init")
    }
    
    // NavigationItem 枚举已移动到 Models/NavigationItem.swift
    
    var body: some View {
        List {
            Section("Homebrew 管理") {
                ForEach(NavigationItem.allCases) { item in
                    HStack {
                        Label(item.rawValue, systemImage: item.icon)
                            .foregroundColor(sidebarSelection.selection == item ? .white : .primary)
                        Spacer()
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(sidebarSelection.selection == item ? Color.accentColor : Color.clear)
                    )
                    .padding(.horizontal, 4)
                    .onTapGesture {
                        print("Tapped on \(item.rawValue)")
                        sidebarSelection.selection = item
                        print("Selection updated to: \(String(describing: sidebarSelection.selection))")
                    }
                }
            }
            
            Section("系统") {
                Button(action: {
                    // 打开设置
                    showSettings = true
                }) {
                    Label("设置", systemImage: "gear")
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .onChange(of: sidebarSelection.selection) { newValue in
            if let item = newValue {
                switch item {
                case .dashboard:
                    brewViewModel.refreshStatus()
                case .packages:
                    brewViewModel.fetchPackages()
                case .services:
                    brewViewModel.fetchServices()
                case .updates:
                    brewViewModel.checkUpdates()
                }
            }
        }
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(BrewViewModel())
            .environmentObject(SidebarSelectionViewModel())
    }
}