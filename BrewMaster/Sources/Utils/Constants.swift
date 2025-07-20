import Foundation
import SwiftUI

struct Constants {
    // MARK: - UI常量
    
    struct UI {
        static let sidebarWidth: CGFloat = 220
        static let terminalHeight: CGFloat = 300
        static let minWindowWidth: CGFloat = 1200
        static let minWindowHeight: CGFloat = 800
        static let defaultWindowWidth: CGFloat = 1400
        static let defaultWindowHeight: CGFloat = 900
        static let cornerRadius: CGFloat = 8
        static let padding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let iconSize: CGFloat = 20
    }
    
    // MARK: - 颜色
    
    struct Colors {
        static let background = Color(NSColor.windowBackgroundColor)
        static let secondaryBackground = Color(NSColor.controlBackgroundColor)
        static let accent = Color.blue
        static let text = Color.primary
        static let secondaryText = Color.secondary
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let terminal = Color.black
        static let terminalText = Color.green
    }
    
    // MARK: - 命令
    
    struct Commands {
        static let brewPath = "/usr/local/bin/brew"
        static let brewInfo = "brew info --json=v1 --installed"
        static let brewList = "brew list"
        static let brewSearch = "brew search --json=v1"
        static let brewOutdated = "brew outdated --json=v1"
        static let brewUpdate = "brew update"
        static let brewUpgrade = "brew upgrade"
        static let brewServices = "brew services list"
        static let brewVersion = "brew --version"
        static let systemInfo = "system_profiler SPSoftwareDataType SPHardwareDataType"
    }
    
    // MARK: - 通知名称
    
    struct Notifications {
        static let packageInstalled = Notification.Name("packageInstalled")
        static let packageUninstalled = Notification.Name("packageUninstalled")
        static let packageUpdated = Notification.Name("packageUpdated")
        static let serviceStatusChanged = Notification.Name("serviceStatusChanged")
        static let brewUpdated = Notification.Name("brewUpdated")
    }
}