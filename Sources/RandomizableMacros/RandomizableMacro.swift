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
            try generateExtensionForStruct(decl: declaration, type: type, context: context)
        case .enumDecl:
            try generateExtensionForEnum(decl: declaration, type: type, context: context)
        case .classDecl:
            try generateExtensionForClass(decl: declaration, type: type,context: context)
        case .protocolDecl:
            try generateExtensionForProtocol(decl: declaration, type: type)
        default:
            throw DiagnosticError.unsupportedSyntaxType
        }
        return syntax.map { [$0] } ?? []
#else
   return []
#endif
    }
}

private extension RandomizableMacro {
    
    // MARK: - Struct
    
    static func generateExtensionForStruct(
        decl: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        context: some MacroExpansionContext
    ) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(type): Randomizable") {
            let parameters = getParameters(decl: decl, context: context)
            
            let funcDeclParameters = parameters
                .compactMap { "\n\($0.name): \($0.type) = \($0.makeRandomString)" }
                .joined(separator: ", ")
            
            let funcBlocInitParameters = parameters
                .map {
                    if $0.label == "_" { return "\n\($0.name)" }
                    return  "\n\($0.name): \($0.name)"
                }
                .joined(separator: ", ")
            
            try FunctionDeclSyntax("\(raw: decl.accessLevel)static func makeRandomWith(\(raw: funcDeclParameters)\n) -> Self") {
                ".init(\(raw: funcBlocInitParameters)\n)"
            }
            
            try FunctionDeclSyntax("\(raw: decl.accessLevel)static func makeRandom() -> Self") {
                "makeRandomWith()"
            }
        }
    }
    
    // MARK: - Enum
    
    static func generateExtensionForEnum(decl: some DeclGroupSyntax, type: some TypeSyntaxProtocol, context: some MacroExpansionContext) throws -> ExtensionDeclSyntax? {
        guard let cases = decl.as(EnumDeclSyntax.self)?.cases, !cases.isEmpty else {
            context.diagnose(
                Diagnostic(
                    node: decl.memberBlock,
                    message: DiagnosticError.enumWithNoCases
                )
            )
            return nil
        }
        
        return try ExtensionDeclSyntax("extension \(type): Randomizable") {
            let casesList = cases
                .flatMap { $0 }
                .map { ".\($0.name.text)\($0.associatedValueList)" }
                .joined(separator: ",\n")
            
            try FunctionDeclSyntax("\(raw: decl.accessLevel)static func makeRandom() -> Self") {
                "[\n\(raw: casesList)\n].randomElement()!"
            }
        }
    }
    
    // MARK: - Class
    
    static func generateExtensionForClass(
        decl: some DeclGroupSyntax,
        type: some TypeSyntaxProtocol,
        context: some MacroExpansionContext
    ) throws -> ExtensionDeclSyntax {
        try ExtensionDeclSyntax("extension \(type): Randomizable") {
            let parameters = getParameters(decl: decl, context: context)
            
            let funcDeclParameters = parameters
                .compactMap { "\n\($0.name): \($0.type) = \($0.makeRandomString)" }
                .joined(separator: ", ")
            
            let funcBlocInitParameters = parameters
                .map {
                    if $0.label == "_" { return "\n\($0.name)" }
                    return  "\n\($0.name): \($0.name)"
                }
                .joined(separator: ", ")
            
            try FunctionDeclSyntax("\(raw: decl.accessLevel)static func makeRandomWith(\(raw: funcDeclParameters)\n) -> Self") {
                "self.init(\(raw: funcBlocInitParameters)\n)"
            }
            
            try FunctionDeclSyntax("\(raw: decl.accessLevel)static func makeRandom() -> Self") {
                "makeRandomWith()"
            }
        }
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
