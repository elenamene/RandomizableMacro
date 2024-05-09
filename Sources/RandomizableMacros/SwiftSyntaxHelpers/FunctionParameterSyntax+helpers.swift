import SwiftSyntax

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
