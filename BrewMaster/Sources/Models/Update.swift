import Foundation

struct Update: Identifiable, Hashable {
    let id = UUID()
    let packageName: String
    let currentVersion: String
    let newVersion: String
    let type: PackageType
    let pinned: Bool
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Update, rhs: Update) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [Update] {
        [
            Update(
                packageName: "git",
                currentVersion: "2.33.0",
                newVersion: "2.34.1",
                type: .formula,
                pinned: false
            ),
            Update(
                packageName: "node",
                currentVersion: "16.13.0",
                newVersion: "16.14.0",
                type: .formula,
                pinned: true
            ),
            Update(
                packageName: "visual-studio-code",
                currentVersion: "1.62.3",
                newVersion: "1.63.0",
                type: .cask,
                pinned: false
            ),
            Update(
                packageName: "firefox",
                currentVersion: "95.0",
                newVersion: "96.0",
                type: .cask,
                pinned: false
            )
        ]
    }
}