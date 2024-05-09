import SwiftDiagnostics

extension RandomizableMacro {
    public enum DiagnosticError: String, Error, DiagnosticMessage {
        case unsupportedType
        case enumWithNoCases
        case unsupportedSyntaxType
        case privateObjectsNotSupported
        
        public var severity: DiagnosticSeverity {
            .error
        }
        
        public var diagnosticID: MessageID {
            MessageID(domain: "RandomizableMacro", id: rawValue)
        }

        public var message: String {
            switch self {
            case .unsupportedType:
                return "'@Randomizable' can only be applied to a 'struct', 'class', 'enum` and 'protocol`"
            case .enumWithNoCases:
                return "Can't use '@Randomizable' with no enum cases"
            case .unsupportedSyntaxType:
                return "Unsupported type"
            case .privateObjectsNotSupported:
                return "'@Randomizable' cannot be applied to private objects"
            }
        }
    }
}
