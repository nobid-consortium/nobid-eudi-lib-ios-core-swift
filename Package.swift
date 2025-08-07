// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "nobid-core",
    platforms: [.iOS(.v14)],  
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "nobid-core",
            targets: ["nobid-core"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.8.4"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/airsidemobile/JOSESwift.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "nobid-core",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                "CryptoSwift",
                "Swinject",
                "JOSESwift"
            ]),
    ]
)
