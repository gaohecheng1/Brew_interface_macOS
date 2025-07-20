import Foundation

struct BrewServiceModel: Identifiable, Hashable {
    let id: String
    let name: String
    let status: String
    let user: String
    let plist: String
    let isRunning: Bool
    let pid: Int?
    let lastRunTime: Date?
    let version: String?
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BrewServiceModel, rhs: BrewServiceModel) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [BrewServiceModel] {
        [
            BrewServiceModel(
                id: UUID().uuidString,
                name: "mysql",
                status: "started",
                user: "gaoheyuan",
                plist: "/usr/local/opt/mysql/homebrew.mxcl.mysql.plist",
                isRunning: true,
                pid: 1234,
                lastRunTime: Date().addingTimeInterval(-3600 * 5),
                version: "8.0.33"
            ),
            BrewServiceModel(
                id: UUID().uuidString,
                name: "redis",
                status: "started",
                user: "gaoheyuan",
                plist: "/usr/local/opt/redis/homebrew.mxcl.redis.plist",
                isRunning: true,
                pid: 1235,
                lastRunTime: Date().addingTimeInterval(-3600 * 2),
                version: "7.0.11"
            ),
            BrewServiceModel(
                id: UUID().uuidString,
                name: "nginx",
                status: "stopped",
                user: "gaoheyuan",
                plist: "/usr/local/opt/nginx/homebrew.mxcl.nginx.plist",
                isRunning: false,
                pid: nil,
                lastRunTime: Date().addingTimeInterval(-86400 * 2),
                version: "1.25.1"
            ),
            BrewServiceModel(
                id: UUID().uuidString,
                name: "postgresql",
                status: "stopped",
                user: "gaoheyuan",
                plist: "/usr/local/opt/postgresql/homebrew.mxcl.postgresql.plist",
                isRunning: false,
                pid: nil,
                lastRunTime: nil,
                version: "15.3"
            )
        ]
    }
}