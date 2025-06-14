// swift-tools-version: 6.1.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ClusteringMapView",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "ClusteringMapView", targets: ["ClusteringMapView"])
    ],
    targets: [
        .target(name: "ClusteringMapView"),
        .testTarget(name: "ClusteringMapViewTests", dependencies: ["ClusteringMapView"])
    ]
)
