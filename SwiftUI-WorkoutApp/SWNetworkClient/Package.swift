// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWNetworkClient",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SWNetworkClient",
            targets: ["SWNetworkClient"]
        )
    ],
    dependencies: [
        .package(path: "../SWModels")
    ],
    targets: [
        .target(
            name: "SWNetworkClient",
            dependencies: ["SWModels"]
        )
    ]
)
