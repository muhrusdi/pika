import Vapor
import VaporMustache
import HTTP
import VaporMySQL

let mysql = try VaporMySQL.Provider(host: "localhost", user: "root", password: "", database: "pokedex")

let drop = Droplet(preparations: [Pokemon.self], providers: [VaporMustache.Provider.self], initializedProviders: [mysql])

drop.post("pokemon") { request in
  drop.console.info("tach 1", newLine: true)

  guard let name = request.data["name"].string else {
    throw Abort.custom(status: .badRequest, message: "Please include a name")
  }

  drop.console.info("tach 2", newLine: true)

  if let pokemon = try Pokemon.query().filter("name", name).first() {
    throw Abort.custom(status: .badRequest, message: "Duplicated pokemon")
  }

  drop.console.info("tach 3", newLine: true)

  let response = try drop.client.get("http://pokeapi.co/api/v2/pokemon/\(name.lowercased())")
  guard let id = response.data["id"]?.int else {
    throw Abort.custom(status: .badRequest, message: "Invalid pokemon name")
  }

  drop.console.info("Id: \(id)")

  var pokemon = Pokemon(name: name, time: 0)

  try pokemon.save()

  return pokemon
}

drop.get("pokemon", Pokemon.self) { request, pokemon in
  let response = try drop.client.get("http://pokeapi.co/api/v2/pokemon/\(pokemon.name.lowercased())/")

  guard let image = response.data["sprites", "front_default"].string else {
        throw Abort.custom(status: .badRequest, message: "Invalid Pokémon name.")
    }

    return try drop.view("pokemon.mustache", context: [
        "image": image,
        "name": pokemon.name,
        "date": pokemon.readableDate
    ])
}

class InvalidParameterMiddleware: Middleware {

    func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: request)
        } catch Abort.notFound {
            return try drop.view("not-found.mustache").makeResponse()
        }
    }

}

let middleware = InvalidParameterMiddleware()

drop.middleware.append(middleware)

drop.serve()
