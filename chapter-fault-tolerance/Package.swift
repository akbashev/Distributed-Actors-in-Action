// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LogProcessing",
    platforms: [
      .macOS("13.3")
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
//        .package(url: "https://github.com/apple/swift-distributed-actors.git", branch: "main"),
        .package(url: "https://github.com/apple/swift-foundation.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "LogProcessing",
            dependencies: [
//              .product(name: "DistributedCluster", package: "swift-distributed-actors"),
              .product(name: "FoundationEssentials", package: "swift-foundation")
            ]),
        .testTarget(
            name: "LogProcessingTests",
            dependencies: ["LogProcessing"]),
    ]
)
