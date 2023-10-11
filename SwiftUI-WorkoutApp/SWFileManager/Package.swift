// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWFileManager",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SWFileManager",
            targets: ["SWFileManager"]
        )
    ],
    targets: [
        .target(name: "SWFileManager"),
        .testTarget(
            name: "SWFileManagerTests",
            dependencies: ["SWFileManager"]
        )
    ]
)
