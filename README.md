# BrewMaster - Homebrew图形界面管理工具

![BrewMaster Logo](Resources/brewmaster_logo.svg)

## 项目简介

BrewMaster是一个为macOS设计的Homebrew图形界面管理工具，使用SwiftUI构建，提供了直观、美观的用户界面，让您可以轻松管理Homebrew包和服务，无需记忆复杂的命令行指令。

## 功能特性

- **仪表盘**：一目了然地查看Homebrew状态，包括已安装包数量、运行中服务数量、可更新包数量等
- **包管理**：
  - 查看所有已安装的包（公式和桶装）
  - 搜索和安装新包
  - 更新和卸载包
  - 查看包的详细信息（版本、依赖、安装路径等）
- **服务管理**：
  - 查看所有Homebrew服务及其状态
  - 启动、停止和重启服务
  - 查看服务日志
- **更新管理**：
  - 检查可更新的包
  - 选择性更新或一键更新所有包
  - 更新Homebrew本身
- **终端集成**：内置终端，支持直接执行Homebrew命令

## 系统要求

- macOS 12.0 (Monterey) 或更高版本
- 已安装Homebrew

## 安装方法

### 方法一：直接下载

1. 从[Releases](https://github.com/gaohecheng1/Brew_interface_macOS/releases)页面下载最新版本的BrewMaster.app
2. 将应用拖动到Applications文件夹
3. 启动应用

### 方法二：从源码构建

1. 克隆仓库：`git clone https://github.com/gaohecheng1/Brew_interface_macOS.git`
2. 进入项目目录：`cd Brew_interface_macOS/BrewMaster`
3. 使用Xcode打开项目：`open Package.swift`
4. 在Xcode中构建并运行项目

## 使用指南

### 仪表盘

仪表盘提供了Homebrew的状态概览，包括：

- Homebrew版本和最后更新时间
- 已安装包数量
- 运行中服务数量
- 可更新包数量
- 最近活动记录
- 快速操作按钮（更新Homebrew、更新所有包、清理系统）

### 包管理

包管理页面允许您：

- 查看所有已安装的包，可按类型（公式/桶装）筛选
- 搜索包名或描述
- 查看包的详细信息
- 安装新包
- 更新或卸载已安装的包

### 服务管理

服务管理页面允许您：

- 查看所有Homebrew服务及其状态
- 启动、停止或重启服务
- 查看服务的详细信息（用户、配置文件、PID等）
- 查看服务日志

### 更新管理

更新管理页面允许您：

- 检查可更新的包
- 选择要更新的包或一键更新所有包
- 查看更新详情（当前版本和可用版本）

### 终端

内置终端允许您：

- 直接执行Homebrew命令
- 查看命令输出
- 使用命令历史记录

## 技术架构

BrewMaster采用MVVM（Model-View-ViewModel）架构模式，使用SwiftUI构建用户界面，Combine框架处理异步操作和数据流。

- **Models**：定义数据结构，如Package、Service、Activity等
- **Views**：使用SwiftUI构建的用户界面组件
- **ViewModels**：处理业务逻辑和状态管理
- **Services**：与Homebrew交互的服务层

## 贡献指南

欢迎贡献代码、报告问题或提出改进建议！请遵循以下步骤：

1. Fork项目
2. 创建特性分支：`git checkout -b feature/amazing-feature`
3. 提交更改：`git commit -m 'Add some amazing feature'`
4. 推送到分支：`git push origin feature/amazing-feature`
5. 提交Pull Request

## 许可证

本项目采用MIT许可证 - 详情请参阅[LICENSE](LICENSE)文件

## 致谢

- [Homebrew](https://brew.sh/) - macOS缺失的软件包管理器
- [SwiftUI](https://developer.apple.com/xcode/swiftui/) - 用于构建用户界面的框架
- [Combine](https://developer.apple.com/documentation/combine) - 用于处理异步事件的框架

## 联系方式

如有任何问题或建议，请通过以下方式联系我们：

- 电子邮件：your.email@example.com
- GitHub Issues：[https://github.com/gaohecheng1/Brew_interface_macOS/issues](https://github.com/gaohecheng1/Brew_interface_macOS/issues)