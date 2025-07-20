import Foundation

struct Package: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let version: String
    let installedOn: Date?
    let description: String
    let homepage: String?
    let dependencies: [String]
    let installPath: String
    let type: PackageType
    let isOutdated: Bool
    let outdatedVersion: String?
    
    // 用于Hashable协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Package, rhs: Package) -> Bool {
        lhs.id == rhs.id
    }
    
    // 创建示例数据用于预览
    static var examples: [Package] {
        [
            Package(
                name: "git",
                version: "2.33.0",
                installedOn: Date().addingTimeInterval(-86400 * 30),
                description: "Distributed revision control system",
                homepage: "https://git-scm.com",
                dependencies: ["gettext", "pcre2"],
                installPath: "/usr/local/Cellar/git/2.33.0",
                type: .formula,
                isOutdated: true,
                outdatedVersion: "2.34.1"
            ),
            Package(
                name: "node",
                version: "16.13.0",
                installedOn: Date().addingTimeInterval(-86400 * 15),
                description: "Platform built on V8 to build network applications",
                homepage: "https://nodejs.org/",
                dependencies: ["icu4c", "python@3.9"],
                installPath: "/usr/local/Cellar/node/16.13.0",
                type: .formula,
                isOutdated: false,
                outdatedVersion: nil
            ),
            Package(
                name: "visual-studio-code",
                version: "1.62.3",
                installedOn: Date().addingTimeInterval(-86400 * 5),
                description: "Open-source code editor",
                homepage: "https://code.visualstudio.com/",
                dependencies: [],
                installPath: "/usr/local/Caskroom/visual-studio-code/1.62.3",
                type: .cask,
                isOutdated: true,
                outdatedVersion: "1.63.0"
            )
        ]
    }
}

enum PackageType: String, CaseIterable, Identifiable {
    case formula = "Formula"
    case cask = "Cask"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .formula:
            return "命令行工具和库"
        case .cask:
            return "图形界面应用"
        }
    }
    
    var icon: String {
        switch self {
        case .formula:
            return "terminal"
        case .cask:
            return "app.badge"
        }
    }
}