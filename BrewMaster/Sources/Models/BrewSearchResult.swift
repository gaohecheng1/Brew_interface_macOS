import Foundation

struct BrewSearchResult: Identifiable, Hashable {
    let id: String
    let name: String
    let type: String // "公式" 或 "桶装"
    let description: String
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BrewSearchResult, rhs: BrewSearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [BrewSearchResult] {
        [
            BrewSearchResult(
                id: UUID().uuidString,
                name: "git",
                type: "公式",
                description: "分布式版本控制系统"
            ),
            BrewSearchResult(
                id: UUID().uuidString,
                name: "python",
                type: "公式",
                description: "解释型、交互式、面向对象的编程语言"
            ),
            BrewSearchResult(
                id: UUID().uuidString,
                name: "visual-studio-code",
                type: "桶装",
                description: "微软开源代码编辑器"
            ),
            BrewSearchResult(
                id: UUID().uuidString,
                name: "firefox",
                type: "桶装",
                description: "Mozilla开发的网络浏览器"
            )
        ]
    }
}