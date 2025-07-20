import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    var placeholder: String = "搜索..."
    var onSubmit: (() -> Void)? = nil
    var onClear: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(placeholder, text: $searchText)
                .textFieldStyle(.plain)
                .onSubmit {
                    onSubmit?() // 如果有提交动作则执行
                }
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    onClear?() // 如果有清除动作则执行
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

struct SearchToolbar: View {
    @Binding var searchText: String
    var placeholder: String = "搜索..."
    var onSubmit: (() -> Void)? = nil
    var trailingContent: (() -> AnyView)? = nil
    
    var body: some View {
        HStack {
            SearchBar(
                searchText: $searchText,
                placeholder: placeholder,
                onSubmit: onSubmit
            )
            
            if let trailingContent = trailingContent {
                trailingContent()
            }
        }
        .padding()
        .background(Color(.controlBackgroundColor))
    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SearchBar(
                searchText: .constant(""),
                placeholder: "搜索包..."
            )
            
            SearchBar(
                searchText: .constant("nginx"),
                placeholder: "搜索服务..."
            )
            
            Divider()
            
            SearchToolbar(
                searchText: .constant(""),
                placeholder: "搜索包...",
                trailingContent: {
                    AnyView(
                        Button(action: {}) {
                            Label("安装", systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    )
                }
            )
        }
        .padding()
    }
}