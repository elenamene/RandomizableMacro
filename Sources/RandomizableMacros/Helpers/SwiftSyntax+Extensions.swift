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
        modifiers.compactMap {
            switch $0.name.tokenKind {
            case .keyword(.public): "public"
            case .keyword(.private): "private"
            default: nil
            }
        }.first ?? ""
    }
}

extension VariableDeclSyntax {
    public var isComputedProperty: Bool {
        bindings.first?.accessorBlock != nil
    }
    
    public var isStaticProperty: Bool {
        modifiers.lazy.contains(where: { $0.name.tokenKind == .keyword(.static) })
    }
    
    public var isPrivateProperty: Bool {
        modifiers.lazy.contains(where: { $0.name.tokenKind == .keyword(.private) })
    }
    
    public var propertyName: String {
        bindings
            .first?
            .pattern.as(IdentifierPatternSyntax.self)?
            .identifier
            .text ?? ""
    }
    
    public var propertyType: String {
        bindings
            .first?
            .typeAnnotation?.as(TypeAnnotationSyntax.self)?
            .type.as(IdentifierTypeSyntax.self)?
            .name.text ?? ""
    }
    
    var toDeclParameter: Parameter {
        Parameter(
            name: propertyName,
            label: propertyName,
            type: propertyType
        )
    }
}

extension EnumDeclSyntax {
    var cases: [EnumCaseElementListSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .map { $0.elements }
    }
}

extension FunctionParameterSyntax {
    var toDeclParameter: Parameter {
        Parameter(
            name: (secondName ?? firstName).text,
            label: firstName.text,
            type: paramType
        )
    }
    
    var paramType: String {
        type.as(IdentifierTypeSyntax.self)?.name.text ?? ""
    }
}

struct Parameter {
    let name: String
    let label: String
    let type: String
}
