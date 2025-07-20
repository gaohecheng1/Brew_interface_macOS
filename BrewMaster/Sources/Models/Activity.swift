import Foundation

struct Activity: Identifiable {
    let id = UUID()
    let type: ActivityType
    let description: String
    let timestamp: Date
    let details: String?
    let isError: Bool
    
    init(type: ActivityType, description: String, details: String? = nil, timestamp: Date = Date(), isError: Bool = false) {
        self.type = type
        self.description = description
        self.timestamp = timestamp
        self.details = details
        self.isError = isError
    }
    
    // 创建示例数据用于预览
    static var examples: [Activity] {
        [
            Activity(
                type: .install,
                description: "安装了 git 2.33.0",
                timestamp: Date().addingTimeInterval(-3600 * 2)
            ),
            Activity(
                type: .update,
                description: "更新了 node 16.13.0 -> 16.14.0",
                timestamp: Date().addingTimeInterval(-3600 * 5)
            ),
            Activity(
                type: .uninstall,
                description: "卸载了 python@3.8",
                timestamp: Date().addingTimeInterval(-86400)
            ),
            Activity(
                type: .service,
                description: "启动了 mysql 服务",
                timestamp: Date().addingTimeInterval(-3600)
            ),
            Activity(
                type: .error,
                description: "更新 brew 失败",
                details: "Error: Failed to update homebrew core",
                timestamp: Date().addingTimeInterval(-3600 * 3),
                isError: true
            )
        ]
    }
}

enum ActivityType: String {
    case install = "安装"
    case update = "更新"
    case uninstall = "卸载"
    case service = "服务"
    case system = "系统"
    case error = "错误"
    
    var icon: String {
        switch self {
        case .install:
            return "plus.circle.fill"
        case .update:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .uninstall:
            return "minus.circle.fill"
        case .service:
            return "gear.circle.fill"
        case .system:
            return "terminal.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .install:
            return "green"
        case .update:
            return "blue"
        case .uninstall:
            return "red"
        case .service:
            return "purple"
        case .system:
            return "gray"
        case .error:
            return "orange"
        }
    }
}