import SwiftUI

struct PackageDetailView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    let package: BrewPackage
    @State private var isLoading = false
    @State private var showingUninstallConfirmation = false
    @State private var detailedPackage: BrewPackage?
    @State private var isLoadingDetails = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 包标题和图标
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(currentPackage.name)
                            .font(.largeTitle)
                            .bold()
                        
                        Text(currentPackage.type)
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isLoadingDetails {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: currentPackage.type == "公式" ? "terminal.fill" : "app.square.fill")
                            .font(.system(size: 48))
                            .foregroundColor(currentPackage.type == "公式" ? .blue : .orange)
                    }
                }
                
                Divider()
                
                // 包信息
                if isLoadingDetails {
                    VStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { _ in
                            VStack(alignment: .leading, spacing: 8) {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 16)
                                    .cornerRadius(4)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 20)
                                    .cornerRadius(4)
                            }
                        }
                    }
                } else {
                    Group {
                        PackageInfoSection(title: "描述", content: currentPackage.description)
                        
                        PackageInfoSection(title: "版本", content: currentPackage.version)
                        
                        if !currentPackage.dependencies.isEmpty {
                            PackageInfoSection(title: "依赖", content: currentPackage.dependencies.joined(separator: ", "))
                        }
                        
                        PackageInfoSection(title: "安装路径", content: currentPackage.installPath)
                        
                        if let homepage = currentPackage.homepage, !homepage.isEmpty {
                            Button(action: {
                                if let url = URL(string: homepage) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Label("访问主页", systemImage: "safari")
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
                
                Spacer()
                
                // 操作按钮
                if !isLoadingDetails {
                    HStack(spacing: 16) {
                        if currentPackage.hasUpdate {
                            Button(action: {
                                isLoading = true
                                brewViewModel.updatePackage(currentPackage) { success in
                                    isLoading = false
                                    if success {
                                        loadPackageDetails()
                                    }
                                }
                            }) {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 16, height: 16)
                                } else {
                                    Label("更新", systemImage: "arrow.up.circle")
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(isLoading)
                        }
                        
                        Button(action: {
                            showingUninstallConfirmation = true
                        }) {
                            Label("卸载", systemImage: "trash")
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .disabled(isLoading)
                        
                        if currentPackage.type == "公式" && currentPackage.hasService {
                            if currentPackage.serviceRunning {
                                Button(action: {
                                    isLoading = true
                                    brewViewModel.stopService(currentPackage.name) { success in
                                        isLoading = false
                                        if success {
                                            loadPackageDetails()
                                        }
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
                                .disabled(isLoading)
                            } else {
                                Button(action: {
                                    isLoading = true
                                    brewViewModel.startService(currentPackage.name) { success in
                                        isLoading = false
                                        if success {
                                            loadPackageDetails()
                                        }
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
                                .buttonStyle(.bordered)
                                .disabled(isLoading)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .alert("确认卸载", isPresented: $showingUninstallConfirmation) {
            Button("取消", role: .cancel) { }
            Button("卸载", role: .destructive) {
                isLoading = true
                brewViewModel.uninstallPackage(currentPackage) { success in
                    isLoading = false
                }
            }
        } message: {
            Text("确定要卸载 \(currentPackage.name) 吗？此操作不可撤销。")
        }
        .onAppear {
            loadPackageDetails()
        }
    }
    
    // 计算属性：当前显示的包信息
    private var currentPackage: BrewPackage {
        return detailedPackage ?? package
    }
    
    // 加载包详细信息
    private func loadPackageDetails() {
        isLoadingDetails = true
        brewViewModel.getPackageInfo(package.name) { detailedInfo in
            if let detailedInfo = detailedInfo {
                self.detailedPackage = detailedInfo
            }
            self.isLoadingDetails = false
        }
    }
}

// 信息部分组件
struct PackageInfoSection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.body)
                .textSelection(.enabled)
        }
    }
}

struct PackageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let mockPackage = BrewPackage(
            id: "1",
            name: "nginx",
            type: "公式",
            version: "1.21.6",
            description: "HTTP(S) 服务器，反向代理，IMAP/POP3 代理服务器",
            installPath: "/usr/local/Cellar/nginx/1.21.6",
            dependencies: ["openssl", "pcre"],
            homepage: "https://nginx.org/",
            hasUpdate: true,
            availableVersion: "1.22.0",
            hasService: true,
            serviceRunning: true
        )
        
        PackageDetailView(package: mockPackage)
            .environmentObject(BrewViewModel())
            .frame(width: 500, height: 600)
    }
}