// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWKeychain",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SWKeychain", targets: ["SWKeychain"]
        )
    ],
    targets: [
        .target(name: "SWKeychain"),
        .testTarget(name: "SWKeychainTests", dependencies: ["SWKeychain"])
    ]
)
