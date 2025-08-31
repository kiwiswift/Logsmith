import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Macro implementation that injects an `OSLog.Logger` into a type.
///
/// Generates:
///  - `static let <name>: OSLog.Logger = { ... }()`
///  - (optionally) `var <name>: OSLog.Logger { Self.<name> }`
public struct LoggableMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract type name
        guard let typeNameToken = declaration.as(ClassDeclSyntax.self)?.name ??
                declaration.as(StructDeclSyntax.self)?.name ??
                declaration.as(ActorDeclSyntax.self)?.name ??
                declaration.as(EnumDeclSyntax.self)?.name else {
            throw LoggerError.onlyApplicableToNamedTypes
        }
        
        // Helper to read labeled arguments
        let args = node.arguments?.as(LabeledExprListSyntax.self)
        
        func findArgument(_ label: String) -> ExprSyntax? {
            args?.first(where: { $0.label?.text == label })?.expression
        }
        
        func stringLiteralValue(from expr: ExprSyntax?) -> String? {
            guard let lit = expr?.as(StringLiteralExprSyntax.self) else { return nil }
            // Join all string segments (handles multi-part literals)
            return lit.segments.compactMap { segment in
                segment.as(StringSegmentSyntax.self)?.content.text
            }.joined()
        }
        
        // Category: either a string literal, any other expression (inserted raw), or the type name
        let categoryExprSource: String
        if let provided = findArgument("category") {
            if let str = stringLiteralValue(from: provided) {
                // Quote literal content
                categoryExprSource = "\"\(str)\""
            } else {
                // Use raw expression text (e.g. a constant like MyConstants.logCategory)
                categoryExprSource = provided.description.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            categoryExprSource = "\"\(typeNameToken.text)\""
        }
        
        // Subsystem: either a literal/expression provided, or default to Bundle.main.bundleIdentifier ?? "com.unknown.app"
        let subsystemExprSource: String
        if let provided = findArgument("subsystem") {
            if let str = stringLiteralValue(from: provided) {
                subsystemExprSource = "\"\(str)\""
            } else {
                subsystemExprSource = provided.description.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } else {
            subsystemExprSource = "Bundle.main.bundleIdentifier ?? \"com.unknown.app\""
        }
        
        // Name: property identifier - must be a simple string literal in the attribute (defaults to "logger")
        let nameIdentifier: String
        if let provided = findArgument("name"), let str = stringLiteralValue(from: provided), !str.isEmpty {
            nameIdentifier = str
        } else {
            nameIdentifier = "logger"
        }
        
        // staticOnly: boolean literal (defaults to false)
        var staticOnly = false
        if let provided = findArgument("staticOnly"), let boolLit = provided.as(BooleanLiteralExprSyntax.self) {
            staticOnly = boolLit.literal.text == "true"
        }
        
        // Build generated members. Always generate a static logger; optionally generate an instance computed var and helpers.
        var members: [DeclSyntax] = []
        
        let staticLoggerDecl: DeclSyntax = """
        static let \(raw: nameIdentifier): Logger = {
            return Logger(
                subsystem: \(raw: subsystemExprSource),
                category: \(raw: categoryExprSource)
            )
        }()
        """
        members.append(staticLoggerDecl)
        
        if !staticOnly {
            let instanceDecl: DeclSyntax = """
            var \(raw: nameIdentifier): Logger { Self.\(raw: nameIdentifier) }
            """
            members.append(instanceDecl)
            
            // Helper methods (do not pass file/function/line to OSLog.Logger APIs)
            let helpers: [DeclSyntax] = [
                // logDebug
                """
                func logDebug(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).debug("📝 \\(text)")
                }
                """,
                // logInfo
                """
                func logInfo(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).info("ℹ️ \\(text)")
                }
                """,
                // logError
                """
                func logError(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).error("❌ \\(text)")
                }
                """,
                // log (default)
                """
                func log(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).log("📜 \\(text)")
                }
                """,
                // logVerbose
                """
                func logVerbose(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).debug("💬 \\(text)")
                }
                """,
                // logWarning
                """
                func logWarning(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).error("⚠️ \\(text)")
                }
                """,
                // logCritical
                """
                func logCritical(_ message: @autoclosure () -> String, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
                    let text = message()
                    \(raw: nameIdentifier).fault("💣 \\(text)")
                }
                """
            ]
            members.append(contentsOf: helpers)
        }
        
        return members
    }
}

enum LoggerError: Error, CustomStringConvertible {
    case onlyApplicableToNamedTypes
    case missingSubsystemArgument
    
    var description: String {
        switch self {
        case .onlyApplicableToNamedTypes:
            return "This macro can only be applied to classes, structs, enums, or actors"
        case .missingSubsystemArgument:
            return "Subsystem argument is required"
        }
    }
}

@main
struct LogsmithMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoggableMacro.self
    ]
}
