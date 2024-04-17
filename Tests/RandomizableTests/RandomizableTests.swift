import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(RandomizableMacros)
import RandomizableMacros

let testMacros: [String: Macro.Type] = [
    "Randomizable": RandomizableMacro.self,
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
            expandedSource:
            """
            struct Flight {
                let id: Int
                let destination: String
                
                static let ignoredStaticProperty = ""
                var ignoredComputedProperty: String { "" }
                private var ignoredPrivateProperty = 0
            }
            
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
    
    func testMacro_withStruct_withInit() throws {
        #if canImport(RandomizableMacros)
        assertMacroExpansion(
            """
            @Randomizable
            struct StructWithInit {
                let id: Int
                let name: String
                
                init(_ id: Int, name: String) {
                    self.id = id
                    self.name = name
                }
            }
            """,
            expandedSource:
            """
            struct StructWithInit {
                let id: Int
                let name: String
                
                init(_ id: Int, name: String) {
                    self.id = id
                    self.name = name
                }
            }
            
            extension StructWithInit: Randomizable {
                static func makeRandomWith(
                    id: Int = .makeRandom(),
                    name: String = .makeRandom()
                ) -> Self {
                    .init(
                        id,
                        name: name
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
    
    func testMacro_withEnum() throws {
        assertMacroExpansion(
            """
            @Randomizable
            public enum Service {
                case flight
                case train
                case car
            }
            """,
            expandedSource:
            """
            public enum Service {
                case flight
                case train
                case car
            }
            
            extension Service: Randomizable {
                static public func makeRandom() -> Self {
                    [.flight, .train, .car].randomElement()!
                }
            }
            """,
            macros: testMacros
        )
    }
    
    func testMacro_withEnum_withAssociatedValues() throws {
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

