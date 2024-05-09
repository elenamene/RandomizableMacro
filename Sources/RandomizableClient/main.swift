import Randomizable

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

extension Flight {
    @Randomizable
    struct Segment {
        let id: String
    }
}

@Randomizable
public enum Service {
    case flight(id: Int, String)
    case train(ticket: String)
    case car(Int)
    case hotel(_ id: String)
    case taxi
}

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

print(
    Flight.makeRandom(),
    Flight.makeRandomWith(destination: "London"),
    Flight.makeRandomWith(id: 1234),
    StructWithInit.makeRandom(),
    StructWithInit.makeRandomWith(id: 123),
    Service.makeRandom()
)
