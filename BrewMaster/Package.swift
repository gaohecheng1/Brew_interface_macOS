// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BrewMaster",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "BrewMaster", targets: ["BrewMaster"])
    ],
    dependencies: [
        // 依赖项，如果需要的话
    ],
    targets: [
        .executableTarget(
            name: "BrewMaster",
            dependencies: [],
            path: "Sources",
            resources: [
                .process("../Resources")
            ]
        )
        // 暂时移除测试目标，直到创建适当的测试结构
        // .testTarget(
        //     name: "BrewMasterTests",
        //     dependencies: ["BrewMaster"],
        //     path: "Tests/BrewMasterTests"
        // )
    ]
)