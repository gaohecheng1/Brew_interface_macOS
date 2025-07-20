import SwiftUI

struct SimpleContentView: View {
    @StateObject private var brewViewModel = BrewViewModel()
    @StateObject private var terminalViewModel = TerminalViewModel()
    @StateObject private var sidebarSelection = SidebarSelectionViewModel()
    
    var body: some View {
        NavigationView {
            // 侧边栏
            SidebarView()
                .environmentObject(brewViewModel)
                .environmentObject(sidebarSelection)
                .frame(minWidth: 200)
            
            // 主内容区域（不使用VSplitView，先测试主视图）
            VStack {
                // 主内容
                SimpleDashboardView()
                    .environmentObject(brewViewModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Divider()
                
                // 简化的终端区域
                VStack {
                    Text("终端区域")
                        .font(.headline)
                        .padding()
                    
                    Text("这里应该显示终端内容")
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Spacer()
                }
                .frame(height: 200)
                .background(Color.gray.opacity(0.1))
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
            print("SimpleContentView appeared, refreshing status...")
            brewViewModel.refreshStatus()
        }
    }
}

struct SimpleContentView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleContentView()
    }
}