// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import OSLog
@attached(member, names: named(logger))
public macro Loggable(category: String? = nil) = #externalMacro(module: "LogsmithMacros", type: "LoggableMacro")
