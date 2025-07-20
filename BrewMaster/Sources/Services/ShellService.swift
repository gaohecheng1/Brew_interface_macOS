import Foundation
import Combine

struct CommandOutput {
    let output: String
    let isError: Bool
}

class ShellService {
    // MARK: - 私有属性
    private let brewPath: String
    
    // MARK: - 初始化
    init() {
        self.brewPath = Self.detectBrewPath()
    }
    
    // MARK: - 公共方法
    
    /// 执行shell命令并返回输出流
    func execute(command: String) -> AnyPublisher<CommandOutput, Error> {
        return Future<CommandOutput, Error> { promise in
            self.executeCommand(command) { output, error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(output))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// 同步执行命令并返回输出
    func executeSync(command: String) throws -> String {
        // 替换命令中的brew为完整路径
        let processedCommand = command.replacingOccurrences(of: "brew ", with: "\(brewPath) ")
        print("同步执行命令: \(processedCommand)")
        
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", processedCommand]
        process.standardOutput = pipe
        process.standardError = pipe
        
        // 设置环境变量
        setupEnvironment(for: process)
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            } else {
                throw ShellError.outputDecodingFailed
            }
        } catch {
            throw ShellError.executionFailed(error.localizedDescription)
        }
    }
    
    // MARK: - 私有方法
    
    /// 检测brew的安装路径
    private static func detectBrewPath() -> String {
        let possiblePaths = [
            "/opt/homebrew/bin/brew",  // Apple Silicon Mac
            "/usr/local/bin/brew",     // Intel Mac
            "/home/linuxbrew/.linuxbrew/bin/brew"  // Linux (如果支持)
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                print("检测到brew路径: \(path)")
                return path
            }
        }
        
        // 如果都找不到，尝试使用which命令
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", "which brew"]
        process.standardOutput = pipe
        process.standardError = Pipe()
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !output.isEmpty {
                    print("通过which命令检测到brew路径: \(output)")
                    return output
                }
            }
        } catch {
            print("使用which命令检测brew路径失败: \(error)")
        }
        
        print("警告: 无法检测到brew路径，使用默认路径")
        return "/usr/local/bin/brew"  // 默认路径
    }
    
    /// 设置环境变量
    private func setupEnvironment(for process: Process) {
        var environment = ProcessInfo.processInfo.environment
        
        // 添加常见的PATH路径
        let additionalPaths = [
            "/opt/homebrew/bin",
            "/opt/homebrew/sbin",
            "/usr/local/bin",
            "/usr/local/sbin",
            "/usr/bin",
            "/bin",
            "/usr/sbin",
            "/sbin"
        ]
        
        let currentPath = environment["PATH"] ?? ""
        let newPath = additionalPaths.joined(separator: ":") + ":" + currentPath
        environment["PATH"] = newPath
        
        // 设置Homebrew相关环境变量
        if brewPath.contains("/opt/homebrew") {
            environment["HOMEBREW_PREFIX"] = "/opt/homebrew"
            environment["HOMEBREW_CELLAR"] = "/opt/homebrew/Cellar"
            environment["HOMEBREW_REPOSITORY"] = "/opt/homebrew"
        } else {
            environment["HOMEBREW_PREFIX"] = "/usr/local"
            environment["HOMEBREW_CELLAR"] = "/usr/local/Cellar"
            environment["HOMEBREW_REPOSITORY"] = "/usr/local/Homebrew"
        }
        
        process.environment = environment
    }
    
    private func executeCommand(_ command: String, completion: @escaping (CommandOutput, Error?) -> Void) {
        // 替换命令中的brew为完整路径
        let processedCommand = command.replacingOccurrences(of: "brew ", with: "\(brewPath) ")
        print("执行命令: \(processedCommand)")
        
        let process = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", processedCommand]
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // 设置环境变量
        setupEnvironment(for: process)
        
        do {
            try process.run()
            
            process.terminationHandler = { process in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let output = String(data: outputData, encoding: .utf8) ?? ""
                let error = String(data: errorData, encoding: .utf8) ?? ""
                
                print("命令执行完成: \(command)")
                print("退出状态: \(process.terminationStatus)")
                
                if process.terminationStatus != 0 {
                    print("命令执行失败: \(error)")
                    let shellError = ShellError.executionFailed(error.isEmpty ? "未知错误，退出状态: \(process.terminationStatus)" : error)
                    completion(CommandOutput(output: error, isError: true), shellError)
                } else if !error.isEmpty {
                    print("命令有错误输出: \(error)")
                    completion(CommandOutput(output: error, isError: true), nil)
                } else {
                    print("命令执行成功，输出长度: \(output.count)字符")
                    completion(CommandOutput(output: output, isError: false), nil)
                }
            }
        } catch {
            print("命令启动失败: \(error.localizedDescription)")
            completion(CommandOutput(output: error.localizedDescription, isError: true), error)
        }
    }
}

// MARK: - 错误类型

enum ShellError: Error {
    case executionFailed(String)
    case outputDecodingFailed
    
    var localizedDescription: String {
        switch self {
        case .executionFailed(let message):
            return "命令执行失败: \(message)"
        case .outputDecodingFailed:
            return "无法解码命令输出"
        }
    }
}