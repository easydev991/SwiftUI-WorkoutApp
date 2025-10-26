// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWNetworkClient",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SWNetworkClient", targets: ["SWNetworkClient"])
    ],
    dependencies: [
        .package(path: "../SWModels"),
        .package(path: "../SWNetwork")
    ],
    targets: [
        .target(
            name: "SWNetworkClient",
            dependencies: ["SWNetwork", "SWModels"]
        )
    ]
)
