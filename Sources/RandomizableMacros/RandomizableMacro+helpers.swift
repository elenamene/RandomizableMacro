import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

extension RandomizableMacro {
    static func getParameters(decl: some DeclGroupSyntax, context: some MacroExpansionContext) -> [Parameter] {
        // Use init parameters if present else use stored properties
        if let initParams = decl.firstInitializerParameters {
            initParams.compactMap {
                if let param = try? $0.toDeclParameter {
                    return param
                } else {
                    context.diagnose(
                        Diagnostic(
                            node: $0,
                            message: DiagnosticError.unsupportedSyntaxType
                        )
                    )
                    return nil
                }
            }
        } else {
            decl.propertiesToInitialize.compactMap {
                if let param = try? $0.toDeclParameter {
                    return param
                } else {
                    context.diagnose(
                        Diagnostic(
                            node: $0,
                            message: DiagnosticError.unsupportedSyntaxType
                        )
                    )
                    return nil
                }
            }
        }
    }
}
