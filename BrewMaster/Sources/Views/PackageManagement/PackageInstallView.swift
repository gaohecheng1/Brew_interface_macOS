import SwiftUI

struct PackageInstallView: View {
    @EnvironmentObject private var brewViewModel: BrewViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [BrewSearchResult] = []
    @State private var selectedPackageType: PackageType = .all
    @State private var selectedPackage: BrewSearchResult? = nil
    @State private var isInstalling = false
    
    enum PackageType: String, CaseIterable, Identifiable {
        case all = "全部"
        case formula = "公式"
        case cask = "桶装"
        
        var id: String { self.rawValue }
    }
    
    var filteredResults: [BrewSearchResult] {
        if selectedPackageType == .all {
            return searchResults
        } else {
            return searchResults.filter { $0.type == selectedPackageType.rawValue }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 标题栏
            HStack {
                Text("安装新包")
                    .font(.title2)
                    .bold()
                
                Spacer()
                
                Button("关闭") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            .padding()
            
            Divider()
            
            // 搜索栏
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("搜索包名...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        if !searchText.isEmpty {
                            performSearch()
                        }
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button("搜索") {
                    if !searchText.isEmpty {
                        performSearch()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(searchText.isEmpty || isSearching)
            }
            .padding()
            
            // 类型筛选
            Picker("包类型", selection: $selectedPackageType) {
                ForEach(PackageType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom)
            
            Divider()
            
            // 搜索结果
            if isSearching {
                VStack {
                    ProgressView("搜索中...")
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty && !searchText.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("未找到匹配的包")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if searchResults.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Text("输入包名开始搜索")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    Text("例如：nginx, firefox, mysql")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredResults, selection: $selectedPackage) { result in
                    SearchResultRow(result: result) {
                        installPackage(result)
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
    
    private func performSearch() {
        isSearching = true
        searchResults = []
        
        brewViewModel.searchPackage(searchText) { results in
            searchResults = results
            isSearching = false
        }
    }
    
    private func installPackage(_ package: BrewSearchResult) {
        isInstalling = true
        
        brewViewModel.installPackage(package) { success in
            isInstalling = false
            if success {
                dismiss()
            }
        }
    }
}

// 搜索结果行组件
struct SearchResultRow: View {
    let result: BrewSearchResult
    let installAction: () -> Void
    @State private var isInstalling = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: result.type == "公式" ? "terminal" : "app.square")
                .foregroundColor(result.type == "公式" ? .blue : .orange)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(result.name)
                    .font(.headline)
                
                if !result.description.isEmpty {
                    Text(result.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Button(action: installAction) {
                if isInstalling {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                } else {
                    Text("安装")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isInstalling)
        }
        .padding(.vertical, 4)
    }
}

struct PackageInstallView_Previews: PreviewProvider {
    static var previews: some View {
        PackageInstallView()
            .environmentObject(BrewViewModel())
    }
}