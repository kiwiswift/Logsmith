// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(logger))
public macro Loggerai(category: String? = nil) = #externalMacro(module: "LoggeraiMacros", type: "LoggeraiMacro")
