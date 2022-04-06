// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EventLogUI",
    platforms: [
        .macOS(.v10_12),
        .iOS(.v15),
        .tvOS(.v10),
        .watchOS(.v3)
    ],
    products: [
        .library(
            name: "EventLogUI",
            targets: ["EventLogUI"]
        )
    ],
    targets: [
        .target(
            name: "EventLogUI",
            path: "Sources"
        ),
        .testTarget(
            name: "EventLogUITests",
            dependencies: ["EventLogUI"],
            path: "Tests",
            exclude: ["CheckCocoaPodsQualityIndexes.rb"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
