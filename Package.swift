// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Logsmith",
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
            name: "Logsmith",
            targets: ["Logsmith"]
        ),
        .executable(
            name: "LogsmithClient",
            targets: ["LogsmithClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", exact: "600.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.4.0")
    ],
    targets: [
        .macro(
            name: "LogsmithMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(
            name: "Logsmith",
            dependencies: ["LogsmithMacros"]
        ),
        .executableTarget(
            name: "LogsmithClient",
            dependencies: ["Logsmith"]
        ),
        .testTarget(
            name: "LogsmithTests",
            dependencies: [
                "LogsmithMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ]
)
