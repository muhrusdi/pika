import Vapor
import Fluent

final class Pokemon: Model {
    var id: Node?
    var name: String
    var time: Int
    
    init(name: String, time: Int) {
        self.name = name
        self.time = time
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        name = try node.extract("name")
        time = try node.extract("time")
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "name": name,
            "time": time
        ])
    }

    static func prepare(_ database: Database) throws {
        //
    }

    static func revert(_ database: Database) throws {
        //
    }
}
