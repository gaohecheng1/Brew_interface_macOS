import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    var message: String? = nil
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title3)
                .foregroundColor(.secondary)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EmptyStateView(
                icon: "magnifyingglass",
                title: "未找到匹配的包",
                message: "尝试使用不同的搜索词或浏览所有可用包",
                actionTitle: "浏览所有包",
                action: { print("Action tapped") }
            )
            
            EmptyStateView(
                icon: "checkmark.circle",
                title: "所有包都是最新的",
                message: "最后检查时间: 2023-06-15 14:30:45"
            )
        }
    }
}