import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    // 外观设置
    @AppStorage("colorScheme") private var colorScheme = "auto"
    @AppStorage("accentColor") private var accentColor = "blue"
    @AppStorage("showSidebar") private var showSidebar = true
    @AppStorage("compactMode") private var compactMode = false
    
    // 更新设置
    @AppStorage("autoCheckUpdates") private var autoCheckUpdates = true
    @AppStorage("notifyAvailableUpdates") private var notifyAvailableUpdates = true
    @AppStorage("updateCheckInterval") private var updateCheckInterval = 24.0
    @AppStorage("autoInstallUpdates") private var autoInstallUpdates = false
    
    // 终端设置
    @AppStorage("terminalFontSize") private var terminalFontSize = 12.0
    @AppStorage("terminalFontFamily") private var terminalFontFamily = "SF Mono"
    @AppStorage("terminalTheme") private var terminalTheme = "dark"
    @AppStorage("showLineNumbers") private var showLineNumbers = true
    @AppStorage("terminalWordWrap") private var terminalWordWrap = true
    @AppStorage("showCursor") private var showCursor = true
    
    // Homebrew 配置
    @AppStorage("brewPrefix") private var brewPrefix = "/usr/local"
    @AppStorage("brewCacheSize") private var brewCacheSize = "未知"
    @AppStorage("enableAnalytics") private var enableAnalytics = false
    @AppStorage("parallelJobs") private var parallelJobs = 4
    
    // 活动历史
    @AppStorage("maxActivitiesToShow") private var maxActivitiesToShow = 10
    @AppStorage("autoSaveHistory") private var autoSaveHistory = true
    @AppStorage("historyRetentionDays") private var historyRetentionDays = 30
    
    // 通知设置
    @AppStorage("enableNotifications") private var enableNotifications = true
    @AppStorage("notificationSound") private var notificationSound = true
    @AppStorage("showBadgeCount") private var showBadgeCount = true
    
    // 性能设置
    @AppStorage("enableCaching") private var enableCaching = true
    @AppStorage("maxCacheSize") private var maxCacheSize = 500.0
    @AppStorage("backgroundRefresh") private var backgroundRefresh = true
    
    @State private var selectedTab = 0
    @State private var showingResetAlert = false
    @State private var showingClearCacheAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 常规设置
            generalSettingsView
                .tabItem {
                    Label("常规", systemImage: "gear")
                }
                .tag(0)
            
            // 终端设置
            terminalSettingsView
                .tabItem {
                    Label("终端", systemImage: "terminal")
                }
                .tag(1)
            
            // 关于
            aboutView
                .tabItem {
                    Label("关于", systemImage: "info.circle")
                }
                .tag(2)
        }
        .padding(20)
        .frame(width: 580, height: 450)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("重置设置") {
                    showingResetAlert = true
                }
                .foregroundColor(.red)
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") {
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
     }
        .alert("重置所有设置", isPresented: $showingResetAlert) {
            Button("取消", role: .cancel) { }
            Button("重置", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("这将重置所有设置为默认值，此操作无法撤销。")
        }
        .alert("清除缓存", isPresented: $showingClearCacheAlert) {
            Button("取消", role: .cancel) { }
            Button("清除", role: .destructive) {
                clearCache()
            }
        } message: {
            Text("这将清除所有缓存数据，可能会影响应用性能。")
        }
        .onAppear {
            applyColorScheme(colorScheme)
            updateBrewCacheSize()
        }
    }
    
    // MARK: - 计算属性
    private var fontFamily: Font.Design {
        switch terminalFontFamily {
        case "SF Mono", "Monaco", "Menlo":
            return .monospaced
        default:
            return .monospaced
        }
    }
    
    private var terminalBackgroundColor: Color {
        switch terminalTheme {
        case "light":
            return Color(NSColor.textBackgroundColor)
        case "dark":
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case "classic":
            return Color(red: 0.0, green: 0.2, blue: 0.0)
        case "blue":
            return Color(red: 0.0, green: 0.1, blue: 0.3)
        default:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    private var terminalTextColor: Color {
        switch terminalTheme {
        case "light":
            return Color(NSColor.textColor)
        case "dark":
            return Color.white
        case "classic":
            return Color.green
        case "blue":
            return Color(red: 0.6, green: 0.8, blue: 1.0)
        default:
            return Color.white
        }
    }
    
    private var terminalThemeDisplayName: String {
        switch terminalTheme {
        case "light":
            return "浅色"
        case "dark":
            return "深色"
        case "classic":
            return "经典绿色"
        case "blue":
            return "蓝色"
        default:
            return "深色"
        }
    }
    
    // MARK: - 常规设置
    private var generalSettingsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 外观设置
                SettingsGroup(title: "外观", icon: "paintbrush") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "主题模式") {
                            Picker("主题模式", selection: $colorScheme) {
                                Label("自动", systemImage: "gearshape").tag("auto")
                                Label("浅色", systemImage: "sun.max").tag("light")
                                Label("深色", systemImage: "moon").tag("dark")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 240)
                            .onChange(of: colorScheme) { newValue in
                                applyColorScheme(newValue)
                            }
                        }
                        
                        SettingsRow(title: "强调色") {
                            Picker("强调色", selection: $accentColor) {
                                Label("蓝色", systemImage: "circle.fill").foregroundColor(.blue).tag("blue")
                                Label("绿色", systemImage: "circle.fill").foregroundColor(.green).tag("green")
                                Label("橙色", systemImage: "circle.fill").foregroundColor(.orange).tag("orange")
                                Label("紫色", systemImage: "circle.fill").foregroundColor(.purple).tag("purple")
                            }
                            .pickerStyle(.menu)
                            .frame(width: 100)
                        }
                        
                        SettingsRow(title: "界面选项") {
                            VStack(alignment: .trailing, spacing: 12) {
                                Toggle("显示侧边栏", isOn: $showSidebar)
                                    .toggleStyle(.checkbox)
                                    .controlSize(.regular)
                                    .font(.system(size: 14))
                                Toggle("紧凑模式", isOn: $compactMode)
                                    .toggleStyle(.checkbox)
                                    .controlSize(.regular)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
                
                // 更新设置
                SettingsGroup(title: "更新", icon: "arrow.clockwise") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "自动检查更新") {
                            Toggle("", isOn: $autoCheckUpdates)
                                .labelsHidden()
                        }
                        
                        SettingsRow(title: "检查间隔") {
                            Picker("检查间隔", selection: $updateCheckInterval) {
                                Text("每小时").tag(1.0)
                                Text("每天").tag(24.0)
                                Text("每周").tag(168.0)
                            }
                            .pickerStyle(.menu)
                            .frame(width: 100)
                            .disabled(!autoCheckUpdates)
                        }
                        
                        SettingsRow(title: "通知设置") {
                            VStack(alignment: .trailing, spacing: 8) {
                                Toggle("更新通知", isOn: $notifyAvailableUpdates)
                                    .disabled(!autoCheckUpdates)
                                Toggle("自动安装", isOn: $autoInstallUpdates)
                                    .disabled(!autoCheckUpdates)
                            }
                        }
                    }
                }
                
                // Homebrew 配置
                SettingsGroup(title: "Homebrew", icon: "gear.badge") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "安装前缀") {
                            TextField("路径", text: $brewPrefix)
                                .frame(width: 200)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        SettingsRow(title: "并行任务") {
                            Stepper("\(parallelJobs) 个", value: $parallelJobs, in: 1...8)
                                .frame(width: 120)
                                .controlSize(.regular)
                        }
                        
                        SettingsRow(title: "缓存大小") {
                            HStack(spacing: 8) {
                                Text(brewCacheSize)
                                    .foregroundColor(.secondary)
                                    .frame(width: 80, alignment: .trailing)
                                Button("清理") {
                                    showingClearCacheAlert = true
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.regular)
                            }
                        }
                    }
                }
                
                // 活动历史
                SettingsGroup(title: "活动历史", icon: "clock") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "显示数量") {
                            Stepper("\(maxActivitiesToShow) 条", value: $maxActivitiesToShow, in: 5...50, step: 5)
                                .frame(width: 120)
                        }
                        
                        SettingsRow(title: "保留天数") {
                            Stepper("\(historyRetentionDays) 天", value: $historyRetentionDays, in: 7...365, step: 7)
                                .frame(width: 120)
                        }
                        
                        SettingsRow(title: "自动保存") {
                            Toggle("", isOn: $autoSaveHistory)
                                .labelsHidden()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - 更新设置
    private var updateSettingsView: some View {
        Form {
            Section(header: Text("自动更新")) {
                Toggle("自动检查更新", isOn: $autoCheckUpdates)
                
                HStack {
                    Text("检查间隔")
                    Spacer()
                    Picker("检查间隔", selection: $updateCheckInterval) {
                        Text("每小时").tag(1.0)
                        Text("每6小时").tag(6.0)
                        Text("每12小时").tag(12.0)
                        Text("每天").tag(24.0)
                        Text("每周").tag(168.0)
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100)
                    .disabled(!autoCheckUpdates)
                }
                
                Toggle("有可用更新时通知", isOn: $notifyAvailableUpdates)
                    .disabled(!autoCheckUpdates)
                
                Toggle("自动安装更新", isOn: $autoInstallUpdates)
                    .disabled(!autoCheckUpdates)
            }
            
            Section(header: Text("更新历史")) {
                HStack {
                    Text("保留历史记录")
                    Spacer()
                    Stepper("\(historyRetentionDays) 天", value: $historyRetentionDays, in: 7...365, step: 7)
                        .frame(width: 120)
                }
                
                Toggle("自动保存活动历史", isOn: $autoSaveHistory)
                
                HStack {
                    Text("显示活动数量")
                    Spacer()
                    Stepper("\(maxActivitiesToShow) 条", value: $maxActivitiesToShow, in: 5...100, step: 5)
                        .frame(width: 120)
                }
            }
        }
        }
    
    // MARK: - 终端设置
    private var terminalSettingsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 字体设置
                SettingsGroup(title: "字体设置", icon: "textformat") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "字体系列") {
                            Picker("字体系列", selection: $terminalFontFamily) {
                                Text("SF Mono").tag("SF Mono")
                                Text("Monaco").tag("Monaco")
                                Text("Menlo").tag("Menlo")
                                Text("Courier New").tag("Courier New")
                                Text("Source Code Pro").tag("Source Code Pro")
                            }
                            .pickerStyle(.menu)
                            .frame(width: 140)
                        }
                        
                        SettingsRow(title: "字体大小") {
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("\(Int(terminalFontSize))pt")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Slider(value: $terminalFontSize, in: 10...24, step: 1)
                                    .frame(width: 180)
                            }
                        }
                    }
                }
                
                // 外观设置
                SettingsGroup(title: "外观设置", icon: "paintpalette") {
                    VStack(spacing: 16) {
                        SettingsRow(title: "终端主题") {
                            Picker("终端主题", selection: $terminalTheme) {
                                Text("深色").tag("dark")
                                Text("浅色").tag("light")
                                Text("经典绿色").tag("classic")
                                Text("蓝色").tag("blue")
                            }
                            .pickerStyle(.segmented)
                            .frame(width: 280)
                        }
                        
                        SettingsRow(title: "显示选项") {
                            VStack(alignment: .trailing, spacing: 12) {
                                Toggle("显示行号", isOn: $showLineNumbers)
                                    .toggleStyle(.checkbox)
                                    .controlSize(.regular)
                                    .font(.system(size: 14))
                                Toggle("自动换行", isOn: $terminalWordWrap)
                                    .toggleStyle(.checkbox)
                                    .controlSize(.regular)
                                    .font(.system(size: 14))
                                Toggle("显示光标", isOn: $showCursor)
                                    .toggleStyle(.checkbox)
                                    .controlSize(.regular)
                                    .font(.system(size: 14))
                            }
                        }
                    }
                }
                
                // 终端预览
                SettingsGroup(title: "预览", icon: "terminal") {
                    VStack(alignment: .leading, spacing: 12) {
                        // 终端窗口预览
                        VStack(spacing: 0) {
                            // 标题栏
                            HStack {
                                HStack(spacing: 6) {
                                    Circle().fill(Color.red).frame(width: 12, height: 12)
                                    Circle().fill(Color.yellow).frame(width: 12, height: 12)
                                    Circle().fill(Color.green).frame(width: 12, height: 12)
                                }
                                Spacer()
                                Text("终端")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.windowBackgroundColor))
                            
                            // 终端内容
                            VStack(alignment: .leading, spacing: 4) {
                                if showLineNumbers {
                                    HStack(alignment: .top, spacing: 8) {
                                        Text("1")
                                            .font(.system(size: terminalFontSize - 2, design: .monospaced))
                                            .foregroundColor(.secondary)
                                            .frame(width: 20, alignment: .trailing)
                                        Text("$ brew install package-name")
                                            .font(.system(size: terminalFontSize, design: .monospaced))
                                            .foregroundColor(terminalTextColor)
                                    }
                                } else {
                                    Text("$ brew install package-name")
                                        .font(.system(size: terminalFontSize, design: .monospaced))
                                        .foregroundColor(terminalTextColor)
                                }
                                
                                Text("==> Downloading package-name...")
                                    .font(.system(size: terminalFontSize, design: .monospaced))
                                    .foregroundColor(.green)
                                
                                Text("🍺  package-name was successfully installed!")
                                    .font(.system(size: terminalFontSize, design: .monospaced))
                                    .foregroundColor(terminalTextColor)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(terminalBackgroundColor)
                        }
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        
                        // 设置信息
                        HStack {
                            Text("字体: \(terminalFontFamily)")
                            Spacer()
                            Text("大小: \(Int(terminalFontSize))pt")
                            Spacer()
                            Text("主题: \(terminalThemeDisplayName)")
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
    }
    
    // MARK: - Homebrew 配置
    private var brewSettingsView: some View {
        Form {
            Section(header: Text("安装配置")) {
                HStack {
                    Text("安装前缀")
                    Spacer()
                    TextField("安装路径", text: $brewPrefix)
                        .frame(width: 280)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.regular)
                }
                
                HStack {
                    Text("并行任务数")
                    Spacer()
                    Stepper("\(parallelJobs) 个", value: $parallelJobs, in: 1...16)
                        .frame(width: 140)
                        .controlSize(.regular)
                }
                
                Toggle("启用分析数据收集", isOn: $enableAnalytics)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
            }
            
            Section(header: Text("缓存管理")) {
                HStack {
                    Text("缓存大小")
                    Spacer()
                    Text(brewCacheSize)
                        .foregroundColor(.secondary)
                    Button("刷新") {
                        updateBrewCacheSize()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                }
                
                HStack {
                    Spacer()
                    Button("清除 Homebrew 缓存") {
                        showingClearCacheAlert = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            
            Section(header: Text("路径信息")) {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(title: "Homebrew 路径", value: brewPrefix)
                    InfoRow(title: "配置文件", value: "~/.brewmaster")
                    InfoRow(title: "日志文件", value: "~/Library/Logs/BrewMaster")
                }
            }
        }
    }
    
    // MARK: - 通知设置
    private var notificationSettingsView: some View {
        Form {
            Section(header: Text("通知偏好")) {
                Toggle("启用通知", isOn: $enableNotifications)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
                Toggle("通知声音", isOn: $notificationSound)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
                    .disabled(!enableNotifications)
                Toggle("显示角标计数", isOn: $showBadgeCount)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
                    .disabled(!enableNotifications)
            }
            
            Section(header: Text("通知类型")) {
                VStack(alignment: .leading, spacing: 8) {
                    NotificationTypeRow(title: "安装完成", enabled: $notifyAvailableUpdates)
                    NotificationTypeRow(title: "更新可用", enabled: $notifyAvailableUpdates)
                    NotificationTypeRow(title: "错误警告", enabled: $enableNotifications)
                    NotificationTypeRow(title: "后台任务", enabled: $backgroundRefresh)
                }
                .disabled(!enableNotifications)
            }
        }
    }
    
    // MARK: - 性能设置
    private var performanceSettingsView: some View {
        Form {
            Section(header: Text("缓存设置")) {
                Toggle("启用缓存", isOn: $enableCaching)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
                
                HStack {
                    Text("最大缓存大小")
                    Spacer()
                    Slider(value: $maxCacheSize, in: 100...2000, step: 100) {
                        Text("\(Int(maxCacheSize)) MB")
                    } minimumValueLabel: {
                        Text("100MB")
                    } maximumValueLabel: {
                        Text("2GB")
                    }
                    .frame(width: 200)
                    .disabled(!enableCaching)
                }
            }
            
            Section(header: Text("后台任务")) {
                Toggle("后台刷新", isOn: $backgroundRefresh)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .font(.system(size: 14))
                
                Text("启用后台刷新将定期更新包信息，但可能会增加系统资源使用。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Section(header: Text("系统信息")) {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRow(title: "内存使用", value: "约 45 MB")
                    InfoRow(title: "CPU 使用", value: "< 1%")
                    InfoRow(title: "磁盘使用", value: "约 2.3 MB")
                }
            }
        }
    }
    
    // MARK: - 关于页面
    private var aboutView: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                // 使用Bundle资源加载SVG图标
                if let url = Bundle.main.url(forResource: "brewmaster_logo", withExtension: "svg"),
                   let svgData = try? Data(contentsOf: url),
                   let nsImage = NSImage(data: svgData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128, height: 128)
                        .shadow(radius: 4)
                } else {
                    // 备用图标
                    Image(systemName: "cube.box.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                        .frame(width: 128, height: 128)
                        .shadow(radius: 4)
                }
                
                VStack(spacing: 8) {
                    Text("BrewMaster")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("版本 1.0.0 (Build 2025.7)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack(spacing: 16) {
                Text("BrewMaster 是一个为 macOS 设计的现代化 Homebrew 图形界面管理工具。使用 SwiftUI 构建，提供直观、美观的用户界面，让您轻松管理 Homebrew 包和服务。")
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .padding(.horizontal)
                
                HStack(spacing: 16) {
                    Button("访问项目主页") {
                        if let url = URL(string: "https://github.com/yourusername/brewmaster") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("查看更新日志") {
                        if let url = URL(string: "https://github.com/yourusername/brewmaster/releases") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    
                    Button("反馈问题") {
                        if let url = URL(string: "https://github.com/yourusername/brewmaster/issues") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            VStack(spacing: 8) {
                Text("© 2024 BrewMaster. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Built with ❤️ using SwiftUI by xiaoyuan")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    // MARK: - 功能实现方法
    private func updateBrewCacheSize() {
        // 获取 Homebrew 缓存大小
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "du -sh $(brew --cache) 2>/dev/null | cut -f1 || echo '未知'"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) {
            DispatchQueue.main.async {
                self.brewCacheSize = output.isEmpty ? "未知" : output
            }
        }
    }
    
    private func clearCache() {
        // 清除 Homebrew 缓存
        let task = Process()
        task.launchPath = "/usr/local/bin/brew"
        task.arguments = ["cleanup", "--prune=all"]
        task.launch()
        task.waitUntilExit()
        
        // 更新缓存大小显示
        updateBrewCacheSize()
    }
    
    private func resetAllSettings() {
        // 重置所有设置为默认值
        colorScheme = "auto"
        accentColor = "blue"
        showSidebar = true
        compactMode = false
        autoCheckUpdates = true
        notifyAvailableUpdates = true
        updateCheckInterval = 24.0
        autoInstallUpdates = false
        terminalFontSize = 12.0
        terminalFontFamily = "SF Mono"
        terminalTheme = "dark"
        showLineNumbers = true
        terminalWordWrap = true
        showCursor = true
        brewPrefix = "/usr/local"
        enableAnalytics = false
        parallelJobs = 4
        maxActivitiesToShow = 10
        autoSaveHistory = true
        historyRetentionDays = 30
        enableNotifications = true
        notificationSound = true
        showBadgeCount = true
        enableCaching = true
        maxCacheSize = 500.0
        backgroundRefresh = true
    }
    
    private func applyColorScheme(_ scheme: String) {
        switch scheme {
        case "light":
            NSApp.appearance = NSAppearance(named: .aqua)
        case "dark":
            NSApp.appearance = NSAppearance(named: .darkAqua)
        default:
            NSApp.appearance = nil
        }
    }
    
    // MARK: - 辅助视图组件
    private struct InfoRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 2)
        }
    }
    
    private struct NotificationTypeRow: View {
        let title: String
        @Binding var enabled: Bool
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.system(size: 14))
                Spacer()
                Toggle("", isOn: $enabled)
                    .toggleStyle(.checkbox)
                    .controlSize(.regular)
                    .labelsHidden()
            }
            .padding(.vertical, 4)
        }
    }
    

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

// MARK: - 自定义设置组件
struct SettingsGroup<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .font(.system(size: 16, weight: .medium))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.bottom, 4)
            
            VStack(spacing: 0) {
                content
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(NSColor.separatorColor), lineWidth: 0.5)
            )
        }
    }
}

struct SettingsRow<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.primary)
                .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            content
        }
        .padding(.vertical, 4)
    }
}