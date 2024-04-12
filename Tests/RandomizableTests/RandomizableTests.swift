import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(RandomizableMacros)
import RandomizableMacros

let testMacros: [String: Macro.Type] = [
    "randomizable": RandomizableMacro.self,
]
#endif

final class RandomizableTests: XCTestCase {
    func testMacro_withStruct() throws {
        #if canImport(RandomizableMacros)
        assertMacroExpansion(
            """
            @Randomizable
            struct Flight {
                let id: Int
                let destination: String
                
                static let ignoredStaticProperty = ""
                var ignoredComputedProperty: String { "" }
                private var ignoredPrivateProperty = 0
            }
            """,
            expandedSource: """
            extension Flight: Randomizable {
                static func makeRandomWith(
                    id: Int = .makeRandom(),
                    destination: String = .makeRandom()
                ) -> Self {
                    .init(
                        id: id,
                        destination: destination
                    )
                }
                static func makeRandom() -> Self {
                    makeRandomWith()
                }
            }
            """,
            macros: testMacros
        )
#else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
    
//    func testMacro_withStruct() throws {
//        #if canImport(RandomizableMacros)
//        assertMacroExpansion(
//            """
//            @Randomizable
//            struct Flight {
//                let id: Int
//                let destination: String
//                
//                static let ignoredStaticProperty = ""
//                var ignoredComputedProperty: String { "" }
//                private var ignoredPrivateProperty = 0
//            }
//            """,
//            expandedSource: """
//            extension Flight: Randomizable {
//                static func makeRandomWith(
//                    id: Int = .makeRandom(),
//                    destination: String = .makeRandom()
//                ) -> Self {
//                    .init(
//                        id: id,
//                        destination: destination
//                    )
//                }
//                static func makeRandom() -> Self {
//                    makeRandomWith()
//                }
//            }
//            """,
//            macros: testMacros
//        )
//#else
//        throw XCTSkip("macros are only supported when running tests for the host platform")
//        #endif
//    }
    
    func testMacro_withEnum() throws {
    }
    
    func testMacro_withClass() throws {
    }
    
    func testMacro_withProtocol() throws {
    }
    
    func testMacro_withPrivateType() throws {
    }
    
    func testMacro_withPublicType() throws {
    }
    
    func testMacro_withNonSupportedType() throws {
    }
}

