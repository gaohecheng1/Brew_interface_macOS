import Foundation
import Combine
import SwiftUI

class TerminalViewModel: ObservableObject {
    // MARK: - 发布属性
    @Published var outputLines: [String] = []
    @Published var outputColors: [Color] = []
    @Published var isExecuting = false
    @Published var commandHistory: [String] = []
    
    // MARK: - 私有属性
    private let terminalService = TerminalService()
    private var cancellables = Set<AnyCancellable>()
    private let maxHistoryCount = 50
    private let maxOutputLines = 1000
    
    // MARK: - 初始化
    init() {
        loadCommandHistory()
    }
    
    // MARK: - 公共方法
    
    /// 执行命令
    func executeCommand(_ command: String) {
        guard !command.isEmpty else { return }
        
        // 添加命令到历史记录
        addToCommandHistory(command)
        
        // 显示命令
        addOutput("$ \(command)", color: .white)
        
        // 标记为正在执行
        isExecuting = true
        
        // 执行命令
        terminalService.executeCommand(command)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isExecuting = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.addOutput("错误: \(error.localizedDescription)", color: .red)
                }
            }, receiveValue: { [weak self] output in
                // 处理输出
                if !output.output.isEmpty {
                    if output.isError {
                        self?.addOutput(output.output, color: .red)
                    } else {
                        self?.addOutput(output.output, color: .white)
                    }
                }
                
                // 添加空行以提高可读性
                if !output.output.isEmpty {
                    self?.addOutput("", color: .white)
                }
            })
            .store(in: &cancellables)
    }
    
    /// 添加输出文本
    func addOutput(_ text: String, color: Color) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 将文本按行分割
            let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
                .map { String($0) }
            
            // 添加每一行及其颜色
            for line in lines {
                self.outputLines.append(line)
                self.outputColors.append(color)
            }
            
            // 限制输出行数
            if self.outputLines.count > self.maxOutputLines {
                let excessLines = self.outputLines.count - self.maxOutputLines
                self.outputLines.removeFirst(excessLines)
                self.outputColors.removeFirst(excessLines)
            }
        }
    }
    
    /// 清除输出
    func clearOutput() {
        DispatchQueue.main.async { [weak self] in
            self?.outputLines = []
            self?.outputColors = []
        }
    }
    
    // MARK: - 私有方法
    
    /// 添加命令到历史记录
    private func addToCommandHistory(_ command: String) {
        // 如果命令已存在于历史记录中，先移除它
        if let index = commandHistory.firstIndex(of: command) {
            commandHistory.remove(at: index)
        }
        
        // 添加命令到历史记录开头
        commandHistory.insert(command, at: 0)
        
        // 限制历史记录数量
        if commandHistory.count > maxHistoryCount {
            commandHistory = Array(commandHistory.prefix(maxHistoryCount))
        }
        
        // 保存历史记录
        saveCommandHistory()
    }
    
    /// 保存命令历史记录
    private func saveCommandHistory() {
        // 这里可以实现持久化存储，例如使用UserDefaults或文件存储
        // 简单起见，这里暂不实现
    }
    
    /// 加载命令历史记录
    private func loadCommandHistory() {
        // 这里可以实现从持久化存储加载，例如使用UserDefaults或文件存储
        // 简单起见，这里暂不实现
    }
}