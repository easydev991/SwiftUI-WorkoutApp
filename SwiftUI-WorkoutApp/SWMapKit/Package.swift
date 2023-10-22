// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SWMapKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "SWMapKit", targets: ["SWMapKit"])
    ],
    targets: [.target(name: "SWMapKit")]
)
