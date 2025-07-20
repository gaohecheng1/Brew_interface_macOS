import SwiftUI

struct ContentView: View {
    @StateObject private var brewViewModel = BrewViewModel()
    @StateObject private var terminalViewModel = TerminalViewModel()
    @StateObject private var sidebarSelection = SidebarSelectionViewModel()
    @AppStorage("sidebarWidth") private var sidebarWidth: Double = 180
    @AppStorage("colorScheme") private var colorScheme = "auto"
    @AppStorage("accentColor") private var accentColor = "blue"
    
    init() {
        print("ContentView init")
    }
    
    private var colorSchemeValue: ColorScheme? {
        switch colorScheme {
        case "light":
            return .light
        case "dark":
            return .dark
        default:
            return nil // 跟随系统
        }
    }
    
    private var accentColorValue: Color {
        switch accentColor {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        default:
            return .blue
        }
    }
    
    var body: some View {
        HSplitView {
            // 侧边栏
            SidebarView()
                .environmentObject(brewViewModel)
                .environmentObject(sidebarSelection)
                .frame(minWidth: 140, idealWidth: sidebarWidth, maxWidth: 300)
                .onAppear {
                    if sidebarWidth < 140 || sidebarWidth > 300 {
                        sidebarWidth = 180
                    }
                }
            
            // 主内容区域
            VStack {
                // 主内容区域
                MainContentView()
                    .environmentObject(brewViewModel)
                    .environmentObject(sidebarSelection)
                    .frame(minWidth: 350, minHeight: 300)
                
                Divider()
                
                // Brew Master 终端区域
                TerminalView()
                    .environmentObject(terminalViewModel)
                    .frame(minWidth: 400, idealHeight: 120, maxHeight: 150)
                    .background(Color.black.opacity(0.85))
                    .cornerRadius(8)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)) { _ in
            // 保存当前分割位置
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let window = NSApplication.shared.windows.first {
                    let windowWidth = window.frame.width
                    let currentSidebarWidth = min(max(sidebarWidth, 140), min(300, windowWidth * 0.4))
                    if abs(currentSidebarWidth - sidebarWidth) > 5 {
                        sidebarWidth = currentSidebarWidth
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: {
                    brewViewModel.refreshStatus()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
            }
        }
        .onAppear {
            print("ContentView appeared, refreshing status...")
            brewViewModel.refreshStatus()
        }
        .preferredColorScheme(colorSchemeValue)
        .accentColor(accentColorValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}