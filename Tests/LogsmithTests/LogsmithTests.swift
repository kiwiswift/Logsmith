import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LogsmithMacros)
import LogsmithMacros
#endif

final class LogsmithTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(record: false,
                         macros: [LoggableMacro.self]) {
            super.invokeTest()
        }
    }

    func test_MacroWithDefaultValues() throws {
        assertMacro {
        """
        @Loggable
        class Example {
            func greet(name: String) {
                logger.info("Hello, \\(name)! This is a greeting from the Logsmith macro.")
            }
        }

        """
        } expansion: {
            #"""
            class Example {
                func greet(name: String) {
                    logger.info("Hello, \(name)! This is a greeting from the Logsmith macro.")
                }

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "Example"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """#
        }
    }

    func test_Struct_Defaults() {
        assertMacro {
            """
            @Loggable
            struct Widget {}
            """
        } expansion: {
            """
            struct Widget {

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "Widget"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_Actor_Defaults() {
        assertMacro {
            """
            @Loggable
            actor Worker {}
            """
        } expansion: {
            """
            actor Worker {

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "Worker"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_Enum_Defaults() {
        assertMacro {
            """
            @Loggable
            enum Mode { case a, b }
            """
        } expansion: {
            """
            enum Mode { case a, b 

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "Mode"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_CustomCategoryAndSubsystem_Literals() {
        assertMacro {
            """
            @Loggable(category: "Networking", subsystem: "com.example.app")
            final class APIClient {}
            """
        } expansion: {
            """
            final class APIClient {

                static let logger: Logger = {
                    return Logger(
                        subsystem: "com.example.app",
                        category: "Networking"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_CustomCategoryAndSubsystem_Expressions() {
        assertMacro {
            """
            enum IDs {
                static let bundle = "com.example.dynamic"
                static let cat = "DynamicCategory"
            }

            @Loggable(category: IDs.cat, subsystem: IDs.bundle)
            class DynamicLoggerOwner {}
            """
        } expansion: {
            """
            enum IDs {
                static let bundle = "com.example.dynamic"
                static let cat = "DynamicCategory"
            }
            class DynamicLoggerOwner {

                static let logger: Logger = {
                    return Logger(
                        subsystem: IDs.bundle,
                        category: IDs.cat
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_CustomName_DefaultsElsewhereUnaffected() {
        assertMacro {
            """
            @Loggable(name: "log")
            struct CustomName {}
            """
        } expansion: {
            """
            struct CustomName {

                static let log: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "CustomName"
                    )
                }()

                var log: Logger {
                    Self.log
                }
            }
            """
        }
    }

    func test_StaticOnly_NoInstanceProperty() {
        assertMacro {
            """
            @Loggable(staticOnly: true)
            class StaticOnly {}
            """
        } expansion: {
            """
            class StaticOnly {

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "StaticOnly"
                    )
                }()
            }
            """
        }
    }

    func test_CustomAllArguments() {
        assertMacro {
            """
            @Loggable(category: "UI", subsystem: "com.example.ui", name: "uiLogger", staticOnly: false)
            class ViewController {}
            """
        } expansion: {
            """
            class ViewController {

                static let uiLogger: Logger = {
                    return Logger(
                        subsystem: "com.example.ui",
                        category: "UI"
                    )
                }()

                var uiLogger: Logger {
                    Self.uiLogger
                }
            }
            """
        }
    }

    func test_GenericType_UsesTypeNameAsCategoryByDefault() {
        assertMacro {
            """
            @Loggable
            struct Box<T> { let value: T }
            """
        } expansion: {
            """
            struct Box<T> { let value: T 

                static let logger: Logger = {
                    return Logger(
                        subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                        category: "Box"
                    )
                }()

                var logger: Logger {
                    Self.logger
                }
            }
            """
        }
    }

    func test_NestedType_UsesOwnTypeNameAsCategory() {
        assertMacro {
            """
            struct Outer {
                @Loggable
                struct Inner {}
            }
            """
        } expansion: {
            """
            struct Outer {
                struct Inner {

                    static let logger: Logger = {
                        return Logger(
                            subsystem: Bundle.main.bundleIdentifier ?? "com.unknown.app",
                            category: "Inner"
                        )
                    }()

                    var logger: Logger {
                        Self.logger
                    }
            }
            }
            """
        }
    }

    func test_Protocol_IsUnsupported_Diagnostic() {
        assertMacro {
            """
            @Loggable
            protocol P {}
            """
        } diagnostics: {
            """
            @Loggable
            ┬────────
            ╰─ 🛑 This macro can only be applied to classes, structs, enums, or actors
            protocol P {}
            """
        }
    }

    func test_Extension_OnUnnamedTarget_IsUnsupported_Diagnostic() {
        assertMacro {
            """
            @Loggable
            extension {}
            """
        } diagnostics: {
            """
            @Loggable
            ┬────────
            ╰─ 🛑 This macro can only be applied to classes, structs, enums, or actors
            extension {}
                      ╰─ 🛑 expected type in extension
                         ✏️ insert type
            """
        }
    }
}
