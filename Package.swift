// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "windy-swift",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v9)
    ],
    products: [
        .library(name: "WindySwift", targets: ["WindySwift"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "WindySwift", dependencies: [], exclude: ["WindySwiftExample"]),
        .testTarget(name: "WindySwiftTests", dependencies: ["WindySwift"]),
    ]
)
