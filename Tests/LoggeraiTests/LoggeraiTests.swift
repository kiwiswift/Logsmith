import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest
import MacroTesting

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(LoggeraiMacros)
import LoggeraiMacros
#endif

final class LoggeraiTests: XCTestCase {

    override func invokeTest() {
        withMacroTesting(record: false,
                         macros: [LoggeraiMacro.self]) {
            super.invokeTest()
        }
    }

    func testMacro() throws {
        assertMacro {
        """
        @Loggerai
        class Example {
            func greet(name: String) {
                logger.info("Hello, \(name)! This is a greeting from the Loggerai macro.")
            }
        }

        """
        } expansion: {
            """
            class Example {
                func greet(name: String) {
                    logger.info("Hello, -[LoggeraiTests testMacro]! This is a greeting from the Loggerai macro.")
                }

                static let logger: os.Logger = {
                    let subsystem: String
                    if let bundleID = Bundle.main.bundleIdentifier {
                        subsystem = bundleID
                    } else {
                        subsystem = "com.unknown.app"
                    }
                    return os.Logger(
                        subsystem: subsystem,
                        category: "Example"
                    )
                }()
            
                var logger: os.Logger { Self.logger }
            }
            """
        }
    }
}
