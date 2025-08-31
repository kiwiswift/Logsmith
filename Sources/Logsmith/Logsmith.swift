// The Swift Programming Language
// https://docs.swift.org/swift-book

@_exported import OSLog

// This macro generates a static logger, an instance logger, and helper methods.
// Because the member names can vary (custom `name:` parameter) and include multiple functions,
// we must declare that it may add arbitrary members.
@attached(member, names: arbitrary)
public macro Loggable(
    category: String? = nil,
    subsystem: String? = nil,
    name: String = "logger",
    staticOnly: Bool = false
) = #externalMacro(module: "LogsmithMacros", type: "LoggableMacro")
