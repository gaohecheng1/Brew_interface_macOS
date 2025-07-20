import SwiftUI

struct PackageManagementView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var searchText: String = ""
    @State private var selectedCategory: PackageCategory = .all
    @State private var selectedPackage: BrewPackage? = nil
    @State private var selectedPackages: Set<BrewPackage.ID> = []
    @State private var showingInstallSheet = false
    @State private var isMultiSelectMode = false
    
    enum PackageCategory: String, CaseIterable, Identifiable {
        case all = "全部"
        case formulae = "公式"
        case casks = "桶装"
        
        var id: String { self.rawValue }
    }
    
    var filteredPackages: [BrewPackage] {
        var filtered = brewViewModel.installedPackages
        
        // 按类别筛选
        if selectedCategory != .all {
            filtered = filtered.filter { $0.type == selectedCategory.rawValue }
        }
        
        // 按搜索文本筛选
        if !searchText.isEmpty {
            filtered = filtered.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    // MARK: - 批量操作方法
    private func updateSelectedPackages() {
        let packagesToUpdate = filteredPackages.filter { selectedPackages.contains($0.id) }
        for package in packagesToUpdate {
            brewViewModel.updatePackage(package)
        }
        selectedPackages.removeAll()
    }
    
    private func uninstallSelectedPackages() {
        let packagesToUninstall = filteredPackages.filter { selectedPackages.contains($0.id) }
        for package in packagesToUninstall {
            brewViewModel.uninstallPackage(package)
        }
        selectedPackages.removeAll()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索和筛选栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索包...", text: $searchText)
                    .textFieldStyle(.plain)
                
                Spacer()
                
                Picker("分类", selection: $selectedCategory) {
                    ForEach(PackageCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 120)
                
                // 多选模式切换
                Button(action: {
                    isMultiSelectMode.toggle()
                    if !isMultiSelectMode {
                        selectedPackages.removeAll()
                    }
                }) {
                    Label(isMultiSelectMode ? "退出多选" : "多选", 
                          systemImage: isMultiSelectMode ? "checkmark.circle.fill" : "checkmark.circle")
                }
                .buttonStyle(.bordered)
                
                // 批量操作菜单
                if isMultiSelectMode && !selectedPackages.isEmpty {
                    Menu {
                        Button("更新选中包") {
                            updateSelectedPackages()
                        }
                        
                        Button("卸载选中包") {
                            uninstallSelectedPackages()
                        }
                    } label: {
                        Label("批量操作", systemImage: "ellipsis.circle")
                    }
                    .buttonStyle(.bordered)
                }
                
                Button(action: {
                    brewViewModel.fetchPackages()
                }) {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
                .buttonStyle(.bordered)
                
                Button(action: {
                    showingInstallSheet = true
                }) {
                    Label("安装包", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(.controlBackgroundColor))
            
            Divider()
            
            // 包列表和详情
            HSplitView {
                // 包列表
                VStack(spacing: 0) {
                    if isMultiSelectMode {
                        // 多选列表
                        List(filteredPackages, id: \.id) { package in
                            PackageRowWithCheckbox(
                                package: package,
                                isSelected: selectedPackages.contains(package.id)
                            ) {
                                if selectedPackages.contains(package.id) {
                                    selectedPackages.remove(package.id)
                                } else {
                                    selectedPackages.insert(package.id)
                                }
                            }
                        }
                        .listStyle(.inset)
                    } else {
                        // 单选列表
                        List(filteredPackages, selection: $selectedPackage) { package in
                            PackageRow(package: package)
                                .tag(package)
                        }
                        .listStyle(.inset)
                        .onChange(of: selectedPackage) { newValue in
                            print("Package selection changed to: \(String(describing: newValue?.name))")
                        }
                    }
                    
                    // 多选状态栏（移动到列表底部）
                    if isMultiSelectMode && !selectedPackages.isEmpty {
                        HStack {
                            Text("已选择 \(selectedPackages.count) 个包")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("全选") {
                                selectedPackages = Set(filteredPackages.map { $0.id })
                            }
                            .buttonStyle(.borderless)
                            .font(.caption)
                            
                            Button("清空") {
                                selectedPackages.removeAll()
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
                            count: brewViewModel.installedPackages.count,
                            label: "已安装",
                            color: themeManager.successColor
                        )
                        
                        StatusBadge(
                            count: brewViewModel.updatablePackages.count,
                            label: "可更新",
                            color: themeManager.warningColor
                        )
                        
                        Spacer()
                    }
                    .padding(8)
                    .background(Color(.controlBackgroundColor))
                }
                .frame(minWidth: 230)
                
                // 包详情
                if let selectedPackage = selectedPackage {
                    PackageDetailView(package: selectedPackage)
                        .environmentObject(brewViewModel)
                        .frame(minWidth: 350)
                        .id(selectedPackage.id) // 强制刷新
                } else {
                    VStack {
                        Image(systemName: "cube.box")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                            .padding()
                        
                        Text("选择一个包查看详情")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .frame(minWidth: 350, maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .navigationTitle("包管理")
        .sheet(isPresented: $showingInstallSheet) {
            PackageInstallView()
                .environmentObject(brewViewModel)
        }
        .onAppear {
            brewViewModel.fetchPackages()
        }
    }
}

// 包行组件
struct PackageRow: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let package: BrewPackage
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: package.type == "公式" ? "terminal" : "app.square")
                .foregroundColor(package.type == "公式" ? themeManager.formulaColor : themeManager.caskColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(package.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(package.version)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if package.hasUpdate {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.orange)
                    if let availableVersion = package.availableVersion {
                        Text(availableVersion)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// 带复选框的包行组件
struct PackageRowWithCheckbox: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let package: BrewPackage
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
            
            Image(systemName: package.type == "公式" ? "terminal" : "app.square")
                .foregroundColor(package.type == "公式" ? themeManager.formulaColor : themeManager.caskColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(package.name)
                        .font(.headline)
                        .foregroundColor(isSelected ? .primary : .primary)
                    
                    Spacer()
                    
                    Text(package.version)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)
                }
                
                Text(package.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            if package.hasUpdate {
                VStack(spacing: 2) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.orange)
                    if let availableVersion = package.availableVersion {
                        Text(availableVersion)
                            .font(.caption2)
                            .foregroundColor(.orange)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
    }
}

struct PackageManagementView_Previews: PreviewProvider {
    static var previews: some View {
        PackageManagementView()
            .environmentObject(BrewViewModel())
    }
}