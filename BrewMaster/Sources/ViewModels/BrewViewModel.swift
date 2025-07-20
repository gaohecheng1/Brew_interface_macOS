import Foundation
import Combine
import SwiftUI

class BrewViewModel: ObservableObject {
    // MARK: - 发布属性
    @Published var brewVersion: String = ""
    @Published var lastUpdateTime: String = ""
    @Published var systemInfo: String = ""
    @Published var lastUpdateCheckTime: String = ""
    
    @Published var installedPackages: [BrewPackage] = []
    @Published var services: [BrewServiceModel] = []
    @Published var updatablePackages: [BrewPackage] = []
    @Published var recentActivities: [BrewActivity] = []
    
    // MARK: - 计算属性
    var runningServices: [BrewServiceModel] {
        services.filter { $0.isRunning }
    }
    
    var stoppedServices: [BrewServiceModel] {
        services.filter { !$0.isRunning }
    }
    
    // MARK: - 私有属性
    private let brewService = BrewService()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 初始化
   init() {
        setupSystemInfo()
        loadRecentActivities()
        refreshStatus() // 初始化时加载数据
    }
    
    // MARK: - 公共方法
    
    /// 刷新Homebrew状态
    func refreshStatus() {
        print("开始刷新Homebrew状态...")
        getBrewVersion()
        getLastUpdateTime()
        fetchPackages()
        fetchServices()
        checkUpdates() // 添加检查更新
        print("刷新Homebrew状态完成")
    }
    
