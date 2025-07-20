import Foundation
import SwiftUI

class Formatters {
    // MARK: - 日期格式化
    
    /// 格式化日期为相对时间（例如：5分钟前，2小时前，昨天等）
    static func formatRelativeDate(_ date: Date?) -> String {
        guard let date = date else { return "未知" }
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    /// 格式化日期为标准格式（例如：2022-01-15 14:30）
    static func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "未知" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    // MARK: - 文件大小格式化
    
    /// 格式化文件大小（例如：1.5 MB，2.3 GB等）
    static func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    // MARK: - 颜色转换
    
    /// 根据颜色名称返回SwiftUI颜色
    static func color(from name: String) -> Color {
        switch name.lowercased() {
        case "red":
            return .red
        case "green":
            return .green
        case "blue":
            return .blue
        case "orange":
            return .orange
        case "yellow":
            return .yellow
        case "purple":
            return .purple
        case "gray":
            return .gray
        default:
            return .primary
        }
    }
}