import Randomizable

@Randomizable
struct Flight {
    let id: Int
    let destination: String
    
    private let count = 0
    var title: String { ""}
}

@Randomizable
struct StructWithInit {
    let id: Int
    let name: String
    
    init(_ id: Int, name: String) {
        self.id = id
        self.name = name
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
    case flight
    case train
    case car
}

/*
@Randomizable
private class Trip {
    let services: [Service]
    var status: String
    
    init(services: [Service], status: String) {
        self.services = services
        self.status = status
    }
}
 */

print(
    Flight.makeRandom(),
    Flight.makeRandomWith(destination: "London"),
    Flight.makeRandomWith(id: 1234),
    Service.makeRandom(),
    StructWithInit.makeRandom(),
    StructWithInit.makeRandomWith(id: 123),
    StructWithInit.makeRandomWith(name: "ciao")
)
