// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/OlegEremenko991/CachedAcyncImage",
            from: "1.0.3"
        )
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: []
        )
    ]
)
