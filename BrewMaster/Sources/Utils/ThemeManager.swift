import SwiftUI
import Foundation

// MARK: - 全局主题管理器
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @AppStorage("accentColor") var accentColor = "blue"
    @AppStorage("colorScheme") var colorScheme = "auto"
    
    private init() {}
    
    // MARK: - 强调色
    var primaryAccentColor: Color {
        switch accentColor {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        default:
            return .blue
        }
    }
    
    // MARK: - 状态颜色（基于强调色调整）
    var successColor: Color {
        return .green // 成功状态保持绿色
    }
    
    var warningColor: Color {
        return .orange // 警告状态保持橙色
    }
    
    var errorColor: Color {
        return .red // 错误状态保持红色
    }
    
    // MARK: - 交互元素颜色
    var buttonColor: Color {
        return primaryAccentColor
    }
    
    var linkColor: Color {
        return primaryAccentColor
    }
    
    // MARK: - 包类型颜色
    var formulaColor: Color {
        return primaryAccentColor
    }
    
    var caskColor: Color {
        return .orange // Cask 保持橙色以区分
    }
    
    // MARK: - 服务状态颜色
    var serviceRunningColor: Color {
        return successColor
    }
    
    var serviceStoppedColor: Color {
        return .gray
    }
    
    // MARK: - 活动图标颜色
    func activityIconColor(for type: String) -> Color {
        switch type {
        case "success":
            return successColor
        case "error":
            return errorColor
        case "warning":
            return warningColor
        case "info":
            return primaryAccentColor
        default:
            return primaryAccentColor
        }
    }
}

// MARK: - SwiftUI Environment Key
struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}

// MARK: - View Extension
extension View {
    func withThemeManager() -> some View {
        self.environmentObject(ThemeManager.shared)
    }
}