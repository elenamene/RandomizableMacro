import SwiftSyntax

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
        get throws {
            try bindings
                .first?
                .typeAnnotation?.as(TypeAnnotationSyntax.self)?
                .type
                .typeName ?? ""
        }
    }
    
    var toDeclParameter: Parameter {
        get throws {
            Parameter(
                name: propertyName,
                label: propertyName,
                type: try propertyType
            )
        }
    }
}
