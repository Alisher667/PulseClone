// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

// Package for distribution, see Packages/ for packages for development.
let package = Package(
    name: "Pulse",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "Pulse", type: .dynamic, targets: ["Pulse"]),
        .library(name: "PulseCore", targets: ["PulseCore"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Pulse",
            dependencies: [.product(name: "Logging", package: "swift-log"), "PulseCore"],
            path: "Packages/Sources/Pulse"
        ),
        .binaryTarget(
            name: "PulseCore",
            url: "https://github.com/kean/Pulse/files/5951555/PulseCore-0.7.0.zip",
            checksum: "65c8dc856660b5a913e57b4c32dd8e819a1a9ffe8b6da7b11b8aa11afcc1d570"
        )
    ]
)
