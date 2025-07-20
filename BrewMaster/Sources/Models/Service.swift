import Foundation

struct Service: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let status: ServiceStatus
    let user: String
    let plist: String
    let pid: Int?
    let lastRunTime: Date?
    let packageName: String
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Service, rhs: Service) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [Service] {
        [
            Service(
                name: "mysql",
                status: .running,
                user: "gaoheyuan",
                plist: "/usr/local/opt/mysql/homebrew.mxcl.mysql.plist",
                pid: 1234,
                lastRunTime: Date().addingTimeInterval(-3600 * 5),
                packageName: "mysql"
            ),
            Service(
                name: "redis",
                status: .running,
                user: "gaoheyuan",
                plist: "/usr/local/opt/redis/homebrew.mxcl.redis.plist",
                pid: 1235,
                lastRunTime: Date().addingTimeInterval(-3600 * 2),
                packageName: "redis"
            ),
            Service(
                name: "nginx",
                status: .stopped,
                user: "gaoheyuan",
                plist: "/usr/local/opt/nginx/homebrew.mxcl.nginx.plist",
                pid: nil,
                lastRunTime: Date().addingTimeInterval(-86400 * 2),
                packageName: "nginx"
            ),
            Service(
                name: "postgresql",
                status: .stopped,
                user: "gaoheyuan",
                plist: "/usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist",
                pid: nil,
                lastRunTime: nil,
                packageName: "postgresql"
            )
        ]
    }
}

enum ServiceStatus: String, Identifiable {
    case running = "运行中"
    case stopped = "已停止"
    case unknown = "未知"
    
    var id: String { self.rawValue }
    
    var color: String {
        switch self {
        case .running:
            return "green"
        case .stopped:
            return "red"
        case .unknown:
            return "gray"
        }
    }
    
    var icon: String {
        switch self {
        case .running:
            return "play.circle.fill"
        case .stopped:
            return "stop.circle.fill"
        case .unknown:
            return "questionmark.circle.fill"
        }
    }
}