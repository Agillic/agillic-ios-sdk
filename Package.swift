// swift-tools-version:5.1
import PackageDescription

let package = Package(
  name: "AgillicSDK",
  platforms: [.iOS(.v11)],
  products: [
    .library(name: "AgillicSDK", targets: ["AgillicSDK"]),
  ],
  dependencies: [
   .package(url: "https://github.com/snowplow/snowplow-objc-tracker", .exact("1.7.1"))
 ],
  targets: [
    .target(
        name: "AgillicSDK",
        dependencies: ["SnowplowTracker"],
        path: "src/AgillicSDK")
  ]
)
