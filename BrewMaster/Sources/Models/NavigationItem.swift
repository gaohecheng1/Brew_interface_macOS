import SwiftUI

enum NavigationItem: String, CaseIterable, Identifiable {
    case dashboard = "仪表盘"
    case packages = "包管理"
    case services = "服务管理"
    case updates = "更新管理"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .dashboard: return "gauge"
        case .packages: return "shippingbox"
        case .services: return "server.rack"
        case .updates: return "arrow.triangle.2.circlepath"
        }
    }
}