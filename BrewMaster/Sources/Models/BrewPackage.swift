import Foundation
import SwiftUI

struct BrewPackage: Identifiable, Hashable {
    let id: String
    let name: String
    let type: String // "公式" 或 "桶装"
    let version: String
    let description: String
    let installPath: String
    let dependencies: [String]
    let homepage: String?
    let hasUpdate: Bool
    let availableVersion: String?
    let hasService: Bool
    let serviceRunning: Bool
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BrewPackage, rhs: BrewPackage) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [BrewPackage] {
        [
            BrewPackage(
                id: UUID().uuidString,
                name: "git",
                type: "公式",
                version: "2.33.0",
                description: "分布式版本控制系统",
                installPath: "/usr/local/Cellar/git/2.33.0",
                dependencies: ["gettext", "pcre2"],
                homepage: "https://git-scm.com",
                hasUpdate: true,
                availableVersion: "2.34.1",
                hasService: false,
                serviceRunning: false
            ),
            BrewPackage(
                id: UUID().uuidString,
                name: "node",
                type: "公式",
                version: "16.13.0",
                description: "基于V8引擎的JavaScript运行时",
                installPath: "/usr/local/Cellar/node/16.13.0",
                dependencies: ["icu4c", "python@3.9"],
                homepage: "https://nodejs.org/",
                hasUpdate: false,
                availableVersion: nil,
                hasService: false,
                serviceRunning: false
            ),
            BrewPackage(
                id: UUID().uuidString,
                name: "mysql",
                type: "公式",
                version: "8.0.27",
                description: "开源关系型数据库",
                installPath: "/usr/local/Cellar/mysql/8.0.27",
                dependencies: ["openssl@1.1"],
                homepage: "https://dev.mysql.com/doc/refman/8.0/en/",
                hasUpdate: false,
                availableVersion: nil,
                hasService: true,
                serviceRunning: true
            ),
            BrewPackage(
                id: UUID().uuidString,
                name: "visual-studio-code",
                type: "桶装",
                version: "1.62.3",
                description: "微软开源代码编辑器",
                installPath: "/usr/local/Caskroom/visual-studio-code/1.62.3",
                dependencies: [],
                homepage: "https://code.visualstudio.com/",
                hasUpdate: true,
                availableVersion: "1.63.0",
                hasService: false,
                serviceRunning: false
            )
        ]
    }
}