import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    
    init() {
        print("DashboardView init")
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 状态卡片
                HStack(spacing: 16) {
                    DashboardStatusCard(
                        title: "已安装包",
                        value: "\(brewViewModel.installedPackages.count)",
                        icon: "shippingbox.fill",
                        color: themeManager.primaryAccentColor
                    )
                    
                    DashboardStatusCard(
                        title: "运行中服务",
                        value: "\(brewViewModel.runningServices.count)",
                        icon: "server.rack",
                        color: themeManager.successColor
                    )
                    
                    DashboardStatusCard(
                        title: "可更新",
                        value: "\(brewViewModel.updatablePackages.count)",
                        icon: "arrow.up.circle.fill",
                        color: themeManager.warningColor
                    )
                }
                
                // 系统信息
                GroupBox("系统信息") {
                    VStack(alignment: .leading, spacing: 8) {
                        DashboardInfoRow(label: "Homebrew 版本", value: brewViewModel.brewVersion)
                        DashboardInfoRow(label: "最后更新时间", value: brewViewModel.lastUpdateTime)
                        DashboardInfoRow(label: "系统", value: brewViewModel.systemInfo)
                    }
                    .padding(.vertical, 8)
                }
                
                // 最近活动
                GroupBox("最近活动") {
                    if brewViewModel.recentActivities.isEmpty {
                        Text("暂无活动记录")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                    } else {
                        ForEach(brewViewModel.recentActivities) { activity in
                            ActivityRow(activity: activity)
                            
                            if activity.id != brewViewModel.recentActivities.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                
                // 快速操作
                GroupBox("快速操作") {
                    HStack(spacing: 16) {
                        DashboardActionButton(
                            title: "更新 Homebrew",
                            icon: "arrow.triangle.2.circlepath",
                            action: { brewViewModel.updateHomebrew() }
                        )
                        
                        DashboardActionButton(
                            title: "更新所有包",
                            icon: "arrow.up.doc",
                            action: { brewViewModel.updateAllPackages() }
                        )
                        
                        DashboardActionButton(
                            title: "清理系统",
                            icon: "trash",
                            action: { brewViewModel.cleanup() }
                        )
                    }
                    .padding(.vertical, 8)
                }
            }
            .padding()
        }
        .navigationTitle("仪表盘")
        .onAppear {
            print("DashboardView appeared - starting refresh...")
            brewViewModel.refreshStatus()
        }
    }
}

// 状态卡片组件
struct DashboardStatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(value)
                    .font(.system(size: 28, weight: .bold))
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12)
            .fill(Color(.controlBackgroundColor))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1))
        .frame(maxWidth: .infinity)
    }
}

// 信息行组件
struct DashboardInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

// 使用 ActivityRow 组件，该组件已在 Views/Components/ActivityRow.swift 中定义

// 操作按钮组件
struct DashboardActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
            .environmentObject(BrewViewModel())
    }
}