import SwiftUI

struct ServiceDetailView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    let service: BrewServiceModel
    @State private var isLoading = false
    @State private var showingLogs = false
    @State private var logs: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 服务标题和状态
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(service.name)
                            .font(.largeTitle)
                            .bold()
                        
                        HStack {
                            Circle()
                                .fill(service.isRunning ? Color.green : Color.gray)
                                .frame(width: 10, height: 10)
                            
                            Text(service.status)
                                .font(.headline)
                                .foregroundColor(service.isRunning ? .green : .secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "server.rack")
                        .font(.system(size: 48))
                        .foregroundColor(.blue)
                }
                
                Divider()
                
                // 服务信息
                Group {
                    InfoSectionView(title: "服务名称", content: service.name)
                    
                    InfoSectionView(title: "状态", content: service.status)
                    
                    if !service.user.isEmpty {
                        InfoSectionView(title: "用户", content: service.user)
                    }
                    
                    if !service.plist.isEmpty {
                        InfoSectionView(title: "配置文件", content: service.plist)
                    }
                    
                    if service.isRunning, let pid = service.pid {
                        InfoSectionView(title: "进程 ID", content: String(pid))
                    }
                    
                    if let lastRun = service.lastRunTime {
                        let formattedDate: String = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            formatter.timeStyle = .medium
                            return formatter.string(from: lastRun)
                        }()
                        InfoSectionView(title: "最后运行时间", content: formattedDate)
                    }
                    
                    if let version = service.version, !version.isEmpty {
                        InfoSectionView(title: "版本", content: version)
                    }
                }
                
                // 日志查看按钮
                Button(action: {
                    showingLogs = true
                    fetchServiceLogs()
                }) {
                    Label("查看日志", systemImage: "doc.text")
                }
                .buttonStyle(.bordered)
                .padding(.top)
                
                Spacer()
                
                // 操作按钮
                HStack(spacing: 16) {
                    if service.isRunning {
                        Button(action: {
                            isLoading = true
                            brewViewModel.stopService(service.name) { success in
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Label("停止服务", systemImage: "stop.circle")
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(isLoading)
                        
                        Button(action: {
                            isLoading = true
                            brewViewModel.restartService(service.name) { success in
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Label("重启服务", systemImage: "arrow.triangle.2.circlepath")
                            }
                        }
                        .buttonStyle(.bordered)
                        .disabled(isLoading)
                    } else {
                        Button(action: {
                            isLoading = true
                            brewViewModel.startService(service.name) { success in
                                isLoading = false
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.7)
                                    .frame(width: 16, height: 16)
                            } else {
                                Label("启动服务", systemImage: "play.circle")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                    }
                }
                .padding(.top)
            }
            .padding()
        }
        .sheet(isPresented: $showingLogs) {
            ServiceLogsView(serviceName: service.name, logs: logs)
        }
    }
    
    private func fetchServiceLogs() {
        logs = "正在加载日志..."
        brewViewModel.getServiceLogs(service.name) { logContent in
            logs = logContent
        }
    }
}

// 服务日志视图
struct ServiceLogsView: View {
    let serviceName: String
    let logs: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("\(serviceName) 服务日志")
                    .font(.headline)
                
                Spacer()
                
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
            
            Divider()
            
            // 日志内容
            ScrollView {
                Text(logs)
                    .font(.system(.body, design: .monospaced))
                    .padding()
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(width: 700, height: 500)
    }
}

struct ServiceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockService = BrewServiceModel(
            id: "1",
            name: "mysql",
            status: "started",
            user: "gaoheyuan",
            plist: "/usr/local/opt/mysql/homebrew.mxcl.mysql.plist",
            isRunning: true,
            pid: 12345,
            lastRunTime: Date(),
            version: "8.0.33"
        )
        
        ServiceDetailView(service: mockService)
            .environmentObject(BrewViewModel())
            .frame(width: 500, height: 600)
    }
}