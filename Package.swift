// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PGTest",
    platforms: [
        .macOS(.v12),
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PGTest",
            targets: ["PGTest"]
        ),
    ],
    targets: [
        .target(name: "PGTest")
    ]
)
