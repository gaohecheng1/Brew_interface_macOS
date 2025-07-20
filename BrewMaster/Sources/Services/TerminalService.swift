import Foundation
import Combine

class TerminalService {
    // MARK: - 公共方法
    
    /// 执行命令并返回输出
    func executeCommand(_ command: String) -> AnyPublisher<CommandOutput, Error> {
        return shellService.execute(command: command)
    }
    
    // MARK: - 私有属性
    private let shellService = ShellService()
}