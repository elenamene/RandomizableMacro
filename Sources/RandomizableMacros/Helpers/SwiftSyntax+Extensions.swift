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

extension TypeSyntax {
    var typeName: String {
        get throws {
            if let identifierType = self.as(IdentifierTypeSyntax.self)?.name.text {
                return identifierType
            }
            if let arrayType = self.as(ArrayTypeSyntax.self) {
                return "[\(try arrayType.element.typeName)]"
            }
            if let optionalType = self.as(OptionalTypeSyntax.self) {
                return "\(try optionalType.wrappedType.typeName)?"
            }
            if let dicType = self.as(DictionaryTypeSyntax.self) {
                return "[\(try dicType.key.typeName): \(try dicType.value.typeName)]"
            }
            if let tupleType = self.as(TupleTypeSyntax.self) {
                let typeList = try tupleType.elements
                    .map { try $0.type.typeName }
                    .joined(separator: ", ")
                return "(\(typeList))"
            }
            throw RandomizableMacro.DiagnosticError.unsupportedSyntaxType
        }
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
        get throws {
            Parameter(
                name: (secondName ?? firstName).text,
                label: firstName.text,
                type: try type.typeName
            )
        }
    }
}

struct Parameter {
    let name: String
    let label: String
    let type: String
}

extension Parameter {
    var makeRandomString: String {
        let types = type.components(separatedBy: ",")
        if types.count > 1 {
            let tupleTypeList = types
                .map { _ in ".makeRandom()" }
                .joined(separator: ", ")
            return "(\(tupleTypeList))"
        }
        return ".makeRandom()"
    }
}
