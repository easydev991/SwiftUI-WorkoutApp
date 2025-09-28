// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CachedAsyncImage",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "CachedAsyncImage", targets: ["CachedAsyncImage"])
    ],
    dependencies: [],
    targets: [
        .target(name: "CachedAsyncImage", dependencies: []),
        .testTarget(name: "CachedAsyncImageTests", dependencies: ["CachedAsyncImage"])
    ]
)
