import Foundation
import Combine

class BrewService {
    // MARK: - 私有属性
    private let shellService = ShellService()
    
    // MARK: - 公共方法
    
    /// 获取Homebrew版本
    func getBrewVersion() -> AnyPublisher<String, Error> {
        return shellService.execute(command: "brew --version")
            .map { output -> String in
                // 提取版本号
                if let versionLine = output.output.split(separator: "\n").first,
                   let versionMatch = versionLine.range(of: #"\d+\.\d+\.\d+"#, options: .regularExpression) {
                    return String(versionLine[versionMatch])
                }
                return "未知"
            }
            .eraseToAnyPublisher()
    }
    
    /// 获取最后更新时间
    func getLastUpdateTime() -> AnyPublisher<String, Error> {
        return shellService.execute(command: "stat -f '%Sm' $(brew --prefix)/Homebrew/.git/FETCH_HEAD")
            .map { output -> String in
                let timeString = output.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                return timeString.isEmpty ? "未知" : timeString
            }
            .eraseToAnyPublisher()
    }
    
    /// 获取已安装的包
    func getInstalledPackages() -> AnyPublisher<[BrewPackage], Error> {
        print("BrewService: 开始获取已安装的包")
        
        // 获取公式列表（带版本信息）
        let formulaePublisher = shellService.execute(command: "brew list --formula --versions")
            .map { [weak self] output -> [BrewPackage] in
                guard let self = self else { 
                    print("BrewService: self已被释放，无法解析公式列表")
                    return [] 
                }
                print("BrewService: 获取到公式列表原始输出: \(output.output.prefix(100))...")
                let packages = self.parsePackageList(output.output, type: "公式")
                print("BrewService: 解析到\(packages.count)个公式")
                return packages
            }
            .catch { error -> AnyPublisher<[BrewPackage], Error> in
                print("BrewService: 获取公式列表失败: \(error)")
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        
        // 获取桶装列表（带版本信息）
        let casksPublisher = shellService.execute(command: "brew list --cask --versions")
            .map { [weak self] output -> [BrewPackage] in
                guard let self = self else { 
                    print("BrewService: self已被释放，无法解析桶装列表")
                    return [] 
                }
                print("BrewService: 获取到桶装列表原始输出: \(output.output.prefix(100))...")
                let packages = self.parsePackageList(output.output, type: "桶装")
                print("BrewService: 解析到\(packages.count)个桶装")
                return packages
            }
            .catch { error -> AnyPublisher<[BrewPackage], Error> in
                print("BrewService: 获取桶装列表失败: \(error)")
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        
        // 合并结果
        return Publishers.Zip(formulaePublisher, casksPublisher)
            .map { formulae, casks -> [BrewPackage] in
                let allPackages = formulae + casks
                print("BrewService: 合并后共有\(allPackages.count)个包")
                return allPackages
            }
            .eraseToAnyPublisher()
    }
    
    /// 获取服务列表
    func getServices() -> AnyPublisher<[BrewServiceModel], Error> {
        print("BrewService: 开始获取服务列表")
        
        // 首先获取基本服务列表
        let servicesPublisher = shellService.execute(command: "brew services")
            .map { [weak self] output -> [BrewServiceModel] in
                guard let self = self else { 
                    print("BrewService: self已被释放，无法解析服务列表")
                    return [] 
                }
                print("BrewService: 获取到服务列表原始输出: \(output.output.prefix(100))...")
                let services = self.parseServiceList(output.output)
                print("BrewService: 解析到\(services.count)个服务")
                return services
            }
            .catch { error -> AnyPublisher<[BrewServiceModel], Error> in
                print("BrewService: 获取服务列表失败: \(error)")
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        
        // 获取已安装包的版本信息来补充服务版本
        let packagesPublisher = shellService.execute(command: "brew list --formula --versions")
            .map { output -> [String: String] in
                var versionMap: [String: String] = [:]
                let lines = output.output.split(separator: "\n")
                for line in lines {
                    let components = line.split(separator: " ")
                    if components.count >= 2 {
                        let name = String(components[0])
                        // 获取最新版本（可能有多个版本）
                        let versions = Array(components[1...])
                        let latestVersion = versions.last.map(String.init) ?? String(components[1])
                        versionMap[name] = latestVersion
                    }
                }
                return versionMap
            }
            .catch { _ -> AnyPublisher<[String: String], Error> in
                return Just([:]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        
        // 合并服务信息和版本信息
        return Publishers.Zip(servicesPublisher, packagesPublisher)
            .flatMap { services, versionMap -> AnyPublisher<[BrewServiceModel], Error> in
                // 为每个服务获取详细的版本信息
                let servicePublishers = services.map { service -> AnyPublisher<BrewServiceModel, Error> in
                    // 首先尝试从已安装包列表中获取版本
                    if let version = versionMap[service.name] {
                        let updatedService = BrewServiceModel(
                            id: service.id,
                            name: service.name,
                            status: service.status,
                            user: service.user,
                            plist: service.plist,
                            isRunning: service.isRunning,
                            pid: service.pid,
                            lastRunTime: service.lastRunTime,
                            version: version
                        )
                        return Just(updatedService).setFailureType(to: Error.self).eraseToAnyPublisher()
                    } else {
                        // 如果在已安装包列表中找不到，尝试通过brew info获取版本信息
                        return self.shellService.execute(command: "brew info --formula \(service.name)")
                            .map { output -> BrewServiceModel in
                                let version = self.extractVersionFromInfo(output.output)
                                return BrewServiceModel(
                                    id: service.id,
                                    name: service.name,
                                    status: service.status,
                                    user: service.user,
                                    plist: service.plist,
                                    isRunning: service.isRunning,
                                    pid: service.pid,
                                    lastRunTime: service.lastRunTime,
                                    version: version
                                )
                            }
                            .catch { _ -> AnyPublisher<BrewServiceModel, Error> in
                                // 如果获取失败，返回原始服务信息
                                let originalService = BrewServiceModel(
                                    id: service.id,
                                    name: service.name,
                                    status: service.status,
                                    user: service.user,
                                    plist: service.plist,
                                    isRunning: service.isRunning,
                                    pid: service.pid,
                                    lastRunTime: service.lastRunTime,
                                    version: nil
                                )
                                return Just(originalService).setFailureType(to: Error.self).eraseToAnyPublisher()
                            }
                            .eraseToAnyPublisher()
                    }
                }
                
                // 合并所有服务的结果
                return Publishers.MergeMany(servicePublishers)
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 检查更新
    func checkUpdates() -> AnyPublisher<[BrewPackage], Error> {
        print("BrewService: 开始检查更新...")
        // 先更新Homebrew索引
        return shellService.execute(command: "brew update")
            .flatMap { [weak self] output -> AnyPublisher<[BrewPackage], Error> in
                guard let self = self else { 
                    print("BrewService: self已被释放，无法检查更新")
                    return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher() 
                }
                
                print("BrewService: brew update 执行结果: \(output.output.prefix(100))...")
                
                // 获取可更新的公式
                let formulaePublisher = self.shellService.execute(command: "brew outdated --formula --verbose")
                    .map { output -> [BrewPackage] in
                        print("BrewService: 获取到可更新公式原始输出: \(output.output.prefix(100))...")
                        return self.parseOutdatedPackages(output.output, type: "公式")
                    }
                    .catch { error -> AnyPublisher<[BrewPackage], Error> in
                        print("BrewService: 获取可更新公式失败: \(error)")
                        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                
                // 获取可更新的桶装
                let casksPublisher = self.shellService.execute(command: "brew outdated --cask --verbose")
                    .map { output -> [BrewPackage] in
                        print("BrewService: 获取到可更新桶装原始输出: \(output.output.prefix(100))...")
                        return self.parseOutdatedPackages(output.output, type: "桶装")
                    }
                    .catch { error -> AnyPublisher<[BrewPackage], Error> in
                        print("BrewService: 获取可更新桶装失败: \(error)")
                        return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                
                // 合并结果
                return Publishers.Zip(formulaePublisher, casksPublisher)
                    .map { formulae, casks -> [BrewPackage] in
                        let allPackages = formulae + casks
                        print("BrewService: 合并后共有\(allPackages.count)个可更新包")
                        return allPackages
                    }
                    .eraseToAnyPublisher()
            }
            .catch { error -> AnyPublisher<[BrewPackage], Error> in
                print("BrewService: brew update 执行失败: \(error)")
                // 即使更新索引失败，也尝试获取可更新包
                return Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 更新Homebrew
    func updateHomebrew() -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew update")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 更新所有包
    func updateAllPackages() -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew upgrade")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 更新多个包
    func updatePackages(_ packageNames: [String]) -> AnyPublisher<Void, Error> {
        let packagesString = packageNames.joined(separator: " ")
        return shellService.execute(command: "brew upgrade \(packagesString)")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 更新单个包
    func updatePackage(_ packageName: String) -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew upgrade \(packageName)")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 卸载包
    func uninstallPackage(_ packageName: String, type: String) -> AnyPublisher<Void, Error> {
        let command = type == "公式" ?
            "brew uninstall --formula \(packageName)" :
            "brew uninstall --cask \(packageName)"
        
        return shellService.execute(command: command)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 搜索包
    func searchPackage(_ query: String) -> AnyPublisher<[BrewSearchResult], Error> {
        // 搜索公式
        let formulaePublisher = shellService.execute(command: "brew search --formula \(query)")
            .map { [weak self] output -> [BrewSearchResult] in
                guard let self = self else { return [] }
                return self.parseSearchResults(output.output, type: "公式")
            }
        
        // 搜索桶装
        let casksPublisher = shellService.execute(command: "brew search --cask \(query)")
            .map { [weak self] output -> [BrewSearchResult] in
                guard let self = self else { return [] }
                return self.parseSearchResults(output.output, type: "桶装")
            }
        
        // 合并结果
        return Publishers.Zip(formulaePublisher, casksPublisher)
            .map { formulae, casks -> [BrewSearchResult] in
                return formulae + casks
            }
            .eraseToAnyPublisher()
    }
    
    /// 安装包
    func installPackage(_ packageName: String, type: String) -> AnyPublisher<Void, Error> {
        let command = type == "公式" ?
            "brew install --formula \(packageName)" :
            "brew install --cask \(packageName)"
        
        return shellService.execute(command: command)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 启动服务
    func startService(_ serviceName: String) -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew services start \(serviceName)")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 停止服务
    func stopService(_ serviceName: String) -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew services stop \(serviceName)")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 重启服务
    func restartService(_ serviceName: String) -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew services restart \(serviceName)")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    /// 获取服务日志
    func getServiceLogs(_ serviceName: String) -> AnyPublisher<String, Error> {
        // 首先获取服务的plist路径
        return shellService.execute(command: "brew services info \(serviceName) | grep plist")
            .flatMap { [weak self] output -> AnyPublisher<String, Error> in
                guard let self = self else { return Just("").setFailureType(to: Error.self).eraseToAnyPublisher() }
                
                // 提取plist路径
                let plistLine = output.output.trimmingCharacters(in: .whitespacesAndNewlines)
                guard let plistPath = plistLine.split(separator: ":").last?.trimmingCharacters(in: .whitespaces) else {
                    return Just("无法获取服务日志路径").setFailureType(to: Error.self).eraseToAnyPublisher()
                }
                
                // 获取日志路径
                return self.shellService.execute(command: "defaults read \(plistPath) StandardOutPath || echo ''")
                    .flatMap { logPathOutput -> AnyPublisher<String, Error> in
                        let logPath = logPathOutput.output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
                        
                        if logPath.isEmpty {
                            return Just("无法获取服务日志").setFailureType(to: Error.self).eraseToAnyPublisher()
                        }
                        
                        // 读取日志内容
                        return self.shellService.execute(command: "tail -n 100 \(logPath) 2>/dev/null || echo '无法读取日志文件'")
                            .map { logOutput in
                                return logOutput.output.isEmpty ? "日志为空" : logOutput.output
                            }
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    /// 清理系统
    func cleanup() -> AnyPublisher<Void, Error> {
        return shellService.execute(command: "brew cleanup")
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - 私有方法
    
    /// 解析简单包列表（每行只有包名）
    private func parseSimplePackageList(_ output: String, type: String) -> [BrewPackage] {
        print("BrewService: 开始解析简单\(type)列表，输出长度: \(output.count)字符")
        let lines = output.split(separator: "\n")
        print("BrewService: 解析简单\(type)列表，共\(lines.count)行")
        var packages: [BrewPackage] = []
        
        for (index, line) in lines.enumerated() {
            do {
                let packageName = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if !packageName.isEmpty {
                    print("BrewService: 解析到\(type): \(packageName)")
                    
                    // 创建包对象
                    let package = BrewPackage(
                        id: UUID().uuidString,
                        name: packageName,
                        type: type,
                        version: "未知", // 版本需要额外获取
                        description: "", // 描述需要额外获取
                        installPath: "", // 安装路径需要额外获取
                        dependencies: [], // 依赖需要额外获取
                        homepage: nil,
                        hasUpdate: false,
                        availableVersion: nil,
                        hasService: type == "公式", // 简单假设所有公式都可能有服务
                        serviceRunning: false // 服务状态需要额外获取
                    )
                    
                    packages.append(package)
                } else {
                    print("BrewService: 警告 - 无法解析\(type)行 \(index+1): '\(line)'，包名为空")
                }
            } catch {
                print("BrewService: 错误 - 解析\(type)行 \(index+1)时出错: \(error)")
            }
        }
        
        print("BrewService: 成功解析\(packages.count)个\(type)")
        return packages
    }
    
    /// 解析详细包列表
    private func parsePackageList(_ output: String, type: String) -> [BrewPackage] {
        print("BrewService: 开始解析\(type)列表，输出长度: \(output.count)字符")
        let lines = output.split(separator: "\n")
        print("BrewService: 解析\(type)列表，共\(lines.count)行")
        var packages: [BrewPackage] = []
        
        for (index, line) in lines.enumerated() {
            do {
                let lineStr = line.trimmingCharacters(in: .whitespacesAndNewlines)
                if lineStr.isEmpty { continue }
                
                let components = lineStr.split(separator: " ")
                if components.count >= 1 {
                    let name = String(components[0])
                    // 如果有版本信息，取第一个版本（可能有多个版本）
                    let version = components.count > 1 ? String(components[1]) : "未知"
                    
                    print("BrewService: 解析到\(type): \(name), 版本: \(version)")
                    
                    // 获取包的详细信息
                    let (description, installPath, dependencies, homepage) = getPackageDetails(name: name, type: type)
                    
                    // 创建包对象
                    let package = BrewPackage(
                        id: UUID().uuidString,
                        name: name,
                        type: type,
                        version: version,
                        description: description,
                        installPath: installPath,
                        dependencies: dependencies,
                        homepage: homepage,
                        hasUpdate: false,
                        availableVersion: nil,
                        hasService: type == "公式", // 简单假设所有公式都可能有服务
                        serviceRunning: false // 服务状态需要额外获取
                    )
                    
                    packages.append(package)
                } else {
                    print("BrewService: 警告 - 无法解析\(type)行 \(index+1): '\(line)'，组件数量不足")
                }
            } catch {
                print("BrewService: 错误 - 解析\(type)行 \(index+1)时出错: \(error)")
            }
        }
        
        print("BrewService: 成功解析\(packages.count)个\(type)")
        return packages
    }
    
    /// 解析服务列表
    private func parseServiceList(_ output: String) -> [BrewServiceModel] {
        print("BrewService: 开始解析服务列表，输出长度: \(output.count)字符")
        let lines = output.split(separator: "\n")
        print("BrewService: 解析服务列表，共\(lines.count)行")
        var services: [BrewServiceModel] = []
        
        if lines.isEmpty {
            print("BrewService: 警告 - 服务列表为空")
            return services
        }
        
        // 打印标题行以便调试
        if lines.count > 0 {
            print("BrewService: 服务列表标题行: '\(lines[0])'")
        }
        
        // 跳过标题行
        for i in 1..<lines.count {
            do {
                let line = lines[i]
                print("BrewService: 解析服务行 \(i): '\(line)'")
                let components = line.split(separator: " ").filter { !$0.isEmpty }
                print("BrewService: 服务行 \(i) 组件数量: \(components.count)")
                
                if components.count >= 2 {
                    let name = String(components[0])
                    let status = String(components[1])
                    let user = components.count > 2 ? String(components[2]) : ""
                    let plist = components.count > 3 ? String(components[3]) : ""
                    
                    print("BrewService: 解析到服务 - 名称: \(name), 状态: \(status), 用户: \(user)")
                    
                    // 创建服务对象
                    let service = BrewServiceModel(
                        id: UUID().uuidString,
                        name: name,
                        status: status,
                        user: user,
                        plist: plist,
                        isRunning: status.lowercased() == "started",
                        pid: nil, // PID需要额外获取
                        lastRunTime: nil, // 最后运行时间需要额外获取
                        version: nil // 版本需要额外获取
                    )
                    
                    services.append(service)
                } else if components.count == 1 {
                    // 处理只有名称的情况
                    let name = String(components[0])
                    print("BrewService: 解析到服务（只有名称） - 名称: \(name)")
                    
                    // 创建服务对象，使用默认值
                    let service = BrewServiceModel(
                        id: UUID().uuidString,
                        name: name,
                        status: "unknown",
                        user: "",
                        plist: "",
                        isRunning: false,
                        pid: nil,
                        lastRunTime: nil,
                        version: nil
                    )
                    
                    services.append(service)
                } else {
                    print("BrewService: 警告 - 无法解析服务行 \(i): '\(line)'，组件数量不足")
                }
            } catch {
                print("BrewService: 错误 - 解析服务行 \(i)时出错: \(error)")
            }
        }
        
        print("BrewService: 成功解析\(services.count)个服务")
        return services
    }
    
    /// 解析可更新的包
    private func parseOutdatedPackages(_ output: String, type: String) -> [BrewPackage] {
        print("BrewService: 开始解析可更新的\(type)列表，输出长度: \(output.count)字符")
        let lines = output.split(separator: "\n")
        print("BrewService: 解析可更新的\(type)列表，共\(lines.count)行")
        var packages: [BrewPackage] = []
        
        for (index, line) in lines.enumerated() {
            print("BrewService: 解析可更新的\(type)行 \(index+1): '\(line)'")
            let components = line.split(separator: " ")
            print("BrewService: 可更新的\(type)行 \(index+1) 组件数量: \(components.count)")
            
            if components.count >= 3 {
                let name = String(components[0])
                let currentVersion = String(components[1])
                let newVersion = String(components[2])
                
                print("BrewService: 解析到可更新的\(type) - 名称: \(name), 当前版本: \(currentVersion), 新版本: \(newVersion)")
                
                // 创建包对象
                let package = BrewPackage(
                    id: UUID().uuidString,
                    name: name,
                    type: type,
                    version: currentVersion,
                    description: "", // 描述需要额外获取
                    installPath: "", // 安装路径需要额外获取
                    dependencies: [], // 依赖需要额外获取
                    homepage: nil,
                    hasUpdate: true,
                    availableVersion: newVersion,
                    hasService: type == "公式", // 简单假设所有公式都可能有服务
                    serviceRunning: false // 服务状态需要额外获取
                )
                
                packages.append(package)
            } else {
                print("BrewService: 警告 - 无法解析可更新的\(type)行 \(index+1): '\(line)'，组件数量不足")
            }
        }
        
        print("BrewService: 成功解析\(packages.count)个可更新的\(type)")
        return packages
    }
    
    /// 解析搜索结果
    private func parseSearchResults(_ output: String, type: String) -> [BrewSearchResult] {
        let lines = output.split(separator: "\n")
        var results: [BrewSearchResult] = []
        
        for line in lines {
            let name = String(line.trimmingCharacters(in: .whitespaces))
            if !name.isEmpty {
                // 创建搜索结果对象
                let result = BrewSearchResult(
                    id: UUID().uuidString,
                    name: name,
                    type: type,
                    description: "" // 描述需要额外获取
                )
                
                results.append(result)
            }
        }
        
        return results
    }
    
    /// 获取包的详细信息
    private func getPackageDetails(name: String, type: String) -> (description: String, installPath: String, dependencies: [String], homepage: String?) {
        // 这里可以异步获取详细信息，但为了性能考虑，先返回基本信息
        // 在实际应用中，可以考虑缓存机制或按需加载
        
        var description = ""
        var installPath = ""
        var dependencies: [String] = []
        var homepage: String? = nil
        
        // 尝试获取基本的安装路径
        if type == "公式" {
            installPath = "/usr/local/Cellar/\(name)"
        } else {
            installPath = "/usr/local/Caskroom/\(name)"
        }
        
        // 可以在这里添加更多的信息获取逻辑
        // 例如：通过 brew info 命令获取详细信息
        // 但为了避免阻塞主线程，这里先返回基本信息
        
        return (description, installPath, dependencies, homepage)
    }
    
    /// 异步获取包的详细信息
    func getPackageInfo(_ packageName: String, type: String) -> AnyPublisher<BrewPackage?, Error> {
        let command = type == "公式" ? 
            "brew info --formula \(packageName)" : 
            "brew info --cask \(packageName)"
        
        return shellService.execute(command: command)
            .map { [weak self] output -> BrewPackage? in
                guard let self = self else { return nil }
                return self.parsePackageInfo(output.output, name: packageName, type: type)
            }
            .eraseToAnyPublisher()
    }
    
    /// 从brew info输出中提取版本信息
    private func extractVersionFromInfo(_ output: String) -> String? {
        let lines = output.split(separator: "\n")
        
        for line in lines {
            let lineStr = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 查找版本信息，通常在第一行或包含版本号的行
            if lineStr.contains(":") {
                let parts = lineStr.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    let nameAndVersion = String(parts[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                    // 使用正则表达式提取版本号
                    if let versionRange = nameAndVersion.range(of: #"\d+\.\d+(?:\.\d+)*(?:[a-zA-Z0-9\-\.]*)?"#, options: .regularExpression) {
                        return String(nameAndVersion[versionRange])
                    }
                }
            }
            
            // 也检查是否有单独的版本行
            if lineStr.lowercased().contains("version") {
                if let versionRange = lineStr.range(of: #"\d+\.\d+(?:\.\d+)*(?:[a-zA-Z0-9\-\.]*)?"#, options: .regularExpression) {
                    return String(lineStr[versionRange])
                }
            }
        }
        
        return nil
    }
    
    /// 解析包信息
    private func parsePackageInfo(_ output: String, name: String, type: String) -> BrewPackage? {
        let lines = output.split(separator: "\n")
        guard !lines.isEmpty else { return nil }
        
        var description = ""
        var installPath = ""
        var dependencies: [String] = []
        var homepage: String? = nil
        var version = "未知"
        
        for line in lines {
            let lineStr = String(line).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // 解析描述
            if lineStr.contains(":") && description.isEmpty {
                let parts = lineStr.split(separator: ":", maxSplits: 1)
                if parts.count == 2 {
                    description = String(parts[1]).trimmingCharacters(in: .whitespaces)
                }
            }
            
            // 解析主页
            if lineStr.contains("From:") || lineStr.contains("Homepage:") {
                let parts = lineStr.split(separator: " ")
                for part in parts {
                    if part.hasPrefix("http") {
                        homepage = String(part)
                        break
                    }
                }
            }
            
            // 解析依赖
            if lineStr.contains("Depends on:") {
                let dependsLine = lineStr.replacingOccurrences(of: "Depends on:", with: "")
                dependencies = dependsLine.split(separator: ",").map { 
                    String($0).trimmingCharacters(in: .whitespaces) 
                }
            }
            
            // 解析安装路径
            if lineStr.contains("/usr/local/Cellar") || lineStr.contains("/usr/local/Caskroom") {
                installPath = lineStr
            }
        }
        
        // 如果没有找到安装路径，使用默认路径
        if installPath.isEmpty {
            installPath = type == "公式" ? "/usr/local/Cellar/\(name)" : "/usr/local/Caskroom/\(name)"
        }
        
        return BrewPackage(
            id: UUID().uuidString,
            name: name,
            type: type,
            version: version,
            description: description,
            installPath: installPath,
            dependencies: dependencies,
            homepage: homepage,
            hasUpdate: false,
            availableVersion: nil,
            hasService: type == "公式",
            serviceRunning: false
        )
    }
}