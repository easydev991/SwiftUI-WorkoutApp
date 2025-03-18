// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWUtils",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SWUtils", targets: ["SWUtils"])
    ],
    targets: [
        .target(name: "SWUtils"),
        .testTarget(name: "SWUtilsTests", dependencies: ["SWUtils"])
    ]
)
