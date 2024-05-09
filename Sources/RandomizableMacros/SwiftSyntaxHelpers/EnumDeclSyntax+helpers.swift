import SwiftSyntax

extension EnumDeclSyntax {
    var cases: [EnumCaseElementListSyntax] {
        memberBlock.members
            .compactMap { $0.decl.as(EnumCaseDeclSyntax.self) }
            .map { $0.elements }
    }
}

extension EnumCaseElementSyntax {
    var associatedValueList: String {
        if let parameterClause {
            let makeRandomList = parameterClause.parameters
                .map {
                    if let label = $0.firstName,
                       !label.text.contains("_") {
                        return  "\(label): .makeRandom()"
                    }
                    return ".makeRandom()"
                }
                .joined(separator: ", ")
            return "(\(makeRandomList))"
        }
        return ""
    }
}
