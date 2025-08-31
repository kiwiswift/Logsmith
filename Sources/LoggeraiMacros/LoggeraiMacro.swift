import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct LoggeraiMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Extract type name
        guard let typeName = declaration.as(ClassDeclSyntax.self)?.name ??
                declaration.as(StructDeclSyntax.self)?.name ??
                declaration.as(ActorDeclSyntax.self)?.name ??
                declaration.as(EnumDeclSyntax.self)?.name else {
            throw LoggerError.onlyApplicableToNamedTypes
        }

        // Extract category or use type name
        let category = node.arguments?.as(LabeledExprListSyntax.self)?
            .first(where: { $0.label?.text == "category" })?
            .expression.as(StringLiteralExprSyntax.self)?
            .segments.first?.as(StringSegmentSyntax.self)?.content.text
        ?? typeName.text

        // Generate logger property
        return [
            """
            static let logger: Logger = {
                let subsystem: String
                if let bundleID = Bundle.main.bundleIdentifier {
                    subsystem = bundleID
                } else {
                    subsystem = "com.unknown.app"
                }
                return os.Logger(
                    subsystem: subsystem,
                    category: "\(raw: category)"
                )
            }()
            
            var logger: os.Logger { Self.logger }
            """
        ]
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
struct LoggeraiMacros: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LoggeraiMacro.self
    ]
}
