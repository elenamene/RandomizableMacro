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
#if DEBUG
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
            throw DiagnosticError.notAValidType
        }
        return syntax.map { [$0] } ?? []
#else
   return []
#endif
    }
}

private extension RandomizableMacro {
    
    // MARK: - Struct
    
    static func generateExtensionForStruct(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(type): Randomizable") {
            // Use init parameters if present else use stored properties
            let parameters: [Parameter] = if let initParams = decl.firstInitializerParameters {
                initParams.map { $0.toDeclParameter }
            } else {
                decl.propertiesToInitialize.map { $0.toDeclParameter }
            }
            
            let funcDeclParameters = parameters
                .compactMap { "\n\($0.name): \($0.type) = .makeRandom()" }
                .joined(separator: ", ")
            
            let funcBlocInitParameters = parameters
                .map {
                    if $0.label == "_" { return "\n\($0.name)" }
                    return  "\n\($0.name): \($0.name)"
                }
                .joined(separator: ", ")
            
            try FunctionDeclSyntax("static\(raw: decl.accessLevel) func makeRandomWith(\(raw: funcDeclParameters)\n) -> Self") {
                ".init(\(raw: funcBlocInitParameters)\n)"
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
