import Foundation

struct SearchResult: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let description: String
    let type: PackageType
    let isInstalled: Bool
    let version: String?
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SearchResult, rhs: SearchResult) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [SearchResult] {
        [
            SearchResult(
                name: "git",
                description: "Distributed revision control system",
                type: .formula,
                isInstalled: true,
                version: "2.33.0"
            ),
            SearchResult(
                name: "python",
                description: "Interpreted, interactive, object-oriented programming language",
                type: .formula,
                isInstalled: false,
                version: nil
            ),
            SearchResult(
                name: "visual-studio-code",
                description: "Open-source code editor",
                type: .cask,
                isInstalled: true,
                version: "1.62.3"
            ),
            SearchResult(
                name: "firefox",
                description: "Web browser",
                type: .cask,
                isInstalled: false,
                version: nil
            )
        ]
    }
}