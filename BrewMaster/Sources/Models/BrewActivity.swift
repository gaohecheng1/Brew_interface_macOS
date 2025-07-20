import Foundation
import SwiftUI

// 用于支持 Color 的 Codable
struct CodableColor: Codable {
    let red: Double
    let green: Double
    let blue: Double
    let opacity: Double
    
    init(color: Color) {
        // 将 SwiftUI Color 转换为 NSColor
        let nsColor: NSColor
        if #available(macOS 12.0, *) {
            nsColor = NSColor(color)
        } else {
            // 对于较旧的 macOS 版本，使用默认颜色
            nsColor = NSColor.systemBlue
        }
        
        // 确保颜色空间是 RGB
        let rgbColor = nsColor.usingColorSpace(.sRGB) ?? NSColor.systemBlue
        
        red = Double(rgbColor.redComponent)
        green = Double(rgbColor.greenComponent)
        blue = Double(rgbColor.blueComponent)
        opacity = Double(rgbColor.alphaComponent)
    }
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    // 预定义的颜色映射，用于常用颜色
    static func fromStandardColor(_ color: Color) -> CodableColor {
        // 检查是否是标准颜色
        if color == .red { return CodableColor(red: 1, green: 0, blue: 0, opacity: 1) }
        if color == .green { return CodableColor(red: 0, green: 1, blue: 0, opacity: 1) }
        if color == .blue { return CodableColor(red: 0, green: 0, blue: 1, opacity: 1) }
        if color == .orange { return CodableColor(red: 1, green: 0.5, blue: 0, opacity: 1) }
        if color == .yellow { return CodableColor(red: 1, green: 1, blue: 0, opacity: 1) }
        if color == .purple { return CodableColor(red: 0.5, green: 0, blue: 0.5, opacity: 1) }
        if color == .gray { return CodableColor(red: 0.5, green: 0.5, blue: 0.5, opacity: 1) }
        if color == .black { return CodableColor(red: 0, green: 0, blue: 0, opacity: 1) }
        if color == .white { return CodableColor(red: 1, green: 1, blue: 1, opacity: 1) }
        
        // 如果不是标准颜色，尝试转换
        return CodableColor(color: color)
    }
    
    // 便捷初始化方法
    init(red: Double, green: Double, blue: Double, opacity: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
}

struct BrewActivity: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    let timeString: String
    
    // 标准初始化方法
    init(id: String, title: String, description: String, icon: String, iconColor: Color, timeString: String) {
        self.id = id
        self.title = title
        self.description = description
        self.icon = icon
        self.iconColor = iconColor
        self.timeString = timeString
    }
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BrewActivity, rhs: BrewActivity) -> Bool {
        lhs.id == rhs.id
    }
    
    // 用于Codable协议
    enum CodingKeys: String, CodingKey {
        case id, title, description, icon, iconColor, timeString
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        icon = try container.decode(String.self, forKey: .icon)
        timeString = try container.decode(String.self, forKey: .timeString)
        
        let codableColor = try container.decode(CodableColor.self, forKey: .iconColor)
        iconColor = codableColor.color
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(icon, forKey: .icon)
        try container.encode(timeString, forKey: .timeString)
        
        // 使用预定义颜色映射来处理标准颜色
        let codableColor = CodableColor.fromStandardColor(iconColor)
        try container.encode(codableColor, forKey: .iconColor)
    }
    
    // 创建示例数据用于预览
    static var examples: [BrewActivity] {
        [
            BrewActivity(
                id: UUID().uuidString,
                title: "安装包",
                description: "成功安装了 git 2.33.0",
                icon: "arrow.down.circle",
                iconColor: .green,
                timeString: "2022-01-15 14:30:00"
            ),
            BrewActivity(
                id: UUID().uuidString,
                title: "更新包",
                description: "成功更新了 node 16.13.0 -> 16.14.0",
                icon: "arrow.triangle.2.circlepath",
                iconColor: .blue,
                timeString: "2022-01-15 13:45:00"
            ),
            BrewActivity(
                id: UUID().uuidString,
                title: "启动服务",
                description: "成功启动了 mysql 服务",
                icon: "play.circle",
                iconColor: .green,
                timeString: "2022-01-15 12:30:00"
            ),
            BrewActivity(
                id: UUID().uuidString,
                title: "卸载包",
                description: "成功卸载了 python@3.8",
                icon: "trash",
                iconColor: .red,
                timeString: "2022-01-14 18:20:00"
            ),
            BrewActivity(
                id: UUID().uuidString,
                title: "更新失败",
                description: "更新 brew 时发生错误",
                icon: "xmark.circle",
                iconColor: .red,
                timeString: "2022-01-14 16:15:00"
            )
        ]
    }
}