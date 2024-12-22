// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Printer-NhaDv",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Printer-NhaDv",
            targets: ["Printer-NhaDv"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Kitura/BlueSocket.git", .upToNextMajor(from: "2.0.2"))
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Printer-NhaDv",
            dependencies: ["Socket"]),
        .testTarget(
            name: "Printer-NhaDvTests",
            dependencies: ["Printer-NhaDv"]
        ),
    ]
)
