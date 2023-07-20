// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Words",
    platforms: [
      .macOS("13.0")
    ],
    dependencies: [
      // Dependencies declare other packages that this package depends on.
      // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/apple/swift-distributed-actors.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Words",
            dependencies: [
              .product(
                name: "DistributedCluster",
                package: "swift-distributed-actors"
              )
            ]
        )
    ]
)
