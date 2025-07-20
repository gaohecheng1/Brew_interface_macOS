import SwiftUI

struct StatusCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?() // 如果有动作则执行，否则不做任何事
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text(value)
                        .font(.system(size: 28, weight: .bold))
                }
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12)
                .fill(Color(.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

struct StatusCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            StatusCard(
                title: "已安装包",
                value: "42",
                icon: "shippingbox.fill",
                color: .blue
            )
            
            StatusCard(
                title: "运行中服务",
                value: "5",
                icon: "server.rack",
                color: .green,
                action: { print("Card tapped") }
            )
            
            StatusCard(
                title: "可更新",
                value: "3",
                icon: "arrow.up.circle.fill",
                color: .orange
            )
        }
        .padding()
        .frame(width: 300)
    }
}