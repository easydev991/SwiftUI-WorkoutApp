// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWModels",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SWModels", targets: ["SWModels"])
    ],
    dependencies: [.package(path: "../SWUtils")],
    targets: [
        .target(name: "SWModels", dependencies: ["SWUtils"]),
        .testTarget(name: "SWModelsTest", dependencies: ["SWModels"])
    ]
)
