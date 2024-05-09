struct Parameter {
    let name: String
    let label: String
    let type: String
}

extension Parameter {
    var makeRandomString: String {
        let types = type.components(separatedBy: ",")
        if types.count > 1 {
            let tupleTypeList = types
                .map { _ in ".makeRandom()" }
                .joined(separator: ", ")
            return "(\(tupleTypeList))"
        }
        return ".makeRandom()"
    }
}
