import SwiftUI

struct TerminalView: View {
    @EnvironmentObject private var terminalViewModel: TerminalViewModel
    @State private var commandInput: String = ""
    @FocusState private var isInputFocused: Bool
    @AppStorage("terminalTheme") private var terminalTheme = "dark"
    @AppStorage("accentColor") private var accentColor = "blue"
    
    private var terminalBackgroundColor: Color {
        switch terminalTheme {
        case "light":
            return Color(NSColor.textBackgroundColor)
        case "dark":
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        case "classic":
            return Color(red: 0.0, green: 0.2, blue: 0.0)
        case "blue":
            return Color(red: 0.0, green: 0.1, blue: 0.3)
        default:
            return Color(red: 0.1, green: 0.1, blue: 0.1)
        }
    }
    
    private var terminalTextColor: Color {
        switch terminalTheme {
        case "light":
            return Color(NSColor.textColor)
        case "dark":
            return Color.white
        case "classic":
            return Color.green
        case "blue":
            return Color(red: 0.6, green: 0.8, blue: 1.0)
        default:
            return Color.white
        }
    }
    
    private var accentColorValue: Color {
        switch accentColor {
        case "blue":
            return .blue
        case "green":
            return .green
        case "orange":
            return .orange
        case "purple":
            return .purple
        default:
            return .blue
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 终端输出区域
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(terminalViewModel.outputLines.indices, id: \.self) { index in
                            Text(terminalViewModel.outputLines[index])
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(terminalViewModel.outputColors[index])
                                .textSelection(.enabled)
                                .id(index)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: terminalViewModel.outputLines.count) { _ in
                    if !terminalViewModel.outputLines.isEmpty {
                        scrollView.scrollTo(terminalViewModel.outputLines.count - 1, anchor: .bottom)
                    }
                }
            }
            .background(terminalBackgroundColor)
            
            Divider()
            
            // 命令输入区域
            HStack {
                Text("$")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(terminalTextColor)
                
                TextField("输入命令...", text: $commandInput)
                    .font(.system(.body, design: .monospaced))
                    .textFieldStyle(.plain)
                    .foregroundColor(terminalTextColor)
                    .focused($isInputFocused)
                    .onSubmit {
                        if !commandInput.isEmpty {
                            terminalViewModel.executeCommand(commandInput)
                            commandInput = ""
                        }
                    }
                
                Button(action: {
                    if !commandInput.isEmpty {
                        terminalViewModel.executeCommand(commandInput)
                        commandInput = ""
                    }
                }) {
                    Image(systemName: "return")
                        .foregroundColor(accentColorValue)
                }
                .buttonStyle(.borderless)
                .keyboardShortcut(.return, modifiers: [])
                .disabled(commandInput.isEmpty)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(terminalBackgroundColor)
        }
        .onAppear {
            terminalViewModel.addOutput("欢迎使用 Brew Master！", color: .green)
            terminalViewModel.addOutput("您可以在此执行 Homebrew 命令。", color: .green)
            terminalViewModel.addOutput("例如：brew list, brew services list 等", color: .green)
            terminalViewModel.addOutput("", color: .white)
            isInputFocused = true
        }
    }
}

struct TerminalView_Previews: PreviewProvider {
    static var previews: some View {
        TerminalView()
            .environmentObject(TerminalViewModel())
            .frame(width: 600, height: 400)
    }
}