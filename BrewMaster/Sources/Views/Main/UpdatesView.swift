import SwiftUI

struct UpdatesView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @State private var isCheckingUpdates = false
    @State private var isUpdating = false
    @State private var selectedPackages: Set<String> = []
    @State private var showingUpdateOptions = false
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部操作栏
            HStack {
                Button(action: {
                    checkForUpdates()
                }) {
                    Label("检查更新", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                .disabled(isCheckingUpdates || isUpdating)
                
                Spacer()
                
                if !brewViewModel.updatablePackages.isEmpty {
                    Button(action: {
                        if selectedPackages.isEmpty {
                            // 如果没有选择包，则更新所有
                            updateAllPackages()
                        } else {
                            // 如果选择了包，则更新选中的包
                            updateSelectedPackages()
                        }
                    }) {
                        if isUpdating {
                            ProgressView()
                                .scaleEffect(0.7)
                                .frame(width: 16, height: 16)
                        } else {
                            Label(selectedPackages.isEmpty ? "更新全部" : "更新选中项", 
                                  systemImage: "arrow.down.circle")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCheckingUpdates || isUpdating)
                }
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // 更新内容
            if isCheckingUpdates {
                VStack {
                    ProgressView("正在检查更新...")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if brewViewModel.updatablePackages.isEmpty {
                VStack {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 48))
                        .foregroundColor(.green)
                        .padding()
                    
                    Text("所有包都是最新的")
                        .font(.title3)
                    
                    Text("最后检查时间: \(brewViewModel.lastUpdateCheckTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    // 更新摘要
                    HStack {
                        Text("发现 \(brewViewModel.updatablePackages.count) 个可更新项")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("最后检查时间: \(brewViewModel.lastUpdateCheckTime)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Divider()
                    
                    // 可更新包列表
                    List {
                        Section(header: 
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { selectedPackages.count == brewViewModel.updatablePackages.count },
                                    set: { newValue in
                                        if newValue {
                                            selectedPackages = Set(brewViewModel.updatablePackages.map { $0.id })
                                        } else {
                                            selectedPackages = []
                                        }
                                    }
                                )) {
                                    Text("全选")
                                }
                                .toggleStyle(.checkbox)
                                
                                Spacer()
                            }
                        ) {
                            ForEach(brewViewModel.updatablePackages) { package in
                                UpdateRow(package: package, isSelected: selectedPackages.contains(package.id)) { isSelected in
                                    if isSelected {
                                        selectedPackages.insert(package.id)
                                    } else {
                                        selectedPackages.remove(package.id)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("更新管理")
        .onAppear {
            if brewViewModel.updatablePackages.isEmpty && brewViewModel.lastUpdateCheckTime.isEmpty {
                checkForUpdates()
            }
        }
    }
    
    private func checkForUpdates() {
        isCheckingUpdates = true
        brewViewModel.checkUpdates { success in
            isCheckingUpdates = false
        }
    }
    
    private func updateAllPackages() {
        isUpdating = true
        brewViewModel.updateAllPackages { success in
            isUpdating = false
            if success {
                // 更新成功后重新检查更新
                checkForUpdates()
            }
        }
    }
    
    private func updateSelectedPackages() {
        isUpdating = true
        let packagesToUpdate = brewViewModel.updatablePackages.filter { selectedPackages.contains($0.id) }
        brewViewModel.updatePackages(packagesToUpdate) { success in
            isUpdating = false
            if success {
                // 更新成功后重新检查更新
                checkForUpdates()
                selectedPackages = []
            }
        }
    }
}

// 更新行组件
struct UpdateRow: View {
    let package: BrewPackage
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Toggle(isOn: Binding(
                get: { isSelected },
                set: { onToggle($0) }
            )) {
                EmptyView()
            }
            .toggleStyle(.checkbox)
            
            Image(systemName: package.type == "公式" ? "terminal" : "app.square")
                .foregroundColor(package.type == "公式" ? .blue : .orange)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(package.name)
                    .font(.headline)
                
                HStack {
                    Text(package.version)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(package.availableVersion ?? "")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            
            Spacer()
            
            Text(package.type)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(8)
        }
        .padding(.vertical, 4)
    }
}

struct UpdatesView_Previews: PreviewProvider {
    static var previews: some View {
        UpdatesView()
            .environmentObject(BrewViewModel())
    }
}