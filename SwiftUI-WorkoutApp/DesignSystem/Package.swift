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
        .package(url: "https://github.com/OlegEremenko991/CachedAsyncImage991", from: "1.0.4")
    ],
    targets: [
        .target(
            name: "DesignSystem",
            dependencies: [
                .product(name: "CachedAsyncImage991", package: "CachedAsyncImage991")
            ]
        )
    ]
)
