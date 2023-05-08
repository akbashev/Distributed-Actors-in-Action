// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "GoTicks",
  platforms: [
    .macOS("13.3")
  ],
  products: [
    .library(name: "Backend", targets: ["Backend"]),
    .library(name: "Frontend", targets: ["Frontend"]),
    .library(name: "Models", targets: ["Models"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
    .package(url: "https://github.com/apple/swift-distributed-actors.git", branch: "main"),
    .package(url: "https://github.com/apple/swift-foundation.git", branch: "main"),
    .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define a module or a test suite.
    // Targets can depend on other targets in this package, and on products in packages this package depends on.
    .target(
      name: "Backend",
      dependencies: [
        "Models",
        .product(
          name: "DistributedCluster",
          package: "swift-distributed-actors"
        ),
      ]
    ),
    .target(
      name: "Frontend",
      dependencies: [
        "Models",
        .product(
          name: "Vapor",
          package: "vapor"
        )
      ]
    ),
    .executableTarget(
      name: "goticks",
      dependencies: [
        "Backend",
        "Frontend"
      ]
    ),
    .target(
      name: "Models",
      dependencies: []
    )
  ]
)
