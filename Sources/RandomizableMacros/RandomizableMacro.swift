import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct RandomizableMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let syntax = switch declaration.kind {
        case .structDecl:
            try generateExtensionForStruct(decl: declaration, type: type)
        case .enumDecl:
            try generateExtensionForEnum(decl: declaration, type: type, context: context)
        case .classDecl:
            try generateExtensionForClass(decl: declaration, type: type)
        case .protocolDecl:
            try generateExtensionForProtocol(decl: declaration, type: type)
        default:
            let error = Diagnostic(
                node: node,
                message: DiagnosticError.notAValidType
            )
            context.diagnose(error)
            throw DiagnosticError.notAValidType
        }
        return syntax.map { [$0] } ?? []
    }
}

private extension RandomizableMacro {
    
    // MARK: - Struct
    
    static func generateExtensionForStruct(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(type): Randomizable") {
            
            // TODO: Add support for custom init in struct
            
            let declParameters = decl
                .propertiesToInitialize
                .map { "\n\($0.propertyName): \($0.propertyType) = .makeRandom()" }
                .joined(separator: ", ")
            
            let initParameters = decl.propertiesToInitialize
                .map { "\n\($0.propertyName): \($0.propertyName)" }
                .joined(separator: ", ")
            
            try FunctionDeclSyntax("static\(raw: decl.accessLevel) func makeRandomWith(\(raw: declParameters)\n) -> Self") {
                ".init(\(raw: initParameters)\n)"
            }
            
            try FunctionDeclSyntax("static\(raw: decl.accessLevel) func makeRandom() -> Self") {
                "makeRandomWith()"
            }
        }
    }
    
    // MARK: - Enum
    
    static func generateExtensionForEnum(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol, context: some MacroExpansionContext) throws -> ExtensionDeclSyntax? {
        guard let cases = decl.as(EnumDeclSyntax.self)?.cases, !cases.isEmpty else {
            let error = Diagnostic(
                node: decl.memberBlock,
                message: DiagnosticError.enumWithNoCases
            )
            context.diagnose(error)
            return nil
        }
        
        return try ExtensionDeclSyntax("extension \(type): Randomizable") {
            let casesList = cases
                .flatMap { $0 }
                .map { ".\($0.name.text)" }
                .joined(separator: ", ")
            
            // TODO: Add support for associated values
            
            try FunctionDeclSyntax("static \(raw: decl.accessLevel) func makeRandom() -> Self") {
                "[\(raw: casesList)].randomElement()!"
            }
        }
    }
    
    // MARK: - Class
    
    static func generateExtensionForClass(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("Not implemented")
    }
    
    // MARK: - Protocol
    
    static func generateExtensionForProtocol(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("Not implemented")
    }
}

@main
struct StubPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [RandomizableMacro.self]
}
