import SwiftUI

struct LoadingButton: View {
    let title: String
    let systemImage: String
    let isLoading: Bool
    let action: () -> Void
    var color: Color = .accentColor
    var style: ButtonStyle = .borderedProminent
    
    enum ButtonStyle {
        case bordered
        case borderedProminent
        case plain
    }
    
    var body: some View {
        applyButtonStyle(to:
            Button(action: action) {
                HStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 16, height: 16)
                    } else {
                        Image(systemName: systemImage)
                    }
                    
                    Text(title)
                }
                .foregroundColor(style == .plain ? color : nil)
            }
            .disabled(isLoading)
        )
    }
    
    @ViewBuilder
    private func applyButtonStyle<T: View>(to view: T) -> some View {
        switch style {
        case .bordered:
            view.buttonStyle(.bordered)
        case .borderedProminent:
            view.buttonStyle(.borderedProminent)
        case .plain:
            view.buttonStyle(.plain)
        }
    }
}

struct LoadingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            LoadingButton(
                title: "正常状态",
                systemImage: "arrow.clockwise",
                isLoading: false,
                action: {}
            )
            
            LoadingButton(
                title: "加载中",
                systemImage: "arrow.clockwise",
                isLoading: true,
                action: {}
            )
            
            LoadingButton(
                title: "普通按钮",
                systemImage: "trash",
                isLoading: false,
                action: {},
                color: .red,
                style: .bordered
            )
            
            LoadingButton(
                title: "文本按钮",
                systemImage: "info.circle",
                isLoading: false,
                action: {},
                style: .plain
            )
        }
        .padding()
    }
}