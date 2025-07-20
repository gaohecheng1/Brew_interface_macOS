import SwiftUI

@main
struct BrewMasterApp: App {
    @AppStorage("colorScheme") private var colorScheme = "auto"
    @AppStorage("accentColor") private var accentColor = "blue"
    
    init() {
        print("BrewMasterApp initialized")
        applyColorScheme()
        applyAccentColor()
        setApplicationIcon()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ThemeManager.shared)
                .frame(minWidth: 600, idealWidth: 900, minHeight: 800)
                .onAppear {
                    print("BrewMasterApp WindowGroup appeared")
                }
                .onChange(of: colorScheme) { newValue in
                    applyColorScheme()
                }
                .onChange(of: accentColor) { newValue in
                    applyAccentColor()
                }
        }
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
    }
    
    private func applyColorScheme() {
        DispatchQueue.main.async {
            let appearance: NSAppearance?
            
            switch colorScheme {
            case "light":
                appearance = NSAppearance(named: .aqua)
            case "dark":
                appearance = NSAppearance(named: .darkAqua)
            case "auto":
                appearance = nil // 跟随系统
            default:
                appearance = nil
            }
            
            // 应用到所有窗口
            NSApplication.shared.windows.forEach { window in
                window.appearance = appearance
            }
            
            // 设置应用级别的外观
            NSApp.appearance = appearance
        }
    }
    
    private func applyAccentColor() {
        DispatchQueue.main.async {
            let color: NSColor
            
            switch accentColor {
            case "blue":
                color = .systemBlue
            case "green":
                color = .systemGreen
            case "orange":
                color = .systemOrange
            case "purple":
                color = .systemPurple
            default:
                color = .systemBlue
            }
            
            // 设置应用级别的强调色
            NSApp.appearance?.performAsCurrentDrawingAppearance {
                _ = color // 使用color变量
            }
        }
    }
    
    private func setApplicationIcon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("开始设置应用图标...")
            
            // 尝试从Bundle中加载SVG图标
            guard let svgURL = Bundle.main.url(forResource: "brewmaster_logo", withExtension: "svg") else {
                print("错误: 无法找到brewmaster_logo.svg文件")
                print("Bundle.main路径: \(Bundle.main.bundlePath)")
                print("Bundle.main资源路径: \(Bundle.main.resourcePath ?? "无")")
                // 尝试直接从项目路径加载
                let projectPath = "/Users/gaoheyuan/Documents/Brew_interface_macOS/BrewMaster/Resources/brewmaster_logo.svg"
                if FileManager.default.fileExists(atPath: projectPath) {
                    print("从项目路径加载SVG: \(projectPath)")
                    let projectURL = URL(fileURLWithPath: projectPath)
                    self.loadSVGFromURL(projectURL)
                    return
                }
                self.setFallbackIcon()
                return
            }
            
            self.loadSVGFromURL(svgURL)
        }
    }
    
    private func loadSVGFromURL(_ svgURL: URL) {
        print("找到SVG文件: \(svgURL.path)")
        
        guard let svgData = try? Data(contentsOf: svgURL) else {
            print("错误: 无法读取SVG文件数据")
            self.setFallbackIcon()
            return
        }
        
        print("SVG数据大小: \(svgData.count) bytes")
        
        guard let nsImage = NSImage(data: svgData) else {
            print("错误: 无法从SVG数据创建NSImage")
            self.setFallbackIcon()
            return
        }
        
        // 设置图标大小
        nsImage.size = NSSize(width: 512, height: 512)
        NSApplication.shared.applicationIconImage = nsImage
        print("✅ 应用图标设置成功 - 使用SVG图标")
    }
    
    private func setFallbackIcon() {
        print("使用备用图标...")
        // 创建一个简单的备用图标
        if let fallbackImage = NSImage(systemSymbolName: "terminal", accessibilityDescription: "BrewMaster") {
            fallbackImage.size = NSSize(width: 512, height: 512)
            NSApplication.shared.applicationIconImage = fallbackImage
            print("✅ 应用图标设置成功 - 使用备用图标")
        } else {
            print("❌ 无法设置备用图标")
        }
    }
}