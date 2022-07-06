// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ACFreedom",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "ACFreedom",
            targets: ["ACFreedom"]),
        .executable(name: "ACFreedomApp", targets: ["ACFreedomApp"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.40.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.2.3")
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
//        "NIO", "Logging", "AnyCodable", "CryptoSwift"
        .target(
            name: "ACFreedom",
            dependencies: [
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "CryptoSwift", package: "swift-log"),
                .product(name: "Logging", package: "swift-nio"),
                .product(name: "AnyCodable", package: "AnyCodable"),

            ]),
        .target(
            name: "ACFreedomApp",
            dependencies: [
                .target(name: "ACFreedom")

            ]),
        .testTarget(
            name: "ACFreedomTests",
            dependencies: ["ACFreedom"]),
    ]
)
