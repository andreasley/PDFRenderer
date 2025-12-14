// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PDFRenderer",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "PDFRenderer",
            targets: ["PDFRenderer"]),
    ],
    targets: [
        .target(
            name: "PDFRenderer",
            dependencies: []),
        .testTarget(
            name: "PDFRendererTests",
            dependencies: ["PDFRenderer"]),
    ]
)
