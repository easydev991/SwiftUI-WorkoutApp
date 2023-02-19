// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DateFormatterService",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "DateFormatterService",
            targets: ["DateFormatterService"]
        )
    ],
    dependencies: [
        .package(path: "../Utils")
    ],
    targets: [
        .target(
            name: "DateFormatterService",
            dependencies: ["Utils"]
        ),
        .testTarget(
            name: "DateFormatterServiceTests",
            dependencies: ["DateFormatterService"]
        )
    ]
)
