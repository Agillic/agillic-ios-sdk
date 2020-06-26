// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "AgillicSDK",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "AgillicSDK",
            targets: ["AgillicSDK"]),
    ],
    dependencies: [
        .package(name: "SnowplowTracker", url: "https://github.com/snowplow/snowplow-objc-tracker", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "AgillicSDK",
            dependencies: ["SnowplowTracker"],
            path: "AgillicSDK",
            publicHeadersPath: ".")
    ]
)
