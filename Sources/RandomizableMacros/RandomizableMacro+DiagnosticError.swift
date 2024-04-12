import SwiftDiagnostics

extension RandomizableMacro {
    public enum DiagnosticError: String, Error, DiagnosticMessage {
        case notAValidType
        case enumWithNoCases
        
        public var severity: DiagnosticSeverity {
            .error
        }
        
        public var diagnosticID: MessageID {
            MessageID(domain: "RandomizableMacro", id: rawValue)
        }

        public var message: String {
            switch self {
            case .notAValidType:
                return "'@Randomizable' can only be applied to a 'struct', 'class', 'enum` and 'protocol`"
            case .enumWithNoCases:
                return "Can't use '@Randomizable' with no enum cases"
            }
        }
    }
}
