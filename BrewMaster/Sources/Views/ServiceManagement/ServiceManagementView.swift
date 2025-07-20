import SwiftUI

struct ServiceManagementView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var searchText: String = ""
    @State private var selectedService: BrewServiceModel? = nil
    @State private var selectedServices: Set<BrewServiceModel.ID> = []
    @State private var isLoading = false
    @State private var isMultiSelectMode = false
    
    var filteredServices: [BrewServiceModel] {
        if searchText.isEmpty {
            return brewViewModel.services
        } else {
            return brewViewModel.services.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.status.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索服务...", text: $searchText)
                    .textFieldStyle(.plain)
                
                Spacer()
                
                // 多选模式切换
                Button(action: {
                    isMultiSelectMode.toggle()
                    if !isMultiSelectMode {
                        selectedServices.removeAll()
                    }
                }) {
                    Label(isMultiSelectMode ? "退出多选" : "多选", 
                          systemImage: isMultiSelectMode ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .buttonStyle(.bordered)
                
                // 批量操作菜单
                if isMultiSelectMode && !selectedServices.isEmpty {
                    Menu {
                        Button("启动选中服务") {
                            startSelectedServices()
                        }
                        
                        Button("停止选中服务") {
                            stopSelectedServices()
                        }
                    } label: {
                        Label("批量操作", systemImage: "ellipsis.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: {
                    brewViewModel.fetchServices()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // 服务列表和详情
            HSplitView {
                // 服务列表
                VStack(spacing: 0) {
                    if isMultiSelectMode {
                        // 多选列表
                        List(filteredServices, id: \.id) { service in
                            ServiceRowWithCheckbox(
                                service: service,
                                isSelected: selectedServices.contains(service.id)
                            ) {
                                if selectedServices.contains(service.id) {
                                    selectedServices.remove(service.id)
                                } else {
                                    selectedServices.insert(service.id)
                                }
                            }
                        }
                        .listStyle(.inset)
                    } else {
                        // 单选列表
                        List(filteredServices, selection: $selectedService) { service in
                            ServiceRow(service: service)
                                .tag(service)
                        }
                        .listStyle(.inset)
                        .onChange(of: selectedService) { newValue in
                            print("Service selection changed to: \(String(describing: newValue?.name))")
                        }
                    }
                    
                    // 多选状态栏（移动到列表底部）
                    if isMultiSelectMode && !selectedServices.isEmpty {
                        HStack {
                            Text("已选择 \(selectedServices.count) 个服务")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("全选") {
                                selectedServices = Set(filteredServices.map { $0.id })
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            
                            Button("清空") {
                                selectedServices.removeAll()
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.controlBackgroundColor))
                    }
                    
                    // 状态统计
                    HStack {
                        StatusBadge(
                            count: brewViewModel.runningServices.count,
                            label: "运行中",
                            color: themeManager.serviceRunningColor
                        )
                        
                        StatusBadge(
                            count: brewViewModel.stoppedServices.count,
                            label: "已停止",
                            color: .secondary
                        )
                        
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(.controlBackgroundColor))
                }
                .frame(minWidth: 230)
                
                // 服务详情
                if let selectedService = selectedService {
                    ServiceDetailView(service: selectedService)
                        .environmentObject(brewViewModel)
                        .frame(minWidth: 350)
                } else {
                    VStack {
                        Image(systemName: "server.rack")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("选择一个服务查看详情")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 350, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("服务管理")
        .onAppear {
            brewViewModel.fetchServices()
        }
    }
    
    // MARK: - 批量操作方法
    private func startSelectedServices() {
        let servicesToStart = filteredServices.filter { selectedServices.contains($0.id) }
        for service in servicesToStart {
            brewViewModel.startService(service.name)
        }
        selectedServices.removeAll()
    }
    
    private func stopSelectedServices() {
        let servicesToStop = filteredServices.filter { selectedServices.contains($0.id) }
        for service in servicesToStop {
            brewViewModel.stopService(service.name)
        }
        selectedServices.removeAll()
    }
}

// 带复选框的服务行组件（多选模式）
struct ServiceRowWithCheckbox: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let service: BrewServiceModel
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 复选框
            Button(action: onToggle) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .font(.system(size: 16))
            }
            .buttonStyle(.plain)
            
            // 状态指示器
            Circle()
                .fill(service.isRunning ? themeManager.serviceRunningColor : themeManager.serviceStoppedColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(service.name)
                        .font(.headline)
                    
                    if let version = service.version {
                        Text("v\(version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                
                Text(service.status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 启动/停止状态图标
            if service.isRunning {
                Image(systemName: "play.fill")
                    .foregroundColor(themeManager.serviceRunningColor)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "stop.fill")
                    .foregroundColor(themeManager.serviceStoppedColor)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

// 服务行组件
struct ServiceRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let service: BrewServiceModel
    
    var body: some View {
        HStack(spacing: 12) {
            // 状态指示器
            Circle()
                .fill(service.isRunning ? themeManager.serviceRunningColor : themeManager.serviceStoppedColor)
                .frame(width: 10, height: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(service.name)
                        .font(.headline)
                    
                    if let version = service.version {
                        Text("v\(version)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(.controlBackgroundColor))
                            .cornerRadius(4)
                    }
                }
                
                Text(service.status)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // 启动/停止按钮
            if service.isRunning {
                Image(systemName: "play.fill")
                    .foregroundColor(themeManager.serviceRunningColor)
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "stop.fill")
                    .foregroundColor(themeManager.serviceStoppedColor)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.vertical, 4)
    }
}

// 状态徽章组件
struct StatusBadge: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(count)")
                .font(.caption.bold())
            
            Text(label)
                .font(.caption)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundColor(color)
        .cornerRadius(12)
    }
}

struct ServiceManagementView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceManagementView()
            .environmentObject(BrewViewModel())
    }
}