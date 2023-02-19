// swift-tools-version: 5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShortAddressService",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "ShortAddressService",
            targets: ["ShortAddressService"]
        )
    ],
    dependencies: [
        .package(path: "../Utils")
    ],
    targets: [
        .target(
            name: "ShortAddressService",
            dependencies: ["Utils"]
        )
    ]
)
