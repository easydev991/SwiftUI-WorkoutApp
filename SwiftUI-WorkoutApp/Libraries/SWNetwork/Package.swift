// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWNetwork",
    defaultLocalization: "en",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SWNetwork", targets: ["SWNetwork"])
    ],
    targets: [
        .target(name: "SWNetwork"),
        .testTarget(
            name: "SWNetworkTests",
            dependencies: ["SWNetwork"]
        )
    ]
)
