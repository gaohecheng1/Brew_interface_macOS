import Foundation
import Combine

struct CommandOutput {
    let output: String
    let isError: Bool
}

class ShellService {
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
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: "/bin/zsh")
        process.arguments = ["-c", command]
        process.standardOutput = pipe
        process.standardError = pipe
        
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
    
    private func executeCommand(_ command: String, completion: @escaping (CommandOutput, Error?) -> Void) {
        print("执行命令: \(command)")
        let task = Process()
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        task.arguments = ["-c", command]
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            
            task.terminationHandler = { process in
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