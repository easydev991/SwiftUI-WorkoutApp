// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWDesignSystem",
    defaultLocalization: "en",
    platforms: [.iOS(.v16)],
    products: [
        .library(name: "SWDesignSystem", targets: ["SWDesignSystem"])
    ],
    dependencies: [
        .package(path: "../CachedAsyncImage")
    ],
    targets: [
        .target(
            name: "SWDesignSystem",
            dependencies: [
                .product(name: "CachedAsyncImage", package: "CachedAsyncImage")
            ]
        )
    ]
)
