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
                let destination: String?
                let segments: [Segment]
                let optionalArray: [Segment]?
                let dict: [Int: [Segment]]
                let tuple: (Int, String)
                
                static let ignoredStaticProperty = ""
                var ignoredComputedProperty: String { "" }
                private var ignoredPrivateProperty = 0
            }
            """,
            expandedSource:
            """
            struct Flight {
                let id: Int
                let destination: String?
                let segments: [Segment]
                let optionalArray: [Segment]?
                let dict: [Int: [Segment]]
                let tuple: (Int, String)
                
                static let ignoredStaticProperty = ""
                var ignoredComputedProperty: String { "" }
                private var ignoredPrivateProperty = 0
            }
            
            extension Flight: Randomizable {
                static func makeRandomWith(
                    id: Int = .makeRandom(),
                    destination: String? = .makeRandom(),
                    segments: [Segment] = .makeRandom(),
                    optionalArray: [Segment]? = .makeRandom(),
                    dict: [Int: [Segment]] = .makeRandom(),
                    tuple: (Int, String) = (.makeRandom(), .makeRandom())
                ) -> Self {
                    .init(
                        id: id,
                        destination: destination,
                        segments: segments,
                        optionalArray: optionalArray,
                        dict: dict,
                        tuple: tuple
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
                let destination: String?
                let flights: [Flight]
                let dict: [Int: [Flight]]
                
                init(
                    _ id: Int,
                    destination: String?,
                    flights: [Flight],
                    dict: [Int: [Flight]]
                ) {
                    self.id = id
                    self.destination = destination
                    self.flights = flights
                    self.dict = dict
                }
            }
            """,
            expandedSource:
            """
            struct StructWithInit {
                let id: Int
                let destination: String?
                let flights: [Flight]
                let dict: [Int: [Flight]]
                
                init(
                    _ id: Int,
                    destination: String?,
                    flights: [Flight],
                    dict: [Int: [Flight]]
                ) {
                    self.id = id
                    self.destination = destination
                    self.flights = flights
                    self.dict = dict
                }
            }
            
            extension StructWithInit: Randomizable {
                static func makeRandomWith(
                    id: Int = .makeRandom(),
                    destination: String? = .makeRandom(),
                    flights: [Flight] = .makeRandom(),
                    dict: [Int: [Flight]] = .makeRandom()
                ) -> Self {
                    .init(
                        id,
                        destination: destination,
                        flights: flights,
                        dict: dict
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
    
    func testMacro_withPublicStruct() throws {
        #if canImport(RandomizableMacros)
        assertMacroExpansion(
            """
            @Randomizable
            public struct Train {
                let id: Int
                let destination: String?
            }
            """,
            expandedSource:
            """
            public struct Train {
                let id: Int
                let destination: String?
            }
            
            extension Train: Randomizable {
                public static func makeRandomWith(
                    id: Int = .makeRandom(),
                    destination: String? = .makeRandom()
                ) -> Self {
                    .init(
                        id: id,
                        destination: destination
                    )
                }
                public static func makeRandom() -> Self {
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
                public static func makeRandom() -> Self {
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
        assertMacroExpansion(
            """
            @Randomizable
            class Trip {
                let id: Int
                let services: [Service]
                var status: String
                
                required init(
                    _ id: Int,
                    services: [Service],
                    status: String
                ) {
                    self.id = id
                    self.services = services
                    self.status = status
                }
            }
            """,
            expandedSource:
            """
            class Trip {
                let id: Int
                let services: [Service]
                var status: String
                
                required init(
                    _ id: Int,
                    services: [Service],
                    status: String
                ) {
                    self.id = id
                    self.services = services
                    self.status = status
                }
            }
            
            extension Trip: Randomizable {
                static func makeRandomWith(
                    id: Int = .makeRandom(),
                    services: [Service] = .makeRandom(),
                    status: String = .makeRandom()
                ) -> Self {
                    self.init(
                        id,
                        services: services,
                        status: status
                    )
                }
                static func makeRandom() -> Self {
                    makeRandomWith()
                }
            }
            """,
            macros: testMacros
        )
        
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