    /// 获取Homebrew版本
    func getBrewVersion() {
        print("开始获取Homebrew版本...")
        brewService.getBrewVersion()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("获取Homebrew版本完成")
                case .failure(let error):
                    print("获取Homebrew版本失败: \(error)")
                }
            }, receiveValue: { [weak self] version in
                print("获取到Homebrew版本: \(version)")
                self?.brewVersion = version
            })
            .store(in: &cancellables)
    }
    
    /// 获取最后更新时间
    func getLastUpdateTime() {
        print("开始获取最后更新时间...")
        brewService.getLastUpdateTime()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("获取最后更新时间完成")
                case .failure(let error):
                    print("获取最后更新时间失败: \(error)")
                }
            }, receiveValue: { [weak self] time in
                print("获取到最后更新时间: \(time)")
                self?.lastUpdateTime = time
            })
            .store(in: &cancellables)
    }
    
    /// 获取已安装的包
    func fetchPackages() {
        print("开始获取已安装的包...")
        brewService.getInstalledPackages()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("获取已安装的包完成")
                case .failure(let error):
                    print("获取已安装的包失败: \(error)")
                }
            }, receiveValue: { [weak self] packages in
                print("获取到 \(packages.count) 个已安装的包")
                self?.installedPackages = packages
            })
            .store(in: &cancellables)
    }
    
    /// 获取服务列表
    func fetchServices() {
        print("开始获取服务列表...")
        brewService.getServices()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("获取服务列表完成")
                case .failure(let error):
                    print("获取服务列表失败: \(error)")
                }
            }, receiveValue: { [weak self] services in
                print("获取到 \(services.count) 个服务")
                self?.services = services
            })
            .store(in: &cancellables)
    }
    
    /// 检查更新
    func checkUpdates(completion: ((Bool) -> Void)? = nil) {
        print("开始检查可更新包...")
        brewService.checkUpdates()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    print("检查可更新包完成")
                    completion?(true)
                case .failure(let error):
                    print("检查可更新包失败: \(error)")
                    completion?(false)
                }
            }, receiveValue: { [weak self] packages in
                print("获取到 \(packages.count) 个可更新包")
                self?.updatablePackages = packages
                self?.lastUpdateCheckTime = self?.currentTimeString() ?? ""
            })
            .store(in: &cancellables)
    }
    
    /// 更新Homebrew
    func updateHomebrew(completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "更新 Homebrew", description: "正在更新 Homebrew 核心组件", icon: "arrow.triangle.2.circlepath", iconColor: .blue)
        
        brewService.updateHomebrew()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "Homebrew 更新完成", description: "Homebrew 已更新到最新版本", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "Homebrew 更新失败", description: "更新过程中发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.getBrewVersion()
                self?.getLastUpdateTime()
            })
            .store(in: &cancellables)
    }
    
    /// 更新所有包
    func updateAllPackages(completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "更新所有包", description: "正在更新所有可更新的包", icon: "arrow.down.circle", iconColor: .blue)
        
        brewService.updateAllPackages()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "包更新完成", description: "所有包已更新到最新版本", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "包更新失败", description: "更新过程中发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPackages()
            })
            .store(in: &cancellables)
    }
    
    /// 更新选定的包
    func updatePackages(_ packages: [BrewPackage], completion: ((Bool) -> Void)? = nil) {
        let packageNames = packages.map { $0.name }
        addActivity(title: "更新选定包", description: "正在更新 \(packageNames.count) 个包", icon: "arrow.down.circle", iconColor: .blue)
        
        brewService.updatePackages(packageNames)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "包更新完成", description: "选定的包已更新到最新版本", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "包更新失败", description: "更新过程中发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPackages()
            })
            .store(in: &cancellables)
    }
    
    /// 更新单个包
    func updatePackage(_ package: BrewPackage, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "更新包", description: "正在更新 \(package.name)", icon: "arrow.down.circle", iconColor: .blue)
        
        brewService.updatePackage(package.name)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "包更新完成", description: "\(package.name) 已更新到最新版本", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "包更新失败", description: "更新 \(package.name) 时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPackages()
            })
            .store(in: &cancellables)
    }
    
    /// 卸载包
    func uninstallPackage(_ package: BrewPackage, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "卸载包", description: "正在卸载 \(package.name)", icon: "trash", iconColor: .red)
        
        brewService.uninstallPackage(package.name, type: package.type)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "包卸载完成", description: "\(package.name) 已成功卸载", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "包卸载失败", description: "卸载 \(package.name) 时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPackages()
                self?.fetchServices()
            })
            .store(in: &cancellables)
    }
    
    /// 搜索包
    func searchPackage(_ query: String, completion: @escaping ([BrewSearchResult]) -> Void) {
        brewService.searchPackage(query)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { results in
                completion(results)
            })
            .store(in: &cancellables)
    }
    
    /// 安装包
    func installPackage(_ package: BrewSearchResult, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "安装包", description: "正在安装 \(package.name)", icon: "arrow.down.circle", iconColor: .blue)
        
        brewService.installPackage(package.name, type: package.type)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "包安装完成", description: "\(package.name) 已成功安装", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "包安装失败", description: "安装 \(package.name) 时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchPackages()
                self?.fetchServices()
            })
            .store(in: &cancellables)
    }
    
    /// 启动服务
    func startService(_ serviceName: String, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "启动服务", description: "正在启动 \(serviceName) 服务", icon: "play.circle", iconColor: .green)
        
        brewService.startService(serviceName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "服务已启动", description: "\(serviceName) 服务已成功启动", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "服务启动失败", description: "启动 \(serviceName) 服务时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchServices()
            })
            .store(in: &cancellables)
    }
    
    /// 停止服务
    func stopService(_ serviceName: String, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "停止服务", description: "正在停止 \(serviceName) 服务", icon: "stop.circle", iconColor: .orange)
        
        brewService.stopService(serviceName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "服务已停止", description: "\(serviceName) 服务已成功停止", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "服务停止失败", description: "停止 \(serviceName) 服务时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchServices()
            })
            .store(in: &cancellables)
    }
    
    /// 重启服务
    func restartService(_ serviceName: String, completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "重启服务", description: "正在重启 \(serviceName) 服务", icon: "arrow.triangle.2.circlepath", iconColor: .blue)
        
        brewService.restartService(serviceName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "服务已重启", description: "\(serviceName) 服务已成功重启", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "服务重启失败", description: "重启 \(serviceName) 服务时发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { [weak self] _ in
                self?.fetchServices()
            })
            .store(in: &cancellables)
    }
    
    /// 获取服务日志
    func getServiceLogs(_ serviceName: String, completion: @escaping (String) -> Void) {
        brewService.getServiceLogs(serviceName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { logs in
                completion(logs)
            })
            .store(in: &cancellables)
    }
    
    /// 获取包详细信息
    func getPackageInfo(_ packageName: String, type: String = "公式", completion: @escaping (BrewPackage?) -> Void) {
        brewService.getPackageInfo(packageName, type: type)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    print("获取包详细信息失败: \(error)")
                    completion(nil)
                }
            }, receiveValue: { package in
                completion(package)
            })
            .store(in: &cancellables)
    }
    
    /// 清理系统
    func cleanup(completion: ((Bool) -> Void)? = nil) {
        addActivity(title: "清理系统", description: "正在清理未使用的下载和旧版本", icon: "trash", iconColor: .blue)
        
        brewService.cleanup()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    self?.addActivity(title: "清理完成", description: "系统已成功清理", icon: "checkmark.circle", iconColor: .green)
                    completion?(true)
                case .failure:
                    self?.addActivity(title: "清理失败", description: "清理过程中发生错误", icon: "xmark.circle", iconColor: .red)
                    completion?(false)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
    
    // MARK: - 私有方法
    
    /// 设置系统信息
    private func setupSystemInfo() {
        let processInfo = ProcessInfo.processInfo
        let osVersion = processInfo.operatingSystemVersionString
        systemInfo = "macOS \(osVersion)"
    }
    
    /// 添加活动记录
    private func addActivity(title: String, description: String, icon: String, iconColor: Color) {
        let activity = BrewActivity(
            id: UUID().uuidString,
            title: title,
            description: description,
            icon: icon,
            iconColor: iconColor,
            timeString: currentTimeString()
        )
        
        DispatchQueue.main.async { [weak self] in
            self?.recentActivities.insert(activity, at: 0)
            // 限制活动记录数量
            if let count = self?.recentActivities.count, count > 20 {
                self?.recentActivities = Array(self!.recentActivities.prefix(20))
            }
            self?.saveRecentActivities()
        }
    }
    
    /// 获取当前时间字符串
    private func currentTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    /// 保存最近活动到 UserDefaults
    private func saveRecentActivities() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentActivities)
            UserDefaults.standard.set(data, forKey: "recentActivities")
        } catch {
            print("保存活动记录失败: \(error)")
        }
    }
    
    /// 从 UserDefaults 加载最近活动
    private func loadRecentActivities() {
        if let data = UserDefaults.standard.data(forKey: "recentActivities") {
            do {
                let decoder = JSONDecoder()
                let activities = try decoder.decode([BrewActivity].self, from: data)
                recentActivities = activities
            } catch {
                print("加载活动记录失败: \(error)")
                recentActivities = []
            }
        } else {
            recentActivities = []
        }
    }
}