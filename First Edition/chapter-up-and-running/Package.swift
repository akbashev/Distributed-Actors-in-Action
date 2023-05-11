// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "goticks",
    // macOS needed for Distributed actors
    platforms: [
      .macOS(.v13),
    ],
    dependencies: [
        // Used it for RestApi
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "goticks",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
              ]
            ),
        .testTarget(
            name: "goticksTests",
            dependencies: [
                "goticks"
            ]
        )
    ]
)
