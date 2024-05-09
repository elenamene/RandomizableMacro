import SwiftSyntax

extension DeclGroupSyntax {
    public var properties: [VariableDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(VariableDeclSyntax.self) }
    }
    
    public var propertiesToInitialize: [VariableDeclSyntax] {
        properties.filter {
            !$0.isComputedProperty &&
            !$0.isStaticProperty &&
            !$0.isPrivateProperty
        }
    }
    
    public var functions: [FunctionDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(FunctionDeclSyntax.self) }
    }
    
    public var initializers: [InitializerDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(InitializerDeclSyntax.self) }
    }
    
    public var firstInitializerParameters: FunctionParameterListSyntax? {
        initializers
            .first?
            .signature
            .parameterClause
            .parameters
    }
    
    public var associatedTypes: [AssociatedTypeDeclSyntax] {
        memberBlock.members.compactMap { $0.decl.as(AssociatedTypeDeclSyntax.self) }
    }
    
    var accessLevel: String {
        get throws {
            try modifiers.compactMap {
                switch $0.name.tokenKind {
                case .keyword(.public):
                    "public "
                case .keyword(.private):
                    throw RandomizableMacro.DiagnosticError.privateObjectsNotSupported
                default: nil
                }
            }.first ?? ""
        }
    }
}
