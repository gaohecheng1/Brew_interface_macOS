import SwiftUI

struct SimpleDashboardView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text("BrewMaster 仪表盘")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // 简单的状态显示
            HStack(spacing: 20) {
                VStack {
                    Text("\(brewViewModel.installedPackages.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("已安装包")
                        .font(.caption)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                
                VStack {
                    Text("\(brewViewModel.runningServices.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("运行中服务")
                        .font(.caption)
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
                
                VStack {
                    Text("\(brewViewModel.updatablePackages.count)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("可更新")
                        .font(.caption)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
            
            // 系统信息
            VStack(alignment: .leading, spacing: 8) {
                Text("系统信息")
                    .font(.headline)
                
                HStack {
                    Text("Homebrew 版本:")
                    Spacer()
                    Text(brewViewModel.brewVersion.isEmpty ? "加载中..." : brewViewModel.brewVersion)
                }
                
                HStack {
                    Text("最后更新:")
                    Spacer()
                    Text(brewViewModel.lastUpdateTime.isEmpty ? "加载中..." : brewViewModel.lastUpdateTime)
                }
                
                HStack {
                    Text("系统:")
                    Spacer()
                    Text(brewViewModel.systemInfo.isEmpty ? "加载中..." : brewViewModel.systemInfo)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            // 刷新按钮
            Button("刷新数据") {
                brewViewModel.refreshStatus()
            }
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("SimpleDashboardView appeared")
            brewViewModel.refreshStatus()
        }
    }
}

struct SimpleDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        SimpleDashboardView()
            .environmentObject(BrewViewModel())
    }
}