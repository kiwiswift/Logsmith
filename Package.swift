// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Loggerai",
    platforms: [
        // Macro plugins are built on macOS; use a recent version to match plugin requirements.
        .macOS(.v13),
        .iOS(.v15),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13)
    ],
    products: [
        .library(
            name: "Loggerai",
            targets: ["Loggerai"]
        ),
        .executable(
            name: "LoggeraiClient",
            targets: ["LoggeraiClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "600.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.4.0")
    ],
    targets: [
        .macro(
            name: "LoggeraiMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Loggerai",
            dependencies: ["LoggeraiMacros"]
        ),
        .executableTarget(
            name: "LoggeraiClient",
            dependencies: ["Loggerai"]
        ),
        .testTarget(
            name: "LoggeraiTests",
            dependencies: [
                "LoggeraiMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
