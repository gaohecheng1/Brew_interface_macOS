import Foundation

struct SystemInfo {
    let brewVersion: String
    let lastUpdated: Date?
    let macOSVersion: String
    let processorType: String
    let installedPackagesCount: Int
    let runningServicesCount: Int
    let outdatedPackagesCount: Int
    
    // 创建示例数据用于预览
    static var example: SystemInfo {
        SystemInfo(
            brewVersion: "3.3.9",
            lastUpdated: Date().addingTimeInterval(-86400 * 2),
            macOSVersion: "macOS 12.0.1 (21A559)",
            processorType: "Apple M1 Pro",
            installedPackagesCount: 45,
            runningServicesCount: 3,
            outdatedPackagesCount: 5
        )
    }
}