import SwiftUI

struct ActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isLoading: Bool = false
    var color: Color? = nil
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(color)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.secondary.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
    }
}

struct ActionButtonRow: View {
    let buttons: [ActionButtonConfig]
    
    struct ActionButtonConfig {
        let title: String
        let icon: String
        let action: () -> Void
        var isLoading: Bool = false
        var color: Color? = nil
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<buttons.count, id: \.self) { index in
                let button = buttons[index]
                ActionButton(
                    title: button.title,
                    icon: button.icon,
                    action: button.action,
                    isLoading: button.isLoading,
                    color: button.color
                )
            }
        }
    }
}

struct ActionButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ActionButtonRow(buttons: [
                ActionButtonRow.ActionButtonConfig(
                    title: "更新 Homebrew",
                    icon: "arrow.triangle.2.circlepath",
                    action: {}
                ),
                ActionButtonRow.ActionButtonConfig(
                    title: "更新所有包",
                    icon: "arrow.up.doc",
                    action: {},
                    isLoading: true
                ),
                ActionButtonRow.ActionButtonConfig(
                    title: "清理系统",
                    icon: "trash",
                    action: {},
                    color: .red
                )
            ])
            
            Divider()
            
            ActionButton(
                title: "启动服务",
                icon: "play.circle",
                action: {}
            )
        }
        .padding()
        .frame(width: 500)
    }
}