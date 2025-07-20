import SwiftUI

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    var isCopyable: Bool = false
    
    @State private var isCopied: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if isCopyable {
                HStack(spacing: 8) {
                    Text(value)
                        .foregroundColor(valueColor)
                    
                    Button(action: {
                        copyToClipboard()
                    }) {
                        Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                            .foregroundColor(isCopied ? .green : .secondary)
                            .imageScale(.small)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                Text(value)
                    .foregroundColor(valueColor)
            }
        }
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        
        withAnimation {
            isCopied = true
        }
        
        // 2秒后重置复制状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

struct InfoSectionView: View {
    let title: String
    let content: String
    var isCopyable: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if isCopyable {
                HStack {
                    Text(content)
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    CopyButton(textToCopy: content)
                }
            } else {
                Text(content)
                    .textSelection(.enabled)
            }
        }
    }
}

struct CopyButton: View {
    let textToCopy: String
    @State private var isCopied: Bool = false
    
    var body: some View {
        Button(action: {
            copyToClipboard()
        }) {
            Image(systemName: isCopied ? "checkmark.circle.fill" : "doc.on.doc")
                .foregroundColor(isCopied ? .green : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    private func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(textToCopy, forType: .string)
        
        withAnimation {
            isCopied = true
        }
        
        // 2秒后重置复制状态
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                isCopied = false
            }
        }
    }
}

struct InfoRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            InfoRow(label: "Homebrew 版本", value: "3.6.21")
            
            InfoRow(label: "安装路径", value: "/usr/local/Cellar/nginx/1.21.6", isCopyable: true)
            
            InfoRow(label: "状态", value: "运行中", valueColor: .green)
            
            Divider()
            
            InfoSectionView(title: "描述", content: "HTTP(S) 服务器，反向代理，IMAP/POP3 代理服务器")
            
            InfoSectionView(title: "安装路径", content: "/usr/local/Cellar/nginx/1.21.6", isCopyable: true)
        }
        .padding()
        .frame(width: 400)
    }
}