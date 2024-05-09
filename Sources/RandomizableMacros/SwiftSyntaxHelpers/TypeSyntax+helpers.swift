import SwiftSyntax

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
