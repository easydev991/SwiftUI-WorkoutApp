// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LegacyImagePicker",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "LegacyImagePicker", targets: ["LegacyImagePicker"])
    ],
    dependencies: [],
    targets: [
        .target(name: "LegacyImagePicker", dependencies: [])
    ]
)
